# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sqlite3}
  s.version = "1.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck", "Luis Lavena", "Aaron Patterson"]
  s.date = %q{2013-01-12}
  s.description = %q{This module allows Ruby programs to interface with the SQLite3
database engine (http://www.sqlite.org).  You must have the
SQLite engine installed in order to build this module.

Note that this module is only compatible with SQLite 3.6.16 or newer.}
  s.email = ["jamis@37signals.com", "luislavena@gmail.com", "aaron@tenderlovemaking.com"]
  s.extensions = ["ext/sqlite3/extconf.rb"]
  s.extra_rdoc_files = ["API_CHANGES.rdoc", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "ext/sqlite3/backup.c", "ext/sqlite3/database.c", "ext/sqlite3/exception.c", "ext/sqlite3/sqlite3.c", "ext/sqlite3/statement.c"]
  s.files = ["API_CHANGES.rdoc", "CHANGELOG.rdoc", "ChangeLog.cvs", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "ext/sqlite3/backup.c", "ext/sqlite3/backup.h", "ext/sqlite3/database.c", "ext/sqlite3/database.h", "ext/sqlite3/exception.c", "ext/sqlite3/exception.h", "ext/sqlite3/extconf.rb", "ext/sqlite3/sqlite3.c", "ext/sqlite3/sqlite3_ruby.h", "ext/sqlite3/statement.c", "ext/sqlite3/statement.h", "faq/faq.rb", "faq/faq.yml", "lib/sqlite3.rb", "lib/sqlite3/constants.rb", "lib/sqlite3/database.rb", "lib/sqlite3/errors.rb", "lib/sqlite3/pragmas.rb", "lib/sqlite3/resultset.rb", "lib/sqlite3/statement.rb", "lib/sqlite3/translator.rb", "lib/sqlite3/value.rb", "lib/sqlite3/version.rb", "setup.rb", "tasks/faq.rake", "tasks/gem.rake", "tasks/native.rake", "tasks/vendor_sqlite3.rake", "test/helper.rb", "test/test_backup.rb", "test/test_collation.rb", "test/test_database.rb", "test/test_database_readonly.rb", "test/test_deprecated.rb", "test/test_encoding.rb", "test/test_integration.rb", "test/test_integration_open_close.rb", "test/test_integration_pending.rb", "test/test_integration_resultset.rb", "test/test_integration_statement.rb", "test/test_sqlite3.rb", "test/test_statement.rb", "test/test_statement_execute.rb", "test/test_result_set.rb", ".gemtest"]
  s.homepage = %q{http://github.com/luislavena/sqlite3-ruby}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{sqlite3}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{This module allows Ruby programs to interface with the SQLite3 database engine (http://www.sqlite.org)}
  s.test_files = ["test/test_backup.rb", "test/test_collation.rb", "test/test_database.rb", "test/test_database_readonly.rb", "test/test_deprecated.rb", "test/test_encoding.rb", "test/test_integration.rb", "test/test_integration_open_close.rb", "test/test_integration_pending.rb", "test/test_integration_resultset.rb", "test/test_integration_statement.rb", "test/test_result_set.rb", "test/test_sqlite3.rb", "test/test_statement.rb", "test/test_statement_execute.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.8.2"])
      s.add_development_dependency(%q<mini_portile>, ["~> 0.2.2"])
      s.add_development_dependency(%q<hoe>, ["~> 3.4"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.8.2"])
      s.add_dependency(%q<mini_portile>, ["~> 0.2.2"])
      s.add_dependency(%q<hoe>, ["~> 3.4"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.8.2"])
    s.add_dependency(%q<mini_portile>, ["~> 0.2.2"])
    s.add_dependency(%q<hoe>, ["~> 3.4"])
  end
end
