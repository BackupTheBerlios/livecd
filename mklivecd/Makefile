# $Id: Makefile,v 1.15 2003/10/02 07:57:55 jaco Exp $

include Rules.mk

all: mklivecd

version:
	@echo "$(PKGNAME), $(MKLIVECDVER)-$(MKLIVECDREL)"

mklivecd:
	$(MKDIR) -p $(DISTDIR)/init.d
	$(CP) $(SRCDIR)/isolinux.cfg $(DISTDIR)
	$(CP) $(SRCDIR)/init.d/hwdetect $(DISTDIR)/init.d
	$(CAT) $(SRCDIR)/hwdetect.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g;s/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' \
		>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g;s/@KERNELVER@/$(KERNELVER)/g' \
		>$(DISTDIR)/linuxrc
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g' \
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
		$(SED) -e 's/@MKLIVECDVER@/$(MKLIVECDVER)/g;s/@MKLIVECDREL@/$(MKLIVECDREL)/g;s/@SPECDATE@/$(SPECDATE)/g' \
		>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(DISTDIR)

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)/init.d
	$(CP) AUTHORS CHANGELOG COPYING FAQ README TODO Makefile Rules.mk $(DISTDIR)/$(PKGNAME).spec $(MKLIVECDDIST)
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
