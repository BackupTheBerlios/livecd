# $Id: Rules.mk,v 1.32 2005/09/25 06:12:29 ikerekes Exp $

# User parameters: These are parameters that can be changed for
# your installation (See the FAQ for valid options)
# The preferred way to change/overeride this is with a
#     make DEF_KEYBOARD=dvorak
DEF_KEYBOARD=us

# these two parameters need to match up to allow splash to work
# The preferred way to change/override this is with a
#     make DEF_RESOLUTION=800x600 DEF_VGAMODE=788
DEF_RESOLUTION=800x600
DEF_VGAMODE=788

# splash progress bar parameters
# MAX_SPLASH: default: 65534. With a patched bootsplash, the
# preferred way to change/override this is with a
#     make MAX_SPLASH=32767
MAX_SPLASH=65534

### no more user-editable parameters after this line

# various script number of splash steps
VAL_SPLASH_LINUXRC=6
VAL_SPLASH_SYSINIT=7
VAL_SPLASH_HWDETECT=17
VAL_SPLASH_FULL=20

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=9
RELVER=1
CVSVER=yes

# Automatic variable updates, leave alone
MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +%Y%m%d)
	MKLIVECDREL=0.$(CVSDATE).$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)-$(CVSDATE)
else
	MKLIVECDREL=$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)
endif
KERNELVER=$(shell uname -r)
SPECDATE=$(shell LC_ALL=C date +"%a %b %e %Y")

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
DOCDIR=$(PREFIX)/share/doc/$(PKGNAME)-$(MKLIVECDVER)
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

# these are files in the root dir
DOCDIST=\
	AUTHORS \
	CHANGELOG \
	COPYING \
	FAQ \
	README \
	README.BOOTCODES \
	README.USB \
	TODO

BUILDDIST=\
	Makefile \
	Rules.mk \
	Modules.mk \
	$(DISTDIR)/$(PKGNAME).spec

# these are files in the src dir
SRCDIST=\
	$(SRCDIR)/linuxrc.in \
	$(SRCDIR)/rc.sysinit.in \
	$(SRCDIR)/$(PKGNAME).in \
	$(SRCDIR)/hwdetect.in \
	$(SRCDIR)/hwdetect-lang.in \
	$(SRCDIR)/halt.local.in
