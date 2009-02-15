#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
begin
  stdscr = FFI::NCurses.initscr
  FFI::NCurses.clear
  FFI::NCurses.addstr("Hello world!")
  FFI::NCurses.refresh
  FFI::NCurses.getch
ensure
  FFI::NCurses.endwin
end
