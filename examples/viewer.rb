#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# A simple file viewer.
#
# Sean O'Halpin, 2011-09-16
#
# Possible features to add:
# - show line, col numbers
# - hex view
#
require 'ffi-ncurses'

include FFI::NCurses

# some helper methods for working with stdlib FILE pointers
module CLib
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  typedef :pointer, :FILEP
  # FILE* open, close and eof
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
  attach_function :feof, [:FILEP], :int
end

$APP_DEBUG = ARGV.delete("--debug")
def log(*a)
  STDERR.puts a.inspect if $APP_DEBUG
end

def redraw_background_frame
  clear
  touchwin(stdscr)
  box(stdscr, 0, 0)
  title = "[ F1 for help ]"
  wmove(stdscr, 0, (COLS() - title.size)/2)
  waddstr(stdscr, title)
  refresh
end

def show_text_window(title, text)
  text_width = text.lines.map{ |x| x.size }.max
  text_height = text.lines.to_a.size

  width = text_width + 2
  height = text_height + 2
  col = (COLS() - width)/2
  row = (LINES() - height)/2

  frame = newwin(height, width, row, col)
  keypad frame, true
  box(frame, 0, 0)

  title = "[ #{title} ]"
  wmove(frame, 0, (width - title.size)/2)
  waddstr(frame, title)

  win = derwin(frame, text_height, text_width, 1, 1)
  wmove(win, 0, 0)
  waddstr(win, text)
  wrefresh(win)
  wgetch(frame)
  flushinp
  delwin(win)
  delwin(frame)
end

def view(text)
  lines = text.lines.to_a
  maxx = lines.map{|x| x.size }.max + 1
  maxy = lines.size + 1

  # We need to open /dev/tty so we can read from STDIN without borking
  # ncurses
  term = CLib.fopen("/dev/tty", "rb+")
  screen = newterm(nil, term, term)
  old_screen = set_term(screen)

  help_text = <<EOT
F1          - Help
Home        - Beginning of file
End         - End of file
PgDn, space - Scroll down one page
PgUp        - Scroll up one page
Down arrow  - Scroll down one line
Up arrow    - Scroll up one line
Right arrow - Scroll right one column
Left arrow  - Scroll left one column
^q, q, Esc  - Quit
EOT

  saved_exception = nil
  begin
    raw
    noecho
    curs_set 0
    pad = newpad(maxy, maxx)
    keypad pad, true
    lines.each do |line|
      rv = waddstr(pad, line)
      log :adding, line, :rv, rv
    end

    current_line = 0
    current_col  = 0

    border = 2
    redraw_background_frame

    rv = prefresh(pad, current_line, current_col, border, border, LINES() - border - 1, COLS() - border - 1)
    log :prefresh1, :rv, rv

    # main loop
    while ch = wgetch(pad)
      log :ch, ch
      case ch
      when KEY_HOME
        current_line = 0
      when KEY_END
        current_line = maxy - LINES() + border
      when KEY_NPAGE, ' '[0].ord
        current_line = [current_line + LINES(), maxy - LINES() + border].min
      when KEY_PPAGE
        current_line = [current_line - LINES() + border, 0].max
      when KEY_DOWN
        current_line = [current_line + 1, maxy - LINES() + border].min
      when KEY_UP
        current_line = [current_line - 1, 0].max
      when KEY_RIGHT
        current_col = [current_col + 1, maxx - COLS() + border].min
      when KEY_LEFT
        current_col = [current_col - 1, 0].max
      when KEY_F1
        # Help
        show_text_window "Help", help_text
        redraw_background_frame
      when KEY_CTRL_Q, 'q'[0].ord, 27 # 27 == Esc
        # Quit
        delwin(pad)
        break
      when KEY_CTRL_C
        # for JRuby - Ctrl-C in cbreak mode is not trapped in rescue below for some reason
        raise Interrupt
      when KEY_RESIZE
        redraw_background_frame
      end
      rv = prefresh(pad, current_line, current_col, border, border, LINES() - border - 1, COLS() - border - 1)
      log :prefresh2, :rv, rv
    end
  rescue Object => e
    saved_exception = e
  ensure
    CLib.fclose(term) if !CLib.feof(term)
    flushinp
    endwin
    delscreen(screen)
  end
  if saved_exception
    raise saved_exception
  end
end

view(ARGF.read) # simplistic but works for demo
