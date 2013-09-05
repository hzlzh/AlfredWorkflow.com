# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :version
Hoe.plugin :yard
Hoe.plugin :travis

Hoe.spec 'alfred-workflow' do

  developer 'Zhao Cai', 'caizhaoff@gmail.com'

  license 'GPL-3'

  extra_deps << ['plist', '>= 3.1.0']




  extra_dev_deps << ['rspec', '>= 2.13']
  extra_dev_deps << ['facets', '>= 2.9.0']
  extra_dev_deps << ['rake', '>= 10.0.0']
  extra_dev_deps << ['hoe'] << ['hoe-gemspec'] << ['hoe-git'] << ['hoe-version'] << ['hoe-bundler'] << ['hoe-yard']
  extra_dev_deps << ['guard', '~> 1.7.0'] << ['guard-rspec'] << ['guard-bundler']
  extra_dev_deps << ['terminal-notifier-guard'] << ['growl']

end

%w{major minor patch}.each { |v|
  desc "Bump #{v.capitalize} Version"
  task "bump:#{v}", [:message] => ["version:bump:#{v}"] do |t, args|
    m = args[:message] ? args[:message] : "Bump version to #{ENV["VERSION"]}"
    sh "git commit -am '#{m}'"
  end
}


desc "automate guard rspec"
task :guard  do
  sh %q{bundle exec guard --group=system}
end

desc "multirubies"
task :multirubies  do
  sh %q{bundle exec guard --group=multirubies}
end




# vim: syntax=ruby
