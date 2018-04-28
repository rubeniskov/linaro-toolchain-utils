#!/bin/bash
#title:           download.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#usage:           ltu_download <version> <revision> <arch_type> <host_arch> [destination]
#==============================================================================

source "./common.sh"

ltu_download_usage() {
  local app_name=$(basename $0)
cat <<EOF
Usage: $app_name download [version/s] <options>

  Example
    $app_name download 7.2 elf
    $app_name download 4.9 elf

  Options
    $app_name download -d|--destination      Destination folder
    $app_name download -l|--latest           Match only with the latest revision of each version
    $app_name download -h|--help             Display this usage

  Versions


  Arch Types

EOF
}

ltu_download() {
    local pattern destination flags
    local destination="/tmp"
    local opts=$(ltu_exec getopt \
            --options :d:lh \
            --long destination:,latest,help \
            --name 'ltu_download' -- "$@")

    eval set -- "$opts"
    while true; do
      case "${1}" in
        --)
            pattern="${@:2}"
            break
            ;;
        --destination)
            destination="$2"
            shift 2
            ;;
        --latest)
            flags+=("$1")
            shift 1
            ;;
        -h|--help|*)
            ltu_download_usage
            exit 1
            ;;
      esac
    done

    ltu_ls --remote -q -a ${pattern} |\
    while read -r row; do
      echo $row | ltu_format_remote_toolchain |\
      while read -r url; do
          local filename=${url##*/}
          local path="${destination}/${filename}"
          if [ ! -f "${path}" ]; then
              mkdir -p "${destination}/"
              ltu_get_from_url -Lf "${url}" --progress-bar -o "${path}" 2>&1 |\
              while IFS= read -d $'\r' -r progress; do
                  ltu_log "prg" "Downloading" "${progress##* }" "$url"
              done

              if [[ $? != 0 ]];then
                  ltu_log "err" "Download failed" "${row}"
                  return 1
              fi
              ltu_log "info" "Downloaded" "${destination}/${filename}"
          fi

          printf "%s %s %s\n" "${row}" "${url}" "${path}"

      done
    done

    return 0
}
