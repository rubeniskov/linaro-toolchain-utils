
ltu_unpack() {
    local file=$1
    local destination="${@: -1}"
    local filename="${file##*/}"
    local compression_type="${filename##*.}"
    local dirname=${filename//.tar.$compression_type}
    local total=0
    mkdir -p "$destination"
    tar xvpf $file "${dirname}/bin" "${dirname}/lib" -C $destination 2>&1 |\
    while read filepath; do
        total=$((total+1))
        ltu_log "prg" "Unpacking" "$total" "$file ${filepath##*/}"
    done
    ltu_log "info" "Unpacked" "$file"
}
