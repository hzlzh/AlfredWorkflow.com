
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/universal-darwin12.0
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
prefix = $(DESTDIR)/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr
exec_prefix = $(prefix)
dvidir = $(docdir)
datadir = $(datarootdir)
localedir = $(datarootdir)/locale
psdir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
localstatedir = $(prefix)/var
infodir = $(DESTDIR)/usr/share/info
bindir = $(exec_prefix)/bin
htmldir = $(docdir)
libexecdir = $(exec_prefix)/libexec
rubylibdir = $(libdir)/ruby/$(ruby_version)
sitedir = $(DESTDIR)/Library/Ruby/Site
libdir = $(exec_prefix)/lib
pdfdir = $(docdir)
sysconfdir = $(prefix)/etc
datarootdir = $(prefix)/share
includedir = $(prefix)/include
docdir = $(datarootdir)/doc/$(PACKAGE)
sitearchdir = $(sitelibdir)/$(sitearch)
archdir = $(rubylibdir)/$(arch)
vendorlibdir = $(vendordir)/$(ruby_version)
sbindir = $(exec_prefix)/sbin
sitelibdir = $(sitedir)/$(ruby_version)
vendordir = $(libdir)/ruby/vendor_ruby
sharedstatedir = $(prefix)/com
mandir = $(DESTDIR)/usr/share/man
oldincludedir = $(DESTDIR)/usr/include

CC = xcrun cc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)

RUBY_EXTCONF_H = 
CFLAGS   =  -fno-common -arch i386 -arch x86_64 -g -Os -pipe -fno-common -DENABLE_DTRACE  -fno-common  -pipe -fno-common $(cflags) 
INCFLAGS = -I. -I$(topdir) -I$(hdrdir) -I$(srcdir)
DEFS     = 
CPPFLAGS =   -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE $(DEFS) $(cppflags) -DHAS_EXCEPTION_MAGIC=1 -DHAS_IVAR_HELPERS=0 -DRUBY_VERSION_MICRO=7 -DSAFE_CACHE=1 -DIS_WINDOWS=0 -DHAS_ENCODING_SUPPORT=0 -DHAS_RB_TIME_TIMESPEC=0 -DHAS_PROC_WITH_BLOCK=0 -DHAS_NANO_TIME=0 -DHAS_TOP_LEVEL_ST_H=1 -DRUBY_VERSION_MINOR=8 -DHAS_RSTRUCT=1 -DRUBY_VERSION=1.8.7 -DRUBY_RUBY -DRUBY_TYPE=ruby -DRUBY_VERSION_MAJOR=1 -Wall
CXXFLAGS = $(CFLAGS) 
ldflags  = -L. -arch i386 -arch x86_64 
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = cc -arch i386 -arch x86_64 -pipe -bundle -undefined dynamic_lookup
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = universal-darwin12.0
sitearch = universal-darwin12.0
ruby_version = 1.8
ruby = /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED)  -lpthread -ldl -lobjc  
SRCS = cache.c cache8.c dump.c fast.c load.c oj.c saj.c
OBJS = cache.o cache8.o dump.o fast.o load.o oj.o saj.o
TARGET = oj
DLLIB = $(TARGET).bundle
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /Users/bpinto/Documents/Bruno/Alfred/Alfred.alfredpreferences/workflows/hatmaker/workflow/bundle/ruby/1.8/gems/oj-2.0.10/lib$(target_prefix)
RUBYARCHDIR = /Users/bpinto/Documents/Bruno/Alfred/Alfred.alfredpreferences/workflows/hatmaker/workflow/bundle/ruby/1.8/gems/oj-2.0.10/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).bundle $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h
