#!/bin/bash

osascript <<EOF
if application "Spotify" is running
  tell application "Spotify"
    playpause
  end tell
end if
EOF
