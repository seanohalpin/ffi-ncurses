#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses
begin
  slk_init(0)
  initscr
  slk_set(1, "Mabelode", 1)
  slk_set(2, "Xiombarg", 1)
  slk_set(3, "Arioch", 1)
  slk_set(4, "Chaos", 1)
  slk_set(5, "Law", 1)
  slk_set(6, "Corum", 1)
  slk_set(7, "Jhaelen", 1)
  slk_set(8, "Irsei", 1)
  slk_refresh
  getch
ensure
  endwin
end
