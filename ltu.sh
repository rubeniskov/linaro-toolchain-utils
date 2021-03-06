#!/usr/bin/env bash
# toolchain utils
#
# deps: gpg curl xz-utils ca-certificates getopts

source "./common.sh"
source "./ls.sh"
source "./download.sh"
source "./install.sh"
source "./use.sh"

ltu_usage() {
  local app_name=$(basename $0)
cat <<EOF
Usage: $app_name [install|use|ls|ls-remote...] <options>
  Version
    $LTU_VERSION

  Example
    $app_name install 7.2 elf
    $app_name use 7.2 elf

  Commands
    $app_name i/install <version/s>       Extract and install toolchain
    $app_name uninstall <version/s>     Uninstall a version
    $app_name use <version> [<target>]  Modify the enviroment vars to use <version>.
    $app_name which <version>           Display path to installed toolchain version.
    $app_name ls                        List remote versions checking installed
    $app_name ls <version>              List remote versions checking installed, matching a given <version>
    $app_name ls-local                  List installed versions
    $app_name ls-local <version>        List installed versions, matching a given <version>
    $app_name ls-remote                 List remote versions available for install
    $app_name ls-remote <version>       List remote versions available for install, matching a given <version>
    $app_name download                  Download toolchain binaries
    $app_name help                      Display this usage

  Options:
    $app_name --version:                Display the toolchain utility version
    $app_name -?|-h|--help:             Display this usage

EOF
}

ltu() {
  case "$1" in
    ls)
        shift
        ltu_ls $@
        ;;
    ls-remote)
        shift
        ltu_ls --remote $@
        ;;
    ls-local)
        shift
        ltu_ls --local $@
        ;;
    download)
        shift
        ltu_download $@
        ;;
    install)
        shift
        ltu_install $@
        ;;
    use)
        shift
        ltu_use $@
        ;;
    --version)
        echo $LTU_VERSION
        ;;
    -h|--help|help|?|*)
        ltu_usage
        ;;
  esac
}

if [[ $_ != $0 ]]; then
    ltu $@
fi
