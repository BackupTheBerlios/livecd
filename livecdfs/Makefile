# $Id: Makefile,v 1.7 2004/01/24 10:25:06 jaco Exp $

include Rules.mk

all: $(LIBRARY)

$(LIBRARY): $(OBJECTS) 
	$(CC) -shared -Wl,-soname \
	      -Wl,$(LIBRARY).$(MINORVER).$(PATCHVER) \
	      -o $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(OBJECTS)
	$(LN) -sf $(LIBRARY).$(MAJORVER).$(MINORVER).$(PATCHVER) $(LIBRARY).$(MINORVER).$(PATCHVER)
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
	
clean:
	$(RM) -rf $(SRCDIR)/*.o
	$(RM) -rf $(LIBRARY)* test
	$(FIND) $(LUFSDIR) -type f | $(GREP) .o$$ | $(XARGS) $(RM) -rf
	$(FIND) $(TOPDIR) -type f | $(GREP) ~$$ | $(XARGS) $(RM) -rf
