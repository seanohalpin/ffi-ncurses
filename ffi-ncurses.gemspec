Gem::Specification.new do |s|
  s.name        = "ffi-ncurses"
  s.version     = "0.1.0"
  s.date        = "2009-01-18"
  s.summary     = "FFI wrapper for ncurses"
  s.email       = "sean.ohalpin@gmail.com"
  s.homepage    = "http://github.com/seanohalpin/ffi-ncurses"
  s.description = "ffi-ncurses is an ruby-ffi wrapper for ncurses."
  s.has_rdoc    = false
  s.authors     = ["Sean O'Halpin"]
  s.files       =
    [
     "History.txt", 
     "README.txt", 
     "Rakefile", 
     "ffi-ncurses.gemspec", 
     "lib/ffi/ffi-ncurses.rb", 
    ]
#   s.test_files  =
#     [
#     ]
#   s.rdoc_options     = ["--main", "README.txt"]
#   s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("ruby-ffi", ["> = 0.2.0"])
end
