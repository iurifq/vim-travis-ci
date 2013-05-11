# Travis-ci Vim plugin

This plugin provides `:GTravisBrowse` command to browse the build page of your latest git commit in [Travis CI](http://travis-ci.org).

This command places a request to Travis API so you may have to wait a while. It follows [vim-fugitive](http://github.com/tpope/vim-fugitive) command naming pattern and is only available when the current buffer is inside of a git managed folder.

## Installation

It depends on [vim-fugitive](http://github.com/tpope/vim-fugitive) and [webapi-vim](http://github.com/mattn/webapi-vim) plugins. These plugins depend on git and curl, so make sure to have them installed. If you use [Vundle](http://github.com/gmarik/vundle), you can install this plugin placing the following commands in you .vimrc.

```vim
Bundle 'tpope/vim-fugitive'
Bundle 'mattn/webapi-vim'
Bundle 'iurifq/vim-travis-ci'
```

## TODO

* Support github private repositories via OAuth authentication
* Support multiple remote repositories
* Asynchronous request to Travis API, maybe with [vim-dispatch](http://github.com/tpope/vim-dispatch)
* Handle errors while accessing external API
