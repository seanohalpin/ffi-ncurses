#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/widechars'

def centre(text)
  col = (COLS() - WideChars.display_width(text))/2
  y, x = getyx(stdscr)
  mvaddstr y, col, text
end

include FFI::NCurses
begin
  greeting = ARGV.shift || "World"
  stdscr = initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0
  #  printw "Hello %s", :string, greeting # doesn't work in rbx
  # addstr "Hello " + greeting + "\n"
  # addstr "你好" + "\n"
  # addstr "ＨＥＬＬＯ ＷＯＲＬＤ\n"
  # addstr "-|" * 11 + "\n"

  move (LINES() - 3)/3, 0
  centre "Hello " + greeting
  addstr "\n"
  centre "你好"
  addstr "\n"
  centre "ＨＥＬＬＯ ＷＯＲＬＤ"
  addstr "\n\n"
  centre "Press any key to continue"
  refresh
  ch = getch
  flushinp
  #printw "\nYou pressed %c (%d)", :char, ch, :int, ch
  addstr sprintf("\nYou pressed %c (%d)", ch, ch)
  refresh
  sleep 1
ensure
  endwin
end
