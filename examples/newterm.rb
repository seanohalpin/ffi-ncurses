#!/usr/bin/env ruby
require 'ffi-ncurses'

# newterm - how to read STDIN and do ncurses at the same time
# See ncurses FAQ http://invisible-island.net/ncurses/ncurses.faq.html "Problems with output buffering"

# Call like this:
#
#     $ echo hello|ruby newterm.rb
#
# or
#
#     $ ruby newterm.rb < input.txt
#
# otherwise the program will stall.

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

module CLib
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  # FILE* open and close
  typedef :pointer, :FILEP
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
end

begin
  term = CLib.fopen("/dev/tty", "rb+")
  screen = FFI::NCurses.newterm(nil, term, term)
  old_screen = FFI::NCurses.set_term(screen)
  FFI::NCurses.noecho
  FFI::NCurses.clear
  FFI::NCurses.move 1, 1
  FFI::NCurses.addstr("Press any key to continue")
  FFI::NCurses.move 3, 1
  FFI::NCurses.addstr(STDIN.read(3))
  FFI::NCurses.refresh
  FFI::NCurses.flushinp
  FFI::NCurses.getch
  FFI::NCurses.addstr(STDIN.read)
  FFI::NCurses.move 5, 1
  FFI::NCurses.addstr("Press any key to continue")
  FFI::NCurses.refresh
  FFI::NCurses.flushinp
  FFI::NCurses.getch
rescue => e
  log :e1, e
ensure
  begin
    # Watch the ordering of these calls, i.e. do not call delscreen
    # before endwin
    FFI::NCurses.flushinp
    FFI::NCurses.echo
    FFI::NCurses.endwin
    FFI::NCurses.delscreen(screen)
    CLib.fclose(term)
  rescue => e
    log :e2, e
  end
end
