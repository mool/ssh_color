#!/bin/bash

default_fg="{51143,51143,51143}"

# First, check to see if we have the correct terminal!
if [ "$(tty)" == 'not a tty' ] || [ "$TERM_PROGRAM" != "iTerm.app" ] ; then
  /usr/bin/ssh "$@"
  exit $?
fi

function set_fg {
  local tty=$(tty)
  osascript -e "
    tell application \"iTerm\"
      repeat with theTerminal in terminals
        tell theTerminal
          try
            tell session id \"$tty\"
              set foreground color to $1
            end tell
          on error errmesg number errn
          end try
        end tell
      end repeat
    end tell"
}

on_exit () {
  set_fg "$default_fg"
}
trap on_exit EXIT

host=$(echo $1 | cut -d"@" -f2)
match=$(cat ~/.ssh_color | grep $host | wc -l)
if [ $match -gt 0 ]
then
  color=$(cat ~/.ssh_color | grep $host | cut -f2 -d":")
  set_fg "$color"
fi

/usr/bin/ssh "$@"
