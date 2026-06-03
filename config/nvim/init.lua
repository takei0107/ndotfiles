-- disable rtp plugins
local function disable_rtp_plugins()
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_gzip = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_netrw = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_spellfile_plugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_zipPlugin = 1
end

-- set basic vim options
local function set_vim_opts()
  vim.o.compatible = false
  vim.o.belloff = "all"
  vim.o.mouse = ""

  local function setup_recovery_files()
    vim.o.swapfile = false
    vim.o.backup = false
    vim.o.undofile = true
  end
  setup_recovery_files()

  vim.o.number = true
  vim.o.splitright = true
  vim.o.splitbelow = true

  vim.o.hlsearch = true
  vim.o.incsearch = true

  vim.o.wildmenu = true
  vim.o.wildoptions = "pum"
  vim.o.wildmode = "full"

  vim.o.ruler = true
  vim.o.laststatus = 2

  vim.o.cursorline = true
  vim.o.cursorcolumn = true

  vim.o.winborder = "single"
  vim.o.pumborder = "single"

  vim.opt.completeopt = { "menu", "noselect", "popup" }

  vim.o.smarttab = true
  vim.o.expandtab = true
  vim.o.tabstop = 2
  vim.o.shiftwidth = 0
  vim.o.softtabstop = -1
  vim.o.smartindent = true
end

-- set main theme
---@param has_term_gui_colors boolean
local function set_theme(has_term_gui_colors)
  if has_term_gui_colors then
    vim.o.termguicolors = true
    vim.cmd("colorscheme industry")
    vim.cmd("highlight Normal guibg=NONE")
    vim.cmd("highlight NonText guibg=NONE")
    vim.cmd("highlight EndOfBuffer guibg=NONE")
    vim.cmd("highlight LineNr guibg=NONE")
  end
end

-- set basic keymaps
local function set_keymaps()
  vim.keymap.set("n", "<C-[><C-[>", ":nohlsearch<CR>", { silent = true })
end

---@return boolean
local function is_wayland()
  return vim.fn.empty(vim.env.WAYLAND_DISPLAY) == 0
end

-- making available clipboard, if effective clibpoard-tool is installed
-- :h clipboard-tool
local function enabled_clipboard()
  local function has_wl_clipboard()
    return vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1
  end

  local function set_wl_copy()
    vim.g.clipboard = "wl-copy"
  end

  if is_wayland() then
    if has_wl_clipboard() then
      set_wl_copy()
    end
  end
end

-- making available to make directory, if not exists on file saved
-- https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
local function define_auto_mkdir()
  local function auto_mkdir(dir, force)
    local function prompt(dirname)
      local ans = vim.fn.confirm(string.format('"%s" does not exist. Create?', dirname), "&Yes\n&No")
      return ans == 1
    end
    if vim.fn.isdirectory(dir) == 0 and (force or prompt(dir)) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.o.encoding, vim.o.termencoding), "p")
    end
  end

  local gid = vim.api.nvim_create_augroup("vimrc_auto_mkdir", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    group = gid,
    callback = function(ev)
      auto_mkdir(vim.fn.expand(vim.fs.dirname(ev.file)), vim.v.cmdbang == 1)
    end,
  })
end

---@class RCVimPackConfig: vim.pack.keyset.add
---@field spec string|vim.pack.Spec
---@field init? function

-- vim.pack wrapper
---@param configs RCVimPackConfig[]
local function vim_pack(configs)
  ---@type vim.pack.keyset.add
  local default_opts = {
    confirm = false,
  }

  local itr = vim.iter(configs)
  itr:each(function(
    config --[[@as RCVimPackConfig]]
  )
    ---@type vim.pack.keyset.add
    local opts = config.opts and vim.tbl_extend("force", default_opts, config.opts) or default_opts

    vim.pack.add({
      config.spec,
    }, opts)

    if vim.is_callable(config.init) then
      config.init()
    end
  end)
end

