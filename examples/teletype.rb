require 'ffi-ncurses'

include FFI::NCurses

def teletype(text)
  rv = true
  text.each_char do |char|
    addstr char
    napms(rand(30))
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
