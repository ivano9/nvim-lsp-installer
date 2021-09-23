local process = require "nvim-lsp-installer.process"

local M = {}

function M.get_head_sha(root_dir, callback)
    local stdio = process.in_memory_sink()
    process.spawn("git", {
        args = { "rev-parse", "--short", "HEAD" },
        cwd = root_dir,
        stdio_sink = stdio.sink,
    }, function(success)
        if success then
            callback(vim.trim(stdio.buffers.stdout[1]))
        else
            callback(nil)
        end
    end)
end

function M.get_latest_upstream_sha(root_dir, callback)
    local stdio = process.in_memory_sink()
    local c = process.chain {
        cwd = root_dir,
        stdio_sink = stdio.sink,
    }
    c.run("git", { "fetch" })
    c.run("git", { "rev-parse", "--short", "@{u}" })
    c.spawn(function(success)
        if success then
            callback(vim.trim(stdio.buffers.stdout[#stdio.buffers.stdout - 1]))
        else
            callback(nil)
        end
    end)
end

return M
