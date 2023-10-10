--[[
Author: LeeZB
Date: 2023-09-22 18:45:28
LastEditors: LeeZB leezb101@126.com
LastEditTime: 2023-09-22 18:47:00
copyright: Copyright © 2019 HeNan DtCloud Network Technology Co.,Lt d.
--]]
local set = vim.o
set.number = true
set.relativenumber = true
set.clipboard = "unnamed"
-- 设置tab键缩进2格
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true

vim.opt.termguicolors = true

-- copy后高亮
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 300 })
	end,
})
-- keybindings
local opt = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.g.localmapleader = " "
vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<leader>s", "<C-w>s", opt)
-- 判断是否有count在jk跳转前，决定是否跳转可视行和物理行
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })
-- 跳转到前一个位置、跳转到后一个位置
vim.keymap.set("n", "<leader>[", "<C-o>", opt)
vim.keymap.set("n", "<leader>]", "<C-i>", opt)

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	{
		"RRethy/nvim-base16",
		lazy = true,
	},
	{
		-- 持久化
		"folke/persistence.nvim",
		event = "BufReadPre",
		config = function()
			require("persistence").setup()
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	-- 候选提示带文档
	{
		"folke/neodev.nvim",
	},
	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		cmd = "Telescope",
		"nvim-telescope/telescope.nvim",
		tag = "0.1.3",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>p", ":Telescope find_files<CR>", desc = "Telescope Find Files" },
			{ "<leader>P", ":Telescope live_grep<CR>", desc = "Telescope Live Grep" },
			{ "<leader>rs", ":Telescope resume<CR>", desc = "Telescope resume" },
			{ "<leader>hf", ":Telescope oldfiles<CR>", desc = "Telescope Oldfiles" },
		},
	},
	{
		event = "VeryLazy",
		"williamboman/mason.nvim",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		-- config = function()
		--   require('mason').setup()
		-- end
	},
	{
		event = "VeryLazy",
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
	},
	-- 补全
	{
		event = "VeryLazy",
		"hrsh7th/nvim-cmp",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",
			"L3MON4D3/LuaSnip",
		},
	},
	-- 补全&诊断等
	{
		event = "VeryLazy",
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			local null_ls = require("null-ls")
			local formatting = null_ls.builtins.formatting
			null_ls.setup({
				sources = {
					formatting.prettierd.with({
						filetypes = {
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
							"vue",
							"css",
							"scss",
							"less",
							"html",
							"json",
							"yaml",
							"graphql",
						},
					}),
					formatting.stylua,
					null_ls.builtins.diagnostics.eslint,
					-- null_ls.builtins.diagnostics.eslint_d.with({
					--	diagnostics_format = "[eslint] #{m}\n(#{c})",
					-- }),
					null_ls.builtins.diagnostics.fish,
					null_ls.builtins.completion.spell,
					formatting.black,
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.keymap.set("n", "<leader>f", function()
							vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
							-- format({ bufnr = bufnr, async = true })
						end, { buffer = bufnr, desc = "[lsp] format" })
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
								-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
								vim.lsp.buf.format({ bufnr = bufnr, async = true })
							end,
						})
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = { "html", "css", "vim", "lua", "javascript", "typescript", "vue", "tsx" },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				-- 启用增量选择
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						node_incremental = "<CR>",
						node_decremental = "<BS>",
						scope_incremental = "<TAB>",
					},
				},
				indent = {
					enable = true,
				},
			})
		end,
	},
	-- git
	{
		event = "VeryLazy",
		"tpope/vim-fugitive",
		cmd = "Git",
		config = function()
			vim.cmd.cnoreabbrev([[git Git]])
			vim.cmd.cnoreabbrev([[gp Git push]])
		end,
	},
	-- git sign 标记
	{
		event = "VeryLazy",
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		event = "VeryLazy",
		"rhysd/conflict-marker.vim",
		config = function()
			vim.cmd([[
      let g:conflict_marker_highlight_group = ''
      let g:conflict_marker_begin = '^<<<<<<< .*$'
      let g:conflict_marker_end   = '^>>>>>>> .*$'
      highlight ConflictMarkerBegin guibg=#2f7366
      highlight ConflictMarkerOurs guibg=#2e5049
      highlight ConflictMarkerTheirs guibg=#344f69
      highlight ConflictMarkerEnd guibg=#2f628e
      highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
      ]])
		end,
	},
	-- file explorer
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		keys = {
			{
				id = "treeToggle",
				"<leader>t",
				":NvimTreeToggle<CR>",
				desc = "toggle nvimtree",
			},
		},
		config = function()
			require("nvim-tree").setup({
				filters = {
					custom = {
						".git/",
					},
					exclude = {
						".gitignore",
					},
					dotfiles = true,
				},
				git = {
					enable = true,
				},
			})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		lazy = false,
		version = "*",
		dependencies = "kyazdani42/nvim-web-devicons",
		keys = {
			{ "<leader>bp", ":BufferLinePickClose<CR>", desc = "Bufferline pick close tab" },
			{ "<leader>bl", ":BufferLineCloseLeft<CR>", desc = "Bufferline close left tab" },
			{ "<leader>br", ":BufferLineCloseRight<CR>", desc = "Bufferline close right tab" },
			{ "<leader>bo", ":BufferLineCloseOthers<CR>", desc = "Bufferline close others tab" },
			{ "<leader>bc", ":bdelete %<CR>", desc = "Bufferline close current tab" },
		},
		config = function()
			require("bufferline").setup({
				options = {
					diagnostics = "nvim_lsp",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							highlight = "Directory",
							text_align = "left",
						},
					},
					diagnostics_indicator = function(count, level, diagnostics_dict, context)
						local s = " "
						for e, n in pairs(diagnostics_dict) do
							local sym = e == "error" and " " or (e == "warning" and " " or "")
							s = s .. n .. sym
						end
						return s
					end,
				},
			})
		end,
	},
	{
		lazy = false,
		version = "*",
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "|", right = "|" },
					-- https://github.com/ryanoasis/powerline-extra-symbols
					section_separators = { left = " ", right = "" },
				},
				extensions = { "nvim-tree" },
				sections = {
					lualine_c = {
						"filename",
						{
							"lsp_progress",
							spinner_symbols = { " ", " ", " ", " ", " ", " " },
						},
					},
					lualine_x = {
						"filesize",
						{
							"fileformat",
							-- symbols = {
							--   unix = '', -- e712
							--   dos = '', -- e70f
							--   mac = '', -- e711
							-- },
							symbols = {
								unix = "LF",
								dos = "CRLF",
								mac = "CR",
							},
						},
						"encoding",
						"filetype",
					},
				},
			})
		end,
	},
	{
		lazy = false,
		version = "*",
		"arkav/lualine-lsp-progress",
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.config
		opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc =
        "Treesitter Search"
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc =
        "Toggle Flash Search"
      },
    }
