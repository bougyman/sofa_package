module SofaPackage
  class Stats
    include Makura::Model
    properties :none
    layout :licenses, :map => File.read(CouchDir.join("map/stats_licenses.js")), :reduce => File.read(CouchDir.join("reduce/stats_licenses.js"))
    layout :votes, :map => File.read(CouchDir.join("map/stats_votes.js"))
    save
  end
end
