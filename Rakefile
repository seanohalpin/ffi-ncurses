# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

if File.exist?('local/config.rb')
  load 'local/config.rb'
end

ensure_in_path 'lib'
require 'ffi-ncurses'

task :default => 'spec:run'

# see tasks/setup.rb for full list of options

PROJ.name = 'ffi-ncurses'
PROJ.authors = ["Sean O'Halpin"]
PROJ.email = 'sean.ohalpin@gmail.com'
PROJ.url = 'http://github.com/seanohalpin/ffi-ncurses'
PROJ.summary = "FFI wrapper for ncurses"
PROJ.version = FFI::NCurses::VERSION
PROJ.rubyforge.name = 'ffi-ncurses'

PROJ.description = <<EOT
A wrapper for ncurses 5.x. Tested on Mac OS X 10.4 (Tiger) and Ubuntu
8.04 with ruby 1.8.6 using ruby-ffi (>= 0.2.0) and JRuby 1.1.6.

The API is very much a transliteration of the C API rather than an
attempt to provide an idiomatic Ruby object-oriented API. The intent
is to provide a 'close to the metal' wrapper around the ncurses
library upon which you can build your own abstractions.

See the examples directory for real working examples.
EOT

# gem
# PROJ.gem.dependencies << ["ffi", ">= 0.2.0"]

# rdoc
PROJ.rdoc.exclude << "^notes"
PROJ.readme_file = 'README.rdoc'

# spec
PROJ.spec.opts << '--color'

# files
PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc \.git local notes)
PROJ.exclude << '^tags$' << "^bug" << "^tools"
PROJ.exclude << File.read('.gitignore').split(/\n/)

# notes
#PROJ.notes.exclude = %w(^README\.txt$ ^data/)
PROJ.notes.extensions << '.org'

# EOF
