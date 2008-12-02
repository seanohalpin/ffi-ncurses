#!/usr/bin/env ruby -w
# shows how to call variadic functions
require 'ffi-ncurses'
begin	
  NCurses.initscr
  NCurses.clear
  NCurses.printw("Hello %s! There are %d arguments to this variadic function!", :string, "world", :int, 2)
  NCurses.refresh
  NCurses.getch
ensure
  NCurses.endwin
end
