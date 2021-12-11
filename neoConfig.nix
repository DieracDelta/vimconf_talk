{ pkgs, dsl }:
with dsl; {

  vim.g = {
    mapleader = " ";
    nofoldenable = true;
    noshowmode = true;
    completeopt = "menu,menuone,noselect";
    noswapfile = true;
  };

  vim.o = {
    showcmd = true;
    showmatch = true;
    ignorecase = true;
    smartcase = true;
    cursorline = true;
    wrap = true;
    autoindent = true;
    copyindent = true;
    splitbelow = true;
    splitright = true;
    number = true;
    relativenumber = true;
    title = true;
    undofile = true;
    autoread = true;
    hidden = true;
    list = true;
    background = "dark";
    backspace = "indent,eol,start";
    undolevels = 1000000;
    undoreload = 1000000;
    foldmethod = "indent";
    foldnestmax = 10;
    foldlevel = 1;
    scrolloff = 3;
    sidescrolloff = 5;
    listchars = "tab:→→,trail:●,nbsp:○";
    clipboard = "unnamed,unnamedplus";
    formatoptions = "tcqj";
    encoding = "utf-8";
    fileencoding = "utf-8";
    fileencodings = "utf-8";
    bomb = true;
    binary = true;
    matchpairs = "(:),{:},[:],<:>";
    expandtab = true;
    #pastetoggle = "<leader>v";
    wildmode = "list:longest,list:full";
  };

  use.which-key.register = callWith
    {
      "K" = [ "<cmd>lua vim.lsp.buf.hover()<CR>" "Get Type Information" ];
      "['<leader>']" = {
        name = "+leader_bindings";
        "D" = [ "<cmd>lua vim.lsp.buf.declaration()<CR>" "Jump to Declaration" ];
        "d" = [ "<cmd>lua vim.lsp.buf.definition()<CR>" "Jump to Definition" ];
        "i" = [ "<cmd>lua vim.lsp.buf.implementation()<CR>" "Jump to Implementation" ];
        "s" = [ "<cmd>lua vim.lsp.buf.signature_help()<CR>" "Get function signature" ];
        "k" = [ "<cmd>lua vim.lsp.buf.type_definition()<CR>" "Get type definition" ];
        "rn" = [ "<cmd>lua vim.lsp.buf.rename()<CR>" "Rename function/variable" ];
        "ca" = [ "<cmd>lua vim.lsp.buf.code_action()<CR>" "Perform code action" ];
        "r" = [ "<cmd>lua vim.lsp.buf.references()<CR>" "Get function/variable refs" ];
        "e" = [ "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>" "Get lsp errors" ];
        "f" = [ "<cmd>lua vim.lsp.buf.formatting()<CR>" "Format buffer" ];
        "bb" = [ "<cmd>Telescope buffers<cr>" "Get buffer list" ];
        "gg" = [ "<cmd>Telescope live_grep<cr>" "Fzf fuzzy search" ];
        "['<leader>']" = [ "<cmd>Telescope find_files<cr>" "search files" ];
        "ws" = [ "<cmd>sp<cr>" "Split window horizontally" ];
        "wv" = [ "<cmd>vs<cr>" "Split window vertically" ];
        "bd" = [ "<cmd>q<cr>" "Delete buffer" ];
        "bn" = [ "<cmd>tabnext<cr>" "Next buffer" ];
        "bp" = [ "<cmd>tabprevious<cr>" "Previous buffer" ];
        "bN" = [ "<cmd>tabedit<cr>" "New buffer/tab" ];
        "bD" = [ "<cmd>Bclose!<cr>" "Delete buffer aggressively" ];
        "wd" = [ "<cmd>q<cr>" "Delete window" ];
        "wl" = [ "<cmd>wincmd l<cr>" "Move window right" ];
        "wj" = [ "<cmd>wincmd j<cr>" "Move window down" ];
        "wk" = [ "<cmd>wincmd k<cr>" "Move window up" ];
        "wh" = [ "<cmd>wincmd h<cr>" "Move window left" ];
      };
    };

  use.Comment.setup = callWith {
    toggler = {
      line = "<leader>c<leader>";
      block = "<leader>b<leader>";
    };
    opleader = {
      line = "<leader>c";
      block = "<leader>b";
    };
    extra = {
      above = "<leader>cO";
      below = "<leader>co";
      eol = "<leader>cA";
    };
  };

  use.lspconfig.rnix.setup = callWith {
    cmd = [ "rnix-lsp" ];
    capabilities = rawLua
      "require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())";
  };

  use.lspconfig.rust_analyzer.setup = callWith {
    cmd = [ "rust-analyzer" ];
    capabilities = rawLua
      "require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())";
  };

  use.telescope.setup = callWith { };

  use."nvim-treesitter.configs".setup = callWith {
    ensure_installed = [ "nix" "rust" ];
    highlight = {
      enable = true;
      disable = [ "css" ];
    };
    rainbow = {
      enable = true;
      disable = [ "html" ];
      extended_mode = true;
      max_file_lines = 10000;
      colors = [
        "#bd93f9"
        "#6272a4"
        "#8be9fd"
        "#50fa7b"
        "#f1fa8c"
        "#ffb86c"
        "#ff5555"
      ];
    };
  };

  use.cmp.setup = callWith {
    mapping = {
      "['<C-n>']" = rawLua
        "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Insert })";
      "['<C-p>']" = rawLua
        "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Insert })";
      "['<Down>']" = rawLua
        "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Select })";
      "['<Up>']" = rawLua
        "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Select })";
      "['<C-d>']" = rawLua "require('cmp').mapping.scroll_docs(-4)";
      "['<C-f>']" = rawLua "require('cmp').mapping.scroll_docs(4)";
      "['<C-Space>']" = rawLua "require('cmp').mapping.complete()";
      "['<C-e>']" = rawLua "require('cmp').mapping.close()";
      "['<CR>']" = rawLua
        "require('cmp').mapping.confirm({ behavior = require('cmp').ConfirmBehavior.Replace, select = true, })";
    };
    sources = [{ name = "nvim_lsp"; } { name = "buffer"; }];
    snippet.expand = rawLua '' function(args) require('luasnip').lsp_expand(args.body) end '';
  };

  use.lsp_signature.setup = callWith {
    bind = true;
    hint_enable = false;
    hi_parameter = "Visual";
    handler_opts.border = "single";
  };


  use.which-key.setup = callWith { };

  use.telescope.load_extension = callWith "harpoon";

}
