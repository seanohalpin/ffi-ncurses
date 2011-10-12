# FOV calculation for roguelike
# based on fov.py
# http://roguebasin.roguelikedevelopment.org/index.php/Python_shadowcasting_implementation
# See http://roguebasin.roguelikedevelopment.org/index.php/FOV_using_recursive_shadowcasting for explanation

def log(*a)
  STDERR.print Time.now.to_s + ": "
  STDERR.puts a.inspect
end
#log "Started"

require 'ffi-ncurses'
NC = FFI::NCurses
#log "Loaded ffi-ncurses"

FOV_RADIUS = 10 # 10

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

module FOV
  # Multipliers for transforming coordinates to other octants:
  MULT = [
          [1,  0,  0, -1, -1,  0,  0,  1],
          [0,  1, -1,  0,  0, -1,  1,  0],
          [0,  1,  1,  0,  0, -1, -1,  0],
          [1,  0,  0,  1, -1,  0,  0, -1]
         ]

  # original
  def cast_light(px, py, row, start, finish, radius, xx, xy, yx, yy, level)
    # Recursive lightcasting function
    if start >= finish
      radius_squared = radius*radius
      row.upto(radius) do |j|
        dx, dy = -j-1, -j
        blocked = false
        while dx <= 0
          dx += 1
          # Translate the dx, dy coordinates into map coordinates:
          x, y = px + dx * xx + dy * xy, py + dx * yx + dy * yy
          # l_slope and r_slope store the slopes of the left and right
          # extremities of the square we're considering:
          l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
          if start < r_slope
            next
          elsif finish > l_slope
            break
          else
            # Our light beam is touching this square; light it:
            if dx*dx + dy*dy < radius_squared
              self.light(x, y)
            end
            if blocked
              # we're scanning a row of blocked squares:
              if self.blocked?(x, y)
                new_start = r_slope
                next
              else
                blocked = false
                start = new_start
              end
            else
              if self.blocked?(x, y) and j < radius
                # This is a blocking square, start a child scan:
                blocked = true
                self.cast_light(px, py, j+1, start, l_slope, radius, xx, xy, yx, yy, level+1)
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
  end

  def do_fov(x, y, radius)
    # Calculate lit squares from the given location and radius
    0.upto(7) do |octant|
      #self.cast_light(x, y, 1, 1.0, 0.0, radius,
      self.cast_light(x, y, 1, 1.0, 0.0, radius,
                      MULT[0][octant], MULT[1][octant],
                      MULT[2][octant], MULT[3][octant], 0)
    end
  end
end

# http://roguebasin.roguelikedevelopment.org/index.php/Ruby_shadowcasting_implementation
module ShadowcastingFieldOfView
  # Multipliers for transforming coordinates into other octants
  @@mult = [
            [1,  0,  0, -1, -1,  0,  0,  1],
            [0,  1, -1,  0,  0, -1,  1,  0],
            [0,  1,  1,  0,  0, -1, -1,  0],
            [1,  0,  0,  1, -1,  0,  0, -1],
           ]

  # Determines which co-ordinates on a 2D grid are visible
  # from a particular co-ordinate.
  # start_x, start_y: center of view
  # radius: how far field of view extends
  def do_fov(start_x, start_y, radius)
    light start_x, start_y
    8.times do |oct|
      cast_light start_x, start_y, 1, 1.0, 0.0, radius,
      @@mult[0][oct],@@mult[1][oct],
      @@mult[2][oct], @@mult[3][oct], 0
    end
  end

  private
  # Recursive light-casting function
  def cast_light(cx, cy, row, light_start, light_end, radius, xx, xy, yx, yy, id)
    return if light_start < light_end
    radius_sq = radius * radius
    (row..radius).each do |j| # .. is inclusive
      dx, dy = -j - 1, -j
      blocked = false
      while dx <= 0
        dx += 1
        # Translate the dx, dy co-ordinates into map co-ordinates
        mx, my = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy
        # l_slope and r_slope store the slopes of the left and right
        # extremities of the square we're considering:
        l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
        if light_start < r_slope
          next
        elsif light_end > l_slope
          break
        else
          # Our light beam is touching this square; light it
          light(mx, my) if (dx*dx + dy*dy) < radius_sq
          if blocked
            # We've scanning a row of blocked squares
            if blocked?(mx, my)
              new_start = r_slope
              next
            else
              blocked = false
              light_start = new_start
            end
          else
            if blocked?(mx, my) and j < radius
              # This is a blocking square, start a child scan
              blocked = true
              cast_light(cx, cy, j+1, light_start, l_slope,
                         radius, xx, xy, yx, yy, id+1)
              new_start = r_slope
            end
          end
        end
      end # while dx <= 0
      break if blocked
    end # (row..radius+1).each
  end
