[private]
@default:
    just -f "{{ justfile() }}" --list --unsorted

[script]
install-zig version="0.15.2":
    version="{{ version }}"
    archive_file="zig-x86_64-linux-$version.tar.xz"
    install_dir="$HOME/.local/zig"
    bin_path="$HOME/.local/bin"
    zig_bin_symlink="$bin_path/zig"

    if ! curl -fsSL --output "/tmp/$archive_file" "https://ziglang.org/download/$version/$archive_file"; then
        echo Failed to download "$archive_file" 1>&2
        exit 1
    fi

    rm -r "$install_dir"
    mkdir -p "$install_dir"

    tar -xf "/tmp/$archive_file" -C "$install_dir" --strip-components=1
    extract_ok=$?
    rm "/tmp/$archive_file"

    if [ "$extract_ok" -ne 0 ]; then
        echo Failed to extract "$archive_file" 1>&2
        exit $extract_ok
    fi

    if [ ! -d "$bin_path" ]; then
        mkdir -p "$bin_path"
    fi

    if [ -L "$zig_bin_symlink" ]; then
        rm "$zig_bin_symlink"
    fi

    ln -s "$install_dir/zig" "$zig_bin_symlink"
