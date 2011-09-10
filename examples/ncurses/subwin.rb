#!/usr/bin/env ruby

require "ncurses"

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

module WindowExtensions
  extend self

  def title(win, str)
    str = "[ #{str} ]"
    xpos = (win.getmaxx - str.size)/2
    win.mvaddstr(0, xpos, str)
  end
end

module Title
  def title=(str)
    @title = str
    WindowExtensions.title(self, str)
  end

  def title
    @title
  end
end

def two_windows()
  width = Ncurses.COLS
  one = Ncurses::WINDOW.new(0, width, 0, 0)
  # make a derived window (origin is relative to parent origin)
  two = one.derwin(10, one.getmaxx/3, 8, 6)
  one.border(*([0]*8))
  two.border(*([0]*8))
  one.move(3,3)
  one.addstr("move(3,3)")
  two.extend(Title)
  two.title = "Derived window"
  two.move(3,3)
  two.addstr("move(3,3)")
  two.move(5,3)
  two.addstr("Press a key")
  one.noutrefresh  # copy window to virtual screen, don't update real screen
  two.noutrefresh
  Ncurses.doupdate # update screen
  two.getch
end

begin
  Ncurses.initscr
  Ncurses.cbreak                  # provide unbuffered input
  Ncurses.noecho                  # turn off input echoing
  Ncurses.nonl                    # turn off newline translation
  Ncurses.stdscr.intrflush(false) # turn off flush-on-interrupt
  Ncurses.stdscr.keypad(true)     # turn on keypad mode

  two_windows                     # demo of a window and a derived window with borders

ensure
  Ncurses.flushinp                # flush any remaining input
  Ncurses.nl
  Ncurses.echo
  Ncurses.nocbreak
  Ncurses.endwin
end


