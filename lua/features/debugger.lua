return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-jdtls",
    },
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapTerminate",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
      "DapClearBreakpoints",
      "DapReplOpen",
    },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end,
        desc = "Conditional breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Open REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle UI",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dx",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "Clear breakpoints",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })

      dapui.setup()

      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = false,
        commented = false,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        only_first_definition = true,
        all_references = false,
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      local function setup_adapters()
        local ft = vim.bo.filetype
        if ft == "python" then
          require("languages.python-debug").setup()
        elseif ft == "java" then
          require("languages.java-debug").setup()
        end
      end

      setup_adapters()

      local augroup = vim.api.nvim_create_augroup("DapLanguageAdapters", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "python",
        callback = function()
          require("languages.python-debug").setup()
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "java",
        callback = function()
          require("languages.java-debug").setup()
        end,
      })
    end,
  },
}
