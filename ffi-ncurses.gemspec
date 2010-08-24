# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ffi-ncurses}
  s.version = "0.3.3"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean O'Halpin"]
  s.date = %q{2009-02-24}
  s.description = <<-EOT
A wrapper for ncurses 5.x. Tested on Ubuntu 8.04 to 10.04 and Mac OS X
10.4 (Tiger) with ruby 1.8.6, 1.8.7 and 1.9.x using ffi (>= 0.6.3) and
JRuby 1.5.1.

The API is a transliteration of the C API rather than an attempt to
provide an idiomatic Ruby object-oriented API.

See the examples directory for real working examples.
EOT
  s.email = %q{sean.ohalpin@gmail.com}
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = [
             "History.txt",
             "README.rdoc",
             "examples/doc-eg1.rb",
             "examples/doc-eg2.rb",
             "examples/doc-eg3.rb",
             "examples/example-attributes.rb",
             "examples/example-colour.rb",
             "examples/example-cursor.rb",
             "examples/example-getsetsyx.rb",
             "examples/example-hello.rb",
             "examples/example-jruby.rb",
             "examples/example-keys.rb",
             "examples/example-mouse.rb",
             "examples/example-printw-variadic.rb",
             "examples/example-softkeys.rb",
             "examples/example-stdscr.rb",
             "examples/example-windows.rb",
             "examples/example.rb",
             "examples/ncurses-example.rb",
             "ffi-ncurses.gemspec",
             "lib/ffi-ncurses.rb",
             "lib/ffi-ncurses/darwin.rb",
             "lib/ffi-ncurses/keydefs.rb",
             "lib/ffi-ncurses/mouse.rb",
             "lib/ffi-ncurses/ord-shim.rb",
             "lib/ffi-ncurses/winstruct.rb"
            ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/seanohalpin/ffi-ncurses}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ffi-ncurses}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FFI wrapper for ncurses}
  s.add_dependency("ffi", ">= 0.6.3")
end
