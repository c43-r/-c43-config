 -- --- General Settings ---
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relative line numbers
vim.opt.tabstop = 4             -- 4 spaces per tab
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true    -- True color support
vim.opt.cursorline = true       -- Highlight current line
vim.g.mapleader = " "           -- Space is your leader key

-- --- Bootstrap Lazy.nvim (Plugin Manager) ---
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- --- Plugins ---
require("lazy").setup({
    -- Theme
    { "ellisonleao/gruvbox.nvim", priority = 1000, config = function() vim.cmd([[colorscheme gruvbox]]) end },
    
    -- File Explorer & UI
    "nvim-tree/nvim-tree.lua",
    "nvim-lualine/lualine.nvim",
    "nvim-tree/nvim-web-devicons",

    -- LSP and Autocomplete
    { "neovim/nvim-lspconfig" },             -- Required
    { "williamboman/mason.nvim" },           -- LSP Manager
    { "williamboman/mason-lspconfig.nvim" }, -- Bridges Mason & Lspconfig
    
    -- Autocompletion Engine
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },                  -- Snippet engine
})

-- --- Plugin Configurations ---

-- Setup Mason (The Tool Installer)
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "rust_analyzer", "basedpyright" }
})

-- Setup Lualine (Status bar)
require('lualine').setup()

-- Setup Nvim-Tree (File explorer)
require("nvim-tree").setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

-- Setup LSP Autocomplete Capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "rust_analyzer", "basedpyright" }
})

-- Configure specific languages
local servers = { 'clangd', 'rust_analyzer', 'pyright' }
for _, server_name in ipairs(servers) do
    vim.lsp.config(server_name,{
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    })

    vim.lsp.enable(server_name)
end

-- --- Completion Keybinds ---
local cmp = require('cmp')
cmp.setup({
    snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({ { name = 'nvim-lspconfig' } })
})

-- --- LSP Keybinds ---
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
