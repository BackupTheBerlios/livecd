# $Id: Rules.mk,v 1.21 2004/01/30 19:23:15 jaco Exp $

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=livecdfs
MAJORVER=0
MINORVER=1
PATCHVER=0
RELVER=1
CVSVER=yes

# Automatic variable updates, leave alone
LIVECDFSVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +cvs.%Y%m%d)
	LIVECDFSREL=0.$(CVSDATE).$(RELVER)
	ARCHIVEVER=$(LIVECDFSVER)-$(CVSDATE)
else
	LIVECDFSREL=$(RELVER)
	ARCHIVEVER=$(LIVECDFSVER)
endif
KERNELVER=$(shell uname -r)
SPECDATE=$(shell LC_ALL=C date +"%a %b %e %Y")
LIVECDFSDIST=$(PKGNAME)-$(ARCHIVEVER)

# our flags
EXTRA_CXXFLAGS=-DDEBUG
CXXFLAGS+=-O2 -g -Wall -fno-rtti -fno-exceptions -fPIC $(EXTRA_CXXFLAGS) -I$(LUFSDIR)/include
EXTRA_CFLAGS=
CFLAGS+=-O2 -g -Wall -fPIC $(EXTRA_CFLAGS) -I$(LUFSDIR)/include

# internal directories
DISTDIR=dist
SRCDIR=src
LUFSDIR=lufs
TOPDIR=$(shell pwd)

# external directories
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
BINDIR=$(PREFIX)/bin
SBINDIR=$(PREFIX)/sbin
DESTDIR=

# cour commands
BZIP2=bzip2
CAT=cat
CD=cd
CP=cp
FIND=find
GREP=grep
INSTALL=install
LN=ln
MD5SUM=md5sum
MKDIR=mkdir
RM=rm
RPMBUILD=rpmbuild
SED=sed
STRIP=strip
TAR=tar
XARGS=xargs

# our files
OBJECTS=\
	$(SRCDIR)/handles.o \
	$(SRCDIR)/livecdfs.o \
	$(SRCDIR)/main.o \
	$(SRCDIR)/path.o \
	$(SRCDIR)/whiteout.o \
	$(LUFSDIR)/lufsd/dircache.o

INCLUDES=\
	$(SRCDIR)/debug.h \
	$(SRCDIR)/handles.h \
	$(SRCDIR)/livecdfs.h \
	$(SRCDIR)/path.h \
	$(SRCDIR)/whiteout.h

SOURCES=\
	$(SRCDIR)/handles.cpp \
	$(SRCDIR)/livecdfs.cpp \
	$(SRCDIR)/main.cpp \
	$(SRCDIR)/path.cpp \
	$(SRCDIR)/test.cpp \
	$(SRCDIR)/whiteout.cpp

DOCDIST=\
	AUTHORS \
	CHANGELOG \
	COPYING \
	CREDITS \
	README \
	README.USAGE
	
BUILDDIST=\
	Makefile \
	Rules.mk \
	$(DISTDIR)/$(PKGNAME).spec

EXTDIST=$(LUFSDIR)

LIBRARY=liblufs-livecdfs.so

LUFSDLIVECDFS=lufsd.livecdfs

LUFSOBJS=$(LUFSDIR)/lufsd/options.o

LUFSDOBJS=\
	$(LUFSDIR)/lufsd/daemon.o \
	$(LUFSDIR)/lufsd/filesystem.o \
	$(LUFSDIR)/lufsd/fsctl.o \
	$(LUFSDIR)/lufsd/message.o \
	$(LUFSDIR)/lufsd/options.o
	