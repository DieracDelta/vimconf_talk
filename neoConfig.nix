{ pkgs, dsl }:
with dsl; {

  vim.g = {
    mapleader = " ";
    nofoldenable = true;
    noshowmode = true;
    completeopt = "menu,menuone,noselect";
    noswapfile = true;
    blamer_enabled = 1;
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
      "K" = [ "<cmd>lua show_documentation()<CR>" "Get Type Information" ];
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
        "fb" = [ "<cmd>Telescope file_browser<cr>" "Get buffer list" ];
        "gg" = [ "<cmd>Telescope live_grep<cr>" "Fzf fuzzy search" ];
        "['<leader>']" = [ "<cmd>Telescope find_files<cr>" "search files" ];
        "ws" = [ "<cmd>sp<cr>" "Split window horizontally" ];
        "wv" = [ "<cmd>vs<cr>" "Split window vertically" ];
        "bd" = [ "<cmd>q<cr>" "Delete buffer" ];
        "bn" = [ "<cmd>bnext<cr>" "Next buffer" ];
        "bp" = [ "<cmd>bprev<cr>" "Previous buffer" ];
        "bN" = [ "<cmd>tabedit<cr>" "New buffer/tab" ];
        "bD" = [ "<cmd>Bclose!<cr>" "Delete buffer aggressively" ];
        "wd" = [ "<cmd>q<cr>" "Delete window" ];
        "wl" = [ "<cmd>wincmd l<cr>" "Move window right" ];
        "wj" = [ "<cmd>wincmd j<cr>" "Move window down" ];
        "wk" = [ "<cmd>wincmd k<cr>" "Move window up" ];
        "wh" = [ "<cmd>wincmd h<cr>" "Move window left" ];
        "gs" = [ "<cmd>lua require('neogit').open()<CR>" "Open neogit (magit clone)" ];
        "gb" = [ "<cmd>BlamerToggle<CR>" "Toggle git blame" ];
        "gc" = ["<cmd>Neogen<CR>" "generate comments boilerplate"];

        # rust bindings
        # TODO
        # "rJ"
        "rm" = [ "<cmd>lua require'rust-tools.expand_macro'.expand_macro()<CR>" "Expand macro" ];
        "rh" = [ "cmd lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>" "toggle inlay type hints"];
        "rpm" = [ "cmd lua require'rust-tools.parent_module'.parent_module()<CR>" "go to parent module" ];
        "rJ" = [ "cmd lua require'rust-tools.join_lines'.join_lines()<CR>" "join lines rust" ];
        "cu" = [ "lua require('crates').update_crate()" "update a crate"];
        "cua" = [ "lua require('crates').update_all_crates()" "update all crates"];
        "cU" = [ "lua require('crates').upgrade_crate()" "upgrade a crate"];
        "cUa" = [ "lua require('crates').upgrade_all_crates()" "upgrade all crates"];

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

  use.crates.setup = callWith {
    text = {
      loading = "  Loading...";
      version = "  %s";
      prerelease = "  %s";
      yanked = "  %s yanked";
      nomatch = "  Not found";
      upgrade = "  %s";
      error = "  Error fetching crate";
    };
    popup = {
      text = {
        title = " # %s ";
        version = " %s ";
        prerelease = " %s ";
        yanked = " %s yanked ";
        feature = "   %s ";
        enabled = " * %s ";
        transitive = " ~ %s ";
      };
    };
    cmp = {
      text = {
        prerelease = " pre-release ";
        yanked = " yanked ";
      };
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
    settings = {
      "['rust-analyzer']" = {
        procMacro = {
          enable = true;
        };
      };
    };
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
    sources = [{ name = "nvim_lsp"; } { name = "buffer"; } { name = "vsnip"; } { name = "crates"; } ];
    snippet.expand = rawLua '' function(args) vim.fn["vsnip#anonymous"](args.body) end '';
  };


  use.lsp_signature.setup = callWith {
    bind = true;
    hint_enable = false;
    hi_parameter = "Visual";
    handler_opts.border = "single";
  };

  use.which-key.setup = callWith { };
  use.neogit.setup = callWith { };
  use.rust-tools.setup = callWith {
    tools = {
      autoSetHints = true;
      runnables = {
        use_telescope = true;
      };
      inlay_hints = {

        only_current_line = false;
        only_current_line_autocmd = "CursorMoved";

        show_parameter_hints = true;

        parameter_hints_prefix = "<- ";
        other_hints_prefix = "=> ";

        max_len_align = false;

        max_len_align_padding = 1;

        right_align = false;

        right_align_padding = 7;
        highlight = "DiagnosticSignWarn";
      };
    };
  };

  use.neogen.setup = callWith {
    enabled = true;
  };

  use.fidget.setup = callWith {};

  lua = ''
    vim.api.nvim_set_keymap("i", "<Tab>", "vsnip#available(1)  ? '<Plug>(vsnip-jump-next)': '<Tab>'", {expr = true})
    vim.api.nvim_set_keymap("s", "<Tab>", "vsnip#available(1)  ? '<Plug>(vsnip-jump-next)': '<Tab>'", {expr = true})
    vim.api.nvim_set_keymap("i", "<S-Tab>", "vsnip#available(-1)  ? '<Plug>(vsnip-jump-prev)': '<S-Tab>'", {expr = true})
    vim.api.nvim_set_keymap("s", "<S-Tab>", "vsnip#available(-1)  ? '<Plug>(vsnip-jump-prev)': '<S-Tab>'", {expr = true})
    vim.api.nvim_set_keymap("i", "<C-j>", "vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'", {expr = true})
    vim.api.nvim_set_keymap("s", "<C-j>", "vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'", {expr = true})

    require("telescope").setup {
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          }
        }
      }
    }
    require("telescope").load_extension("file_browser")
    require("telescope").load_extension("ui-select")
    function show_documentation()
        local filetype = vim.bo.filetype
        if vim.tbl_contains({ 'vim','help' }, filetype) then
            vim.cmd('h '..vim.fn.expand('<cword>'))
        elseif vim.tbl_contains({ 'man' }, filetype) then
            vim.cmd('Man '..vim.fn.expand('<cword>'))
        elseif vim.fn.expand('%:t') == 'Cargo.toml' then
            require('crates').show_popup()
        else
            vim.lsp.buf.hover()
        end
    end
  '';

}
