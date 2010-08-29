#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
initscr
begin
  attributes = %w[
    A_BLINK
    A_BOLD
    A_DIM
    A_NORMAL
    A_REVERSE
    A_STANDOUT
    A_UNDERLINE
  ]
  alt_attributes = %w[
    A_ALTCHARSET
    A_HORIZONTAL
    A_INVIS
    A_LEFT
    A_LOW
    A_PROTECT
    A_RIGHT
    A_TOP
    A_VERTICAL
  ]

  attributes.each do |attr|
    attr_const = FFI::NCurses.const_get(attr)
    attr_set attr_const, 0, nil
    addstr "THIS IS #{attr}\n"
  end

  refresh
  ch = getch
ensure
  endwin
end
