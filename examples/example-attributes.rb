require 'ffi-ncurses'
include NCurses
initscr
begin
  attr_set A_BOLD, 0, nil
  addstr "THIS IS BOLD"
  attr_set A_NORMAL, 0, nil
  addstr "THIS IS NORMAL"

  refresh
  ch = getch
ensure
  endwin
end
