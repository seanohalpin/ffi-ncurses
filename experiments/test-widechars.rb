# -*- coding: utf-8 -*-
# run with ruby -KU for 1.8.x
require 'ffi-ncurses'
require 'ffi-ncurses/widechars'

def timer(label, &block)
  t = Time.now
  block.call
  p [label, Time.now - t]
end


txt = "ＡＰＰＬＥ pie"
# txt = "APPLE pie"
p txt
p txt.encoding if txt.respond_to?(:encoding)

# 1.9.2 first time round == 13 then 14 on subsequent calls - WTF?
# size = (txt.size + 1) * FFI::WideChars.find_type(:wchar_t).size
# p [:size, size]
# buffer = "\0" * size
# rv = FFI::WideChars.mbstowcs(buffer, txt, txt.size)
# p [:mbstowcs2, rv]
# if rv != -1
#   rv = FFI::WideChars.wcswidth(buffer, rv)
#   p [:wcswidth2, rv]
# end
p [:display_width, txt.display_width]
# timer :display_width2 do
#   1000.times { txt.display_width2 }
# end

# this crashes
timer :display_width do
  1000.times { txt.display_width }
end
# p [:display_width, txt.display_width]
#puts txt

# buffer_size = (txt.size + 1) * FFI::WideChars.find_type(:wchar_t).size
# p [:buffer_size, buffer_size]
# buffer = "\0" * buffer_size
# rv = FFI::WideChars.mbstowcs(buffer, txt, txt.size)
# p [:mbstowcs3, rv]
# # p buffer.bytes.to_a
# if rv == -1
#   raise ArgumentError, "Invalid multibyte sequence"
# else
#   rv = FFI::WideChars.wcswidth(buffer, rv)
#   p [:wcswidth3, rv]
#   rv
# end

ch = txt[0]
p [:ch, ch]
p ch.bytesize if ch.respond_to?(:bytesize)

ch = txt[1]
p ch
p ch.bytesize if ch.respond_to?(:bytesize)

# this works in jruby --1.9
width = 0
wchar_t_size = FFI::WideChars.find_type(:wchar_t).size
txt.each_char do |ch|
  p ch
  buffer_size = (ch.size + 1) * wchar_t_size
  # p [:size, size]
  buffer = FFI::Buffer.new(FFI::WideChars.find_type(:wchar_t), buffer_size)
  rv = FFI::WideChars.mbstowcs(buffer, ch, ch.size)
  # p [:mbstowcs, rv]
  if rv != -1
    rv = FFI::WideChars.wcswidth(buffer, rv)
    p [:wcswidth, rv]
    if rv == -1
      width = -1
    else
      width += rv
    end
  end
end
p [:width3, width]

# p FFI::WideChars.wcwidth(ch.ord)

p [:slice, txt[1,3]]
p [:slice, txt[1..3]]
p [:slice, txt[1...3]]

p [:display_slice, txt.display_slice(1, 3)]
p [:display_slice, txt.display_slice(1..3)]
p [:display_slice, txt.display_slice(1...3)]

apple = "apple"
p [:slice, apple[1,3]]
p [:slice, apple[1..3]]
p [:slice, apple[1...3]]


