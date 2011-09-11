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
$ripoffwin = nil
ripoffCallback = Proc.new do |win, cols|
  $ripoffwin = win
  FFI::NCurses.wbkgd(win, FFI::NCurses::A_REVERSE)
  FFI::NCurses.werase(win)

  FFI::NCurses.wmove(win, 0, 0)
  FFI::NCurses.waddstr(win, "ripoff: window %s, %d columns %s" % [win.to_s, cols, Time.now])
  FFI::NCurses.wnoutrefresh(win)
  Thread.start do
    # FFI::NCurses.immedok(win)
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

def get_cmd
  while (ch = FFI::NCurses.getch) == FFI::NCurses::ERR
    sleep(0.1) # this has better performance than using halfdelay
    FFI::NCurses.wrefresh($ripoffwin)
  end
  ch
end

begin
  #FFI::NCurses.ripoffline(-1, RipoffCallback) # works
  FFI::NCurses.ripoffline(1, callback)  # rip line off top
  FFI::NCurses.ripoffline(-1, callback) # rip line off bottom
  FFI::NCurses.initscr
  # FFI::NCurses.halfdelay(1)
  FFI::NCurses.nodelay(FFI::NCurses.stdscr, true) # v. expensive in CPU (unless we sleep as above)
  FFI::NCurses.noecho
  FFI::NCurses.clear
  FFI::NCurses.border(*([0]*8))
  FFI::NCurses.move(4, 4)
  FFI::NCurses.addstr("Hello")
  FFI::NCurses.refresh
  # FFI::NCurses.getch
  get_cmd
  FFI::NCurses.flushinp
  FFI::NCurses.addstr("World")
  FFI::NCurses.refresh
  get_cmd
  #FFI::NCurses.getch
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
