#!/bin/sh
for p in *.rb; do
  if [ "$p" = "newterm.rb" ]; then
    echo Not running $p
  elif [ "$p" = "multiterm.rb" ]; then
    echo Not running $p
  elif [ "$p" = "viewer.rb" ]; then
    echo $p
    ruby $p $p
  else
    echo $p
    ruby $p
  fi
done
