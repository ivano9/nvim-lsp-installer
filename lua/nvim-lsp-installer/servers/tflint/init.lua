local server = require "nvim-lsp-installer.server"
local notify = require "nvim-lsp-installer.notify"
local path = require "nvim-lsp-installer.path"
local installers = require "nvim-lsp-installer.installers"
local shell = require "nvim-lsp-installer.installers.shell"
local process = require "nvim-lsp-installer.process"

return function(name, root_dir)
    local bin_path = path.concat { root_dir, "tflint" }

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = installers.when {
            unix = shell.remote_bash(
                "https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh",
                {
                    env = {
                        TFLINT_INSTALL_PATH = root_dir,
                        TFLINT_INSTALL_NO_ROOT = 1,
                    },
                }
            ),
        },
        default_options = {
            cmd = { bin_path, "--langserver" },
        },
        get_installed_packages = function (callback)
            -- TODO tflint --version
        end,
        post_setup = function()
            function _G.lsp_installer_tflint_init()
                notify "Installing TFLint plugins…"
                process.spawn(
                    bin_path,
                    {
                        args = { "--init" },
                        cwd = path.cwd(),
                        stdio_sink = process.simple_sink(),
                    },
                    vim.schedule_wrap(function(success)
                        if success then
                            notify "Successfully installed TFLint plugins."
                        else
                            notify "Failed to install TFLint."
                        end
                    end)
                )
            end

            vim.cmd [[ command! TFLintInit call v:lua.lsp_installer_tflint_init() ]]
        end,
    }
end
