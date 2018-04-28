
source './test/test.sh'
source './ls-remote.sh'

describe "Toolchain ls remote"

    test "Check remote toolchains"
        assert_file ltu_ls_remote
        assert_file ltu_ls_remote 4.9
        assert_file ltu_ls_remote 6.1 2016.08
        assert_file ltu_ls_remote 5.3 DUMMY

    test "Check remote option --latest"
        assert_file ltu_ls_remote --latest
        assert_file ltu_ls_remote --latest 4.9
        assert_file ltu_ls_remote --latest 6.1 2016.08
        assert_file ltu_ls_remote --latest 5.3 DUMMY

    test "Check remote option --brief"
        assert_file ltu_ls_remote --brief
        assert_file ltu_ls_remote --brief 4.9
        assert_file ltu_ls_remote --brief 6.1 2016.08
        assert_file ltu_ls_remote --brief DUMMY
