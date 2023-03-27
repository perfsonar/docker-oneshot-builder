ARG FROM=almalinux:latest
FROM ${FROM}


# OS/Family/Version-specific system prep

COPY prep /prep
RUN /prep/prep && rm -rf /prep


# General systemd configuration

RUN systemctl mask systemd-firstboot systemd-modules-load systemd-logind console-getty
RUN systemctl unmask systemd-udevd


# Entry point.  This runs systemd.

COPY --chown=root:root --chmod=755 entry /entry
ENTRYPOINT [ "/entry" ]

# Normally, we'd let Docker just run this by default with 'ENTRYPOINT
# /entry'.  Debian-flavored containers don't handle it properly and
# the PID ends up being something other than 1.  That prevents systemd
# from running properly.


# Build service

VOLUME /build
COPY --chown=root:root --chmod=555 service/build /usr/bin/build
COPY --chown=root:root --chmod=444 service/build.target /etc/systemd/system/build.target
COPY --chown=root:root --chmod=444 service/build.service /etc/systemd/system/build.service
RUN systemctl enable build
