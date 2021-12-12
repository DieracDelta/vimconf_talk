{
  description = "Tutorial Flake accompanying vimconf talk.";

  # Input source for our derivation
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    DSL = { url = "github:DieracDelta/nix2lua/aarch64-darwin"; };
    nix2vim = {
      url = "github:gytis-ivaskevicius/nix2vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim = {
      url = "github:neovim/neovim?ref=release-0.6&dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    telescope-src = {
      url =
        "github:nvim-telescope/telescope.nvim";
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
      url = "github:DieracDelta/rnix-lsp/mbp-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comment-nvim-src = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
  };

  outputs = inputs@{ self, flake-utils, nixpkgs, neovim, dracula-nvim, nix2vim
    , DSL, comment-nvim-src, ... }:
    let
      # Function to override the source of a package
      withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
      # Vim2Nix DSL
      dsl = nix2vim.lib.dsl;

      overlay = prev: final: rec {
        # Example of packaging plugin with Nix
        dracula = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "dracula-nvim";
          version = "master";
          src = dracula-nvim;
        };

        comment-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "comment-nvim";
          version = "master";
          src = comment-nvim-src;
        };

        # Generate our init.lua from neoConfig using vim2nix transpiler
        neovimConfig = let
          luaConfig = prev.luaConfigBuilder {
            config = import ./neoConfig.nix {
              inherit (nix2vim.lib) dsl;
              pkgs = prev;
            };
          };
        in prev.writeText "init.lua" luaConfig.lua;

        # Building neovim package with dependencies and custom config
        customNeovim = DSL.neovimBuilderWithDeps.legacyWrapper
          neovim.defaultPackage.aarch64-darwin {
            # Dependencies to be prepended to PATH env variable at runtime. Needed by plugins at runtime.
            extraRuntimeDeps = with prev; [
              ripgrep
              clang
              rust-analyzer
              inputs.rnix-lsp.defaultPackage.aarch64-darwin
            ];

            # Build with NodeJS
            withNodeJs = true;

            # Passing in raw lua config
            configure.customRC = ''
              colorscheme dracula
              luafile ${neovimConfig}
            '';

            configure.packages.myVimPackage.start = with prev.vimPlugins; [
              # Adding reference to our custom plugin
              # for themeing
              dracula

              # commenting with treesiter
              comment-nvim

              # Overwriting plugin sources with different version
              # fuzzy finder
              (withSrc telescope-nvim inputs.telescope-src)
              (withSrc cmp-buffer inputs.cmp-buffer)
              (withSrc nvim-cmp inputs.nvim-cmp)
              (withSrc cmp-nvim-lsp inputs.cmp-nvim-lsp)

              # Plugins from nixpkgs
              lsp_signature-nvim
              lspkind-nvim
              nvim-lspconfig
              plenary-nvim
              popup-nvim
              # which method am I on
              nvim-treesitter-context
              # for sane tab detection
              vim-sleuth
              vim-vsnip
              vim-vsnip-integ
              # FIXME figure out how to configure this one
              harpoon

              which-key-nvim
              friendly-snippets
              neogit


              # Compile syntaxes into treesitter
              (prev.vimPlugins.nvim-treesitter.withPlugins
                (plugins: with plugins; [ tree-sitter-nix tree-sitter-rust tree-sitter-json ]))
            ];
          };

      };

    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix2vim.overlay overlay ];
        };
      in {
        # The packages: our custom neovim and the config text file
        packages = { inherit (pkgs) customNeovim neovimConfig; };

        # The package built by `nix build .`
        defaultPackage = pkgs.customNeovim;

        # The app run by `nix run .`
        defaultApp = {
          type = "app";
          program = "${pkgs.customNeovim}/bin/nvim";
        };
      });
}
