require 'ffi-ncurses'
begin	
  # the methods can be called as module methods
  NCurses.initscr
  NCurses.clear
  NCurses.printw("Hello world!")
  NCurses.refresh
  NCurses.getch
  NCurses.endwin

  # or as included methods
  include NCurses
  initscr
  start_color
  curs_set 0
  raw
  cbreak
  noecho
  clear
  move 10, 10
  standout
  printw("Hi!")
  standend

  init_pair(1, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  init_pair(2, NCurses::Colour::RED, NCurses::Colour::BLACK)
  init_pair(3, NCurses::Colour::GREEN, NCurses::Colour::BLACK)
  init_pair(4, NCurses::Colour::YELLOW, NCurses::Colour::BLACK)
  init_pair(5, NCurses::Colour::BLUE, NCurses::Colour::BLACK)
  init_pair(6, NCurses::Colour::MAGENTA, NCurses::Colour::BLACK)
  init_pair(7, NCurses::Colour::CYAN, NCurses::Colour::BLACK)
  init_pair(8, NCurses::Colour::WHITE, NCurses::Colour::BLACK)

  init_pair(9, NCurses::Colour::BLACK, NCurses::Colour::BLACK)
  init_pair(10, NCurses::Colour::BLACK, NCurses::Colour::RED)
  init_pair(11, NCurses::Colour::BLACK, NCurses::Colour::GREEN)
  init_pair(12, NCurses::Colour::BLACK, NCurses::Colour::YELLOW)
  init_pair(13, NCurses::Colour::BLACK, NCurses::Colour::BLUE)
  init_pair(14, NCurses::Colour::BLACK, NCurses::Colour::MAGENTA)
  init_pair(15, NCurses::Colour::BLACK, NCurses::Colour::CYAN)
  init_pair(16, NCurses::Colour::BLACK, NCurses::Colour::WHITE)
  
  1.upto(16) do |i|
    attr_set NCurses::A_NORMAL, i, 0
    addch (?A - 1 + i)
  end
  attr_set NCurses::A_HORIZONTAL, 0, 0
  addch (?Z | COLOR_PAIR(3))
  attr_set A_BOLD, 2, 0
  addch ?S

  refresh
  ch = getch
  endwin

  initscr
  curs_set 0
  raw
  cbreak
  noecho
  win = newwin(6, 12, 15, 15)
  box(win, 0, 0)
  inner_win = newwin(4, 10, 16, 16)
  waddstr(inner_win, (["Hello window!"] * 5).join(' '))
  wrefresh(win)
  wrefresh(inner_win)
  ch = wgetch(inner_win)

rescue Object => e
  NCurses.endwin
  puts e
ensure
  NCurses.endwin
  NCurses.class_eval {
    require 'pp'
    pp @unattached_functions

  }
end
