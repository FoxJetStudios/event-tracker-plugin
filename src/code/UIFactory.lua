-- UIFactory.lua

local UIFactory   = {}
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local C = {
	BG0       = Color3.fromRGB(14,  14,  16 ),
	BG1       = Color3.fromRGB(22,  22,  25 ),
	BG2       = Color3.fromRGB(30,  30,  34 ),
	BG3       = Color3.fromRGB(38,  38,  43 ),
	BG4       = Color3.fromRGB(48,  48,  54 ),
	BG5       = Color3.fromRGB(58,  58,  65 ),

	TEXT_PRI  = Color3.fromRGB(240, 240, 245),
	TEXT_SEC  = Color3.fromRGB(160, 160, 170),
	TEXT_DIM  = Color3.fromRGB(100, 100, 110),
	
	GREY      = Color3.fromRGB(33, 33, 33),
	BLUE      = Color3.fromRGB(0,   130, 255),
	BLUE_DIM  = Color3.fromRGB(0,   90,  180),
	GREEN     = Color3.fromRGB(60,  200, 100),
	GREEN_DIM = Color3.fromRGB(40,  140, 70 ),
	RED       = Color3.fromRGB(220, 60,  60 ),
	RED_DIM   = Color3.fromRGB(155, 40,  40 ),
	ORANGE    = Color3.fromRGB(255, 145, 0  ),
	MUTED     = Color3.fromRGB(65,  65,  72 ),
	MUTED_DIM = Color3.fromRGB(48,  48,  54 ),

	GLOW_BLUE  = Color3.fromRGB(0,   150, 255),
	GLOW_GREEN = Color3.fromRGB(80,  255, 130),
	GLOW_RED   = Color3.fromRGB(255, 80,  80 ),
}

local CORNER_SM  = UDim.new(0, 6)
local CORNER_MD  = UDim.new(0, 10)
local CORNER_LG  = UDim.new(0, 14)

local ANIM_FAST  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ANIM_MED   = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ANIM_SLOW  = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ITEM_HEIGHT  = 114
local ITEM_GAP     = 10
local ITEM_STRIDE  = ITEM_HEIGHT + ITEM_GAP
local SCROLL_OVERSCAN = 2

local function Corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or CORNER_MD
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thickness, trans, pos)
	local pos = pos or Enum.BorderStrokePosition.Outer
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1,1,1)
	s.Thickness = thickness or 1.5
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.BorderStrokePosition = pos
	s.Parent = parent
	return s
end

local function ApplyButtonBehavior(btn, glowColor)
	local baseSize   = btn.Size
	local pressSize  = UDim2.new(
		baseSize.X.Scale * 0.95, baseSize.X.Offset * 0.95,
		baseSize.Y.Scale * 0.95, baseSize.Y.Offset * 0.95
	)
	local stroke = Stroke(btn, glowColor or C.GLOW_BLUE, 1.5, 1)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,    ANIM_FAST, {Size = baseSize}):Play()
		TweenService:Create(stroke, ANIM_FAST, {Transparency = 0.2}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,    ANIM_FAST, {Size = baseSize}):Play()
		TweenService:Create(stroke, ANIM_FAST, {Transparency = 1}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, ANIM_FAST, {Size = pressSize}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, ANIM_FAST, {Size = baseSize}):Play()
	end)
end

local function FadeIn(frame, duration)
	frame.BackgroundTransparency = 1
	TweenService:Create(frame, TweenInfo.new(duration or 0.18), {BackgroundTransparency = 0}):Play()
end

local function GetLocationString(instance)
	if not instance then return "Unknown" end
	local parents, current = {}, instance.Parent
	while current and current ~= game do
		table.insert(parents, 1, current.Name)
		current = current.Parent
	end
	local svc = parents[1] or "Root"
	return parents[2] and (svc .. "  ›  " .. parents[2]) or svc
end

