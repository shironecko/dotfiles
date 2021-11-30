# just execute the fucking scripts
Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# install Scoop
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) { 
   Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Multi-connection Scoop downloads with aria2
scoop install aria2

# Chezmoi for .files management
if ((Get-Command "chezmoi" -ErrorAction SilentlyContinue) -eq $null) {
   scoop bucket add twpayne https://github.com/twpayne/scoop-bucket
   scoop install chezmoi
   chezmoi init git@github.com:shironecko/dotfiles.git
} else {
   chezmoi update
}

scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add jetbrains

scoop install 7zip bat fd ripgrep fzf tokei touch lsd
scoop install vscode sublime-text sublime-merge neovim-nightly
scoop install watchexec
scoop install rustup rust-analyzer
scoop install llvm
scoop install neovide, alacritty
# Benchmarking console apps
scoop install hyperfine
scoop install autohotkey
# Regex's are hard
scoop install grex

# Terminal job system
cargo install --locked pueue
# Hex dump
cargo install hx
# Renaming stuff
cargo install nomino
# Lua autoformatter
cargo install stylua
# tmux in rust (apparently no Win support, like every other multiplexer ); )
#cargo install zellij

# My font of choice
scoop install IBMPlexMono-NF

# make fzf use fd instead of find
[Environment]::SetEnvironmentVariable("FZF_DEFAULT_COMMAND", "fd --type f", "User")
# enable fancy things in neovide
[Environment]::SetEnvironmentVariable("NEOVIDE_MULTIGRID", "ON", "User")

# global gitignore
git config --global core.excludesfile $env:userprofile\.gitignore

# setup nvim plugins
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
