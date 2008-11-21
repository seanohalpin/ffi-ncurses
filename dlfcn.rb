# ruby-ffi wrapper for dlfcn.h - dynamic load functions
require 'rubygems'
require 'ffi'
module DL
  extend FFI::Library

  ffi_lib 'dl'

  # extern int dladdr(const void *, Dl_info *);
  # extern int dlclose(void * __handle);
  # extern char * dlerror(void);
  # extern void * dlopen(const char * __path, int __mode);
  # extern void * dlsym(void * __handle, const char * __symbol);
  
  attach_function 'dladdr', [:pointer, :pointer], :int
  attach_function 'dlclose', [:pointer], :int
  attach_function 'dlerror', [], :int # really a pointer to a string, but FFI doesn't like string == 0x0
  attach_function 'dlopen', [:string, :int], :pointer
  attach_function 'dlsym', [:pointer, :string], :pointer

  RTLD_LAZY   = 0x1
  RTLD_NOW    = 0x2
  RTLD_LOCAL  = 0x4
  RTLD_GLOBAL = 0x8
  RTLD_NOLOAD = 0x10
  RTLD_NODELETE = 0x80

  RTLD_NEXT = -1                # Search subsequent objects
  RTLD_DEFAULT = -2             # Use default search algorithm

end

if __FILE__ == $0
  p DL.dlopen('ncurses.so', DL::RTLD_GLOBAL)
end
