# $Id: Makefile,v 1.12 2004/01/31 07:45:42 jaco Exp $

include Rules.mk

all: $(LIBRARY) $(LUFSDLIVECDFS)

debug:
	$(MAKE) EXTRA_CXXFLAGS=-DDEBUG

$(LIBRARY): $(OBJECTS) 
	$(CC) -shared -Wl,-soname \
	      -Wl,$(LIBRARY).$(MAJORVER).$(MINORVER) \
	      -o $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(OBJECTS)
	$(STRIP) --strip-debug --strip-unneeded $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER)
	$(LN) -sf $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(LIBRARY).$(MAJORVER).$(MINORVER)
	$(LN) -sf $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(LIBRARY)

$(LUFSDLIVECDFS): $(OBJECTS) $(LUFSDOBJS)
	$(CXX) -static -o $@ $(OBJECTS) $(LUFSDOBJS) -lpthread 
	$(STRIP) --strip-debug --strip-unneeded $(LUFSDLIVECDFS)

test: $(SRCDIR)/test.o $(OBJECTS) $(LUFSOBJS)  
	$(CXX) -o $@ $< $(OBJECTS) $(LUFSOBJS) 

install: $(LIBRARY) $(LUFSDLIVECDFS)
	$(MKDIR) -p $(DESTDIR)$(LIBDIR) $(DESTDIR)$(SBINDIR)
	$(CP) -a $(LIBRARY)* $(DESTDIR)$(LIBDIR)
	$(INSTALL) -m 755 $(LUFSDLIVECDFS) $(DESTDIR)$(SBINDIR)
	
.cpp.o: $(INCLUDES)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

spec: clean
	$(MKDIR) -p $(DISTDIR)
	$(CAT) $(PKGNAME).spec.in | \
		$(SED) -e 's,@LIVECDFSVER@,$(LIVECDFSVER),g' | \
		$(SED) -e 's,@LIVECDFSREL@,$(LIVECDFSREL),g' | \
		$(SED) -e 's,@SPECDATE@,$(SPECDATE),g' | \
		$(SED) -e 's,@ARCHIVEVER@,$(ARCHIVEVER),g' \
			>$(DISTDIR)/$(PKGNAME).spec

dist: spec
	$(MKDIR) -p $(LIVECDFSDIST)/$(SRCDIR)
	$(CP) $(DOCDIST) $(LIVECDFSDIST)
	$(CP) $(BUILDDIST) $(LIVECDFSDIST)
	$(CP) $(SOURCES) $(LIVECDFSDIST)/$(SRCDIR)
	$(CP) $(INCLUDES) $(LIVECDFSDIST)/$(SRCDIR)
	$(CP) -a $(EXTDIST) $(LIVECDFSDIST)
	$(TAR) -c $(LIVECDFSDIST) | \
		$(BZIP2) >$(DISTDIR)/$(LIVECDFSDIST).tar.bz2
	$(MD5SUM) $(DISTDIR)/$(LIVECDFSDIST).tar.bz2 \
		>$(DISTDIR)/$(LIVECDFSDIST).tar.bz2.md5
	$(RM) -rf $(LIVECDFSDIST)

rpm: dist
	$(RPMBUILD) -ta $(DISTDIR)/$(LIVECDFSDIST).tar.bz2

clean:
	$(RM) -rf $(OBJECTS) $(LUFSOBJS) $(LUFSDOBJS) 
	$(RM) -rf $(LIBRARY)* test $(LUFSDLIVECDFS)
	$(FIND) $(LUFSDIR) -type f | $(GREP) .o$$ | $(XARGS) $(RM) -rf
	$(FIND) $(TOPDIR) -type f | $(GREP) ~$$ | $(XARGS) $(RM) -rf
	$(RM) -rf $(DISTDIR)
