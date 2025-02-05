local dispatcher = require "nvim-lsp-installer.dispatcher"
local fs = require "nvim-lsp-installer.fs"
local log = require "nvim-lsp-installer.log"
local installers = require "nvim-lsp-installer.installers"
local servers = require "nvim-lsp-installer.servers"
local status_win = require "nvim-lsp-installer.ui.status-win"

local M = {}

-- old, but also somewhat convenient, API
M.get_server_root_path = servers.get_server_install_path

M.Server = {}
M.Server.__index = M.Server

---@class Server
--@param opts table
-- @field name (string)                  The name of the LSP server. This MUST correspond with lspconfig's naming.
--
-- @field homepage (string)              A URL to the homepage of this server. This is for example where users can
--                                       report issues and receive support.
--
-- @field installer (function)           The function that installs the LSP (see the .installers module). The function signature should be `function (server, callback)`, where
--                                       `server` is the Server instance being installed, and `callback` is a function that must be called upon completion. The `callback` function
--                                       has the signature `function (success, result)`, where `success` is a boolean and `result` is of any type (similar to `pcall`).
--
-- @field default_options (table)        The default options to be passed to lspconfig's .setup() function. Each server should provide at least the `cmd` field.
--
-- @field root_dir (string)              The absolute path to the directory of the installation.
--                                       This MUST be a directory inside nvim-lsp-installer's designated root install directory inside stdpath("data"). Most servers will make use of server.get_server_root_path() to produce its root_dir path.
--
-- @field post_setup (function)          An optional function to be executed after the setup function has been successfully called.
--                                       Use this to defer setting up server specific things until they're actually
--                                       needed, like custom commands.
--
-- @field pre_setup (function)           An optional function to be executed prior to calling lspconfig's setup().
--                                       Use this to defer setting up server specific things until they're actually needed.
--
function M.Server:new(opts)
    return setmetatable({
        name = opts.name,
        root_dir = opts.root_dir,
        homepage = opts.homepage,
        _root_dir = opts.root_dir, -- @deprecated Use the `root_dir` property instead.
        _installer = type(opts.installer) == "function" and opts.installer or installers.pipe(opts.installer),
        _default_options = opts.default_options,
        _post_setup = opts.post_setup,
        _pre_setup = opts.pre_setup,
    }, M.Server)
end

function M.Server:setup(opts)
    if self._pre_setup then
        log.fmt_debug("Calling pre_setup for server=%s", self.name)
        self._pre_setup()
    end
    -- We require the lspconfig server here in order to do it as late as possible.
    -- The reason for this is because once a lspconfig server has been imported, it's
    -- automatically registered with lspconfig and causes it to show up in :LspInfo and whatnot.
    local lsp_server = require("lspconfig")[self.name]
    if lsp_server then
        lsp_server.setup(vim.tbl_deep_extend("force", self._default_options, opts or {}))
        if self._post_setup then
            log.fmt_debug("Calling post_setup for server=%s", self.name)
            self._post_setup()
        end
    else
        error(("Unable to setup server %q: Could not find lspconfig server entry."):format(self.name))
    end
end

function M.Server:get_default_options()
    return vim.deepcopy(self._default_options)
end

function M.Server:is_installed()
    return servers.is_server_installed(self.name)
end

function M.Server:create_root_dir()
    fs.mkdirp(self.root_dir)
end

function M.Server:install()
    status_win().install_server(self)
end

function M.Server:install_attached(context, callback)
    local uninstall_ok, uninstall_err = pcall(self.uninstall, self)
    if not uninstall_ok then
        context.stdio_sink.stderr(tostring(uninstall_err) .. "\n")
        callback(false)
        return
    end

    self:create_root_dir()

    local install_ok, install_err = pcall(self._installer, self, function(success)
        if not success then
            vim.schedule(function()
                pcall(self.uninstall, self)
            end)
        else
            vim.schedule(function()
                dispatcher.dispatch_server_ready(self)
            end)
        end
        callback(success)
    end, context)
    if not install_ok then
        context.stdio_sink.stderr(tostring(install_err) .. "\n")
        callback(false)
    end
end

function M.Server:uninstall()
    log.debug("Uninstalling server", self.name)
    if fs.dir_exists(self.root_dir) then
        fs.rmrf(self.root_dir)
    end
end

return M
