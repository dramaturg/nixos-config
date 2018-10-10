{ pkgs, lib, config, ... }:
{
  programs.home-manager.enable = true;

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ../dotfiles/vimrc;
    settings = {
       relativenumber = true;
       number = true;
    };
    plugins = [
      "idris-vim"
      "sensible"
      "vim-airline"
      "The_NERD_tree" # file system explorer
      "fugitive" "vim-gitgutter" # git 
      "rust-vim"
    ];
  };

  home.file = {
    ".zshrcfoo" = {
      source = ../dotfiles/zshrc;
      #recursive = true;
    };
  };
}