local function CreateModal(root, targetSize)
	local container = Instance.new("Frame")
	container.Size                = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.ZIndex              = 100
	container.Parent              = root

	local overlay = Instance.new("TextButton")
	overlay.Size                  = UDim2.fromScale(2, 2)
	overlay.BackgroundColor3      = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Text                  = ""
	overlay.AutoButtonColor       = false
	overlay.Parent                = container

	local modal = Instance.new("CanvasGroup")
	modal.AnchorPoint             = Vector2.new(0.5, 0.5)
	modal.Position                = UDim2.fromScale(0.5, 0.5)
	modal.Size                    = targetSize + UDim2.new(0.04, 0, 0.04, 0)
	modal.GroupTransparency       = 1
	modal.BackgroundColor3        = C.BG5
	modal.ClipsDescendants        = true
	modal.Parent                  = container
	Corner(modal, CORNER_LG)
	Stroke(modal, C.BG4, 1, 0)

	TweenService:Create(overlay, ANIM_MED, {BackgroundTransparency = 0.55}):Play()
	TweenService:Create(modal,   ANIM_MED, {Size = targetSize, GroupTransparency = 0}):Play()

	local function close()
		local ct = TweenService:Create(modal, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1,
			Size = targetSize - UDim2.new(0.04, 0, 0.04, 0),
		})
		TweenService:Create(overlay, ANIM_FAST, {BackgroundTransparency = 1}):Play()
		ct:Play()
		ct.Completed:Connect(function() container:Destroy() end)
	end

	overlay.MouseButton1Click:Connect(close)
	return container, modal, close
end

local function MakeButton(opts)
	local b = Instance.new("TextButton")
	b.Size             = opts.Size     or UDim2.new(0, 80, 0, 36)
	b.Position         = opts.Position or UDim2.new(0, 0, 0, 0)
	b.AnchorPoint      = opts.AnchorPoint or Vector2.new(0, 0)
	b.BackgroundColor3 = opts.BgColor  or C.BLUE
	b.Text             = opts.Text     or ""
	b.TextColor3       = C.TEXT_PRI
	b.TextSize         = opts.TextSize or 13
	b.Font             = opts.Font     or Enum.Font.BuilderSansBold
	b.AutoButtonColor  = false
	b.Parent           = opts.Parent
	Corner(b, opts.CornerRadius or CORNER_SM)
	ApplyButtonBehavior(b, opts.GlowColor or C.GLOW_BLUE)
	return b
end

function UIFactory.CreateEmptyState(parent)
	local frame = Instance.new("Frame")
	frame.Name                  = "EmptyState"
	frame.Size                  = UDim2.new(1, -40, 0, 160)
	frame.Position              = UDim2.fromScale(0.5, 0.45)
	frame.AnchorPoint           = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Parent                = parent

	local icon = Instance.new("Frame")
	icon.Size                   = UDim2.new(0, 48, 0, 4)
	icon.Position               = UDim2.fromScale(0.5, 0)
	icon.AnchorPoint            = Vector2.new(0.5, 0)
	icon.BackgroundColor3       = C.BG4
	icon.Parent                 = frame
	Corner(icon, UDim.new(1, 0))

	local msg = Instance.new("TextLabel")
	msg.Size                    = UDim2.new(1, 0, 0, 50)
	msg.Position                = UDim2.new(0.5, 0, 0, 22)
	msg.AnchorPoint             = Vector2.new(0.5, 0)
	msg.BackgroundTransparency  = 1
	msg.Text                    = "No events found on your experience.\nCheck back later or create one."
	msg.Font                    = Enum.Font.BuilderSansMedium
	msg.TextSize                = 15
	msg.TextColor3              = C.TEXT_DIM
	msg.TextWrapped             = true
	msg.LineHeight              = 1.4
	msg.Parent                  = frame

	return frame
end

