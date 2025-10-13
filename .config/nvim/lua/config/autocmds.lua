-- This file is for setting up autocommands

local api = vim.api

-- Helper function to create autocommand groups for organization.
local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- =============================================================================
-- GROUP: last_location
-- Purpose: Jump to the last known cursor position when opening a file.
-- =============================================================================
api.nvim_create_autocmd('BufReadPost', {
  group = augroup("last_location"),
  pattern = '*',
  callback = function()
    if vim.fn.line('"') > 1 and vim.fn.line('"') <= vim.fn.line('$') then
      api.nvim_exec('normal! g`"', false)
    end
  end,
  desc = "Jump to last cursor position on opening a file",
})

-- =============================================================================
-- GROUP: filetype_indent
-- Purpose: Set indentation rules based on the file type.
-- =============================================================================
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = 'php',
  command = 'setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120',
})
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = 'ruby',
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120',
})
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = {'coffee', 'javascript'},
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120',
})
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = 'python',
  command = 'setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120',
})
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = {'html', 'htmldjango', 'xhtml', 'haml'},
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=0',
})
api.nvim_create_autocmd('FileType', {
  group = augroup("filetype_indent"),
  pattern = {'sass', 'scss', 'css'},
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120',
})

-- =============================================================================
-- GROUP: jquery_syntax
-- Purpose: Use jQuery syntax for javascript files, as per .vimrc.
-- =============================================================================
api.nvim_create_autocmd('Syntax', {
    group = augroup("jquery_syntax"),
    pattern = 'javascript',
    command = 'set syntax=jquery',
})

-- =============================================================================
-- GROUP: custom_c_filetypes
-- Purpose: Recognize custom C/C++ file extensions (.tops, .cu, .cuh)
-- =============================================================================
vim.filetype.add({
  extension = {
    tops = 'cpp',
    cu = 'cpp',
    cuh = 'cpp',
  },
})
