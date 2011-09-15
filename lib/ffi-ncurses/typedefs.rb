module FFI
  module NCurses
    extend FFI::Library

    # If I define my own typedefs, a bug in FFI (at least 0.6.3) means
    # I have to redefine the built-in types if they're going to be
    # used in variadic functions
    FFI::TypeDefs.keys.each do |key|
      typedef key, key
    end

    typedef :ulong,   :attr_t
    typedef :pointer, :attr_t_p
    typedef :pointer, :cchar_t_p
    typedef :ulong,   :chtype
    typedef :pointer, :chtype_p
    typedef :pointer, :file_p
    typedef :pointer, :int_p
    typedef :pointer, :mevent_p
    typedef :ulong,   :mmask_t
    typedef :pointer, :mmask_t_p
    typedef :pointer, :panel_p
    typedef :pointer, :screen_p
    typedef :pointer, :short_p
    typedef :ushort,  :wchar_t
    typedef :pointer, :wchar_t_p
    typedef :pointer, :window_p
    typedef :int,     :wint_t    # An integral type capable of storing any valid value of wchar_t, or WEOF
    typedef :pointer, :wint_t_p

  end
end

# Refs:
# http://pubs.opengroup.org/onlinepubs/007908799/xsh/wchar.h.html
