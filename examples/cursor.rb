#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses

def try_cursor(n)
  addstr "\ncurs_set #{n} "
  curs_set n
  getch
end

begin
  initscr
  noecho
  addstr "Press any key to cycle through the cursor types:\n"
  addstr "Default "
  getch
  try_cursor 0
  # Note that there probably won't be any difference between cursors 1
  # and 2 on an X terminal. Try in the Linux console to see a difference.
  try_cursor 1
  try_cursor 2
ensure
  FFI::NCurses.endwin
end
