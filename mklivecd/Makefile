# $Id: Makefile,v 1.31 2004/01/06 12:51:21 jaco Exp $

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
	$(CAT) $(SRCDIR)/linuxrc.in | \
		$(SED) -e 's,@MKLIVECDVER@,$(ARCHIVEVER),g' | \
		$(SED) -e 's,@KERNELVER@,$(KERNELVER),g' | \
		$(SED) -e 's,@MAX_SPLASH@,$(MAX_SPLASH),g' | \
		$(SED) -e 's,@VAL_SPLASH_FULL@,$(VAL_SPLASH_FULL),g' | \
		$(SED) -e 's,@VAL_SPLASH_LINUXRC@,$(VAL_SPLASH_LINUXRC),g' | \
		$(SED) -e 's,@VAL_SPLASH_SYSINIT@,$(VAL_SPLASH_SYSINIT),g' | \
		$(SED) -e 's,@VAL_SPLASH_HWDETECT@,$(VAL_SPLASH_HWDETECT),g' | \
		$(SED) -e 's,@DEF_MODULES_24@,$(DEF_MODULES_24),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_24@,$(DEF_MODULES_OPT_24),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_24@,$(DEF_MODULES_DEP_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_24@,$(DEF_SCSI_MODULES_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_24@,$(DEF_SCSI_MODULES_OPT_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_24@,$(DEF_SCSI_MODULES_DEP_24),g' | \
		$(SED) -e 's,@DEF_USB_24@,$(DEF_USB_24),g' | \
		$(SED) -e 's,@DEF_MODULES_26@,$(DEF_MODULES_26),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_26@,$(DEF_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_26@,$(DEF_MODULES_DEP_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_26@,$(DEF_SCSI_MODULES_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_26@,$(DEF_SCSI_MODULES_OPT_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_26@,$(DEF_SCSI_MODULES_DEP_26),g' | \
		$(SED) -e 's,@DEF_USB_26@,$(DEF_USB_26),g' | \
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
		$(SED) -e 's,@DEF_RESOLUTION@,$(DEF_RESOLUTION),g' | \
		$(SED) -e 's,@DEF_VGAMODE@,$(DEF_VGAMODE),g' | \
		$(SED) -e 's,@DEF_MODULES_PATH_24@,$(DEF_MODULES_PATH_24),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_PATH_24@,$(DEF_MODULES_OPT_PATH_24),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_PATH_24@,$(DEF_MODULES_DEP_PATH_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_PATH_24@,$(DEF_SCSI_MODULES_PATH_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_PATH_24@,$(DEF_SCSI_MODULES_OPT_PATH_24),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_PATH_24@,$(DEF_SCSI_MODULES_DEP_PATH_24),g' | \
		$(SED) -e 's,@DEF_USB_PATH_24@,$(DEF_USB_PATH_24),g' | \
		$(SED) -e 's,@DEF_MODULES_PATH_26@,$(DEF_MODULES_PATH_26),g' | \
		$(SED) -e 's,@DEF_MODULES_OPT_PATH_26@,$(DEF_MODULES_OPT_PATH_26),g' | \
		$(SED) -e 's,@DEF_MODULES_DEP_PATH_26@,$(DEF_MODULES_DEP_PATH_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_PATH_26@,$(DEF_SCSI_MODULES_PATH_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_OPT_PATH_26@,$(DEF_SCSI_MODULES_OPT_PATH_26),g' | \
		$(SED) -e 's,@DEF_SCSI_MODULES_DEP_PATH_26@,$(DEF_SCSI_MODULES_DEP_PATH_26),g' | \
		$(SED) -e 's,@DEF_USB_PATH_26@,$(DEF_USB_PATH_26),g' \
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

dist: spec
	$(MKDIR) -p $(MKLIVECDDIST)/$(SRCDIR)
	$(CP) $(DOCDIST) $(MKLIVECDDIST)
	$(CP) $(BUILDDIST) $(MKLIVECDDIST)
	$(CP) $(SRCDIST) $(MKLIVECDDIST)/$(SRCDIR)
	$(TAR) -c $(MKLIVECDDIST) | \
		$(BZIP2) >$(DISTDIR)/$(MKLIVECDDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(MKLIVECDDIST).tar.bz2 \
		>$(DISTDIR)/$(MKLIVECDDIST).tar.bz2.md5
	$(RM) -rf $(MKLIVECDDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(MKLIVECDDIST).tar.bz2
