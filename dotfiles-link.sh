#!/bin/bash

CURRENT_DIR=$(pwd)

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

yay -S sheldon starship

mkdir -p "$HOME/.config/sheldon"
ln -s "${CURRENT_DIR}/nvim" "$HOME/.config/nvim"
ln -s "${CURRENT_DIR}/.zshrc" "$HOME/.zshrc"
ln -s "${CURRENT_DIR}/.config/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
ln -s "${CURRENT_DIR}/.config/starship.toml" "$HOME/.config/starshop.toml"

nvim --headless +PlugInstall +qa

echo "setup done"

