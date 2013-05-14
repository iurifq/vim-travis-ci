# Travis CI Vim plugin

This plugin provides `:GTravisBrowse` command to browse the build page of a git commit in [Travis CI](http://travis-ci.org). You can use it without any arguments, which references to the HEAD commit or giving a commit reference as follows.

```vim
:GTravisBrowse
:GTravisBrowse HEAD^
:GTravisBrowse HEAD~3
:GTravisBrowse 6cfb346
:GTravisBrowse some-branch-name
```

It follows [vim-fugitive](http://github.com/tpope/vim-fugitive) command naming pattern and is only available when the current buffer is inside of a git managed folder.

## Installation

It depends on [vim-fugitive](http://github.com/tpope/vim-fugitive) and [webapi-vim](http://github.com/mattn/webapi-vim) plugins. These plugins depend on git and curl, so make sure you have them installed. If you use [Vundle](http://github.com/gmarik/vundle), you can install this plugin placing the following commands in you .vimrc.

```vim
Bundle 'tpope/vim-fugitive'
Bundle 'mattn/webapi-vim'
Bundle 'iurifq/vim-travis-ci'
```

## TODO

* Support github private repositories via OAuth authentication
* Support multiple remote repositories
* Handle errors while accessing external API
