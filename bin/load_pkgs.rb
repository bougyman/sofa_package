#!/usr/bin/env ruby
require_relative "../model/init"
require "sofa_package/pkgbuild"
SofaPackage::Log.level = Logger::INFO
start = ARGV[0]
go = false
if user_path = ENV["SofaPackage_Path"]
  path = Pathname(user_path)
  raise "WTF? Tthat's not a valid directory." unless path.directory?
else
  path = SofaPackage::Root.join("aur")
end
path.entries.sort.each { |name| 
  if name.to_s =~ /^\.(?:\.|git)?$/
    SofaPackage::Log.warn "skipping #{name.to_s}"
    next
  end
  dir = path.join(name)
  go = true if start.nil? or dir.basename.to_s == start
  next unless go
  next unless dir.directory?
  begin
    SofaPackage::Pkgbuild.new(dir).write 
  rescue => e
    SofaPackage::Log.error "Wo! #{e}"
    SofaPackage::Log.error e.backtrace.join("\n\t")
  end
}
