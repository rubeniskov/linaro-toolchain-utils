
source './test/test.sh'
source './ls-local.sh'

describe "Toolchain ls local"

    test "Check local toolchains"
        assert_file ltu_ls_local
        assert_file ltu_ls_local 4.9
        assert_file ltu_ls_local 6.1 2016.08
        assert_file ltu_ls_local 5.3 DUMMY

    test "Check local option --latest"
        assert_file ltu_ls_local --latest
        assert_file ltu_ls_local --latest 4.9
        assert_file ltu_ls_local --latest 6.1 2016.08
        assert_file ltu_ls_local --latest 5.3 DUMMY

    test "Check local option --brief"
        assert_file ltu_ls_local --brief
        assert_file ltu_ls_local --brief 4.9
        assert_file ltu_ls_local --brief 6.1 2016.08
        assert_file ltu_ls_local --brief DUMMY
