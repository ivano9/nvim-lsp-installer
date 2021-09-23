local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "vscode-langservers-extracted" },
    cmd = "vscode-html-language-server",
}
