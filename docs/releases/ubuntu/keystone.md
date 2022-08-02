# keystone ubuntu Changelog

# 0

## 0.4.0

- Pull latest from Github docker-base
- Update `keystone.goss.yaml` to specify full path to busybox
- Update `keystone_add_busybox` function to skip linking applets if it exists - [ETHOS-38168](https://jira.corp.adobe.com/browse/ETHOS-38168)

## 0.3.0

- Add archstring support symlink (needed by Behance install scripts)
- Remove goss installation from `keystone_runtime`
- Install goss in a separate folder `/bbc_goss` which we copy later when running the test stage
- Add separate stage to trigger goss tests i.e. `docker build --target test ..`
- Add keystone specific goss tests
- Update default image to be the keystone_runtime if `--target` is not specified
- Add `docs/` in `.dockerignore`
- Add `tr` which is used by `040-check-java.sh` in java-based BBCS - [ETHOS-31761](https://jira.corp.adobe.com/browse/EON-31761)
- Add this changelog

## 0.2.0

- Manual security updates

## 0.1.0

- Initial release
