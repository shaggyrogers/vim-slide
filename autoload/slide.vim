""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" slide.vim
" =========
"
" Description:           Contains all the functionality for this plugin.
" Author:                Michael De Pasquale <shaggyrogers>
" Creation Date:         2019-07-21
" Modification Date:     2019-12-09
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set up options and mappings.
function! slide#Init() abort "{{{
    noremap  <SID>SlideLeft  <cmd>call <SID>Move('left',  g:slide#LeftRight#Pattern)<CR>
    noremap  <SID>SlideDown  <cmd>call <SID>Move('down',  g:slide#UpDown#Pattern)<CR>
    noremap  <SID>SlideUp    <cmd>call <SID>Move('up',    g:slide#UpDown#Pattern)<CR>
    noremap  <SID>SlideRight <cmd>call <SID>Move('right', g:slide#LeftRight#Pattern)<CR>
    onoremap <SID>SlideLeft  <cmd>call <SID>Move('left',  g:slide#LeftRight#Pattern, -1)<CR>
    onoremap <SID>SlideDown  <cmd>call <SID>Move('down',  g:slide#UpDown#Pattern)<CR>
    onoremap <SID>SlideUp    <cmd>call <SID>Move('up',    g:slide#UpDown#Pattern, -1)<CR>
    onoremap <SID>SlideRight <cmd>call <SID>Move('right', g:slide#LeftRight#Pattern)<CR>

    noremap <unique> <script> <nowait> <Plug>SlideLeft  <SID>SlideLeft
    noremap <unique> <script> <nowait> <Plug>SlideDown  <SID>SlideDown
    noremap <unique> <script> <nowait> <Plug>SlideUp    <SID>SlideUp
    noremap <unique> <script> <nowait> <Plug>SlideRight <SID>SlideRight

    if g:slide#DefaultMappings
        if maparg('<M-h>') != '' || maparg('<M-j>') != ''
                    \ || maparg('<M-k>') != '' || maparg('<M-l>') != ''
            let l:warn = 'Slide: Not setting default mappings, one or more of'
                        \ . ' ALT + h/j/k/l are already in use.'
                        \ . ' Set g:slide#DefaultMappings = 0 in your .vimrc or'
                        \ . ' remove these mappings.'
            echohl WarningMsg | echomsg l:warn | echohl None
            let v:warningmsg = l:warn
            return
        endif

        map <unique> <nowait> <M-h> <Plug>SlideLeft
        map <unique> <nowait> <M-j> <Plug>SlideDown
        map <unique> <nowait> <M-k> <Plug>SlideUp
        map <unique> <nowait> <M-l> <Plug>SlideRight
    endif
endfunction " }}}

" Move through whitespace/non-whitespace characters.
" Arguments: dir, [pattern], [offset]
"  * dir         String     Can be "left", "right", "up" or "down".
"  * pattern     String     A regular expression matching a single character.
"  * offset      Number     Adjusts the number of steps in the specified
function! s:Move(dir, ...) abort " {{{
    if a:0 > 2
        throw 'slide: Expected 1 - 3 arguments, got ' . a:0
    endif

    let l:dir = tolower(a:dir)
    let l:exp = get(a:, '1', '\S')

    " Find new position
    if l:dir == 'up' || l:dir == 'down'
        let l:pos = s:MoveUD(l:dir, l:exp, v:count1)
    elseif l:dir == 'left' || l:dir == 'right'
        let l:pos = s:MoveLR(l:dir, l:exp, v:count1)
    else
        throw printf('Unrecognised direction %s. Expected up, down, left or right.', l:dir)
    endif

    if l:pos is v:null
        return
    endif

    " Apply offset
    let l:off = get(a:, '2', 0) * (l:dir == 'up' || l:dir == 'left' ? -1 : 1)

    if l:dir == 'up' || l:dir == 'down'
        let l:pos[1] = max([1, min([line('$'), l:pos[1] + l:off])])
    else
        let l:col = max([1, min([len(getline(l:pos[1])), l:pos[2] + l:off])])
        let l:pos[2] = l:col
        let l:pos[4] = l:col
    endif

    if l:pos is v:null
        return
    endif

    " Add to jumplist
    if (g:slide#JumpList#Lines > 0
                \ && abs(line('.') - l:pos[1]) >= g:slide#JumpList#Lines)
            \ || (g:slide#JumpList#Columns > 0
                \ && abs(col('.') - l:pos[2]) >= g:slide#JumpList#Columns)
        execute "normal! m'"
    endif

    " Move cursor
    call setpos('.', l:pos)

    " Open folds if moving left/right
    if l:dir == 'left' || l:dir == 'right'
        execute 'normal! zv'
    endif
endfunction "}}}

" Move left and right.
function! s:MoveLR(dir, pat, count) abort " {{{
    let l:curpos = getcurpos()
    let l:text = getline('.')

    if a:dir == 'left' && l:curpos[2] <= 1 || a:dir == 'right' && l:curpos[2] >= len(l:text)
        return v:null
    endif

    " FIXME: Handle wrapped lines
    let l:wrapBack = &wrap

    if &wrap
        let &wrap = 0
    endif

    let l:p1 = '(\m' . a:pat . '\v)'
    let l:p2 = '(\m' . a:pat . '\v)@='
    let l:P1 = '(\m' . a:pat . '\v)@<!'
    let l:P2 = '(\m' . a:pat . '\v)@!'

    if g:slide#LeftRight#Skip
        let l:pat = printf('((%s%s%s)|(%s%s%s)|$|^)', l:P1, l:P1, l:p1, l:P1, l:p1, l:p2)
    else
        let l:pat = printf('((%s%s)|(%s%s)|$|^)', l:P1, l:p1, l:p1, l:P2)
    endif

    " Find match
    let l:col = l:curpos[2]
    let l:lastCol = v:null
    let l:lineLen = len(l:text)

    if a:dir == 'left'
        let l:text = join(reverse(split(l:text, '\zs')), '')
        let l:col = l:lineLen - l:curpos[2]
    endif

    for l:i in range(1, a:count)
        let l:col = match(l:text, '\v%>'. min([l:col + 1, l:lineLen - 1]) . 'v' . l:pat)

        if l:col == -1 || l:col is l:lastCol
            let l:col = l:lastCol
            break
        endif

        let l:lastCol = l:col
    endfor

    if l:wrapBack
        let &wrap = 1
    endif

    if l:col is v:null
        return v:null
    endif

    call assert_true(l:col > 0 && l:col <= l:lineLen)
    let l:col = a:dir == 'left' ? l:lineLen - l:col : l:col + 1
    let l:curpos[2:4] = [l:col, 0, l:col]

    return l:curpos
endfunction
"}}}

" Check if a character at a given line and virtual column matches the specified
" pattern.
function! s:CheckScreenChar(line, vcol, pat) abort "{{{
    let l:vchar = matchstr(getline(a:line), '\m\%' . a:vcol . 'v.')
    return l:vchar == '' ? v:false : match(l:vchar, a:pat) != -1
endfunction  "}}}

" Get a buffer column for a given virtual column on a given line.
function! s:ScreenToBufferColumn(line, vcol) abort  "{{{
    let l:text = getline(a:line)
    let l:result = match(l:text, '\m\%>' . a:vcol . 'v.')
    return l:result == -1 ? len(l:text) : l:result
endfunction  "}}}

" Move up and down.
function! s:MoveUD(dir, pat, count) abort " {{{
    let [l:curpos, l:step] = [getcurpos(), a:dir == 'up' ? -1 : 1]
    let [l:line, l:col, l:lastLine] = [l:curpos[1], virtcol('.'), line('$')]

    " Can't move past the start/end of the buffer.
    if l:line == 1 && a:dir == 'up' || l:line == l:lastLine && a:dir == 'down'
        return v:null
    endif

    function! s:DoSkipFolds(line, step)
        if !g:slide#Folds#Skip
            return a:line
        endif

        let l:foldend = a:step == 1 ? foldclosedend(a:line) : foldclosed(a:line)

        return l:foldend == -1 ? a:line : l:foldend
    endfunction

    function! s:StepUD(line, col, step, pat, lastLine)
        let l:newline = s:DoSkipFolds(a:line, a:step) + a:step
        let l:startMatch = !s:CheckScreenChar(l:newline, a:col, a:pat)

        " Keep stepping until transition (!match -> match or match -> !match)
        while !s:CheckScreenChar(l:newline, a:col, a:pat) == l:startMatch
                    \ && 1 <= l:newline && l:newline <= a:lastLine
            let l:newline = s:DoSkipFolds(l:newline + a:step, a:step)
        endwhile

        return l:startMatch ? l:newline : l:newline - a:step
    endfunction

    " Trace path up/down along virtual column
    for l:i in range(1, a:count)
        let l:line = s:StepUD(l:line, l:col, l:step, a:pat, l:lastLine)
    endfor

    " Convert virtual column to buffer column
    let l:col = s:ScreenToBufferColumn(l:line, l:col)
    let l:curpos[1:2] = [l:line, l:col]

    return l:curpos
endfunction " }}}

" vim: set ts=4 sw=4 tw=79 fdm=marker ff=unix fenc=utf-8 et :
