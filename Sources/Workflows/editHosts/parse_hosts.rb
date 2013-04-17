#!/usr/bin/env ruby
PATH = '/etc/hosts'

def split_args(args)
    split = args.strip.split(/\s+/)
    puts split
    return false if split.length != 2

    return split
end

def line_is_entry(line, address, host)
    not line.match(/#{address}(\s+)#{host}/).nil?
end

def remove_entry(args)
    addr, host = split_args(args)
    return false if addr == false

    removed = false
    input = File.read(PATH)
    output = String.new

    File.open(PATH, "r").each_line do |line|

        if line_is_entry(line, addr, host)
            removed = true
        else
            output << line
        end
    end

    if removed
        File.open(PATH, 'w') { |file| file.puts output }
    end
end

def add_entry(args)
    addr, host = split_args(args)
    return false if addr == false

    File.open(PATH, 'a') { |file| file.puts addr + ' ' + host }
end

