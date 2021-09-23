local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "@tailwindcss/language-server" },
    cmd = "tailwindcss-language-server",
    args = { "--stdio" },
}
