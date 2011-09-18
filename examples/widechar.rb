#!/usr/bin/env ruby
# encoding: UTF-8
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-29

require 'ffi-ncurses'

include FFI::NCurses

module CLib
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  typedef :pointer, :FILEP
  # FILE* open, close and eof
  attach_function :fopen, [:string, :string], :FILEP
  attach_function :fclose, [:FILEP], :int
  attach_function :feof, [:FILEP], :int
  attach_function :fflush, [:FILEP], :int
  attach_function :fputs, [:string, :FILEP], :int
end

$APP_DEBUG = ARGV.delete("--debug")

# def log(*a)
#   STDERR.puts a.inspect if $APP_DEBUG
# end

def log(*a)
  if $APP_DEBUG
    File.open("log.txt", "ab") do |file|
      file.puts a.inspect
    end
  end
end

def line(row, txt = nil)
  move row, 2
  if txt
    addstr(txt)
  end
end

def column(col, txt = nil)
  y, x = getyx(stdscr)
  move y, col
  if txt
    addstr(txt)
  end
end

def can_use_widechars?
  RUBY_VERSION >= '1.9.0' || (Object.const_defined?(:RUBY_ENGINE) && RUBY_ENGINE == "jruby")
end

$APP_FORCE_WIDECHARS    = ARGV.delete("--widechars")    ? true : false
$APP_FORCE_NO_WIDECHARS = ARGV.delete("--no-widechars") ? true : false
def use_widechars?
  if $APP_FORCE_NO_WIDECHARS
    false
  else
    $APP_FORCE_WIDECHARS || can_use_widechars?
  end
end

def getkey(win, input_buffer)
  if use_widechars?
    log :wget_wch
    # 1.8.x stalls in this function
    rv = FFI::NCurses.wget_wch(win, input_buffer)
    log :rv, rv
    ch = input_buffer.read_int # assumes wint_t is an int (which in all cases I've seen it is...)
    log :ch, ch

    # if a key code, return as is
    if rv == KEY_CODE_YES
      fkey = true
    else
      fkey = false
    end
  else
    ch = FFI::NCurses.wgetch(win)
    if (KEY_CODE_YES..KEY_MAX).include?(ch)
      fkey = true
    else
      fkey = false
    end
  end
  # convert to UTF-8 string
  char = [ch].pack("U")
  [fkey, ch, char]
end

begin
  # standard preamble

  #initscr

  term = CLib.fopen("/dev/tty", "rb+")
  screen = newterm(nil, term, term)
  old_screen = set_term(screen)

  raw
  keypad stdscr, true

  # for 1.8.7
  # notimeout stdscr, true
  # typeahead(-1)
  # meta(stdscr, true)

  # set_escdelay(100)
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

  if !can_use_widechars? && use_widechars?
    attr_on(A_REVERSE, nil)
    mvaddstr 10, 6, " WARNING: wget_wch doesn't work with MRI 1.8.x   "
    mvaddstr 11, 6, " If your keyboard gets stuck, press an arrow key "
    mvaddstr 12, 6, " then Ctrl-Q to quit                             "
    mvaddstr 13, 6, "                                                 "
    mvaddstr 14, 6, " Press any key to continue                       "
    attr_off(A_REVERSE, nil)
    getch
    clear
  end

  box(stdscr, 0, 0)
  line 1, "Press any key to display codes in various interpretations"
  line 2, "Press Ctrl-Q to quit"
  if !use_widechars?
    attr_on(A_REVERSE, nil)
    line 3, "Unicode input turned off"
    attr_off(A_REVERSE, nil)
  end

  wrefresh(stdscr)

  ch = 0
  buffer = FFI::Buffer.new(FFI::NCurses.find_type(:wint_t))
  log :buffer_size, buffer.size, FFI.find_type(:int).size
  cchar = WinStruct::CCharT.new
  cchar[:attr] = 0

  char_col = 50

  input_buffer = FFI::Buffer.new(FFI::NCurses.find_type(:wint_t))
  while ch != KEY_CTRL_Q
    # read a Unicode character

    # log :wget_wch
    # # 1.8.x stalls in this function
    # rv = FFI::NCurses.wget_wch(win, input_buffer)
    # log :rv, rv
    # ch = input_buffer.read_int # assumes wint_t is an int (which in all cases I've seen it is...)
    # log :ch, ch

    # # if a key code, return as is
    # if rv == KEY_CODE_YES
    #   fkey = true
    # else
    #   fkey = false
    # end
    # # convert to UTF-8 string
    # char = [ch].pack("U")

    fkey, ch, char = getkey(win, buffer)

    clear
    box(stdscr, 0, 0)

    line 1, "Press any key to display codes in various interpretations"
    line 2, "Press Ctrl-Q to quit"
    if !use_widechars?
      attr_on(A_REVERSE, nil)
      line 3, "Unicode input turned off"
      attr_off(A_REVERSE, nil)
    end

    if fkey
      attr_on(A_BOLD, nil)
    end
    line 4, "#{fkey ? "Function" : "Normal  "} key - keycode: [#{ch} #{"0x%04x" % ch}]"
    line 5, "keyname: "
    column char_col, "[#{keyname(ch)}]"
    line 6, "key_name: "
    column char_col, "[#{key_name(ch)}]"
    if fkey
      attr_off(A_BOLD, nil)
    end

    line 7, "output raw keycode using non-widechar routines:"
    column char_col, "["
    waddch win, char[0].ord
    addstr "]"

    line 8, "output UTF-8 using non-widechar routines:"
    column char_col, "["
    attr_on(COLOR_PAIR(5) | A_BOLD, nil)
    waddstr win, char
    attr_off(COLOR_PAIR(5) | A_BOLD, nil)
    addstr "]"

    line 9, "output Unicode character using wadd_wch:"
    cchar[:attr] = COLOR_PAIR(6) | A_BOLD
    cchar[:chars][0] = ch # ch == Unicode codepoint
    column char_col, "["
    wadd_wch win, cchar
    addstr "]"

    wrefresh(win)
  end
rescue => saved_exception
ensure
  CLib.fclose(term) if !CLib.feof(term)
  flushinp
  endwin
  delscreen(screen)

  # endwin
end
if saved_exception
  raise saved_exception
end
