local config_dir = vim.fn.stdpath("config")
package.path = config_dir .. "/?.lua;" .. package.path
require("keymaps")
require("options")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

--Disable document color, so annoying lol
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.lsp.document_color.enable(false, args.buf)
	end,
})
-- Highlight Yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})
-- LSP Root Markers
vim.lsp.config("*", {
	root_markers = { ".git", "package.json" }, -- Add or remove markers as needed
})

require("lazy").setup({
	-- Dependencies
	{ "mason-org/mason.nvim", config = true },
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	{ "MunifTanjim/nui.nvim" },
	{ "mason-org/mason-lspconfig.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	-------------------------------------------------
	-- Autoclose parentheses, brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	-- Lualine
	{
		"nvim-lualine/lualine.nvim",
		event = { "VimEnter" },
		dependencies = {
			{
				"linrongbin16/lsp-progress.nvim",
				config = function()
					require("lsp-progress").setup()
				end,
			},
		},
		opts = {
			options = {
				theme = "tokyonight",
				section_separators = "",
				disabled_filetypes = { "alpha", "neo-tree" },
			},
			sections = {
				lualine_c = {
					function()
						return require("lsp-progress").progress()
					end,
				},
			},
		},
	},

	-- Color Scheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",
				on_highlights = function(hl, c)
					hl.Delimiter = { fg = "#eeeeee" }
					hl["@tag.delimiter.tsx"] = { fg = "#cecece" }
					hl["@tag.builtin.tsx"] = { fg = "#E06C75" }
					hl["@tag.tsx"] = { fg = "#e5c07b" }
					hl["@tag.attribute.tsx"] = { fg = c.magenta }
					hl["@keyword.tsx"] = { fg = c.purple, italic = true }
					hl["@keyword.return.tsx"] = { fg = c.purple, italic = true }
					hl["@markup.heading.1.tsx"] = { fg = "#c0caf5" }
					hl["@property.graphql"] = { fg = "#c0caf5" }
					hl["@punctuation.bracket.graphql"] = { fg = c.purple }
				end,
				on_colors = function(colors)
					-- colors.bg = "#272b41"
				end,
			})
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "latte",
			})
		end,
	},
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
	},
	-- Folding
	require("plugins.nvim-ufo"),

	-- Formatting
	require("plugins.none-ls"),

	-- Neo Tree
	require("plugins.neo-tree"),

	-- Treesitter
	require("plugins.treesitter"),

	-- Typescript LSP & Others
	{
		"pmizio/typescript-tools.nvim",
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- These are installed using mason
			vim.lsp.enable({ "lua_ls", "tailwindcss", "gopls" })
			-- config for lua
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME, -- The base directory (fast)
								vim.fn.stdpath("config"), -- Your config dir (fast)
							},
						},
						diagnostics = {
							globals = { "vim" },
							disable = { "missing-fields" },
						},
						format = {
							enable = false,
						},
					},
				},
			})
		end,
	},

	-- Autocompletion
	require("plugins.blink-cmp"),

	-- Telescope
	require("plugins.telescope"),
})

vim.cmd("colorscheme catppuccin")
