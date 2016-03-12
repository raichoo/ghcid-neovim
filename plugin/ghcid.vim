if exists("g:loaded_ghcid")
  finish
endif

let g:loaded_ghcid = 1

function! ghcid#loadGhcid()
  if exists('g:haskell_ghcid')
    call jobsend(g:haskell_ghcid, ":load Main\n")
    call jobsend(g:haskell_ghcid, ":main\n")
    call jobstart('inotifywait -re modify .', { 'on_exit': function('ghcid#reloadGhcid') })
  endif
endfunction

function! ghcid#reloadGhcid()
  if exists('g:haskell_ghcid')
    call jobsend(g:haskell_ghcid, ":reload\n")
    call ghcid#loadGhcid()
  endif
endfunction

function! ghcid#startGhcid()
  if !exists('g:haskell_ghcid')
    let g:haskell_ghcid = termopen('stack ghci', { 'on_exit': function('ghcid#cleanupGhcid') })
    call ghcid#loadGhcid()
  endif
endfunction

function! ghcid#stopGhcid()
  if exists('g:haskell_ghcid')
    call jobsend(g:haskell_ghcid, ":quit\n")
    call ghcid#cleanupGhcid()
  endif
endfunctio

function! ghcid#cleanupGhcid()
  if exists('g:haskell_ghcid')
    unlet g:haskell_ghcid
  endif
endfunction

command! GhcidStart call ghcid#startGhcid()
command! GhcidStop call ghcid#stopGhcid()
command! GhcidReload call ghcid#reloadGhcid()

au VimLeavePre *.hs call ghcid#stopGhcid()
