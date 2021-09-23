local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "graphql-language-service-cli", "graphql" },
    cmd = "graphql-lsp",
    args = { "server", "-m", "stream" },
    default_options = {
        filetypes = { "typescriptreact", "javascriptreact", "graphql" },
    },
}
