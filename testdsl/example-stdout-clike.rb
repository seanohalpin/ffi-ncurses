#!/usr/bin/env ruby -w
require 'ffi-ncurses'
include NCurses

def main(argc, argv)
  initscr();
  addstr("Hello World");
  refresh();
  if(argc > 1) then
    getch();
  end
  endwin();
  return(0);
end

main(ARGV.size + 1, [$0] + ARGV)
