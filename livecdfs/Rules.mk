# $Id: Rules.mk,v 1.1 2004/01/18 15:47:52 jaco Exp $

TOPDIR=$(shell pwd)
SRCDIR=src
LUFSDIR=$(TOPDIR)/lufs

CXXFLAGS=-I$(LUFSDIR)/include -DDEBUG
CFLAGS=-I$(LUFSDIR)/include

CD=cd
FIND=find
GREP=grep
LN=ln
RM=rm
XARGS=xargs

OBJECTS=$(SRCDIR)/handles.o \
	$(SRCDIR)/livecdfs.o \
	$(SRCDIR)/main.o \
	$(SRCDIR)/path.o \
	$(LUFSDIR)/lufsd/dircache.o

LIBRARY=liblufs-livecdfs.so

LUFSOBJS=$(LUFSDIR)/lufsd/options.o
