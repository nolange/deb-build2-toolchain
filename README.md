<!-- vi:et:ts=4 -->
# unofficial Debian package for build2 toolchain

# Preparation

```bash
apt-get install dpkg-dev debhelper
```

# How to setup a working debian source package

These are the steps necessary to build a working
source-package you can then build with `dpkg-buildpackage -b`

the `debian/rules` is a standard make file by the way,
so targets like the bootstrap can be invoked directly by eg.
`debian/rules bootstrap-p2`

## Step 1a Download build2 and libbutl archives

This is mutually exclusive with Step 1b, and not supported anymore!

```bash
VERSION=0.6.0
BUILDPKG_URL=https://pkg.cppget.org/1/alpha/build2/build2-0.6.0.tar.gz
LIBUTLPKG_URL=https://pkg.cppget.org/1/alpha/build2/libbutl-0.6.0.tar.gz
wget $BUILDPKG_URL
wget $LIBUTLPKG_URL

mv "$(readlink -f ${BUILDPKG_URL##*/})" build2-toolchain_$VERSION.orig.tar.gz
mv "$(readlink -f ${LIBUTLPKG_URL##*/})" build2-toolchain_$VERSION.orig-libbutl.tar.gz
```

## Step 1b Prepare build2 and libbutl archives from the conglomerate toolchain package

This is mutually exclusive with Step 1a

In case you want a more recent version that - so far - only is available
as full package

```bash
VERSION=0.6.99
FULLPACKAGE_URL=https://stage.build2.org/0/0.7.0-a.0/build2-toolchain-0.7.0-a.0.1513492208.1b466e40662bb9a4.tar.xz

FULLPACKAGE=${FULLPACKAGE_URL##*/}
wget $FULLPACKAGE_URL

mkdir -p build2-toolchain_full
tar -C build2-toolchain_full -x -f "$(readlink -f $FULLPACKAGE)" --strip-components=1

tar -C build2-toolchain_full -c -J -f build2-toolchain_$VERSION.orig.tar.xz build2
tar -C build2-toolchain_full -c -J -f build2-toolchain_$VERSION.orig-libbutl.tar.xz libbutl
tar -C build2-toolchain_full -c -J -f build2-toolchain_$VERSION.orig-libpkgconf.tar.xz libpkgconf
```

## Step 2 Unpack the sources and copy the debian directory

```bash
mkdir -p build2-toolchain build2-toolchain/libbutl build2-toolchain/libpkgconf
tar -C build2-toolchain -x -f build2-toolchain_$VERSION.orig.tar.?z --strip-components=1
tar -C build2-toolchain/libbutl -x -f build2-toolchain_$VERSION.orig-libbutl.tar.?z --strip-components=1
tar -C build2-toolchain/libpkgconf -x -f build2-toolchain_$VERSION.orig-libpkgconf.tar.?z --strip-components=1

cp -r <path to debian directory> build2-toolchain
```

## Step 3 Create the source package

Finish up the source-package by generating the debian specific
files.

```bash
cd build2-toolchain && dpkg-buildpackage -S
```

This will result in the following files,
the .dsc file being the canonical source package information

```
build2-toolchain_0.7.0-1.debian.tar.xz
build2-toolchain_0.7.0-1.dsc
build2-toolchain_0.7.0.orig-libbutl.tar.xz
build2-toolchain_0.7.0.orig-libpkgconf.tar.xz
build2-toolchain_0.7.0.orig.tar.xz
```

# TODOs

-   \[X\] Find a proper solution for the libbutl dpendency

-   \[ \] libpkgconf should be brought into debian before build2, currently its statically linked to not mess things up for the future

-   \[X\] Properly support arguments for parallel builds

-   \[ \] Symbol files for libraries

-   \[ \] ... and more fixes for libbutl (weird versioning scheme?)

-   \[x\] Multiarch builds

-   \[ \] figure out how to build in a subdirectory (symlinks?). Cleanup is currently messy
