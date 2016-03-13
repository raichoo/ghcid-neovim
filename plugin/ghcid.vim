if exists("g:loaded_ghcid")
  finish
endif

let g:loaded_ghcid = 1

let g:ghcid_running = {}

function! ghcid#loadGhcid()
  let l:cwd = getcwd()
  if has_key(g:ghcid_running,l:cwd)
    call jobsend(g:ghcid_running[l:cwd], ":load Main\n")
    call jobsend(g:ghcid_running[l:cwd], ":main\n")
    call jobstart('inotifywait -re modify ' . l:cwd, { 'on_exit': function('ghcid#reloadGhcid') })
  endif
endfunction

function! ghcid#reloadGhcid()
  let l:cwd = getcwd()
  if has_key(g:ghcid_running, l:cwd)
    call jobsend(g:ghcid_running[l:cwd], ":reload\n")
    call ghcid#loadGhcid()
  endif
endfunction

function! ghcid#startGhcid(...)
  setfiletype ghcid
  au BufUnload <buffer> call ghcid#stopGhcid()
  let l:com = ''
  if a:0 == 1
    let l:com = ' ' . a:1
  endif
  let l:cwd = getcwd()
  if !has_key(g:ghcid_running, l:cwd)
    let g:ghcid_running[l:cwd] = termopen('stack ghci' . l:com, { 'on_exit': function('ghcid#cleanupGhcid') })
    call ghcid#loadGhcid()
  endif
endfunction

function! ghcid#stopGhcid()
  let l:cwd = getcwd()
  if has_key(g:ghcid_running, l:cwd)
    call jobsend(g:ghcid_running[l:cwd], ":quit\n")
    call ghcid#cleanupGhcid()
  endif
endfunction

function! ghcid#cleanupGhcid()
  let l:cwd = getcwd()
  if has_key(g:ghcid_running, l:cwd)
    unlet g:ghcid_running[l:cwd]
  endif
endfunction

command! -nargs=? GhcidStart call ghcid#startGhcid(<f-args>)
command! GhcidStop call ghcid#stopGhcid()
command! GhcidReload call ghcid#reloadGhcid()

