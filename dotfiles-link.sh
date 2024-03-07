#!/bin/bash

CURRENT_DIR=$(pwd)

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

ln -s "${CURRENT_DIR}/nvim" "$HOME/.config/nvim"

nvim --headless +PlugInstall +qa

echo "setup done"

