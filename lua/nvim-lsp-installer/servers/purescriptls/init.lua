local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = "purescript-language-server",
    cmd = "purescript-language-server",
    args = { "--stdio" },
}
