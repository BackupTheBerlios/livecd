# $Id: Rules.mk,v 1.1 2003/10/01 12:04:25 jaco Exp $

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=6
RPMRELVER=1mdk
CVSVER=yes

# Automatic variable updates, leave alone
MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +cvs.%Y%m%d)
	RELEASE=0.$(CVSDATE).$(RPMRELVER)
	ARCHIVEVER=$(MKLIVECDVER)-$(CVSDATE)
else
	RELEASE=$(RPMRELVER)
	ARCHIVEVER=$(MKLIVECDVER)
endif
KERNELVER=$(shell uname -r)

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
