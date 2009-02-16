#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  initscr
  win = newwin(6, 12, 15, 15)
  box(win, 0, 0)
  inner_win = newwin(4, 10, 16, 16)
  waddstr(inner_win, (["Hello!"] * 5).join(' '))
  wrefresh(win)
  wrefresh(inner_win)
  ch = wgetch(inner_win)
  delwin(win)

rescue Object => e
  FFI::NCurses.endwin
  puts e
ensure
  FFI::NCurses.endwin
end
