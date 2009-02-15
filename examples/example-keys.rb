require 'ffi-ncurses'
include FFI::NCurses
begin
  initscr
  raw
  keypad stdscr, 1
  noecho
  curs_set 0
  ch = 0
  while ch != 27
    clear
    addstr "Press any key (Escape to exit): "
    printw "%d %c", :int, ch, :int, ch
    refresh
    ch = getch
  end
ensure
  endwin
end
