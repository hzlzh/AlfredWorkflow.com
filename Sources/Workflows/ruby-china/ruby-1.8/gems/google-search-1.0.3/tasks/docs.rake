
namespace :docs do
  
  desc 'Build sdoc'
  task :build do
    sh "sdoc -d -N -i lib -x spec -x examples -x doc -x Manifest -x Rakefile"
  end
  
  desc 'Remove rdoc products'
  task :remove => [:clobber_docs]
  
  desc 'Build docs, and open in browser for viewing (specify BROWSER)'
  task :open => ['docs:build'] do
    browser = ENV["BROWSER"] || "safari"
    sh "open -a #{browser} doc/index.html"
  end
  
end