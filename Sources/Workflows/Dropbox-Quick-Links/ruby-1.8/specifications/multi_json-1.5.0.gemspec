# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multi_json}
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Josh Kalderimis", "Erik Michaels-Ober"]
  s.date = %q{2012-12-10}
  s.description = %q{A gem to provide easy switching between different JSON backends, including Oj, Yajl, the JSON gem (with C-extensions), the pure-Ruby JSON gem, and OkJson.}
  s.email = ["michael@intridea.com", "josh.kalderimis@gmail.com", "sferik@gmail.com"]
  s.extra_rdoc_files = ["LICENSE.md", "README.md"]
  s.files = ["LICENSE.md", "README.md", "Rakefile", "multi_json.gemspec", "Gemfile", ".document", ".rspec", ".travis.yml", "spec/adapter_shared_example.rb", "spec/helper.rb", "spec/multi_json_spec.rb", "lib/multi_json/adapters/json_common.rb", "lib/multi_json/adapters/json_gem.rb", "lib/multi_json/adapters/json_pure.rb", "lib/multi_json/adapters/nsjsonserialization.rb", "lib/multi_json/adapters/oj.rb", "lib/multi_json/adapters/ok_json.rb", "lib/multi_json/adapters/yajl.rb", "lib/multi_json/vendor/okjson.rb", "lib/multi_json/version.rb", "lib/multi_json.rb"]
  s.homepage = %q{http://github.com/intridea/multi_json}
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A gem to provide swappable JSON backends.}
  s.test_files = ["spec/adapter_shared_example.rb", "spec/helper.rb", "spec/multi_json_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.9"])
      s.add_development_dependency(%q<rdoc>, [">= 3.9"])
      s.add_development_dependency(%q<rspec>, [">= 2.6"])
      s.add_development_dependency(%q<simplecov>, [">= 0.4"])
    else
      s.add_dependency(%q<rake>, [">= 0.9"])
      s.add_dependency(%q<rdoc>, [">= 3.9"])
      s.add_dependency(%q<rspec>, [">= 2.6"])
      s.add_dependency(%q<simplecov>, [">= 0.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.9"])
    s.add_dependency(%q<rdoc>, [">= 3.9"])
    s.add_dependency(%q<rspec>, [">= 2.6"])
    s.add_dependency(%q<simplecov>, [">= 0.4"])
  end
end
