local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup(function(use)
    use "wbthomason/packer.nvim"

    use "chriskempson/base16-vim"

    use "tpope/vim-commentary"
    use "tpope/vim-surround"
    use "tpope/vim-repeat"

    use "kyazdani42/nvim-web-devicons"

    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
        }
    }

    use "nvim-lualine/lualine.nvim"

    use "svermeulen/vimpeccable"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
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

local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
local vimp = require('vimp')

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

