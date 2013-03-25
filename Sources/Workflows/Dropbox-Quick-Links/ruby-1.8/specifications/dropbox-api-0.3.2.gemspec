# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dropbox-api}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcin Bunsch"]
  s.date = %q{2012-08-31}
  s.description = %q{To deliver a more Rubyesque experience when using the DropBox API.}
  s.email = ["marcin@futuresimple.com"]
  s.files = [".gitignore", ".rspec", "Gemfile", "LICENSE", "README.markdown", "Rakefile", "dropbox-api.gemspec", "lib/dropbox-api.rb", "lib/dropbox-api/client.rb", "lib/dropbox-api/client/files.rb", "lib/dropbox-api/client/raw.rb", "lib/dropbox-api/connection.rb", "lib/dropbox-api/connection/requests.rb", "lib/dropbox-api/objects/delta.rb", "lib/dropbox-api/objects/dir.rb", "lib/dropbox-api/objects/file.rb", "lib/dropbox-api/objects/fileops.rb", "lib/dropbox-api/objects/object.rb", "lib/dropbox-api/tasks.rb", "lib/dropbox-api/util/config.rb", "lib/dropbox-api/util/error.rb", "lib/dropbox-api/util/oauth.rb", "lib/dropbox-api/util/util.rb", "lib/dropbox-api/version.rb", "spec/connection.sample.yml", "spec/fixtures/dropbox.jpg", "spec/lib/dropbox-api/client_spec.rb", "spec/lib/dropbox-api/connection_spec.rb", "spec/lib/dropbox-api/dir_spec.rb", "spec/lib/dropbox-api/file_spec.rb", "spec/lib/dropbox-api/oauth_spec.rb", "spec/lib/dropbox-api/thumbnail_spec.rb", "spec/spec_helper.rb", "spec/support/config.rb", "spec/support/jpeg.rb"]
  s.homepage = %q{http://github.com/futuresimple/dropbox-api}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dropbox-api}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A Ruby client for the DropBox REST API.}
  s.test_files = ["spec/connection.sample.yml", "spec/fixtures/dropbox.jpg", "spec/lib/dropbox-api/client_spec.rb", "spec/lib/dropbox-api/connection_spec.rb", "spec/lib/dropbox-api/dir_spec.rb", "spec/lib/dropbox-api/file_spec.rb", "spec/lib/dropbox-api/oauth_spec.rb", "spec/lib/dropbox-api/thumbnail_spec.rb", "spec/spec_helper.rb", "spec/support/config.rb", "spec/support/jpeg.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
    else
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<hashie>, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<hashie>, [">= 0"])
  end
end
