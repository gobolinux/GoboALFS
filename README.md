# GoboALFS
The Automated [Gobo]Linux From Scratch automates the bootstrap of
new GoboLinux releases.

## Prerequisites
Your host system must have the following development packages:
* subversion
* bison
* gawk
* make
* gcc
* g++
* xz-utils
* libxml2-utils
* xsltproc
* docbook2x
* libncurses5-dev
* texinfo
* git
* uuid-dev
* autoconf
* unionfs-fuse
* squashfs-tools version 4.0 or above.
* genisoimage (for mkisofs)
* syslinux-utils (for isohybrid)
* dosfstools (for mkfs.fat)

Also, the `lfs` user and group must exist. Please make sure that
the `lfs` user has sudo privileges.

## Bootstrapping from a Linux container
If you are bootstrapping GoboLinux from a Linux container (e.g.., LXC),
certify that you are running a privileged container and that apparmor
lets you mount the devpts filesystem. On most distros'
`/etc/apparmor.d/lxc/lxc-default` you will have to replace a line that reads
```
deny mount fstype=devpts,
```
with
```
mount options=(rw,newinstance) -> /dev/pts/,
```

## Usage
Logged in as `lfs`, simply create a work directory (e.g., `/GoboLinux`) and
launch the main script passing that directory as its sole argument:
```
$ ./GoboALFS /GoboLinux
```
