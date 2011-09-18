#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0
  ch = 0
  name = "none"
  # while ch != 27                # Escape
  while ch != KEY_CTRL_Q
    clear
    addstr "Press any key (Ctrl-Q to exit): "
    #printw "name: %s dec: %d char: [%c]", :string, name, :int, ch, :int, ch
    addstr sprintf("name: %s dec: %d char: [%s]", name, ch, (1..127).include?(ch) ? ch.chr : " ")
    refresh
    ch = getch
    name = keyname(ch)
  end
ensure
  endwin
end
