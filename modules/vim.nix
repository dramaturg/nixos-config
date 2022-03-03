{ config, pkgs, lib, ... }:

with lib;

let
  myVim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        syntax on
        set nu
        set foldmethod=syntax
        set listchars=tab:->
        set list
        set backspace=indent,eol,start
        set expandtab
        set softtabstop=2
        set shiftwidth=2
        set autoindent
        set smartindent
        set smarttab

        "Persistent undo
        try
        	if MySys() == "windows"
        		set undodir=C:\Windows\Temp
        	else
        		set undodir=~/.vim_undodir
        	endif

        	if !isdirectory(&undodir)
        		exec "silent !mkdir -p " . &undodir
        	endif
        	set undofile
        catch
        endtry

        " better searching
        set ignorecase
        set smartcase
        set hlsearch
        set wrapscan
        set incsearch

        " Press Space to turn off highlighting and clear any message already displayed.
        :nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>


        " show a wrapper char at wrapped lines
        if has("linebreak")
        	let &sbr = nr2char(8618).' '
        endif

        " MultipleSearch
        let g:MultipleSearchMaxColors = 8
        let g:MultipleSearchColorSequence = "red,yellow,blue,green,magenta,cyan,gray,brown"
        let g:MultipleSearchTextColorSequence = "white,black,white,black,white,black,black,white"

        " netrw
        let g:netrw_list_hide = ".*\.swp$"

        " Golang
        let g:go_fmt_options = "-tabs=false -tabwidth=4"

        " Yankring
        let g:yankring_history_dir = '$HOME/.vim/'
        let g:yankring_history_file = '.yankring'
        nnoremap <silent> <F3> :YRShow<cr>
        inoremap <silent> <F3> <ESC>:YRShow<cr>

        " I don't need help when I want escape
        inoremap <F1> <ESC>
        nnoremap <F1> <ESC>
        vnoremap <F1> <ESC>

        " Rainbow Parentheses
        au VimEnter * RainbowParenthesesToggle
        au Syntax * RainbowParenthesesLoadRound
        au Syntax * RainbowParenthesesLoadSquare
        au Syntax * RainbowParenthesesLoadBraces


        " navigate more naturally when editing wrapped lines
        nnoremap j gj
        nnoremap k gk

        " windows resizing
        if bufwinnr(1)
        	map + <C-W>+
        	map - <C-W>-
        endif

        " tmux integration
        let g:tmux_navigator_no_mappings = 1
        "let g:tmux_navigator_save_on_switch = 1
        nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
        nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
        nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
        nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
        nnoremap <silent> <C-A> :TmuxNavigatePrevious<cr>

        " binary files
        augroup Binary
          au!
          au BufReadPre *.bin let &bin=1
          au BufReadPost *.bin if &bin | %!xxd
          au BufReadPost *.bin set filetype=xxd | endif
          au BufWritePre *.bin if &bin | %!xxd -r
          au BufWritePre *.bin endif
          au BufWritePost *.bin if &bin | %!xxd
          au BufWritePost *.bin set nomod | endif
        augroup END

        " Tlist
        nnoremap <silent> <F8> :TlistToggle<CR>  " F8 toggle the taglist
        let Tlist_Ctags_Cmd = 'ctags'
        let Tlist_Auto_Refresh = 1
        let Tlist_Inc_Winwidth = 0
        let Tlist_Exit_OnlyWindow = 1
        let Tlist_Process_File_Always = 1
        let Tlist_Use_Right_Window = 1
        let Tlist_Display_Tag_Scope = 1
        let Tlist_Show_Menu = 1

        " Strip all trailing whitespace in file
        function! StripWhitespace ()
        	exec ':%s/ \+$//gc'
        endfunction
        map ,s :call StripWhitespace ()<CR>
      '';
      vam.pluginDictionaries = [{
        names = [ "vim-nix" "Syntastic" "undotree" ]
          ++ optional config.programs.vim.fat "YouCompleteMe";
      }];
    };
  };
in {
  options = {
    programs.vim.fat = mkOption {
      type = types.bool;
      default = true;
      description = "include vim modules that consume a lot of disk space";
    };
  };

  config = {
    environment.systemPackages = [ myVim pkgs.xxd ];
    environment.shellAliases.vi = "vim";
    environment.variables.EDITOR = "vim";
    programs.bash.shellAliases = { vi = "vim"; };
  };
}

# vim.ruby = false;
# vim.defaultEditor = true;
