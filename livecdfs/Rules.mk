# $Id: Rules.mk,v 1.3 2004/01/21 19:21:03 jaco Exp $

TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=$(TOPDIR)/lufs
PREFIX=/usr
LIBDIR=$(PREFIX)/lib

CXXFLAGS=-I$(LUFSDIR)/include -DDEBUG
CFLAGS=-I$(LUFSDIR)/include

CD=cd
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

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
