# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'ffi-ncurses/version'
project = FFI::NCurses

require 'rake/testtask'
require 'yard'

Rake::TestTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => %w(spec)

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w[--readme README.rdoc]
end

desc "Build #{project::NAME}-#{project::VERSION} gem"
task :gem do
  system "gem build #{project::NAME}.gemspec"
end

desc "Push #{project::NAME}-#{project::VERSION} gem to rubygems.org"
task :release => :gem do
  system "gem push #{project::NAME}-#{project::VERSION}.gem"
end

