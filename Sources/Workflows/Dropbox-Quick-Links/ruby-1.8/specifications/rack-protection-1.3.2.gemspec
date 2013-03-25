# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-protection}
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Konstantin Haase", "Alex Rodionov", "Chris Heald", "Chris Mytton", "Corey Ward", "David Kellum", "Fojas", "Mael Clerambault", "Martin Mauch", "SAKAI, Kazuaki", "Stanislav Savulchik", "Steve Agalloco", "Akzhan Abdulin", "TOBY", "Bj\303\270rge N\303\246ss"]
  s.date = %q{2012-12-12}
  s.description = %q{You should use protection!}
  s.email = ["konstantin.mailinglists@googlemail.com", "p0deje@gmail.com", "cheald@gmail.com", "self@hecticjeff.net", "coreyward@me.com", "dek-oss@gravitext.com", "developer@fojasaur.us", "mael@clerambault.fr", "martin.mauch@gmail.com", "kaz.july.7@gmail.com", "s.savulchik@gmail.com", "steve.agalloco@gmail.com", "akzhan.abdulin@gmail.com", "toby.net.info.mail+git@gmail.com", "bjoerge@bengler.no"]
  s.files = ["License", "README.md", "Rakefile", "lib/rack-protection.rb", "lib/rack/protection.rb", "lib/rack/protection/authenticity_token.rb", "lib/rack/protection/base.rb", "lib/rack/protection/escaped_params.rb", "lib/rack/protection/form_token.rb", "lib/rack/protection/frame_options.rb", "lib/rack/protection/http_origin.rb", "lib/rack/protection/ip_spoofing.rb", "lib/rack/protection/json_csrf.rb", "lib/rack/protection/path_traversal.rb", "lib/rack/protection/remote_referrer.rb", "lib/rack/protection/remote_token.rb", "lib/rack/protection/session_hijacking.rb", "lib/rack/protection/version.rb", "lib/rack/protection/xss_header.rb", "rack-protection.gemspec", "spec/authenticity_token_spec.rb", "spec/escaped_params_spec.rb", "spec/form_token_spec.rb", "spec/frame_options_spec.rb", "spec/http_origin_spec.rb", "spec/ip_spoofing_spec.rb", "spec/json_csrf_spec.rb", "spec/path_traversal_spec.rb", "spec/protection_spec.rb", "spec/remote_referrer_spec.rb", "spec/remote_token_spec.rb", "spec/session_hijacking_spec.rb", "spec/spec_helper.rb", "spec/xss_header_spec.rb"]
  s.homepage = %q{http://github.com/rkh/rack-protection}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{You should use protection!}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
  end
end
