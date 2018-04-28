toolchain_usage(){
    app_name=$(basename $0)
    toolchain_version
    case "$1" in
        install)
cat <<EOF
Usage: $app_name install [version/s] <options>

    Example
        $app_name install $(toolchain_ls_remote_versions|awk '{print $1}'|tail -n 3|tr "\n" " ")
        $app_name install $(toolchain_ls_remote_versions|awk '{print $1}'|head -n 1) --arch_type=$(toolchain_ls_remote_targets|head -n 1)

    Versions
        default $2

    Options
      $app_name install -a|--arch_type:       Cross compile toolchain architecture            <$3>
      $app_name install -d|--host_arch:       Host toolchain arquitecture                     <$4>
      $app_name install -d|--destination:     Destination directory                           <$5>
      $app_name install -w|--workdir:         Directory where the files will be downloaded    <$6>
      $app_name install -r|--revision:        Revision release for this version <latest>
                                              only valid when single version install
      $app_name install --no-clean:           Disable autoclean downloaded files
      $app_name install --version:            Display the toolchain utility version
      $app_name install --help:               Display this usage

      Versions
$(toolchain_ls_remote_versions|awk '{print "\t - "$0}')

      Arch Types
$(toolchain_ls_remote_targets|awk '{print "\t - "$0}')

EOF
        ;;
        *)
cat <<EOF
    Usage: $app_name [help|download|install] <options>

    Commands
      $app_name download                  Download toolchain binaries
      $app_name install <version/s>       Extract and install toolchain
      $app_name uninstall <version/s>     Uninstall a version
      $app_name use <version> [<target>]  Modify the enviroment vars to use <version>.
      $app_name which <version>           Display path to installed toolchain version.
      $app_name ls                        List installed versions
      $app_name ls <version>              List versions matching a given <version>
      $app_name ls-remote                 List remote versions available for install
      $app_name ls-remote <version>       List remote versions available for install, matching a given <version>
      $app_name help                      Display this usage

    Options:
      $app_name --version:                Display the toolchain utility version
      $app_name -?|-h|--help:             Display this usage

EOF
        ;;
    esac
}
