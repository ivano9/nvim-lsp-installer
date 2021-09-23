local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local platform = require "nvim-lsp-installer.platform"
local std = require "nvim-lsp-installer.installers.std"
local git = require "nvim-lsp-installer.process.git"
local Data = require "nvim-lsp-installer.data"

local REPO_URL = "github.com/rust-analyzer/rust-analyzer"
local VERSION = "2021-06-28"

local target = Data.coalesce(
    Data.when(
        platform.is_mac,
        Data.coalesce(
            Data.when(platform.arch == "arm64", "rust-analyzer-aarch64-apple-darwin.gz"),
            Data.when(platform.arch == "x64", "rust-analyzer-x86_64-apple-darwin.gz")
        )
    ),
    Data.when(
        platform.is_linux,
        Data.coalesce(
            Data.when(platform.arch == "arm64", "rust-analyzer-aarch64-unknown-linux-gnu.gz"),
            Data.when(platform.arch == "x64", "rust-analyzer-x86_64-unknown-linux-gnu.gz")
        )
    ),
    Data.when(
        platform.is_win,
        Data.coalesce(
            Data.when(platform.arch == "arm64", "rust-analyzer-aarch64-pc-windows-msvc.gz"),
            Data.when(platform.arch == "x64", "rust-analyzer-x86_64-pc-windows-msvc.gz")
        )
    )
)

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.gunzip_remote(
                ("https://%s/releases/download/%s/%s"):format(REPO_URL, VERSION, target),
                platform.is_win and "rust-analyzer.exe" or "rust-analyzer"
            ),
            std.chmod("+x", { "rust-analyzer" }),
        },
        get_installed_packages = function(callback)
            git.get_head_sha(root_dir, function(sha)
                if sha then
                    callback { { REPO_URL, sha } }
                else
                    callback(nil)
                end
            end)
        end,
        get_latest_available_packages = function(callback)
            git.get_latest_upstream_sha(root_dir, function(sha)
                if sha then
                    callback { { REPO_URL, sha } }
                else
                    callback(nil)
                end
            end)
        end,
        default_options = {
            cmd = { path.concat { root_dir, "rust-analyzer" } },
        },
    }
end
