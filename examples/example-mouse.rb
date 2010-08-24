#!/usr/bin/env ruby
#
# Sean O'Halpin, 2009-02-15
#
require 'ffi-ncurses'
require 'ffi-ncurses/mouse'
require 'ffi-ncurses/ord-shim'  # for 1.8.6 compatibility

include FFI::NCurses

begin
  initscr
  clear
  noecho
  cbreak
  keypad stdscr, FFI::NCurses::TRUE

  # Get all the mouse events
  mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, nil)
  mouse_event = MEVENT.new
  ch = 0
  addstr "Click mouse buttons anywhere on the screen. q to quit\n"
  until ch == "q"[0].ord do
    ch = getch
    case ch
    when KEY_MOUSE
      if getmouse(mouse_event) == OK
        if FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 1) > 0
          addstr "Button 1 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
        elsif FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 2) > 0
          addstr "Button 2 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
        elsif FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 3) > 0
          addstr "Button 3 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
        else
          addstr "Other mouse event %x" % mouse_event[:bstate]
        end
        row = getcury(stdscr) + 1
        move row, 0
        move mouse_event[:y], mouse_event[:x]
        addch " "[0].ord | WA_STANDOUT
        move row, 0
      end
    else
      printw "other event (%lu)", :ulong, ch
      addstr "\n"
    end
    refresh
  end
ensure
  endwin
end
