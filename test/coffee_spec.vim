source ftplugin/coffee.vim

function! Test_get_mocha_grep()
  call s:Test_get_mocha_grep(1, '')
  call s:Test_get_mocha_grep(2, ' --grep ''one''')
  call s:Test_get_mocha_grep(3, ' --grep ''one two''')
  call s:Test_get_mocha_grep(7, ' --grep ''one two three''')
  call s:Test_get_mocha_grep(8, ' --grep ''one two three four''')
  call s:Test_get_mocha_grep(9, " --grep 'one two three fi''ve'")
  call s:Test_get_mocha_grep(10, " --grep 'one two three alpha\\(bravo\\)'")
endfunc

function! s:Test_get_mocha_grep(line_number, expected)
  call Describe("when line number is " . a:line_number)
  e! test/fixture1.coffee
  exec a:line_number
  let grep = coffee#get_mocha_grep()
  call AssertEquals(grep, a:expected)
endfunc

function! Test_get_mocha_contexts()
  call s:Test_get_mocha_contexts(1, [])
  call s:Test_get_mocha_contexts(2, ['one'])
  call s:Test_get_mocha_contexts(3, ['one', 'two'])
  call s:Test_get_mocha_contexts(7, ['one', 'two', 'three'])
  call s:Test_get_mocha_contexts(8, ['one', 'two', 'three', 'four'])
  call s:Test_get_mocha_contexts(9, ['one', 'two', 'three', "fi've"])
endfunc

function! s:Test_get_mocha_contexts(line_number, expected)
  call Describe("when line number is " . a:line_number)
  e! test/fixture1.coffee
  exec a:line_number
  let contexts = coffee#get_mocha_contexts()
  call AssertEquals(contexts, a:expected)
endfunc

function! Test_get_line_context()
  call Describe("coffee#get_line_context(\"hello\")")
  call AssertEquals(coffee#get_line_context("hello"), [])

  call Describe("coffee#get_line_context(\"describe 'abc'\")")
  call AssertEquals(coffee#get_line_context("describe 'abc'"), [0, 'abc'])

  call Describe("coffee#get_line_context(\"describe 'bla bla'\")")
  call AssertEquals(coffee#get_line_context("   describe 'bla bla'"), [3, 'bla bla'])

  call Describe("coffee#get_line_context('describe \"hello\"')")
  call AssertEquals(coffee#get_line_context("		describe \"hello\""), [2, 'hello'])
endfunc

function! Test_get_indent()
  call Describe("coffee#get_indent(\"hello\")")
  call AssertEquals(coffee#get_indent("hello"), 0)

  call Describe("coffee#get_indent(\"   hello\")")
  call AssertEquals(coffee#get_indent("   hello"), 3)

  call Describe("coffee#get_indent(\"	hello\")")
  call AssertEquals(coffee#get_indent("	hello"), 1)
endfunc
