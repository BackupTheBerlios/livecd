# $Id: Makefile,v 1.1 2007/12/09 23:03:38 didouph Exp $

include Rules.mk
include Modules.mk

all: mklivecd

version:
	@echo "$(PKGNAME), $(MKLIVECDVER)-$(MKLIVECDREL)"

mklivecd:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(SRCDIR)/hwdetect.in | \
		$(SED) -e 's,@MKLIVECDVER@,$(ARCHIVEVER),g' | \
		$(SED) -e 's,@DEF_KEYBOARD@,$(DEF_KEYBOARD),g' | \
		$(SED) -e 's,@MAX_SPLASH@,$(MAX_SPLASH),g' | \
		$(SED) -e 's,@VAL_SPLASH_FULL@,$(VAL_SPLASH_FULL),g' | \
		$(SED) -e 's,@VAL_SPLASH_LINUXRC@,$(VAL_SPLASH_LINUXRC),g' | \
		$(SED) -e 's,@VAL_SPLASH_SYSINIT@,$(VAL_SPLASH_SYSINIT),g' | \
		$(SED) -e 's,@VAL_SPLASH_HWDETECT@,$(VAL_SPLASH_HWDETECT),g' \
			>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/hwdetect-lang.in >>$(DISTDIR)/hwdetect
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's,@MKLIVECDVER@,$(ARCHIVEVER),g' | \
		$(SED) -e 's,@KERNELVER@,$(KERNELVER),g' | \
		$(SED) -e 's,@MAX_SPLASH@,$(MAX_SPLASH),g' | \
		$(SED) -e 's,@VAL_SPLASH_FULL@,$(VAL_SPLASH_FULL),g' | \
		$(SED) -e 's,@VAL_SPLASH_LINUXRC@,$(VAL_SPLASH_LINUXRC),g' | \
		$(SED) -e 's,@VAL_SPLASH_SYSINIT@,$(VAL_SPLASH_SYSINIT),g' | \
		$(SED) -e 's,@VAL_SPLASH_HWDETECT@,$(VAL_SPLASH_HWDETECT),g' | \
		$(SED) -e 's,@DEF_MODULES_26@,$(DEF_MODULES_26),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_26@,$(DEF_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_26@,$(DEF_MODULES_DEP_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_26@,$(DEF_SCSI_MODULES_26),g' | \
#		$(SED) -e 's,@DEF_SCSI_MODULES_old26@,$(DEF_SCSI_MODULES_old26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_26@,$(DEF_SCSI_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_26@,$(DEF_SCSI_MODULES_DEP_26),g' | \
#		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_old26@,$(DEF_SCSI_MODULES_DEP_old26),g' | \
		$(SED) -e 's,@DEF_USB_MODULES_26@,$(DEF_USB_MODULES_26),g' | \
		$(SED) -e 's,@DEF_USB_MODULES_DRV_26@,$(DEF_USB_MODULES_DRV_26),g' \
			>$(DISTDIR)/linuxrc
	$(CP) $(SRCDIR)/halt.local.in $(DISTDIR)/halt.local
	$(CAT) $(SRCDIR)/rc.sysinit.in | \
		$(SED) -e 's,@MAX_SPLASH@,$(MAX_SPLASH),g' | \
		$(SED) -e 's,@VAL_SPLASH_FULL@,$(VAL_SPLASH_FULL),g' | \
		$(SED) -e 's,@VAL_SPLASH_LINUXRC@,$(VAL_SPLASH_LINUXRC),g' | \
		$(SED) -e 's,@VAL_SPLASH_SYSINIT@,$(VAL_SPLASH_SYSINIT),g' | \
		$(SED) -e 's,@VAL_SPLASH_HWDETECT@,$(VAL_SPLASH_HWDETECT),g' \
			>$(DISTDIR)/rc.sysinit
	$(CAT) $(SRCDIR)/$(PKGNAME).in | \
		$(SED) -e 's,@PKGNAME@,$(PKGNAME),g' | \
		$(SED) -e 's,@MKLIVECDVER@,$(ARCHIVEVER),g' | \
		$(SED) -e 's,@DEF_KEYBOARD@,$(DEF_KEYBOARD),g' | \
		$(SED) -e 's,@DEF_UNION@,$(DEF_UNION),g' | \
		$(SED) -e 's,@DEF_RESOLUTION@,$(DEF_RESOLUTION),g' | \
		$(SED) -e 's,@DEF_VGAMODE@,$(DEF_VGAMODE),g' | \
		$(SED) -e 's,@DEF_MODULES_26@,$(DEF_MODULES_26),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_26@,$(DEF_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_26@,$(DEF_MODULES_DEP_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_26@,$(DEF_SCSI_MODULES_26),g' | \
#		$(SED) -e 's,@DEF_SCSI_MODULES_old26@,$(DEF_SCSI_MODULES_old26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_26@,$(DEF_SCSI_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_26@,$(DEF_SCSI_MODULES_DEP_26),g' | \
#		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_old26@,$(DEF_SCSI_MODULES_DEP_old26),g' | \
		$(SED) -e 's,@DEF_USB_MODULES_26@,$(DEF_USB_MODULES_26),g' | \
		$(SED) -e 's,@DEF_USB_MODULES_DRV_26@,$(DEF_USB_MODULES_DRV_26),g' \
			>$(DISTDIR)/$(PKGNAME)

install:
	$(MKDIR) -p $(DESTDIR)$(SHAREDIR)
	$(MKDIR) -p $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 644 $(DISTDIR)/linuxrc $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 644 $(DISTDIR)/halt.local $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 644 $(DISTDIR)/rc.sysinit $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 755 $(DISTDIR)/$(PKGNAME) $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(DISTDIR)/hwdetect $(DESTDIR)$(SBINDIR)

install-doc:
	$(MKDIR) -p $(DESTDIR)$(DOCDIR)
	$(CP) -f $(DOCDIST) $(DOCDIR)

spec:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(PKGNAME).spec.in | \
		$(SED) -e 's,@MKLIVECDVER@,$(MKLIVECDVER),g' | \
		$(SED) -e 's,@MKLIVECDREL@,$(MKLIVECDREL),g' | \
		$(SED) -e 's,@SPECDATE@,$(SPECDATE),g' | \
		$(SED) -e 's,@ARCHIVEVER@,$(ARCHIVEVER),g' \
			>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(MKLIVECDDIST)
	$(RM) -rf $(DISTDIR)
	$(RM) -rf $(SRCDIR)/*~

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(DOCDIST) $(MKLIVECDDIST)
	$(CP) $(BUILDDIST) $(MKLIVECDDIST)
	$(CP) $(SRCDIST) $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(PKGNAME).spec.in $(MKLIVECDDIST)
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 \
		>$(DISTDIR)/$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 --clean
