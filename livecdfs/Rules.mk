# $Id: Rules.mk,v 1.4 2004/01/22 08:37:20 jaco Exp $

TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=$(TOPDIR)/lufs
PREFIX=/usr
LIBDIR=$(PREFIX)/lib

CXXFLAGS=-Wall -DDEBUG -I$(LUFSDIR)/include
CFLAGS=-Wall -I$(LUFSDIR)/include

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
