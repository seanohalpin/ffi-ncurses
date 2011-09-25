# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'ffi-ncurses/version'

date         = "2011-09-25"
authors      = ["Sean O'Halpin"]
email        = "sean.ohalpin@gmail.com"
project      = FFI::NCurses
description  = "An FFI wrapper around ncursesw 5.x for MRI Ruby 1.8.x, 1.9.x and JRuby."
dependencies = [
                ["ffi", ">= 1.0.9"],
                ["ffi-locale", ">= 1.0.0"],
               ]

Gem::Specification.new do |s|
  s.authors     = authors
  s.email       = email
  s.date        = date
  s.description = description
  dependencies.each do |dep|
    s.add_dependency *dep
  end
  s.files =
    [
     "#{project::NAME}.gemspec",
     "lib/#{project::NAME}.rb",
     "COPYING",
     "History.txt",
     "README.rdoc",
     "Rakefile",
     "Gemfile",
     "Gemfile.lock",
    ] +
    Dir["examples/**/*"] +
    Dir["lib/**/*.rb"] +
    Dir["spec/**/*.rb"]

  s.name          = project::NAME
  s.version       = project::VERSION
  s.homepage      = "http://github.com/seanohalpin/#{project::NAME}"
  s.summary       = s.description
  s.require_paths = ["lib"]
end
