# just execute the fucking scripts
Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# install Scoop
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Chezmoi for .files management
scoop bucket add twpayne https://github.com/twpayne/scoop-bucket
scoop install chezmoi

scoop bucket add extras