function UIFactory.CreateMainWidget(plugin)
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, false, false, 500, 620, 450, 420
	)
	local widget = plugin:CreateDockWidgetPluginGuiAsync("EventTracker", widgetInfo)
	widget.Title = "Event Tracker"

	local root = Instance.new("Frame")
	root.Size             = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = C.BG1
	root.Parent           = widget

	local topLine = Instance.new("Frame")
	topLine.Size             = UDim2.new(1, 0, 0, 2)
	topLine.BackgroundColor3 = C.GREY
	topLine.BorderSizePixel  = 0
	topLine.Parent           = root

	local header = Instance.new("Frame")
	header.Size             = UDim2.new(1, 0, 0, 62)
	header.Position         = UDim2.new(0, 0, 0, 2)
	header.BackgroundColor3 = C.BG2
	header.BorderSizePixel  = 0
	header.Parent           = root

	local sep = Instance.new("Frame")
	sep.Size             = UDim2.new(1, 0, 0, 1)
	sep.Position         = UDim2.new(0, 0, 1, 0)
	sep.AnchorPoint      = Vector2.new(0, 1)
	sep.BackgroundColor3 = C.BG4
	sep.BorderSizePixel  = 0
	sep.Parent           = header

	local searchBox = Instance.new("TextBox")
	searchBox.Size              = UDim2.new(1, -110, 0, 36)
	searchBox.Position          = UDim2.new(0, 12, 0.5, 0)
	searchBox.AnchorPoint       = Vector2.new(0, 0.5)
	searchBox.PlaceholderText   = "Search events…"
	searchBox.PlaceholderColor3 = C.TEXT_DIM
	searchBox.Text              = ""
	searchBox.BackgroundColor3  = C.BG3
	searchBox.TextColor3        = C.TEXT_PRI
	searchBox.TextSize          = 13
	searchBox.TextXAlignment    = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus  = false
	searchBox.Font              = Enum.Font.BuilderSansMedium
	searchBox.Parent            = header
	Corner(searchBox, CORNER_SM)
	local searchStroke = Stroke(searchBox, C.GLOW_BLUE, 1.5, 1)

	searchBox.Focused:Connect(function()
		TweenService:Create(searchStroke, ANIM_FAST, {Transparency = 0.4}):Play()
	end)
	searchBox.FocusLost:Connect(function()
		TweenService:Create(searchStroke, ANIM_FAST, {Transparency = 1}):Play()
	end)

	do
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.Parent = searchBox
	end

	local refreshBtn = MakeButton({
		Text       = "Refresh",
		Size       = UDim2.new(0, 76, 0, 36),
		Position   = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BgColor    = C.BLUE,
		GlowColor  = C.GLOW_BLUE,
		TextSize   = 15,
		Parent     = header,
	})

	local cleanupBtn = MakeButton({
		Text       = "Clean Up",
		Size       = UDim2.new(0, 86, 0, 36),
		Position   = UDim2.new(1, -96, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BgColor    = C.ORANGE,
		GlowColor  = Color3.fromRGB(255, 200, 80),
		TextSize   = 15,
		Parent     = header,
	})
	cleanupBtn.Visible = false

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size                  = UDim2.new(1, -16, 1, -78)
	scrollFrame.Position              = UDim2.new(0, 8, 0, 70)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness    = 4
	scrollFrame.ScrollBarImageColor3  = C.BG4
	scrollFrame.ElasticBehavior       = Enum.ElasticBehavior.Never
	scrollFrame.ScrollingDirection    = Enum.ScrollingDirection.Y
	scrollFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent                = root

	local emptyState = UIFactory.CreateEmptyState(root)
	emptyState.Visible = false

	local function UpdateCleanupVisibility(hasUnused)
		if hasUnused then
			cleanupBtn.Visible = true
			refreshBtn.Position = UDim2.new(1, -10, 0.5, 0)
			searchBox.Size      = UDim2.new(1, -208, 0, 36)
		else
			cleanupBtn.Visible  = false
			refreshBtn.Position = UDim2.new(1, -10, 0.5, 0)
			searchBox.Size      = UDim2.new(1, -110, 0, 36)
		end
	end

	return {
		Widget                  = widget,
		Root                    = root,
		Container               = scrollFrame,
		ScrollFrame             = scrollFrame,
		RefreshButton           = refreshBtn,
		CleanupButton           = cleanupBtn,
		SearchBox               = searchBox,
		UpdateCleanupVisibility = UpdateCleanupVisibility,
		EmptyState              = emptyState,
	}
end

function UIFactory.AttachVirtualScroll(scrollFrame, dataList, actions)
	local rendered    = {}
	local connections = {}
	local totalItems  = #dataList

	local function RefreshCanvasSize()
		totalItems = #dataList
		local totalH = totalItems > 0 and (totalItems * ITEM_STRIDE - ITEM_GAP) or 0
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalH)
	end
	RefreshCanvasSize()

	local function VisibleRange()
		local vpH    = scrollFrame.AbsoluteSize.Y
		local scrollY = scrollFrame.CanvasPosition.Y
		local first  = math.floor(scrollY / ITEM_STRIDE) + 1
		local last   = math.ceil((scrollY + vpH) / ITEM_STRIDE)
		return
			math.max(1, first - SCROLL_OVERSCAN),
		math.min(totalItems, last + SCROLL_OVERSCAN)
	end
	
	local function BuildCard(idx)
		local data  = dataList[idx]
		if not data then return end

		local yPos  = (idx - 1) * ITEM_STRIDE

		local frame = Instance.new("Frame")
		frame.Size             = UDim2.new(1, -2, 0, ITEM_HEIGHT)
		frame.Position         = UDim2.new(0, 1, 0, yPos)
		frame.BackgroundColor3 = C.BG3
		frame.BackgroundTransparency = 1
		frame.Parent           = scrollFrame
		Corner(frame, CORNER_MD)

		local cardStroke = Stroke(frame, C.BG4, 1, 0, Enum.BorderStrokePosition.Inner)

		frame.MouseEnter:Connect(function()
			TweenService:Create(frame,      ANIM_FAST, {BackgroundColor3 = C.BG4}):Play()
			TweenService:Create(cardStroke, ANIM_FAST, {Transparency = 0.6}):Play()
		end)
		frame.MouseLeave:Connect(function()
			TweenService:Create(frame,      ANIM_FAST, {BackgroundColor3 = C.BG3}):Play()
			TweenService:Create(cardStroke, ANIM_FAST, {Transparency = 0}):Play()
		end)

		TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()

		local strip = Instance.new("Frame")
		strip.Size             = UDim2.new(0, 3, 1, -24)
		strip.Position         = UDim2.new(0, 0, 0.5, 0)
		strip.AnchorPoint      = Vector2.new(0, 0.5)
		strip.BackgroundColor3 = (data.References.Fired == 0 and data.References.Listened == 0)
			and C.RED or C.BLUE
		strip.BorderSizePixel  = 0
		strip.Parent           = frame
		Corner(strip, UDim.new(1, 0))

		local title = Instance.new("TextLabel")
		title.Text             = data.Name
		title.Size             = UDim2.new(0.65, 0, 0, 26)
		title.Position         = UDim2.new(0, 18, 0, 12)
		title.Font             = Enum.Font.BuilderSansBold
		title.TextSize         = 19
		title.TextColor3       = C.TEXT_PRI
		title.TextXAlignment   = Enum.TextXAlignment.Left
		title.BackgroundTransparency = 1
		title.TextTruncate     = Enum.TextTruncate.AtEnd
		title.Parent           = frame

		local location = Instance.new("TextLabel")
		location.Text          = GetLocationString(data.Instance)
		location.Size          = UDim2.new(0.80, 0, 0, 18)
		location.Position      = UDim2.new(0, 18, 0, 42)
		location.Font          = Enum.Font.BuilderSansMedium
		location.TextSize      = 15
		location.TextColor3    = C.TEXT_SEC
		location.TextXAlignment = Enum.TextXAlignment.Left
		location.BackgroundTransparency = 1
		location.TextTruncate  = Enum.TextTruncate.AtEnd
		location.Parent        = frame

		local statsBg = Instance.new("Frame")
		statsBg.Size             = UDim2.new(0, 190, 0, 22)
		statsBg.Position         = UDim2.new(0, 18, 0, 74)
		statsBg.BackgroundColor3 = C.BG0
		statsBg.Parent           = frame
		Corner(statsBg, UDim.new(1, 0))

		local statsLbl = Instance.new("TextLabel")
		statsLbl.Size            = UDim2.fromScale(1, 1)
		statsLbl.Text            = "  ⚡ " .. data.References.Fired .. "  fires     👂 " .. data.References.Listened .. "  listeners"
		statsLbl.Font            = Enum.Font.BuilderSansMedium
		statsLbl.TextSize        = 13
		statsLbl.TextColor3      = C.GREEN
		statsLbl.BackgroundTransparency = 1
		statsLbl.TextXAlignment  = Enum.TextXAlignment.Center
		statsLbl.Parent          = statsBg

		local function ActionBtn(text, color, glow, yOff, cb)
			return MakeButton({
				Text        = text,
				Size        = UDim2.new(0, 120, 0, 28),
				Position    = UDim2.new(1, -12, 0, yOff),
				AnchorPoint = Vector2.new(1, 0),
				BgColor     = color,
				GlowColor   = glow,
				TextSize    = 16,
				Parent      = frame,
				CornerRadius = CORNER_SM,
			})
		end

		local selectBtn = ActionBtn("Select", C.MUTED,    C.TEXT_SEC,   9,  nil)
		local codeBtn   = ActionBtn("Code",   C.GREEN_DIM, C.GLOW_GREEN, 42,  nil)
		local deleteBtn = ActionBtn("Delete", C.RED_DIM,   C.GLOW_RED,   76,  nil)

		selectBtn.MouseButton1Click:Connect(function() actions.onSelect(data) end)
		codeBtn.MouseButton1Click:Connect(function()   actions.onViewCode(data) end)
		deleteBtn.MouseButton1Click:Connect(function()
			local root = scrollFrame.Parent
			UIFactory.ShowConfirm(root, "Delete " .. data.Name .. "? This cannot be undone.", function()
				if data.Instance then data.Instance:Destroy() end
				if actions.onDeleted then actions.onDeleted(idx) end
			end)
		end)

		local conn
		if data.Instance then
			conn = data.Instance.AncestryChanged:Connect(function(_, newParent)
				if not newParent then
					frame:Destroy()
					rendered[idx] = nil
					if conn then conn:Disconnect() end
					if actions.onDeleted then actions.onDeleted(idx) end
				end
			end)
			frame.Destroying:Connect(function()
				if conn then conn:Disconnect() end
			end)
		end

		rendered[idx] = frame
	end

	local function DestroyCard(idx)
		local f = rendered[idx]
		if f then
			f:Destroy()
			rendered[idx] = nil
		end
	end

	local lastStart, lastEnd = 0, 0

	local function Reconcile()
		local s, e = VisibleRange()
		if s == lastStart and e == lastEnd then return end

		for idx, _ in pairs(rendered) do
			if idx < s or idx > e then
				DestroyCard(idx)
			end
		end

		for idx = s, e do
			if not rendered[idx] and dataList[idx] then
				BuildCard(idx)
			end
		end

		lastStart, lastEnd = s, e
	end

	local scrollConn = scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(Reconcile)
	local sizeConn   = scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Reconcile)

	table.insert(connections, scrollConn)
	table.insert(connections, sizeConn)

	RefreshCanvasSize()
	Reconcile()

	return {
		Refresh = function(newData)
			for idx in pairs(rendered) do DestroyCard(idx) end
			dataList = newData
			lastStart, lastEnd = 0, 0
			RefreshCanvasSize()
			scrollFrame.CanvasPosition = Vector2.new(0, 0)
			Reconcile()
		end,

		Destroy = function()
			for _, c in ipairs(connections) do c:Disconnect() end
			for idx in pairs(rendered) do DestroyCard(idx) end
		end,
	}
