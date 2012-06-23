# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "extend_at/version"

Gem::Specification.new do |s|
  s.name        = "extend_at"
  s.version     = ExtendModelAt::VERSION
  s.authors     = ["Andrés José Borek"]
  s.email       = ["andres.b.dev@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Create dynamic fields to extend rails models (like content types in Drupal)}
  s.description = %q{This gem allows you to extend rails models without migrations: This way you can, i.e., develop your own content types, like in Drupal.}

  s.rubyforge_project = "extend_at"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '~> 3.1'
  s.add_development_dependency "rspec", '~> 2.8'
  s.add_development_dependency "rspec-core", '~> 2.8'
  s.add_development_dependency "rspec-expectations", '~> 2.8'
  s.add_development_dependency "activesupport", '~> 3.1'
#   s.add_development_dependency "rspec-mocks", '~> 2.8.0'
  s.add_development_dependency "database_cleaner", "~> 0.8"
  
end