,
	},
})

-- colorscheme
vim.cmd.colorscheme("base16-tender")

-- global mappings
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		-- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})

-- lsp
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup()

-- Set up lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("neodev").setup({})

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim", "hs" },
			},
			workspace = {
				checkThirdParty = false,
				-- Make the server aware of Neovim runtime files
				library = {
					vim.api.nvim_get_runtime_file("", true),
					-- "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/",
					-- vim.fn.expand("~/lualib/share/lua/5.4"),
					-- vim.fn.expand("~/lualib/lib/luarocks/rocks-5.4"),
					"/opt/homebrew/opt/openresty/lualib",
				},
			},
			completion = {
				callSnippet = "Replace",
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})

lspconfig.pyright.setup({
	capabilities = capabilities,
})

-- Set up nvim-cmp.
local cmp = require("cmp")

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
			-- they way you will only jump inside the snippet region
			elseif require("luasnip").expand_or_jumpable() then
				require("luasnip").expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		-- { name = 'vsnip' }, -- For vsnip users.
		{ name = "luasnip" }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer" },
	}),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- vue + volar
local lspconfig_configs = require("lspconfig.configs")
local lspconfig_util = require("lspconfig.util")

local function on_new_config(new_config, new_root_dir)
	local function get_typescript_server_path(root_dir)
		local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
		return project_root and (lspconfig_util.path.join(project_root, "node_modules", "typescript", "lib")) or ""
	end

	if
		new_config.init_options
		and new_config.init_options.typescript
		and new_config.init_options.typescript.tsdk == ""
	then
		new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
	end
end

local volar_cmd = { "vue-language-server", "--stdio" }
local volar_root_dir = lspconfig_util.root_pattern("package.json")

lspconfig_configs.volar_api = {
	default_config = {
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,
		filetypes = { "vue" },
		-- If you want to use Volar's Take Over Mode (if you know, you know)
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
		init_options = {
			typescript = {
				tsdk = "",
			},
			languageFeatures = {
				implementation = true, -- new in @volar/vue-language-server v0.33
				references = true,
				definition = true,
				typeDefinition = true,
				callHierarchy = true,
				hover = true,
				rename = true,
				renameFileRefactoring = true,
				signatureHelp = true,
				codeAction = true,
				workspaceSymbol = true,
				completion = {
					defaultTagNameCase = "both",
					defaultAttrNameCase = "kebabCase",
					getDocumentNameCasesRequest = false,
					getDocumentSelectionRequest = false,
				},
			},
		},
	},
}
lspconfig.volar_api.setup({})

lspconfig_configs.volar_doc = {
	default_config = {
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,

		filetypes = { "vue" },
		-- If you want to use Volar's Take Over Mode (if you know, you know):
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
		init_options = {
			typescript = {
				tsdk = "",
			},
			languageFeatures = {
				implementation = true, -- new in @volar/vue-language-server v0.33
				documentHighlight = true,
				documentLink = true,
				codeLens = { showReferencesNotification = true },
				-- not supported - https://github.com/neovim/neovim/pull/15723
				semanticTokens = false,
				diagnostics = true,
				schemaRequestService = true,
			},
		},
	},
}
lspconfig.volar_doc.setup({})

lspconfig_configs.volar_html = {
	default_config = {
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,

		filetypes = { "vue" },
		-- If you want to use Volar's Take Over Mode (if you know, you know), intentionally no 'json':
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
		init_options = {
			typescript = {
				tsdk = "",
			},
			documentFeatures = {
				selectionRange = true,
				foldingRange = true,
				linkedEditingRange = true,
				documentSymbol = true,
				-- not supported - https://github.com/neovim/neovim/pull/13654
				documentColor = false,
				documentFormatting = {
					defaultPrintWidth = 100,
				},
			},
		},
	},
}
lspconfig.volar_html.setup({})

lspconfig.tsserver.setup({})
