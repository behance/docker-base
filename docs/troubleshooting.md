# Troubleshooting

* [gpg: keyserver receive failed: End of file](#gpg-keyserver-receive-failed-end-of-file)

# gpg: keyserver receive failed: End of file

There have been cases where the `install_s6.sh` script fails with:

```
#13 11.49 gpg: directory '/root/.gnupg' created
#13 11.50 gpg: keybox '/root/.gnupg/pubring.kbx' created
#13 15.49 gpg: keyserver receive failed: End of file
#13 ERROR: process "/bin/sh -c ln -s /scripts/clean_alpine.sh /clean.sh
[...snip...]
```

If you look at the `install_s6.sh` script, it fails on this line:

```
gpg --keyserver pgp.surfnet.nl --recv-keys $PUBLIC_KEY
```

If you try to manually run this command, it fails:

```
gpg --keyserver pgp.surfnet.nl --recv-keys 6101B2783B2FD161
gpg: directory '/root/.gnupg' created
gpg: keybox '/root/.gnupg/pubring.kbx' created
gpg: keyserver receive failed: End of file
root@dd54b59b57c5:/# echo $?
2
```

As a workaround (for now), I found [#352] and in the comments, I found a
solution from `mikenye` where he [embeds the actual public key].

So if you're building locally and are runing into this failure try:

1. Copy the public key from `mikenye`'s PR and save it as `s6-gpg-pub-key`
1. Update the Dockerfile instructions to copy the file to `/tmp`
   i.e. `COPY s6-gpg-pub-key /tmp/s6-gpg-pub-key`
1. Update `install_s6.sh`. Instead of:
   ```
   gpg --keyserver pgp.surfnet.nl --recv-keys 6101B2783B2FD161
   ```

   You do:
   ```
   gpg --import /tmp/s6-gpg-pub-key
   rm /tmp/s6-gpg-pub-key
   ```
1. The rest of the commands should be the same

In more recent versions of s6-overlay i.e. `3.x`, it looks like their
[verification steps] are different. So this could be a temporary issue
until we upgrade to the latest s6-overlay version.

If we're going to stay on this version for a while, we might just end up
baking in the public key

[#352]: https://github.com/just-containers/s6-overlay/issues/352
[embeds the actual public key]: https://github.com/mikenye/deploy-s6-overlay/pull/10
[verification steps]: https://github.com/just-containers/s6-overlay/#verifying-downloads