end

function UIFactory.CreateEntry(data, parent, actions)
	local frame = Instance.new("Frame")
	frame.Size             = UDim2.new(1, 0, 0, ITEM_HEIGHT)
	frame.BackgroundColor3 = C.BG3
	frame.Parent           = parent
	Corner(frame, CORNER_MD)
	FadeIn(frame, 0.18)

	local cardStroke = Stroke(frame, C.BG4, 1, 0, Enum.BorderStrokePosition.Outer)
	frame.MouseEnter:Connect(function()
		TweenService:Create(frame,      ANIM_FAST, {BackgroundColor3 = C.BG4}):Play()
		TweenService:Create(cardStroke, ANIM_FAST, {Transparency = 0.6}):Play()
	end)
	frame.MouseLeave:Connect(function()
		TweenService:Create(frame,      ANIM_FAST, {BackgroundColor3 = C.BG3}):Play()
		TweenService:Create(cardStroke, ANIM_FAST, {Transparency = 0}):Play()
	end)

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

	local strip = Instance.new("Frame")
	strip.Size             = UDim2.new(0, 3, 1, -24)
	strip.Position         = UDim2.new(0, 0, 0.5, 0)
	strip.AnchorPoint      = Vector2.new(0, 0.5)
	strip.BackgroundColor3 = C.BLUE
	strip.BorderSizePixel  = 0
	strip.Parent           = frame
	Corner(strip, UDim.new(1, 0))

	local title = Instance.new("TextLabel")
	title.Text             = data.Name
	title.Size             = UDim2.new(0.55, 0, 0, 26)
	title.Position         = UDim2.new(0, 18, 0, 12)
	title.Font             = Enum.Font.BuilderSansBold
	title.TextSize         = 17
	title.TextColor3       = C.TEXT_PRI
	title.TextXAlignment   = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.TextTruncate     = Enum.TextTruncate.AtEnd
	title.Parent           = frame

	local location = Instance.new("TextLabel")
	location.Text          = GetLocationString(data.Instance)
	location.Size          = UDim2.new(0.55, 0, 0, 18)
	location.Position      = UDim2.new(0, 18, 0, 42)
	location.Font          = Enum.Font.BuilderSansMedium
	location.TextSize      = 12
	location.TextColor3    = C.TEXT_SEC
	location.TextXAlignment = Enum.TextXAlignment.Left
	location.BackgroundTransparency = 1
	location.Parent        = frame

	local statsBg = Instance.new("Frame")
	statsBg.Size             = UDim2.new(0, 190, 0, 22)
	statsBg.Position         = UDim2.new(0, 18, 0, 74)
	statsBg.BackgroundColor3 = C.BG0
	statsBg.Parent           = frame
	Corner(statsBg, UDim.new(1, 0))

	local statsLbl = Instance.new("TextLabel")
	statsLbl.Size            = UDim2.fromScale(1, 1)
	statsLbl.Text            = "  ⚡ " .. data.References.Fired .. " fires   👂 " .. data.References.Listened .. " listeners"
	statsLbl.Font            = Enum.Font.BuilderSansMedium
	statsLbl.TextSize        = 11
	statsLbl.TextColor3      = C.GREEN
	statsLbl.BackgroundTransparency = 1
	statsLbl.TextXAlignment  = Enum.TextXAlignment.Left
	statsLbl.Parent          = statsBg

	local function ActionBtn(text, color, glow, yOff)
		return MakeButton({
			Text        = text,
			Size        = UDim2.new(0, 68, 0, 28),
			Position    = UDim2.new(1, -12, 0, yOff),
			AnchorPoint = Vector2.new(1, 0),
			BgColor     = color,
			GlowColor   = glow,
			TextSize    = 11,
			Parent      = frame,
			CornerRadius = CORNER_SM,
		})
	end

	local selectBtn = ActionBtn("Select", C.MUTED,    C.TEXT_SEC,   14)
	local codeBtn   = ActionBtn("Code",   C.GREEN_DIM, C.GLOW_GREEN, 48)
	local deleteBtn = ActionBtn("Delete", C.RED_DIM,   C.GLOW_RED,   82)

	selectBtn.MouseButton1Click:Connect(function() actions.onSelect(data) end)
	codeBtn.MouseButton1Click:Connect(function()   actions.onViewCode(data) end)
	deleteBtn.MouseButton1Click:Connect(function()
		local root = parent.Parent.Parent
		UIFactory.ShowConfirm(root, "Delete " .. data.Name .. "? This cannot be undone.", function()
			if data.Instance then data.Instance:Destroy() end
			if actions.onDeleted then actions.onDeleted() end
			frame:Destroy()
		end)
	end)

	return frame
