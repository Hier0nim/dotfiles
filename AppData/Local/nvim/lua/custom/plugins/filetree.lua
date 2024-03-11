vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {}

    -- Define key mappings
    local opts = { noremap = true, silent = true }

    -- Toggle Neo-tree file explorer
    vim.api.nvim_set_keymap('n', '<leader>nn', ':Neotree reveal toggle<CR>', opts)

    -- Toggle Neo-tree git status
    vim.api.nvim_set_keymap('n', '<leader>ng', ':Neotree source=git_status toggle<CR>', opts)

    -- Toggle Neo-tree buffer explorer
    vim.api.nvim_set_keymap('n', '<leader>nb', ':Neotree source=buffers toggle<CR>', opts)
  end,
}
