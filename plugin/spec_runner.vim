" ============================================================================
" File:        spec_runner.vim
" Description: runs specs (current file or current line)
" Maintainer:  David Elentok <3david at gmail dot com>
" ============================================================================

" Variables {{{1
let g:spec_runner_last_command = ''
let g:spec_runner_second_tmux_session = 'test-output'

let g:spec_runner_root = expand("<sfile>:p:h") . "/../"
let g:spec_runner_bin = "python " . g:spec_runner_root . "spec_runner.py"

" Public Functions {{{1
func! RunSpecFile()
  call s:RunSpec('all', 'add-extra-args')
endfunc

func! RunSpecLine()
  call s:RunSpec(line('.'), 'add-extra-args')
endfunc

func! RunLastSpec()
  if (g:spec_runner_last_command != '')
    call s:RunSpecCommand(g:spec_runner_last_command)
  end
endfunc


" Private Functions {{{1
func! s:RunSpec(line, add_extra_args)
  let cmd = s:GetSpecCommand(a:line, a:add_extra_args)
  let g:spec_runner_last_command = cmd
  call s:RunSpecCommand(cmd)
endfunc

func! s:GetSpecCommand(line, add_extra_args)
  let cmd = g:spec_runner_bin . " " . s:GetCurrentFileName()
  if a:line != 'all'
    let cmd .= ' ' . a:line
  end
  if (a:add_extra_args && exists('b:spec_runner_extra_args'))
    let cmd .= ' ' . b:spec_runner_extra_args
  end
  return cmd
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
  call VimuxRunCommand("cd " . getcwd() . "\n" . a:command)
endfunc

func! s:RunWithSecondTmux(command)
  call s:SendToSecondTmux("clear")
  call s:SendToSecondTmux("cd " . getcwd())
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
nnoremap <Leader>tl :call RunSpecLine()<cr>
nnoremap <Leader>tf :call RunSpecFile()<cr>
nnoremap <Leader>tt :call RunLastSpec()<cr>

command! -nargs=* SpecArgs call SetSpecArgs("<args>")
command! -nargs=* ClearSpecArgs call ClearSpecArgs()

" vim: foldmethod=marker
