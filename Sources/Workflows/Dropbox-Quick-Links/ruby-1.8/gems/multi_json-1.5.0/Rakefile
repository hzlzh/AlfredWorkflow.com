require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
desc "Run all examples"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

namespace :doc do
  require 'rdoc/task'
  require File.expand_path('../lib/multi_json/version', __FILE__)
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "multi_json #{MultiJson::VERSION}"
    rdoc.main = 'README.md'
    rdoc.rdoc_files.include('README.md', 'LICENSE.md', 'lib/**/*.rb')
  end
end
