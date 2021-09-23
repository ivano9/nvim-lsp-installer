local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "stylelint-lsp" },
    cmd = "stylelint-lsp",
    args = { "--stdio" },
}
