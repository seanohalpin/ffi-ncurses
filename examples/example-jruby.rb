require 'ffi'
require 'ffi-ncurses'

include FFI::NCurses

initscr
addstr 'Hello World'
refresh
getch
endwin
