# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
#require "gdata/version"

Gem::Specification.new do |s|
  s.name        = 'gdata'
  s.version     = '1.1.1'
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Jeff Fisher, Ying Tsen Hong'
  s.email       = 'tsenying@gmail.com, jfisher@youtube.com'
  s.homepage    = 'http://github.com/tsenying/gdata-ruby-util.git'
  s.summary     = "Google Data APIs Ruby Utility Library"
  s.description = <<EOF
  This gem provides a set of wrappers designed to make it easy to work with
  the Google Data APIs.
EOF

  s.rubyforge_project      = 'gdata-ruby-util'

  s.files       = `git ls-files`.split("\n").reject {|f| ['test/test_config\.yml'].include?(f) }
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = ['lib']

  s.has_rdoc         = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.rdoc_options << '--main' << 'README'
end
