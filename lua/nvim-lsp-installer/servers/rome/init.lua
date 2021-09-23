local npm = require "nvim-lsp-installer.installers.npm"

return npm.server_factory {
    packages = { "rome@10.0.7-nightly.2021.7.2" }, -- https://github.com/rome/tools/pull/1409
    cmd = "rome",
    args = { "lsp" },
}
