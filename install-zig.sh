#!/usr/bin/env bash

version="0.15.2"
archive_file="zig-x86_64-linux-$version.tar.xz"
install_dir="$HOME/.local/zig"
bin_path="$HOME/.local/bin"
zig_bin_symlink="$bin_path/zig"

curl --output "/tmp/$archive_file" "https://ziglang.org/download/$version/$archive_file"

rm -r "$install_dir"
mkdir -p "$install_dir"

tar -xf "/tmp/$archive_file" -C "$install_dir" --strip-components=1
rm "/tmp/$archive_file"

if [[ ! -d "$bin_path" ]]; then
  mkdir -p "$bin_path"
fi

if [[ -L "$zig_bin_symlink" ]]; then
  rm "$zig_bin_symlink"
fi

ln -s "$install_dir/zig" "$zig_bin_symlink"
