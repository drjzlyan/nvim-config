local function in_git_repo()
  local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.trim(result) == "true"
end

local function lazygit_float()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed. Install it with: brew install lazygit", vim.log.levels.ERROR)
    return
  end
  if not in_git_repo() then
    vim.notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.bo[buf].bufhidden = "wipe"

  vim.fn.jobstart("lazygit", {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })

  vim.cmd("startinsert")
end

return {
  {
    "lewis6991/gitsigns.nvim",
    cond = in_git_repo,
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>gg", lazygit_float, desc = "LazyGit" },
      { "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Line blame" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk", mode = { "n", "v" } },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk", mode = { "n", "v" } },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage hunk" },
      { "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous hunk" },
      { "<leader>gD", "<cmd>Gitsigns diffthis<cr>", desc = "Diff against index" },
    },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
        },
        preview_config = {
          border = "rounded",
        },
      })

      vim.api.nvim_create_user_command("LazyGit", lazygit_float, { desc = "Open LazyGit in a floating terminal" })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cond = in_git_repo,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gd",
        function()
          vim.cmd("DiffviewOpen")
        end,
        desc = "Diffview",
      },
    },
    config = function()
      require("diffview").setup({})
    end,
  },
}
