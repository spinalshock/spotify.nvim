#!/bin/bash

osascript <<EOF
if application "Spotify" is running
  tell application "Spotify"
    previous track
  end tell
end if
EOF