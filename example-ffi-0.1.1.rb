#!/usr/bin/env ruby -w
require 'ffi-ncurses'
begin	
  # the methods can be called as module methods
#   NCurses.initscr
#   NCurses.clear
#   NCurses.addstr("Hello world!")
#   NCurses.refresh
#   NCurses.getch
#   NCurses.endwin

  NCurses.initscr
  NCurses.start_color
  NCurses.curs_set 0
  NCurses.raw
  NCurses.cbreak
  NCurses.noecho
  NCurses.clear
  NCurses.move 10, 10
  NCurses.standout
  NCurses.addstr("Hi!")
  NCurses.standend
  NCurses.refresh
  NCurses.getch

  NCurses.init_pair(1, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  NCurses.init_pair(2, NCurses::Colour::RED, NCurses::Colour::BLACK)
  NCurses.init_pair(3, NCurses::Colour::GREEN, NCurses::Colour::BLACK)
  NCurses.init_pair(4, NCurses::Colour::YELLOW, NCurses::Colour::BLACK)
  NCurses.init_pair(5, NCurses::Colour::BLUE, NCurses::Colour::BLACK)
  NCurses.init_pair(6, NCurses::Colour::MAGENTA, NCurses::Colour::BLACK)
  NCurses.init_pair(7, NCurses::Colour::CYAN, NCurses::Colour::BLACK)
  NCurses.init_pair(8, NCurses::Colour::WHITE, NCurses::Colour::BLACK)

  NCurses.init_pair(9, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  NCurses.init_pair(10, NCurses::Colour::BLACK, NCurses::Colour::RED)
  NCurses.init_pair(11, NCurses::Colour::BLACK, NCurses::Colour::GREEN)
  NCurses.init_pair(12, NCurses::Colour::BLACK, NCurses::Colour::YELLOW)
  NCurses.init_pair(13, NCurses::Colour::BLACK, NCurses::Colour::BLUE)
  NCurses.init_pair(14, NCurses::Colour::BLACK, NCurses::Colour::MAGENTA)
  NCurses.init_pair(15, NCurses::Colour::BLACK, NCurses::Colour::CYAN)
  NCurses.init_pair(16, NCurses::Colour::BLACK, NCurses::Colour::WHITE)
  
  1.upto(16) do |i|
    NCurses.attr_set NCurses::A_NORMAL, i, 0
    NCurses.addch(?A - 1 + i)
  end
  NCurses.attr_set NCurses::A_HORIZONTAL, 0, 0
  NCurses.addch(?Z | NCurses::COLOR_PAIR(3))
  NCurses.attr_set NCurses::A_BOLD, 2, 0
  NCurses.addch ?S

  NCurses.refresh
  ch = NCurses.getch
  NCurses.endwin

  NCurses.initscr
  NCurses.curs_set 0
  NCurses.raw
  NCurses.cbreak
  NCurses.noecho
  win = NCurses.newwin(6, 12, 15, 15)
  NCurses.box(win, 0, 0)
  inner_win = NCurses.newwin(4, 10, 16, 16)
  NCurses.waddstr(inner_win, (["Hello window!"] * 5).join(' '))
  NCurses.wrefresh(win)
  NCurses.wrefresh(inner_win)
  ch = NCurses.wgetch(inner_win)

rescue Object => e
  NCurses.endwin
  puts e
ensure
  NCurses.endwin
end
