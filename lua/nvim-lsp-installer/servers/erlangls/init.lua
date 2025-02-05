local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local process = require "nvim-lsp-installer.process"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://erlang-ls.github.io/",
        installer = {
            std.ensure_executables {
                { "rebar3", "rebar3 was not found in path. Refer to http://rebar3.org/docs/." },
            },
            context.latest_github_release "erlang-ls/erlang_ls",
            std.git_clone "https://github.com/erlang-ls/erlang_ls.git",
            function(server, callback, context)
                local c = process.chain {
                    cwd = server.root_dir,
                    stdio_sink = context.stdio_sink,
                }
                c.run("rebar3", { "escriptize" })
                c.run("rebar3", { "as", "dap", "escriptize" })
                c.spawn(callback)
            end,
            -- TODO: check this on Windows
            std.rename("_build/default/bin/erlang_ls", "erlang_ls"),
            std.chmod("+x", { "erlang_ls" }),
        },
        default_options = {
            cmd = { path.concat { root_dir, "erlang_ls" } },
        },
    }
end
