local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "vscode_langservers_extracted" },
    cmd = "vscode-json-language-server",
}