end

function UIFactory.ShowConfirm(root, text, onConfirm)
	local targetSize = UDim2.new(0, 330, 0, 190)
	local _, modal, closeFunc = CreateModal(root, targetSize)

	local lbl = Instance.new("TextLabel")
	lbl.Size                   = UDim2.new(1, 0, 0, 100)
	lbl.Position               = UDim2.new(0, 0, 0, 12)
	lbl.Text                   = text
	lbl.TextSize               = 15
	lbl.TextColor3             = C.TEXT_PRI
	lbl.Font                   = Enum.Font.BuilderSansMedium
	lbl.BackgroundTransparency = 1
	lbl.TextWrapped            = true
	lbl.LineHeight             = 1.4
	lbl.Parent                 = modal

	do
		local p = Instance.new("UIPadding")
		p.PaddingLeft = UDim.new(0, 18) ; p.PaddingRight = UDim.new(0, 18)
		p.Parent = lbl
	end

	local confirmBtn = MakeButton({
		Text        = "Delete",
		Size        = UDim2.new(0, 120, 0, 38),
		Position    = UDim2.fromScale(0.28, 0.82),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BgColor     = C.RED,
		GlowColor   = C.GLOW_RED,
		TextSize    = 14,
		Parent      = modal,
		CornerRadius = CORNER_SM,
	})

	local cancelBtn = MakeButton({
		Text        = "Cancel",
		Size        = UDim2.new(0, 120, 0, 38),
		Position    = UDim2.fromScale(0.72, 0.82),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BgColor     = C.MUTED,
		GlowColor   = C.TEXT_SEC,
		TextSize    = 14,
		Parent      = modal,
		CornerRadius = CORNER_SM,
	})

	confirmBtn.MouseButton1Click:Connect(function() onConfirm() ; closeFunc() end)
	cancelBtn.MouseButton1Click:Connect(closeFunc)
