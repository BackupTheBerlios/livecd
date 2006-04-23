# $Id: Rules.mk,v 1.10 2006/04/23 03:38:23 tom_kelly33 Exp $

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=livecd-utils
MAJORVER=0
MINORVER=3
PATCHVER=0
RELVER=1
CVSVER=yes

# Automatic variable updates, leave alone
UTILSVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +%Y%m%d)
	UTILSREL=$(CVSDATE).$(RELVER)
	ARCHIVEVER=$(UTILSVER)-$(CVSDATE)
else
	UTILSREL=$(RELVER)
	ARCHIVEVER=$(UTILSVER)
endif
SPECDATE=$(shell LC_ALL=C date +"%a %b %e %Y")

# Internal directories: don't edit
DISTDIR=dist
ICONDIR=icons
IMGDIR=images
SRCDIR=src
UTILSDIST=$(PKGNAME)-$(ARCHIVEVER)
ICONSDIST=$(PKGNAME).icons

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
PUIC=$(shell which puic)
LN=$(shell which ln)
RM=$(shell which rm)
RPMBUILD=$(shell which rpmbuild)
SED=$(shell which sed)
TAR=$(shell which tar)
TOUCH=$(shell which touch)

# these are files in the root dir
DOCDIST=\
	AUTHORS \
	CHANGELOG \
	COPYING \
	CREDITS \
	Makefile \
	Rules.mk \
	$(DISTDIR)/$(PKGNAME).spec

# these are files in the src dir
SRCDIST=\
	$(SRCDIR)/livecd-install.pro \
	$(SRCDIR)/livecd-install.ui \
	$(SRCDIR)/livecd-install.ui.pm \
	$(SRCDIR)/livecd-install-lang.pm.in \
	$(SRCDIR)/livecd-install.pl.in
