local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = "pyright",
    cmd = "pyright-langserver",
    args = { "--stdio" },
}
