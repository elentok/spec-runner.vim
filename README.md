Spec-Runner.vim
===============

Automatically runs specs from vim.


How does spec-runner choose where to run the tests?
------------------------------------------------------

1. If there's a tmux session named "test-output" it will run the test in its first window.
2. Else, if we're inside a tmux session it will run using Vimux.
3. Else, it will run in the current process (using "!")

You can change the name of the second tmux session using the variable `g:spec_runner_second_tmux_session`

Extra Args
----------

To add extra arguments to the spec command (like `--grep 'pattern'` in mocha tests) use one of the following:

* `:let g:spec_runner_extra_args="--grep mypattern"`
* `:SpecArgs --grep mypattern`

Key mappings
------------

* &lt;Leader&gt;tl - run current spec (current line)
* &lt;Leader&gt;tf - run entire spec file
* &lt;Leader&gt;tt - run last spec command

