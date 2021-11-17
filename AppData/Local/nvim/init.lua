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

  use 'editorconfig/editorconfig-vim'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzy-native.nvim',
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

set hidden

let neovide_remember_window_size = v:true
]]

g.mapleader = ' '

-- don't want config errors before packer install everything
local function try_require(module, fn)
  local success, result = pcall(require, module)
  if success then
    if fn then
      fn(result)
    end

    return result
  else
    return nil
  end
end

try_require('stabilize', function(mod)
  mod.setup()
end)

try_require('nightfox', function(mod)
  mod.load 'nightfox'
end)

try_require('nvim-treesitter.configs', function(mod)
  mod.setup {
    highlight = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['ap'] = '@parameter.outer',
          ['ip'] = '@parameter.inner',
        },
      },
    },
  }
end)

local telescope = try_require 'telescope'
local telescope_builtin = try_require 'telescope.builtin'
local vimp = try_require 'vimp'
local cmp = try_require 'cmp'
local lspconfig = try_require 'lspconfig'
local luasnip = try_require 'luasnip'
local lspkind = try_require('lspkind', function(mod)
  mod.init()
end)
local lsp_status = try_require 'lsp-status'

if
  telescope == nil
  or telescope_builtin == nil
  or vimp == nil
  or cmp == nil
  or lspconfig == nil
  or luasnip == nil
  or lspkind == nil
  or lsp_status == nil
then
  -- some interconnected setup follows, better not attempt it unless all plugins are installed
  return
end

require('lualine').setup {
  options = {
    theme = 'nightfox',
  },
  sections = {
    lualine_b = { { 'diagnostics', sources = { 'nvim_lsp' } } },
    lualine_c = { 'filename', require('lsp-status').status },
  },
}

telescope.setup {
  defaults = {
    path_display = { 'truncate' },
  },
}

telescope.load_extension 'fzy_native'

cmp.setup {
  mapping = {
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

vimp.nnoremap('<leader>rf', function()
  cmd 'Neoformat'
end)

local project_ff_dir = './'
function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

try_require('plenary.context_manager', function(context_manager)
  local with = context_manager.with
  local open = context_manager.open
  local conf_path = '.project_ff_dir'
  if file_exists(conf_path) then
    project_ff_dir = with(open(conf_path), function(reader)
      return reader:read()
    end)
  end
end)

vimp.nnoremap('<C-f>', telescope_builtin.current_buffer_fuzzy_find)

vimp.nnoremap('<leader>ff', function()
  telescope_builtin.find_files { search_dirs = { project_ff_dir } }
end)
vimp.nnoremap('<leader>fF', telescope_builtin.find_files)

vimp.nnoremap('<leader>fg', function()
  telescope_builtin.live_grep { search_dirs = { project_ff_dir } }
end)
vimp.nnoremap('<leader>fG', telescope_builtin.live_grep)

vimp.nnoremap('<leader>fb', telescope_builtin.buffers)
vimp.nnoremap('<leader>fh', telescope_builtin.search_history)
vimp.nnoremap('<leader>fm', telescope_builtin.marks)
vimp.nnoremap('<leader>fq', telescope_builtin.quickfix)
vimp.nnoremap('<leader>fj', telescope_builtin.jumplist)
vimp.nnoremap('<leader>fr', telescope_builtin.resume)
vimp.nnoremap('<leader>fR', telescope_builtin.registers)
vimp.nnoremap('<leader>ft', telescope_builtin.treesitter)

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
    vimp.nnoremap('gt', telescope_builtin.lsp_type_definitions)

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

    -- this one clangd shortcut
    vimp.nnoremap('<A-o>', function()
      cmd 'ClangdSwitchSourceHeader'
    end)
  end)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local servers = { 'clangd', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- TODO: maybe re-enable this once gutter stops jerking?
local signs = { Error = ' ', Warning = ' ', Hint = ' ', Information = ' ' }
cmd 'set signcolumn=yes'
for type, icon in pairs(signs) do
  -- local hl = "DiagnosticSign" .. type -- For 0.6.0
  local hl = 'LspDiagnosticsSign' .. type -- For 0.5.1
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end
