local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "dot-language-server" },
    cmd = "dot-language-server",
    args = { "--stdio" },
}
