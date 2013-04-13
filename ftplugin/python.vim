func! python#spec(file, line)
  let path = expand("%:h:p")
  let module = expand("%:t:r")
  let command = "cd " . path . "; python -m unittest --verbose " . module
  return command
endfunc

if !exists("b:spec_func")
  let b:spec_func = "python#spec"
end
