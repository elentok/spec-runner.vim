func! vim#spec(file, line)
  let command = "vimspec"
  "let command .= " " . a:file
  return command
endfunc

if !exists("b:spec_func")
  let b:spec_func = "vim#spec"
end
