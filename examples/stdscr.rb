#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-01-31
#
require 'ffi-ncurses'
begin
  scr = FFI::NCurses.initscr
  FFI::NCurses.box(FFI::NCurses.stdscr, 0, 0)
  FFI::NCurses.mvaddstr 1, 1, "#{[scr, FFI::NCurses.stdscr].inspect}"
  FFI::NCurses.refresh
  FFI::NCurses.getch

rescue Object => e
  FFI::NCurses.endwin
  raise
ensure
  FFI::NCurses.endwin
end
