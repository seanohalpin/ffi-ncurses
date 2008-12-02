#!/usr/bin/env ruby -w
# Sean O'Halpin, 2008-11-18
# hacking on ruby-ffi, ncurses and dl to get ncurses exported variables
# and values returned via pointer args
require 'rubygems'
require 'ffi'
require 'pp'
require 'dlfcn'
require 'ffi-ncurses'

begin
  lib = 'ncurses'
  # copied from FFI.attach_function
  if lib && File.basename(lib) == lib
    ext = ".#{FFI::Platform::LIBSUFFIX}"
    lib = FFI::Platform::LIBPREFIX + lib unless lib =~ /^#{FFI::Platform::LIBPREFIX}/
      lib += ext unless lib =~ /#{ext}/
  end
  puts [:lib, lib]
  dl_handle = DL.dlopen(lib, DL::RTLD_NOLOAD)
  
  p [:dl_handle, dl_handle]
  # clear error
  rv = DL.dlerror
  # get pointer
  ptr = DL.dlsym(dl_handle, 'stdscr')
  rv = DL.dlerror
  # note: the pointer returned from dlsym is a vector - needs to be
  # dereferenced (using read_pointer) to get 'real' value - also note
  # that it has no value until after it has been set in initscr
  p [:dlsym_stdscr, ptr, ptr.read_pointer, rv]

  stdscr = NCurses.initscr
  stdscr_dl = DL.dlsym(dl_handle, 'stdscr')
  curscr = DL.dlsym(dl_handle, 'curscr')

  NCurses.clear
  NCurses.waddstr stdscr, "Hello"
  NCurses.waddstr stdscr_dl.read_pointer, " World"

  NCurses.attr_set NCurses::A_NORMAL, 5, 0

  p_attr = FFI::MemoryPointer.new(:uint)
  p_pair = FFI::MemoryPointer.new(:short)

  # int attr_get(attr_t *attrs, short *pair, void *opts);
  rv = NCurses.wattr_get(curscr, p_attr, p_pair, 0)
  NCurses.waddstr stdscr, " curscr attr=%d" % p_attr.get_uint32(0)
  NCurses.waddstr stdscr, " pair=%d" % p_pair.get_int16(0)
  
  rv = NCurses.wattr_get(stdscr, p_attr, p_pair, 0)
  NCurses.waddstr stdscr, " stdscr attr=%d %d" % [p_attr.get_uint16(0) >> 8 & 0xFF, p_attr.get_uint16(0) & 0xFF]
  NCurses.waddstr stdscr, " pair=%d" % p_pair.get_int16(0)
  NCurses.wrefresh stdscr

  NCurses.wgetch(stdscr)
ensure
  
  NCurses.endwin
end
p [:dlsym_stdscr2, stdscr_dl, stdscr_dl.read_pointer]
pp [:stdscr, stdscr]
