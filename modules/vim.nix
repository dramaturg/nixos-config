with import <nixpkgs> {};

vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''
		set hlsearch    " highlight all search results
		set ignorecase  " do case insensitive search
		set incsearch   " show incremental search results as you type
    '';
    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
    vimrcConfig.vam.pluginDictionaries = [
        { names = [
            # Here you can place all your vim plugins
            # They are installed managed by `vam` (a vim plugin manager)
            "Syntastic"
            "ctrlp"
            "rust"
            "gitgutter"
            "undotree"
            "youcompleteme"
            "vim-nix"
        ]; }
    ];
	vimrcConfig.pathogen.pluginNames = [
		"vim-racket"
	];
}
