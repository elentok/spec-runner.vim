func! GetRubySpecCommand(file, line)
  if file_readable('zeus.json')
    let command = "zeus rspec "
  else
    let command = "rspec "
  end

  let command .= a:file
  if a:line >= 0
    let command .= ":" . a:line
  end
  return command
endfunc

if !exists("b:spec_func")
  let b:spec_func = "GetRubySpecCommand"
end
