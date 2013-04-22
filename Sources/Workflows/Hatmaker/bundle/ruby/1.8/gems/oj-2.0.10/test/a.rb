#!/usr/bin/env ruby -wW1
# encoding: UTF-8

$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'pp'
require 'oj'
require 'perf'

obj = [[1],[2],[3],[4],[5],[6],[7],[8],[9]]
obj = [[],[],[],[],[],[],[],[],[]]
obj = {
  'a' => 'Alpha', # string
  'b' => true,    # boolean
  'c' => 12345,   # number
  'd' => [ true, [false, [12345, nil], 3.967, ['something', false], nil]], # mix it up array
  'e' => { 'one' => 1, 'two' => 2 }, # hash
  'f' => nil,     # nil
  'g' => 12345678901234567890123456789, # big number
  'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
  'i' => [[[[[[[nil]]]]]]]  # deep array, again, not that deep
}

json = Oj.dump(obj, mode: :compat)

puts json
#pp Oj.saj_parse(nil, json)
pp Oj.t_parse(json)

if true
  perf = Perf.new()
  perf.add('SAJ', 'oj') { Oj.saj_parse(nil, json) }
  perf.add('T', 'oj') { Oj.t_parse(json) }
  perf.add('load', 'oj') { Oj.load(json) }
  perf.run(10000)
end
