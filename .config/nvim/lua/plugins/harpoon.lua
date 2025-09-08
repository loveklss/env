-- This file installs and configures the harpoon plugin for fast file navigation.

return {
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Harpoon's setup is minimal
      require("harpoon").setup({})

      local map = vim.keymap.set
      -- Import the specific modules for mark and ui, as per the new API
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      -- Keymap to add the current file to the Harpoon list
      map("n", "<leader>ha", mark.add_file, { desc = "Harpoon: [A]dd file" })

      -- Keymap to open the Harpoon UI
      map("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: Toggle UI [H]ub" })

      -- Keymaps to navigate to specific files
      map("n", "<leader>h1", function() ui.nav_file(1) end, { desc = "Harpoon: Go to file 1" })
      map("n", "<leader>h2", function() ui.nav_file(2) end, { desc = "Harpoon: Go to file 2" })
      map("n", "<leader>h3", function() ui.nav_file(3) end, { desc = "Harpoon: Go to file 3" })
      map("n", "<leader>h4", function() ui.nav_file(4) end, { desc = "Harpoon: Go to file 4" })
    end,
  },
}