#!/usr/bin/env ruby
require_relative "../model/init"
require "sofa_package/pkgbuild"
start = ARGV[0]
go = false
SofaPackage::Root.join("aur/*").entries.sort.each { |dir| 
  go = true if start.nil? or dir.basename.to_s == start
  next unless go
  next unless dir.directory?
  puts dir.basename
  SofaPakcage::Pkgbuild.new(dir).write 
}
