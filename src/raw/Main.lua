local TrackerUtils = require(script.Parent.TrackerUtils)
local UIFactory = require(script.Parent.UIFactory)

local toolbar = plugin:CreateToolbar("Fox Jet Studios")
local button = toolbar:CreateButton(
	"Event Tracker",
	"View and manage all your experience's events",
	"rbxassetid://95011315458887"
) 
local ui = UIFactory.CreateMainWidget(plugin)
local widget = ui.Widget
local container = ui.Container

local SUPPORTED_CLASSES = {
	UnreliableRemoteEvent = true,
	RemoteEvent = true,
	BindableEvent = true,
}

local function RefreshList(filter)
	filter = filter and string.lower(filter) or nil
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, descendant in ipairs(game:GetDescendants()) do
		if SUPPORTED_CLASSES[descendant.ClassName] then
			local name = descendant.Name
			local path = descendant:GetFullName()

			local nameMatch = not filter or string.find(string.lower(name), filter)
			local pathMatch = not filter or string.find(string.lower(path), filter)

			if nameMatch or pathMatch then
				local data = TrackerUtils.GetListenersForInstance(descendant)
				if data then
					local entryData = {
						Instance = data.Instance,
						Name = data.Instance.Name,
						Type = data.Instance.ClassName,
						Path = data.Instance:GetFullName(),
						References = data.Stats,
						Locations = data.Locations
					}

					UIFactory.CreateEntry(entryData, container, {
						onDeleted = function()
							RefreshList(ui.SearchBox.Text)
						end,
						onSelect = function(evData)
							game:GetService("Selection"):Set({evData.Instance})
						end,
						onViewCode = function(evData)
							UIFactory.ShowCodeWindow(plugin, ui.Root, evData)
						end
					})
				end
			end
		end
	end
end

ui.RefreshButton.MouseButton1Click:Connect(function()
	RefreshList(ui.SearchBox.Text)
end)

ui.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	RefreshList(ui.SearchBox.Text)
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	if widget.Enabled then RefreshList() end
end)