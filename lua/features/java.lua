return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          java = { "google-java-format" },
        },
        formatters = {
          ["google-java-format"] = {
            command = "google-java-format",
            args = { "--aosp", "-" },
            stdin = true,
          },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
      })
    end,
  },
}
