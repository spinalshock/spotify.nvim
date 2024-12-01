local M = {}
local previous_volume = nil
local last_song_info = nil -- To store the last known song info

-- Utility function to run a Bash script
local function run_script(script_name)
  local script_dir = vim.fn.stdpath 'config' .. '/lua/plugins/spotify.nvim/lua/spotify/scripts/'
  local script_path = vim.fn.expand(script_dir .. script_name)
  local result = vim.fn.system('bash ' .. vim.fn.shellescape(script_path))

  -- Handle errors
  if vim.v.shell_error ~= 0 then
    vim.notify('Error running Spotify script: ' .. result, vim.log.levels.ERROR)
    return nil
  end
  return result
end

local function notify_user(message, level)
  level = level or 'info'
  if pcall(require, 'noice') then
    require('noice').notify(message, level, { title = 'Spotify' })
  else
    vim.notify(message, vim.log.levels[string.upper(level)] or vim.log.levels.INFO, { title = 'Spotify' })
  end
end

local function trim(s)
  return s:match '^%s*(.-)%s*$'
end

-- Play/Pause
function M.play_pause()
  run_script 'playpause.sh'

  -- Call the info function to display the updated song
  M.info()
end

-- Next Track
function M.next(repeat_count)
  repeat_count = repeat_count or 1
  for _ = 1, repeat_count do
    run_script 'next-track.sh'
  end

  -- Call the info function to display the updated song
  M.info()
end

-- Previous Track
function M.previous(repeat_count)
  repeat_count = repeat_count or 1
  for _ = 1, repeat_count do
    run_script 'previous-track.sh'
  end

  -- Call the info function to display the updated song
  M.info()
end

-- Volume Up
function M.volume_up(repeat_count)
  repeat_count = repeat_count or 1
  for _ = 1, repeat_count do
    run_script 'volume-up.sh'
  end

  -- Call the sound_volume function to display the current volume
  M.sound_volume()
end

-- Volume Down
function M.volume_down(repeat_count)
  repeat_count = repeat_count or 1
  for _ = 1, repeat_count do
    run_script 'volume-down.sh'
  end

  -- Call the sound_volume function to display the current volume
  M.sound_volume()
end

-- Mute Toggle
function M.mute_toggle()
  local current_volume = tonumber(run_script 'sound-volume.sh')

  if current_volume == 0 then
    if previous_volume then
      M.volume_up(previous_volume / 10)
      previous_volume = nil
    else
      M.volume_up(10)
    end
  else
    previous_volume = current_volume
    M.volume_down(current_volume / 10)
  end
end

-- Shuffle Toggle
function M.shuffle_toggle()
  run_script 'shuffle-toggle.sh'
  -- Call the info function to display the updated song
  M.info()
end

-- Repeat Toggle
function M.repeat_toggle()
  run_script 'repeat-toggle.sh'
  -- Call the info function to display the updated song
  M.info()
end

-- Display Information
function M.info(force)
  -- Run the now-playing script and capture the output
  local song_info = run_script 'now-playing.sh'

  -- Trim whitespace or newlines from the output (fallback added if vim.trim doesn't work)
  song_info = vim.trim and vim.trim(song_info) or trim(song_info)

  if force then
    notify_user(song_info, 'info')
    return
  end
  -- If the song info has changed, notify the user
  if song_info ~= last_song_info then
    notify_user(song_info, 'info')
    last_song_info = song_info -- Update the last known song info
  end
end

function M.sound_volume()
  local volume = run_script 'sound-volume.sh'
  notify_user('Volume: ' .. volume, 'info')
end

-- Polling setup to check for song info changes every 3 seconds
local function start_polling()
  vim.loop.new_timer():start(0, 3000, function()
    -- Schedule the info check to run in the main thread
    vim.schedule(function()
      M.info() -- Check if the song info has changed and display it if necessary
    end)
  end)
end

function M.statusline()
  return last_song_info
end

-- Start polling when the plugin is set up
start_polling()

return M
