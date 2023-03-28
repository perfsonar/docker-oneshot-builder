ARG FROM=almalinux:latest
FROM ${FROM}

VOLUME /build

# OS/Family/Version-specific system prep
COPY prep /prep
RUN /prep/prep && rm -rf /prep

# This must be the "exec" format; Debian doesn't handle shell-style
# properly.
ENTRYPOINT [ "/entry" ]