end

function UIFactory.ShowCodeWindow(plugin, root, data)
	local targetSize = UDim2.fromScale(0.82, 0.74)
	local _, modal, closeFunc = CreateModal(root, targetSize)

	local header = Instance.new("TextLabel")
	header.Size                = UDim2.new(1, 0, 0, 48)
	header.Position            = UDim2.new(0, 0, 0, 3)
	header.Text                = "Code References  ·  " .. data.Name
	header.Font                = Enum.Font.BuilderSansBold
	header.TextSize            = 17
	header.TextColor3          = C.TEXT_PRI
	header.BackgroundTransparency = 1
	header.Parent              = modal

	local countLbl = Instance.new("TextLabel")
	countLbl.Size              = UDim2.new(1, -24, 0, 18)
	countLbl.Position          = UDim2.new(0, 12, 0, 34)
	countLbl.Text              = tostring(#data.Locations) .. " reference(s) found"
	countLbl.Font              = Enum.Font.BuilderSansMedium
	countLbl.TextSize          = 12
	countLbl.TextColor3        = C.TEXT_DIM
	countLbl.TextXAlignment    = Enum.TextXAlignment.Left
	countLbl.BackgroundTransparency = 1
	countLbl.Parent            = modal

	local sep = Instance.new("Frame")
	sep.Size             = UDim2.new(1, -24, 0, 1)
	sep.Position         = UDim2.new(0, 12, 0, 54)
	sep.BackgroundColor3 = C.BG4
	sep.Parent           = modal

	local list = Instance.new("ScrollingFrame")
	list.Size                  = UDim2.new(1, -24, 1, -72)
	list.Position              = UDim2.new(0, 12, 0, 62)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness    = 4
	list.ScrollBarImageColor3  = C.BG4
	list.Parent                = modal

	local layout = Instance.new("UIListLayout")
	layout.Padding    = UDim.new(0, 6)
	layout.SortOrder  = Enum.SortOrder.LayoutOrder
	layout.Parent     = list
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	for _, loc in ipairs(data.Locations) do
		local isFireType = loc.Type == "Fired"
		local accent = isFireType and C.RED or C.GREEN

		local btn = Instance.new("TextButton")
		btn.Size              = UDim2.new(1, -4, 0, 42)
		btn.BackgroundColor3  = C.BG4
		btn.AutoButtonColor   = false
		btn.Text              = ""
		btn.AutomaticSize     = Enum.AutomaticSize.Y
		btn.Parent            = list
		Corner(btn, CORNER_SM)
		local btnStroke = Stroke(btn, accent, 1.48, 1, Enum.BorderStrokePosition.Inner)

		local pill = Instance.new("Frame")
		pill.Size             = UDim2.new(0, 3, 0.6, 0)
		pill.Position         = UDim2.new(0, 0, 0.2, 0)
		pill.BackgroundColor3 = accent
		pill.BorderSizePixel  = 0
		pill.Parent           = btn
		Corner(pill, UDim.new(1, 0))

		local typeTag = Instance.new("TextLabel")
		typeTag.Size                = UDim2.new(0, 60, 0, 16)
		typeTag.Position            = UDim2.new(0, 12, 0, 6)
		typeTag.Text                = loc.Type or "?"
		typeTag.Font                = Enum.Font.BuilderSansBold
		typeTag.TextSize            = 10
		typeTag.TextColor3          = accent
		typeTag.TextXAlignment      = Enum.TextXAlignment.Left
		typeTag.BackgroundTransparency = 1
		typeTag.Parent              = btn

		local pathLbl = Instance.new("TextLabel")
		pathLbl.Size                = UDim2.new(1, -20, 0, 16)
		pathLbl.Position            = UDim2.new(0, 12, 0, 22)
		pathLbl.Text                = tostring(loc.Path) .. "  (line " .. tostring(loc.Line) .. ")"
		pathLbl.Font                = Enum.Font.BuilderSansMedium
		pathLbl.TextSize            = 12
		pathLbl.TextColor3          = C.TEXT_SEC
		pathLbl.TextXAlignment      = Enum.TextXAlignment.Left
		pathLbl.TextTruncate        = Enum.TextTruncate.AtEnd
		pathLbl.BackgroundTransparency = 1
		pathLbl.Parent              = btn

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn,      ANIM_FAST, {BackgroundColor3 = C.BG5}):Play()
			TweenService:Create(btnStroke, ANIM_FAST, {Transparency = 0.2}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn,      ANIM_FAST, {BackgroundColor3 = C.BG4}):Play()
			TweenService:Create(btnStroke, ANIM_FAST, {Transparency = 1}):Play()
		end)
		btn.MouseButton1Down:Connect(function()
			TweenService:Create(btn, ANIM_FAST, {BackgroundColor3 = C.BG3}):Play()
		end)
		btn.MouseButton1Click:Connect(function()
			if loc.Script then
				plugin:OpenScript(loc.Script, loc.Line)
				closeFunc()
			end
		end)
	end
