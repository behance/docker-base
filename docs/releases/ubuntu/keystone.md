# keystone ubuntu Changelog

# 0

## 0.3.0

- Add archstring support symlink (needed by Behance install scripts)
- Remove goss installation from `keystone_runtime`
- Install goss in a separate folder `/bbc_goss` which we copy later when running the test stage
- Add separate stage to trigger goss tests i.e. `docker build --target test ..`
- Add keystone specific goss tests
- Update default image to be the keystone_runtime if `--target` is not specified
- Add `docs/` in `.dockerignore`
- Add this changelog

## 0.2.0

- Manual security updates

## 0.1.0

- Initial release