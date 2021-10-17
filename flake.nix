{
  description = "A very basic flake";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/master"; };
    DSL = { url = "github:DieracDelta/nix2lua"; };
    neovim = {
      url = "github:neovim/neovim?rev=88336851ee1e9c3982195592ae2fc145ecfd3369&dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-bundler = {
      url = "github:matthewbauer/nix-bundle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    telescope-src = {
      url = "github:nvim-telescope/telescope.nvim?rev=b5c63c6329cff8dd8e23047eecd1f581379f1587";
      flake = false;
    };
    nix-utils = {
      url = "github:tomberek/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dracula-nvim = {
      url = "github:Mofiqul/dracula.nvim";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    nvim-cmp-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, neovim, nix-bundler, nix-utils, dracula-nvim, ...}:
    let pkgs = import nixpkgs {system = "x86_64-linux";};
        result_nvim = pkgs.wrapNeovim (neovim.defaultPackage.x86_64-linux) {
          withNodeJs = true;
          configure.customRC = "";
          configure.packages.myVimPackage.start = with pkgs.vimPlugins; [ ];
        };
  in
  {
    defaultPackage.x86_64-linux = result_nvim;
  };
}
