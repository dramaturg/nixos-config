{ config, pkgs, lib, ...}:

with lib;

let
  vim = pkgs.vim_configurable.customize {
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

		  set hlsearch    " highlight all search results
		  set ignorecase  " do case insensitive search
		  set incsearch   " show incremental search results as you type
        '';
        vam.pluginDictionaries = [
        {
          names = [
            "vim-nix"
            "Syntastic"
            "undotree"
          ] ++ optional config.programs.vim.fat "youcompleteme";
        }
      ];
    };
  };
in
{
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
    environment.variables.EDITOR = "vim";
    programs.bash.shellAliases = {
      vi = "vim";
    };
  };
}

# vim.ruby = false;
# vim.defaultEditor = true;
