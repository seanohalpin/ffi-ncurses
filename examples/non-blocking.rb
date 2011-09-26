#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'

def KEY(ch)
  ch[0].ord
end

include FFI::NCurses
initscr
begin
  cbreak
  noecho
  curs_set 0
  timeout(100) # delay in milliseconds
  counter = 0
  move 0, 0
  scrollok(stdscr, true)
  while (ch = getch) != KEY("q")
    flushinp
    addstr sprintf("You pressed %d\n", ch)
    refresh
  end
ensure
  endwin
end
