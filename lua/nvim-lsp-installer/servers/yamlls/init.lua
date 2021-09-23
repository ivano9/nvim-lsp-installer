local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "yaml-language-server" },
    cmd = "yaml-language-server",
    args = { "--stdio" },
}