end

function UIFactory.ShowCleanupWindow(root, allEvents, onRefreshCallback)
	local targetSize = UDim2.fromScale(0.87, 0.82)
	local _, modal, closeFunc = CreateModal(root, targetSize)

	local header = Instance.new("TextLabel")
	header.Size                = UDim2.new(1, 0, 0, 52)
	header.Position            = UDim2.new(0, 0, 0, 3)
	header.Text                = "Unused Events"
	header.Font                = Enum.Font.BuilderSansBold
	header.TextSize            = 18
	header.TextColor3          = C.ORANGE
	header.BackgroundTransparency = 1
	header.Parent              = modal

	local subLbl = Instance.new("TextLabel")
	subLbl.Size                = UDim2.new(1, -24, 0, 16)
	subLbl.Position            = UDim2.new(0, 12, 0, 36)
	subLbl.Text                = "Events with 0 fires and 0 listeners"
	subLbl.Font                = Enum.Font.BuilderSansMedium
	subLbl.TextSize            = 12
	subLbl.TextColor3          = C.TEXT_DIM
	subLbl.TextXAlignment      = Enum.TextXAlignment.Left
	subLbl.BackgroundTransparency = 1
	subLbl.Parent              = modal

	local sep = Instance.new("Frame")
	sep.Size             = UDim2.new(1, -24, 0, 1)
	sep.Position         = UDim2.new(0, 12, 0, 56)
	sep.BackgroundColor3 = C.BG4
	sep.Parent           = modal

	local listContainer = Instance.new("ScrollingFrame")
	listContainer.Size                  = UDim2.new(1, -24, 1, -72)
	listContainer.Position              = UDim2.new(0, 12, 0, 64)
	listContainer.BackgroundTransparency = 1
	listContainer.ScrollBarThickness    = 4
	listContainer.ScrollBarImageColor3  = C.BG4
	listContainer.Parent                = modal

	local layout = Instance.new("UIListLayout")
	layout.Padding    = UDim.new(0, 6)
	layout.SortOrder  = Enum.SortOrder.LayoutOrder
	layout.Parent     = listContainer
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		listContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)

	local unusedCount = 0

	for _, data in pairs(allEvents) do
		if data.References.Fired == 0 and data.References.Listened == 0 then
			unusedCount = unusedCount + 1

			local row = Instance.new("Frame")
			row.Size             = UDim2.new(1, -4, 0, 48)
			row.BackgroundColor3 = C.BG4
			row.Parent           = listContainer
			Corner(row, CORNER_SM)
			FadeIn(row, 0.12)

			local leftAccent = Instance.new("Frame")
			leftAccent.Size             = UDim2.new(0, 3, 0.55, 0)
			leftAccent.Position         = UDim2.new(0, 0, 0.5, 0)
			leftAccent.AnchorPoint      = Vector2.new(0, 0.5)
			leftAccent.BackgroundColor3 = C.RED
			leftAccent.BorderSizePixel  = 0
			leftAccent.Parent           = row
			Corner(leftAccent, UDim.new(1, 0))

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Text                = data.Name
			nameLbl.Size               = UDim2.new(1, -90, 1, 0)
			nameLbl.Position           = UDim2.new(0, 14, 0, 0)
			nameLbl.Font               = Enum.Font.BuilderSansBold
			nameLbl.TextSize           = 14
			nameLbl.TextColor3         = C.TEXT_PRI
			nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
			nameLbl.BackgroundTransparency = 1
			nameLbl.TextTruncate       = Enum.TextTruncate.AtEnd
			nameLbl.Parent             = row

			local del = MakeButton({
				Text        = "Delete",
				Size        = UDim2.new(0, 62, 0, 30),
				Position    = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BgColor     = C.RED_DIM,
				GlowColor   = C.GLOW_RED,
				TextSize    = 12,
				Parent      = row,
				CornerRadius = CORNER_SM,
			})

			del.MouseButton1Click:Connect(function()
				if data.Instance then data.Instance:Destroy() end
				local closeTween = TweenService:Create(row, ANIM_FAST, {BackgroundTransparency = 1})
				closeTween:Play()
				closeTween.Completed:Connect(function() row:Destroy() end)
				if onRefreshCallback then onRefreshCallback() end
			end)
		end
	end

	if unusedCount == 0 then
		header.Text       = "All Clear!"
		header.TextColor3 = C.GREEN
		subLbl.Text       = "No unused events found, great job keeping things tidy."
	end
end

return UIFactory