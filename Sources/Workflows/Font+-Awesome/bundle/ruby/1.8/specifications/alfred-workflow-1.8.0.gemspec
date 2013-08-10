# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alfred-workflow}
  s.version = "1.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zhao Cai"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDdDCCAlygAwIBAgIBATANBgkqhkiG9w0BAQUFADBAMRIwEAYDVQQDDAljYWl6\naGFvZmYxFTATBgoJkiaJk/IsZAEZFgVnbWFpbDETMBEGCgmSJomT8ixkARkWA2Nv\nbTAeFw0xMzA0MTYxMzAxMzlaFw0xNDA0MTYxMzAxMzlaMEAxEjAQBgNVBAMMCWNh\naXpoYW9mZjEVMBMGCgmSJomT8ixkARkWBWdtYWlsMRMwEQYKCZImiZPyLGQBGRYD\nY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu2zqh0u+TbhY5kNf\nZ4OI5AZnXyIE6xVjO7mpp5t5qS+6m8iPIwWYhVTzFm/TDHX1jJ1Dauy7/iXA5m+i\nxAKAOmCiL2j1VudVz+qBKPwiPAG3O0gtLWsxX5J5BwMimakOmDTGmXAEJCCYNjs8\n9hdJzcGLydTpQU3RuAn2RE+Y7Rzwm3RAW/hMs5PDdx/3XtksHlQ54is4zob0aCOs\nhJ9TYLpaKvtZCixX0YyiIuAl07BI4sYyXNNWzk+tHf5RlJ3d/oXR/XxLI6xH2v+h\nRMsQVqF9UKGANhc8yhrcL7YnG6G8v8fkdJFKa2ZuBSIqYKCLl4ATcXD6tTF+THTf\noVxAGQIDAQABo3kwdzAJBgNVHRMEAjAAMB0GA1UdDgQWBBSCk5kEqlkwgrdYCHRk\nwy0ZQt1eeTAeBgNVHREEFzAVgRNjYWl6aGFvZmZAZ21haWwuY29tMAsGA1UdDwQE\nAwIEsDAeBgNVHRIEFzAVgRNjYWl6aGFvZmZAZ21haWwuY29tMA0GCSqGSIb3DQEB\nBQUAA4IBAQCle3HlwCgKX19WNYY2EcJYilQCZJPtl/Gj1EbefaX3paMym6yO4FB9\ni2yP1WTVB4N8OrS0z24b6mo5jKgplyTU6w9D+yI5WKbN4C7XCbBLeNGVlD9yK8CA\nzc+igDfc63grzUR5Xj7PPxef4owUdz+XDG+mmmv6wNyXSzQUtFyZ8ucVL1vk5ihP\nvZU7EDLfcHe3xiTYkarBtblwtSj6PHtYn/1v8ztYHhGKvW3wTTiplNwnW4Sx2Wfa\neIuFwYbmfyt5/ObUtmp3BlaIStTiX9TBWeuTx6Zq6q6wDzcudbDRd+jLa2XG2AGB\nS6w/KYMnbhUxfyEU1MX10sJv87WIrtgF\n-----END CERTIFICATE-----\n"]
  s.date = %q{2013-05-03}
  s.description = %q{alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.}
  s.email = ["caizhaoff@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.md"]
  s.files = [".rspec", ".ruby-version", "Gemfile", "Gemfile.lock", "Guardfile", "History.txt", "Manifest.txt", "README.md", "Rakefile", "alfred-workflow.gemspec", "lib/alfred.rb", "lib/alfred/feedback.rb", "lib/alfred/feedback/file_item.rb", "lib/alfred/feedback/item.rb", "lib/alfred/setting.rb", "lib/alfred/ui.rb", "lib/alfred/version.rb", "spec/alfred/feedback/item_spec.rb", "spec/alfred/feedback_spec.rb", "spec/alfred/setting_spec.rb", "spec/alfred/ui_spec.rb", "spec/alfred_spec.rb", "spec/spec_helper.rb", "test/workflow/info.plist", ".gemtest"]
  s.homepage = %q{http://zhaocai.github.com/alfred2-ruby-template/}
  s.licenses = ["GPL-3"]
  s.rdoc_options = ["--title", "TestAlfred::TestWorkflow Documentation", "--quiet"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{alfred-workflow}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<plist>, [">= 3.1.0"])
      s.add_development_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.13"])
      s.add_development_dependency(%q<facets>, [">= 2.9.0"])
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
    else
      s.add_dependency(%q<plist>, [">= 3.1.0"])
      s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_dependency(%q<rspec>, [">= 2.13"])
      s.add_dependency(%q<facets>, [">= 2.9.0"])
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
    end
  else
    s.add_dependency(%q<plist>, [">= 3.1.0"])
    s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
    s.add_dependency(%q<rspec>, [">= 2.13"])
    s.add_dependency(%q<facets>, [">= 2.9.0"])
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
  end
end
