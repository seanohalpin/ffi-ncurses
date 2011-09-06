#!/usr/bin/env ruby
# encoding: UTF-8
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-29

require 'ffi-ncurses'

include FFI::NCurses

def clip(value, max)
  (value + max) % max
end

def log(txt)
  File.open("ncurses.log", "a") do |file|
    file.puts(txt)
  end
end

def chtype(s, attr = 0)
  if s.kind_of?(String)
    s[0].ord
  else
    s
  end | attr
end

class ChType
  attr_accessor :char, :attr, :color
  def initialize(char = " ", attr = 0, color = 0)
    if char.kind_of?(String)
      from_args(char, attr, color)
    else
      from_chtype(char)
    end
  end
  def from_args(char, attr, color)
    @char, @attr, @color = char.unpack("U")[0], attr, color
  end
  def to_chtype
    @char | @attr | @color
  end
  def to_s
    [@char].pack("U")
  end
  def from_chtype(chtype)
    @char = chtype & A_CHARTEXT
    @attr = chtype & A_ATTRIBUTES
    @color = chtype & A_COLOR
  end
end

def save_excursion(win, &block)
  y, x = getyx(win)
  block.call
  move(y, x)
end

class CCharT < FFI::Struct
  layout \
  :attr, :uint,
  :chars, [:ushort, 5]
end

#p FFI.find_type(:uint)
#p FFI.find_type(:ushort)

# cchar = CCharT.new
# cchar[:attr] = 0
# cchar[:chars][0] = 0
# cchar[:chars].each_with_index do |e, i|
#   p cchar[:chars][i]
# end
# exit

begin
  # standard preamble
  initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0

  # initialize colour
  start_color

  # set up colour pairs
  # TODO: check that these are standard combinations
  # TODO: extend to 256 colours
  #             Background       Foreground
  init_pair(0,  Colour::BLACK,   Colour::BLACK)
  init_pair(1,  Colour::RED,     Colour::BLACK)
  init_pair(2,  Colour::GREEN,   Colour::BLACK)
  init_pair(3,  Colour::YELLOW,  Colour::BLACK)
  init_pair(4,  Colour::BLUE,    Colour::BLACK)
  init_pair(5,  Colour::MAGENTA, Colour::BLACK)
  init_pair(6,  Colour::CYAN,    Colour::BLACK)
  init_pair(7,  Colour::WHITE,   Colour::BLACK)

  init_pair(8,  Colour::BLACK,   Colour::BLACK)
  init_pair(9,  Colour::BLACK,   Colour::RED)
  init_pair(10, Colour::BLACK,   Colour::GREEN)
  init_pair(11, Colour::BLACK,   Colour::YELLOW)
  init_pair(12, Colour::BLACK,   Colour::BLUE)
  init_pair(13, Colour::BLACK,   Colour::MAGENTA)
  init_pair(14, Colour::BLACK,   Colour::CYAN)
  init_pair(15, Colour::BLACK,   Colour::WHITE)

  # init
  win = stdscr
  box(win, 0, 0)
  wrefresh(win)

  ch = 0
  buffer = FFI::MemoryPointer.new(:pointer, 2)
  cchar = WinStruct::CCharT.new
  cchar[:attr] = 0
  # 0.upto(cchar[:chars].size - 1) do |i|
  #   cchar[:chars][i] = 0
  # end

  while ch != KEY_CTRL_Q
    # read a Unicode character
    rv = wget_wch(win, buffer)
    ch = buffer.read_int
    # log "rv=#{rv} ch=#{ch}"

    case ch
    when KEY_CTRL("Q")
      break
    else
      # output using non-widechar routines
      char = chtype(ch, COLOR_PAIR(7) | A_BOLD)
      waddch win, char
      waddch win, 32

      # output a wide character (i.e. Unicode)
      cchar[:attr] = COLOR_PAIR(6) | A_BOLD
      cchar[:chars][0] = ch
      # cchar[:chars][1] = 0

      wadd_wch win, cchar
      waddch win, 32

      # output skull (how to output a Unicode character)
      cchar[:attr] = COLOR_PAIR(7) | A_BOLD
      cchar[:chars][0] = 0x2620 # ☠
      wadd_wch win, cchar
      waddch win, 32

      char = ChType.new(char)
      waddstr win, "ch=#{ch} #{char.inspect}\n"
    end
    wrefresh(win)
  end
ensure
  endwin
end

