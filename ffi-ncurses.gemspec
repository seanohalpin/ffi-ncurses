Gem::Specification.new do |s|
  s.name        = "ffi-ncurses"
  s.version     = "0.2.0"
  s.date        = "2009-02-03"
  s.summary     = "FFI wrapper for ncurses"
  s.email       = "sean.ohalpin@gmail.com"
  s.homepage    = "http://github.com/seanohalpin/ffi-ncurses"
  s.description = "ffi-ncurses is an ruby-ffi wrapper for ncurses."
  s.has_rdoc    = false
  s.authors     = ["Sean O'Halpin"]
  s.files       =
    [
     "History.txt", 
     "README.rdoc",
     "ffi-ncurses.gemspec", 
     "ffi-ncurses.rb",
     "ffi-ncurses-darwin.rb",
     "ffi-ncurses-mouse.rb",
     *Dir["examples/example*.rb"],
    ]
#   s.test_files  =
#     [
#     ]
#   s.rdoc_options     = ["--main", "README.txt"]
#   s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("ruby-ffi", ["> = 0.2.0"])
end
