# $Id: Rules.mk,v 1.14 2003/10/09 11:24:00 jaco Exp $

# User parameters: These are parameters that can be changed for
# your installation (See the FAQ for valid options)
DEF_KEYBOARD=us

# these two parameters need to match up to allow splash to work
DEF_RESOLUTION=1024x768
DEF_VGAMODE=791

# these are base modules to be used for the fs types, IDE and
# their dependancies
DEF_MODULES=ext3 jbd nls_iso8859-13 nls_iso8859-14 \
nls_iso8859-15 nls_iso8859-1 nls_iso8859-2 nls_iso8859-3 nls_iso8859-4 \
nls_iso8859-5 nls_iso8859-6 nls_iso8859-7 nls_iso8859-8 nls_iso8859-9 \
nls_utf8

# these are the dependancies for the above
DEF_MODULES_OPT=translucency zlib_inflate
DEF_MODULES_DEP=isofs cdrom ide-cd

# these modules are for all the SCSI types out there
# not available: ncr53c8xx
DEF_SCSI_MODULES=aic7xxx aic7xxx_old BusLogic NCR53c406a \
initio advansys aha1740 aha1542 aha152x atp870u dtc eata fdomain \
gdth megaraid pas16 pci2220i pci2000 psi240i qlogicfas qlogicfc \
qlogicisp seagate t128 tmscsim u14-34f ultrastor wd7000 \
a100u2w 3w-xxxx sym53c8xx

# these are dependancies for the above modules
DEF_SCSI_MODULES_DEP=scsi_mod sr_mod sd_mod

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=7
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

# these are files in the root dir
DOCDIST=AUTHORS \
	CHANGELOG \
	COPYING \
	FAQ \
	README \
	TODO \
	Makefile \
	Rules.mk \
	$(DISTDIR)/$(PKGNAME).spec

# these are files in the src dir
SRCDIST=$(SRCDIR)/linuxrc.in \
	$(SRCDIR)/$(PKGNAME).in \
	$(SRCDIR)/hwdetect.in
