
begin
  require 'bones'
rescue LoadError
  abort '### please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name         'logging'
  summary      'A flexible and extendable logging library for Ruby'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://rubygems.org/gems/logging'

  rdoc.exclude << '^data'
  rdoc.include << '^examples/.*\.rb'
  #rcov.opts    << '-x' << '~/.rvm/'

  use_gmail

  depend_on 'little-plugger'
  depend_on 'multi_json'

  depend_on 'flexmock', '~> 1.0',  :development => true
  depend_on 'bones-git',           :development => true
  #depend_on 'bones-rcov',   :development => true
}

