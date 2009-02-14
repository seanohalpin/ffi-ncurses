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

ensure_in_path 'lib'
require 'ffi-ncurses'

task :default => 'spec:run'

PROJ.name = 'ffi-ncurses'
PROJ.authors = ["Sean O'Halpin"]
PROJ.email = 'sean.ohalpin@gmail.com'
PROJ.url = 'http://github.com/seanohalpin/ffi-ncurses'
PROJ.summary = "FFI wrapper for ncurses"
PROJ.version = "0.2.0"
PROJ.rubyforge.name = 'ffi-ncurses'

PROJ.spec.opts << '--color'

PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc \.git)
PROJ.exclude << '^tags$'

PROJ.notes.extensions << '.org'

# EOF
