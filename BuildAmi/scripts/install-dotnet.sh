#!/usr/bin/env bash
COLOR_START="\033[01;34m"
COLOR_END="\033[00m"
MSG_TIME="${MSG_TIME:-30}"

function show_msg() {
  echo -e "${COLOR_START}${@}${COLOR_END}"
}

show_msg "Adding dotnet repo"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' || exit 1

show_msg "Running 'apt-get install aptitude'..."
sudo apt-get install aptitude -y || exit 1

show_msg "Updating aptitude"
sudo aptitude update || exit 1

show_msg "Installing dotnet"
sudo aptitude install dotnet-runtime-2.0.7 --assume-yes || exit 1

show_msg "dotnet installation complete"
