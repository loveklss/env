" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
   finish
endif
let b:bid_ftplugin=1

"Close lookupfile window by two <ESC>
nnoremap <buffer> <Esc><Esc> <C-W>q
inoremap <buffer> <Esc><Esc> <Esc><C-W>q