---@return { efm_enabled: function? }
local function setup_plugins()
  ---@type { efm_enabled: function? }
  local M = {}

  ---@param x string
  ---@return string
  local github = function(x)
    return "https://github.com/" .. x
  end

  local function install()
    vim_pack({
      {
        spec = github("neovim/nvim-lspconfig.git"),
      },
      {
        spec = github("mason-org/mason.nvim.git"),
        init = function()
          require("mason").setup()

          local function install_required()
            local mason_registry = require("mason-registry")

            local required_packages = {
              "stylua",
            }

            local packages_installed = vim
              .iter(required_packages)
              :filter(function(p)
                return not mason_registry.is_installed(p)
              end)
              :join(" ")

            if packages_installed ~= "" then
              vim.cmd((":MasonInstall %s"):format(packages_installed))
            end
          end

          vim.api.nvim_create_autocmd("VimEnter", {
            pattern = "*",
            callback = function()
              install_required()
            end,
          })
        end,
      },
      {
        spec = github("mason-org/mason-lspconfig.nvim.git"),
        init = function()
          require("mason-lspconfig").setup({
            -- [prerequisites]
            -- - pip, venv (for pylsp)
            --   - $ sudo apt install --no-install-recommends python3-pip python3-venv
            -- - node.js (for vtsls)
            --   - $ mise use -g node
            ensure_installed = { "efm", "lua_ls", "pylsp", "vtsls" },
          })
        end,
      },
      {
        spec = github("creativenull/efmls-configs-nvim"),
        init = function()
          M.efm_enabled = function()
            local stylua = require("efmls-configs.formatters.stylua")

            local languages = {
              lua = { stylua },
            }

            local config = {
              filetypes = vim.tbl_keys(languages),
              settings = {
                languages = languages,
              },
              init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
              },
            }

            vim.lsp.config("efm", config)
            vim.lsp.enable("efm")

            local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
            vim.api.nvim_create_autocmd("BufWritePost", {
              group = lsp_fmt_group,
              callback = function(ev)
                local efm = vim.lsp.get_clients({ name = "efm", bufnr = ev.buf })

                if vim.tbl_isempty(efm) then
                  return
                end

                vim.lsp.buf.format({ name = "efm" })
              end,
            })
          end
        end,
      },
      {
        spec = github("cohama/lexima.vim.git"),
      },
      {
        spec = github("nvim-mini/mini.pick"),
        init = function()
          local minipick = require("mini.pick")
          minipick.setup({
            source = {
              show = minipick.default_show,
            },
            mappings = {
              delete_char = "<C-h>",
              scroll_left = "<M-h>",
              scroll_right = "<M-l>",
            },
          })
          vim.keymap.set("n", "<C-p>", function()
            minipick.builtin.files()
          end)
        end,
      },
      {
        spec = github("lewis6991/gitsigns.nvim"),
        init = function()
          require("gitsigns").setup()
        end,
      },
      {
        spec = github("nvim-mini/mini.statusline"),
        init = function()
          require("mini.statusline").setup({
            use_icons = false,
          })
        end,
      },
    })
  end

  local function remove()
    local deleted_specs = vim
      .iter(vim.pack.get())
      :filter(function(
        x --[[@as vim.pack.keyset.get]]
      )
        return not x.active
      end)
      :map(function(x)
        return x.spec
      end)
      :filter(function(spec)
        return vim.fn.confirm(
          ("really remove this plugin? name = %s, src = %s"):format(spec.name, spec.src),
          "&Yes\n&No"
        ) == 1
      end)
      :totable()

    if #deleted_specs > 0 then
      vim.pack.del(vim
        .iter(deleted_specs)
        :map(function(spec)
          return spec.name
        end)
        :totable())
    end
  end

  install()
  remove()

  return M
end

local function setup_lsp()
  local function completion_enable(client_id, bufnr)
    vim.lsp.completion.enable(true, client_id, bufnr, {
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub("%b()", "") }
      end,
    })
  end

  local function all_client_setting()
    vim.lsp.config("*", {
      on_attach = function(client, bufnr)
        completion_enable(client.id, bufnr)
        vim.keymap.set("i", "<C-n>", function()
          if vim.fn.pumvisible() == 1 then
            local key = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
            vim.api.nvim_feedkeys(key, "i", false)
          else
            vim.lsp.completion.get()
          end
        end, {
          buf = bufnr,
          silent = true,
        })
      end,
    })
  end

  local function lua_ls_setting()
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            pathStrict = true,
            path = { "?.lua", "?/init.lua" },
          },
          workspace = {
            library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), {
              "${3rd}/luv/library",
            }),
            checkThirdParty = "Disable",
          },
        },
      },
    })
  end

  local function lua_ls()
    lua_ls_setting()
    vim.lsp.enable("lua_ls")
  end

  local function pylsp()
    vim.lsp.enable("pylsp")
  end

  local function vtsls()
    vim.lsp.enable("vtsls")
  end

  all_client_setting()
  lua_ls()
  pylsp()
  vtsls()
end

local function setup_diagnostic()
  vim.diagnostic.config({
    virtual_text = true,
  })
end

local function define_c_style()
  local gid = vim.api.nvim_create_augroup("c", {})
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    group = gid,
    command = "setlocal tabstop=4",
  })
end

local function main()
  disable_rtp_plugins()

  vim.cmd("syntax enable")

  -- basic opts, theme, keymaps, tools and customizes
  set_vim_opts()
  enabled_clipboard()
  set_theme(vim.fn.has("termguicolors") == 1)
  set_keymaps()
  define_auto_mkdir()

  -- lsp and diagnostic
  local m = setup_plugins() or {}
  setup_lsp()
  if vim.is_callable(m.efm_enabled) then
    ---@cast m { efm_enabled: function }
    m.efm_enabled()
  end
  setup_diagnostic()

  -- code stylings
  define_c_style()

  vim.cmd("filetype plugin indent on")
end

main()
