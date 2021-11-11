local fn = vim.fn
local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'svermeulen/vimpeccable'

  use 'EdenEast/nightfox.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use 'lukas-reineke/indent-blankline.nvim'

  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'

  use 'luukvbaal/stabilize.nvim'

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind-nvim',
    },
  }

  use 'sbdchd/neoformat'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

local cmd = vim.cmd
local api = vim.api
local o = vim.o -- global
local g = vim.g -- global 2?
local wo = vim.wo -- window local
local bo = vim.bo -- buffer local

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.shortmess:append 'c'
vim.opt.termguicolors = true
o.termguicolors = true

o.guifont = 'BlexMono NF:h16'

o.inccommand = 'nosplit'
o.swapfile = true
o.smartcase = true
o.laststatus = 2
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.scrolloff = 4
o.showcmd = true
o.wildmenu = true
o.showmatch = true
o.ruler = true
o.list = true
-- window-local option
wo.number = true
wo.relativenumber = true
wo.wrap = false
wo.cursorline = true
wo.foldenable = true

-- lua options are a mess and I'm tired of them
cmd [[
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
filetype plugin indent on
]]

g.mapleader = ' '

-- next lines are plugin-specific and need packer to init first
if packer_bootstrap then
  return
end

require('nightfox').load 'nightfox'

local telescope = require 'telescope'
local telescope_builtin = require 'telescope.builtin'
local vimp = require 'vimp'
local cmp = require 'cmp'
local lspconfig = require 'lspconfig'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'
lspkind.init()

require('stabilize').setup()

-- this somehow fixes indent line background color?
vim.cmd [[highlight IndentBlanklineSpaceChar guibg=#1a1a1a gui=nocombine]]

require('lualine').setup {
  options = {
    theme = 'nightfox',
  },
  sections = {
    lualine_b = { 'diagnostics', sources = { 'nvim_lsp' } },
    lualine_c = { 'filename', require('lsp-status').status },
  },
}

cmp.setup {
  mapping = {
    --['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    --['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),

    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-u>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { 'i', 'c' }
    ),

    ['<C-x><C-o>'] = cmp.mapping.complete(),

    ['<tab>'] = cmp.mapping {
      i = cmp.config.disable,
      c = function(fallback)
        fallback()
      end,
    },
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = '[buf]',
        nvim_lua = '[api]',
        nvim_lsp = '[LSP]',
        path = '[path]',
        luasnip = '[snip]',
      },
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 4 },
  },
}

vimp.nnoremap('<A-o>', function()
  cmd 'e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,'
end)

vimp.nnoremap('<leader>rf', function()
  cmd 'Neoformat'
end)

vimp.nnoremap('<C-f>', telescope_builtin.current_buffer_fuzzy_find)
vimp.nnoremap('<leader>ff', telescope_builtin.find_files)
vimp.nnoremap('<leader>fb', telescope_builtin.buffers)
vimp.nnoremap('<leader>fg', telescope_builtin.live_grep)

local on_attach = function(client, bufnr)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vimp.add_buffer_maps(bufnr, function()
    -- telescope
    vimp.nnoremap('<leader>fs', telescope_builtin.lsp_document_symbols)
    vimp.nnoremap('<leader>fd', telescope_builtin.lsp_document_diagnostics)
    vimp.nnoremap('<leader>rr', telescope_builtin.lsp_code_actions)
    vimp.nnoremap('gd', telescope_builtin.lsp_definitions)
    vimp.nnoremap('gD', telescope_builtin.lsp_declarations)
    vimp.nnoremap('gi', telescope_builtin.lsp_implementations)

    -- raw lsp
    vimp.nnoremap('K', vim.lsp.buf.hover)
    vimp.nnoremap('<C-k>', vim.lsp.buf.signature_help)
    vimp.nnoremap('<space>wa', vim.lsp.buf.add_workspace_folder)
    vimp.nnoremap('<space>wr', vim.lsp.buf.remove_workspace_folder)
    vimp.nnoremap('<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders))
    end)
    vimp.nnoremap('<space>D', vim.lsp.buf.type_definition)
    vimp.nnoremap('<space>rn', vim.lsp.buf.rename)
    vimp.nnoremap('<space>e', vim.lsp.diagnostic.show_line_diagnostics)
    vimp.nnoremap('[d', vim.lsp.diagnostic.goto_prev)
    vimp.nnoremap(']d', vim.lsp.diagnostic.goto_next)
    vimp.nnoremap('<space>q', vim.lsp.diagnostic.set_loclist)
    vimp.nnoremap('<space>rF', vim.lsp.buf.formatting)
  end)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

local signs = { Error = ' ', Warning = ' ', Hint = ' ', Information = ' ' }
for type, icon in pairs(signs) do
  -- local hl = "DiagnosticSign" .. type -- For 0.6.0
  local hl = 'LspDiagnosticsSign' .. type -- For 0.5.1
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end
