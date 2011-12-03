# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hash_keyword_args/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["ronen barzel"]
  gem.email         = ["ronen@barzel.org"]
  gem.description   = %q{Makes it easier and more robust to use a hash for keyword args to a method. In particular, performs argument checking and default values.}
  gem.summary       = %q{Helper for using a hash for keyword args to a method. Performs argument checking, provides accessor methods for values, supports default values, required arguments, and argument value validation.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hash_keyword_args"
  gem.require_paths = ["lib"]
  gem.version       = HashKeywordArgs::VERSION

  gem.add_dependency 'enumerable_hashify'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'simplecov-gem-adapter'
end
