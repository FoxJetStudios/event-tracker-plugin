local UIFactory = {}
local TweenService = game:GetService("TweenService")

local function ApplyHoverEffect(element)
	local originalSize = element.Size
	local hoverSize = UDim2.new(originalSize.X.Scale * 1.05, originalSize.X.Offset, originalSize.Y.Scale * 1.05, originalSize.Y.Offset)

	element.MouseEnter:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.2), {Size = hoverSize}):Play()
	end)

	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.2), {Size = originalSize}):Play()
	end)
end

local function GetLocationString(instance)
	if not instance then return "Unknown" end

	local parents = {}
	local current = instance.Parent

	while current and current ~= game do
		table.insert(parents, 1, current.Name)
		current = current.Parent
	end

	local serviceName = parents[1] or "Root"
	local secondFolder = parents[2]

	if secondFolder then
		return serviceName .. " / " .. secondFolder
	else
		return serviceName
	end
end

local function CreateModal(root, targetSize)
	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.ZIndex = 100
	container.Parent = root

	local overlay = Instance.new("TextButton")
	overlay.Size = UDim2.fromScale(2, 2)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Parent = container

	local modal = Instance.new("CanvasGroup")
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.Position = UDim2.fromScale(0.5, 0.5)
	modal.Size = targetSize + UDim2.new(0.05, 0, 0.05, 0)
	modal.GroupTransparency = 1
	modal.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
	modal.ClipsDescendants = true
	modal.Parent = container
	Instance.new("UICorner", modal)

	TweenService:Create(overlay, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(modal, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = targetSize, 
		GroupTransparency = 0
	}):Play()

	local function close()
		local closeTween = TweenService:Create(modal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1, 
			Size = targetSize - UDim2.new(0.05, 0, 0.05, 0)
		})
		TweenService:Create(overlay, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()

		closeTween:Play()
		closeTween.Completed:Connect(function()
			container:Destroy()
		end)
	end

	overlay.MouseButton1Click:Connect(close)

	return container, modal, close
end

function UIFactory.CreateEmptyState(parent)
	local emptyFrame = Instance.new("Frame")
	emptyFrame.Name = "EmptyState"
	emptyFrame.Size = UDim2.new(1, -40, 0, 200)
	emptyFrame.Position = UDim2.fromScale(0.5, 0.4)
	emptyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	emptyFrame.BackgroundTransparency = 1
	emptyFrame.Parent = parent

	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, 0, 0, 60)
	message.Position = UDim2.fromScale(0.5, 0.5)
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.BackgroundTransparency = 1
	message.Text = "No events found on your experience, check back later or create one!"
	message.Font = Enum.Font.BuilderSansMedium
	message.TextSize = 16
	message.TextColor3 = Color3.fromRGB(120, 120, 125)
	message.TextWrapped = true
	message.Parent = emptyFrame

	return emptyFrame
end

