
source './test/test.sh'
source './ls-remote.sh'


describe "Toolchain ls remote"

    test "Check remote versions"
        assert_file toolchain_ls_remote_versions
        assert_file toolchain_ls_remote_versions 4.9
        assert_file toolchain_ls_remote_versions 4.9 2016.02
        assert_file toolchain_ls_remote_versions 5.3 2016.02
        assert_file toolchain_ls_remote_versions 5.3 DUMMY

    test "Check remote targets"
        assert_file toolchain_ls_remote_targets
        assert_file toolchain_ls_remote_targets 4.9
        assert_file toolchain_ls_remote_targets 4.9 2017.01
        assert_file toolchain_ls_remote_targets 5.4 2017.01
        assert_file toolchain_ls_remote_targets 7.1 2017.05
        assert_file toolchain_ls_remote_targets DUMMY
        assert_file toolchain_ls_remote_targets 7.1 DUMMY
