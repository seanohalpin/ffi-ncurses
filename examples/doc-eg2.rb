require 'ffi-ncurses'
include FFI::NCurses
begin
  stdscr = initscr
  start_color
  curs_set 0
  raw
  cbreak
  noecho
  clear
  move 10, 10
  standout
  addstr("Hi!")
  standend
  refresh
  getch
ensure
  endwin
end
