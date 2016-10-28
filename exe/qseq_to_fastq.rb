#!/usr/bin/env ruby
require 'zlib'

File.open(ARGV[0], 'w') do |f|
  STDIN.each_line do |line|
    part = line.gsub!(/\n/, '').split(/\t/)
    f.puts "@#{part[2..7].join(':')}\n"
    f.puts "#{part[8]}\n"
    f.puts "+\n"
    f.puts "#{part[9]}\n"
  end
end
