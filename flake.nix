{
  description = "A very basic flake";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/master"; };
    flake-utils.url = "github:numtide/flake-utils";
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

  outputs = inputs@{ self, flake-utils, nixpkgs, home-manager, neovim, dracula-nvim, nix2vim, ... }:
    let
      withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
      dsl = nix2vim.lib.dsl;
      overlay = prev: final: rec {
        # Example of packaging plugin with Nix
        #vimUtils = prev.vimUtils.buildVimPluginFrom2Nix {
        #  pname = "dracula-nvim";
        #  version = "master";
        #  src = dracula-nvim;
        #};

        # init.lua derivation
        neovimConfig =
          let
            luaConfig = prev.luaConfigBuilder {
              config = import ./neoConfig.nix {
                inherit (nix2vim.lib) dsl;
                pkgs = prev;
              };
            };
          in
          prev.writeText "init.lua" luaConfig.lua;

        # Building neovim package with dependencies and custom config
        customNeovim = prev.wrapNeovim neovim.defaultPackage.x86_64-linux {
          withNodeJs = true;

          configure.customRC = ''
            colorscheme dracula
            luafile ${neovimConfig}
          '';

          configure.packages.myVimPackage.start = with prev.vimPlugins; [
            # Adding reference our custom plugin
            #vimUtils

            # Overwriting plugin sources with different version
            (withSrc telescope-nvim inputs.telescope-src)
            (withSrc cmp-buffer inputs.cmp-buffer)
            (withSrc nvim-cmp inputs.nvim-cmp)
            (withSrc cmp-nvim-lsp inputs.cmp-nvim-lsp)

            # Plugins from nixpkgs
            lsp_signature-nvim
            lspkind-nvim
            nerdcommenter
            nvim-lspconfig
            plenary-nvim
            popup-nvim

            # Overwriting treesitter to with extra syntaxes
            (prev.vimPlugins.nvim-treesitter.withPlugins (
              plugins: with plugins; [ tree-sitter-nix tree-sitter-python tree-sitter-c tree-sitter-rust ]
            ))
          ];
        };

      };

    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix2vim.overlay overlay ];
        };
      in
      {
        packages = {
          inherit (pkgs) customNeovim neovimConfig;
        };

        defaultPackage = pkgs.customNeovim;

        defaultApp = {
          type = "app";
          program = toString (pkgs.writeScript "nvim" "nix develop -c ${pkgs.customNeovim}/bin/nvim");
        };

        devShell = pkgs.mkShell {
          propagatedBuildInputs = with pkgs; [
            ripgrep
            clang
            rust-analyzer
            inputs.rnix-lsp.defaultPackage.x86_64-linux
            customNeovim
          ];
        };
      });
}
