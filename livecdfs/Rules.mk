# $Id: Rules.mk,v 1.14 2004/01/25 14:35:14 jaco Exp $

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
CXXFLAGS+=-Wall -fno-rtti -fno-exceptions $(EXTRA_CXXFLAGS) -I$(LUFSDIR)/include
CFLAGS+=-Wall $(EXTRA_CFLAGS) -I$(LUFSDIR)/include

# internal directories
DISTDIR=dist
SRCDIR=src
LUFSDIR=lufs
TOPDIR=$(shell pwd)

# external directories
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
DESTDIR=

# cour commands
BZIP2=bzip2
CAT=cat
CD=cd
CP=cp
FIND=find
GREP=grep
LN=ln
MD5SUM=md5sum
MKDIR=mkdir
RM=rm
RPMBUILD=rpmbuild
SED=sed
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
	README
	
BUILDDIST=\
	Makefile \
	Rules.mk \
	$(DISTDIR)/$(PKGNAME).spec

EXTDIST=$(LUFSDIR)

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
