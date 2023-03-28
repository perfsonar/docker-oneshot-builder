# Preparation Scripts

This directory contains a set of scripts run inside the container
while building it.  Their purpose is to take OS, family, version and
distribution-specific steps that prepare the system for use.  This
includes updating the system and installing required packages.

To build up the internals of the container, the `prep` script in the
`prep` directory is executed.  The script makes determinations about
the operating system running it and then attempts to execute a series
of additional scripts in the same directory in this order:

 * Operating System (`Linux`)
 * Operating System - Family (`RedHat`, `Debian`)
 * Operating System - Family - Major Version (`9`, `10`)
 * Operating System - Family - Major Version - Distribution (`almalinux`, `ubuntu`)

Note: This is a bit broken for Debian and Ubuntu and should probably
be re-ordered so the major version comes last (e.g.,
`Linux-RedHat-almalinux-9` or `Linux-Debian-ubuntu-22`).

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

Preparation steps should be placed in the most-generic script
possible.  For example, something available on all Red Hat-derived
systems regardless of version should be in `Linux-Redhat` or
`Linux-Redhat.post`.  Similarly, something specific to AlmaLinux 9
should be placed in `Linux-RedHat-9-almalinux-post`.
