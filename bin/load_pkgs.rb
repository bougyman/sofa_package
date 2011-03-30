#!/usr/bin/env ruby
require_relative "../model/init"
require "sofa_package/pkgbuild"

app_root = File.expand_path(File.join(File.dirname(__FILE__),".."))

SofaPackage::Log.level = Logger::INFO
["aur"].each do |repos|
  Dir.chdir File.join(app_root, repos)
  %x{git pull}
  if File.exists?(".been_touched_before")
    %x{find . -maxdepth 1 -type d -mmin -2 >/tmp/#{repos}_changed}
  else
    %x{find . -maxdepth 1 -type d >/tmp/#{repos}_changed}
    File.open(".been_touched_before","w") { |f| f.puts Time.now }
  end

  changed_packages = File.readlines("/tmp/#{repos}_changed")[2 .. -1].map { |f| f.strip }# Get rid of top-level dir and pkg metadata-dir 
  changed_packages.each do |cp|
    begin
      SofaPackage::Pkgbuild.new(cp).write 
    rescue => e
      SofaPackage::Log.error "Wo! #{e}"
      SofaPackage::Log.error e.backtrace.join("\n\t")
    end
  end
end
