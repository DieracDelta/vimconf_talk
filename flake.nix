{
  description = "Tutorial Flake accompanying vimconf talk.";

  # Input source for our derivation
  inputs = {
    master.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    stable.url = "github:NixOS/nixpkgs/21.11";
    flake-utils.url = "github:numtide/flake-utils";
    DSL = {
      url = "github:DieracDelta/nix2lua/aarch64-darwin";
      inputs.neovim.follows = "neovim";
      inputs.nixpkgs.follows = "stable";
    };
    terraform-ls-src = {
      url = "github:hashicorp/terraform-ls";
      flake = false;
    };
    nix2vim = {
      url = "github:gytis-ivaskevicius/nix2vim";
      inputs.nixpkgs.follows = "stable";
    };
    neovim = {
      url = "github:neovim/neovim?dir=contrib&ref=master";
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
      url = "github:Ma27/rnix-lsp?ref=01b3623b49284d87a034676d3f4b298e495190dd";
      inputs.nixpkgs.follows = "stable";
    };
    comment-nvim-src = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    blamer-nvim-src = {
      url = "github:APZelos/blamer.nvim";
      flake = false;
    };
    telescope-ui-select-src = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    rust-tools-src = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };
    fidget-src = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };
    neogen-src = {
      url = "github:danymat/neogen";
      flake = false;
    };
    which-key-src = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , flake-utils
    , nixpkgs
    , neovim
    , dracula-nvim
    , nix2vim
    , DSL
    , comment-nvim-src
    , blamer-nvim-src
    , telescope-ui-select-src
    , rust-tools-src
    , which-key-src
    , fidget-src
    , neogen-src
    , stable
    , master
    , ...
    }:
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

        blamer-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "blamer-nvim";
          version = "master";
          src = blamer-nvim-src;
        };

        parinfer-rust-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "parinfer-rust";
          version = "master";
          src = prev.pkgs.parinfer-rust;
        };

        telescope-ui-select = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "telescope-ui-select";
          version = "master";
          src = telescope-ui-select-src;
        };

        rust-tools = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "rust-tools";
          version = "master";
          src = rust-tools-src;
        };

        fidget = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "fidget";
          version = "master";
          src = fidget-src;
        };

        neogen = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "neogen";
          version = "master";
          src = neogen-src;
        };

        which-key = prev.vimUtils.buildVimPluginFrom2Nix {
          pname = "which-key";
          version = "master";
          src = which-key-src;
        };



        # Generate our init.lua from neoConfig using vim2nix transpiler
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

        # shamelessly copied from fufexan (thanks buddy!)

        # Building neovim package with dependencies and custom config
        customNeovim = (DSL.DSL prev).neovimBuilderWithDeps.legacyWrapper
          neovim.defaultPackage.${prev.system}
          {
            # Dependencies to be prepended to PATH env variable at runtime. Needed by plugins at runtime.
            extraRuntimeDeps = with prev; [
              (
                buildGoModule rec {
                  pname = "terraform-ls";
                  version = "0.27.0";

                  src = fetchFromGitHub {
                    owner = "hashicorp";
                    repo = pname;
                    rev = "v${version}";
                    sha256 = "sha256-TWxYCHdzeJtdyPajA3XxqwpDufXnLod6LWa28OHjyms=";
                  };

                  vendorSha256 = "sha256-e/m/8h0gF+kux+pCUqZ7Pw0XlyJ5dL0Zyqb0nUlgfpc=";
                  ldflags = [ "-s" "-w" "-X main.version=v${version}" "-X main.prerelease=" ];

                  # There's a mixture of tests that use networking and several that fail on aarch64
                  doCheck = false;

                  doInstallCheck = true;
                  installCheckPhase = ''
                    runHook preInstallCheck
                    $out/bin/terraform-ls --help
                    $out/bin/terraform-ls version | grep "v${version}"
                    runHook postInstallCheck
                  '';

                  meta = with lib; {
                    description = "Terraform Language Server (official)";
                    homepage = "https://github.com/hashicorp/terraform-ls";
                    changelog = "https://github.com/hashicorp/terraform-ls/blob/v${version}/CHANGELOG.md";
                    license = licenses.mpl20;
                    maintainers = with maintainers; [ mbaillie jk ];
                  };
                }
              )
              # master.clang-tools # fix headers not found
              clang # LSP and compiler
              fd # telescope file browser
              ripgrep # telescope
              nodePackages.vscode-json-languageserver # json
              gopls
              pyright
              inputs.rnix-lsp.defaultPackage.${prev.system} # nix
            ];

            # Build with NodeJS
            withNodeJs = true;

            # Passing in raw lua config
            configure.customRC = ''
              colorscheme dracula
              luafile ${neovimConfig}
            '';

            configure.packages.myVimPackage.start = with master.legacyPackages.${prev.system}.vimPlugins; [
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
              # harpoon

              which-key
              friendly-snippets
              neogit
              blamer-nvim

              parinfer-rust-nvim

              master.legacyPackages.${prev.system}.vimPlugins.telescope-file-browser-nvim
              # sexy dropdown
              telescope-ui-select

              # more lsp rust functionality
              rust-tools

              # for updating rust crates
              crates-nvim

              # for showing lsp progress
              fidget

              # for generating boilerplate for comments
              neogen

              # Compile syntaxes into treesitter
              (prev.vimPlugins.nvim-treesitter.withPlugins
                (plugins: with plugins; [ tree-sitter-nix tree-sitter-rust tree-sitter-json tree-sitter-c tree-sitter-go master.legacyPackages.${prev.system}.tree-sitter-grammars.tree-sitter-hcl]))
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
