# $Id: Rules.mk,v 1.2 2004/01/18 16:51:02 jaco Exp $

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
	$(LUFSDIR)/lufsd/dircache.o

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
