#!/usr/bin/env ruby
require 'pathname'
require "open-uri"
require "mimer_plus"
require "nokogiri"
require_relative "../sofa_package"
require SofaPackage::Root.join("model/init").to_s

class String
  def unquote
    sub(/^(['"])(.*?)\1$/, '\2')
  end
end

module SofaPackage
  class Pkgbuild
    attr_reader :dir
    def initialize(pathname)
      @dir = pathname.respond_to?(:expand_path) ? pathname.expand_path : Pathname(pathname).expand_path
      @name = @dir.basename
    end

    def pkgbuild
      @pkgbuild ||= File.read(dir.join("PKGBUILD"))
    end

    def mime_type(file)
      Mimer.new(file).mime_type
    end

    def comments
      return @_comments if @_comments
      @_comments = if id = metadata[:aur_id]
        if res = open("http://aur.archlinux.org/packages.php?ID=#{id}")
          (Nokogiri(res)/"div.comment-header").map { |c| [c.next_element.text.strip, c.text.strip].join(" ") }
        end
      else
        []
      end
    end

    def metadata
      return @_metadata if @_metadata
      res = JSON.parse open("http://aur.archlinux.org/rpc.php?type=info&arg=#{@name}").read
      @_metadata = if results = res["results"]
        {aur_id: results["ID"],
         votes: results["NumVotes"].to_i,
         out_of_date: results["OutOfDate"] == "0" ? false : true}
      else
        {}
      end
    end

    def files
      return @files if @files
      _files = []
      dir.find { |path| _files << path.expand_path if path.file? && path.to_s !~ %r{/\.} && path.basename.to_s != "PKGBUILD" }
      @files = _files.map { |f| f.relative_path_from(dir).to_s }
    end

    def attach_files(pkg)
      Log.info "Adding Attachments to #{@name}" unless files.empty?
      files.each { |path| 
        Log.info path
        id = CGI.escape(path)
        file = dir.join path
        pkg.attach(id, File.read(file), "rev" => pkg._rev, "Content-Type" => mime_type(file))
        pkg = Package[pkg._id]
      }
    end

    def write
      pkg = package
      if exists = Package[pkg._id]
        pkg._rev = exists._rev
      end
      if pkg.save
        attach_files(pkg)
      end
    end

    def package
      Package.new(parse_pkgbuild.merge(metadata).merge({_id: dir.basename, pkgbuild: pkgbuild, comments: comments}))
    end

    def parse_pkgbuild
      Log.info "Parsing PKGBUILD for #{@name}"
      origpkg = pkgbuild.dup
      if type = mime_type(dir.join("PKGBUILD")).split(/;\s*/)[1]
        content_type = type.match(/charset=([^\s]*)/)[1].upcase
        unless ["UTF-8", "US-ASCII", "BINARY"].include? content_type
          p "Converting #{@name}/PKGBUILD to UTF-8 from #{content_type}"
          begin
            @pkgbuild = Iconv.new("UTF-8", content_type).conv(origpkg)
          rescue Iconv::InvalidEncoding
            nil
          end
        end
      end
      plains = pkgbuild.scan(/^(\w+)=([^(]*?)\s*$/)
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
          next [s,q] if chr =~ /[\s,]/
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
end

if $0 == __FILE__
  path = ARGV[0]
  raise "No Path" unless path and Pathname(path).directory?
  SofaPackage::Pkgbuild.new(path).write
end
