#!/usr/bin/env ruby
# encoding: UTF-8
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-20

require 'ffi-ncurses'

class Console
  include FFI::NCurses

  attr_accessor :win

  def initialize
    # standard NCurses preamble
    initscr
    raw
    keypad stdscr, FFI::NCurses::TRUE
    noecho
    curs_set 0
    @win = stdscr

    at_exit { reset }
  end

  def reset
    endwin
  end

  def cursor=(tf)
    curs_set tf ? 1 : 0
  end

  # output
  def refresh
    wrefresh(@win)
  end

  def clear
    wclear(@win)
  end

  def []=(x, y, c)
    mvwaddstr win, y, x, normalize(c)
  end

  def put(str)
    log "str=#{str.inspect}"
    log "str'=#{str.inspect}"
    waddstr(@win, normalize(str))
  end

  def move(x, y)
    wmove(@win, y, x)
  end

  # input
  def get
    # should convert to string
    # and use 'standard' names for function keys, etc.
    wgetch(@win)
  end

  # query state
  def xy
    # getyx returns [y, x]
    # NCurses.getyx(@win).reverse
    [getcurx(win), getcury(win)]
  end

  def x
    getcurx(@win)
  end

  def y
    getcury(@win)
  end

  def save(&block)
    saved_xy = xy
    block.call
    move *saved_xy
  end

  private
  def normalize(char)
    if !char.kind_of?(String)
      char = char.chr
    end
    char
  end

end

# utils
def clip(value, max)
  (value + max) % max
end

def log(txt)
  File.open("log.log", "a") do |file|
    file.puts(txt)
  end
end

console = Console.new
console.cursor = true

begin
  console[10, 2] = "Hello"
  console.refresh
  sleep 1
  console.clear
  console.move 1, 1
  while ch = console.get
    # log "ch=#{ch}"
    case ch
    when Console::KEY_CTRL_Q
      log "Ctrl-Q: #{ch.inspect} #{ch.chr}"
      break
    when Console::KEY_RETURN
      console.move 1, console.y + 1
    else
      if ch <= 255
        console.put ch
      end
    end
    # xy = console.xy
    # console[1, 0] = console.xy.inspect + "   "
    # console.move *xy

    console.save do
      console[1, 0] = console.xy.inspect + "   "
    end
    console.refresh

  end
end

