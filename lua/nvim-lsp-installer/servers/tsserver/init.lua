local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "typescript-language-server", "typescript" },
    cmd = "typescript-language-server",
    args = { "--stdio" },
}
