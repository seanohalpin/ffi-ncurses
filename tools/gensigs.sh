#!/bin/bash
#echo $0
#echo $(dirname $0)
BASEDIR=$(dirname $0)
cd $BASEDIR
# INPUT_FILE=/usr/include/ncursesw/ncurses.h
INPUT_FILE=ncurses-all.h
# INPUT_FILE=ncurses.h
# INPUT_FILE=/usr/include/ncurses.h
# Preprocess, strip out =#line= numbers and blank lines:
cpp -DNCURSES_NOMACROS -DNCURSES_OPAQUE -D_XOPEN_SOURCE_EXTENDED -imacros stdio.h -imacros wchar.h $INPUT_FILE | egrep -v "^\s*$" | grep -v "^#" > stage1.h
# Generate FFI signatures:
ruby gentypes.rb $* stage1.h > functions.rb 2>unmapped-functions.rb
ruby wrap_bools.rb > bool_wrappers.rb
# fixup
cp functions.rb bool_wrappers.rb ../lib/ffi-ncurses/

