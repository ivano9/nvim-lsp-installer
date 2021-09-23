local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local std = require "nvim-lsp-installer.installers.std"

local REPO_URL = "github.com/elixir-lsp/elixir-ls"
local VERSION = "v0.8.1"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.unzip_remote(("https://%s/releases/download/%s/elixir-ls.zip"):format(REPO_URL, VERSION), "elixir-ls"),
            std.chmod("+x", { "elixir-ls/language_server.sh" }),
        },
        get_installed_packages = function(callback)
            callback { { REPO_URL, VERSION } }
        end,
        default_options = {
            cmd = { path.concat { root_dir, "elixir-ls", "language_server.sh" } },
        },
    }
end
