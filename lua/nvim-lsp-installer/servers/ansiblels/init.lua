local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local git = require "nvim-lsp-installer.process.git"
local std = require "nvim-lsp-installer.installers.std"
local npm = require "nvim-lsp-installer.installers.npm"

local REPO_URL = "github.com/ansible/ansible-language-server"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.git_clone(("https://%s"):format(REPO_URL)),
            npm.install { "npm@latest" }, -- ansiblels has quite a strict npm version requirement
            npm.exec("npm", { "install" }),
            npm.run "compile",
            npm.exec("npm", { "install", "--production" }),
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
            filetypes = { "yaml", "yaml.ansible" },
            cmd = { "node", path.concat { root_dir, "out", "server", "src", "server.js" }, "--stdio" },
        },
    }
end
