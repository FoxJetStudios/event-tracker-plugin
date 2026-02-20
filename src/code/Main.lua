-- Main.lua

local TrackerUtils = require(script.Parent.TrackerUtils)
local UIFactory    = require(script.Parent.UIFactory)

local toolbar = plugin:CreateToolbar("Fox Jet Studios's Plugins")
local button  = toolbar:CreateButton(
	"Event Tracker",
	"View and manage all your experience's events",
	"rbxassetid://95011315458887"
)

local ui        = UIFactory.CreateMainWidget(plugin)
local widget    = ui.Widget
local scrollFrame = ui.ScrollFrame

local SUPPORTED_CLASSES = {
	UnreliableRemoteEvent = true,
	RemoteEvent           = true,
	BindableEvent         = true,
}

local currentData    = {}
local currentScroller = nil

local function BuildEntryData(instance)
	local data = TrackerUtils.GetListenersForInstance(instance)
	if not data then return nil end
	return {
		Instance   = data.Instance,
		Name       = data.Instance.Name,
		Type       = data.Instance.ClassName,
		Path       = data.Instance:GetFullName(),
		References = data.Stats,
		Locations  = data.Locations,
	}
end

local function MakeActions(getFilterFn)
	return {
		onDeleted = function(removedIdx)
			if removedIdx then
				table.remove(currentData, removedIdx)
			end
			if getFilterFn then
				getFilterFn()
			else
				if currentScroller then
					currentScroller.Refresh(currentData)
				end
			end
			ui.EmptyState.Visible = (#currentData == 0)
			
			local hasUnused = false
			for _, d in ipairs(currentData) do
				if d.References.Fired == 0 and d.References.Listened == 0 then
					hasUnused = true
					break
				end
			end
			ui.UpdateCleanupVisibility(hasUnused)
		end,

		onSelect = function(evData)
			game:GetService("Selection"):Set({ evData.Instance })
		end,

		onViewCode = function(evData)
			UIFactory.ShowCodeWindow(plugin, ui.Root, evData)
		end,
	}
end

local function RefreshList(filter)
	local lowerFilter = filter and filter ~= "" and string.lower(filter) or nil

	local newData = {}
	for _, descendant in ipairs(game:GetDescendants()) do
		if SUPPORTED_CLASSES[descendant.ClassName] then
			local name = descendant.Name
			local path = descendant:GetFullName()

			local passes = true
			if lowerFilter then
				local nameMatch = string.find(string.lower(name), lowerFilter, 1, true)
				local pathMatch = string.find(string.lower(path), lowerFilter, 1, true)
				passes = nameMatch or pathMatch
			end

			if passes then
				local entry = BuildEntryData(descendant)
				if entry then
					table.insert(newData, entry)
				end
			end
		end
	end

	currentData = newData

	local hasUnused = false
	for _, d in ipairs(currentData) do
		if d.References.Fired == 0 and d.References.Listened == 0 then
			hasUnused = true
			break
		end
	end
	ui.UpdateCleanupVisibility(hasUnused)
	ui.EmptyState.Visible = (#currentData == 0)

	local actions = MakeActions(function()
		RefreshList(ui.SearchBox.Text)
	end)

	if currentScroller then
		currentScroller.Refresh(currentData)
	else
		currentScroller = UIFactory.AttachVirtualScroll(scrollFrame, currentData, actions)
	end

	if currentScroller then
		currentScroller.Destroy()
	end
	currentScroller = UIFactory.AttachVirtualScroll(scrollFrame, currentData, actions)
end

ui.CleanupButton.MouseButton1Click:Connect(function()
	UIFactory.ShowCleanupWindow(ui.Root, currentData, function()
		RefreshList(ui.SearchBox.Text)
	end)
end)

ui.RefreshButton.MouseButton1Click:Connect(function()
	RefreshList(ui.SearchBox.Text)
end)

local searchDebounce = false
ui.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if searchDebounce then return end
	searchDebounce = true
	task.delay(0.15, function()
		searchDebounce = false
		RefreshList(ui.SearchBox.Text)
	end)
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	if widget.Enabled then
		RefreshList()
	end
end)