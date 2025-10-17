-- ~/.config/nvim/lua/theme-sync.lua
local M = {}

function M.set_theme_from_env()
  local mac_theme = os.getenv 'MAC_THEME'

  if mac_theme == 'dark' then
    -- Dark theme
    vim.cmd 'colorscheme catppuccin-frappe'
    vim.notify('🌙 Neovim: Catppuccin Frappe (dark)', vim.log.levels.INFO)
  elseif mac_theme == 'light' then
    -- Light theme
    vim.cmd 'colorscheme catppuccin-latte'
    vim.notify('☀️ Neovim: Catppuccin Latte (light)', vim.log.levels.INFO)
  else
    -- Fallback - detect system theme on Mac, default to dark on server
    local is_mac = vim.fn.has 'mac' == 1
    if is_mac then
      -- On Mac, try to detect system theme
      local handle = io.popen 'defaults read -globalDomain AppleInterfaceStyle 2>/dev/null'
      if handle then
        local result = handle:read '*a'
        handle:close()

        if result:match 'Dark' then
          vim.cmd 'colorscheme catppuccin-frappe'
          vim.notify('🌙 Neovim: Mac dark mode → Catppuccin Frappe', vim.log.levels.INFO)
        else
          vim.cmd 'colorscheme catppuccin-latte'
          vim.notify('☀️ Neovim: Mac light mode → Catppuccin Latte', vim.log.levels.INFO)
        end
      end
    else
      -- On server, use MAC_THEME or default to dark
      vim.cmd 'colorscheme catppuccin-frappe'
      vim.notify('🖥️ Neovim: Server default → Catppuccin Frappe', vim.log.levels.INFO)
    end
  end
end

function M.toggle_theme()
  -- Manual theme toggle for testing
  local current_theme = vim.g.colors_name
  if current_theme == 'catppuccin-latte' then
    vim.cmd 'colorscheme catppuccin-frappe'
    vim.notify('🌙 Switched to Catppuccin Frappe', vim.log.levels.INFO)
  else
    vim.cmd 'colorscheme catppuccin-latte'
    vim.notify('☀️ Switched to Catppuccin Latte', vim.log.levels.INFO)
  end
end

return M
