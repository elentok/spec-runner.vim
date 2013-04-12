"""
gets the context in which to run coffee script tests
"""

import re

def get_mocha_grep(filepath, line_number):
    """ finds the grep argument for mocha by combining the 'describe' calls

    >>> get_mocha_grep("./test/fixture1.coffee", 10)
    >>> get_mocha_grep("./test/fixture1.coffee", 1)
    ['one']
    >>> get_mocha_grep("./test/fixture1.coffee", 2)
    ['one', 'two']
    >>> get_mocha_grep("./test/fixture1.coffee", 3)
    ['one', 'two', 'three']
    >>> get_mocha_grep("./test/fixture1.coffee", 4)
    ['one', 'two', 'three', 'four']
    >>> get_mocha_grep("./test/fixture1.coffee", 5)
    ['one', 'two', 'three', 'five']
    """
    contexts = []
    lines = open(filepath, 'r').readlines()
    if line_number > len(lines):
        return None
    line_number -= 1
    line = lines[line_number]
    context = get_context(line)
    last_indent = -1
    if context is not None:
        last_indent = context[0]
        contexts.insert(0, context[1])
    else:
        last_indent = get_indent(line)
    while line_number >= 0:
        line = lines[line_number]
        context = get_context(line)
        if context is not None:
            (indent, context_name) = context
            if indent < last_indent:
                contexts.insert(0, context_name)
                if indent == 0:
                    return contexts
                last_indent = indent
        line_number -= 1
    return contexts

INDENT_RE = re.compile("(^[\t ]*)")

def get_indent(line):
    """
    get the indentation of a line

    >>> get_indent("hello")
    0
    >>> get_indent("   hello")
    3
    >>> get_indent("\\t\\tbla")
    2
    """
    match = INDENT_RE.match(line)
    if match is not None:
        return len(match.groups()[0])
    else:
        return 0

CONTEXT_RE = re.compile("(^[\t ]*)(it|describe) +(\"([^\"]+)\"|'([^']+)')")

def get_context(line):
    """
    get the indent of this context line (returns -1 if it's not a context line)
    >>> get_context("hello")
    >>> get_context("describe 'abc'")
    (0, 'abc')
    >>> get_context("   describe 'bla bla'")
    (3, 'bla bla')
    >>> get_context('\\t\\tdescribe "hello"')
    (2, 'hello')
    """
    match = CONTEXT_RE.match(line)
    if match is None:
        return
    else:
        (indent, _, _, context1, context2) = match.groups()
        indent = len(indent)
        return (indent, context1 or context2)
