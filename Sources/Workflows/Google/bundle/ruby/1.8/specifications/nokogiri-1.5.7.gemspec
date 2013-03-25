# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nokogiri}
  s.version = "1.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson", "Mike Dalessio", "Yoko Harada", "Tim Elliott"]
  s.date = %q{2013-03-18}
  s.default_executable = %q{nokogiri}
  s.description = %q{Nokogiri (鋸) is an HTML, XML, SAX, and Reader parser.  Among Nokogiri's
many features is the ability to search documents via XPath or CSS3 selectors.

XML is like violence - if it doesn’t solve your problems, you are not using
enough of it.}
  s.email = ["aaronp@rubyforge.org", "mike.dalessio@gmail.com", "yokolet@gmail.com", "tle@holymonkey.com"]
  s.executables = ["nokogiri"]
  s.extensions = ["ext/nokogiri/extconf.rb"]
  s.extra_rdoc_files = ["CHANGELOG.ja.rdoc", "CHANGELOG.rdoc", "C_CODING_STYLE.rdoc", "Manifest.txt", "README.ja.rdoc", "README.rdoc", "ext/nokogiri/html_document.c", "ext/nokogiri/html_element_description.c", "ext/nokogiri/html_entity_lookup.c", "ext/nokogiri/html_sax_parser_context.c", "ext/nokogiri/html_sax_push_parser.c", "ext/nokogiri/nokogiri.c", "ext/nokogiri/xml_attr.c", "ext/nokogiri/xml_attribute_decl.c", "ext/nokogiri/xml_cdata.c", "ext/nokogiri/xml_comment.c", "ext/nokogiri/xml_document.c", "ext/nokogiri/xml_document_fragment.c", "ext/nokogiri/xml_dtd.c", "ext/nokogiri/xml_element_content.c", "ext/nokogiri/xml_element_decl.c", "ext/nokogiri/xml_encoding_handler.c", "ext/nokogiri/xml_entity_decl.c", "ext/nokogiri/xml_entity_reference.c", "ext/nokogiri/xml_io.c", "ext/nokogiri/xml_libxml2_hacks.c", "ext/nokogiri/xml_namespace.c", "ext/nokogiri/xml_node.c", "ext/nokogiri/xml_node_set.c", "ext/nokogiri/xml_processing_instruction.c", "ext/nokogiri/xml_reader.c", "ext/nokogiri/xml_relax_ng.c", "ext/nokogiri/xml_sax_parser.c", "ext/nokogiri/xml_sax_parser_context.c", "ext/nokogiri/xml_sax_push_parser.c", "ext/nokogiri/xml_schema.c", "ext/nokogiri/xml_syntax_error.c", "ext/nokogiri/xml_text.c", "ext/nokogiri/xml_xpath_context.c", "ext/nokogiri/xslt_stylesheet.c"]
  s.files = [".autotest", ".gemtest", "CHANGELOG.ja.rdoc", "CHANGELOG.rdoc", "C_CODING_STYLE.rdoc", "Manifest.txt", "README.ja.rdoc", "README.rdoc", "ROADMAP.md", "Rakefile", "STANDARD_RESPONSES.md", "Y_U_NO_GEMSPEC.md", "bin/nokogiri", "build_all", "ext/nokogiri/depend", "ext/nokogiri/extconf.rb", "ext/nokogiri/html_document.c", "ext/nokogiri/html_document.h", "ext/nokogiri/html_element_description.c", "ext/nokogiri/html_element_description.h", "ext/nokogiri/html_entity_lookup.c", "ext/nokogiri/html_entity_lookup.h", "ext/nokogiri/html_sax_parser_context.c", "ext/nokogiri/html_sax_parser_context.h", "ext/nokogiri/html_sax_push_parser.c", "ext/nokogiri/html_sax_push_parser.h", "ext/nokogiri/nokogiri.c", "ext/nokogiri/nokogiri.h", "ext/nokogiri/xml_attr.c", "ext/nokogiri/xml_attr.h", "ext/nokogiri/xml_attribute_decl.c", "ext/nokogiri/xml_attribute_decl.h", "ext/nokogiri/xml_cdata.c", "ext/nokogiri/xml_cdata.h", "ext/nokogiri/xml_comment.c", "ext/nokogiri/xml_comment.h", "ext/nokogiri/xml_document.c", "ext/nokogiri/xml_document.h", "ext/nokogiri/xml_document_fragment.c", "ext/nokogiri/xml_document_fragment.h", "ext/nokogiri/xml_dtd.c", "ext/nokogiri/xml_dtd.h", "ext/nokogiri/xml_element_content.c", "ext/nokogiri/xml_element_content.h", "ext/nokogiri/xml_element_decl.c", "ext/nokogiri/xml_element_decl.h", "ext/nokogiri/xml_encoding_handler.c", "ext/nokogiri/xml_encoding_handler.h", "ext/nokogiri/xml_entity_decl.c", "ext/nokogiri/xml_entity_decl.h", "ext/nokogiri/xml_entity_reference.c", "ext/nokogiri/xml_entity_reference.h", "ext/nokogiri/xml_io.c", "ext/nokogiri/xml_io.h", "ext/nokogiri/xml_libxml2_hacks.c", "ext/nokogiri/xml_libxml2_hacks.h", "ext/nokogiri/xml_namespace.c", "ext/nokogiri/xml_namespace.h", "ext/nokogiri/xml_node.c", "ext/nokogiri/xml_node.h", "ext/nokogiri/xml_node_set.c", "ext/nokogiri/xml_node_set.h", "ext/nokogiri/xml_processing_instruction.c", "ext/nokogiri/xml_processing_instruction.h", "ext/nokogiri/xml_reader.c", "ext/nokogiri/xml_reader.h", "ext/nokogiri/xml_relax_ng.c", "ext/nokogiri/xml_relax_ng.h", "ext/nokogiri/xml_sax_parser.c", "ext/nokogiri/xml_sax_parser.h", "ext/nokogiri/xml_sax_parser_context.c", "ext/nokogiri/xml_sax_parser_context.h", "ext/nokogiri/xml_sax_push_parser.c", "ext/nokogiri/xml_sax_push_parser.h", "ext/nokogiri/xml_schema.c", "ext/nokogiri/xml_schema.h", "ext/nokogiri/xml_syntax_error.c", "ext/nokogiri/xml_syntax_error.h", "ext/nokogiri/xml_text.c", "ext/nokogiri/xml_text.h", "ext/nokogiri/xml_xpath_context.c", "ext/nokogiri/xml_xpath_context.h", "ext/nokogiri/xslt_stylesheet.c", "ext/nokogiri/xslt_stylesheet.h", "lib/nokogiri.rb", "lib/nokogiri/css.rb", "lib/nokogiri/css/node.rb", "lib/nokogiri/css/parser.rb", "lib/nokogiri/css/parser.y", "lib/nokogiri/css/parser_extras.rb", "lib/nokogiri/css/syntax_error.rb", "lib/nokogiri/css/tokenizer.rb", "lib/nokogiri/css/tokenizer.rex", "lib/nokogiri/css/xpath_visitor.rb", "lib/nokogiri/decorators/slop.rb", "lib/nokogiri/html.rb", "lib/nokogiri/html/builder.rb", "lib/nokogiri/html/document.rb", "lib/nokogiri/html/document_fragment.rb", "lib/nokogiri/html/element_description.rb", "lib/nokogiri/html/element_description_defaults.rb", "lib/nokogiri/html/entity_lookup.rb", "lib/nokogiri/html/sax/parser.rb", "lib/nokogiri/html/sax/parser_context.rb", "lib/nokogiri/html/sax/push_parser.rb", "lib/nokogiri/syntax_error.rb", "lib/nokogiri/version.rb", "lib/nokogiri/xml.rb", "lib/nokogiri/xml/attr.rb", "lib/nokogiri/xml/attribute_decl.rb", "lib/nokogiri/xml/builder.rb", "lib/nokogiri/xml/cdata.rb", "lib/nokogiri/xml/character_data.rb", "lib/nokogiri/xml/document.rb", "lib/nokogiri/xml/document_fragment.rb", "lib/nokogiri/xml/dtd.rb", "lib/nokogiri/xml/element_content.rb", "lib/nokogiri/xml/element_decl.rb", "lib/nokogiri/xml/entity_decl.rb", "lib/nokogiri/xml/namespace.rb", "lib/nokogiri/xml/node.rb", "lib/nokogiri/xml/node/save_options.rb", "lib/nokogiri/xml/node_set.rb", "lib/nokogiri/xml/notation.rb", "lib/nokogiri/xml/parse_options.rb", "lib/nokogiri/xml/pp.rb", "lib/nokogiri/xml/pp/character_data.rb", "lib/nokogiri/xml/pp/node.rb", "lib/nokogiri/xml/processing_instruction.rb", "lib/nokogiri/xml/reader.rb", "lib/nokogiri/xml/relax_ng.rb", "lib/nokogiri/xml/sax.rb", "lib/nokogiri/xml/sax/document.rb", "lib/nokogiri/xml/sax/parser.rb", "lib/nokogiri/xml/sax/parser_context.rb", "lib/nokogiri/xml/sax/push_parser.rb", "lib/nokogiri/xml/schema.rb", "lib/nokogiri/xml/syntax_error.rb", "lib/nokogiri/xml/text.rb", "lib/nokogiri/xml/xpath.rb", "lib/nokogiri/xml/xpath/syntax_error.rb", "lib/nokogiri/xml/xpath_context.rb", "lib/nokogiri/xslt.rb", "lib/nokogiri/xslt/stylesheet.rb", "lib/xsd/xmlparser/nokogiri.rb", "tasks/cross_compile.rb", "tasks/nokogiri.org.rb", "tasks/test.rb", "test/css/test_nthiness.rb", "test/css/test_parser.rb", "test/css/test_tokenizer.rb", "test/css/test_xpath_visitor.rb", "test/decorators/test_slop.rb", "test/files/2ch.html", "test/files/address_book.rlx", "test/files/address_book.xml", "test/files/bar/bar.xsd", "test/files/dont_hurt_em_why.xml", "test/files/encoding.html", "test/files/encoding.xhtml", "test/files/exslt.xml", "test/files/exslt.xslt", "test/files/foo/foo.xsd", "test/files/metacharset.html", "test/files/noencoding.html", "test/files/po.xml", "test/files/po.xsd", "test/files/shift_jis.html", "test/files/shift_jis.xml", "test/files/snuggles.xml", "test/files/staff.dtd", "test/files/staff.xml", "test/files/staff.xslt", "test/files/test_document_url/bar.xml", "test/files/test_document_url/document.dtd", "test/files/test_document_url/document.xml", "test/files/tlm.html", "test/files/to_be_xincluded.xml", "test/files/valid_bar.xml", "test/files/xinclude.xml", "test/helper.rb", "test/html/sax/test_parser.rb", "test/html/sax/test_parser_context.rb", "test/html/test_builder.rb", "test/html/test_document.rb", "test/html/test_document_encoding.rb", "test/html/test_document_fragment.rb", "test/html/test_element_description.rb", "test/html/test_named_characters.rb", "test/html/test_node.rb", "test/html/test_node_encoding.rb", "test/test_convert_xpath.rb", "test/test_css_cache.rb", "test/test_encoding_handler.rb", "test/test_memory_leak.rb", "test/test_nokogiri.rb", "test/test_reader.rb", "test/test_soap4r_sax.rb", "test/test_xslt_transforms.rb", "test/xml/node/test_save_options.rb", "test/xml/node/test_subclass.rb", "test/xml/sax/test_parser.rb", "test/xml/sax/test_parser_context.rb", "test/xml/sax/test_push_parser.rb", "test/xml/test_attr.rb", "test/xml/test_attribute_decl.rb", "test/xml/test_builder.rb", "test/xml/test_c14n.rb", "test/xml/test_cdata.rb", "test/xml/test_comment.rb", "test/xml/test_document.rb", "test/xml/test_document_encoding.rb", "test/xml/test_document_fragment.rb", "test/xml/test_dtd.rb", "test/xml/test_dtd_encoding.rb", "test/xml/test_element_content.rb", "test/xml/test_element_decl.rb", "test/xml/test_entity_decl.rb", "test/xml/test_entity_reference.rb", "test/xml/test_namespace.rb", "test/xml/test_node.rb", "test/xml/test_node_attributes.rb", "test/xml/test_node_encoding.rb", "test/xml/test_node_inheritance.rb", "test/xml/test_node_reparenting.rb", "test/xml/test_node_set.rb", "test/xml/test_parse_options.rb", "test/xml/test_processing_instruction.rb", "test/xml/test_reader_encoding.rb", "test/xml/test_relax_ng.rb", "test/xml/test_schema.rb", "test/xml/test_syntax_error.rb", "test/xml/test_text.rb", "test/xml/test_unparented_node.rb", "test/xml/test_xinclude.rb", "test/xml/test_xpath.rb", "test/xslt/test_custom_functions.rb", "test/xslt/test_exception_handling.rb", "test_all", "test/namespaces/test_namespaces_in_builder_doc.rb", "test/namespaces/test_namespaces_in_created_doc.rb", "test/namespaces/test_namespaces_in_parsed_doc.rb"]
  s.homepage = %q{http://nokogiri.org}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{nokogiri}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Nokogiri (鋸) is an HTML, XML, SAX, and Reader parser}
  s.test_files = ["test/decorators/test_slop.rb", "test/test_encoding_handler.rb", "test/css/test_parser.rb", "test/css/test_nthiness.rb", "test/css/test_tokenizer.rb", "test/css/test_xpath_visitor.rb", "test/xslt/test_exception_handling.rb", "test/xslt/test_custom_functions.rb", "test/test_reader.rb", "test/xml/test_comment.rb", "test/xml/test_unparented_node.rb", "test/xml/test_processing_instruction.rb", "test/xml/test_node_attributes.rb", "test/xml/test_xpath.rb", "test/xml/test_node_encoding.rb", "test/xml/test_element_decl.rb", "test/xml/test_entity_decl.rb", "test/xml/test_namespace.rb", "test/xml/test_cdata.rb", "test/xml/test_node_inheritance.rb", "test/xml/test_entity_reference.rb", "test/xml/test_text.rb", "test/xml/test_reader_encoding.rb", "test/xml/test_dtd.rb", "test/xml/test_xinclude.rb", "test/xml/test_parse_options.rb", "test/xml/test_schema.rb", "test/xml/test_element_content.rb", "test/xml/test_document.rb", "test/xml/test_relax_ng.rb", "test/xml/test_c14n.rb", "test/xml/test_dtd_encoding.rb", "test/xml/test_syntax_error.rb", "test/xml/test_attribute_decl.rb", "test/xml/test_node_set.rb", "test/xml/test_builder.rb", "test/xml/sax/test_parser.rb", "test/xml/sax/test_push_parser.rb", "test/xml/sax/test_parser_context.rb", "test/xml/test_document_encoding.rb", "test/xml/test_attr.rb", "test/xml/test_document_fragment.rb", "test/xml/test_node.rb", "test/xml/test_node_reparenting.rb", "test/xml/node/test_save_options.rb", "test/xml/node/test_subclass.rb", "test/test_css_cache.rb", "test/test_soap4r_sax.rb", "test/html/test_node_encoding.rb", "test/html/test_document.rb", "test/html/test_named_characters.rb", "test/html/test_builder.rb", "test/html/sax/test_parser.rb", "test/html/sax/test_parser_context.rb", "test/html/test_document_encoding.rb", "test/html/test_element_description.rb", "test/html/test_document_fragment.rb", "test/html/test_node.rb", "test/test_memory_leak.rb", "test/test_convert_xpath.rb", "test/namespaces/test_namespaces_in_builder_doc.rb", "test/namespaces/test_namespaces_in_created_doc.rb", "test/namespaces/test_namespaces_in_parsed_doc.rb", "test/test_xslt_transforms.rb", "test/test_nokogiri.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-bundler>, [">= 1.1"])
      s.add_development_dependency(%q<hoe-debugging>, [">= 1.0.3"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 1.0"])
      s.add_development_dependency(%q<hoe-git>, [">= 1.4"])
      s.add_development_dependency(%q<mini_portile>, [">= 0.2.2"])
      s.add_development_dependency(%q<minitest>, ["~> 2.2.2"])
      s.add_development_dependency(%q<rake>, [">= 0.9"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.8.0"])
      s.add_development_dependency(%q<racc>, [">= 1.4.6"])
      s.add_development_dependency(%q<rexical>, [">= 1.0.5"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 2.16"])
    else
      s.add_dependency(%q<hoe-bundler>, [">= 1.1"])
      s.add_dependency(%q<hoe-debugging>, [">= 1.0.3"])
      s.add_dependency(%q<hoe-gemspec>, [">= 1.0"])
      s.add_dependency(%q<hoe-git>, [">= 1.4"])
      s.add_dependency(%q<mini_portile>, [">= 0.2.2"])
      s.add_dependency(%q<minitest>, ["~> 2.2.2"])
      s.add_dependency(%q<rake>, [">= 0.9"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.8.0"])
      s.add_dependency(%q<racc>, [">= 1.4.6"])
      s.add_dependency(%q<rexical>, [">= 1.0.5"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 2.16"])
    end
  else
    s.add_dependency(%q<hoe-bundler>, [">= 1.1"])
    s.add_dependency(%q<hoe-debugging>, [">= 1.0.3"])
    s.add_dependency(%q<hoe-gemspec>, [">= 1.0"])
    s.add_dependency(%q<hoe-git>, [">= 1.4"])
    s.add_dependency(%q<mini_portile>, [">= 0.2.2"])
    s.add_dependency(%q<minitest>, ["~> 2.2.2"])
    s.add_dependency(%q<rake>, [">= 0.9"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.8.0"])
    s.add_dependency(%q<racc>, [">= 1.4.6"])
    s.add_dependency(%q<rexical>, [">= 1.0.5"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 2.16"])
  end
end
