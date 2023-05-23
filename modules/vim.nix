{ config, pkgs, lib, ... }:

with lib;

let
  myVim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        syntax on
        set listchars=tab:->
        set list
        set backspace=indent,eol,start
        set expandtab
        set softtabstop=2
        set shiftwidth=2
        set autoindent

        set hlsearch    " highlight all search results
        set ignorecase  " do case insensitive search
        set incsearch   " show incremental search results as you type
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
    environment.systemPackages = [ myVim ];
    environment.shellAliases.vi = "vim";
    environment.variables.EDITOR = lib.mkOverride 0 "vim";
    programs.bash.shellAliases = { vi = "vim"; };
  };
}

# vim.ruby = false;
# vim.defaultEditor = true;
