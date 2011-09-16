#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/widechars'

def centre(text)
  col = (COLS() - text.strip.size)/2
  y, x = getyx(stdscr)
  mvaddstr y, col, text
end

def fullwidth(txt)
  txt.codepoints.map{ |x|
    case x
    when 0x30..0x7F
      x + 0xFEE0
    else
      x
    end
  }.pack("U*")
end

include FFI::NCurses
begin
  greeting = ARGV.shift || "World"
  stdscr = initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0
  clear
  move (LINES() - 3)/3, 0
  centre "Hello " + greeting + "\n\n"
  centre "Press any key to continue\n"
  refresh
  ch = getch
  flushinp
  addstr sprintf("\nYou pressed %c (%d)", ch, ch)
  refresh
  sleep 1
ensure
  endwin
end
