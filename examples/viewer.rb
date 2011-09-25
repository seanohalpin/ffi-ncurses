#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
#
# A simple file viewer.
#
# Sean O'Halpin, 2011-09-16
#
# Possible features to add:
# - search
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
  attach_function :fflush, [:FILEP], :int
  attach_function :fputs, [:string, :FILEP], :int
end

$APP_DEBUG = ARGV.delete("--debug")
def log(*a)
  STDERR.puts a.inspect if $APP_DEBUG
end

def redraw_background_frame
  clear
  touchwin(stdscr)
  box(stdscr, 0, 0)
  title = "[ F1 or ? for help ]"
  wmove(stdscr, 0, (COLS() - title.size)/2)
  waddstr(stdscr, title)
  wnoutrefresh(stdscr)
end

def std_colors
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
end

def show_text_window(win, title, text)
  text_width = text.lines.map{ |x| x.size }.max
  text_height = text.lines.to_a.size

  width = text_width + 4
  height = text_height + 4

  rows, cols = getmaxyx(win)

  col = (cols - width)/2
  row = (rows - height)/2

  frame = newwin(height, width, row, col)
  keypad frame, true
  box(frame, 0, 0)

  title = "[ #{title} ]"
  wmove(frame, 0, (width - title.size)/2)
  waddstr(frame, title)

  win = derwin(frame, text_height, text_width, 2, 2)
  wmove(win, 0, 0)
  waddstr(win, text)
  wnoutrefresh(win)
  wgetch(frame)
  flushinp
  delwin(win)
  delwin(frame)
end

def update_row_col(left_border, row, col)
  move(0, left_border)
  addstr("%03d:%003d" % [row + 1, col + 1])
  wnoutrefresh(stdscr)
end

@maximized = false
def toggle_maximize(term)
  # Maximize terminal window (xterm only).
  #
  # You can do the same with Alt-F10 in Gnome (and it seems more
  # reliable).
  CLib.fflush(term)

  # maximize
  CLib.fputs("\e[9;#{@maximized ? 0 : 1}t", term)
  CLib.fflush(term)

  @maximized = !@maximized
end

# Helper function to match charcodes or (single character) strings
# against keycodes returned by ncursesw.
#
# Note that this won't work for characters outside Latin-1 as they overlap numerically with
# ncurses's KEY_ codes. Should return new class for KEY_ codes.
#
def KEY(s)
  case s
  when String
    s.unpack("U")[0]
  else
    s
  end
end

def resize_terminal_window(rows, cols)
  print("\e[8;#{rows};#{cols};t") # set window size to rows x cols
  resizeterm(rows, cols)              # note: you need to tell ncurses that you've resized the terminal
end

def page_height
  LINES() - total_tb_border
end

def page_width
  COLS() - total_lr_border
end

def total_lr_border
  @left_border + @right_border
end

def total_tb_border
  @top_border + @bottom_border
end

def view(text, arg_rows = nil, arg_cols = nil)
  @top_border = @bottom_border = 1
  @left_border = @right_border = 1
  # set_escdelay(10) if respond_to?(:set_escdelay) # Centos 5.1 :S
  lines = text.lines.to_a
  maxx = lines.map{|x| x.size }.max + total_lr_border
  maxy = lines.size + total_tb_border

  # We need to open /dev/tty so we can read from STDIN without borking
  # ncurses
  term = CLib.fopen("/dev/tty", "rb+")
  screen = newterm(nil, term, term)
  old_screen = set_term(screen)

  # save original window size
  orig_rows, orig_cols = getmaxyx(stdscr)
  if arg_rows.nil?
    arg_rows = orig_rows
  end
  if arg_cols.nil?
    arg_cols = orig_cols
  end
  if arg_rows != orig_rows || arg_cols != orig_cols
    resize_terminal_window(arg_rows, arg_cols)
  end

  help_text = <<EOT
