#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# minirogue - find your way out of the maze.
#
# Based on the minirogue by Joe at http://cymonsgames.com/learning-curses-by-example/
#
# TODO: Combine this with Jamis Buck's maze generation algorithms to
# guarantee a way out.
#
# © Sean O'Halpin, 2011-10-04
#
require 'ffi-ncurses'

include FFI::NCurses

def KEY(s)
  case s
  when String
    s.unpack("U")[0]
  else
    s
  end
end

def log(*a)
  File.open("log.txt", "ab+") do |file|
    file.puts a.inspect
  end
end

log "Starting #{$0}"

def popup_window(parent_win, title, text)
  text_width = text.lines.map{ |x| x.size }.max
  text_height = text.lines.to_a.size

  width = text_width + 4
  height = text_height + 4

  rows, cols = getmaxyx(parent_win)

  col = (cols - width)/2
  row = (rows - height)/2

  frame = derwin(parent_win, height, width, row, col)
  wclear(frame)
  keypad frame, true
  box(frame, 0, 0)

  title = "[ #{title} ]"
  wmove(frame, 0, (width - title.size)/2)
  waddstr(frame, title)

  win = derwin(frame, text_height, text_width, 2, 2)
  keypad win, true
  wmove(win, 0, 0)
  waddstr(win, text)
  wrefresh(frame)
  wrefresh(win)
  ch = wgetch(win)
  flushinp
  ungetch(ch)
  delwin(win)
  delwin(frame)
end

log "Before initscr"

begin
  initscr
rescue Object => e
  log "Error in initscr: #{e}"
  exit
end

log "initscr"

begin
  if defined?(:has_colors) && has_colors
    start_color
    # standard colours
    init_pair(Color::BLACK,   Color::BLACK,   Color::BLACK)
    init_pair(Color::RED,     Color::RED,     Color::BLACK)
    init_pair(Color::GREEN,   Color::GREEN,   Color::BLACK)
    init_pair(Color::YELLOW,  Color::YELLOW,  Color::BLACK)
    init_pair(Color::BLUE,    Color::BLUE,    Color::BLACK)
    init_pair(Color::MAGENTA, Color::MAGENTA, Color::BLACK)
    init_pair(Color::CYAN,    Color::CYAN,    Color::BLACK)
    init_pair(Color::WHITE,   Color::WHITE,   Color::BLACK)

    door_colour = COLOR_PAIR(Color::GREEN) | A_BOLD
    treasure_colour = COLOR_PAIR(Color::YELLOW) | A_BOLD
  else
    door_colour = 0
    treasure_colour = 0
  end

  ROWS = LINES() / 2
  COLUMNS = COLS() / 3
  map = Array.new(ROWS) { Array.new(COLUMNS) }

  FLOOR    = KEY(' ')
  DOOR     = KEY('+') | door_colour | A_BLINK
  WALL     = ACS_CKBOARD  # ACS values are not defined until after initscr
  TREASURE = KEY('$') | treasure_colour | A_BOLD
  PLAYER   = KEY('@')

  srand
  0.upto(ROWS - 1) do |yy|
    0.upto(COLUMNS - 1) do |xx|
      map[yy][xx] = (
                     (yy != 0 ) &&
                     (yy != ROWS - 1) &&
                     (xx != 0) &&
                     (xx != COLUMNS - 1) &&
                     rand(4) != 0) ? FLOOR : WALL
    end
  end

  maxy, maxx = getmaxyx(stdscr)

  frame = newwin(ROWS + 2, COLUMNS + 2, (maxy - ROWS)/2, (maxx - COLUMNS) / 2)
  box(frame, 0, 0)
  wnoutrefresh(frame)
  GAMEWIN = derwin(frame, ROWS, COLUMNS, 1, 1)

  found_treasure = false
  keypad GAMEWIN, true
  curs_set 0
  noecho
  y = 1
  x = 1
  c = nil
  # make sure starting position is floor
  map[1][1] = FLOOR
  # open doorway out
  outy = rand(ROWS - 2) + 1
  map[outy][COLUMNS - 1] = DOOR

  # place treasure
  ty = rand(ROWS - 2) + 1
  tx = rand(COLUMNS - 2) + 1
  # ty = 2
  # tx = 2
  map[ty][tx] = TREASURE

  # display map
  0.upto(ROWS - 1) do |yy|
    0.upto(COLUMNS - 1) do |xx|
      mvwaddch(GAMEWIN, yy, xx, map[yy][xx])
    end
  end

  mvwaddch(GAMEWIN, y, x, PLAYER)
  wrefresh(GAMEWIN)
  while !(x == COLUMNS - 1 && y == outy) && KEY('q') != (c = wgetch(GAMEWIN))
    0.upto(ROWS - 1) do |yy|
      0.upto(COLUMNS - 1) do |xx|
        mvwaddch(GAMEWIN, yy, xx, map[yy][xx])
      end
    end
    newy, newx = y, x
    case c
    when KEY_UP
      newy -= 1
    when KEY_DOWN
      newy += 1
    when KEY_LEFT
      newx -= 1
    when KEY_RIGHT
      newx += 1
    when KEY_PPAGE
      newy -= 1
      newx += 1
    when KEY_NPAGE
      newy += 1
      newx += 1
    when KEY_HOME
      newy -= 1
      newx -= 1
    when KEY_END
      newy += 1
      newx -= 1
    end
    #log :x, x, :y, y, :newx, newx, :newy, newy, map[newy][newx] & A_CHARTEXT, [FLOOR, DOOR, TREASURE].map{ |x| x & A_CHARTEXT}.include?(map[newy][newx] & A_CHARTEXT), TREASURE == (map[newy][newx] & A_CHARTEXT), TREASURE & A_CHARTEXT
    log :BEFORE, :x, x, :y, y, :newx, newx, :newy, newy, map[newy][newx] & A_CHARTEXT, [FLOOR, DOOR, TREASURE].map{ |sym| sym & A_CHARTEXT}.include?(map[newy][newx] & A_CHARTEXT)
    # NOTE: I had map{|x| x ...} which was causing havoc in 1.8.7. D'oh!
    if [FLOOR, DOOR, TREASURE].map{ |sym| sym & A_CHARTEXT}.include?(map[newy][newx] & A_CHARTEXT)
      y, x = newy, newx
    end
    log :AFTER, :x, x, :y, y
    mvwaddch(GAMEWIN, y, x, PLAYER)
    wrefresh(GAMEWIN)
    if (TREASURE & A_CHARTEXT) == map[y][x] & A_CHARTEXT
      map[y][x] = FLOOR
      found_treasure = true
      popup_window(GAMEWIN, "Message", "Found treasure!")
      # got to be a better way to do this... panels?
      wclear(GAMEWIN)
      0.upto(ROWS - 1) do |yy|
        0.upto(COLUMNS - 1) do |xx|
          mvwaddch(GAMEWIN, yy, xx, map[yy][xx])
        end
      end
      mvwaddch(GAMEWIN, y, x, PLAYER)
      wrefresh(GAMEWIN)
    end
  end
  if c != KEY('q')
    popup_window(GAMEWIN, "Message", "You escaped!")
  end
rescue => e
  log "Error: #{e}"
  endwin
  raise
ensure
  endwin
end
