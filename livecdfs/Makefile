# $Id: Makefile,v 1.8 2004/01/24 12:03:13 jaco Exp $

include Rules.mk

all: $(LIBRARY)

$(LIBRARY): $(OBJECTS) 
	$(CC) -shared -Wl,-soname \
	      -Wl,$(LIBRARY).$(MAJORVER).$(MINORVER) \
	      -o $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(OBJECTS)
	$(LN) -sf $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(LIBRARY).$(MAJORVER).$(MINORVER)
	$(LN) -sf $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(LIBRARY)

test: $(SRCDIR)/test.o $(OBJECTS) $(LUFSOBJS)  
	$(CXX) -o $@ $< $(OBJECTS) $(LUFSOBJS) 

install: $(LIBRARY)
	$(MKDIR) -p $(DESTDIR)/$(LIBDIR)
	$(CP) -a $(LIBRARY)* $(DESTDIR)/$(LIBDIR)
	
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
	$(RM) -rf $(SRCDIR)/*.o
	$(RM) -rf $(LIBRARY)* test
	$(FIND) $(LUFSDIR) -type f | $(GREP) .o$$ | $(XARGS) $(RM) -rf
	$(FIND) $(TOPDIR) -type f | $(GREP) ~$$ | $(XARGS) $(RM) -rf
	$(RM) -rf $(DISTDIR)
