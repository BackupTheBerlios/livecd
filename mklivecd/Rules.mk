# $Id: Rules.mk,v 1.7 2003/10/03 13:45:54 jaco Exp $

# User parameters: These are parameters that can be changed for
# your installation (See the FAQ for valid options)
DEF_KEYBOARD=us

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=6
RELVER=1
CVSVER=yes

# Automatic variable updates, leave alone
MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +cvs.%Y%m%d)
	MKLIVECDREL=0.$(CVSDATE).$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)-$(CVSDATE)
else
	MKLIVECDREL=$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)
endif
KERNELVER=$(shell uname -r)
SPECDATE=$(shell date +"%a %b %e %Y")

# Internal directories: don't edit
DISTDIR=dist
SRCDIR=src
MKLIVECDDIST=$(PKGNAME)-$(ARCHIVEVER)

# Destination directories: you can change the locations for your site either
# here or as an override on the make command-line (preferred)
DESTDIR=
PREFIX=/usr
SBINPREFIX=$(PREFIX)
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib/$(PKGNAME)
SHAREDIR=$(PREFIX)/share/$(PKGNAME)
DOCDIR=$(PREFIX)/doc/$(PKGNAME)
SBINDIR=$(SBINPREFIX)/sbin
RCDIR=$(SHAREDIR)/init.d

# Utility programs: you can change the locations for your site either
# here or as an override on the make command-line (preferred)
BZIP2=$(shell which bzip2)
CAT=$(shell which cat)
CP=$(shell which cp)
GZIP=$(shell which gzip)
INSTALL=$(shell which install)
MD5SUM=$(shell which md5sum)
MKDIR=$(shell which mkdir)
LN=$(shell which ln)
RM=$(shell which rm)
RPMBUILD=$(shell which rpmbuild)
SED=$(shell which sed)
TAR=$(shell which tar)
TOUCH=$(shell which touch)
