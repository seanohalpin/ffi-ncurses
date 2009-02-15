#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'

# translated from "Programmer's Guide to NCurses", Gookin, p. 292

begin
  include FFI::NCurses
  initscr
  noecho
  win = newwin(5, 20, 10, 30)
  box(win, 0, 0)
  waddstr(win, "This is 'win'")
  wrefresh(win)
  wgetch(win)

  winy, winx = getyx(win)
  stdy, stdx = getyx(stdscr)
  vy, vx = getsyx
  printw("    win: %d, %d\n", :int, winy, :int, winx)
  printw(" stdscr: %d, %d\n", :int, stdy, :int, stdx)
  printw("virtual: %d, %d\n", :int, vy, :int, vx)
  refresh
  getch

  vy, vx = getsyx
  printw("virtual: %d, %d\n", :int, vy, :int, vx)
  refresh
  getch

  leaveok(win, FFI::NCurses::TRUE)
  wrefresh(win)
  winy, winx = getyx(win)
  vy, vx = getsyx
  printw("    win: %d, %d\n", :int, winy, :int, winx)
  printw("virtual: %d, %d\n", :int, vy, :int, vx)
  refresh
  getch

  setsyx(3, 3)
  wrefresh(newscr)
  getch
  vy, vx = getsyx
  printw("virtual: %d, %d\n", :int, vy, :int, vx)
  refresh
  getch
  
rescue Object => e
  FFI::NCurses.endwin
  raise
ensure
  FFI::NCurses.endwin
end
