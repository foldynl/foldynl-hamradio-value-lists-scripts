#!/usr/bin/env bash
set -euo pipefail

LISTS_DIR=../../lists

# download_and_compress <url> <dest_dir> <filename>
#   Downloads <url> into <dest_dir>/<filename>, then creates <filename>.gz
#   alongside it with gzip -k (keep original).
download_and_compress() {
    local url="$1"
    local dest_dir="$2"
    local filename="$3"
    local dest_file="${dest_dir}/${filename}"

    if ! curl -A "user-agent-name QLog" -fsSL --retry 3 --retry-delay 5 -o "${dest_file}" "${url}"; then
        echo "[ERROR] Download failed: ${url}" >&2
        return 1
    fi

    gzip -kf "${dest_file}" # -k keep original, -f overwrite existing .gz
}