function UIFactory.CreateMainWidget(plugin)
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		500, 600,
		450, 400
	)

	local widget = plugin:CreateDockWidgetPluginGui("EventTracker", widgetInfo)
	widget.Title = "Event Tracker"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
	root.Parent = widget

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 70)
	header.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
	header.BorderSizePixel = 0
	header.Parent = root

	local refresh = Instance.new("TextButton")
	refresh.Size = UDim2.new(0, 80, 0, 40)
	refresh.Position = UDim2.new(1, -10, 0.5, 0)
	refresh.AnchorPoint = Vector2.new(1, 0.5)
	refresh.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	refresh.Text = "Refresh"
	refresh.TextColor3 = Color3.new(1, 1, 1)
	refresh.TextSize = 14
	refresh.Font = Enum.Font.BuilderSansBold
	refresh.Parent = header
	Instance.new("UICorner", refresh)
	ApplyHoverEffect(refresh)

	local cleanupBtn = Instance.new("TextButton")
	cleanupBtn.Size = UDim2.new(0, 90, 0, 40)
	cleanupBtn.Position = UDim2.new(1, -100, 0.5, 0)
	cleanupBtn.AnchorPoint = Vector2.new(1, 0.5)
	cleanupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	cleanupBtn.Text = "Clean Up"
	cleanupBtn.TextColor3 = Color3.new(1, 1, 1)
	cleanupBtn.TextSize = 14
	cleanupBtn.Font = Enum.Font.BuilderSansBold
	cleanupBtn.Visible = false 
	cleanupBtn.Parent = header
	Instance.new("UICorner", cleanupBtn)
	ApplyHoverEffect(cleanupBtn)

	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1, -110, 0, 40)
	searchBox.Position = UDim2.new(0, 10, 0.5, 0)
	searchBox.AnchorPoint = Vector2.new(0, 0.5)
	searchBox.PlaceholderText = "Search Events..."
	searchBox.Text = ""
	searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
	searchBox.TextColor3 = Color3.new(1, 1, 1)
	searchBox.TextSize = 14
	searchBox.TextScaled = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.TextEditable = true
	searchBox.Font = Enum.Font.BuilderSansBold
	searchBox.Parent = header

	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 10)
	searchPadding.Parent = searchBox
	Instance.new("UICorner", searchBox)

	local container = Instance.new("ScrollingFrame")
	container.Size = UDim2.new(1, -20, 1, -90)
	container.Position = UDim2.new(0.5, 0, 0.5, 35)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 6
	container.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.Parent = container
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	local emptyState = UIFactory.CreateEmptyState(root)
	emptyState.Visible = false

	local function UpdateCleanupVisibility(hasUnusedEvents)
		if hasUnusedEvents then
			cleanupBtn.Visible = true
			searchBox.Size = UDim2.new(1, -210, 0, 40)
		else
			cleanupBtn.Visible = false
			searchBox.Size = UDim2.new(1, -110, 0, 40)
		end
	end

	return {
		Widget = widget,
		Root = root,
		Container = container,
		RefreshButton = refresh,
		CleanupButton = cleanupBtn,
		SearchBox = searchBox,
		UpdateCleanupVisibility = UpdateCleanupVisibility,
		EmptyState = emptyState
	}
end

function UIFactory.CreateEntry(data, parent, actions)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 110)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
	frame.Parent = parent
	Instance.new("UICorner", frame)
	
	local ancestryConn
	if data.Instance then
		ancestryConn = data.Instance.AncestryChanged:Connect(function(_, newParent)
			if not newParent then
				frame:Destroy()
				if actions.onDeleted then actions.onDeleted() end
				if ancestryConn then ancestryConn:Disconnect() end
			end
		end)
	end

	frame.Destroying:Connect(function()
		if ancestryConn then ancestryConn:Disconnect() end
	end)

	local title = Instance.new("TextLabel")
	title.Text = data.Name
	title.Size = UDim2.new(0.6, 0, 0, 30)
	title.Position = UDim2.new(0, 15, 0, 10)
	title.Font = Enum.Font.BuilderSansBold
	title.TextSize = 22
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = frame

	local location = Instance.new("TextLabel")
	location.Text = GetLocationString(data.Instance)
	location.Size = UDim2.new(0.6, 0, 0, 20)
	location.Position = UDim2.new(0, 15, 0, 45)
	location.Font = Enum.Font.BuilderSansBold
	location.TextSize = 14
	location.TextColor3 = Color3.fromRGB(180, 180, 185)
	location.TextXAlignment = Enum.TextXAlignment.Left
	location.BackgroundTransparency = 1
	location.Parent = frame

	local stats = Instance.new("TextLabel")
	stats.Text = "Fires: " .. data.References.Fired .. " | Listeners: " .. data.References.Listened
	stats.Size = UDim2.new(0.6, 0, 0, 20)
	stats.Position = UDim2.new(0, 15, 0, 75)
	stats.Font = Enum.Font.BuilderSansBold
	stats.TextSize = 14
	stats.TextColor3 = Color3.fromRGB(150, 255, 150)
	stats.TextXAlignment = Enum.TextXAlignment.Left
	stats.BackgroundTransparency = 1
	stats.Parent = frame

	local function createBtn(name, color, xOffset, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 73, 0, 33)
		b.Position = UDim2.new(1, xOffset, 0.5, 0)
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.BackgroundColor3 = color
		b.Text = name
		b.TextSize = 12
		b.Font = Enum.Font.BuilderSansBold
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Parent = frame
		Instance.new("UICorner", b)
		ApplyHoverEffect(b)
		b.MouseButton1Click:Connect(callback)
	end

	createBtn("Delete", Color3.fromRGB(200, 50, 50), -15, function()
		UIFactory.ShowConfirm(parent.Parent.Parent, "Are you sure you want to delete " .. data.Name .. "? This action is not reversible.", function()
			if data.Instance then data.Instance:Destroy() end
			if actions.onDeleted then actions.onDeleted() end
			frame:Destroy()
		end)
	end)
	createBtn("Code", Color3.fromRGB(50, 160, 50), -95, function() actions.onViewCode(data) end)
	createBtn("Select", Color3.fromRGB(70, 70, 75), -175, function() actions.onSelect(data) end)

	return frame
