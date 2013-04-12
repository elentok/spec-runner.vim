func! coffee#spec(file, line)
  let command = "mocha --compilers coffee:coffee-script --reporter spec"
  let command .= " " . a:file
  if a:line > 0
    let command .= coffee#get_mocha_grep()
  end
  return command
endfunc

if !exists("b:spec_func")
  let b:spec_func = "coffee#spec"
end

func! coffee#get_mocha_grep()
  let contexts = coffee#get_mocha_contexts()
  if contexts == []
    return ''
  else
    let grep = join(contexts, ' ')
    let grep = substitute(grep, "'", "''", 'g')
    return " --grep '" . grep . "'"
  end
endfunc

func! coffee#get_mocha_contexts()
  let line_number = line('.')
  let line = getline(line_number)
  let contexts = []
  let last_indent = coffee#get_indent(line)
  let context = coffee#get_line_context(line)
  if context != []
    call add(contexts, context[1])
  endif
  while line_number > 0
    let context = coffee#get_line_context(line)
    if context != []
      let indent = context[0]
      let context_text = context[1]
      if indent < last_indent
        let last_indent = indent
        call insert(contexts, context_text, 0)
      end
    end
    let line_number -= 1
    let line = getline(line_number)
  endwhile
  return contexts
endfunc

func! coffee#get_line_context(line)
  let match = matchlist(a:line, '\v^([	 ]*)(it|describe) +("([^"]+)"|' . "'([^']+)')")
  if match == []
    return []
  else
    let context = match[5]
    if context == ''
      let context = match[4]
    end
    let indent = strlen(match[1])
    return [indent, context]
  end
endfunc

func! coffee#get_indent(line)
  let match = matchlist(a:line, '\v^([	 ]*)')
  if match == []
    return 0
  else
    return strlen(match[0])
  end
endfunc
