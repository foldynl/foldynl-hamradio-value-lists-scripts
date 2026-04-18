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

    local tmp_file
    tmp_file="$(mktemp)"
    trap 'rm -f "${tmp_file}"' RETURN

    if ! curl -fsSL --retry 3 --retry-delay 5 -o "${tmp_file}" "${url}"; then
        echo "[ERROR] Download failed: ${url}" >&2
        return 1
    fi

    # Compare checksums – skip update if file unchanged
    if [[ -f "${dest_file}" ]]; then
        local old_sum new_sum
        old_sum="$(md5sum "${dest_file}" | cut -d' ' -f1)"
        new_sum="$(md5sum "${tmp_file}"  | cut -d' ' -f1)"
        if [[ "${old_sum}" == "${new_sum}" ]]; then
            return 0
        fi
    fi

    mv "${tmp_file}" "${dest_file}"
    gzip -kf "${dest_file}"          # -k keep original, -f overwrite existing .gz
}
