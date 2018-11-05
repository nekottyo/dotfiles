let g:python3_host_prog = '/usr/bin/python3'
"let g:ruby_host_prog = expand('~/.gem/ruby/2.5.0/gems/neovim-0.7.1/bin/neovim-ruby-host')
let g:deoplete#enable_at_startup = 1

let g:cache_home = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let g:config_home = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" dein {{{
let s:dein_cache_dir = g:cache_home . '/dein'

" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

if &runtimepath !~# '/dein.vim'
    let s:dein_repo_dir = s:dein_cache_dir . '/repos/github.com/Shougo/dein.vim'

    " Auto Download
    if !isdirectory(s:dein_repo_dir)
        call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
    endif

    " dein.vim をプラグインとして読み込む
    execute 'set runtimepath^=' . s:dein_repo_dir
endif

" dein.vim settings
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'title'
let g:dein#install_message_type = 'none'
let g:dein#enable_notification = 1
hi MatchParen term=standout ctermbg=White ctermfg=White guibg=White guifg=White

if dein#load_state(s:dein_cache_dir)
    call dein#begin(s:dein_cache_dir)

    let s:toml_dir = g:config_home . '/dein'

    call dein#load_toml(s:toml_dir . '/plugins.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/lazy.toml', {'lazy': 1})
    if has('nvim')
        call dein#load_toml(s:toml_dir . '/neovim.toml', {'lazy': 1})
    endif

    call dein#end()
    call dein#save_state()
endif

if has('vim_starting') && dein#check_install()
    call dein#install()
endif
" }}}


" 行数
set number

set noswapfile

" insertモードから抜ける
inoremap <silent> jj <ESC>
inoremap <silent> <C-j> j
inoremap <silent> kk <ESC>
inoremap <silent> <C-k> k

" insert モードで Alt + hjkl でカーソル移動
inoremap <A-h> <left>
inoremap <A-j> <down>
inoremap <A-k> <up>
inoremap <A-l> <right>


filetype indent on
set incsearch
set ignorecase
set shiftwidth=4
set shiftround
set autoindent smartindent
set expandtab
set smarttab
set smartcase

" ESCキー2度押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

autocmd FileType python setl tabstop=8 expandtab shiftwidth=4 softtabstop=4
autocmd FileType yaml setl tabstop=4 expandtab shiftwidth=2 softtabstop=2
autocmd FileType ruby,eruby,scss setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType ruby let &colorcolumn=join(range(81,999),",")
autocmd FileType sh,zsh setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType make setl noexpandtab
autocmd FileType html,vue setl tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType dockerfile setl tabstop=2 expandtab shiftwidth=2 softtabstop=2

autocmd BufRead,BufNewFile *.gs setfiletype javascript
autocmd FileType dockerfile setl tabstop=2 expandtab shiftwidth=2 softtabstop=2

set clipboard+=unnamedplus
