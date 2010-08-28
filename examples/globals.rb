#!/usr/bin/env ruby
#
# Sean O'Halpin, 2010-08-28
#
# Demo that global variables are not initialized until after
# `initscr`.
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  # symbols = [:acs_map, :curscr, :newscr, :stdscr, :ttytype, :COLORS, :COLOR_PAIRS, :COLS, :ESCDELAY, :LINES, :TABSIZE]
        symbols = [
                 "acs_map",
                 "curscr",
                 "newscr",
                 "stdscr",
                 "ttytype",
                 "COLORS",
                 "COLOR_PAIRS",
                 "COLS",
                 "ESCDELAY",
                 "LINES",
                 "TABSIZE"
                ]

  # symbols = [:curscr, :newscr, :stdscr]
  symbols.each do |sym|
    p [sym, FFI::NCurses.send(sym)]
  end
  initscr
  symbols.each do |sym|
    addstr [sym, FFI::NCurses.send(sym)].inspect + "\n"
  end
  refresh
  getch
ensure
  endwin
end
