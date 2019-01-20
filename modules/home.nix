{ pkgs, lib, config, ... }:
{
  programs.home-manager.enable = true;

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ../dotfiles/vimrc;
    settings = {
       number = true;
    };
    plugins = [
      "idris-vim"
      "sensible"
      "vim-airline"
      "The_NERD_tree"
      "fugitive"
      "vim-gitgutter"
    ];
  };

  home.file = {
    ".zshrcfoo" = {
      source = ../dotfiles/zshrc;
    };
    ".zshrc.local" = {
      source = ../dotfiles/zshrc.local;
    };
  };
}
