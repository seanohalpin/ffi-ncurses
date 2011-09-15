#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8; -*-
require 'ffi-ncurses'

include FFI::NCurses

def main
  my_wins = []
  my_panels = []
  lines = 10
  cols = 40
  y = 2
  x = 4

  begin
    initscr
    cbreak
    noecho

    # Create windows for the panels
    my_wins[0] = newwin(lines, cols, y, x)
    my_wins[1] = newwin(lines, cols, y + 1, x + 5)
    my_wins[2] = newwin(lines, cols, y + 2, x + 10)

    # Create borders around the windows so that you can see the effect
    # of panels
    my_wins.each do |win|
      box(win, 0, 0)
    end

    # Attach a panel to each window      Order is bottom up #
    my_panels[0] = new_panel(my_wins[0])        # Push 0, order: stdscr-0
    my_panels[1] = new_panel(my_wins[1])        # Push 1, order: stdscr-0-1
    my_panels[2] = new_panel(my_wins[2])        # Push 2, order: stdscr-0-1-2

    # Update the stacking order. 2nd panel will be on top
    update_panels

    # Show it on the screen
    doupdate

    getch
  rescue => e
    endwin
    raise
  ensure
    endwin
  end
end

main
