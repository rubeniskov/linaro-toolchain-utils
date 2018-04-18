
source './test/test.sh'
source './ls-local.sh'

describe "Toolchain ls local"

    test "Check local toolchains"
        assert_file toolchain_ls_local
        assert_file toolchain_ls_local 4.9
        assert_file toolchain_ls_local 6.1 2016.08
        assert_file toolchain_ls_local 5.3 DUMMY

    test "Check local versions"
        assert_file toolchain_ls_local_versions
        assert_file toolchain_ls_local_versions 4.9
        assert_file toolchain_ls_local_versions 6.1 2016.08
        assert_file toolchain_ls_local_versions 5.3 DUMMY

    test "Check local targets"
        assert_file toolchain_ls_local_targets
        assert_file toolchain_ls_local_targets 4.9
        assert_file toolchain_ls_local_targets 6.1 2016.08
        assert_file toolchain_ls_local_targets DUMMY
