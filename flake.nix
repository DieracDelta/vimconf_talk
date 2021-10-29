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
    cmp-nvim-lsp = {
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
      withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
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
        vimUtils = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "dracula-nvim";
          version = "master";
          src = dracula-nvim;
        };

        nvimConfig = pkgs.writeText "init.lua" luaConfig.lua;

        neovim = pkgs.wrapNeovim neovim.defaultPackage.x86_64-linux {
          withNodeJs = true;
          configure.customRC = ''
            luafile ${self.packages.nvimConfig}
          '';
          configure.packages.myVimPackage.start = with pkgs.vimPlugins; [
            self.packages.vimUtils
            (withSrc telescope-nvim inputs.telescope-src)
            (withSrc cmp-buffer inputs.cmp-buffer)
            (withSrc nvim-cmp inputs.nvim-cmp)
            (withSrc cmp-nvim-lsp inputs.cmp-nvim-lsp)

            lsp_signature-nvim
            lspkind-nvim
            nerdcommenter
            nvim-lspconfig
            plenary-nvim
            popup-nvim

            (pkgs.vimPlugins.nvim-treesitter.withPlugins (
              plugins: with plugins; [ tree-sitter-nix tree-sitter-python tree-sitter-c tree-sitter-rust ]
            ))
          ];
        };

      };

      defaultPackage.x86_64-linux = self.packages.neovim;

      defaultApp.x86_64-linux = {
        type = "app";
        program = toString (pkgs.writeScript "nvim" "nix develop -c ${self.packages.neovim}/bin/nvim");
      };

      devshell = pkgs.mkShell {
        propagatedBuildInputs = with pkgs; [
          ripgrep
          clang
          rust-analyzer
          inputs.rnix-lsp.defaultPackage.x86_64-linux
          self.packages.neovim
        ];
      };
    };
}
