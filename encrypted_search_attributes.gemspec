# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'encrypted_search_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "encrypted_search_attributes"
  spec.version       = EncryptedSearchAttributes::VERSION
  spec.authors       = ["M. Scott Ford"]
  spec.email         = ["scott@corgibytes.com"]
  spec.summary       = %q{Auto populates encrypted fields that are designed for searching}
  spec.description   = %q{Encrypting a field makes it very difficult to perform a case insensitive search for the columns data. This gem normalizes the text before encrypted it and storing it in a search column. The current normalization method is to convert the text to all lowercase.}
  spec.homepage      = ""
  spec.license       = "Apache License v2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'symmetric-encryption', '~> 3.3'
  spec.add_dependency 'activerecord', '>= 3'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
