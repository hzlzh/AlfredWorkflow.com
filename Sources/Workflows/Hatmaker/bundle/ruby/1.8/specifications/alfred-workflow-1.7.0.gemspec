# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alfred-workflow}
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhao Cai"]
  s.date = %q{2013-04-06}
  s.description = %q{alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.}
  s.email = ["caizhaoff@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".gemtest", ".rspec", ".ruby-version", ".travis.yml", "Gemfile", "Gemfile.lock", "Guardfile", "History.txt", "Manifest.txt", "README.md", "Rakefile", "lib/alfred.rb", "lib/alfred/feedback.rb", "lib/alfred/feedback/file_item.rb", "lib/alfred/feedback/item.rb", "lib/alfred/setting.rb", "lib/alfred/ui.rb", "lib/alfred/version.rb", "spec/alfred_spec.rb", "spec/feedback_spec.rb", "spec/item_spec.rb", "spec/spec_helper.rb", "test/workflow/info.plist"]
  s.homepage = %q{http://zhaocai.github.com/alfred2-ruby-template/}
  s.licenses = ["GPL-3"]
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{alfred-workflow}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<plist>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<logging>, [">= 1.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<rspec>, [">= 2.13"])
      s.add_development_dependency(%q<rake>, [">= 10.0.0"])
      s.add_development_dependency(%q<hoe>, [">= 0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_development_dependency(%q<hoe-git>, [">= 0"])
      s.add_development_dependency(%q<hoe-version>, [">= 0"])
      s.add_development_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_development_dependency(%q<guard>, ["~> 1.7.0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-bundler>, [">= 0"])
      s.add_development_dependency(%q<terminal-notifier-guard>, [">= 0"])
      s.add_development_dependency(%q<growl>, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>, ["~> 0.9"])
    else
      s.add_dependency(%q<plist>, [">= 3.1.0"])
      s.add_dependency(%q<logging>, [">= 1.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<rspec>, [">= 2.13"])
      s.add_dependency(%q<rake>, [">= 10.0.0"])
      s.add_dependency(%q<hoe>, [">= 0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_dependency(%q<hoe-git>, [">= 0"])
      s.add_dependency(%q<hoe-version>, [">= 0"])
      s.add_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_dependency(%q<guard>, ["~> 1.7.0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-bundler>, [">= 0"])
      s.add_dependency(%q<terminal-notifier-guard>, [">= 0"])
      s.add_dependency(%q<growl>, [">= 0"])
      s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<plist>, [">= 3.1.0"])
    s.add_dependency(%q<logging>, [">= 1.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<rspec>, [">= 2.13"])
    s.add_dependency(%q<rake>, [">= 10.0.0"])
    s.add_dependency(%q<hoe>, [">= 0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 0"])
    s.add_dependency(%q<hoe-git>, [">= 0"])
    s.add_dependency(%q<hoe-version>, [">= 0"])
    s.add_dependency(%q<hoe-bundler>, [">= 0"])
    s.add_dependency(%q<guard>, ["~> 1.7.0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-bundler>, [">= 0"])
    s.add_dependency(%q<terminal-notifier-guard>, [">= 0"])
    s.add_dependency(%q<growl>, [">= 0"])
    s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
  end
end
