local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "@lifeart/ember-language-server" },
    cmd = "ember-language-server",
    args = { "--stdio" },
}
