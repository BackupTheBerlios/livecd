# $Id: Makefile,v 1.23 2003/10/09 11:24:00 jaco Exp $

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
		$(SED) -e 's/@KERNELVER@/$(KERNELVER)/g' | \
		$(SED) -e 's/@DEF_MODULES@/$(DEF_MODULES)/g' | \
		$(SED) -e 's/@DEF_MODULES_OPT@/$(DEF_MODULES_OPT)/g' | \
		$(SED) -e 's/@DEF_MODULES_DEP@/$(DEF_MODULES_DEP)/g' | \
		$(SED) -e 's/@DEF_SCSI_MODULES@/$(DEF_SCSI_MODULES)/g' | \
		$(SED) -e 's/@DEF_SCSI_MODULES_DEP@/$(DEF_SCSI_MODULES_DEP)/g' \
			>$(DISTDIR)/linuxrc
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's/@PKGNAME@/$(PKGNAME)/g' | \
		$(SED) -e 's/@MKLIVECDVER@/$(ARCHIVEVER)/g' | \
		$(SED) -e 's/@DEF_KEYBOARD@/$(DEF_KEYBOARD)/g' | \
		$(SED) -e 's/@DEF_RESOLUTION@/$(DEF_RESOLUTION)/g' | \
		$(SED) -e 's/@DEF_VGAMODE@/$(DEF_VGAMODE)/g' | \
		$(SED) -e 's/@DEF_MODULES@/$(DEF_MODULES)/g' | \
		$(SED) -e 's/@DEF_MODULES_OPT@/$(DEF_MODULES_OPT)/g' | \
		$(SED) -e 's/@DEF_MODULES_DEP@/$(DEF_MODULES_DEP)/g' | \
		$(SED) -e 's/@DEF_SCSI_MODULES@/$(DEF_SCSI_MODULES)/g' | \
		$(SED) -e 's/@DEF_SCSI_MODULES_DEP@/$(DEF_SCSI_MODULES_DEP)/g' \
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
