### $Id: Makefile,v 1.5 2003/09/29 10:39:26 jaco Exp $

### our version identifiers
MAJORVER=0
MINORVER=5
PATCHVER=5
CVSVER=yes

ifeq "$(CVSVER)" "yes" 
	MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)$(shell date +-cvs.%Y%m%d)
else
	MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
endif
KERNELVER=$(shell uname -r)

### destination directories
DESTDIR=
PREFIX=/usr
SBINPREFIX=$(PREFIX)
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib/mklivecd
SHAREDIR=$(PREFIX)/share/mklivecd
DOCDIR=$(PREFIX)/doc/mklivecd
SBINDIR=$(SBINPREFIX)/sbin
RCDIR=$(SHAREDIR)/init.d

### internal directories
MKLIVECDBUILD=.build
MKLIVECDSRC=src
MKLIVECDDIST=mklivecd-$(MKLIVECDVER)

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
SED=/bin/sed
TAR=/bin/tar
TOUCH=/bin/touch

all: version mklivecd

version:
	echo "$(MKLIVECDVER)"

mklivecd:
	$(RM) -rf $(MKLIVECDBUILD)
	$(MKDIR) -p $(MKLIVECDBUILD)/init.d
	$(CP) $(MKLIVECDSRC)/isolinux.cfg $(MKLIVECDBUILD)
	$(CP) $(MKLIVECDSRC)/init.d/hwdetect $(MKLIVECDBUILD)/init.d
	$(CAT) $(MKLIVECDSRC)/hwdetect.in | \
		$(SED) -e 's/\@MKLIVECDVER/$(MKLIVECDVER)/g' \
		>$(MKLIVECDBUILD)/hwdetect
	$(CAT) $(MKLIVECDSRC)/linuxrc.in | \
		$(SED) -e 's/\@MKLIVECDVER/$(MKLIVECDVER)/g;s/\@KERNELVER/$(KERNELVER)/g' \
		>$(MKLIVECDBUILD)/linuxrc
	$(CAT) $(MKLIVECDSRC)/mklivecd.in | \
		$(SED) -e 's/\@MKLIVECDVER/$(MKLIVECDVER)/g' \
		>$(MKLIVECDBUILD)/mklivecd

install:
	$(MKDIR) -p $(DESTDIR)$(SHAREDIR)
	$(MKDIR) -p $(DESTDIR)$(SBINDIR)
	$(MKDIR) -p $(DESTDIR)$(RCDIR)
	$(INSTALL) -m 644 $(MKLIVECDBUILD)/linuxrc $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 644 $(MKLIVECDBUILD)/isolinux.cfg $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 755 $(MKLIVECDBUILD)/mklivecd $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(MKLIVECDBUILD)/hwdetect $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(MKLIVECDBUILD)/init.d/hwdetect $(DESTDIR)$(RCDIR)

spec:
	$(CAT) mklivecd.spec.in | \
		$(SED) -e 's/@MKLIVECDVER/$(MKLIVECDVER)/g' \
		>mklivecd.spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(MKLIVECDBUILD)
	$(RM) -rf mklivecd.spec

dist: clean spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(MKLIVECDSRC)/init.d
	$(CP) AUTHORS CHANGELOG COPYING FAQ README TODO Makefile mklivecd.spec $(MKLIVECDDIST)
	$(CP) $(MKLIVECDSRC)/isolinux.cfg $(MKLIVECDDIST)/$(MKLIVECDSRC)
	$(CP) $(MKLIVECDSRC)/linuxrc.in $(MKLIVECDDIST)/$(MKLIVECDSRC)
	$(CP) $(MKLIVECDSRC)/mklivecd.in $(MKLIVECDDIST)/$(MKLIVECDSRC)
	$(CP) $(MKLIVECDSRC)/hwdetect.in $(MKLIVECDDIST)/$(MKLIVECDSRC)
	$(CP) $(MKLIVECDSRC)/init.d/hwdetect $(MKLIVECDDIST)/$(MKLIVECDSRC)/init.d
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(MKLIVECDDIST).tar.bz2 >$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)
