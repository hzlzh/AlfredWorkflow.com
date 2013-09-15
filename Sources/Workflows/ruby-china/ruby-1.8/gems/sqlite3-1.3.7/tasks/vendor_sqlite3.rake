require "rake/clean"
require "rake/extensioncompiler"
require "mini_portile"

$recipes = {}

$recipes[:sqlite3] = MiniPortile.new "sqlite3", BINARY_VERSION
$recipes[:sqlite3].files << "http://sqlite.org/sqlite-autoconf-#{URL_VERSION}.tar.gz"

namespace :ports do
  directory "ports"

  desc "Install port sqlite3 #{$recipes[:sqlite3].version}"
  task :sqlite3 => ["ports"] do |t|
    recipe = $recipes[:sqlite3]
    checkpoint = "ports/.#{recipe.name}-#{recipe.version}-#{recipe.host}.installed"

    unless File.exist?(checkpoint)
      cflags = "-O2 -DSQLITE_ENABLE_COLUMN_METADATA"
      cflags << " -fPIC" if recipe.host && recipe.host.include?("x86_64")
      recipe.configure_options << "CFLAGS='#{cflags}'"
      recipe.cook
      touch checkpoint
    end

    recipe.activate
  end
end

if RUBY_PLATFORM =~ /mingw/
  Rake::Task['compile'].prerequisites.unshift "ports:sqlite3"
end

if ENV["USE_MINI_PORTILE"] == "true"
  Rake::Task["compile"].prerequisites.unshift "ports:sqlite3"
end

task :cross do
  ["CC", "CXX", "LDFLAGS", "CPPFLAGS", "RUBYOPT"].each do |var|
    ENV.delete(var)
  end
  host = ENV.fetch("HOST", Rake::ExtensionCompiler.mingw_host)
  $recipes.each do |_, recipe|
    recipe.host = host
  end

  # hook compile task with dependencies
  Rake::Task["compile"].prerequisites.unshift "ports:sqlite3"
end

CLOBBER.include("ports")
