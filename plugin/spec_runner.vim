" ============================================================================
" File:        spec_runner.vim
" Description: runs specs (current file or current line)
" Maintainer:  David Elentok <3david at gmail dot com>
" ============================================================================

" Variables {{{1
let g:spec_runner_last_command = ''
let g:spec_runner_second_tmux_session = 'test-output'

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

func! s:RunSpecCommand(command)
  let cmd = s:ProcessCommand(a:command)

  if s:IsSecondTmuxOpen()
    call s:RunWithSecondTmux(cmd)
  elseif IsInTmux()
    call s:RunWithVimux(cmd)
  else
    call "!" . cmd
  end
endfunc

func! s:ProcessCommand(command)
  let cmd = substitute(a:command, '{file}', s:GetCurrentFileName(), 'g')
  if ((cmd != g:spec_runner_last_command) && exists('b:spec_runner_extra_args'))
    let cmd .= ' ' . b:spec_runner_extra_args
  end
  let g:spec_runner_last_command = cmd
  return cmd
endfunc

func! s:GetCurrentFileName()
  return substitute(expand('%'), '^./', '', '')
endfunc

func! IsInTmux()
  return $TMUX != ""
endfunc

func! s:RunWithVimux(command)
  call VimuxRunCommand("clear\n" . a:command)
endfunc

func! s:RunWithSecondTmux(command)
  call s:SendToSecondTmux("clear")
  call s:SendToSecondTmux("cd " . getcwd())
  call s:SendToSecondTmux(a:command)
endfunc

func! s:SendToSecondTmux(command)
  call system("tmux send-keys -t " . g:spec_runner_second_tmux_session . " \"" . a:command . "\" Enter")
endfunc

func! RunLastSpec()
  if (g:spec_runner_last_command != '')
    call s:RunSpecCommand(g:spec_runner_last_command)
  end
endfunc

func! SetSpecArgs(args)
  if (a:args == "")
    if exists("b:spec_runner_extra_args")
      echo "Current spec args: [" . b:spec_runner_extra_args . "]"
    else
      echo "No spec args defined"
    endif
  else
    let b:spec_runner_extra_args = a:args
  endif
endfunc

func! s:IsSecondTmuxOpen()
  return system("tmux ls -F '#{session_name}' | grep '^" . g:spec_runner_second_tmux_session . "$'") != ""
endfunc

func! ClearSpecArgs()
  if exists("b:spec_runner_extra_args")
    unlet b:spec_runner_extra_args
  end
endfunc

" Key mapping {{{1
nnoremap <Leader>tl :call RunSpecLine()<cr>
nnoremap <Leader>tf :call RunSpecFile()<cr>
nnoremap <Leader>tt :call RunLastSpec()<cr>

command! -nargs=* SpecArgs let g:spec_runner_extra_args="<args>"

" vim: foldmethod=marker