end


module PermissiveFieldOfView
  # Determines which co-ordinates on a 2D grid are visible
  # from a particular co-ordinate.
  # start_x, start_y: center of view
  # radius: how far field of view extends
  def do_fov(start_x, start_y, radius)
    @start_x, @start_y = start_x, start_y
    @radius_sq = radius * radius

    # We always see the center
    light @start_x, @start_y

    # Restrict scan dimensions to map borders and within the radius
    min_extent_x = [@start_x, radius].min
    max_extent_x = [@width - @start_x - 1, radius].min
    min_extent_y = [@start_y, radius].min
    max_extent_y = [@height - @start_y - 1, radius].min

    # Check quadrants: NE, SE, SW, NW
    check_quadrant  1,  1, max_extent_x, max_extent_y
    check_quadrant  1, -1, max_extent_x, min_extent_y
    check_quadrant -1, -1, min_extent_x, min_extent_y
    check_quadrant -1,  1, min_extent_x, max_extent_y
  end

  private
  # Represents a line (duh)
  class Line < Struct.new(:xi, :yi, :xf, :yf)
    # Macros to make slope comparisons clearer
    {:below => '>', :below_or_collinear => '>=', :above => '<',
      :above_or_collinear => '<=', :collinear => '=='}.each do |name, fn|
      eval "def #{name.to_s}?(x, y) relative_slope(x, y) #{fn} 0 end"
    end

    def dx; xf - xi end
    def dy; yf - yi end

    def line_collinear?(line)
      collinear?(line.xi, line.yi) and collinear?(line.xf, line.yf)
    end

    def relative_slope(x, y)
      (dy * (xf - x)) - (dx * (yf - y))
    end
  end

  class ViewBump < Struct.new(:x, :y, :parent)
    def deep_copy
      ViewBump.new(x, y, parent.nil? ? nil : parent.deep_copy)
    end
  end

  class View < Struct.new(:shallow_line, :steep_line)
    attr_accessor :shallow_bump, :steep_bump
    def deep_copy
      copy = View.new(shallow_line.dup, steep_line.dup)
      copy.shallow_bump = shallow_bump.nil? ? nil : shallow_bump.deep_copy
      copy.steep_bump   = steep_bump.nil? ? nil : steep_bump.deep_copy
      return copy
    end
  end

  # Check a quadrant of the FOV field for visible tiles
  def check_quadrant(dx, dy, extent_x, extent_y)
    active_views = []
    shallow_line = Line.new(0, 1, extent_x, 0)
    steep_line = Line.new(1, 0, 0, extent_y)

    active_views << View.new(shallow_line, steep_line)
    view_index = 0

    # Visit the tiles diagonally and going outwards
    i, max_i = 1, extent_x + extent_y
    while i != max_i + 1 and active_views.size > 0
      start_j = [0, i - extent_x].max
      max_j = [i, extent_y].min
      j = start_j
      while j != max_j + 1 and view_index < active_views.size
        x, y = i - j, j
        visit_coord x, y, dx, dy, view_index, active_views
        j += 1
      end
      i += 1
    end
  end

  def visit_coord(x, y, dx, dy, view_index, active_views)
    # The top left and bottom right corners of the current coordinate
    top_left, bottom_right = [x, y + 1], [x + 1, y]

    while view_index < active_views.size and
        active_views[view_index].steep_line.below_or_collinear?(*bottom_right)
      # Co-ord is above the current view and can be ignored (steeper fields may need it though)
      view_index += 1
    end

    if view_index == active_views.size or
        active_views[view_index].shallow_line.above_or_collinear?(*top_left)
      # Either current co-ord is above all the fields, or it is below all the fields
      return
    end

    # Current co-ord must be between the steep and shallow lines of the current view
    # The real quadrant co-ordinates:
    real_x, real_y = x * dx, y * dy
    coord = [@start_x + real_x, @start_y + real_y]
    light *coord

    # Don't go beyond circular radius specified
    #if (real_x * real_x + real_y * real_y) > @radius_sq
    #    active_views.delete_at(view_index)
    #    return
    #end

    # If this co-ord does not block sight, it has no effect on the view
    return unless blocked?(*coord)

    view = active_views[view_index]
    if view.shallow_line.above?(*bottom_right) and view.steep_line.below?(*top_left)
      # Co-ord is intersected by both lines in current view, and is completely blocked
      active_views.delete(view)
    elsif view.shallow_line.above?(*bottom_right)
      # Co-ord is intersected by shallow line; raise the line
      add_shallow_bump top_left[0], top_left[1], view
      check_view active_views, view_index
    elsif view.steep_line.below?(*top_left)
      # Co-ord is intersected by steep line; lower the line
      add_steep_bump bottom_right[0], bottom_right[1], view
      check_view active_views, view_index
    else
      # Co-ord is completely between the two lines of the current view. Split the
      # current view into two views above and below the current co-ord.
      shallow_view_index, steep_view_index = view_index, view_index += 1
      active_views.insert(shallow_view_index, active_views[shallow_view_index].deep_copy)
      add_steep_bump bottom_right[0], bottom_right[1], active_views[shallow_view_index]

      unless check_view(active_views, shallow_view_index)
        view_index -= 1
        steep_view_index -= 1
      end

      add_shallow_bump top_left[0], top_left[1], active_views[steep_view_index]
      check_view active_views, steep_view_index
    end
  end

  def add_shallow_bump(x, y, view)
    view.shallow_line.xf = x
    view.shallow_line.yf = y
    view.shallow_bump = ViewBump.new(x, y, view.shallow_bump)

    cur_bump = view.steep_bump
    while not cur_bump.nil?
      if view.shallow_line.above?(cur_bump.x, cur_bump.y)
        view.shallow_line.xi = cur_bump.x
        view.shallow_line.yi = cur_bump.y
      end
      cur_bump = cur_bump.parent
    end
  end

  def add_steep_bump(x, y, view)
    view.steep_line.xf = x
    view.steep_line.yf = y
    view.steep_bump = ViewBump.new(x, y, view.steep_bump)

    cur_bump = view.shallow_bump
    while not cur_bump.nil?
      if view.steep_line.below?(cur_bump.x, cur_bump.y)
        view.steep_line.xi = cur_bump.x
        view.steep_line.yi = cur_bump.y
      end
      cur_bump = cur_bump.parent
    end
  end

  # Removes the view in active_views at index view_index if:
  # * The two lines are collinear
  # * The lines pass through either extremity
  def check_view(active_views, view_index)
    shallow_line = active_views[view_index].shallow_line
    steep_line = active_views[view_index].steep_line
    if shallow_line.line_collinear?(steep_line) and (shallow_line.collinear?(0, 1) or
                                                     shallow_line.collinear?(1, 0))
      active_views.delete_at view_index
      return false
    end
    return true
  end
