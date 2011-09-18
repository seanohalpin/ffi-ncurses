# -*- coding: utf-8 -*-

module WideChars
  def display_width(txt)
    #buffer_size = (FFI::WideChars.mbstowcs(nil, self, 0) + 1) * FFI::WideChars.find_type(:wchar_t).size
    wchar_t = FFI::WideChars.find_type(:wchar_t)
    buffer_size = (txt.size + 1) * wchar_t.size
    buffer = FFI::Buffer.new(wchar_t, buffer_size)
    rv = FFI::WideChars.mbstowcs(buffer, txt, txt.size)
    if rv == -1
      raise ArgumentError, "Invalid multibyte sequence"
    else
      rv = FFI::WideChars.wcswidth(buffer, rv)
      if rv == -1
        raise ArgumentError, "Wide character string contains non-printable characters"
      else
        rv
      end
    end
  end

  if RUBY_VERSION < '1.9.0'
    def display_slice(txt, start, length = 1)
      count = 0
      str = ""
      if start.kind_of?(Range)
        limit = start.last + (start.exclude_end? ? 0 : 1)
        start = start.first
      else
        limit = start + length
      end
      txt.each_char do |char|
        if count >= start && count < limit
          str << char
        end
        count += 1
      end
      str
    end
  else
    def display_slice(txt, *args, &b)
      txt.slice(*args, &b)
    end
  end

  extend self
end

module FFI
  module WideChars
    extend FFI::Library

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
    typedef :pointer, :wint_t_p

    # add some functions for handling widechars
    FUNCTIONS = [
                 [:mbstowcs, [:pointer, :string, :size_t], :int],
                 [:setlocale, [:int, :string], :string],
                 [:wcwidth, [:wchar_t], :int],
                 [:wcswidth, [:wchar_t_p, :size_t], :int],
                ]
    FUNCTION_SIGNATURES = Marshal.load(Marshal.dump(FUNCTIONS))

    LIB_HANDLE = { }
    LIB_HANDLE[:c] = ffi_lib(FFI::Library::LIBC) # for wcwidth, wcswidth
    FUNCTIONS.each do |function|
      attach_function *function
    end

    #if RUBY_VERSION < '1.9.0'
    lc_all = 0
    setlocale(lc_all, "")
    #end
  end
end

# JRuby 1.6 --1.9 fails when using wcswidth on multichar string
# but seems to work when you feed it character by character.
# Also, this seems to be the only safe version.

# This won't work in 1.8.7 (chars == bytes)
module WideCharsJR
  def display_width2
    width = 0
    wchar_t_size = FFI::WideChars.find_type(:wchar_t).size
    # we rely on Ruby to convert a char into a mbs
    each_char do |ch|
      buffer_size = (ch.size + 1) * wchar_t_size
      # p [:size, size]
      buffer = FFI::Buffer.new(FFI::WideChars.find_type(:wchar_t), buffer_size)
      rv = FFI::WideChars.mbstowcs(buffer, ch, ch.size)
      # p [:mbstowcs, rv]
      if rv == -1
        raise ArgumentError, "Invalid multibyte sequence"
      else
        rv = FFI::WideChars.wcswidth(buffer, rv)
        # p [:wcswidth, rv]
        if rv == -1
          raise ArgumentError, "Wide character string contains non-printable characters"
        else
          width += rv
        end
      end
    end
    width
  end
end

class String
  def display_width
    WideChars.display_width(self)
  end
  def display_slice(*args, &b)
    WideChars.display_slice(self, *args, &b)
  end
end

