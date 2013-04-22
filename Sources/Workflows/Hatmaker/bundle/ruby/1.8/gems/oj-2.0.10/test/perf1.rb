#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

#require 'test/unit'
require 'optparse'
require 'oj'
require 'ox'

$indent = 2

opts = OptionParser.new
opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

iter = 100000
s = %{
{ "class": "Foo::Bar",
  "attr1": [ true, [false, [12345, null], 3.967, ["something", false], null]],
  "attr2": { "one": 1 }
}
}
#s = File.read('sample.json')

Oj.default_options = { :indent => 0 }

obj = Oj.load(s)
xml = Ox.dump(obj, :indent => 0)

puts xml

start = Time.now
iter.times do
  Oj.load(s)
end
dt = Time.now - start
puts "%d Oj.load()s in %0.3f seconds or %0.1f loads/msec" % [iter, dt, iter/dt/1000.0]

start = Time.now
iter.times do
  Ox.load(xml)
end
dt = Time.now - start
puts "%d Ox.load()s in %0.3f seconds or %0.1f loads/msec" % [iter, dt, iter/dt/1000.0]

puts

start = Time.now
iter.times do
  Oj.dump(obj)
end
dt = Time.now - start
puts "%d Oj.dump()s in %0.3f seconds or %0.1f dumps/msec" % [iter, dt, iter/dt/1000.0]

start = Time.now
iter.times do
  Ox.dump(obj)
end
dt = Time.now - start
puts "%d Ox.dump()s in %0.3f seconds or %0.1f dumps/msec" % [iter, dt, iter/dt/1000.0]

puts
