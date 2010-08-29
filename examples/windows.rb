#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses

begin
  initscr
  curs_set 0
  win = newwin(6, 12, 15, 15)
  box(win, 0, 0)
  inner_win = newwin(4, 10, 16, 16)
  waddstr(inner_win, (["Hello window!"] * 5).join(' '))
  wrefresh(win)
  wrefresh(inner_win)
  ch = wgetch(inner_win)

rescue Object => e
  endwin
  puts e
ensure
  endwin
end
