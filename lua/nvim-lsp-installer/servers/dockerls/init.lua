local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "dockerfile-language-server-nodejs" },
    cmd = "docker-langserver",
    args = { "--stdio" },
}
