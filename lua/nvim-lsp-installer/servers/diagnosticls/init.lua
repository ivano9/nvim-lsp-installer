local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "diagnostic-languageserver" },
    cmd = "diagnostic-languageserver",
    args = { "--stdio" },
}
