" ============================================================================
" File:        spec_runner.vim
" Description: runs specs (current file or current line)
" Maintainer:  David Elentok <3david at gmail dot com>
" ============================================================================

" Variables {{{1
if !exists('g:spec_runner_mode')
  let g:spec_runner_mode = 'normal'
  " available options:
  " - vimux => uses vimux
  " - second-tmux => uses a secondary tmux session called "test-output"
end

let g:spec_runner_last_command = ''

if !exists('g:spec_runners')
  let g:spec_runners = {
    \ "vim": {
    \   "command": "vimspec"
    \ },
    \ "ruby": {
    \   "command": "rspec {file}",
    \   "can_run_line": 1
    \ },
    \ "coffee": {
    \   "command": "mocha --debug --compilers coffee:coffee-script --reporter spec {file}"
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
  let cmd = s:GetSpecCommand()
  if (cmd != '')
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
func! s:GetSpecCommand()
  if exists('g:override_spec_runner') && g:override_spec_runner != ''
    return g:override_spec_runner
  elseif (has_key(g:spec_runners, &filetype))
    return g:spec_runners[&filetype]['command']
  else
    return ''
  end
endfunc

func! s:CanRunSpecLine()
  if (has_key(g:spec_runners, &filetype))
    let runner = g:spec_runners[&filetype]
    return (has_key(runner, 'can_run_line') && runner['can_run_line'])
  end
  return 0
endfunc

func! s:SendToSecondTmux(command)
  call system("tmux send-keys -t test-output \"" . a:command . "\" Enter")
endfunc

func! s:RunSpecCommand(command)
  let cmd = substitute(a:command, '{file}', s:GetCurrentFileName(), 'g')
  let g:spec_runner_last_command = cmd
  if (g:spec_runner_mode == 'vimux')
    call VimuxRunCommand("clear\n" . cmd)
  elseif (g:spec_runner_mode == 'second-tmux')
    call s:SendToSecondTmux("clear")
    call s:SendToSecondTmux("cd " . getcwd())
    call s:SendToSecondTmux(cmd)
  else
    exec "!" . cmd
  end
endfunc

func! s:GetCurrentFileName()
  return substitute(expand('%'), '^./', '', '')
endfunc

func! RunLastSpec()
  if (g:spec_runner_last_command != '')
    call s:RunSpecCommand(g:spec_runner_last_command)
  end
endfunc


" Key mapping {{{1
map \r :call RunSpecLine()<cr>
map \R :call RunSpecFile()<cr>
map \\ :call RunLastSpec()<cr>

" vim: foldmethod=marker
