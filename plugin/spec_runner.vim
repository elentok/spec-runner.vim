" ============================================================================
" File:        spec_runner.vim
" Description: runs specs (current file or current line)
" Maintainer:  David Elentok <3david at gmail dot com>
" ============================================================================

" Variables {{{1
let g:spec_runner_last_command = ''
let g:spec_runner_second_tmux_session = 'test-output'

" Public Functions {{{1
func! RunSpecFile()
  call s:RunSpec(-1)
endfunc

func! RunSpecLine()
  call s:RunSpec(line('.'))
endfunc

func! RunLastSpec()
  if (g:spec_runner_last_command != '')
    call s:RunSpecCommand(g:spec_runner_last_command)
  end
endfunc


" Private Functions {{{1
func! s:RunSpec(line)
  let cmd = GetSpecCommand(a:line)
  if cmd != ''
    let g:spec_runner_last_command = cmd
    call s:RunSpecCommand(cmd)
  end
endfunc

func! GetSpecCommand(line)
  if exists("b:spec_func")
    return {b:spec_func}(s:GetCurrentFileName(), a:line)
  else
    return ''
  end
endfunc

func! s:GetCurrentFileName()
  return substitute(expand('%'), '^./', '', '')
endfunc

func! s:RunSpecCommand(cmd)
  if s:IsSecondTmuxOpen()
    call s:RunWithSecondTmux(a:cmd)
  elseif IsInTmux()
    call s:RunWithVimux(a:cmd)
  else
    call "!" . a:cmd
  end
endfunc

func! IsInTmux()
  return $TMUX != ""
endfunc

func! s:RunWithVimux(command)
  call VimuxRunCommand("cd " . getcwd() . "; clear")
  call VimuxClearRunnerHistory()
  call VimuxRunCommand(a:command)
endfunc

func! s:RunWithSecondTmux(command)
  call s:SendToSecondTmux("cd " . getcwd())
  call s:SendToSecondTmux("clear")
  call s:SendToSecondTmux("tmux clear-history")
  call s:SendToSecondTmux(a:command)
endfunc

func! s:SendToSecondTmux(command)
  call system("tmux send-keys -t " . g:spec_runner_second_tmux_session . " \"" . a:command . "\" Enter")
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
nnoremap <Leader>tl :w<cr>:call RunSpecLine()<cr>
nnoremap <Leader>tf :w<cr>:call RunSpecFile()<cr>
nnoremap <Leader>tt :w<cr>:call RunLastSpec()<cr>

command! -nargs=* SpecArgs call SetSpecArgs("<args>")
command! -nargs=* ClearSpecArgs call ClearSpecArgs()

" vim: foldmethod=marker
