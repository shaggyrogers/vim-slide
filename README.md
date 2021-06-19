# vim-slide

This provides a set of unidirectional whitespace-boundary motions.


**Example**

The following was recorded using default options:

![screen-gif](./example.gif)


## Installation

Installation using vim-plug is recommended, but other plugin managers and manual installation will also work.

Using vim-plug:


```
call plug#begin(...)
" [...]
Plug 'https://github.com/shaggyrogers/vim-slide.git'
" [...]
call plug#end()
```

Reload .vimrc and install the plugin like so:

```
:so %
:PlugInstall
```

You may need to restart vim for changes to take effect.


## Usage/Options

See `:help slide` for further information.

>  vim: set ts=4 sw=4 tw=0 fdm=manual fenc=utf-8 et :
