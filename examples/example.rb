#!/usr/bin/env ruby
#
# This file exercises a mish-mash of different features.
#
# Sean O'Halpin, 2009-01-18
#
require 'ffi-ncurses'
require 'ffi-ncurses/ord-shim'  # for 1.8.6 compatibility

begin
  # the methods can be called as module methods
  FFI::NCurses.initscr
  FFI::NCurses.clear
  FFI::NCurses.printw("Hello world!")
  FFI::NCurses.refresh
  FFI::NCurses.getch
  FFI::NCurses.endwin

  # or as included methods
  include FFI::NCurses
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
  printw("Hi! maxyx %d %d\n", *([:int, :int].zip(getmaxyx(FFI::NCurses.stdscr)).flatten))
  # easier to do this
  #addstr(sprintf("paryx %d %d\n", *getparyx(FFI::NCurses.stdscr)))
  standend

  init_pair(1, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::BLACK)
  init_pair(2, FFI::NCurses::Colour::RED, FFI::NCurses::Colour::BLACK)
  init_pair(3, FFI::NCurses::Colour::GREEN, FFI::NCurses::Colour::BLACK)
  init_pair(4, FFI::NCurses::Colour::YELLOW, FFI::NCurses::Colour::BLACK)
  init_pair(5, FFI::NCurses::Colour::BLUE, FFI::NCurses::Colour::BLACK)
  init_pair(6, FFI::NCurses::Colour::MAGENTA, FFI::NCurses::Colour::BLACK)
  init_pair(7, FFI::NCurses::Colour::CYAN, FFI::NCurses::Colour::BLACK)
  init_pair(8, FFI::NCurses::Colour::WHITE, FFI::NCurses::Colour::BLACK)

  init_pair(9, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::BLACK)
  init_pair(10, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::RED)
  init_pair(11, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::GREEN)
  init_pair(12, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::YELLOW)
  init_pair(13, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::BLUE)
  init_pair(14, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::MAGENTA)
  init_pair(15, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::CYAN)
  init_pair(16, FFI::NCurses::Colour::BLACK, FFI::NCurses::Colour::WHITE)

  1.upto(16) do |i|
    attr_set FFI::NCurses::A_NORMAL, i, nil
    addch("A"[0].ord - 1 + i)
  end
  attr_set FFI::NCurses::A_HORIZONTAL, 0, nil
  addch("Z"[0].ord | COLOR_PAIR(3))
  attr_set A_BOLD, 2, nil
  addch "S"[0].ord

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
  FFI::NCurses.endwin
  raise
ensure
  FFI::NCurses.endwin
end
