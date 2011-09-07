#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  greeting = ARGV.shift || "World"
  stdscr = initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0
  #  printw "Hello %s", :string, greeting # doesn't work in rbx
  addstr "Hello " + greeting

  move 3, 0
  addstr "Press any key to continue"
  refresh
  ch = getch
  #printw "\nYou pressed %c (%d)", :char, ch, :int, ch
  addstr sprintf("\nYou pressed %c (%d)", ch, ch)
  refresh
  sleep 1
ensure
  endwin
end
