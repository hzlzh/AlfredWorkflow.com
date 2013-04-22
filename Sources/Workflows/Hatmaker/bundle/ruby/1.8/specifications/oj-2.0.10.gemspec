# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oj}
  s.version = "2.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Ohler"]
  s.date = %q{2013-03-10}
  s.description = %q{The fastest JSON parser and object serializer. }
  s.email = %q{peter@ohler.com}
  s.extensions = ["ext/oj/extconf.rb"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["lib/oj/bag.rb", "lib/oj/error.rb", "lib/oj/mimic.rb", "lib/oj/saj.rb", "lib/oj/version.rb", "lib/oj.rb", "ext/oj/extconf.rb", "ext/oj/foo.rb", "ext/oj/cache.h", "ext/oj/cache8.h", "ext/oj/oj.h", "ext/oj/cache.c", "ext/oj/cache8.c", "ext/oj/dump.c", "ext/oj/fast.c", "ext/oj/load.c", "ext/oj/oj.c", "ext/oj/saj.c", "test/a.rb", "test/bug.rb", "test/files.rb", "test/mj.rb", "test/perf.rb", "test/perf1.rb", "test/perf2.rb", "test/perf_fast.rb", "test/perf_obj.rb", "test/perf_obj_old.rb", "test/perf_saj.rb", "test/perf_simple.rb", "test/perf_strict.rb", "test/sample/change.rb", "test/sample/dir.rb", "test/sample/doc.rb", "test/sample/file.rb", "test/sample/group.rb", "test/sample/hasprops.rb", "test/sample/layer.rb", "test/sample/line.rb", "test/sample/oval.rb", "test/sample/rect.rb", "test/sample/shape.rb", "test/sample/text.rb", "test/sample.rb", "test/sample_json.rb", "test/test_fast.rb", "test/test_mimic.rb", "test/test_saj.rb", "test/tests.rb", "LICENSE", "README.md"]
  s.homepage = %q{http://www.ohler.com/oj}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{oj}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A fast JSON parser and serializer.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
