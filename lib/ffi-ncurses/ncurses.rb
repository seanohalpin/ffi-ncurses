# Ncurses compatiblity layer.
require "ffi-ncurses"
require 'ffi-ncurses/ord_shim'  # for 1.8.6 compatibility

def log(*a)
  File.open("ncurses.log", "a") do |file|
    file.puts(a.inspect)
  end
end

module FFI
  module NCurses
    # Methods to help wrap FFI::NCurses methods to be compatible with Ncurses.
    module Compatibility
      extend self

      def lookup_signature(method)
        FFI::NCurses::FUNCTION_SIGNATURES.assoc(method)
      end

      def unbox_args(signature, args)
        signature[1].zip(args).map{ |sig, arg|
          case sig
          when :window_p
            arg.win
          when :chtype
            arg.ord
          else
            arg
          end
        }
      end
    end
  end
end

module Ncurses
  module NCX
    def COLS
      FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
    end

    def LINES
      FFI::NCurses.getmaxy(FFI::NCurses.stdscr)
    end

    def has_colors?
      FFI::NCurses.has_colors
    end
  end
  include NCX
  extend NCX

  class WINDOW
    attr_accessor :win

    def initialize(*args, &block)
      # SOH: Lifted from Ncurses. One example of how truly horrible
      # that interface is (using the existence of an otherwise useless
      # block as a flag).
      if block_given?
        @win = args.first
      else
        @win = FFI::NCurses.newwin(*args)
      end
    end

    # Lifted from Ncurses.
    def method_missing(name, *args)
      name = name.to_s
      if name[0,2] == "mv"
        test_name = name.dup
        test_name[2,0] = "w" # insert "w" after"mv"
        if FFI::NCurses.respond_to?(test_name)
          FFI::NCurses.send(test_name, @win, *args)
        end
      else
        test_name = "w" + name
        if FFI::NCurses.respond_to?(test_name)
          FFI::NCurses.send(test_name, @win, *args)
        else
          FFI::NCurses.send(name, @win, *args)
        end
      end
    end

    def respond_to?(name)
      name = name.to_s
      if name[0,2] == "mv" && FFI::NCurses.respond_to?("mvw" + name[2..-1])
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

  def initscr
    Ncurses.initscr
  end

  def self.stdscr
    @stdscr
  end

  def stdscr
    Ncurses.stdscr
  end

  module MM
    def method_missing(method, *args, &block)
      if FFI::NCurses.respond_to?(method)
        signature = FFI::NCurses::Compatibility.lookup_signature(method)
        args = FFI::NCurses::Compatibility.unbox_args(signature, args)
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

  TRUE  = true
  FALSE = false

  include FFI::NCurses::Color
  include FFI::NCurses::Attributes
  include FFI::NCurses::KeyDefs
  include FFI::NCurses::Constants
  include FFI::NCurses::Mouse
end
