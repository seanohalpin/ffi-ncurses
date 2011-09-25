#!/usr/bin/env ruby
require 'ffi-ncurses'

include FFI::NCurses

module CLib
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  # FILE* open and close
  typedef :pointer, :FILEP
  attach_function :fdopen, [:int, :string], :FILEP
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
end

# This is the version from NCURSES HOWTO
def do_cmd(cmd)
  def_prog_mode              # Save the tty modes
  endwin                     # End curses mode temporarily
  system(cmd)                # Do whatever you like in cooked mode
  reset_prog_mode            # Return to the previous tty mode
  refresh                    # Do refresh() to restore the
                             # Screen contents
                             # stored by def_prog_mode()
end

# This is the version from ncurses examples filter.c
def do_cmdx(cmd)
  reset_shell_mode           # Restore terminal mode
  STDOUT.flush
  system(cmd)                # Do whatever you like in cooked mode
  reset_prog_mode            # Return to the previous tty mode
  touchwin(stdscr)
  # erase
  refresh
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

def main
  begin
    # input = CLib.fdopen(STDIN.fileno, "rb+")
    # output = CLib.fdopen(STDOUT.fileno, "rb+")
    # screen = newterm(nil, output, input)
    # set_term(screen)

    initscr
    keypad stdscr, true
    noecho

    addstr("Hello from ncurses\n")
    refresh
    addstr("Press any key to enter shell\n")
    getch
    addstr("Now entering shell - enter 'exit' or press Ctrl-D to exit\n")
    refresh
    sleep 0.2

    cmd = ARGV[0] || "/bin/sh"
    do_cmd(cmd)
    flushinp
    show_text_window(stdscr, "Message", "Back to ncurses\nPress any key to quit")
    refresh
  ensure
    flushinp
    endwin
    # delscreen(screen)
  end
end

main
