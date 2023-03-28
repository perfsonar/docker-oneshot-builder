ARG FROM=almalinux:latest
FROM ${FROM}


# OS/Family/Version-specific system prep

COPY prep /prep
RUN /prep/prep && rm -rf /prep


# General systemd configuration

RUN systemctl mask systemd-firstboot systemd-modules-load systemd-logind console-getty
RUN systemctl unmask systemd-udevd


# Entry point.  This runs systemd.

COPY --chown=root:root --chmod=755 container/entry /entry

# This must be the "exec" format; Debian doesn't handle shell-style
# properly.
ENTRYPOINT [ "/entry" ]


# Build service

VOLUME /build
COPY --chown=root:root --chmod=555 container/build /usr/bin/build
COPY --chown=root:root --chmod=444 container/build.target /etc/systemd/system/build.target
COPY --chown=root:root --chmod=444 container/build.service /etc/systemd/system/build.service
RUN systemctl enable build