end

function UIFactory.ShowConfirm(root, text, onConfirm)
	local targetSize = UDim2.new(0, 320, 0, 180)
	local container, modal, closeFunc = CreateModal(root, targetSize)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0.6, 0)
	lbl.Position = UDim2.fromScale(0, 0.05)
	lbl.Text = text
	lbl.TextSize = 17
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.BuilderSansMedium
	lbl.BackgroundTransparency = 1
	lbl.TextWrapped = true 
	lbl.TextScaled = true 
	lbl.Parent = modal

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.PaddingTop = UDim.new(0, 10)
	padding.Parent = lbl

	local yes = Instance.new("TextButton")
	yes.Size = UDim2.new(0, 110, 0, 40)
	yes.Position = UDim2.fromScale(0.3, 0.75)
	yes.AnchorPoint = Vector2.new(0.5, 0.5)
	yes.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	yes.Text = "Confirm"
	yes.TextScaled = false
	yes.TextSize = 20
	yes.TextColor3 = Color3.new(1, 1, 1)
	yes.Font = Enum.Font.BuilderSansBold
	yes.Parent = modal
	Instance.new("UICorner", yes)

	local no = Instance.new("TextButton")
	no.Size = UDim2.new(0, 110, 0, 40)
	no.Position = UDim2.fromScale(0.7, 0.75)
	no.AnchorPoint = Vector2.new(0.5, 0.5)
	no.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
	no.Text = "Cancel"
	no.TextScaled = false
	no.TextSize = 20
	no.TextColor3 = Color3.new(1, 1, 1)
	no.Font = Enum.Font.BuilderSansBold
	no.Parent = modal
	Instance.new("UICorner", no)

	yes.MouseButton1Click:Connect(function()
		onConfirm()
		closeFunc()
	end)
	no.MouseButton1Click:Connect(closeFunc)

	ApplyHoverEffect(yes)
	ApplyHoverEffect(no)
end

local function refreshEmptyState()
	local entrycount = 0
	for _, child in ipairs(ui.Container:GetChildren()) do
		if child:IsA("Frame") then
			entrycount = entrycount + 1
		end
	end
	ui.State.EmptyState.Visible = (entrycount == 0)
end

