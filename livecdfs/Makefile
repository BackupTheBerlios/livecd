# $Id: Makefile,v 1.1 2004/01/18 15:47:52 jaco Exp $

include Rules.mk

all: $(LIBRARY) test

$(LIBRARY): $(OBJECTS)
	$(CC) -shared -Wl,-soname -Wl,$(LIBRARY).0.0 -o $(LIBRARY) $(OBJECTS)

test: $(SRCDIR)/test.o $(OBJECTS) $(LUFSOBJS)  
	$(CXX) -o $@ $< $(OBJECTS) $(LUFSOBJS) 

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
	
clean:
	$(RM) -rf $(SRCDIR)/*.o
	$(RM) -rf $(LIBRARY)* test
	$(FIND) $(LUFSDIR) -type f | $(GREP) .o$$ | $(XARGS) $(RM) -rf
	$(FIND) $(TOPDIR) -type f | $(GREP) ~$$ | $(XARGS) $(RM) -rf