F1, ?       - Help
Home        - Beginning of file
End         - End of file
PgDn, space - Scroll down one page
PgUp        - Scroll up one page
Down arrow  - Scroll down one line
Up arrow    - Scroll up one line
Right arrow - Scroll right one column
Left arrow  - Scroll left one column
+/-         - Increase/decrease window size
^q, q, Esc  - Quit
EOT

  saved_exception = nil
  begin
    raw
    noecho
    curs_set 0
    pad = newpad(maxy, maxx)
    if has_colors
      start_color
      std_colors
    end
    keypad pad, true

    # just a bit of fun - format RDoc headers, comments and org-mode
    # header lines
    flag = false
    bg_flag = false
    attribute = 0
    lines.each do |line|
      if line =~ /^\s*[=*#]+/
        case line
        when /^\s*#/
          attribute = COLOR_PAIR(4)
        when /^\s*=+/
          # attribute = A_UNDERLINE
          wbkgdset(pad, A_REVERSE)
          wclrtoeol(pad)
          bg_flag = true
        when /^\s*\*/
          attribute = COLOR_PAIR(1)
        end
        # wchgat(pad, -1, A_REVERSE, COLOR_WHITE, nil)
        flag = true
        # wattron(pad, A_BOLD)
        wattron(pad, attribute)
      end
      rv = waddstr(pad, line)
      if flag
        flag = false
        wattroff(pad, attribute)
        if bg_flag
          wbkgdset(pad, A_NORMAL)
          wattroff(pad, A_BOLD)
        end
      end
      log :adding, line, :rv, rv
    end

    current_line = 0
    current_col  = 0

    redraw_background_frame
    update_row_col(@left_border, current_line, current_col)

    rv = pnoutrefresh(pad, current_line, current_col, @top_border, @left_border, page_height, page_width)
    log :prefresh1, :rv, rv
    doupdate

    # main loop
    while ch = wgetch(pad)
      log :ch, ch
      case ch
      when KEY_HOME
        current_line = 0
        current_col  = 0
      when KEY_END
        current_line = maxy - LINES() + total_lr_border
        current_col  = 0
      when KEY_NPAGE, KEY(' ')
        current_line = [current_line + page_height, [maxy - page_height, 0].max].min
      when KEY_PPAGE
        current_line = [current_line - page_height, 0].max
      when KEY_DOWN
        current_line = [current_line + 1, [maxy - page_height, 0].max].min
      when KEY_UP
        current_line = [current_line - 1, 0].max
      when KEY_RIGHT
        current_col = [current_col + 1, [maxx - page_width, 0].max].min
      when KEY_LEFT
        current_col = [current_col - 1, 0].max
      when KEY_F1, KEY('?')
        # Help
        show_text_window stdscr, "Help", help_text
        redraw_background_frame
      when KEY('f')
        toggle_maximize(term)
      when KEY('+')
        rows, cols = getmaxyx(stdscr)
        rows += 1
        cols += 1
        resize_terminal_window(rows, cols)
        redraw_background_frame
      when KEY('-')
        rows, cols = getmaxyx(stdscr)
        rows -= 1
        cols -= 1
        resize_terminal_window(rows, cols)
        redraw_background_frame
      when KEY_CTRL_Q, 'q'[0].ord, 27 # 27 == Esc
        # Quit
        delwin(pad)
        break
      when KEY_CTRL_C
        # for JRuby - Ctrl-C in cbreak mode is not trapped in rescue
        # below for some reason and so leaves the terminal in raw mode
        raise Interrupt
      when KEY_RESIZE, KEY_CTRL_L
        log :redraw2
        redraw_background_frame
      end

      update_row_col(@left_border, current_line, current_col)
      rv = pnoutrefresh(pad, current_line, current_col, @top_border, @left_border, page_height, page_width)
      log :prefresh2, :rv, rv, :line, current_line, :col, current_col
      doupdate
      flushinp
    end
  rescue Object => saved_exception
  ensure
    CLib.fclose(term) if !CLib.feof(term)
    flushinp
    end_rows, end_cols = getmaxyx(stdscr)
    endwin
    delscreen(screen)

    # restore terminal size at launch
    if end_rows != orig_rows || end_cols != orig_cols
      resizeterm(orig_rows, orig_cols)
      File.open("/dev/tty", "wb+") do |file|
        file.print("\e[8;#{orig_rows};#{orig_cols};t") # restore window
      end
    end
  end
  if saved_exception
    raise saved_exception
  end
end

def main
  require 'ostruct'
  require 'optparse'

  options = OpenStruct.new

  xopts = OptionParser.new do |opts|
    opts.on("-c", "--c COLS", Integer, "Resize screen to COLS width") do |cols|
      options.columns = cols
    end
    opts.on("-r", "--r ROWS", Integer, "Resize screen to ROWS height") do |rows|
      options.rows = rows
    end
  end

  xopts.parse!(ARGV)
  view(ARGF.read, options.rows, options.columns) # simplistic but works for demo

end

if __FILE__ == $0
  main
end
