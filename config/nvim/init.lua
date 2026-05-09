local function disable_rtp_plugins()
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_gzip = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_spellfile_plugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_zipPlugin = 1
end
disable_rtp_plugins()

vim.cmd('syntax enable')

vim.o.compatible = false
vim.o.belloff = 'all'
vim.o.mouse = ''

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
vim.o.wildoptions = 'pum'
vim.o.wildmode = 'full'

vim.o.ruler = true
vim.o.laststatus = 2

vim.o.cursorline = true
vim.o.cursorcolumn = true

vim.o.smarttab = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 0
vim.o.softtabstop = -1
vim.o.smartindent = true

if vim.fn.has('termguicolors') then
  vim.o.termguicolors = true
  vim.cmd('colorscheme industry')
  vim.cmd('highlight Normal guibg=NONE')
  vim.cmd('highlight NonText guibg=NONE')
  vim.cmd('highlight EndOfBuffer guibg=NONE')
  vim.cmd('highlight LineNr guibg=NONE')
end

vim.keymap.set('n', '<C-[><C-[>', ':nohlsearch<CR>', {silent=true})

local function enabled_clipboard()
  local function is_wayland()
    return vim.env.WAYLAND_DISPLAY ~= nil and vim.env.WAYLAND_DISPLAY ~= ''
  end
  local function has_wl_clipboard()
    return vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1
  end

  local function set_wl_copy()
    vim.g.clipboard = 'wl-copy'
  end

  if is_wayland() then
    if has_wl_clipboard() then
      set_wl_copy()
    end
  end
end
enabled_clipboard()

local function define_auto_mkdir()
  local gid = vim.api.nvim_create_augroup('vimrc_auto_mkdir', {})
  local function auto_mkdir(dir, force)
    local function prompt(dir)
      local ans = vim.fn.confirm(string.format('"%s" does not exist. Create?', dir), "&Yes\n&No")
      return ans == 1
    end
    if vim.fn.isdirectory(dir) == 0 and (force or prompt(dir)) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.o.encoding, vim.o.termencoding), 'p')
    end
  end
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    group = gid,
    callback = function(ev)
      auto_mkdir(vim.fn.expand(vim.fs.dirname(ev.file)), vim.v.cmdbang == 1)
    end
  })
end
define_auto_mkdir()

local function define_c_style()
  local gid = vim.api.nvim_create_augroup('c', {})
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'c',
    group = gid,
    command = 'setlocal tabstop=4'
  })
end
define_c_style()

vim.cmd('filetype plugin indent on')

