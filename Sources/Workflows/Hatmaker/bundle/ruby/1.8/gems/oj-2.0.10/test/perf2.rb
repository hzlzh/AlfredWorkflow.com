#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

#require 'test/unit'
require 'optparse'
require 'yajl'
require 'oj'

$indent = 2

opts = OptionParser.new
opts.on("-h", "--help", "Show this display")                { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

class Foo
  def initialize()
    @x = true
    @y = 58
  end
  def to_json()
    %{{"x":#{@x},"y":#{@y}}}
  end
  def to_hash()
    { 'x' => @x, 'y' => @y }
  end
end

iter = 100000
s = %{
{ "class": "Foo::Bar",
  "attr1": [ true, [false, [12345, null], 3.967, ["something", false], null]],
  "attr2": { "one": 1 }
}
}

obj = Oj.load(s)
obj["foo"] = Foo.new()

Oj.default_options = { :indent => 0, :effort => :internal }

puts

start = Time.now
iter.times do
  Oj.load(s)
end
dt = Time.now - start
puts "%d Oj.load()s in %0.3f seconds or %0.1f loads/msec" % [iter, dt, iter/dt/1000.0]

start = Time.now
iter.times do
  Yajl::Parser.parse(s)
end
dt = Time.now - start
puts "%d Yajl::Parser.parse()s in %0.3f seconds or %0.1f parses/msec" % [iter, dt, iter/dt/1000.0]

puts

start = Time.now
iter.times do
  Oj.dump(obj)
end
dt = Time.now - start
puts "%d Oj.dump()s in %0.3f seconds or %0.1f dumps/msec" % [iter, dt, iter/dt/1000.0]

start = Time.now
iter.times do
  Yajl::Encoder.encode(obj)
end
dt = Time.now - start
puts "%d Yajl::Encoder.encode()s in %0.3f seconds or %0.1f encodes/msec" % [iter, dt, iter/dt/1000.0]

puts