end

class Map
  include FOV
  #include PermissiveFieldOfView
  #include ShadowcastingFieldOfView

  attr_accessor :data, :width, :height, :lit_cells, :counter

  def initialize(map)
    self.data = map
    self.width, self.height = map[0].size, map.size
    self.lit_cells = []

    0.upto(self.height - 1) do
      self.lit_cells << [0] * self.width
    end
    # incremented on each turn
    self.counter = 0
  end

  def cell(x, y)
    self.data[y][x]
  end

  BLOCKS = ["#"]

  def blocked?(x, y)
    x < 0 or y < 0 or x >= self.width or y >= self.height or BLOCKS.include?(self.data[y][x])
  end

  def lit?(x, y)
    self.lit_cells[y][x] == self.counter
  end

  def seen?(x, y)
    self.lit_cells[y][x] > 0
  end

  def light(x, y)
    if (0..self.width).include?(x) and (0..self.height).include?(y)
      self.lit_cells[y][x] = self.counter
    end
  end

  DARK   = NC::COLOR_PAIR(NC::COLOR_BLACK + 1)
  SEEN   = NC::COLOR_PAIR(NC::COLOR_BLACK + 1) | NC::A_BOLD
  LIT    = NC::COLOR_PAIR(NC::COLOR_YELLOW + 1) | NC::A_BOLD
  PLAYER = NC::COLOR_PAIR(NC::COLOR_WHITE + 1) | NC::A_BOLD

  def display(s, px, py)
    # Display the map on the given curses screen (utterly unoptimized)
    #log :dark, dark, :lit, lit
    0.upto(self.width - 1) do |x|
      0.upto(self.height - 1) do |y|
        if self.lit?(x, y)
          attr = LIT
        elsif self.seen?(x, y)
          attr = SEEN
        else
          attr = DARK
        end
        if x == px and y == py
          ch = '@'
          attr = PLAYER
        else
          ch = self.cell(x, y)
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
  1.upto(16) do |i|
    NC.init_pair(i, i % 8, 0)
    if i < 8
      c << NC.COLOR_PAIR(i)
    else
      c << (NC.COLOR_PAIR(i) | NC::A_BOLD)
    end
  end
  c
