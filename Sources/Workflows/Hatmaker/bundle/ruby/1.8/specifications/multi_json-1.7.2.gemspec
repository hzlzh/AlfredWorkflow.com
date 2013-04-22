# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multi_json}
  s.version = "1.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Josh Kalderimis", "Erik Michaels-Ober", "Pavel Pravosud"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDLjCCAhagAwIBAgIBADANBgkqhkiG9w0BAQUFADA9MQ8wDQYDVQQDDAZzZmVy\naWsxFTATBgoJkiaJk/IsZAEZFgVnbWFpbDETMBEGCgmSJomT8ixkARkWA2NvbTAe\nFw0xMzAyMDMxMDAyMjdaFw0xNDAyMDMxMDAyMjdaMD0xDzANBgNVBAMMBnNmZXJp\nazEVMBMGCgmSJomT8ixkARkWBWdtYWlsMRMwEQYKCZImiZPyLGQBGRYDY29tMIIB\nIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl0x5dx8uKxi7TkrIuyBUTJVB\nv1o93nUB9j/y4M96gV2rYwAci1JPBseNd6Fybzjo3YGuHl7EQHuSHNaf1p2lxew/\ny60JXIJBBgPcDK/KCP4NUHofm0jfoYD+H5uNJfHCNq7/ZsTxOtE3Ra92s0BCMTpm\nwBMMlWR5MtdEhIYuBO4XhnejYgH0L/7BL2lymntVnsr/agdQoojQCN1IQmsRJvrR\nduZRO3tZvoIo1pBc4JEehDuqCeyBgPLOqMoKtQlold1TQs1kWUBK7KWMFEhKC/Kg\nzyzKRHQo9yDYwOvYngoBLY+T/lwCT4dyssdhzRbfnxAhaKu4SAssIwaC01yVowID\nAQABozkwNzAJBgNVHRMEAjAAMB0GA1UdDgQWBBS0ruDfRak5ci1OpDNX/ZdDEkIs\niTALBgNVHQ8EBAMCBLAwDQYJKoZIhvcNAQEFBQADggEBAHHSMs/MP0sOaLkEv4Jo\nzvkm3qn5A6t0vaHx774cmejyMU+5wySxRezspL7ULh9NeuK2OhU+Oe3TpqrAg5TK\nR8GQILnVu2FemGA6sAkPDlcPtgA6ieI19PZOF6HVLmc/ID/dP/NgZWWzEeqQKmcK\n2+HM+SEEDhZkScYekw4ZOe164ZtZG816oAv5x0pGitSIkumUp7V8iEZ/6ehr7Y9e\nXOg4eeun5L/JjmjARoW2kNdvkRD3c2EeSLqWvQRsBlypHfhs6JJuLlyZPGhU3R/v\nSf3lVKpBCWgRpGTvy45XVpB+59y33PJmEuQ1PTEOYvQyao9UKMAAaAN/7qWQtjl0\nhlw=\n-----END CERTIFICATE-----\n"]
  s.date = %q{2013-03-22}
  s.description = %q{A gem to provide easy switching between different JSON backends, including Oj, Yajl, the JSON gem (with C-extensions), the pure-Ruby JSON gem, and OkJson.}
  s.email = ["michael@intridea.com", "josh.kalderimis@gmail.com", "sferik@gmail.com"]
  s.files = [".yardopts", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE.md", "README.md", "Rakefile", "multi_json.gemspec", "Gemfile", ".document", ".rspec", ".travis.yml", "spec/adapter_shared_example.rb", "spec/has_options.rb", "spec/helper.rb", "spec/json_common_shared_example.rb", "spec/multi_json_spec.rb", "lib/multi_json/adapter.rb", "lib/multi_json/adapters/gson.rb", "lib/multi_json/adapters/jr_jackson.rb", "lib/multi_json/adapters/json_common.rb", "lib/multi_json/adapters/json_gem.rb", "lib/multi_json/adapters/json_pure.rb", "lib/multi_json/adapters/nsjsonserialization.rb", "lib/multi_json/adapters/oj.rb", "lib/multi_json/adapters/ok_json.rb", "lib/multi_json/adapters/yajl.rb", "lib/multi_json/convertible_hash_keys.rb", "lib/multi_json/options.rb", "lib/multi_json/vendor/okjson.rb", "lib/multi_json/version.rb", "lib/multi_json.rb"]
  s.homepage = %q{http://github.com/intridea/multi_json}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A gem to provide swappable JSON backends.}
  s.test_files = ["spec/adapter_shared_example.rb", "spec/has_options.rb", "spec/helper.rb", "spec/json_common_shared_example.rb", "spec/multi_json_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end
