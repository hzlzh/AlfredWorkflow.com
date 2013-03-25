
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/universal-darwin12.0
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr
mandir = $(DESTDIR)/usr/share/man
datarootdir = $(prefix)/share
vendorarchdir = $(vendorlibdir)/$(sitearch)
docdir = $(datarootdir)/doc/$(PACKAGE)
pdfdir = $(docdir)
bindir = $(exec_prefix)/bin
libexecdir = $(exec_prefix)/libexec
localstatedir = $(prefix)/var
datadir = $(datarootdir)
htmldir = $(docdir)
sitearchdir = $(sitelibdir)/$(sitearch)
archdir = $(rubylibdir)/$(arch)
libdir = $(exec_prefix)/lib
psdir = $(docdir)
rubylibdir = $(libdir)/ruby/$(ruby_version)
infodir = $(DESTDIR)/usr/share/info
sharedstatedir = $(prefix)/com
sitedir = $(DESTDIR)/Library/Ruby/Site
dvidir = $(docdir)
sysconfdir = $(prefix)/etc
localedir = $(datarootdir)/locale
oldincludedir = $(DESTDIR)/usr/include
vendordir = $(libdir)/ruby/vendor_ruby
includedir = $(prefix)/include
vendorlibdir = $(vendordir)/$(ruby_version)
sbindir = $(exec_prefix)/sbin
sitelibdir = $(sitedir)/$(ruby_version)

CC = xcrun cc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)

RUBY_EXTCONF_H = 
CFLAGS   =  -fno-common  -g -Os -pipe -fno-common -DENABLE_DTRACE  -fno-common  -pipe -fno-common $(cflags)  -g -DXP_UNIX 
INCFLAGS = -I. -I. -I/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/universal-darwin12.0 -I.
DEFS     = 
CPPFLAGS = -DHAVE_XMLHASFEATURE -DHAVE_XMLFIRSTELEMENTCHILD -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETPARSERSTRUCTUREDERRORS -I-I-I/opt/local/include -I-I-I/usr/local/include -I-I-I/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/include -I-I-I/usr/include -I-I-I/usr/include/libxml2 -I/usr/local/Cellar/libxml2/2.9.0/include/libxml2 -I/opt/local/include/libxml2 -I/usr/local/include/libxml2 -I/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/include/libxml2 -I-I/opt/local/include -I-I/usr/local/include -I-I/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/include -I-I/usr/include -I-I/usr/include/libxml2 -I/opt/local/include -I/usr/local/include -I/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/include -I/usr/include -I/usr/include/libxml2  -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE  
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = cc  -pipe -bundle -undefined dynamic_lookup
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

libpath = . $(libdir) /usr/local/Cellar/libxml2/2.9.0/lib /opt/local/lib /usr/local/lib /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib /usr/lib
LIBPATH =  -L. -L$(libdir) -L/usr/local/Cellar/libxml2/2.9.0/lib -L/opt/local/lib -L/usr/local/lib -L/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib -L/usr/lib
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = /nokogiri
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) -lexslt -lxslt -lxml2 -liconv  -lpthread -ldl -lobjc   
SRCS = html_document.c html_element_description.c html_entity_lookup.c html_sax_parser_context.c html_sax_push_parser.c nokogiri.c xml_attr.c xml_attribute_decl.c xml_cdata.c xml_comment.c xml_document.c xml_document_fragment.c xml_dtd.c xml_element_content.c xml_element_decl.c xml_encoding_handler.c xml_entity_decl.c xml_entity_reference.c xml_io.c xml_libxml2_hacks.c xml_namespace.c xml_node.c xml_node_set.c xml_processing_instruction.c xml_reader.c xml_relax_ng.c xml_sax_parser.c xml_sax_parser_context.c xml_sax_push_parser.c xml_schema.c xml_syntax_error.c xml_text.c xml_xpath_context.c xslt_stylesheet.c
OBJS = html_document.o html_element_description.o html_entity_lookup.o html_sax_parser_context.o html_sax_push_parser.o nokogiri.o xml_attr.o xml_attribute_decl.o xml_cdata.o xml_comment.o xml_document.o xml_document_fragment.o xml_dtd.o xml_element_content.o xml_element_decl.o xml_encoding_handler.o xml_entity_decl.o xml_entity_reference.o xml_io.o xml_libxml2_hacks.o xml_namespace.o xml_node.o xml_node_set.o xml_processing_instruction.o xml_reader.o xml_relax_ng.o xml_sax_parser.o xml_sax_parser_context.o xml_sax_push_parser.o xml_schema.o xml_syntax_error.o xml_text.o xml_xpath_context.o xslt_stylesheet.o
TARGET = nokogiri
DLLIB = $(TARGET).bundle
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /Users/zhaocai/Developer/Productivity/Alfred/Project/GoogleSuggest/google-suggest/bundle/ruby/1.8/gems/nokogiri-1.5.7/lib$(target_prefix)
RUBYARCHDIR = /Users/zhaocai/Developer/Productivity/Alfred/Project/GoogleSuggest/google-suggest/bundle/ruby/1.8/gems/nokogiri-1.5.7/lib$(target_prefix)

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



