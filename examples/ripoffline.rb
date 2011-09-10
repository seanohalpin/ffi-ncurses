#!/usr/bin/env ruby
require 'ffi-ncurses'

# how to use ripoffline

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

# this works
# module FFI
#   module NCurses
#     callback :ripoffline_callback, [:pointer, :int], :int
#     attach_function :ripoffline, [:int, :ripoffline_callback], :int
#   end
# end

# works
ripoffCallback = Proc.new do |win, cols|
  FFI::NCurses.wbkgd(win, FFI::NCurses::A_REVERSE)
  FFI::NCurses.werase(win)

  FFI::NCurses.wmove(win, 0, 0)
  FFI::NCurses.waddstr(win, "ripoff: window %s, %d columns %s" % [win.to_s, cols, Time.now])
  FFI::NCurses.wnoutrefresh(win)
  Thread.start do
    loop do
      FFI::NCurses.wmove(win, 0, 0)
      FFI::NCurses.waddstr(win, "ripoff: window %s, %d columns %s" % [win.to_s, cols, Time.now])
      FFI::NCurses.wnoutrefresh(win)
      sleep 1
    end
  end
  FFI::NCurses::OK
end

callback = FFI::Function.new(:int, [:pointer, :int], &ripoffCallback)

begin
  #FFI::NCurses.ripoffline(-1, RipoffCallback) # works
  FFI::NCurses.ripoffline(1, callback) #
  FFI::NCurses.ripoffline(-1, callback) #
  FFI::NCurses.initscr
  FFI::NCurses.noecho
  FFI::NCurses.clear
  FFI::NCurses.border(*([0]*8))
  FFI::NCurses.move(4, 4)
  FFI::NCurses.addstr("Hello")
  FFI::NCurses.refresh
  FFI::NCurses.getch
  FFI::NCurses.flushinp
  FFI::NCurses.addstr("World")
  FFI::NCurses.refresh
  FFI::NCurses.getch
rescue => e
  FFI::NCurses.flushinp
  FFI::NCurses.echo
  FFI::NCurses.endwin
  log :e1, e
  raise
ensure
  begin
    FFI::NCurses.flushinp
    FFI::NCurses.echo
    FFI::NCurses.endwin
  rescue => e
    log :e2, e
  end
end
