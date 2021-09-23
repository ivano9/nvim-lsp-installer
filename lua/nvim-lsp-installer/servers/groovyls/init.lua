local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local git = require "nvim-lsp-installer.process.git"
local std = require "nvim-lsp-installer.installers.std"

local REPO_URL = "github.com/GroovyLanguageServer/groovy-language-server"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.ensure_executables { { "javac", "javac was not found in path." } },
            std.git_clone(("https://%s"):format(REPO_URL)),
            std.gradlew {
                args = { "build" },
            },
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
            cmd = { "java", "-jar", path.concat { root_dir, "build", "libs", "groovyls-all.jar" } },
        },
    }
end
