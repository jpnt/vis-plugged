local M = {}
M.plugins = {}

local plugins_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
plugins_dir = plugins_dir .. "/vis/plugins/"

local function extract_plugin_name(url)
	return url:match("([^/]+)%.git$") or url:match("([^/]+)$")
end

local function safe_require(plugin_name)
	local path = plugins_dir .. plugin_name
	local init_file = path .. "/init.lua"

	if os.execute("test -d " .. path) and os.execute("test -f " .. init_file) then
		require("plugins/" .. plugin_name)
	else
		vis:info("Plugin not found or invalid: " .. plugin_name)
	end
end

-- BROKEN 07012025
local function download_plugin(plugin_git_url)
	local plugin_name = extract_plugin_name(plugin_git_url)
	if not plugin_name then
		vis:info("Invalid Git URL: " .. plugin_git_url)
		return
	end

	local plugin_path = plugins_dir .. plugin_name

	if os.execute("test -d " .. plugin_path) then
		vis:info("Plugin already installed: Updating: " .. plugin_name)
		local result = os.execute("cd '" .. plugin_path .. "' && git pull -q")
		if result ~= 0 then
			vis:info("Failed to update plugin: " .. plugin_name)
		end
	else
		vis:info("Installing plugin: " .. plugin_git_url)
		local result = os.execute("git clone -q '" .. plugin_git_url .. "' '" .. plugin_path .. "'")
		if result ~= 0 then
			vis:info("Failed to clone plugin: " .. plugin_name)
		end
	end
end

function M.add_plugin(plugin_git_url)
	table.insert(M.plugins, plugin_git_url)
end

function M.download_all_plugins()
	for _, plugin in ipairs(M.plugins) do
		download_plugin(plugin)
	end
end

function M.require_all_plugins()
	for _, plugin in ipairs(M.plugins) do
		local plugin_name = extract_plugin_name(plugin)
		safe_require(plugin_name)
	end
end

vis:command_register('plugged', function(argv)
	M.download_all_plugins()
	M.require_all_plugins()
end, 'Download/Update all plugins and require them')

return M
