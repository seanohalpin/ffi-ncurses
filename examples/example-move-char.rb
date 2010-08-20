#!/usr/bin/env ruby
# encoding: UTF-8
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-20

require 'ffi-ncurses'

include FFI::NCurses

def clip(value, max)
  (value + max) % max
end

def log(txt)
  File.open("log.log", "a") do |file|
    file.puts(txt)
  end
end

begin
  # standard preamble
  initscr
  raw
  keypad stdscr, FFI::NCurses::TRUE
  noecho
  curs_set 0

  # init

  XINC = 2
  YINC = 1

  COLS = 80
  ROWS = 40

  MAX_X = COLS * XINC
  MAX_Y = ROWS * YINC

  MIN_X = 0
  MIN_Y = 0

  new_x = x = MIN_X
  new_y = y = MIN_Y

  # create windows
  # - outer window (with border = 'frame')
  # - inner window ('canvas')

  win = newwin(MAX_Y + 2, MAX_X + 2, MIN_Y, MIN_X)
  inner_win = newwin(MAX_Y, MAX_X, MIN_Y + 1, MIN_X + 1)
  box(win, 0, 0)

  # NB: have to specify for each window
  keypad inner_win, FFI::NCurses::TRUE

  wrefresh(inner_win)
  wrefresh(win)
  ch = 0

  while ch != KEY_CTRL_Q
    # update position
    mvwaddstr inner_win, y, x, "."
    x = new_x
    y = new_y
    mvwaddstr inner_win, y, x, "@"

    # update both windows
    wrefresh(inner_win)
    # wrefresh(win)

    # get command
    ch = wgetch(inner_win)
    # log "ch=#{ch}"

    case ch

      # orthogonal movement
    when KEY_UP
      new_y = clip(y - YINC, MAX_Y)
    when KEY_DOWN
      new_y = clip(y + YINC, MAX_Y)
    when KEY_LEFT
      new_x = clip(x - XINC, MAX_X)
    when KEY_RIGHT
      new_x = clip(x + XINC, MAX_X)

      # diagonal movement
    when KEY_PPAGE
      # page up
      new_x = clip(x + XINC, MAX_X)
      new_y = clip(y - YINC, MAX_Y)
    when KEY_NPAGE
      # page down
      new_x = clip(x + XINC, MAX_X)
      new_y = clip(y + YINC, MAX_Y)
    when KEY_HOME
      new_x = clip(x - XINC, MAX_X)
      new_y = clip(y - YINC, MAX_Y)
    when KEY_END
      new_x = clip(x - XINC, MAX_X)
      new_y = clip(y + YINC, MAX_Y)

    when KEY_CTRL_L, KEY_RESIZE
      # refresh

      # if we don't delete and recreate the window, then calling
      # box(win, 0, 0) creates a border the width of the whole screen
      # rather than just the window
      delwin(win)
      win = newwin(MAX_Y + 2, MAX_X + 2, MIN_Y, MIN_X)
      box(win, 0, 0)
      wrefresh(inner_win)
      wrefresh(win)

      # quit
    when KEY_CTRL("Q")
      break
    else
      log "ch=#{ch}"
    end
  end
ensure
  endwin
end

