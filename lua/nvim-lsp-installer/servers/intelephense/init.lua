local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "intelephense" },
    cmd = "intelephense",
    args = { "--stdio" },
}
