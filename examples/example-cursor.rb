#!/usr/bin/env ruby -w
require 'ffi-ncurses'
include NCurses
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
  NCurses.endwin
end
