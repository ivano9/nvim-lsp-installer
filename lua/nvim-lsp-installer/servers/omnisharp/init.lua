local server = require "nvim-lsp-installer.server"
local platform = require "nvim-lsp-installer.platform"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"

local REPO_URL = "github.com/OmniSharp/omnisharp-roslyn"
local VERSION = "v1.37.15"

local target = Data.coalesce(
    Data.when(platform.is_mac, "omnisharp-osx.zip"),
    Data.when(platform.is_linux and platform.arch == "x64", "omnisharp-linux-x64.zip"),
    Data.when(
        platform.is_win,
        Data.coalesce(
            Data.when(platform.arch == "x64", "omnisharp-win-x64.zip"),
            Data.when(platform.arch == "arm64", "omnisharp-win-arm64.zip")
        )
    )
)

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.unzip_remote(("https://%s/releases/download/%s/%s"):format(REPO_URL, VERSION, target), "omnisharp"),
            std.chmod("+x", { "omnisharp/run" }),
        },
        get_installed_packages = function(callback)
            callback { { REPO_URL, VERSION } }
        end,
        default_options = {
            cmd = {
                platform.is_win and path.concat { root_dir, "OmniSharp.exe" } or path.concat {
                    root_dir,
                    "omnisharp",
                    "run",
                },
                "--languageserver",
                "--hostPID",
                tostring(vim.fn.getpid()),
            },
        },
    }
end
