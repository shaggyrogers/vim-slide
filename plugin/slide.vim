""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" slide.vim
" =========
"
" Description:           Loads this plugin.
" Author:                Michael De Pasquale
" Creation Date:         2019-07-21
" Modification Date:     2019-09-05
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'loaded_slide', 0)
    finish
endif

" Option defaults
let g:slide#UpDownPattern    = get(g:, 'slide#UpDownPattern',    '\S')
let g:slide#LeftRightPattern = get(g:, 'slide#LeftRightPattern', '\S')
let g:slide#LeftRightSkip    = get(g:, 'slide#LeftRightSkip',    1)
let g:slide#JumpMinColumns   = get(g:, 'slide#JumpMinColumns',   2)
let g:slide#JumpMinLines     = get(g:, 'slide#JumpMinLines',     2)
let g:slide#DefaultMaps      = get(g:, 'slide#DefaultMaps',      1)

" Initialise once vimrcs are loaded, to ensure we respect slide#DefaultMaps.
if v:vim_did_enter
    call slide#Init()
else
    augroup SlideInitialise
        au!
        autocmd VimEnter *
                    \ call slide#Init()
                    \ | execute 'autocmd! SlideInitialise'
                    \ | silent! execute 'augroup! SlideInitialise'
    augroup END
endif

let g:loaded_slide = 1

" vim: set ts=4 sw=4 tw=79 fdm=manual fenc=utf-8 et :
