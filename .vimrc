function! s:disable_rtp_plugins() abort
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_getscriptPlugin = 1
  let g:loaded_gzip = 1
  let g:loaded_logiPat = 1
  let g:loaded_rrhelper = 1
  let g:loaded_spellfile_plugin = 1
  let g:loaded_tarPlugin = 1
  let g:loaded_2html_plugin = 1
  let g:loaded_vimballPlugin = 1
  let g:loaded_zipPlugin = 1
endfunction
call s:disable_rtp_plugins()

syntax enable

let s:cachedir = fnamemodify("~/.cache/vim", ":p")

set nocompatible
set belloff=all

function! s:setup_recovery_files() abort
  set noswapfile
  set nobackup
  set undofile
  if &undofile
    let l:undodir = fnamemodify(s:cachedir .. "/undo", ":p")
    if ! isdirectory(l:undodir)
      echom "create undo directory:" .. l:undodir
      call mkdir(l:undodir, "p")
    endif
    execute "set undodir=" .. l:undodir
  endif
endfunction
call s:setup_recovery_files()

set number
set splitright
set splitbelow

set hlsearch
set incsearch

set wildmenu
set wildoptions=pum
set wildmode=full

set ruler
set laststatus=2

set smarttab
set expandtab
set tabstop=2
set shiftwidth=0
set softtabstop=-1
set smartindent

if has("termguicolors")
  set termguicolors
  colorscheme industry 
  highlight Normal guibg=NONE
  highlight NonText guibg=NONE
  highlight EndOfBuffer guibg=NONE
  highlight LineNr guibg=NONE
endif

nnoremap <silent> <ESC><ESC> :nohlsearch<CR>

augroup c
  autocmd!
  autocmd FileType c setlocal tabstop=4
augroup END

filetype plugin indent on
