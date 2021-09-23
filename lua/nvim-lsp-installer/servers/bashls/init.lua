local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "bash-language-server" },
    cmd = "bash-language-server",
    args = { "start" },
}
