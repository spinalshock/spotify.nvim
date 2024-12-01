#!/bin/bash

osascript <<EOF
on max(x, y)
  if x ≥ y then
    return x
  end if
  return y
end max

tell application "Spotify" to set sound volume to (my max((sound volume - 9), 0))
EOF
