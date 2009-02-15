#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  initscr
  addstr "Default"
  getch
  addstr "curs_set 0"
  curs_set 0
  getch
  addstr "curs_set 1"
  curs_set 1
  getch
  addstr "curs_set 2"
  curs_set 2
  getch
ensure
  FFI::NCurses.endwin
end
