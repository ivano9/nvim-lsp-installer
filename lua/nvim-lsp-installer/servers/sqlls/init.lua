local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "sql-language-server" },
    cmd = "sql-language-server",
}
