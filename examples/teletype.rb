#!/usr/bin/env ruby
#
# teletype simulator
#
# Try this for a retro look:
#
#   $ xterm -fa "Courier New":style=bold -fs 14 \
#     -geometry 80x25+100+100 -fg "Dark Slate Gray" -bg "Ivory"
#     -bc -bcn 100 -bcf 100 \
#     -e ruby examples/teletype.rb  &

require 'ffi-ncurses'

include FFI::NCurses

def teletype(text)
  rv = true
  newline_count = 0
  text.each_char do |char|
    if newline_count == 2
      sleep 0.5 + rand(2)
      newline_count = 0
    elsif char == "\n"
      newline_count += 1
    else
      newline_count = 0
    end
    addstr char
    #napms(rand(30))
    sleep 0.01
    if (ch = getch) != -1
      rv = false
      break
    end
    refresh
  end
  rv
end

if ARGV.size > 0
  filename = ARGV[0]
else
  filename = __FILE__
end

text = File.read(filename)

initscr
begin
  scrollok(stdscr, true)
  # turn off blocking read
  timeout(0)
  if teletype(text)
    flushinp
    # turn on blocking read
    timeout(-1)
    getch
  end
ensure
  flushinp
  endwin
end

#########################
# Press any key to quit #
#########################
