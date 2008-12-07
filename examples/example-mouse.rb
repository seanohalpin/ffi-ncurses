require 'ffi-ncurses'
require 'ffi-ncurses-mouse'

include NCurses

  begin
    initscr
    clear
    noecho
    cbreak
    keypad stdscr, NCurses::TRUE

    # Get all the mouse events
    mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, nil)
    mouse_event = NCurses::MEVENT.new
    ch = 0
    until ch == 113 do
      ch = getch
      case ch
      when NCurses::KEY_MOUSE
        if getmouse(mouse_event) == NCurses::OK
          if mouse_event[:bstate] & NCurses::BUTTON1_PRESSED
#          if NCurses.BUTTON_PRESS(mouse_event[:bstate], 1)
            addstr "Button 1 pressed (%d, %d)" % [mouse_event[:y], mouse_event[:x]]
          else
            addstr "Other button pressed"
          end
          row = getcury(stdscr) + 1
          move row, 0
          move mouse_event[:y], mouse_event[:x]
          addch " "[0] | NCurses::WA_STANDOUT
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
