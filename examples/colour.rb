#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/ord_shim'  # for 1.8.6 compatibility
include FFI::NCurses

initscr
begin
  # turn cursor off
  curs_set 0

  # initialize colour
  start_color

  # set up colour pairs
  #             Background       Foreground
  init_pair(0,  Color::BLACK,   Color::BLACK)
  init_pair(1,  Color::RED,     Color::BLACK)
  init_pair(2,  Color::GREEN,   Color::BLACK)
  init_pair(3,  Color::YELLOW,  Color::BLACK)
  init_pair(4,  Color::BLUE,    Color::BLACK)
  init_pair(5,  Color::MAGENTA, Color::BLACK)
  init_pair(6,  Color::CYAN,    Color::BLACK)
  init_pair(7,  Color::WHITE,   Color::BLACK)

  init_pair(8,  Color::BLACK,   Color::BLACK)
  init_pair(9,  Color::BLACK,   Color::RED)
  init_pair(10, Color::BLACK,   Color::GREEN)
  init_pair(11, Color::BLACK,   Color::YELLOW)
  init_pair(12, Color::BLACK,   Color::BLUE)
  init_pair(13, Color::BLACK,   Color::MAGENTA)
  init_pair(14, Color::BLACK,   Color::CYAN)
  init_pair(15, Color::BLACK,   Color::WHITE)

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
