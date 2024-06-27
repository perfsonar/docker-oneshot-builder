# Docker One-Shot Builder

Ths directory containsw a Dockerfile and supporting files to construct
Docker container images that do builds in a directory shared from the
host system.  This activity is referred to as a _Docker One-Shot
Build_ or _DOSB_.

The use case for DOSBs is to enable full builds on Jenkins build hosts
without contaminating them.


## Preparing to Build

Other than Docker and access to the containers, the sole requirement
for a one-shot build is a directory (called the _build directory_) and
one of the following:

 * A `Makefile` that builds the product it contains using a single,
   unadorned invocation of `make` by an unprivileged user with
   frictionless access to `sudo`.

 * A script, specified with the `--run PATH` switch that will be
   copied into the container and invoked by an unprivileged user with
   frictionless access to `sudo`.

In typical use cases, this is as simple as using Git to clone a
repository into a directory and checking out a specific branch:

```
$ git clone https://github.com/some-org/kafoobulator.git
$ git -C some-repo checkout 1.2.3
```


## Building Using a DOSB Container

### Quick Start

The recommended way to build using DOSB is to run the `build` script
directly from this repository:

```
$ git clone https://github.com/some-org/kafoobulator.git

$ curl -s https://raw.githubusercontent.com/perfsonar/docker-oneshot-builder/main/build \
     | sh -s - ./kafoobulator el9
```

You can specify a script on the local system to be copied into the
container and run instead of the default `make` like this:

```
$ git clone https://github.com/some-org/kafoobulator.git

$ curl -s https://raw.githubusercontent.com/perfsonar/docker-oneshot-builder/main/build \
     | sh -s - --run /path/to/script ./kafoobulator el9
```


### Roll Your Own

**PLEASE DON'T DO THIS IF YOU CAN AVOID IT.**

Once the build directory is established, start a non-detached docker
container using one of these images:

| Family | Distribution | Version | Container |
|--------|--------------|:-------:|-----------|
| Red Hat | CentOS | 7 | `ghcr.io/perfsonar/docker-oneshot-builder/el7:latest` |
| Red Hat | Alma Linux | 8 | `ghcr.io/perfsonar/docker-oneshot-builder/el8:latest` |
| Red Hat | Alma Linux | 9 | `ghcr.io/perfsonar/docker-oneshot-builder/el9:latest` |
| Debian | Debian | 10 | `ghcr.io/perfsonar/docker-oneshot-builder/d10:latest` |
| Debian | Ubuntu | 18 | `ghcr.io/perfsonar/docker-oneshot-builder/u18:latest` |
| Debian | Ubuntu | 20 | `ghcr.io/perfsonar/docker-oneshot-builder/u20:latest` |
| Debian | Ubuntu | 22 | `ghcr.io/perfsonar/docker-oneshot-builder/u22:latest` |
| Debian | Ubuntu | 24 | `ghcr.io/perfsonar/docker-oneshot-builder/u24:latest` |

Notes:

 * These containers are based on the perfSONAR Unibuild containers.
 * Debian family containers are provided for different CPU
architectures.

A typical invocation to accompany the Git commands shown above would
look like this:

```
$ docker run \
    --tty \
    --tmpfs /tmp:exec \
    --tmpfs /run:exec \
    --volume "./kafoobulator:/build" \
    --rm \
    <PERMISSIONS: SEE NOTE BELOW> \
    ghcr.io/perfsonar/docker-oneshot-builder/el9:latest
```

Additional permissions-related arguments are required for `systemd` to
run correctly inside Docker containers that vary by operating system:

| System | Arguments |
|--------|-----------|
| macOS | `--privileged` |
| Linux with cgroups v1 | `--privileged` |
| Linux with cgroups v2¹ | `--volume /sys/fs/cgroup:/sys/fs/cgroup:ro` |

¹Systems running cgroups v2 can be identified by the existence of a
 `/sys/fs/cgroup/cgroup.controllers` directory.

Once started, the container will enter the build directory, run `make`
and then exit.

## Build Results

When the `systemd` process inside the container exits, `docker run`
will exit with a status of `130` (terminated by `SIGINT`).  This is a
normal exit condition and should be considered a success.  This bit of
shell script can check for that:

```
STATUS=0
docker-run ... \
    || STATUS=$? ; \
    if [ $STATUS -ne 0 -a $STATUS -ne 130 ]; then \
        echo "Container exited $STATUS" 1>&2 ; \
        exit 1
    fi
```

If the build was successful, any products produced by `make` will be
present in the build directory.  The container will create a
subdirectory of the build directory named `DOSB` containing two files:

 * `status` - Contains the exit status of the `make` command
 * `log` - Contains all output produced by `make`



## Internal Information


### Building a Container

In the directory where this file resides:
```
docker build --build-arg 'FROM=SOURCE-IMAGE' --tag CONTAINER-NAME
```
Where:
 * `SOURCE-IMAGE`is the name of the Docker image to be used in building the container.
  * `CONTAINER-NAME` is the name of the

A typical application would to build this container on top of a DOSB container:
```
docker build --build-arg 'FROM=ghcr.io/perfsonar/unibuild/el9:latest' --tag el9dosb
```
