
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe LittlePlugger do

  it "converts a string from camel-case to underscore" do
    LittlePlugger.underscore('FooBarBaz').should be == 'foo_bar_baz'
    LittlePlugger.underscore('CouchDB').should be == 'couch_db'
    LittlePlugger.underscore('FOOBar').should be == 'foo_bar'
    LittlePlugger.underscore('Foo::Bar::BazBuz').should be == 'foo/bar/baz_buz'
  end

  it "generates a default plugin path" do
    LittlePlugger.default_plugin_path(LittlePlugger).should be == 'little_plugger/plugins'
    LittlePlugger.default_plugin_path(Process::Status).should be == 'process/status/plugins'
  end

  it "generates a default plugin module" do
    LittlePlugger.default_plugin_module('little_plugger').should be == LittlePlugger
    lambda {LittlePlugger.default_plugin_module('little_plugger/plugins')}.
        should raise_error(NameError, 'uninitialized constant LittlePlugger::Plugins')
    LittlePlugger.default_plugin_module('process/status').should be == Process::Status
  end
end

# EOF
