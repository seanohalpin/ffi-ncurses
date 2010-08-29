#!/bin/bash
# INPUT_FILE=/usr/include/ncursesw/ncurses.h
INPUT_FILE=ncurses.h
# Preprocess, strip out =#line= numbers and blank lines:
cpp -DNCURSES_NOMACROS -DNCURSES_OPAQUE -D_XOPEN_SOURCE_EXTENDED -imacros stdio.h -imacros wchar.h $INPUT_FILE | egrep -v "^\s*$" | grep -v "^#" > stage1.h
# Generate FFI signatures:
ruby gentypes.rb stage1.h > cpp-gen.rb 2>cpp-unmapped.rb

