# $Id: Rules.mk,v 1.7 2004/01/22 15:24:57 jaco Exp $

TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=$(TOPDIR)/lufs
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
DESTDIR=

CXXFLAGS=-Wall -DDEBUG -I$(LUFSDIR)/include
CFLAGS=-Wall -I$(LUFSDIR)/include

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
