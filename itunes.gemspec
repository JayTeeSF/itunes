# -*- encoding: utf-8 -*-
require File.expand_path('../lib/itunes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Hoth Jr"]
  gem.email         = ["jason_hoth_jr@his-service.net"]
  gem.description   = %q{Utilities to Generate, Parse, and otherwise manipulate iTunes libraries, their playlists and their tracks}
  gem.summary       = %q{Utilities to Generate, Parse, and otherwise manipulate iTunes libraries, their playlists and their tracks}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "itunes"
  gem.require_paths = ["lib"]
  gem.version       = Itunes::VERSION
  gem.add_dependency('object_cache', '>=0.0.1')
end
