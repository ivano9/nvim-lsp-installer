local path = require "nvim-lsp-installer.path"
local fs = require "nvim-lsp-installer.fs"
local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local std = require "nvim-lsp-installer.installers.std"
local platform = require "nvim-lsp-installer.platform"
local process = require "nvim-lsp-installer.process"

local M = {}

local npm = platform.is_win and "npm.cmd" or "npm"

local function ensure_npm(installer)
    return installers.pipe {
        std.ensure_executables {
            { "node", "node was not found in path. Refer to https://nodejs.org/en/." },
            {
                "npm",
                "npm was not found in path. Refer to https://docs.npmjs.com/downloading-and-installing-node-js-and-npm.",
            },
        },
        installer,
    }
end

function M.packages(packages)
    return ensure_npm(function(server, callback, context)
        local c = process.chain {
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }
        -- stylua: ignore start
        if not (fs.dir_exists(path.concat { server.root_dir, "node_modules" }) or
               fs.file_exists(path.concat { server.root_dir, "package.json" }))
        then
            c.run(npm, { "init", "--yes" })
        end
        -- stylua: ignore end
        c.run(npm, vim.list_extend({ "install" }, packages or {}))
        c.spawn(callback)
    end)
end

-- @alias for packages
M.install = M.packages

function M.exec(executable, args)
    return function(server, callback, context)
        process.spawn(M.executable(server.root_dir, executable), {
            args = args,
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }, callback)
    end
end

function M.run(script)
    return ensure_npm(function(server, callback, context)
        process.spawn(npm, {
            args = { "run", script },
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }, callback)
    end)
end

function M.executable(root_dir, executable)
    return path.concat {
        root_dir,
        "node_modules",
        ".bin",
        platform.is_win and ("%s.cmd"):format(executable) or executable,
    }
end

function M.create_server(opts)
    return server.Server:new {
        name = opts.name,
        root_dir = opts.root_dir,
        installer = M.packages(opts.packages),
        default_options = vim.tbl_deep_extend("force", {
            cmd = vim.list_extend({ M.executable(opts.root_dir, opts.cmd) }, opts.args or {}),
        }, opts.default_options or {}),
        get_installed_packages = function(callback)
            local stdio = process.in_memory_sink()
            process.spawn(npm, {
                args = { "ls", "--depth", "0", "--parseable", "--long", opts.packages[1] },
                cwd = opts.root_dir,
                stdio_sink = stdio.sink,
            }, function(success)
                if success then
                    local packages = {}
                    for i = 1, #stdio.buffers.stdout do
                        local line = stdio.buffers.stdout[i]
                        local package = opts.packages[1]
                        local match = line and line:find(":" .. package .. "@", 1, true) ~= nil
                        print(match, package, line)
                        if match then
                            local version = vim.split(line, "@")[2]
                            print("version", version)
                            packages[#packages + 1] = { package, version }
                        end
                    end
                    callback(packages)
                else
                    callback(nil)
                end
            end)
        end,
        get_latest_available_packages = function(callback)
            local stdio = process.in_memory_sink()
            process.spawn(npm, {
                args = { "view", opts.packages[1], "version" },
                cwd = opts.root_dir,
                stdio_sink = stdio.sink,
            }, function(success)
                if success then
                    local version = vim.trim(stdio.buffers.stdout[1])
                    callback { { opts.packages[1], version } }
                else
                    callback(nil)
                end
            end)
        end,
    }
end

function M.server_factory(opts)
    return function(name, root_dir)
        local merged_opts = vim.tbl_deep_extend("force", opts, {
            name = name,
            root_dir = root_dir,
        })

        return M.create_server(merged_opts)
    end
end

return M
