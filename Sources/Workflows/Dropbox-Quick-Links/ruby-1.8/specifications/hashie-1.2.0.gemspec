# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hashie}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2011-10-15 00:00:00.000000000Z}
  s.description = %q{Hashie is a small collection of tools that make hashes more powerful. Currently includes Mash (Mocking Hash) and Dash (Discrete Hash).}
  s.email = ["michael@intridea.com"]
  s.files = [".document", ".gitignore", ".rspec", ".travis.yml", "Gemfile", "Gemfile.lock", "Guardfile", "LICENSE", "README.rdoc", "Rakefile", "hashie.gemspec", "lib/hashie.rb", "lib/hashie/clash.rb", "lib/hashie/dash.rb", "lib/hashie/hash.rb", "lib/hashie/hash_extensions.rb", "lib/hashie/mash.rb", "lib/hashie/trash.rb", "lib/hashie/version.rb", "spec/hashie/clash_spec.rb", "spec/hashie/dash_spec.rb", "spec/hashie/hash_spec.rb", "spec/hashie/mash_spec.rb", "spec/hashie/trash_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{https://github.com/intridea/hashie}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Your friendly neighborhood hash toolkit.}
  s.test_files = ["spec/hashie/clash_spec.rb", "spec/hashie/dash_spec.rb", "spec/hashie/hash_spec.rb", "spec/hashie/mash_spec.rb", "spec/hashie/trash_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<rspec>, ["~> 2.5"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<rspec>, ["~> 2.5"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
  end
end
