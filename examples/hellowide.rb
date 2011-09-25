#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/widechars'

def centre(text)
  col = (COLS() - WideChars.display_width(text.strip))/2
  y, x = getyx(stdscr)
  mvaddstr y, col, text
end

if RUBY_VERSION >= '1.9.0'
  def fullwidth(txt)
    txt.encode("UTF-32BE").codepoints.map{ |x|
      case x
      when 0x30..0x7F
        x + 0xFEE0
      else
        x
      end
    }.pack("U*")
  end
else
  def fullwidth(txt)
    txt.unpack("U*").map { |x|
      case x
      when 0x30..0x7F
        x + 0xFEE0
      else
        x
      end
    }.pack("U*")
  end
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
  centre "Hello " + greeting + "\n"
  centre "你好\n"
  centre "ＨＥＬＬＯ ＷＯＲＬＤ\n"
  centre fullwidth("[Testing 1234]\n\n")
  centre "Press any key to continue"
  refresh
  ch = getch
ensure
  flushinp
  endwin
end
