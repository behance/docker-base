# Tests

## shunit2

Starting August 28, 2022, all shell scripts should ideally have a corresponding
`shunit2` test.

See [shunit2] for usage and documentation.

Guidelines:

* Tests are stored in `tests/sh`
* Path to the test should mirror the actual location of the original script
* Name of the script should be `test_` + name of actual script to test

For an example, see [test_update_apt_sources.sh].

To run all tests:

```shell
make shunit2
```

To run a specific test file (useful to target a specific test)

```shell
RUN_TEST_FILE=tests/sh/container/root/scripts/ubuntu/test_update_apt_sources.sh make shunit2
```

To run all tests in a specific directory:

```shell
RUN_TEST_DIR=tests/sh/container/root/scripts/ubuntu make shunit2
```

[shunit2]: https://github.com/kward/shunit2
[test_update_apt_sources.sh]: ../tests/sh/container/root/scripts/ubuntu/test_update_apt_sources.sh