local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself

    "chriskempson/base16-vim";

    "tpope/vim-commentary";
    "tpope/vim-surround";
    "tpope/vim-repeat";
}

local cmd = vim.cmd
local o = vim.o  -- global
local g = vim.g  -- global 2?
local wo = vim.wo -- window local
local bo = vim.bo -- buffer local

cmd "colorscheme base16-tomorrow-night"

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
o.expandtab = false -- at some point I switch to a project that uses spaces instead of tabs...
o.ruler = true
o.clipboard = 'unnamedplus'
o.tabstop = 4
-- window-local option
wo.number = true
wo.relativenumber = true
wo.wrap = false
wo.cursorline = true
wo.foldenable = true
-- buffer-local options
bo.expandtab = false -- ugh, tabs :(

g.mapleader = ' '