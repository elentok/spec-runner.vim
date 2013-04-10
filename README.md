Spec-Runner.vim
===============

Automatically runs specs from vim.

Settings
--------

By default, spec-runner will run the tests in the current process,
but it supports two more modes using the `g:spec_runner_mode` variable.

* `"vimux"` - use vimux 
* `"second-tmux"` - use a secondary tmux (so you can run your tests on a second monitor).
  * to use this mode, open a new terminal and run:
  
    ```
    tmux new-session -s test-output
    ```

Extra Args
----------

To add extra arguments to the spec command (like `--grep 'pattern'` in mocha tests) use one of the following:

* `:let g:spec_runner_extra_args="--grep mypattern"`
* `:SpecArgs --grep mypattern`

Key mappings
------------

* \r - run current spec (current line)
* \R - run entire spec file
* \\ - run last spec command (currently only supported when using vimux)

