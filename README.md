completor-swift
===============

Swift code completion for [completor.vim](https://github.com/maralla/completor.vim.git).


Install
-------

[Install completor.vim](https://github.com/maralla/completor.vim#install) first.

For [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'maralla/completor-swift'
```

To enable swift completion, Swift 5.3 should be installed. Then go to the root directory of *completor-swift* and run:

```bash
make
```

Tips
----

Use `<TAB>` To jump to placeholder:

```vim
imap <buffer> <tab>  <Plug>CompletorSwiftJumpToPlaceholder
map  <buffer> <tab>  <Plug>CompletorSwiftJumpToPlaceholder
```
