local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "vim-language-server" },
    cmd = "vim-language-server",
    args = { "--stdio" },
}
