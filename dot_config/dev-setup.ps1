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
scoop install vscode sublime-text sublime-merge neovim
scoop install watchexec
scoop install rustup
scoop install alacritty
# Regex's are hard
scoop install grex

# Terminal job system
cargo install --locked pueue
# Hex dump
cargo install hx
# Renaming stuff
cargo install nomino
# tmux in rust
cargo install zellij

# My font of choice
scoop install IBMPlexMono-NF
