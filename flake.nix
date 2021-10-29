{
  description = "A very basic flake";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/master"; };
    nix2vim = {
      url = "github:gytis-ivaskevicius/nix2vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim = {
      url = "github:neovim/neovim?rev=88336851ee1e9c3982195592ae2fc145ecfd3369&dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    telescope-src = {
      url = "github:nvim-telescope/telescope.nvim?rev=b5c63c6329cff8dd8e23047eecd1f581379f1587";
      flake = false;
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
    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, neovim, dracula-nvim, nix2vim, ... }:
    let
      dsl = nix2vim.lib.dsl;
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nix2vim.overlay ];
      };

      luaConfig = pkgs.luaConfigBuilder {
        config = import ./neoConfig.nix { inherit pkgs dsl; };
      };

    in
    {
      overlay = nix2vim.overlay;
      packages = {
        nvimConfig = pkgs.writeText "init.lua" luaConfig.lua;

        neovim = pkgs.wrapNeovim neovim.defaultPackage.x86_64-linux {
          withNodeJs = true;
          configure.customRC = ''
            luafile ${self.packages.nvimConfig}
          '';
          configure.packages.myVimPackage.start = with pkgs.vimPlugins; [
            (pkgs.vimUtils.buildVimPluginFrom2Nix { pname = "dracula-nvim"; version = "master"; src = dracula-nvim; })
            (telescope-nvim.overrideAttrs (oldattrs: { src = inputs.telescope-src; }))
            (cmp-buffer.overrideAttrs (oldattrs: { src = inputs.cmp-buffer; }))
            (nvim-cmp.overrideAttrs (oldattrs: { src = inputs.nvim-cmp; }))
            (cmp-nvim-lsp.overrideAttrs (oldattrs: { src = inputs.nvim-cmp-lsp; }))
            plenary-nvim
            nerdcommenter
            nvim-lspconfig
            lspkind-nvim
            (pkgs.vimPlugins.nvim-treesitter.withPlugins (
              plugins: with plugins; [ tree-sitter-nix tree-sitter-python tree-sitter-c tree-sitter-rust ]
            ))
            lsp_signature-nvim
            popup-nvim
          ];
        };

      };
      #my_config = pkgs.writeText "config" (DSL.DSL.neovimBuilder config);
      defaultPackage.x86_64-linux = self.packages.neovim;
      #defaultApp.x86_64-linux = {
      #    type = "app";
      #    program = "${result_nvim}/bin/nvim";
      #};
    };
}
