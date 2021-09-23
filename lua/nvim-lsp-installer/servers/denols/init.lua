local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local installers = require "nvim-lsp-installer.installers"
local shell = require "nvim-lsp-installer.installers.shell"
local process = require "nvim-lsp-installer.process"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = installers.when {
            unix = shell.remote_bash("https://deno.land/x/install/install.sh", {
                env = {
                    DENO_INSTALL = root_dir,
                },
            }),
            win = shell.remote_powershell("https://deno.land/x/install/install.ps1", {
                env = {
                    DENO_INSTALL = root_dir,
                },
            }),
        },
        get_installed_packages = function(callback)
            local stdio = process.in_memory_sink()
            process.spawn(path.concat { root_dir, "bin", "deno" }, {
                args = { "--version" },
                cwd = root_dir,
                stdio_sink = stdio.sink,
            }, function(success)
                if success then
                    -- first line is in the structure of "deno 1.14.1 (release, aarch64-apple-darwin)"
                    local version = vim.split(stdio.buffers.stdout[1], " ")[2]
                    callback { { "deno", version } }
                else
                    callback(nil)
                end
            end)
        end,
        default_options = {
            cmd = { path.concat { root_dir, "bin", "deno" }, "lsp" },
        },
    }
end
