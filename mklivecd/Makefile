### $Id: Makefile,v 1.10 2003/10/01 08:28:22 jaco Exp $

### our version identifiers
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=6
RPMRELVER=1mdk
CVSVER=yes

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

### destination directories
DESTDIR=
PREFIX=/usr
SBINPREFIX=$(PREFIX)
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib/$(PKGNAME)
SHAREDIR=$(PREFIX)/share/$(PKGNAME)
DOCDIR=$(PREFIX)/doc/$(PKGNAME)
SBINDIR=$(SBINPREFIX)/sbin
RCDIR=$(SHAREDIR)/init.d

### internal directories
DISTDIR=dist
SRCDIR=src
MKLIVECDDIST=$(PKGNAME)-$(ARCHIVEVER)

### utility programs
BZIP2=/usr/bin/bzip2
CAT=/bin/cat
CP=/bin/cp
GZIP=/bin/gzip
INSTALL=/usr/bin/install
MD5SUM=/usr/bin/md5sum
MKDIR=/bin/mkdir
LN=/bin/ln
RM=/bin/rm
RPMBUILD=/usr/bin/rpmbuild
SED=/bin/sed
TAR=/bin/tar
TOUCH=/bin/touch

all: version mklivecd

version:
	echo "$(MKLIVECDVER)"

mklivecd:
	$(MKDIR) -p $(DISTDIR)/init.d
	$(CP) $(SRCDIR)/isolinux.cfg $(DISTDIR)
	$(CP) $(SRCDIR)/init.d/hwdetect $(DISTDIR)/init.d
	$(CAT) $(SRCDIR)/hwdetect.in | \
		$(SED) -e 's/\@MKLIVECDVER/$(ARCHIVEVER)/g' \
		>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's/\@MKLIVECDVER/$(MKLIVECDVER)/g;s/\@KERNELVER/$(KERNELVER)/g' \
		>$(DISTDIR)/linuxrc
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's/\@MKLIVECDVER/$(MKLIVECDVER)/g' \
		>$(DISTDIR)/$(PKGNAME)

install:
	$(MKDIR) -p $(DESTDIR)$(SHAREDIR)
	$(MKDIR) -p $(DESTDIR)$(SBINDIR)
	$(MKDIR) -p $(DESTDIR)$(RCDIR)
	$(INSTALL) -m 644 $(DISTDIR)/linuxrc $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 644 $(DISTDIR)/isolinux.cfg $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 755 $(DISTDIR)/$(PKGNAME) $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(DISTDIR)/hwdetect $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(DISTDIR)/init.d/hwdetect $(DESTDIR)$(RCDIR)

spec:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(PKGNAME).spec.in | \
		$(SED) -e 's/@MKLIVECDVER/$(MKLIVECDVER)/g;s/@RELEASE/$(RELEASE)/g' \
		>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(DISTDIR)

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)/init.d
	$(CP) AUTHORS CHANGELOG COPYING FAQ README TODO Makefile $(DISTDIR)/$(PKGNAME).spec $(MKLIVECDDIST)
	$(CP) $(SRCDIR)/isolinux.cfg $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/linuxrc.in $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/$(PKGNAME).in $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/hwdetect.in $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/init.d/hwdetect $(MKLIVECDDIST)/$(SRCDIR)/init.d
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(MKLIVECDDIST).tar.bz2
