#!/bin/bash

osascript <<EOF
tell application "Spotify"
    if not repeating then
        set repeating to true
    else
        set repeating to false
    end if
end tell
EOF
