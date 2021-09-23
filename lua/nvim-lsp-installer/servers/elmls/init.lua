local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return npm.create_server {
        name = name,
        root_dir = root_dir,
        packages = { "elm", "elm-test", "elm-format", "@elm-tooling/elm-language-server" },
        cmd = "elm-language-server",
        default_options = {
            init_options = {
                elmPath = npm.executable(root_dir, "elm"),
                elmFormatPath = npm.executable(root_dir, "elm-format"),
                elmTestPath = npm.executable(root_dir, "elm-test"),
                elmAnalyseTrigger = "change",
            },
        },
    }
end
