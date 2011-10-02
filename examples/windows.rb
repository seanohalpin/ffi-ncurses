#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
include FFI::NCurses

def log(*a)
  addstr a.inspect + "\n"
  touchwin(stdscr)
  # STDERR.puts a.inspect
end

begin
  initscr
  curs_set 0
  raw
  noecho
  keypad stdscr, true
  scrollok stdscr, true
  txt = "Press cursor keys to move window"
  win = newwin(7, txt.size + 4, 4, 15)
  box(win, 0, 0)
  inner_win = derwin(win, 4, txt.size + 2, 2, 2)
  wmove(inner_win, 0, 0)
  waddstr(inner_win, txt)
  wmove(inner_win, 2, 0)
  waddstr(inner_win, "Press Ctrl-Q to quit")

  y, x = getbegyx(win)
  move 0, 0
  log :y, y, :x, x
  refresh
  wrefresh(win)
  wrefresh(inner_win)

  ch = 0
  while (ch = getch) != KEY_CTRL_Q
    y, x = getbegyx(win)
    old_y, old_x = y, x
    log :y, y, :x, x, :ch, ch, keyname(ch)
    # move 0, 0
    # addstr "y %d x %d" % [y, x]
    case ch
    when KEY_RIGHT
      x += 1
    when KEY_LEFT
      x -= 1
    when KEY_UP
      y -= 1
    when KEY_DOWN
      y += 1
    end
    rv = mvwin(win, y, x)
    log :y1, y, :x1, x, :rv, rv
    if rv == ERR
      # put the window back
      rv = mvwin(win, old_y, old_x)
    end

    # tell ncurses we want to refresh stdscr (to erase win's frame)
    touchwin(stdscr)
    refresh
    wrefresh(win)
  end

rescue Object => e
  endwin
  puts e
ensure
  endwin
end
