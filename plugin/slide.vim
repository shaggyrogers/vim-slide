""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" slide.vim
" =========
"
" Description:           Loads this plugin.
" Author:                Michael De Pasquale
" Creation Date:         2019-07-21
" Modification Date:     2020-02-25
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'loaded_slide', 0)
    finish
endif

let g:loaded_slide = 1

let s:cpo_save = &cpo
set cpo&vim


try
    " Option defaults
    let g:slide#DefaultMappings   = get(g:, 'slide#DefaultMappings',   1)
    let g:slide#Folds#Skip        = get(g:, 'slide#Folds#Skip',        1)
    let g:slide#JumpList#Columns  = get(g:, 'slide#JumpList#Columns',  2)
    let g:slide#JumpList#Lines    = get(g:, 'slide#JumpList#Lines',    2)
    let g:slide#LeftRight#Pattern = get(g:, 'slide#LeftRight#Pattern', '\S')
    let g:slide#LeftRight#Skip    = get(g:, 'slide#LeftRight#Skip',    1)
    let g:slide#UpDown#Pattern    = get(g:, 'slide#UpDown#Pattern',    '\S')

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

finally
    let &cpo = s:cpo_save
endtry

" vim: set ts=4 sw=4 tw=90 fdm=manual ff=unix fenc=utf-8 et :
