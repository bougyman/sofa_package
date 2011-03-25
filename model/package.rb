require_relative "../lib/sofa_package"
require 'makura'
Makura::Model.database = "aur"
module SofaPackage
  class Package
    include Makura::Model
    PROPS = [:pkgname, :pkgver, :pkgrel, :epoch, :pkgdesc, :arch, :url, :license, :groups, :makedepends,
             :depends, :optdepends, :provides, :conflicts, :replaces, :backup, :options, :changelog,
             :install, :source, :noextract, :md5sums, :sha1sums, :sha256sums, :sha384sums, :sha512sums,
             :pkgbuild]

    def self.varname(var)
      Package::PROPS.include?(var.to_sym) ? var : "var_#{var}"
    end

    properties *PROPS
    property :votes, :type => String
    property :comments, :type => Array

    layout :all, :map => File.read(CouchDir.join("map/package_all.js")
    layout :withdesc, :map => File.read(CouchDir.join("/couch/map/package_withdesc.js")
    save
  end
end
