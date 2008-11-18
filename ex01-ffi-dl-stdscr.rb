require 'rubygems'
require 'ffi'
require 'pp'
require 'dlfcn'
require 'ffi-ncurses'

begin
  # module NC
  #   extend FFI::Library

  #   ffi_lib 'ncurses'

  # #  invoker = attach_function 'stdscr', [], :pointer
  # #   p invoker
  # #   STDSCR = invoker.address
  # #   STDSCR.autorelease = false
  # #   p ["STDSCR", STDSCR]
  #   $invoker = attach_function 'clear', [], :int
  #   attach_function 'endwin', [], :int
  #   attach_function 'getch', [], :int
  #   attach_function 'initscr', [], :pointer
  #   attach_function 'printw', [:string], :int
  #   attach_function 'refresh', [], :int
  #   attach_function 'wrefresh', [:pointer], :int
  #   attach_function 'waddstr', [:pointer, :string], :int
  #   attach_function 'wgetch', [:pointer], :int
  #   attach_function 'newwin', [:int, :int, :int, :int], :pointer

  #   attach_function *[:wattr_get, [:pointer, :pointer, :pointer, :pointer], :int]
  
  # end

 
  puts "starting"

  #handle = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD)
  #handle = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD | DL::RTLD_GLOBAL)
  #handle_x = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD)
  #handle_x = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD)
  #p [:handle_x, handle_x]
  handle = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD)
  #handle = $invoker.handle
  p [:handle, handle]
  # clear error
  rv = DL.dlerror
  # get pointer
  ptr = DL.dlsym(handle, 'stdscr')
  p [:stdscr, ptr, ptr.read_pointer]
  # check error
  rv = DL.dlerror

  #handle2 = DL.dlopen("libncurses.dylib", DL::RTLD_NOLOAD)
  #handle2 = DL.dlopen("libncurses.so", DL::RTLD_NOLOAD)
  #p [:handle2, handle2]
  #ptr2 = DL.dlsym(handle, 'clear')
  #p [:ptr2, ptr2]

  stdscr = NCurses.initscr
  ptr2 = DL.dlsym(handle, 'stdscr')
  curscr = DL.dlsym(handle, 'curscr')

  NCurses.clear
  #NCurses.waddstr NC::STDSCR, "Hello"
  #win = NCurses.newwin 10, 10, 10, 10
  win = stdscr
  NCurses.waddstr win, "Hello"
  NCurses.waddstr ptr2.read_pointer, " World"

  # int attr_get(attr_t *attrs, short *pair, void *opts);

  NCurses.attr_set NCurses::A_NORMAL, 5, 0

  p_attr = FFI::MemoryPointer.new(:uint)
  p_pair = FFI::MemoryPointer.new(2)

  rv = NCurses.wattr_get(curscr, p_attr, p_pair, 0)
  NCurses.waddstr win, " curscr attr=%d" % p_attr.get_uint32(0)
  NCurses.waddstr win, " pair=%d" % p_pair.get_int16(0)
  
  rv = NCurses.wattr_get(win, p_attr, p_pair, 0)
#  NCurses.waddstr win, " stdscr attr=%d" % p_attr.get_uint32(0)
  
  NCurses.waddstr win, " stdscr attr=%d %d" % [p_attr.get_uint16(0) >> 8 & 0xFF, p_attr.get_uint16(0) & 0xFF]
  NCurses.waddstr win, " pair=%d" % p_pair.get_int16(0)
  NCurses.wrefresh win
  #NCurses.printw "hi"
  #NCurses.refresh
  #sleep 1

  NCurses.wgetch(stdscr)
ensure
  
  NCurses.endwin
end
p [:stdscr2, ptr2, ptr2.read_pointer]
pp [:win, win]
pp [:stdscr, stdscr]            # not the same as value returned from dlsym
# yet the value for 'clear' is
pp [:stdscr, stdscr2 = DL.dlsym(handle, 'stdscr')]
pp [:curscr, curscr = DL.dlsym(handle, 'curscr')]
p stdscr
p stdscr2.read_pointer          # at last!!!!
p curscr.read_pointer

p NCurses::A_NORMAL
