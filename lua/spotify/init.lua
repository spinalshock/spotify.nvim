local M = {}
local spotify_commands = require 'spotify.commands'

-- Default key mappings
local default_keymaps = {
  { name = 'play_pause',     mode = 'n', '<leader>pp', ':SpotifyPlayPause<CR>',     desc = 'Play/Pause Spotify' },
  { name = 'next',           mode = 'n', '<leader>pn', ':<C-U>SpotifyNext<CR>',     desc = 'Next Spotify Track' },
  { name = 'previous',       mode = 'n', '<leader>pb', ':<C-U>SpotifyPrev<CR>',     desc = 'Previous Spotify Track' },
  { name = 'volume_up',      mode = 'n', '<leader>+',  ':<C-U>SpotifyVolUp<CR>',    desc = 'Increase Spotify Volume' },
  { name = 'volume_down',    mode = 'n', '<leader>-',  ':<C-U>SpotifyVolDown<CR>',  desc = 'Decrease Spotify Volume' },
  { name = 'shuffle_toggle', mode = 'n', '<leader>ps', ':SpotifyToggleShuffle<CR>', desc = 'Toggle Spotify Shuffle' },
  { name = 'repeat_toggle',  mode = 'n', '<leader>pr', ':SpotifyToggleRepeat<CR>',  desc = 'Toggle Spotify Repeat' },
  { name = 'sound_volume',   mode = 'n', '<leader>pv', ':SpotifyVolume<CR>',        desc = 'Show Spotify Volume' },
  { name = 'info',           mode = 'n', '<leader>pi', ':SpotifyInfo<CR>',          desc = 'Show Spotify Info' },
  { name = 'mute_toggle',    mode = 'n', '<leader>pm', ':SpotifyToggleMute<CR>',    desc = 'Toggle Spotify Mute' },
}

-- Utility function to apply key mappings
local function apply_keymaps(keymaps)
  for _, keymap in ipairs(keymaps) do
    vim.api.nvim_set_keymap(
      keymap.mode or 'n',                                                                                    -- Default mode is normal
      keymap[1],                                                                                             -- Key sequence
      keymap[2],                                                                                             -- Command
      vim.tbl_deep_extend('force', { noremap = true, silent = true, desc = keymap.desc }, keymap.opts or {}) -- Merge user-provided options
    )
  end
end

-- Function to set up the plugin
function M.setup(user_opts)
  -- Start with a copy of default keymaps
  local opts = vim.tbl_deep_extend('force', {}, user_opts or {})

  -- Initialize opts.keymaps with a copy of default_keymaps
  opts.keymaps = vim.list_extend({}, default_keymaps)

  -- If user opts provide keymaps, we need to process them
  if user_opts.keymaps then
    -- Iterate over each user keymap and remove matching default keymap based on 'name'
    for _, user_keymap in ipairs(user_opts.keymaps) do
      -- Iterate over the default keymaps and remove any keymap with the same 'name'
      for i, default_keymap in ipairs(opts.keymaps) do
        if default_keymap.name == user_keymap.name then
          table.remove(opts.keymaps, i) -- Remove the matching default keymap
          break                         -- No need to continue looking for this keymap
        end
      end
    end

    -- Now we merge the user keymaps into opts.keymaps
    vim.list_extend(opts.keymaps, user_opts.keymaps)
  end

  -- Register commands
  vim.api.nvim_create_user_command('SpotifyPlayPause', spotify_commands.play_pause, {})
  vim.api.nvim_create_user_command('SpotifyNext', function()
    spotify_commands.next(vim.v.count1)
  end, {})
  vim.api.nvim_create_user_command('SpotifyPrev', function()
    spotify_commands.previous(vim.v.count1)
  end, {})
  vim.api.nvim_create_user_command('SpotifyVolUp', function()
    spotify_commands.volume_up(vim.v.count1)
  end, {})
  vim.api.nvim_create_user_command('SpotifyVolDown', function()
    spotify_commands.volume_down(vim.v.count1)
  end, {})
  vim.api.nvim_create_user_command('SpotifyToggleMute', spotify_commands.mute_toggle, {})
  vim.api.nvim_create_user_command('SpotifyToggleShuffle', spotify_commands.shuffle_toggle, {})
  vim.api.nvim_create_user_command('SpotifyToggleRepeat', spotify_commands.repeat_toggle, {})
  vim.api.nvim_create_user_command('SpotifyVolume', spotify_commands.sound_volume, {})
  vim.api.nvim_create_user_command('SpotifyInfo', function()
    spotify_commands.info(true)
  end, {})

  -- Apply key mappings
  apply_keymaps(opts.keymaps)
end

return M
