require 'ffi-ncurses'
module FFI
  module NCurses

    NCURSES_MOUSE_VERSION = 1

    # mouse interface

    if NCURSES_MOUSE_VERSION > 1
      def self.NCURSES_MOUSE_MASK(b,m)
        ((m) << (((b) - 1) * 5))
      end
    else
      def self.NCURSES_MOUSE_MASK(b,m)
        ((m) << (((b) - 1) * 6))
      end
    end

    NCURSES_BUTTON_RELEASED	= 001
    NCURSES_BUTTON_PRESSED	= 002
    NCURSES_BUTTON_CLICKED	= 004
    NCURSES_DOUBLE_CLICKED  = 010
    NCURSES_TRIPLE_CLICKED	= 020
    NCURSES_RESERVED_EVENT	= 040

    # event masks
    BUTTON1_RELEASED        = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_RELEASED)
    BUTTON1_PRESSED         = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_PRESSED)
    BUTTON1_CLICKED         = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_CLICKED)
    BUTTON1_DOUBLE_CLICKED  = NCURSES_MOUSE_MASK(1, NCURSES_DOUBLE_CLICKED)
    BUTTON1_TRIPLE_CLICKED  = NCURSES_MOUSE_MASK(1, NCURSES_TRIPLE_CLICKED)

    BUTTON2_RELEASED        = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_RELEASED)
    BUTTON2_PRESSED         = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_PRESSED)
    BUTTON2_CLICKED         = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_CLICKED)
    BUTTON2_DOUBLE_CLICKED  = NCURSES_MOUSE_MASK(2, NCURSES_DOUBLE_CLICKED)
    BUTTON2_TRIPLE_CLICKED  = NCURSES_MOUSE_MASK(2, NCURSES_TRIPLE_CLICKED)

    BUTTON3_RELEASED        = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_RELEASED)
    BUTTON3_PRESSED         = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_PRESSED)
    BUTTON3_CLICKED         = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_CLICKED)
    BUTTON3_DOUBLE_CLICKED  = NCURSES_MOUSE_MASK(3, NCURSES_DOUBLE_CLICKED)
    BUTTON3_TRIPLE_CLICKED  = NCURSES_MOUSE_MASK(3, NCURSES_TRIPLE_CLICKED)

    BUTTON4_RELEASED        = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_RELEASED)
    BUTTON4_PRESSED         = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_PRESSED)
    BUTTON4_CLICKED         = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_CLICKED)
    BUTTON4_DOUBLE_CLICKED  = NCURSES_MOUSE_MASK(4, NCURSES_DOUBLE_CLICKED)
    BUTTON4_TRIPLE_CLICKED  = NCURSES_MOUSE_MASK(4, NCURSES_TRIPLE_CLICKED)

    #
    # In 32 bits the version-1 scheme does not provide enough space for a 5th
    # button, unless we choose to change the ABI by omitting the reserved-events.
    #

    if NCURSES_MOUSE_VERSION > 1

      BUTTON5_RELEASED       = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_RELEASED)
      BUTTON5_PRESSED        = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_PRESSED)
      BUTTON5_CLICKED        = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_CLICKED)
      BUTTON5_DOUBLE_CLICKED = NCURSES_MOUSE_MASK(5, NCURSES_DOUBLE_CLICKED)
      BUTTON5_TRIPLE_CLICKED = NCURSES_MOUSE_MASK(5, NCURSES_TRIPLE_CLICKED)

      BUTTON_CTRL            = NCURSES_MOUSE_MASK(6, 0001)
      BUTTON_SHIFT					 = NCURSES_MOUSE_MASK(6, 0002)
      BUTTON_ALT						 = NCURSES_MOUSE_MASK(6, 0004)
      REPORT_MOUSE_POSITION	 = NCURSES_MOUSE_MASK(6, 0010)

    else

      BUTTON1_RESERVED_EVENT = NCURSES_MOUSE_MASK(1, NCURSES_RESERVED_EVENT)
      BUTTON2_RESERVED_EVENT = NCURSES_MOUSE_MASK(2, NCURSES_RESERVED_EVENT)
      BUTTON3_RESERVED_EVENT = NCURSES_MOUSE_MASK(3, NCURSES_RESERVED_EVENT)
      BUTTON4_RESERVED_EVENT = NCURSES_MOUSE_MASK(4, NCURSES_RESERVED_EVENT)

      BUTTON_CTRL            = NCURSES_MOUSE_MASK(5, 0001)
      BUTTON_SHIFT					 = NCURSES_MOUSE_MASK(5, 0002)
      BUTTON_ALT						 = NCURSES_MOUSE_MASK(5, 0004)
      REPORT_MOUSE_POSITION	 = NCURSES_MOUSE_MASK(5, 0010)

    end

    ALL_MOUSE_EVENTS = (REPORT_MOUSE_POSITION - 1)

    class << self
      # macros to extract single event-bits from masks
      def	BUTTON_RELEASE(e, x)
        ((e) & (001 << (6 * ((x) - 1))))
      end
      def	BUTTON_PRESS(e, x)
        ((e) & (002 << (6 * ((x) - 1))))
      end
      def	BUTTON_CLICK(e, x)
        ((e) & (004 << (6 * ((x) - 1))))
      end
      def	BUTTON_DOUBLE_CLICK(e, x)
        ((e) & (010 << (6 * ((x) - 1))))
      end
      def	BUTTON_TRIPLE_CLICK(e, x)
        ((e) & (020 << (6 * ((x) - 1))))
      end
      def	BUTTON_RESERVED_EVENT(e, x)
        ((e) & (040 << (6 * ((x) - 1))))
      end

      #     if NCURSES_MOUSE_VERSION > 1
      #       def NCURSES_MOUSE_MASK(b,m)
      #         ((m) << (((b) - 1) * 5))
      #       end
      #     else
      #       def NCURSES_MOUSE_MASK(b,m)
      #         ((m) << (((b) - 1) * 6))
      #       end
      #     end
    end

    #   def mouse_trafo(y, x, to_screen)
    #   end

    # already defined in keydefs.rb
    # KEY_MOUSE = 0631 # Mouse event has occurred

    #FFI.add_typedef :ulong, :mmask_t
    class MEVENT < FFI::Struct
      layout :id, :short,
      :x, :int,
      :y, :int,
      :z, :int,
      #    :bstate, :mmask_t
      :bstate, :ulong
    end

    functions =
      [
       [:getmouse, [MEVENT], :int],
       [:ungetmouse, [MEVENT], :int],
      ]

    functions.each do |function|
      begin
        attach_function(*function)
      rescue Object => e
        (@unattached_functions ||= []) << function
      end
    end
  end
end
