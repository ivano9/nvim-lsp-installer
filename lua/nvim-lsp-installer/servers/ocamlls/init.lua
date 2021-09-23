local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "ocaml-language-server" },
    cmd = "ocaml-language-server",
    args = { "--stdio" },
}