###
html_document.o: html_document.c html_document.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

html_element_description.o: html_element_description.c			\
 html_element_description.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
 xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
 xml_syntax_error.h xml_schema.h xml_relax_ng.h xml_namespace.h		\
 xml_encoding_handler.h

html_entity_lookup.o: html_entity_lookup.c html_entity_lookup.h		\
  nokogiri.h xml_io.h xml_document.h html_document.h xml_node.h		\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

html_sax_parser_context.o: html_sax_parser_context.c			\
 html_sax_parser_context.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
 xml_reader.h xslt_stylesheet.h xml_syntax_error.h xml_schema.h		\
 xml_relax_ng.h html_element_description.h xml_namespace.h		\
 xml_encoding_handler.h

nokogiri.o: nokogiri.c nokogiri.h xml_io.h xml_document.h		\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_attr.o: xml_attr.c xml_attr.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_attribute_decl.o: xml_attribute_decl.c xml_attribute_decl.h		\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_element_decl.h xml_entity_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_cdata.o: xml_cdata.c xml_cdata.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_comment.o: xml_comment.c xml_comment.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_node_set.h		\
  xml_dtd.h xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h	\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_document.o: xml_document.c xml_document.h nokogiri.h xml_io.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_document_fragment.o: xml_document_fragment.c			\
  xml_document_fragment.h nokogiri.h xml_io.h xml_document.h		\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_comment.h xml_node_set.h xml_dtd.h		\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_dtd.o: xml_dtd.c xml_dtd.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_attribute_decl.h xml_element_decl.h		\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_element_content.o: xml_element_content.c xml_element_content.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_sax_parser_context.h xml_sax_parser.h		\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_element_decl.o: xml_element_decl.c xml_element_decl.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_entity_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_encoding_handler.o: xml_encoding_handler.c xml_encoding_handler.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h

xml_entity_decl.o: xml_entity_decl.c xml_entity_decl.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_entity_reference.o: xml_entity_reference.c xml_entity_reference.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_document_fragment.h xml_comment.h	\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_io.o: xml_io.c xml_io.h nokogiri.h xml_document.h			\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_namespace.o: xml_namespace.c xml_namespace.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_encoding_handler.h

xml_node.o: xml_node.c xml_node.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_text.h xml_cdata.h		\
  xml_attr.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_node_set.o: xml_node_set.c xml_node_set.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_dtd.h xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h	\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_processing_instruction.o: xml_processing_instruction.c		\
 xml_processing_instruction.h nokogiri.h xml_io.h xml_document.h	\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_entity_reference.h xml_document_fragment.h	\
 xml_comment.h xml_node_set.h xml_dtd.h xml_attribute_decl.h		\
 xml_element_decl.h xml_entity_decl.h xml_xpath_context.h		\
 xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
 xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
 xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
 html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_reader.o: xml_reader.c xml_reader.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_relax_ng.o: xml_relax_ng.c xml_relax_ng.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_sax_parser.o: xml_sax_parser.c xml_sax_parser.h nokogiri.h		\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_sax_parser_context.o: xml_sax_parser_context.c			\
 xml_sax_parser_context.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
 html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h		\
 xml_schema.h xml_relax_ng.h html_element_description.h			\
 xml_namespace.h xml_encoding_handler.h

xml_sax_push_parser.o: xml_sax_push_parser.c xml_sax_push_parser.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_schema.o: xml_schema.c xml_schema.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_syntax_error.o: xml_syntax_error.c xml_syntax_error.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_schema.h		\
  xml_relax_ng.h html_element_description.h xml_namespace.h		\
  xml_encoding_handler.h

xml_text.o: xml_text.c xml_text.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_cdata.h		\
  xml_attr.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_xpath_context.o: xml_xpath_context.c xml_xpath_context.h		\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xslt_stylesheet.o: xslt_stylesheet.c xslt_stylesheet.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xml_syntax_error.h xml_schema.h		\
  xml_relax_ng.h html_element_description.h xml_namespace.h		\
  xml_encoding_handler.h
