#!/usr/bin/env ruby
# encoding: UTF-8
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-29

require 'ffi-ncurses'

include FFI::NCurses

def log(txt)
  File.open("ncurses.log", "a") do |file|
    file.puts(txt)
  end
end

# Return one key from the keyboard.
# If a Unicode character, then convert to UTF-8.
# If an extended key, then return ncurses KEY_ code.
def getkey(win)
  input_buffer = FFI::Buffer.new(FFI::NCurses.find_type(:wint_t))
  rv = FFI::NCurses.wget_wch(win, input_buffer)
  ch = input_buffer.read_int # assumes wint_t is an int (which in all cases I've seen it is...)
  # if a key code, return as is
  if rv == KEY_CODE_YES
    ch
  else
    # else convert to UTF-8 string
    [ch].pack("U")
  end
end

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
  #             Background      Foreground
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

  # init
  win = stdscr
  box(stdscr, 0, 0)
  mvaddstr 1, 2, "Press any key to display codes in various interpretations"
  mvaddstr 2, 2, "Press Ctrl-Q to quit"

  wrefresh(stdscr)

  ch = 0
  # buffer = FFI::MemoryPointer.new(:pointer, 2)
  buffer = FFI::Buffer.new(FFI::NCurses.find_type(:wint_t))
  cchar = WinStruct::CCharT.new
  cchar[:attr] = 0
  # 0.upto(cchar[:chars].size - 1) do |i|
  #   cchar[:chars][i] = 0
  # end

  char_col = 50

  input_buffer = FFI::Buffer.new(FFI::NCurses.find_type(:wint_t))
  while ch != KEY_CTRL_Q
    # read a Unicode character

    rv = FFI::NCurses.wget_wch(win, input_buffer)
    ch = input_buffer.read_int # assumes wint_t is an int (which in all cases I've seen it is...)
    # if a key code, return as is
    if rv == KEY_CODE_YES
      fkey = true
    else
      fkey = false
    end
    # convert to UTF-8 string
    char = [ch].pack("U")

    clear
    box(stdscr, 0, 0)

    mvaddstr 1, 2, "Press any key to display codes in various interpretations"
    mvaddstr 2, 2, "Press Ctrl-Q to quit"

    move 4, 2
    if fkey
      attr_on(A_BOLD, nil)
    end
    addstr "#{fkey ? "Function" : "Normal  "} key - keycode: [#{ch}] name: #{keyname(ch)}"
    if fkey
      attr_off(A_BOLD, nil)
    end

    move 5, 2
    addstr "output raw keycode using non-widechar routines:"
    mvaddstr 5, char_col, "["
    waddch win, char[0].ord
    addstr "]"

    move 6, 2
    addstr "output UTF-8 using non-widechar routines:"
    mvaddstr 6, char_col, "["
    attr_on(COLOR_PAIR(5) | A_BOLD, nil)
    waddstr win, char
    attr_off(COLOR_PAIR(5) | A_BOLD, nil)
    addstr "]"

    move 7, 2
    addstr "output Unicode character using wadd_wch:"
    cchar[:attr] = COLOR_PAIR(6) | A_BOLD
    cchar[:chars][0] = ch # ch == Unicode codepoint
    mvaddstr 7, char_col, "["
    wadd_wch win, cchar
    addstr "]"

    wrefresh(win)
  end
ensure
  endwin
end

