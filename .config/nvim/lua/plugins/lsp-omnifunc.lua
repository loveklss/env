-- Working LSP omnifunc implementation

-- Create a simple omnifunc that works with v:lua
local function lsp_complete(findstart, base)
  if findstart == 1 then
    -- Find the start of the current word
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    
    local start = col
    while start > 0 do
      local char = string.sub(line, start, start)
      if not string.match(char, '[%w_]') then
        break
      end
      start = start - 1
    end
    
    return start
  else
    -- Get completions from LSP
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = (vim.lsp.get_clients and vim.lsp.get_clients({bufnr = bufnr})) or vim.lsp.get_active_clients({bufnr = bufnr})
    
    if #clients == 0 then
      return {}
    end
    
    -- In Neovim 0.11+, make_position_params requires the window ID and client offset_encoding
    local win_id = vim.api.nvim_get_current_win()
    local params
    if vim.fn.has('nvim-0.11') == 1 then
      -- Use the offset_encoding from the first client that supports completion
      local encoding = "utf-16" -- fallback default
      for _, client in ipairs(clients) do
        if client.supports_method('textDocument/completion') then
          encoding = client.offset_encoding or "utf-16"
          break
        end
      end
      params = vim.lsp.util.make_position_params(win_id, encoding)
    else
      params = vim.lsp.util.make_position_params()
    end
    
    local results = {}
    
    -- Get completions from all LSP clients
    for _, client in ipairs(clients) do
      if client.supports_method('textDocument/completion') then
        local response = client.request_sync('textDocument/completion', params, 5000, bufnr)
        if response and response.result then
          local items = response.result.items or response.result
          if type(items) == 'table' then
            for _, item in ipairs(items) do
              if item.label then
                -- Filter based on the base text
                if base == '' or string.find(item.label:lower(), base:lower(), 1, true) then
                  table.insert(results, {
                    word = item.insertText or item.label,
                    abbr = item.label,
                    menu = item.detail or '',
                    info = item.documentation and (
                      type(item.documentation) == 'string' and item.documentation or
                      item.documentation.value or ''
                    ) or '',
                    kind = item.kind or 1,
                  })
                end
              end
            end
          end
        end
      end
    end
    
    return results
  end
end

-- Register the function globally so v:lua can access it
_G.lsp_omnifunc = lsp_complete

-- Register as Vim function using vim.cmd
vim.cmd([[
function! LspOmnifunc(findstart, base)
  return luaeval('_G.lsp_omnifunc(' . a:findstart . ', "' . escape(a:base, '"') . '")')
endfunction
]])

-- Return empty plugin table since this is just a utility module
return {}
