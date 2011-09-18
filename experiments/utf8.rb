#!/usr/bin/env ruby
# -*- coding: utf-8; -*-
#
# Note: terminal set to:
#     LANG=en_GB.utf8
#
# Sean O'Halpin, 2010-08-29

require 'ffi-ncurses'

include FFI::NCurses

# Helper function to match charcodes or (single character) strings
# against keycodes returned by ncursesw.
#
# Note that this won't work for characters outside Latin-1 as they overlap numerically with
# ncurses's KEY_ codes. Should return new class for KEY_ codes.
#

def KEY(s)
  case s
  when String
    s.unpack("U")[0]
  else
    s
  end
end

begin
  # standard preamble
  initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0

  # init
  win = stdscr
  wrefresh(win)

  buffer = FFI::MemoryPointer.new(:pointer, 2)
  cchar = WinStruct::CCharT.new

  ch = 0
  waddstr win, "Press Ctrl-Q to quit\n"
  #
  # If you're using libncursesw, you can simply print UTF-8 strings
  # using the normal ncurses functions.
  #
  # But this won't work in libncurses. Instead you'll get something like:
  #     Pound sterling: M-BM-# and a skull: M-b~XM-
  #
  # handle = LIB_HANDLE.find_symbol("acs_map")
  #boxchar = acs_map.get_array_of_int('l'[0].ord, 1).first
  #chars = acs_map.get_array_of_int(0, 128)
  #boxchar = 4194412
  waddstr win, "Pound sterling: € and a skull: ☠\n"
  waddstr win, "acs_map\n"
  # waddch win, '['.ord
  ('a'..'z').each do |c|
    waddstr win, "%s : " % [c]
    waddch win, acs_map[c.ord]
    waddstr win, "\n"
  end

  waddstr win, "wave: "
  wave = "oprsrp" * 5
  wave.each_char do |c|
    waddch win, acs_map[c.ord]
  end
  waddstr win, "\n"

  # output a wide character using UTF-8
  cchar[:attr] = A_UNDERLINE

  utf8 = "£"
  # p [:utf8, utf8]

  if respond_to?(:wadd_wch)
    # this works
    utf8.codepoints.each_with_index do |c, i|
      cchar[:chars][i] = c
    end
    cchar[:chars][utf8.codepoints.to_a.size] = 0 # need to terminate sequence
    # p [cchar[:chars][0], cchar[:chars][1], cchar[:chars][2], cchar[:chars][3], cchar[:chars][4]]
    waddstr win, "cchar: #{cchar[:chars].to_a.inspect}\n"
    waddstr win, "1 [ "
    wadd_wch win, cchar
    waddstr win, " ]\n"

    # this doesn't work (i.e. you can't output unpacked UTF8 with wadd_wch)
    utf8_unpacked = utf8.unpack("C*")
    utf8_unpacked.each_with_index do |c, i|
      cchar[:chars][i] = c
    end
    cchar[:chars][utf8_unpacked.size] = 0 # need to terminate sequence
    # p [cchar[:chars][0], cchar[:chars][1], cchar[:chars][2], cchar[:chars][3], cchar[:chars][4]]
    waddstr win, "cchar: #{cchar[:chars].to_a.inspect}\n"
    waddstr win, "1.1 [ "
    wadd_wch win, cchar
    waddstr win, " ]\n"

    # this works
    waddstr win, "2 [ "
    utf8.unpack("C*").each do |c|
      waddch win, c | A_REVERSE
    end
    waddstr win, " ]\n"

    # this works
    waddstr win, "2 [ "
    "こ".unpack("C*").each do |c|
      waddch win, c | A_REVERSE
    end
    waddstr win, " ]\n"

    # and so does this
    unicode = "£".unpack("U")[0]
    cchar[:attr] = COLOR_PAIR(1) | A_BOLD
    cchar[:chars][0] = unicode
    cchar[:chars][1] = 0 # need to terminate sequence
    #p [cchar[:chars][0], cchar[:chars][1], cchar[:chars][2], cchar[:chars][3], cchar[:chars][4]]
    waddstr win, "cchar: #{cchar[:chars].to_a.inspect}\n"
    waddstr win, "3 [ "
    wadd_wch win, cchar
    waddstr win, " ]\n"
  end

  # See http://doc.cat-v.org/plan_9/4th_edition/papers/utf
  waddstr win, "Καλημέρα κόσμε\n"
  waddstr win, "こんにちは 世界\n"

  wrefresh(win)
  ch = getch
ensure
  endwin
end

