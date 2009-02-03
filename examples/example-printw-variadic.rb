#!/usr/bin/env ruby -w
# shows how to call variadic functions
require 'ffi-ncurses'
begin	
  FFI::NCurses.initscr
  FFI::NCurses.clear
  FFI::NCurses.printw("Hello %s! There are %d arguments to this variadic function!", :string, "world", :int, 2)
  FFI::NCurses.refresh
  FFI::NCurses.getch
ensure
  FFI::NCurses.endwin
end
