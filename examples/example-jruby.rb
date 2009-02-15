#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi'
require 'ffi-ncurses'

include FFI::NCurses

initscr
addstr 'Hello World'
refresh
getch
endwin
