" ============================================================================
" File:        spec_runner.vim
" Description: runs specs (current file or current line)
" Maintainer:  David Elentok <3david at gmail dot com>
" ============================================================================

" Variables {{{1
if !exists('g:spec_runner_use_vimux')
  let g:spec_runner_use_vimux = 0
end

if !exists('g:spec_runners')
  let g:spec_runners = {
    \ "ruby": {
    \   "command": "rspec {file}",
    \   "can_run_line": 1
    \ },
    \ "coffee": {
    \   "command": "mocha --compilers coffee:coffee-script --reporter spec {file}"
    \ }
    \}

  if exists('g:user_spec_runners')
    for type in keys(g:user_spec_runners)
      let runner = g:user_spec_runners[type]
      if has_key(g:spec_runners, type)
        for key in keys(runner)
          let g:spec_runners[type][key] = runner[key]
        endfor
      else
        let g:spec_runners[type] = runner
      end
    endfor
  end
end

" Public Functions {{{1
func! RunSpecFile()
  if (has_key(g:spec_runners, &filetype))
    let cmd = g:spec_runners[&filetype]['command']
    call s:RunSpecCommand(cmd)
  end
endfunc

func! RunSpecLine()
  if (s:CanRunSpecLine())
    let cmd = g:spec_runners[&filetype]['command'] . ":" . line('.')
    call s:RunSpecCommand(cmd)
  else
    call RunSpecFile()
  end
endfunc

" Private Functions {{{1
func! s:CanRunSpecLine()
  if (has_key(g:spec_runners, &filetype))
    let runner = g:spec_runners[&filetype]
    return (has_key(runner, 'can_run_line') && runner['can_run_line'])
  end
  return 0
endfunc

func! s:RunSpecCommand(command)
  let cmd = substitute(a:command, '{file}', s:GetCurrentFileName(), 'g')
  if (g:spec_runner_use_vimux)
    call VimuxRunCommand("clear\n" . cmd)
  else
    exec "!" . cmd
  end
endfunc

func! s:GetCurrentFileName()
  return substitute(expand('%'), '^./', '', '')
endfunc

" Key mapping {{{1
map \r :call RunSpecLine()<cr>
map \R :call RunSpecFile()<cr>
map \\ :VimuxRunLastCommand<cr>

" vim: foldmethod=marker
