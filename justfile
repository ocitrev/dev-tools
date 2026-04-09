[private]
default:
    @"{{ just_executable() }}" -f "{{ source_file() }}" --list --unsorted

zig_exe := if os() == "linux" { "zig" } else if os() == "windows" { "zig.exe" } else { error("Unsupported OS") }
archive_ext := if os() == "linux" { ".tar.xz" } else if os() == "windows" { ".zip" } else { error("Unsupported OS") }
archive_file := "zig-" + arch() + "-" + os() + "-${version}" + archive_ext
install_dir := env("HOME") / ".local/zig"
bin_path := env("HOME") / ".local/bin"
zig_bin_symlink := bin_path / zig_exe
tmp_archive := / "tmp" / archive_file
tmp_archive_extract := / "tmp" / archive_file + "-extract"

[script("sh", "-u")]
install-zig version="0.15.2":
    version="{{ version }}"

    echo "Downloading {{ archive_file }}"
    if ! curl -fsSL --output "{{ tmp_archive }}" "https://ziglang.org/download/${version}/{{ archive_file }}"; then
        echo Failed to download "{{ archive_file }}" 1>&2
        exit 1
    fi

    echo "Removing old version..."
    rm -r "{{ install_dir }}" 2>/dev/null
    mkdir -p "{{ install_dir }}"

    echo "Unpacking downloaded version..."
    if [ "{{ os() }}" = "windows" ]; then
        unzip -q "{{ tmp_archive }}" -d "{{ tmp_archive_extract }}"
        extract_ok=$?

        if [ "$extract_ok" -eq 0 ]; then
            mv "{{ tmp_archive_extract }}"/*/* "{{ install_dir }}"
            rm -r "{{ tmp_archive_extract }}"
        fi
    else
        tar -xf "{{ tmp_archive }}" -C "{{ install_dir }}" --strip-components=1
        extract_ok=$?
    fi

    echo "Finishing install..."
    rm "{{ tmp_archive }}"

    if [ "$extract_ok" -ne 0 ]; then
        echo Failed to extract "{{ archive_file }}" 1>&2
        exit $extract_ok
    fi

    [ -d "{{ bin_path }}" ] || mkdir -p "{{ bin_path }}"
    rm "{{ zig_bin_symlink }}" 2>/dev/null
    ln -s "{{ install_dir / zig_exe }}" "{{ zig_bin_symlink }}"
    echo "Installed zig $("{{zig_bin_symlink}}" version)"

remove-zig:
    -rm "{{ zig_bin_symlink }}" 2>/dev/null
    -rm -r "{{ install_dir }}" 2>/dev/null
