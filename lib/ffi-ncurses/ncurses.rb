require "ffi-ncurses"
require 'ffi-ncurses/ord_shim'  # for 1.8.6 compatibility

# module NcursesExtension
#   def method_missing(method, *args, &block)
#     FFI::NCurses.send(method, self.win, *args, &block)
#   end
# end

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

module Ncurses
  module NCX
    def COLS
      FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
    end
  end
  include NCX
  extend NCX
  class WINDOW
    attr_accessor :win
    def initialize(*args, &block)
      if block_given?
        @win = args.first
      else
        @win = FFI::NCurses.newwin(*args)
      end
    end
    def method_missing(name, *args)
      name = name.to_s
      if (name[0,2] == "mv")
        test_name = name.dup
        test_name[2,0] = "w" # insert "w" after"mv"
        if (FFI::NCurses.respond_to?(test_name))
          return FFI::NCurses.send(test_name, @win, *args)
        end
      end
      test_name = "w" + name
      if (FFI::NCurses.respond_to?(test_name))
        return FFI::NCurses.send(test_name, @win, *args)
      end
      FFI::NCurses.send(name, @win, *args)
    end
    def respond_to?(name)
      name = name.to_s
      if (name[0,2] == "mv" && FFI::NCurses.respond_to?("mvw" + name[2..-1]))
        true
      else
        FFI::NCurses.respond_to?("w" + name) || FFI::NCurses.respond_to?(name)
      end
    end
    def del
      FFI::NCurses.delwin(@win)
    end
    alias delete del
  end
  def self.initscr
    @stdscr = Ncurses::WINDOW.new(FFI::NCurses.initscr) { }
  end
  def self.stdscr
    @stdscr
  end

  include FFI::NCurses::Color
  include FFI::NCurses::Attributes

  module Compatibility
    def has_colors?
      FFI::NCurses.has_colors
    end
  end
  extend Compatibility

  module MM
    def method_missing(method, *args, &block)
      if FFI::NCurses.respond_to?(method)
      #log :mm, method
        if args.size > 0 && args.first.kind_of?(WINDOW)
          args = [args.first.win, *args[1..-1]].compact
        end
        FFI::NCurses.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method)
      FFI::NCurses.respond_to?(method)
    end
  end
  include MM
  extend MM

  include FFI::NCurses::KeyDefs

  TRUE = true
  FALSE = false
  include FFI::NCurses::Constants
end
