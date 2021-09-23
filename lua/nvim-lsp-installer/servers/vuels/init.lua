local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "vls" },
    cmd = "vls",
    args = { "--stdio" },
}
