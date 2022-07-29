# Linux

IIB/ACE is buildable on a wide range of Linux platforms and supported on most that are buildable.

Product   | x86_64 | s390x | ppc64le | ppc64
----------|--------|-------|---------|--------
IIB v10.0 | Supported | Supported | Supported | Supported
IIB v10.1 | Buildable | N/A | N/A | N/A
ACE v11.0 | Supported | Supported | Buildable | N/A
ACE v12.0 | Supported | Supported | Supported | N/A

An ARM build used to exist but this was never supported. No version of IIB/ACE currently supports building on Linux/ARM or other architectures.

We declare support for any Linux distribution that is sufficiently like a recent Red Hat Enterprise Linux (RHEL) release. Generally this means you should be able to build and run IIB or ACE on any recent RHEL, Ubuntu, Fedora, CentOS, or SLES/openSUSE release. As of July 2022 we use RHEL 7.9 as our SOE for ACE.

Most people in the department tend to use either Ubuntu or RHEL/Fedora as these are what are easily available in VMs or on IBM provided laptops.

I have broken down the prerequisites into their own sections, these do not have to be done in any particular order. It will probably be fastest to do a couple steps in parallel as you might be blocked by download or install times in places.

* [Java development kit](#java-development-kit)
* [GCC C/C++ Compiler](#gcc-cc-compiler)
* [Perl](#perl)
* [Python 3](#python-3)
* [Bison and Flex](#bison-and-flex)
* [IBM MQ](#ibm-mq)

## Java development kit

A large chunk of IIB/ACE is written in Java, as such you will need a Java development kit of an appropriate version. Since the server bundles an IBM JRE we make use of a number of IBM specific extensions, so an IBM JDK is required to build the product.

Both IIB and ACE required Java 8. IIB fix packs before 10.0.0.15 can be built with Java 7 but I would not recommend this for the purposes of a localbuild.

Go to the [IBM SDKs for Java download page on JIM](http://w3.hursley.ibm.com/java/jim/) to get the latest Java 8 release. For Linux you need to ensure you choose the _Linux_ release suitable for your CPU type (i.e. _AMD64/EM64T_ for xLinux, _S390 64-bit_ for zLinux, or _PPCLE_ for pLinux). Select the _SDK Package (tgz)_, you can try the RPM release but I've never used it.

Once you have downloaded the JDK, extract it to a known place on your disk, I prefer `/opt/ibm/java/8.0.x./`. The path you extract the JDK to is known as your `JAVA_HOME` and you will need to know this location later on so make a note of it now.

If you want to use this JDK as your system JDK, edit your `~/.bash_profile`, `.~/bashrc` or similar to add the following two lines:
```bash
export JAVA_HOME="/path/to/your/jdk"
export PATH="${JAVA_HOME}/bin:${PATH}"
```

## GCC C/C++ Compiler

The vast majority of the IIB/ACE code base is written in C++, as such you will need a compatible C++ compiler. The required compiler level depends on what version of IIB/ACE you are building. Currently the requirements are:

Product   | GCC Version
----------|----------
IIB v10.0 | GCC 4.8.5
IIB v10.1 | GCC 10
ACE v11.0 | GCC 7
ACE v12.0 | GCC 7

You should be able to use whatever version of GCC your distribution ships with as long as it is at least GCC 4.8.5. If it is not installed it is usually available from your package manager, you must ensure you get `gcc` as well as `g++`. If you are running RHEL/CentOS you can get more modern GCC versions from the devtoolset packages.

You can double check what version you have installed by running `g++ --version`, for example:
```bash
$ g++ --version
g++ (Ubuntu 9.3.0-10ubuntu2) 9.3.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Perl 5

We use Perl in a small number of places in the build, and it is heavily used by the test material. You need Perl 5, which is likely installed by your distribution. If not, install it from your package manager.

You can double check what version you have installed by running `perl --version`, for example:
```bash
$ perl --version

This is perl 5, version 30, subversion 0 (v5.30.0) built for x86_64-linux-gnu-thread-multi
(with 46 registered patches, see perl -V for more detail)

Copyright 1987-2019, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
```

## Python 3

Some newer parts of the build, and the ACE v11 SIS test framework, are written in Python 3. The minimum required version is Python 3.4, but the newest version of Python 3 should work. Python 2 is _not_ supported.

You need the `python3` executable to be on your PATH. Check it is present and its version by running `python3 --version`:
```bash
$ python3 --version
Python 3.8.2
```

## Bison and Flex

Bison and Flex are two tools that help generate parsers, and are used by in a couple of places in the codebase to generate some code. These are usually available from your package manager if they are not installed by default. I'm not quite sure what the minimum version requirements, at the time of writing I am personally using Bison 3.5.1 and Flex 2.6.4:
```bash
$ bison --version
bison (GNU Bison) 3.5.1
Written by Robert Corbett and Richard Stallman.

Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
$ flex --version
flex 2.6.4
```

## IBM MQ

Although IIB v10 and above no longer require a queue manager, we still rely on the header files provided by MQ to be available during the build.

IBM MQ can be downloaded internally from the [IBM Internal DSW Downloads (Extreme Leverage)](https://w3-03.ibm.com/software/xl/download/ticket.do) page. Search for `IBM MQ 9` and download the appropriate release for your distribution.

When downloading MQ 9 for Linux you have the choice of _MQ for Linux_ which uses RPMs, or _MQ for Ubuntu_ which uses DEBs. I would recommend you choose the one that is more natuarl for your platform.

You should be able to use any appropriate version, but I usually choose whatever was most recently released. At the time of writing that is _IBM MQ V9.2 Long Term Support Release_:

* xLinux:
    * **Red Hat:**  IBM MQ V9.2 Long Term Support Release for Linux on x86 64-bit Multilingual (CC5TSML)
    * **Ubuntu:** IBM MQ V9.2 Long Term Support Release for Ubuntu on x86 64-bit Multilingual (CC5TVML)
* zLinux:
    * **Red Hat:** 	IBM MQ V9.2 Long Term Support Release for Linux on IBM Z 64-bit Multilingual (CC5TRML)
    * **Ubuntu:** IBM MQ V9.2 Long Term Support Release for Ubuntu on IBM Z 64-bit Multilingual (CC5TUML)
* pLinux:
    * **Red Hat:**  IBM MQ V9.2 Long Term Support Release for Linux on LE Power Multilingual (CC5TQML)
    * **Ubuntu:** IBM MQ V9.2 Long Term Support Release for Ubuntu on LE Power Multilingual (CC5TTML)

I would recommend installing the full MQ server release, rather than just the MQ client as it will make local testing much easier. Installation instructions are available on the IBM MQ Knowledge Center:

* [Installing IBM MQ server on Linux using rpm](https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.2.0/com.ibm.mq.ins.doc/q008640_.htm)
* [Installing IBM MQ server on Linux using Debian packages](https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.2.0/com.ibm.mq.ins.doc/q129710_.htm)