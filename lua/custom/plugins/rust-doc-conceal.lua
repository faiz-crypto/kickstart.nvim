-- Visually replace Rust // and /// comments with C-style /* */ block comments.
-- The file on disk is never changed — this is purely a display transformation
-- using Neovim's extmark overlay feature.
-- When the cursor is on a comment line, the real syntax is revealed.
return {
  name = 'rust-doc-conceal',
  dir = vim.fn.stdpath('config'),
  ft = 'rust',
  config = function()
    local ns = vim.api.nvim_create_namespace('rust-doc-conceal')
    local state = {} -- per-buffer: { line_info = {}, revealed = nil }

    -- Scan buffer and build per-line conceal info
    local function compute(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- Classify each line: 'doc' for ///, 'line' for //, nil otherwise
      local line_types = {}
      for i, line in ipairs(lines) do
        if line:match('^%s*///') then
          line_types[i] = 'doc'
        elseif line:match('^%s*//') then
          line_types[i] = 'line'
        end
      end

      -- Group consecutive lines of the same comment type
      local groups = {}
      local cur = nil
      for i = 1, #lines do
        local lt = line_types[i]
        if lt then
          local lnum = i - 1
          if cur and cur.last == lnum - 1 and cur.kind == lt then
            cur.last = lnum
          else
            if cur then
              table.insert(groups, cur)
            end
            cur = { first = lnum, last = lnum, kind = lt }
          end
        else
          if cur then
            table.insert(groups, cur)
          end
          cur = nil
        end
      end
      if cur then
        table.insert(groups, cur)
      end

      local info = {}
      for _, g in ipairs(groups) do
        -- /// is 3 chars, // is 2 chars — replacements match width
        local width = g.kind == 'doc' and 3 or 2
        local first_label = g.kind == 'doc' and '/* ' or '/*'
        local mid_label = g.kind == 'doc' and ' * ' or ' *'
        local last_label = g.kind == 'doc' and ' * ' or ' *'

        for lnum = g.first, g.last do
          local line = lines[lnum + 1]
          local pat = g.kind == 'doc' and '///' or '//'
          local col = line:find(pat, 1, true) - 1
          info[lnum] = {
            col = col,
            width = width,
            label = lnum == g.first and first_label or mid_label,
            is_last = lnum == g.last,
          }
        end
      end
      return info
    end

    local function conceal_line(bufnr, lnum, info)
      -- Clear any existing marks on this line first
      local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { lnum, 0 }, { lnum, -1 }, {})
      for _, m in ipairs(marks) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, m[1])
      end

      vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, info.col, {
        end_col = info.col + info.width,
        virt_text = { { info.label, 'Comment' } },
        virt_text_pos = 'overlay',
      })
      if info.is_last then
        vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
          virt_text = { { ' */', 'Comment' } },
          virt_text_pos = 'eol',
        })
      end
    end

    local function reveal_line(bufnr, lnum)
      local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { lnum, 0 }, { lnum, -1 }, {})
      for _, m in ipairs(marks) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, m[1])
      end
    end

    local function full_update(bufnr)
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      local info = compute(bufnr)
      local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

      for lnum, li in pairs(info) do
        if lnum ~= cursor_lnum then
          conceal_line(bufnr, lnum, li)
        end
      end

      state[bufnr] = { line_info = info, revealed = cursor_lnum }
    end

    local function on_cursor_move(bufnr)
      local s = state[bufnr]
      if not s then
        return
      end

      local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      if cursor_lnum == s.revealed then
        return
      end

      -- Re-conceal the old revealed line
      local old = s.revealed
      if old and s.line_info[old] then
        conceal_line(bufnr, old, s.line_info[old])
      end

      -- Reveal the new cursor line
      if s.line_info[cursor_lnum] then
        reveal_line(bufnr, cursor_lnum)
      end

      s.revealed = cursor_lnum
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'rust',
      callback = function(ev)
        local bufnr = ev.buf
        full_update(bufnr)

        vim.api.nvim_buf_attach(bufnr, false, {
          on_lines = function()
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                full_update(bufnr)
              end
            end)
          end,
          on_detach = function()
            state[bufnr] = nil
          end,
        })

        local group = vim.api.nvim_create_augroup('rust-doc-conceal-' .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = group,
          buffer = bufnr,
          callback = function()
            on_cursor_move(bufnr)
          end,
        })
        vim.api.nvim_create_autocmd('BufWipeout', {
          group = group,
          buffer = bufnr,
          callback = function()
            state[bufnr] = nil
          end,
        })
      end,
    })
  end,
}
