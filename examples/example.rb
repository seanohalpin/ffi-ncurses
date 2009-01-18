#!/usr/bin/env ruby -w
#
# This file exercises a mish-mash of different features.
#
# Sean O'Halpin, 2009-01-18
#
require 'ffi-ncurses'
begin	
  # the methods can be called as module methods
  NCurses.initscr
  NCurses.clear
  NCurses.printw("Hello world!")
  NCurses.refresh
  NCurses.getch
  NCurses.endwin

  # or as included methods
  include NCurses
  initscr
  start_color
  curs_set 0
  raw
  cbreak
  noecho
  clear
  move 10, 10
  standout
  # hmmm.. you have to jump through some hoops to avoid temporary variables
  # 
  printw("Hi! maxyx %d %d\n", *([:int, :int].zip(getmaxyx(NCurses.stdscr)).flatten))
  # easier to do this
  #addstr(sprintf("paryx %d %d\n", *getparyx(NCurses.stdscr)))
  standend

  init_pair(1, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  init_pair(2, NCurses::Colour::RED, NCurses::Colour::BLACK)
  init_pair(3, NCurses::Colour::GREEN, NCurses::Colour::BLACK)
  init_pair(4, NCurses::Colour::YELLOW, NCurses::Colour::BLACK)
  init_pair(5, NCurses::Colour::BLUE, NCurses::Colour::BLACK)
  init_pair(6, NCurses::Colour::MAGENTA, NCurses::Colour::BLACK)
  init_pair(7, NCurses::Colour::CYAN, NCurses::Colour::BLACK)
  init_pair(8, NCurses::Colour::WHITE, NCurses::Colour::BLACK)

  init_pair(9, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  init_pair(10, NCurses::Colour::BLACK, NCurses::Colour::RED)
  init_pair(11, NCurses::Colour::BLACK, NCurses::Colour::GREEN)
  init_pair(12, NCurses::Colour::BLACK, NCurses::Colour::YELLOW)
  init_pair(13, NCurses::Colour::BLACK, NCurses::Colour::BLUE)
  init_pair(14, NCurses::Colour::BLACK, NCurses::Colour::MAGENTA)
  init_pair(15, NCurses::Colour::BLACK, NCurses::Colour::CYAN)
  init_pair(16, NCurses::Colour::BLACK, NCurses::Colour::WHITE)
  
  1.upto(16) do |i|
    attr_set NCurses::A_NORMAL, i, nil
    addch(?A - 1 + i)
  end
  attr_set NCurses::A_HORIZONTAL, 0, nil
  addch(?Z | COLOR_PAIR(3))
  attr_set A_BOLD, 2, nil
  addch ?S

  refresh
  ch = getch
  endwin

  initscr
  curs_set 0
  raw
  cbreak
  noecho
  win = newwin(12, 22, 15, 15)
  box(win, 0, 0)

  # inner_win = newwin(10, 20, 16, 16)

  # note: you can cause a bus error if subwindow parameters exceed
  # parent boundaries

  # inner_win = subwin(win, 8, 18, 18, 18)
  inner_win = derwin(win, 8, 18, 1, 2)
  waddstr(inner_win, sprintf("begyx %d %d\n", *getbegyx(inner_win)))
  waddstr(inner_win, sprintf("maxyx %d %d\n", *getmaxyx(inner_win)))
  waddstr(inner_win, sprintf("paryx %d %d\n", *getparyx(inner_win)))
  waddstr(inner_win, (["Hello window!"] * 5).join(' '))

  wrefresh(win)
  wrefresh(inner_win)
  ch = wgetch(win)
  wclear(inner_win)
  # note: you must clear up subwindows in reverse order
  delwin(inner_win)
  wmove(win, 1, 2)
  waddstr(win, "Bye bye!")
  wrefresh(win)
  ch = wgetch(win)
  delwin(win)
  
rescue Object => e
  NCurses.endwin
  puts e.backtrace.join("\n")
ensure
  NCurses.endwin
#   NCurses.class_eval {
#     require 'pp'
#     pp @unattached_functions

#   }
end
