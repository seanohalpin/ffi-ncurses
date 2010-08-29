#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/ord-shim'  # for 1.8.6 compatibility
include FFI::NCurses

initscr
begin
  # turn cursor off
  curs_set 0

  # initialize colour
  start_color

  # set up colour pairs
  #             Background       Foreground
  init_pair(0,  Colour::BLACK,   Colour::BLACK)
  init_pair(1,  Colour::RED,     Colour::BLACK)
  init_pair(2,  Colour::GREEN,   Colour::BLACK)
  init_pair(3,  Colour::YELLOW,  Colour::BLACK)
  init_pair(4,  Colour::BLUE,    Colour::BLACK)
  init_pair(5,  Colour::MAGENTA, Colour::BLACK)
  init_pair(6,  Colour::CYAN,    Colour::BLACK)
  init_pair(7,  Colour::WHITE,   Colour::BLACK)

  init_pair(8,  Colour::BLACK,   Colour::BLACK)
  init_pair(9,  Colour::BLACK,   Colour::RED)
  init_pair(10, Colour::BLACK,   Colour::GREEN)
  init_pair(11, Colour::BLACK,   Colour::YELLOW)
  init_pair(12, Colour::BLACK,   Colour::BLUE)
  init_pair(13, Colour::BLACK,   Colour::MAGENTA)
  init_pair(14, Colour::BLACK,   Colour::CYAN)
  init_pair(15, Colour::BLACK,   Colour::WHITE)

  0.upto(15) do |i|
    attr_set A_NORMAL, i, nil
    addch("A"[0].ord + i)
  end

  # add character and attribute together
  addch("Z"[0].ord | COLOR_PAIR(1)) # red

  # reset attribute and colour to default
  attr_set A_NORMAL, 0, nil

  # start new line
  addstr "\n"

  # how to add a single space
  addch(' '[0].ord)
  # or
  addstr(" ")

  addstr "Press any key"

  # display and pause for key press
  refresh
  ch = getch
ensure
  endwin
end
