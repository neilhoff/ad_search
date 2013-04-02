# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ad_search/version"

Gem::Specification.new do |s|
  s.name        = "ad_search"
  s.version     = AdSearch::VERSION
  s.authors     = ["Neil Hoff"]
  s.email       = ["neilhoff@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Search Active Directory}
  s.description = %q{Allows you to connect to and search your Active Directory system for users that have
                     not been disabled.  Returns a hash.}

  s.rubyforge_project = "ad_search"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "net-ldap"
end
