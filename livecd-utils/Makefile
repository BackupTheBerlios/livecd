# $Id: Makefile,v 1.4 2003/11/30 16:35:24 jaco Exp $

include Rules.mk

all: livecd-install

version:
	@echo "$(PKGNAME), $(UTILSVER)-$(UTILSREL)"

livecd-install:
	$(MKDIR) -p $(DISTDIR)
	(cd $(SRCDIR) && $(PUIC) -x -o livecd-install.pl.in livecd-install.ui)
	echo '#!/usr/bin/perl' >$(DISTDIR)/livecd-install
	$(CAT) $(SRCDIR)/livecd-install.pl.in >>$(DISTDIR)/livecd-install

install:
	$(MKDIR) -p $(DESTDIR)$(SBINDIR)
	$(INSTALL) -m 755 $(DISTDIR)/livecd-install $(DESTDIR)$(SBINDIR)

spec:
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(PKGNAME).spec.in | \
		$(SED) -e 's,@UTILSVER@,$(UTILSVER),g' | \
		$(SED) -e 's,@UTILSREL@,$(UTILSREL),g' | \
		$(SED) -e 's,@SPECDATE@,$(SPECDATE),g' | \
		$(SED) -e 's,@ARCHIVEVER@,$(ARCHIVEVER),g' \
			>$(DISTDIR)/$(PKGNAME).spec

clean:
	$(RM) -rf $(UTILSDIST)
	$(RM) -rf $(DISTDIR)
	$(RM) -rf $(SRCDIR)/*.pl.in

dist: spec
	$(MKDIR) -p $(UTILSDIST)/$(SRCDIR)
	$(CP) $(DOCDIST) $(UTILSDIST)
	$(CP) $(SRCDIST) $(UTILSDIST)/$(SRCDIR)
	$(CP) $(SRCDIST) $(UTILSDIST)/$(SRCDIR)
	$(CP) $(SRCDIST) $(UTILSDIST)/$(SRCDIR)
	$(TAR) -c $(UTILSDIST) | \
		$(BZIP2) >$(DISTDIR)/$(UTILSDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(UTILSDIST).tar.bz2 \
		>$(DISTDIR)/$(UTILSDIST).tar.bz2.md5
	$(RM) -rf $(UTILSDIST)
	cd $(ICONDIR) && $(TAR) -c *.png | \
		$(BZIP2) >../$(DISTDIR)/$(ICONSDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(ICONSDIST).tar.bz2 \
		>$(DISTDIR)/$(ICONSDIST).tar.bz2.md5

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(UTILSDIST).tar.bz2
