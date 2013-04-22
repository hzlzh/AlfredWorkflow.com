#!/usr/bin/env ruby
# encoding: UTF-8

$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")
# $: << File.join(File.dirname(__FILE__), "../../multi_json/lib")

require 'multi_json'
require 'benchmark'
require 'yajl'
require 'json'
require 'oj'

iter = 1_000_000
iter = 100_000

json = %({"k1":"val1","k2":"val2","k3":"val3"})
obj = { k1: "val1", k2: "val2", k3: "val3" }

puts "Benchmarks for different JSON handlers with MultiJson."
puts "  Ruby #{RUBY_VERSION}"
puts "  #{iter} iterations"

MultiJson.engine = :oj
dt = Benchmark.realtime { iter.times { MultiJson.decode(json) }}
et = Benchmark.realtime { iter.times { MultiJson.encode(obj) }}
puts "    Oj decode: #{dt}  encode: #{et}"

MultiJson.engine = :yajl
dt = Benchmark.realtime { iter.times { MultiJson.decode(json) }}
et = Benchmark.realtime { iter.times { MultiJson.encode(obj) }}
puts "  Yajl decode: #{dt}  encode: #{et}"

MultiJson.engine = :json_gem
dt = Benchmark.realtime { iter.times { MultiJson.decode(json) }}
et = Benchmark.realtime { iter.times { MultiJson.encode(obj) }}
puts "  Json decode: #{dt}  encode: #{et}"

Oj.default_options = { :mode => :compat, :time_format => :ruby }
dt = Benchmark.realtime { iter.times { Oj.load(json) }}
et = Benchmark.realtime { iter.times { Oj.dump(obj) }}
puts "Raw Oj decode: #{dt}  encode: #{et}"

ye = Yajl::Encoder.new
dt = Benchmark.realtime { iter.times { Yajl::Parser.parse(json) }}
et = Benchmark.realtime { iter.times { Yajl::Encoder.encode(obj) }}
e2 = Benchmark.realtime { iter.times { ye.encode(obj) }}
puts "Raw Yajl decode: #{dt} encode: #{et}, encoder: #{e2}"
