# FOV calculation for roguelike
# based on fov.py

def log(*a)
  STDERR.print Time.now.to_s + ": "
  STDERR.puts a.inspect
end
log "Started"

require 'ffi-ncurses'
NC = FFI::NCurses
log "Loaded ffi-ncurses"

FOV_RADIUS = 16 # 10

DUNGEON =  ["###########################################################",
            "#...........#.............................................#",
            "#...........#........#....................................#",
            "#.....................#...................................#",
            "#....####..............#..................................#",
            "#.......#.......................#####################.....#",
            "#.......#...........................................#.....#",
            "#.......#...........##..............................#.....#",
            "#####........#......##..........##################..#.....#",
            "#...#...........................#................#..#.....#",
            "#...#............#..............#................#..#.....#",
            "#...............................#..###############..#.....#",
            "#...............................#...................#.....#",
            "#...............................#...................#.....#",
            "#...............................#####################.....#",
            "#.........................................................#",
            "#.........................................................#",
            "###########################################################"]

class Map
  # Multipliers for transforming coordinates to other octants:
  MULT = [
          [1,  0,  0, -1, -1,  0,  0,  1],
          [0,  1, -1,  0,  0, -1,  1,  0],
          [0,  1,  1,  0,  0, -1, -1,  0],
          [1,  0,  0,  1, -1,  0,  0, -1]
         ]

  attr_accessor :data, :width, :height, :light, :flag

  def initialize(map)
    self.data = map
    self.width, self.height = map[0].size, map.size
    self.light = []

    0.upto(self.height - 1) do
      self.light << [0] * self.width
    end
    self.flag = 0
  end

  def square(x, y)
    self.data[y][x]
  end

  def blocked(x, y)
    x < 0 or y < 0 or x >= self.width or y >= self.height or self.data[y][x] == "#"
  end

  def lit(x, y)
    self.light[y][x] == self.flag
  end

  def set_lit(x, y)
    if (0..self.width).include?(x) and (0..self.height).include?(y)
      self.light[y][x] = self.flag
    end
  end

  def _cast_light(cx, cy, row, start, xend, radius, xx, xy, yx, yy, id)
    # STDERR.puts [cx, cy, row, start, xend, radius, xx, xy, yx, yy, id, caller].inspect
    # Recursive lightcasting function
    if start < xend
      return
    end
    radius_squared = radius*radius
    row.upto(radius) do |j|
      dx, dy = -j-1, -j
      blocked = false
      while dx <= 0
        dx += 1
        # Translate the dx, dy coordinates into map coordinates:
        x, y = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy
        # l_slope and r_slope store the slopes of the left and right
        # extremities of the square we're considering:
        l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
        if start < r_slope
          next
        elsif xend > l_slope
          break
        else
          # Our light beam is touching this square; light it:
          if dx*dx + dy*dy < radius_squared
            self.set_lit(x, y)
          end
          if blocked
            # we're scanning a row of blocked squares:
            if self.blocked(x, y)
              new_start = r_slope
              next
            else
              blocked = false
              start = new_start
            end
          else
            if self.blocked(x, y) and j < radius
              # This is a blocking square, start a child scan:
              blocked = true
              self._cast_light(cx, cy, j+1, start, l_slope, radius, xx, xy, yx, yy, id+1)
              new_start = r_slope
            end
          end
        end
      end
      # Row is scanned; do next row unless last square was blocked:
      if blocked
        break
      end
    end
  end

  def do_fov(x, y, radius)
    "Calculate lit squares from the given location and radius"
    self.flag += 1
    0.upto(7) do |oct|
      self._cast_light(x, y, 1, 1.0, 0.0, radius,
                       MULT[0][oct], MULT[1][oct],
                       MULT[2][oct], MULT[3][oct], 0)
    end
  end

  def display(s, cx, cy)
    "Display the map on the given curses screen (utterly unoptimized)"
    dark, lit = NC.COLOR_PAIR(8), NC.COLOR_PAIR(7) | NC::A_BOLD
    #log :dark, dark, :lit, lit
    0.upto(self.width - 1) do |x|
      0.upto(self.height - 1) do |y|
        if self.lit(x, y)
          attr = lit
        else
          attr = dark
        end
        if x == cx and y == cy
          #log :x, x, :cx, cx, :y, y, :cy, cy
          ch = '@'
          attr = lit
        else
          ch = self.square(x, y)
        end
        NC.attr_on(attr, nil)
        NC.mvaddstr(y, x, ch)
        NC.attr_off(attr, nil)
      end
      NC.refresh
    end
  end
end

def color_pairs()
  c = []
  1.upto(15) do |i|
    NC.init_pair(i, i % 8, 0)
    if i < 8
      c << NC.COLOR_PAIR(i)
    else
      c << (NC.COLOR_PAIR(i) | NC::A_BOLD)
    end
  end
  c
end

if __FILE__ == $0
  begin
    s = NC.initscr
    NC.start_color
    NC.noecho
    NC.cbreak
    NC.curs_set(0)
    color_pairs
    NC.keypad(NC.stdscr, true)
    x, y = 36, 13
    map = Map.new(DUNGEON)
    log "initialized ffi-ncurses"
    loop do
      map.do_fov(x, y, FOV_RADIUS)
      map.display(s, x, y)
      k = NC.getch
      case k
      when 27
        break
      when NC::KEY_UP
        y -= 1
      when NC::KEY_DOWN
        y += 1
      when NC::KEY_LEFT
        x -= 1
      when NC::KEY_RIGHT
        x += 1
      end
    end
  ensure
    NC.keypad(NC.stdscr, false)
    NC.echo()
    NC.nocbreak()
    NC.endwin()
  end
end
