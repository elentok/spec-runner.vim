func! coffee#spec(file, line)
  if g:coffee_spec_mode == 'server'
    return coffee#spec_server(a:file, a:line)
  else
    return coffee#spec_client(a:file, a:line)
  end
endfunc

func! coffee#spec_server(file, line)
  let command = coffee#get_mocha_bin()
  let command .= " --compilers coffee:coffee-script --reporter spec"
  let command .= " " . a:file
  if a:line > 0
    let grep = coffee#get_mocha_grep()
    if grep != ''
      let command .= " --grep '" . grep . "'"
    end
  end
  return command
endfunc

func! coffee#get_mocha_bin()
  if filereadable('node_modules/.bin/mocha')
    return 'node_modules/.bin/mocha'
  else
    return 'mocha'
  end
endfunc

func! coffee#spec_client(file, line)
  let command = "mocha-phantomjs 'public/test.html"
  if a:line > 0
    let grep = coffee#get_mocha_grep()
    if grep != ''
      let command .= "?grep=" . grep
    end
  end
  return command . "'"
endfunc

if !exists("b:spec_func")
  let b:spec_func = "coffee#spec"
end

if !exists("g:coffee_spec_mode")
  let g:coffee_spec_mode = 'server'
end

func! coffee#toggle_spec_mode()
  if g:coffee_spec_mode == 'server'
    let g:coffee_spec_mode = 'client'
  else
    let g:coffee_spec_mode = 'server'
  end
  echo "Set coffee spec mode to '" . g:coffee_spec_mode ."'"
endfunc

command! CoffeeSpecMode call coffee#toggle_spec_mode()

func! coffee#get_mocha_grep()
  let contexts = coffee#get_mocha_contexts()
  if contexts == []
    return ''
  else
    let grep = join(contexts, ' ')
    let grep = substitute(grep, "'", "''", 'g')
    let grep = substitute(grep, '(', '\\(', 'g')
    let grep = substitute(grep, ')', '\\)', 'g')
    return grep
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
