#!/bin/bash

osascript <<EOF
on min(x, y)
  if x ≤ y then
    return x
  end if
  return y
end min

tell application "Spotify" to set sound volume to (my min(( sound volume + 11 ), 100))
EOF
