require "pathname"
module SofaPackage
  LibRoot = Pathname(__FILE__).expand_path.dirname
  unless $LOAD_PATH.include?(LibRoot)
    $LOAD_PATH.unshift(LibRoot.to_s)
  end
  require "sofa_package/version"
  Root = LibRoot.join("..").expand_path
  CouchDir = Root.join("couch").expand_path
end