end

def init_colours
  if respond_to?(:use_default_colors)
    use_default_colors
    bg = -1
    fg = -1
  else
    bg = NC::Color::BLACK
    fg = NC::Color::BLACK
  end
  NC.init_pair(1,  NC::Color::BLACK,   bg)
  NC.init_pair(2,  NC::Color::RED,     bg)
  NC.init_pair(3,  NC::Color::GREEN,   bg)
  NC.init_pair(4,  NC::Color::YELLOW,  bg)
  NC.init_pair(5,  NC::Color::BLUE,    bg)
  NC.init_pair(6,  NC::Color::MAGENTA, bg)
  NC.init_pair(7,  NC::Color::CYAN,    bg)
  NC.init_pair(8,  NC::Color::WHITE,   bg)

  NC.init_pair(9,  fg, NC::Color::BLACK)
  NC.init_pair(10, fg, NC::Color::RED)
  NC.init_pair(11, fg, NC::Color::GREEN)
  NC.init_pair(12, fg, NC::Color::YELLOW)
  NC.init_pair(13, fg, NC::Color::BLUE)
  NC.init_pair(14, fg, NC::Color::MAGENTA)
  NC.init_pair(15, fg, NC::Color::CYAN)
  NC.init_pair(16, fg, NC::Color::WHITE)
end

if __FILE__ == $0
  begin
    s = NC.initscr
    if NC.has_colors
      NC.start_color
      # color_pairs
      init_colours
    end
    NC.noecho
    NC.raw                      # to get Ctrl-Q working
    NC.curs_set(0)
    NC.keypad(NC.stdscr, true)
    x, y = 36, 13
    map = Map.new(DUNGEON)
    # log "initialized ffi-ncurses"
    loop do
      #log map.light
      # map.do_fov(x, y, FOV_RADIUS - rand(4)) # simulate flickering flame
      map.counter += 1
      map.do_fov(x, y, FOV_RADIUS)
      map.display(s, x, y)
      newx, newy = x, y
      k = NC.getch
      #log :key, k
      case k
      when NC::KEY_ESCAPE, NC::KEY_CTRL_Q, NC::KEY_CTRL_C
        break
      when NC::KEY_UP
        newy -= 1
      when NC::KEY_DOWN
        newy += 1
      when NC::KEY_LEFT
        newx -= 1
      when NC::KEY_RIGHT
        newx += 1
      end
      if !map.blocked?(newx, newy)
        x, y, = newx, newy
      end
    end
  ensure
    NC.keypad(NC.stdscr, false)
    NC.echo()
    NC.nocbreak()
    NC.endwin()
  end
end
