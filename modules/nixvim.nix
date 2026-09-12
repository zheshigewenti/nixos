{inputs, ...}: {
  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;
    plugins.lz-n.enable = true;
    globals.mapleader = " ";

    extraConfigLua = ''
      local fcitx_state = 1
      local has_fcitx = vim.fn.executable("fcitx5-remote") == 1
      if has_fcitx then
        local augroup = vim.api.nvim_create_augroup("FcitxUltimate", { clear = true })
        local function fcitx_cmd(arg) vim.fn.jobstart({"fcitx5-remote", arg}) end

        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
          group = augroup,
          callback = function()
            vim.fn.jobstart({"fcitx5-remote"}, {
              stdout_buffered = true,
              on_stdout = function(_, data)
                if data and data[1] then
                  fcitx_state = tonumber(data[1]) or 1
                  if fcitx_state == 2 then fcitx_cmd("-c") end
                end
              end,
            })
          end,
        })

        vim.api.nvim_create_autocmd("InsertEnter", {
          group = augroup,
          callback = function() if fcitx_state == 2 then fcitx_cmd("-o") end end,
        })
      end
    '';

    defaultEditor = true;

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      expandtab = true;
      undofile = true;
      mouse = "a";
      clipboard = "unnamedplus";
      ignorecase = true;
    };

    plugins = {
      web-devicons.enable = false;

      treesitter = {
        enable = true;
        lazyLoad.settings.event = ["BufReadPost" "BufNewFile"];
      };

      telescope = {
        enable = true;
        lazyLoad.settings.cmd = ["Telescope"];
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
        };
      };

      lsp = {
        enable = true;
        lazyLoad.settings.event = ["FileType"];
        servers = {
          nixd.enable = true;
          texlab.enable = true;
          marksman.enable = true;
          html.enable = true;
          cssls.enable = true;
          clangd.enable = true;
        };
      };

      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-n>" = "cmp.config.disable";
            "<C-p>" = "cmp.config.disable";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            {name = "nvim_lsp";}
            {name = "buffer";}
            {name = "path";}
          ];
        };
      };
    };
  };
}
