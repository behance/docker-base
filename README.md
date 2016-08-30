# docker-base
---

Integrates S6 process supervisor for a boot process, signal coordination, and zombie reaping (as PID 1)
@see https://github.com/just-containers/s6-overlay

### Expectations

To add a service to be monitored, simply create a service script: https://github.com/just-containers/s6-overlay#writing-a-service-script
For programmatic switches, create the service in `/etc/services-available`, and symlink to `/etc/services.d` to enable

### Environment Variables

Variable | Example | Description
--- | --- | ---
`S6_KILL_FINISH_MAXTIME` | `S6_KILL_FINISH_MAXTIME=1000` | Wait time (in ms) for zombie reaping before sending a kill signal
`S6_KILL_GRACETIME` | `S6_KILL_GRACETIME=500` | Wait time (in ms) for S6 finish scripts before sending kill signal


### Startup/Runtime Modification

To inject changes just before runtime, shell scripts may be placed into the
`/etc/cont-init.d` folder.
As part of the process manager, these scripts are run in advance of the supervised processes. @see https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks

### Testing

Container tests itself as part of build process using [goss](https://github.com/aelsabbahy/goss) validator. 
To add additional tests, overwrite (or extend) the `/goss.base.yaml` file.  



### Advanced Modification

More advanced changes can take effect using the `run.d` system. Similar to the `/etc/cont-init.d/` script system, any shell scripts (ending in .sh) in the `/run.d/` folder will be executed ahead of the S6 initialization.

- If a `run.d` script terminates with a non-zero exit code, container will stop, terminating with the script's exit code, unless...
- If script terminates with exit code of $SIGNAL_BUILD_STOP (99), this will signal the container to stop cleanly. This can be used for a multi-stage build process


### Long-running processes (workers + crons)

This container image can be used with multiple entrypoints (not to be confused with Docker entrypoints).
For example, a codebase that runs a web service, but also requires crons and background workers. These processes should not run inside the same container (like a VM would), but can be executed separately from the same image artifact by adding arguments to the `run` command.

`docker run {image_id} /worker.sh 3 /bin/binary -parameters -that -binary -receives`

Runs `3` copies of `/bin/binary` that receives the parameters `-parameters -that -binary -receives`


### Container Organization

Besides the instructions contained in the Dockerfile, the majority of this
container's use is in configuration and process. The `./container/root` repo directory is overlayed into a container during build. Adding additional files to the folders in there will be present in the final image. All paths from the following explanation are assumed from the repo's `./root/` base:

Directory | Use
--- | ---
`/etc/cont-init.d/` | startup scripts that run ahead of services booting: https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks
`/etc/fix-attrs.d/` | scripts that may fix permissions at runtime: https://github.com/just-containers/s6-overlay#fixing-ownership--permissions
`/etc/services.d/` |  services that will be supervised by S6: https://github.com/just-containers/s6-overlay#writing-a-service-script
`/etc/services-available/` | same as above, but must be symlinked into `/etc/services.d/` to take effect
`/run.d/` | shell scripts (ending in .sh) that make runtime modifications ahead of S6 initialization
