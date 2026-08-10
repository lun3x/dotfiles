-- Diff indicators in the sign column.
--
-- In a colocated jj repo (.jj + .git) jj pins the git HEAD to @- and resets the
-- index to match, so a plain worktree diff is exactly the @ working-copy change
-- -- the same thing the jj-kaizen VSCode extension draws.
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "▁" },
			topdelete = { text = "▔" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		watch_gitdir = { follow_files = true },
		attach_to_untracked = true,
		update_debounce = 100,
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			-- In a jj repo, diff against HEAD (== @-) rather than the git index.
			-- jj keeps the index in sync anyway, but pinning to HEAD means a
			-- stray `git add` can never make the gutter disagree with `jj diff`.
			-- Plain-git repos are left alone, where staged/unstaged still means
			-- something.
			--
			-- Two sharp edges: on_attach runs *before* gitsigns registers the
			-- buffer in its cache, so change_base would no-op -- hence the
			-- schedule. And change_base(_, false) acts on the *current* buffer,
			-- not on bufnr -- hence the buf_call.
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name ~= "" then
				local found = vim.fs.find(".jj", {
					upward = true,
					type = "directory",
					path = vim.fs.dirname(name),
				})
				if found[1] then
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(bufnr) then
							vim.api.nvim_buf_call(bufnr, function()
								gs.change_base("HEAD", false)
							end)
						end
					end)
				end
			end

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			-- Hunk navigation. Falls back to vim's own ]c/[c inside :diffthis.
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Next hunk")

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Previous hunk")

			-- Inspect. preview_hunk shows removed lines, which have no gutter row
			-- of their own -- this is how you read a deletion.
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hd", gs.diffthis, "Diff against @-")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame line")

			-- Discard back to @-, i.e. a line-range `jj restore`.
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset selected lines")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

			-- Toggles.
			map("n", "<leader>ht", gs.toggle_signs, "Toggle diff signs")
			map("n", "<leader>hl", gs.toggle_linehl, "Toggle line highlight")
		end,
	},
	config = function(_, opts)
		require("gitsigns").setup(opts)

		-- jj commands run in another terminal move HEAD (jj new, jj commit,
		-- jj edit). The gitdir watcher catches most of it; refreshing on focus
		-- covers the rest.
		vim.api.nvim_create_autocmd("FocusGained", {
			callback = function()
				pcall(require("gitsigns").refresh)
			end,
		})
	end,
}
