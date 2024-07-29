#!/bin/bash

# sheldon install
curl https://sh.rustup.rs -sSf | sh
. "$HOME/.cargo/env"
cargo install sheldon

# starship install
curl -sS https://starship.rs/install.sh | sh

# asdf install
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

# リポジトリのディレクトリ（スクリプトが実行されるディレクトリ）
REPO_DIR=$(pwd)

# ホームディレクトリ
HOME_DIR=$HOME

# リポジトリ内の全てのディレクトリとファイルに対してシンボリックリンクを作成
cd $REPO_DIR
find . -type d | while read DIR; do
  mkdir -p "$HOME_DIR/${DIR#./}"
done

find . -type f | while read FILE; do
  ln -s "$REPO_DIR/$FILE" "$HOME_DIR/${FILE#./}"
done

echo "シンボリックリンクの作成が完了しました。"
