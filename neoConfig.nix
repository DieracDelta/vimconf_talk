{ pkgs, dsl }: with dsl; {

  vim.g = {
    mapleader = " ";
    nofoldenable = true;
    noshowmode = true;
    completeopt = "menu,menuone,noselect";
  };

  vim.o = {
    termguicolors = true;
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
    pastetoggle = "<leader>v";
    wildmode = "list:longest,list:full";
  };

  nnoremap.j = "gj";
  nnoremap.k = "gk";
  nnoremap."<leader>D" = "<cmd>lua\tvim.lsp.buf.declaration()<CR>";
  nnoremap."<leader>d" = "<cmd>lua\tvim.lsp.buf.definition()<CR>";
  nnoremap.K = "<cmd>lua\tvim.lsp.buf.hover()<CR>";
  nnoremap."<leader>i" = "<cmd>lua\tvim.lsp.buf.implementation()<CR>";
  nnoremap."<C-k>" = "<cmd>lua\tvim.lsp.buf.signature_help()<CR>";
  nnoremap."<leader>k" = "<cmd>lua\tvim.lsp.buf.type_definition()<CR>";
  nnoremap."<leader>rn" = "<cmd>lua\tvim.lsp.buf.rename()<CR>";
  nnoremap."<leader>ca" = "<cmd>lua\tvim.lsp.buf.code_action()<CR>";
  nnoremap."<leader>r" = "<cmd>lua\tvim.lsp.buf.references()<CR>";
  nnoremap."<leader>e" = "<cmd>lua\tvim.lsp.diagnostic.show_line_diagnostics()<CR>";
  nnoremap."<leader>f" = "<cmd>lua\tvim.lsp.buf.formatting()<CR>";
  nnoremap."<leader>bb" = "<cmd>Telescope buffers<cr>";
  nnoremap."<leader>gg" = "<cmd>Telescope live_grep<cr>";
  nnoremap."<leader><leader>" = "<cmd>Telescope find_files<cr>";
  nnoremap."<leader>ws" = "<cmd>sp<cr>";
  nnoremap."<leader>wv" = "<cmd>vs<cr>";
  nnoremap."<leader>bd" = "<cmd>q<cr>";
  nnoremap."<leader>bn" = "<cmd>tabnext<cr>";
  nnoremap."<leader>bp" = "<cmd>tabprevious<cr>";
  nnoremap."<leader>bN" = "<cmd>tabedit<cr>";
  nnoremap."<leader>bD" = "<cmd>Bclose!<cr>";
  nnoremap."<leader>wd" = "<cmd>q<cr>";
  nnoremap."<leader>wl" = "<cmd>wincmd l<cr>";
  nnoremap."<leader>wj" = "<cmd>wincmd j<cr>";
  nnoremap."<leader>wk" = "<cmd>wincmd k<cr>";
  nnoremap."<leader>wh" = "<cmd>wincmd h<cr>";


  use.lspconfig.rnix.setup = callWith {
    cmd = [ "rnix-lsp" ] ;
    capabilities = rawLua "require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())";
  };

  use.lspconfig.rust_analyzer.setup = callWith {
    cmd = [ "rust-analyzer" ] ;
    capabilities = rawLua "require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())";
  };

  use.lsp_signature.setup = callWith {
    bind = true;
    hint_enable = false;
    hi_parameter = "Visual";
    handler_opts.border = "single";
  };

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
      colors = [ "#bd93f9" "#6272a4" "#8be9fd" "#50fa7b" "#f1fa8c" "#ffb86c" "#ff5555" ];
    };
  };

  use.cmp.setup = callWith {
    mapping = {
      "['<C-n>']" = rawLua "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Insert })";
      "['<C-p>']" = rawLua "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Insert })";
      "['<Down>']" = rawLua "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Select })";
      "['<Up>']" = rawLua "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Select })";
      "['<C-d>']" = rawLua "require('cmp').mapping.scroll_docs(-4)";
      "['<C-f>']" = rawLua "require('cmp').mapping.scroll_docs(4)";
      "['<C-Space>']" = rawLua "require('cmp').mapping.complete()";
      "['<C-e>']" = rawLua "require('cmp').mapping.close()";
      "['<CR>']" = rawLua "require('cmp').mapping.confirm({ behavior = require('cmp').ConfirmBehavior.Replace, select = true, })";
    };
    sources = [
      { name = "nvim_lsp"; }
      { name = "buffer"; }
    ];
  };

  #          rawLua = [
  #            (DSL.DSL.callFn "vim.cmd" ["syntax on"])
  #            (DSL.DSL.callFn "vim.cmd" ["colorscheme dracula"])
  #          ];

}
