return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin",
    opts = {
      integrations = {
        rainbow_delimiters = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      matchup = { enable = true },
      ensure_installed = {
        "comment",
        "embedded_template",
        "ruby",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
  },
  {
    "RRethy/vim-illuminate",
    enabled = false,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local erb_lint = require("lint").linters.erb_lint
      local standardrb = require("lint").linters.standardrb

      erb_lint.cmd = "erblint"
      erb_lint.args = { "--format", "compact" }

      standardrb.ignore_exitcode = true

      opts.linters_by_ft = {
        ruby = { "standardrb", "typos" },
        eruby = { "erb_lint" },
        javascript = { "standardjs", "typos" },
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      format = {
        timeout_ms = 1200,
      },
      formatters_by_ft = {
        ruby = { "standardrb", "typos" },
        eruby = { "erb_lint" },
        javascript = { "standardjs", "typos" },
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    -- Disable default <tab> and <s-tab> behavior in LuaSnip
    keys = function()
      return {}
    end,
    config = function()
      local luasnip = require("luasnip")

      luasnip.filetype_extend("ruby", { "rails" })
      luasnip.filetype_extend("eruby", { "html" })

      require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.config/nvim/snippets" })
    end,
  },
  {
    {
      "hrsh7th/nvim-cmp",
      ---@param opts cmp.ConfigSchema
      opts = function(_, opts)
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local cmp = require("cmp")
        local luasnip = require("luasnip")

        for _, v in ipairs(opts.sources) do
          if v.name == "buffer" then
            v.group_index = 1
            v.option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            }
          end
        end

        -- Set up supertab in cmp
        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        })
      end,
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ruby-lsp",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          -- Disabled formatting
          handlers = { ["textDocument/publishDiagnostics"] = function(...) end },
          -- Disabled diagnostics
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        ruby_ls = {
          init_options = {
            enabledFeatures = {
              "codeActions",
              "codeLens",
              "completion",
              "definition",
              "documentHighlights",
              "documentSymbols",
              "foldingRanges",
              "hover",
              "inlayHint",
              "selectionRanges",
              "semanticHighlighting",
              "workspaceSymbol",
              -- "diagnostics",
              -- "documentLink",
              -- "formatting",
              -- "onTypeFormatting",
            },
          },
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    enabled = false,
    -- dependencies = {
    --   "olimorris/neotest-rspec",
    -- },
    -- opts = function(_, opts)
    --   table.insert(
    --     opts.adapters,
    --     require("neotest-rspec")({
    --       rspec_cmd = function()
    --         return vim.tbl_flatten({
    --           "dip",
    --           "rspec",
    --         })
    --       end,
    --
    --       -- -- Pass the spec file as a relative path instead of an absolute path
    --       -- -- to RSpec
    --       -- transform_spec_path = function(path)
    --       --   local prefix = require("neotest-rspec").root(path)
    --       --   return string.sub(path, string.len(prefix) + 2, -1)
    --       -- end,
    --       --
    --       -- results_path = "tmp/rspec.output",
    --     })
    --   )
    -- end,
  },
  {
    "vim-test/vim-test",
    config = function()
      vim.cmd([[
        let test#strategy = "neovim"

        nmap <silent> <leader>tr :TestNearest<CR>

        let test#ruby#rspec#executable = "dip rspec"
      ]])
    end,
  },
  {
    "ckolkey/ts-node-action",
    dependencies = { "nvim-treesitter" },
    keys = {
      {
        "<leader>n",
        function()
          require("ts-node-action").node_action()
        end,
        desc = "Trigger Node Action",
      },
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
    end,
  },
}
