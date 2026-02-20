-- TrackerUtilis.lua

local TrackerUtils = {}

local PATTERNS = {
	RemoteEvent = {fire = {"FireServer", "FireClient", "FireAllClients"}, listen = {"OnServerEvent", "OnClientEvent"}},
	UnreliableRemoteEvent = {fire = {"FireServer", "FireClient", "FireAllClients"}, listen = {"OnServerEvent", "OnClientEvent"}},
	BindableEvent = {fire = {"Fire"}, listen = {"Event"}}
}

function TrackerUtils.GetListenersForInstance(targetInstance)
	if not targetInstance then return nil end

	local config = PATTERNS[targetInstance.ClassName]
	local name = targetInstance.Name
	local refs = {Fired = 0, Listened = 0}
	local locations = {}

	local strictNamePattern = "%f[%w]" .. name .. "%f[^%w]"
	local assignmentPattern = "([%w_]+)%s*=%s*.-" .. strictNamePattern

	for _, desc in ipairs(game:GetDescendants()) do
		if desc:IsA("LuaSourceContainer") then
			local s, source = pcall(function() return desc.Source end)

			if s and source and source:find(strictNamePattern) then
				local varName = nil
				local lineNum = 0

				for line in source:gmatch("([^\n]*)\n?") do
					lineNum = lineNum + 1
					local foundInLine = false
					local type = nil

					local capturedVar = line:match(assignmentPattern)
					if capturedVar and capturedVar ~= "local" then 
						varName = capturedVar 
					end

					local searchTarget = varName or name
					local currentSearchPattern = "%f[%w]" .. searchTarget .. "%f[^%w]"

					if string.find(line, currentSearchPattern) then
						for _, p in ipairs(config.fire) do
							if line:find("[:%.]" .. p) then
								refs.Fired += 1
								isListener = false
								foundInLine = true
								break
							end
						end

						if not foundInLine then
							for _, p in ipairs(config.listen) do
								if line:find("[:%.]" .. p) then 
									refs.Listened += 1
									isListener = true
									foundInLine = true
									break
								end
							end
						end
					end

					if foundInLine then
						table.insert(locations, {
							Script = desc,
							Path = desc:GetFullName(),
							Line = lineNum,
							Type = isListener and "Listener" or "Fired",
							SourcePreview = line:match("^%s*(.-)%s*$")
						})
					end
				end
			end
		end
	end

	return { Instance = targetInstance, Stats = refs, Locations = locations }
end

return TrackerUtils