require 'ffi-ncurses'
include NCurses
begin
  stdscr = initscr
  raw
  keypad stdscr, 1
  noecho
  curs_set 0
  ch = 0
  while ch != 27
    clear
    addstr "Press any key (Escape to exit): "
    printw "%d", :int, ch
    refresh
    ch = getch
  end
ensure
  endwin
end
