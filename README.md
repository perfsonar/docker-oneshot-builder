# Docker One-Shot Buulder

TODO: Intro

## Internal Information

### Preparation Steps

To build up the internals of the container, the `prep` script in the
`prep` directory is executed.  The script makes determinations about
the operating system running it and then attempts to execute a series
of additional scripts in the same directory in this order:

 * Operating System (`Linux`)
 * Operating System - Family (`RedHat`, `Debian`)
 * Operating System - Family - Major Version (`9`, `10`)
 * Operating System - Family - Major Version - Distribution (`almalinux`, `ubuntu`)

Following that, the same set of scripts with the suffix `-post` will be appended.

For example, on AlmaLinux 9, `prep` will attempt to execute these scripts:

 * Linux
 * Linux-RedHat
 * Linux-RedHat-9
 * Linux-RedHat-9-almalinux
 * Linux-post
 * Linux-RedHat-post
 * Linux-RedHat-9-post
 * Linux-RedHat-9-almalinux-post

Scripts that do not exist will be silently skipped.

Preparation steps should be placed in the most-generic

For example, 