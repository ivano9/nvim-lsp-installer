local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    package = { "svelte-language-server" },
    cmd = "svelteserver",
    args = { "--stdio" },
}
