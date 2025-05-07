-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- カラースキーム設定
  {
    "catppuccin/nvim", -- お好みのカラースキームに変更可
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true, -- テーマの透明背景設定を有効化
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- カラースキームを適用
      vim.cmd.colorscheme("catppuccin")
      
      -- 即時に背景を透明にする設定
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
    end,
  },

  -- カラースキーム変更時に透明背景を維持するための設定
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- カラースキーム変更時に背景を透明に保つための自動コマンド
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- 背景色を透明にする設定
          vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
        end,
        group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
      })
      
      return opts
    end,
  },
}
