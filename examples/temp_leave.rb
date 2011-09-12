#!/usr/bin/env ruby
require 'ffi-ncurses'

include FFI::NCurses

module CLib
  extend FFI::Library
  LIB_HANDLE = ffi_lib("c")
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
def do_cmd(cmd)
  reset_shell_mode           # Restore terminal mode
  STDOUT.flush
  system(cmd)                # Do whatever you like in cooked mode
  reset_prog_mode            # Return to the previous tty mode
  touchwin(stdscr)
  # erase
  refresh
end

def main
  begin
    # input = CLib.fdopen(STDIN.fileno, "rb+")
    # output = CLib.fdopen(STDOUT.fileno, "rb+")
    # screen = newterm(nil, output, input)
    # set_term(screen)

    initscr
    keypad stdscr, true

    addstr("Hello from ncurses\n")
    addstr("Now entering shell - enter 'exit' or press Ctrl-D to exit\n")
    refresh

    do_cmd("/bin/sh")
    flushinp
    addstr("Back to ncurses\n")
    addstr("Press any key to quit\n")
    refresh
    getch                             # Pause so we see the string added
  ensure
    flushinp
    endwin
    # delscreen(screen)
  end
end

main
