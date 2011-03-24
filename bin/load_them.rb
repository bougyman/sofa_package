#!/usr/bin/env ruby
require_relative "../model/pkgbuild"
start = ARGV[0]
go = false
Dir["aur/*"].sort.each { |dir| 
  go = true if start.nil? or File.basename(dir) == start
  next unless go
  next unless File.directory?(dir)
  puts File.basename(dir)
  Pkgbuild.new(dir).write 
}
