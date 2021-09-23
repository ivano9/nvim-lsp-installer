local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "@prisma/language-server" },
    cmd = "prisma-language-server",
    args = { "--stdio" },
}
