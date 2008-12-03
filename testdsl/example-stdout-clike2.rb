#!/usr/bin/env ruby -w
require 'ffi-ncurses'
include NCurses

def c_if(expr, &block)
  if expr && block_given?
    block.call
  end
end
def nloop(n, &block)
  n.times do |i|
    block.call
  end
end
def argc
  ARGV.size + 1
end
def argv
  [$0] + ARGV
end
load "testdsl/eg1.src"
