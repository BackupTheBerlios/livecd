# $Id: Makefile,v 1.21 2003/10/04 16:10:43 jaco Exp $

include Rules.mk

all: mklivecd

version:
	@echo "$(PKGNAME), $(MKLIVECDVER)-$(MKLIVECDREL)"

mklivecd:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(SRCDIR)/hwdetect.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g' | \
		$(SED) -e 's/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' \
			>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g' | \
		$(SED) -e 's/@KERNELVER@/$(KERNELVER)/g' \
			>$(DISTDIR)/linuxrc
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's/@PKGNAME@/$(PKGNAME)/g' | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g' | \
		$(SED) -e 's/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' | \
		$(SED) -e 's/@DEF_RESOLUTION@/$(DEF_RESOLUTION)/g' | \
		$(SED) -e 's/@DEF_VGAMODE@/$(DEF_VGAMODE)/g' \
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
		$(SED) -e 's/@MKLIVECDVER@/$(MKLIVECDVER)/g' | \
		$(SED) -e 's/@MKLIVECDREL@/$(MKLIVECDREL)/g' | \
		$(SED) -e 's/@SPECDATE@/$(SPECDATE)/g' | \
		$(SED) -e 's/@ARCHIVEVER@/$(ARCHIVEVER)/g' \
			>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(DISTDIR)

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(DOCDIST) $(MKLIVECDDIST)
	$(CP) $(SRCDIST) $(MKLIVECDDIST)/$(SRCDIR)
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 \
		>$(DISTDIR)/$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(MKLIVECDDIST).tar.bz2
