require 'makura'
require 'pathname'
require "base64"
require "filemagic"
class String
  def unquote
    sub(/^(['"])(.*?)\1$/, '\2')
  end
end

Makura::Model.database = "aur"
class Package
  include Makura::Model
  PROPS = [:pkgname, :pkgver, :pkgrel, :epoch, :pkgdesc, :arch, :url, :license, :groups, :makedepends,
           :depends, :optdepends, :provides, :conflicts, :replaces, :backup, :options, :changelog,
           :install, :source, :noextract, :md5sums, :sha1sums, :sha256sums, :sha384sums, :sha512sums,
           :text, :files]
  properties *PROPS
  layout :all
  def self.varname(var)
    Package::PROPS.include?(var.to_sym) ? var : "var_#{var}"
  end
  save
end

class Pkgbuild
  attr_reader :pkgbuild, :dir
  def initialize(dir)
    @dir = Pathname(dir).expand_path
    @magic = FileMagic.new(0)
  end

  def pkgbuild
    @pkgbuild ||= File.read(dir.join("PKGBUILD"))
  end

  def encode(file)
    @magic.file(file.to_s) =~ /text/i ? File.read(file) : "b:#{Base64.encode64(File.read(file))}"
  end

  def files
    _files = []
    dir.find { |path| _files << path.expand_path if path.file? and path.basename.to_s != "PKGBUILD" }
    Hash[_files.map { |f| [f.relative_path_from(dir).to_s, encode(f)] }]
  end

  def package
    Package.new(parse_pkgbuild.merge({_id: dir.basename, pkgbuild: pkgbuild, files: files}))
  end

  def parse_pkgbuild
    plains = pkgbuild.scan(/^(\w+)=([^(]*?)$/)
    arrays = pkgbuild.scan(/^(\w+)=(\(.*?\))/m)
    Hash[
      plains.map{|a,b| [Package.varname(a), b.unquote]} + 
      arrays.map{|a,b| [Package.varname(a), disarray(b)]}
    ]
  end

  def disarray(array)
    st = array.each_char.inject([[""],q=nil]) do |(s,q),chr|
      break [s,q] if chr == ')'
      if s.last.empty?
        next [s,q] if chr == '('
        next [s,q] if chr =~ /\s/
        if chr =~ /(['"])/
          q = $1
          next [s,q]
        else
          s.last << chr
        end
      else
        if q
          next [s << '',nil] if chr == q
        else
          next [s << '',q] if chr =~ /\s/
        end
        s.last << chr
      end
      [s,q]
    end
    arr = st.first
    arr.last == "" ? arr[0 .. -2] : arr
  end
end

if $0 == __FILE__
  path = ARGV[0]
  raise "No Path" unless path and Pathname(path).directory?
  Pkgbuild.new(path).package.save
end
