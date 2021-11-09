local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'dstein64/vim-startuptime'
    use 'svermeulen/vimpeccable'

    use 'chriskempson/base16-vim'
    use 'kyazdani42/nvim-web-devicons'
    use 'nvim-lualine/lualine.nvim'

    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'tpope/vim-repeat'

    use {
        'luukvbaal/stabilize.nvim',
        config = function() require('stabilize').setup() end,
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
        }
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
        }
    }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

local cmd = vim.cmd
local api = vim.api
local o = vim.o  -- global
local g = vim.g  -- global 2?
local wo = vim.wo -- window local
local bo = vim.bo -- buffer local

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"

o.inccommand = "nosplit"
o.termguicolors = true
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
o.expandtab = true
o.ruler = true
o.shiftwidth = 4
o.list = true
-- window-local option
wo.number = true
wo.relativenumber = true
wo.wrap = false
wo.cursorline = true
wo.foldenable = true
-- buffer-local options
bo.tabstop = 4
bo.expandtab = true

g.mapleader = ' '

-- next lines are plugin-specific and need packer to init first
if packer_bootstrap then
    return
end

cmd "colorscheme base16-tomorrow-night"

local telescope = require'telescope'
local telescope_builtin = require'telescope.builtin'
local vimp = require'vimp'
local cmp = require'cmp'
local luasnip = require'luasnip'
local lspkind = require'lspkind'
lspkind.init()

cmp.setup({
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-u>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            },
            { "i", "c" }
        ),

        ["<C-space>"] = cmp.mapping {
            i = cmp.mapping.complete(),
            c = function(
                _ --[[fallback]]
            )
                if cmp.visible() then
                    if not cmp.confirm { select = true } then
                        return
                    end
                else
                    cmp.complete()
                end
            end,
        },

        ["<tab>"] = cmp.mapping {
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
                buffer = "[buf]",
                nvim_lua = "[api]",
                nvim_lsp = "[LSP]",
                path = "[path]",
                luasnip = "[snip]",
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
        end
    },
    sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'buffer', keyword_length = 4 },
    }),
})

require'lualine'.setup {
  sections = {
    lualine_b = {'diagnostics', sources={'nvim_lsp'}},
  }
}

vimp.nnoremap('<A-o>', function()
    cmd('e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,')
end)

vimp.nnoremap('<C-p>', function()
    telescope_builtin.find_files()
end)

vimp.nnoremap('<leader>b', function()
    telescope_builtin.buffers()
end)

vimp.nnoremap('<C-f>', function()
    telescope_builtin.current_buffer_fuzzy_find()
end)

