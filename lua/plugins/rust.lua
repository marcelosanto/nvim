local function rust_analyzer_settings()
  local opts = {
    checkOnSave = {
      -- enable = vim.env.NEOVIM_RUST_DIAGNOSTICS == "rust_analyzer",
      enable = false,
      command = "clippy",
      extraArgs = { "--no-deps" },
      target = vim.env.NEOVIM_RUST_TARGET,
    },
    callInfo = {
      full = true,
    },
    lens = {
      enable = true,
      references = true,
      implementations = true,
      enumVariantReferences = true,
      methodReferences = true,
    },
    inlayHints = {
      enable = true,
      bindingModeHints = {
        enable = false,
      },
      chainingHints = {
        enable = true,
      },
      closingBraceHints = {
        enable = true,
      },
      closureReturnTypeHints = {
        enable = true,
      },
      lifetimeElisionHints = {
        enable = true,
        useParameterNames = true,
      },
      parameterHints = {
        enable = true,
      },
      reborrowHints = {
        enable = "never",
      },
      renderColons = true,
      typeHints = {
        enable = true,
        hideClosureInitialization = false,
        hideNamedConstructor = false,
      },
    },
    cachePriming = {
      enable = true,
    },
    diagnostics = {
      enable = vim.env.NEOVIM_RUST_DIAGNOSTICS == "rust_analyzer",
    },
    cargo = {
      autoreload = true,
      loadOutDirsFromCheck = true,
      allFeatures = true,
      buildScripts = {
        enable = true,
      },
      target = vim.env.NEOVIM_RUST_TARGET,
    },
    hoverActions = {
      enable = true,
      references = true,
    },
    procMacro = {
      enable = true,
      ignored = {
        ["async-trait"] = { "async_trait" },
        ["napi-derive"] = { "napi" },
        ["async-recursion"] = { "async_recursion" },
      },
    },
  }
  if vim.env.NEOVIM_RUST_DEVELOP_RUSTC == "true" then
    opts["check"] = {
      invocationLocation = "root",
      invocationStrategy = "once",
      overrideCommand = {
        "python3",
        "x.py",
        "check",
        "--json-output",
      },
    }
    opts["linkedProjects"] = {
      "Cargo.toml",
      "src/tools/x/Cargo.toml",
      "src/bootstrap/Cargo.toml",
      "src/tools/rust-analyzer/Cargo.toml",
      "compiler/rustc_codegen_cranelift/Cargo.toml",
      "compiler/rustc_codegen_gcc/Cargo.toml",
    }
    opts["rustfmt"] = {
      overrideCommand = {
        "${workspaceFolder}/build/host/rustfmt/bin/rustfmt",
        "--edition=2021",
      },
    }
    opts["procMacro"]["server"] = "${workspaceFolder}/build/host/stage0/libexec/rust-analyzer-proc-macro-srv"
    opts["cargo"]["sysrootSrc"] = "./library"
    opts["cargo"]["extraEnv"] = {
      RUSTC_BOOTSTRAP = "1",
    }
    opts["rustc"] = {
      source = "./Cargo.toml",
    }
    opts["cargo"]["buildScripts"] = {
      enable = true,
      invocationLocation = "root",
      invocationStrategy = "once",
      overrideCommand = {
        "python3",
        "x.py",
        "check",
        "--json-output",
      },
    }
  end
  return opts
end

local function codelldb_adapter()
  local cfg = require("rustaceanvim.config")
  local home = vim.env.HOME
  local pkg = home .. "/.local/share/nvim/mason/packages/codelldb"
  local codelldb = pkg .. "/extension/adapter/codelldb"
  local liblldb = pkg .. "/extension/lldb/lib/liblldb.dylib"
  local dap = require("dap")
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    host = "127.0.0.1",
    executable = {
      command = codelldb,
      args = { "--liblldb", liblldb, "--port", "${port}" },
    },
  }
  return cfg.get_codelldb_adapter(codelldb, liblldb)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {      
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
          vim.keymap.set("n", "<leader>K", function() 
            vim.cmd.RustLsp { "hover", "actions" } 
          end, { buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust.
            checkOnSave = true,
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      -- if vim.fn.executable("rust-analyzer") == 0 then
      --   LazyVim.error(
      --     "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
      --     { title = "rustaceanvim" }
      --   )
      -- end,
      vim.g.rustaceanvim = {
        tools = {
            float_win_config = {
                border = 'rounded'
            }
        },
        server = {
            on_attach = require("lvim.lsp").common_on_attach
        },
      }
      end,
    end,
  },
}