function UIFactory.ShowCodeWindow(plugin, root, data)
	local targetSize = UDim2.fromScale(0.8, 0.7)
	local container, modal, closeFunc = CreateModal(root, targetSize)

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Text = "Code References: " .. data.Name
	header.Font = Enum.Font.BuilderSansBold
	header.TextSize = 18
	header.TextColor3 = Color3.new(1, 1, 1)
	header.BackgroundTransparency = 1
	header.Parent = modal

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -30, 1, -70)
	list.Position = UDim2.new(0.5, 0, 0, 60)
	list.AnchorPoint = Vector2.new(0.5, 0)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
	list.Parent = modal

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	for _, loc in ipairs(data.Locations) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -5, 0, 45)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 54)
		btn.Text = "  " .. tostring(loc.Path) .. " (Line " .. tostring(loc.Line) .. ")"
		btn.TextSize = 13
		btn.TextWrapped = true
		btn.AutomaticSize = Enum.AutomaticSize.Y
		btn.TextScaled = false
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Font = Enum.Font.BuilderSansBold
		btn.Parent = list
		
		if loc.Type == "Fired" then
			btn.TextColor3 = Color3.fromRGB(255, 100, 100)
		elseif loc.Type == "Listener" then
			btn.TextColor3 = Color3.fromRGB(100, 255, 100)
		end

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = btn

		ApplyHoverEffect(btn)

		btn.MouseButton1Click:Connect(function()
			if loc.Script then
				plugin:OpenScript(loc.Script, loc.Line) 
				closeFunc()
			end
		end)
	end
end

function UIFactory.ShowCleanupWindow(root, allEvents, onRefreshCallback)
	local targetSize = UDim2.fromScale(0.85, 0.8)
	local container, modal, closeFunc = CreateModal(root, targetSize)

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Text = "Unused Events (0 Fires & 0 Listeners)"
	header.Font = Enum.Font.BuilderSansBold
	header.TextSize = 18
	header.TextColor3 = Color3.fromRGB(255, 100, 100)
	header.BackgroundTransparency = 1
	header.Parent = modal

	local listContainer = Instance.new("ScrollingFrame")
	listContainer.Size = UDim2.new(1, -30, 1, -70)
	listContainer.Position = UDim2.new(0.5, 0, 0, 60)
	listContainer.AnchorPoint = Vector2.new(0.5, 0)
	listContainer.BackgroundTransparency = 1
	listContainer.ScrollBarThickness = 4
	listContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
	listContainer.Parent = modal

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = listContainer

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		listContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	local unusedCount = 0

	for _, data in pairs(allEvents) do
		if data.References.Fired == 0 and data.References.Listened == 0 then
			unusedCount = unusedCount + 1

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -5, 0, 50)
			row.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
			row.Parent = listContainer
			Instance.new("UICorner", row)

			local name = Instance.new("TextLabel")
			name.Text = data.Name
			name.Size = UDim2.new(1, -80, 1, 0)
			name.Position = UDim2.new(0, 12, 0, 0)
			name.Font = Enum.Font.BuilderSansBold
			name.TextSize = 14
			name.TextColor3 = Color3.new(1, 1, 1)
			name.TextXAlignment = Enum.TextXAlignment.Left
			name.BackgroundTransparency = 1
			name.TextTruncate = Enum.TextTruncate.AtEnd
			name.Parent = row

			local del = Instance.new("TextButton")
			del.Size = UDim2.new(0, 60, 0, 30)
			del.Position = UDim2.new(1, -10, 0.5, 0)
			del.AnchorPoint = Vector2.new(1, 0.5)
			del.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			del.Text = "Delete"
			del.TextColor3 = Color3.new(1, 1, 1)
			del.Font = Enum.Font.BuilderSansBold
			del.TextSize = 12
			del.Parent = row
			Instance.new("UICorner", del)

			ApplyHoverEffect(del)

			del.MouseButton1Click:Connect(function()
				if data.Instance then
					data.Instance:Destroy()
				end
				row:Destroy()
				if onRefreshCallback then onRefreshCallback() end
			end)
		end
	end

	if unusedCount == 0 then
		header.Text = "No Unused Events Found"
		header.TextColor3 = Color3.fromRGB(150, 255, 150)
	end
end

pcall(function()
	ui.Container.ChildAdded:Connect(refreshEmptyState)
end)
pcall(function()
	ui.Container.ChildRemoved:Connect(refreshEmptyState)
end)

return UIFactory