local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "typescript", "typescript-language-server" },
    cmd = "typescript-language-server",
    args = { "--stdio" },
}
