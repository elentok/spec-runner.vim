Spec-Runner.vim
===============

Automatically runs specs from vim.

Settings
--------

* to use Vimux, add this line to your .vimrc:

```vim
let g:spec_runner_use_vimux = 1
```

Key mappings
------------

* \r - run current spec (current line)
* \R - run entire spec file
* \\ - run last spec command (currently only supported when using vimux)

