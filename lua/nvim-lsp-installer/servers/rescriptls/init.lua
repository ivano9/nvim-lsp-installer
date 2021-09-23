local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local std = require "nvim-lsp-installer.installers.std"

local REPO_URL = "github.com/rescript-lang/rescript-vscode"
local VERSION = "1.1.3"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = std.unzip_remote(
            ("https://%s/releases/download/%s/rescript-vscode-%s.vsix"):format(REPO_URL, VERSION, VERSION)
        ),
        get_installed_packages = function(callback)
            callback { { REPO_URL, VERSION } }
        end,
        default_options = {
            cmd = { "node", path.concat { root_dir, "extension", "server", "out", "server.js" }, "--stdio" },
        },
    }
end
