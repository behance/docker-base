[![Build Status](https://travis-ci.org/behance/docker-base.svg?branch=master)](https://travis-ci.org/behance/docker-base)  


# docker-base

https://hub.docker.com/r/behance/docker-base/tags/

Provides base OS, security patches, and tools for quick and easy spinup.  


### Variants  

— Ubuntu 16.04 LTS is default  
— Ubuntu 18.04 available, tagged as `-VERSION#-ubuntu-18.04`  
— Alpine builds available, tagged as `-alpine`  
— Centos builds available, tagged as `-centos`  



### Tools

- [S6](https://github.com/just-containers/s6-overlay) process supervisor is used for `only` for zombie reaping (as PID 1), boot coordination, and termination signal translation  
- [Goss](https://github.com/aelsabbahy/goss) is used for build-time testing  
- [Dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) is used for run-time testing.

### Expectations

To add a service to be monitored, simply create a service [run](https://github.com/just-containers/s6-overlay#writing-a-service-script) script
For programmatic switches, create the service in `/etc/services-available`, and symlink to `/etc/services.d` to enable  

### Security

A convenience script is provided for security-only package updates. 

On Ubuntu and CentOS-based variants, run: 
```/bin/bash -e /security_updates.sh```

This file is actually a symlink to the variant-specific script contained in the `/scripts` folder

NOTE: for Alpine variant, which is security-conscious, but does not have a mechanism to isolate security-specific updates, use `apk update && apk upgrade` as a generic alternative.

### Packaging

A convenience script is provided for post-package installation cleanup

On all variants, run: 
```/bin/bash -e /clean.sh```

This file, like security_updates (above) is actually a symlink to the variant-specific script contained in the `/scripts` folder


### Environment Variables

Variable | Example | Description
--- | --- | ---
S6_KILL_FINISH_MAXTIME | S6_KILL_FINISH_MAXTIME=55000 | The maximum time (in ms) a script in /etc/cont-finish.d could take before sending a KILL signal to it. Take into account that this parameter will be used per each script execution, it's not a max time for the whole set of scripts.
S6_KILL_GRACETIME | S6_KILL_GRACETIME=500 | Wait time (in ms) for S6 finish scripts before sending kill signal

* `with-contenv` tool, which is used to expose environment variables across scripts, has a limitation that it cannot read beyond 4k characters for environment variable values. To work around this issue, use the script `/scripts/with-bigcontenv` instead of `with-contenv`. You'll need to remove the `with-contenv` from the shebang line, and add  `source /scripts/with-bigcontenv` in the next line after the shebang line. 
### Startup/Runtime Modification

To inject changes just before runtime, shell scripts may be placed into the
`/etc/cont-init.d` folder.
As part of the process manager, these scripts are run in advance of the supervised processes. @see https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks

### Testing

- Container tests itself as part of build process using [goss](https://github.com/aelsabbahy/goss) validator. To add additional build-time tests, overwrite (or extend) the `./container/root/goss.base.yaml` file.
- To initiate run-time validation, please execute `test.sh`. It uses [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) validator. To add additional run-time tests, extend `./test.sh` and `./goss.yaml` file.



### Advanced Modification

More advanced changes can take effect using the `run.d` system. Similar to the `/etc/cont-init.d/` script system, any shell scripts (ending in .sh) in the `/run.d/` folder will be executed ahead of the S6 initialization.

- If a `run.d` script terminates with a non-zero exit code, container will stop, terminating with the script's exit code, unless...
- If script terminates with exit code of $SIGNAL_BUILD_STOP (99), this will signal the container to stop cleanly. This can be used for a multi-stage build process


### Shutdown Behavior

Sequence of events for a crashed supervised service: 

1. [finish](https://github.com/just-containers/s6-overlay#writing-an-optional-finish-script) script is executed
1. If no `finish` script is specified, service gets restarted, with no further action
1. If `finish` script specifies to bring the container down, admin-initiated container termination behavior applies (above).


Sequence of events for a `docker stop` or admin-initiated container termination: 

1. SIGTERM is broadcast to all supervised services, described as a [run](https://github.com/just-containers/s6-overlay#writing-a-service-script) script.
1. Scripts in `/etc/cont-finish.d` are executed, each with S6_KILL_FINISH_MAXTIME
1. S6 finish scripts are executed, each with S6_KILL_GRACETIME, described as a [finish](https://github.com/just-containers/s6-overlay#writing-an-optional-finish-script) script
1. SIGHUP is broadcast to all services, in all trees
1. SIGTERM is broadcast to all services, in all trees
1. SIGKILL terminates anything remaining


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
`/scripts` | convenience scripts that can be leveraged in derived images
