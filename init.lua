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

local active_jobs = {}

local function handle_async_response(name, event, code, msg)
	local job = active_jobs[name]
	if not job then return end

	if event == 'STDOUT' or event == 'STDERR' then
		job.output = (job.output or "") .. msg
	elseif event == 'EXIT' then
		if code == 0 then
			vis:info("[" .. name .. "] " .. job.description ..  ": Completed successfully!")
		else
			vis:info("[" .. name .. "] " .. (job.output or "No output available") ..
					": Failed with code: " .. code)
		end
		active_jobs[name] = nil
	end
end

vis.events.subscribe(vis.events.PROCESS_RESPONSE, handle_async_response)

local function async_execute(name, cmd, description)
	local fd = vis:communicate(name, cmd)
	if not fd then
		vis:info("Failed to start command: " .. cmd)
		return
	end
	active_jobs[name] = { fd = fd, description = description, output = "" }
end

local function download_plugin(plugin_git_url)
	local plugin_name = extract_plugin_name(plugin_git_url)
	if not plugin_name then
		vis:info("Invalid Git URL: " .. plugin_git_url)
		return
	end

	local plugin_path = plugins_dir .. plugin_name

	if os.execute("test -d " .. plugin_path) then
		vis:info("Plugin found: Updating: " .. plugin_name)
		local name = "update_" .. plugin_name
		async_execute(name, "cd '" .. plugin_path .. "' && git pull -q",
						 "Updating " .. plugin_name)
	else
		vis:info("Installing new plugin: " .. plugin_git_url)
		local name = "install_" .. plugin_name
		async_execute(name, "git clone -q '" .. plugin_git_url .. "' '" ..
				 plugin_path .. "'", "Installing " .. plugin_name)
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
