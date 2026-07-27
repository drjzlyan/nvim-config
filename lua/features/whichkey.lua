return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 0,
      icons = {
        mappings = false,
      },
      spec = {
        { "<leader>e", group = "Explorer" },
        { "<leader>f", group = "Files" },
        { "<leader>s", group = "Search" },
        { "<leader>d", group = "Debug" },
        { "<leader>l", group = "LSP" },
        { "<leader>t", group = "Terminal" },
        { "<leader>q", group = "Session" },
        { "<leader>W", desc = "Save" },
        { "<leader>Z", desc = "Quit" },
        { "<leader>c", desc = "Close buffer" },
        { "<leader>:", desc = "Command history" },
        { "<leader><space>", desc = "Buffers" },
      },
    },
  },
}
