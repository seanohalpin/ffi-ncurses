#!/usr/bin/env ruby
require 'ffi-ncurses'

# newterm2 - how to use newterm to emulate initscr (see also newterm.rb)

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

module CLib
  extend FFI::Library
  LIB_HANDLE = ffi_lib("c")
  # FILE* open and close
  typedef :pointer, :FILEP
  attach_function :fdopen, [:int, :string], :FILEP
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
end

begin
  input = CLib.fdopen(STDIN.fileno, "rb+")
  output = CLib.fdopen(STDOUT.fileno, "rb+")
  screen = FFI::NCurses.newterm(nil, output, input)
  old_screen = FFI::NCurses.set_term(screen)
  FFI::NCurses.noecho
  FFI::NCurses.border(*([0]*8))
  FFI::NCurses.move(4, 4)
  FFI::NCurses.addstr("Hello")
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
  rescue => e
    log :e2, e
  end
end
