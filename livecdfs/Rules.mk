# $Id: Rules.mk,v 1.10 2004/01/24 10:33:18 jaco Exp $

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

# our flags
CXXFLAGS=-Wall -DDEBUG -I$(LUFSDIR)/include
CFLAGS=-Wall -I$(LUFSDIR)/include

# internal directories
TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=lufs

# external directories
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
DESTDIR=

# cour commands
CD=cd
CP=cp
FIND=find
GREP=grep
LN=ln
MKDIR=mkdir
RM=rm
XARGS=xargs

# our files
OBJECTS=$(SRCDIR)/handles.o \
	$(SRCDIR)/livecdfs.o \
	$(SRCDIR)/main.o \
	$(SRCDIR)/path.o \
	$(SRCDIR)/whiteout.o \
	$(LUFSDIR)/lufsd/dircache.o

INCLUDES=$(SRCDIR)/handles.h \
	$(SRCDIR)/livecdfs.h \
	$(SRCDIR)/main.h \
	$(SRCDIR)/path.h \
	$(SRCDIR)/whiteout.h

SOURCES=$(SRCDIR)/handles.cpp \
	$(SRCDIR)/livecdfs.cpp \
	$(SRCDIR)/main.cpp \
	$(SRCDIR)/path.cpp \
	$(SRCDIR)/test.cpp \
	$(SRCDIR)/whiteout.cpp

EXTSRC=$(LUFSDIR)/*

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
