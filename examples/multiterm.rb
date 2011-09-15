#!/usr/bin/env ruby
require 'ffi-ncurses'

# newterm2 - how to use more than one terminal at a time
#
# Note: ncurses knows nothing about your window manager so cannot
# switch window focus for you.
#
# This is how programmers used to do multi-screen - with more than one
# physical terminal. Typically, one would be used for input, the other
# for output.
#
# It might be useful for outputting debug info during a program for
# instance.

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
  attach_function :fdopen, [:int, :string], :FILEP
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
  attach_function :feof, [:FILEP], :int

  module FileExt
    def closed?
      CLib.feof(self) ? true : false
    end

    def close
      if closed?
        raise IOError, "closed stream"
      else
        CLib.fclose(self)
      end
    end
  end
end


def usage
  abort "usage: #{$0} term1 term2\ne.g. #{$0} /dev/pts/0 /dev/pts/1"
end

if ARGV.size != 2
  usage
end
term1 = ARGV[0]
term2 = ARGV[1]

if File.exist?(term1)
  term1_file = File.open(term1, "rb+")
  if !term1_file.tty?
    term1_file.close
    usage
  end
end

if File.exist?(term1)
  term2_file = File.open(term2, "rb+")
  if !term2_file.tty?
    term2_file.close
    term1_file.close
    usage
  end
end

begin
  tty1 = CLib.fdopen(term1_file.fileno, "rb+")
  tty1.extend(CLib::FileExt)
  tty2 = CLib.fdopen(term2_file.fileno, "rb+")
  tty2.extend(CLib::FileExt)
  screen1 = FFI::NCurses.newterm(nil, tty1, tty1)
  screen2 = FFI::NCurses.newterm(nil, tty2, tty2)
  FFI::NCurses.noecho
  [[screen1, "Hello"], [screen2, "World"]].each do |screen, text|
    old_screen = FFI::NCurses.set_term(screen)
    FFI::NCurses.curs_set(0)
    FFI::NCurses.border(*([0]*8))
    FFI::NCurses.move(4, 4)
    FFI::NCurses.addstr(text)
    FFI::NCurses.refresh
    FFI::NCurses.flushinp
  end
  FFI::NCurses.set_term(screen1)
  FFI::NCurses.curs_set(1)
  FFI::NCurses.getch
rescue => e
  log :e1, e
ensure
  begin
    # Watch the ordering of these calls, i.e. do not call delscreen
    # before endwin
    FFI::NCurses.flushinp
    FFI::NCurses.echo

    # close each terminal
    [screen2, screen1].each do |screen|
      FFI::NCurses.set_term(screen)
      FFI::NCurses.endwin
      FFI::NCurses.delscreen(screen)
    end
  rescue => e
    log :e2, e
  ensure
    # [tty2, tty1] do |fd|
    #   CLib.fclose(fd)
    # end
    [tty2, tty1, term2_file, term1_file].each do |fd|
      fd.close if !fd.closed? # handle case where tty1 == tty2
    end
  end
end
