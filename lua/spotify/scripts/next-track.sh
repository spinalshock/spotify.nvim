#!/bin/bash

osascript <<EOF
if application "Spotify" is running
  tell application "Spotify"
    next track
  end tell
end if
EOF
