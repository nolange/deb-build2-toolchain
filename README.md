<!-- vi:et:ts=4 -->
# unofficial Debian package for build2 toolchain

This is an effort to package the build2 buildsystem in a proper
debian package.
It just includes the debian specific scripts, steps to create a full source package
are described.

the full source package should then be able to be compiled into the binary packages
to all supported architectures with debian "Jessie" or later (as build2 depends on gcc with C++14 support).

# Preparation

To be able to build the package you will need the debian build system helpers.

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
FULLPACKAGE_URL=https://stage.build2.org/0/0.7.0-a.0/build2-toolchain-0.7.0-a.0.1516205176.fb7f383bdb5b2f38.tar.xz

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
build2-toolchain_0.6.99-1.debian.tar.xz
build2-toolchain_0.6.99-1.dsc
build2-toolchain_0.6.99.orig-libbutl.tar.xz
build2-toolchain_0.6.99.orig-libpkgconf.tar.xz
build2-toolchain_0.6.99.orig.tar.xz
```

## Step 4 Create the binary packages

This is not the primary focus, better tutorials are elsewhere.

Local Build would be:

```bash
dpkg-source -x build2-toolchain_0.6.99-1.dsc
cd build2-toolchain-0.6.99
dpkg-buildpackage
```

If you have to rebuild multiple times, maybe you can an want to skip the bootstrap build.
This can be done by setting an environment variable containing the path to an existing build2 binary
(should be the same version as the target, ideally taken from a previous run).

```
DEBUG_USE_BOOTSTRAP=/tmp/b dpkg-buildpackage
```

Crosscompiling still fails after compiling when trying to resolve library dependencies for packaging (`dh_shlibdeps`),
a workaround is available with `DO_CROSS_WORKAROUND`, this is primary for testing, regular packages are *not* built this way.
exemplary [Cross Build](https://wiki.debian.org/CrossCompiling#Building_with_dpkg-buildpackage) would be (build *for armel*):

```bash
dpkg-source -x build2-toolchain_0.6.99-1.dsc
cd build2-toolchain-0.6.99
DO_CROSS_WORKAROUND=1 dpkg-buildpackage -aarmel
```

## Step 5 Install the binary packages

Install build2, together with the dependendy libutl:

```bash
dpkg -i build2_0.6.99-1_amd64.deb libbutl_0.6.99-1_amd64.deb
```

# TODOs

-   \[X\] Find a proper solution for the libbutl dpendency

-   \[ \] libpkgconf should be brought into debian before build2, currently its statically linked to not mess things up for the future

-   \[X\] Properly support arguments for parallel builds

-   \[ \] Symbol files for libraries ?

-   \[ \] ... and more fixes for libbutl (weird versioning scheme?)

-   \[x\] Multiarch builds

-   \[ \] figure out how to build in a subdirectory (symlinks?). Cleanup is currently messy
