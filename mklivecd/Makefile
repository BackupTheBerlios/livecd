# $Id: Makefile,v 1.20 2003/10/04 10:03:28 jaco Exp $

include Rules.mk

all: mklivecd

version:
	@echo "$(PKGNAME), $(MKLIVECDVER)-$(MKLIVECDREL)"

mklivecd:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(SRCDIR)/hwdetect.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g;s/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' \
		>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g;s/@KERNELVER@/$(KERNELVER)/g' \
		>$(DISTDIR)/linuxrc
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's/@PKGNAME@/$(PKGNAME)/g;s/@MKLIVECDVER@/$(ARCHIVEVER)/g;s/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' \
		>$(DISTDIR)/$(PKGNAME)

install:
	$(MKDIR) -p $(DESTDIR)$(SHAREDIR)
	$(MKDIR) -p $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 644 $(DISTDIR)/linuxrc $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 755 $(DISTDIR)/$(PKGNAME) $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(DISTDIR)/hwdetect $(DESTDIR)$(SBINDIR)

spec:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(PKGNAME).spec.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(MKLIVECDVER)/g;s/@MKLIVECDREL@/$(MKLIVECDREL)/g;s/@SPECDATE@/$(SPECDATE)/g;s/@ARCHIVEVER@/$(ARCHIVEVER)/g' \
		>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(DISTDIR)

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) AUTHORS CHANGELOG COPYING FAQ README TODO Makefile Rules.mk $(DISTDIR)/$(PKGNAME).spec $(MKLIVECDDIST)
	$(CP) $(SRCDIR)/linuxrc.in $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/$(PKGNAME).in $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(SRCDIR)/hwdetect.in $(MKLIVECDDIST)/$(SRCDIR)
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(MKLIVECDDIST).tar.bz2
