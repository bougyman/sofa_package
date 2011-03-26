require_relative "../lib/sofa_package"
require "makura"
if ENV["SofaPackage_Server"]
  Makura::Model.server = ENV["SofaPackage_Server"]
end
if ENV["SofaPackage_DB"]
  Makura::Model.database = ENV["SofaPackage_DB"]
end
Makura::Model.database ||= "aur"
require_relative "./package"
require_relative "./stats"
