# $Id: Rules.mk,v 1.8 2004/01/24 10:25:06 jaco Exp $

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=livecdfs
MAJORVER=0
MINORVER=1
PATCHVER=0
RELVER=1
CVSVER=yes

# our flags
CXXFLAGS=-Wall -DDEBUG -I$(LUFSDIR)/include
CFLAGS=-Wall -I$(LUFSDIR)/include

# our directories
TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=$(TOPDIR)/lufs
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
DESTDIR=

CD=cd
CP=cp
FIND=find
GREP=grep
LN=ln
MKDIR=mkdir
RM=rm
XARGS=xargs

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

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
