# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{google_suggest}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tatsuya Sato"]
  s.date = %q{2012-01-17 00:00:00.000000000Z}
  s.email = %q{satoryu.1981@gmail.com}
  s.files = ["Gemfile", "Gemfile.lock", "LICENCE.txt", "Rakefile", "lib/google_suggest.rb", "spec/google_suggest_spec.rb", "spec/sample_ja.xml", "spec/sample_us.xml", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/satoryu/google_suggest/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A gem which allows us to retrieve suggest words from Google in your Ruby Code.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
