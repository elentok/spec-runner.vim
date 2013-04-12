"""
Spec Runner
"""

import os
import sys

def run_ruby(filepath, line = None):
    """ runs ruby specs using rspec """
    if os.path.exists('zeus.json'):
        command = "zeus rspec "
    else:
        command = "rspec "

    command += filepath
    if line is not None:
        command += ":%d" % line
    os.system(command)

def run_coffee(filepath, line = None):
    """ runs coffeescript tests using coffee """
    command = "mocha --compilers coffee:coffee-script --reporter spec "
    command += filepath
    if line is not None:
        from coffee_context import get_mocha_grep
        contexts = get_mocha_grep(filepath, line)
        if contexts:
            contexts = ' '.join(contexts)
            print "Test Context: '%s'" % contexts
            print "============================="
            command += " --grep '%s'" % contexts
    os.system(command)

def run_spec(filepath, line = None):
    """ runs specs """
    (_, ext) = os.path.splitext(filepath)
    if ext == '.rb':
        run_ruby(filepath, line)
    elif ext == '.coffee':
        run_coffee(filepath, line)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage:"
        print "  spec_runner.py {file} {optional: line}"
    else:
        os.system('clear')
        if len(sys.argv) == 3:
            run_spec(sys.argv[1], int(sys.argv[2]))
        else:
            run_spec(sys.argv[1])
