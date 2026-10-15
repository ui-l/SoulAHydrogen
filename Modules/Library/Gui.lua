local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Connections = {}
local ConfigItems = {}

local GuiName = "HydrogenGui"
local FolderName = "Soul A Hydrogen Hub"
local IconsUrl = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua"

local function GuiParent()
	if RunService:IsStudio() then
		return Player:WaitForChild("PlayerGui")
	end
	if type(gethui) == "function" then
		local ok, parent = pcall(gethui)
		if ok and parent then
			return parent
		end
	end
	local core = game:GetService("CoreGui")
	return type(cloneref) == "function" and cloneref(core) or core
end

pcall(function()
	local parent = GuiParent()
	for _, name in ipairs({ GuiName, GuiName .. "_Toggle", GuiName .. "_Notifications" }) do
		local old = parent:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
end)

pcall(function()
	if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(FolderName) then
		makefolder(FolderName)
	end
end)

local IconSet = {
	["lucide-x"] = "rbxassetid://10747384394",
	["lucide-x-circle"] = "rbxassetid://10747383819",
	["lucide-minus"] = "rbxassetid://10734896206",
	["lucide-search"] = "rbxassetid://10734943674",
	["lucide-chevron-down"] = "rbxassetid://10709790948",
	["lucide-check"] = "rbxassetid://10709790644",
	["lucide-check-circle"] = "rbxassetid://10709790387",
	["lucide-info"] = "rbxassetid://10723415903",
	["lucide-alert-triangle"] = "rbxassetid://10709753149",
	["lucide-users"] = "rbxassetid://10747373426",
	["lucide-folder"] = "rbxassetid://10723387563",
	["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-settings"] = "rbxassetid://10734950309",
}

local FullIcons = nil
local function LoadFullIcons()
	if FullIcons ~= nil then
		return FullIcons
	end
	FullIcons = false
	local ok, data = pcall(function()
		return loadstring(game:HttpGet(IconsUrl))()
	end)
	if ok and type(data) == "table" and type(data.assets) == "table" then
		FullIcons = data.assets
	end
	return FullIcons
end

local function GetIcon(Name)
	if type(Name) ~= "string" or Name == "" then
		return nil
	end
	local key = string.lower(Name)
	if not string.find(key, "^lucide%-") then
		key = "lucide-" .. key
	end
	if IconSet[key] then
		return IconSet[key]
	end
	local full = LoadFullIcons()
	if full and full[key] then
		IconSet[key] = full[key]
		return full[key]
	end
	return nil
end

local Custom = {}
do
	Custom.ColorRGB = Color3.fromRGB(255, 120, 24)
	Custom.Background = Color3.fromRGB(0, 0, 0)
	Custom.Surface = Color3.fromRGB(20, 20, 20)
	Custom.White = Color3.fromRGB(255, 255, 255)
	Custom.Icons = {
		Close = IconSet["lucide-x"],
		Hide = IconSet["lucide-minus"],
		Search = IconSet["lucide-search"],
		Chevron = IconSet["lucide-chevron-down"],
		Check = IconSet["lucide-check"],
		Info = IconSet["lucide-info"],
		Success = IconSet["lucide-check-circle"],
		Warning = IconSet["lucide-alert-triangle"],
		Error = IconSet["lucide-x-circle"],
		Credits = IconSet["lucide-users"],
		Folder = IconSet["lucide-folder"],
		Click = IconSet["lucide-mouse-pointer-click"],
	}

	function Custom:Create(Name, Properties, Parent)
		local _instance = Instance.new(Name)

		for i, v in pairs(Properties) do
			_instance[i] = v
		end

		if Parent then
			_instance.Parent = Parent
		end

		return _instance
	end

	function Custom:EnabledAFK()
		if getgenv and type(getgenv) == "function" then
			local ok, env = pcall(getgenv)
			if ok and type(env) == "table" then
				if env.__HydrogenAFKConnection then
					pcall(function() env.__HydrogenAFKConnection:Disconnect() end)
				end
			end
		end
		if Custom.AFKConnection then
			return
		end
		Custom.AFKConnection = Player.Idled:Connect(function()
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
		table.insert(Connections, Custom.AFKConnection)
		pcall(function()
			getgenv().__HydrogenAFKConnection = Custom.AFKConnection
		end)
	end
end

Custom:EnabledAFK()

local function AssetImage(Value, Fallback)
	if type(Value) == "number" then
		return "rbxassetid://" .. tostring(Value)
	end
	if type(Value) == "string" and Value ~= "" then
		if string.match(Value, "^%d+$") then
			return "rbxassetid://" .. Value
		end
		if string.find(Value, "rbxasset", 1, true) or string.find(Value, "http", 1, true) then
			return Value
		end
		return GetIcon(Value) or Fallback or ""
	end
	return Fallback or ""
end

local function CopyText(Text)
	Text = tostring(Text or "")
	local copier = (type(setclipboard) == "function" and setclipboard)
		or (type(toclipboard) == "function" and toclipboard)
		or (type(syn) == "table" and type(syn.write_clipboard) == "function" and syn.write_clipboard)
		or (type(Clipboard) == "table" and type(Clipboard.set) == "function" and Clipboard.set)
	if copier then
		local ok = pcall(copier, Text)
		return ok
	end
	return false
end

local DefaultCredits = {
	{
		Name = "Normal Guy",
		Role = "Main Developer & Gui Developer",
		AssetId = 129860409910003,
	},
}

local DefaultSocials = {
	{
		Name = "Github Account",
		Value = "https://github.com/YourName",
		Icon = 91640078956994,
	},
	{
		Name = "TikTok",
		Value = "@YourTikTok",
		Icon = 86288040968024,
	},
	{
		Name = "Discord",
		Value = "https://discord.gg/YourInvite",
	},
}

local function OpenClose()
	local ScreenGui = Custom:Create("ScreenGui", {
		Name = GuiName .. "_Toggle",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, GuiParent())

	local Close_ImageButton = Custom:Create("ImageButton", {
		Name = "ToggleButton",
		BackgroundColor3 = Custom.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0.1021, 0, 0.0743, 0),
		Size = UDim2.fromOffset(52, 52),
		Image = "rbxassetid://114343817737471",
		ScaleType = Enum.ScaleType.Crop,
		ClipsDescendants = true,
		Visible = false,
	}, ScreenGui)

	Custom:Create("UICorner", {
		Name = "MainCorner",
		CornerRadius = UDim.new(1, 0),
	}, Close_ImageButton)

	local dragging, dragStart, startPos = false, nil, nil

	local function UpdateDraggable(input)
		local delta = input.Position - dragStart
		Close_ImageButton.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	Close_ImageButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			dragging = true
			dragStart = input.Position
			startPos = Close_ImageButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Close_ImageButton.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			UpdateDraggable(input)
		end
	end)

	return Close_ImageButton
end

local Open_Close = OpenClose()

local function MakeDraggable(topbarobject, object)
	local dragging, dragStart, startPos = false, nil, nil

	local function UpdatePos(input)
		local delta = input.Position - dragStart
		local newPos =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		object.Position = newPos
	end

	topbarobject.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			UpdatePos(input)
		end
	end)
end

local function CircleClick(Button, X, Y)
	task.spawn(function()
		Button.ClipsDescendants = true

		local Circle = Instance.new("ImageLabel")
		Circle.Image = "rbxassetid://106471194043211"
		Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
		Circle.ImageTransparency = 0.8999999761581421
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.BackgroundTransparency = 1
		Circle.ZIndex = 10
		Circle.Name = "Circle"
		Circle.Parent = Button

		local NewX = X - Button.AbsolutePosition.X
		local NewY = Y - Button.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)

		local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5

		local Time = 0.5
		local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local Tween = TweenService:Create(Circle, TweenInfo, {
			Size = UDim2.new(0, Size, 0, Size),
			Position = UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
		})

		Tween:Play()

		Tween.Completed:Connect(function()
			for i = 1, 10 do
				Circle.ImageTransparency = Circle.ImageTransparency + 0.01
				task.wait(Time / 10)
			end
			Circle:Destroy()
		end)
	end)
end

local Hydrogen_Library = { Unloaded = false, NotificationsVisible = true, FolderName = FolderName, GuiName = GuiName }
local NotificationGui, NotificationLayout
local NotificationCount = 0

function Hydrogen_Library:GetIcon(Name)
	return GetIcon(Name)
end

local function EnsureNotifications()
	if NotificationGui and NotificationGui.Parent then
		return
	end
	NotificationGui = Custom:Create("ScreenGui", {
		Name = GuiName .. "_Notifications",
		ResetOnSpawn = false,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = Hydrogen_Library.NotificationsVisible,
	}, GuiParent())
	NotificationLayout = Custom:Create("Frame", {
		Name = "NotificationLayout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(1, -32, 1, -32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, NotificationGui)
	Custom:Create("UISizeConstraint", { MaxSize = Vector2.new(250, 10000) }, NotificationLayout)
	Custom:Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, NotificationLayout)
end

function Hydrogen_Library:SetNotificationsVisible(Visible)
	self.NotificationsVisible = Visible == true
	if NotificationGui then
		NotificationGui.Enabled = self.NotificationsVisible
	end
end

function Hydrogen_Library:SetNotification(Config)
	Config = Config or {}
	if self.Unloaded then
		return { Close = function() end }
	end
	EnsureNotifications()
	local Title = tostring(Config[1] or Config.Title or "Notification")
	local Description = tostring(Config[2] or Config.Description or "")
	local Content = tostring(Config[3] or Config.Content or "")
	local Icon = AssetImage(Config[4] or Config.Icon, Custom.Icons[Config.Type or "Info"] or Custom.Icons.Info)
	local Duration = math.max(0.05, tonumber(Config[5] or Config.Time) or 0.2)
	local Delay = math.max(0, tonumber(Config[6] or Config.Delay) or 5)
	NotificationCount += 1
	local Holder = Custom:Create("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = NotificationCount,
	}, NotificationLayout)
	local Frame = Custom:Create("Frame", {
		Name = "NotificationBody",
		BackgroundColor3 = Custom.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(340, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, Holder)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Frame)
	Custom:Create("UISizeConstraint", { MinSize = Vector2.new(0, 40) }, Frame)
	Custom:Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, Frame)
	Custom:Create("ImageLabel", {
		Name = "NotificationIcon",
		Image = Icon,
		ImageColor3 = Custom.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(18, 18),
	}, Frame)
	local TextContainer = Custom:Create("Frame", {
		Name = "NotificationContent",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -48, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, Frame)
	Custom:Create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, TextContainer)
	for index, text in ipairs({ Title, Description, Content }) do
		if text ~= "" then
			Custom:Create("TextLabel", {
				Name = "NotificationText",
				Text = text,
				TextColor3 = Custom.White,
				TextTransparency = index == 1 and 0 or 0.3,
				Font = index == 1 and Enum.Font.GothamBold or Enum.Font.Gotham,
				TextSize = index == 1 and 12 or 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = index,
			}, TextContainer)
		end
	end
	local Close = Custom:Create("ImageButton", {
		Name = "Close",
		Image = Custom.Icons.Close,
		ImageColor3 = Custom.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 3,
	}, Frame)
	local Handle = { Closed = false }
	function Handle:Close()
		if self.Closed then
			return
		end
		self.Closed = true
		if not Holder.Parent then
			return
		end
		Close.Visible = false
		TweenService:Create(Frame, TweenInfo.new(Duration), { Position = UDim2.fromOffset(340, 0) }):Play()
		task.delay(Duration, function()
			if Holder.Parent then
				Holder:Destroy()
			end
		end)
	end
	Close.Activated:Connect(function()
		Handle:Close()
	end)
	TweenService:Create(Frame, TweenInfo.new(Duration), { Position = UDim2.fromOffset(0, 0) }):Play()
	if Delay > 0 then
		task.delay(Delay, function()
			Handle:Close()
		end)
	end
	return Handle
end

function Hydrogen_Library:CreateWindow(Config)
	Config = Config or {}
	self.Unloaded = false
	local Title = Config[1] or Config.Title or ""
	local Description = Config[2] or Config.Description or ""
	local TabWidth = Config[3] or Config["Tab Width"] or 120
	local SizeUi = Config[4] or Config.SizeUi or UDim2.fromOffset(550, 315)

	local Funcs = {}

	local HydrogenGuiX = Custom:Create("ScreenGui", {
		Name = GuiName,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, GuiParent())

	Custom:Create("Folder", { Name = FolderName }, HydrogenGuiX)

	local DropShadowHolder = Custom:Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 455, 0, 350),
		ZIndex = 0,
		Name = "DropShadowHolder",
		Position = UDim2.new(
			0,
			(HydrogenGuiX.AbsoluteSize.X // 2 - 455 // 2),
			0,
			(HydrogenGuiX.AbsoluteSize.Y // 2 - 350 // 2)
		),
	}, HydrogenGuiX)

	local DropShadow = Custom:Create("ImageLabel", {
		Image = "",
		ImageColor3 = Color3.fromRGB(15, 15, 15),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = SizeUi,
		ZIndex = 0,
		Name = "DropShadow",
	}, DropShadowHolder)

	local Main = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Custom.Background,
		BackgroundTransparency = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = SizeUi,
		Name = "Main",
	}, DropShadow)

	Custom:Create("UICorner", {}, Main)

	Custom:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1.6,
	}, Main)

	local Top = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 58),
		Name = "Top",
	}, Main)

	local TextLabel = Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold,
		Text = Title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Name = "WindowTitle",
		Size = UDim2.fromOffset(180, 22),
		Position = UDim2.fromOffset(12, 7),
	}, Top)

	Custom:Create("UICorner", {}, Top)

	local TextLabel1 = Custom:Create("TextLabel", {
		Name = "WindowDescription",
		Font = Enum.Font.Gotham,
		Text = Description,
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextTransparency = 0.35,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(180, 16),
		Position = UDim2.fromOffset(12, 30),
	}, Top)

	local Close = Custom:Create("ImageButton", {
		Image = Custom.Icons.Close,
		ImageColor3 = Custom.White,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -12, 0, 16),
		Size = UDim2.fromOffset(20, 20),
		Name = "Close",
	}, Top)

	local Min = Custom:Create("ImageButton", {
		Image = Custom.Icons.Hide,
		ImageColor3 = Custom.White,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -44, 0, 16),
		Size = UDim2.fromOffset(20, 20),
		Name = "Min",
	}, Top)

	local CreditsButton = Custom:Create("TextButton", {
		Name = "CreditsButton",
		Text = "Credits",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Custom.White,
		BackgroundColor3 = Custom.Surface,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -76, 0, 13),
		Size = UDim2.fromOffset(80, 26),
		AutoButtonColor = true,
	}, Top)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, CreditsButton)
	Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 22) }, CreditsButton)
	Custom:Create("ImageLabel", {
		Name = "CreditsIcon",
		Image = Custom.Icons.Credits,
		ImageColor3 = Custom.ColorRGB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(-16, 5),
		Size = UDim2.fromOffset(16, 16),
	}, CreditsButton)

	TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TextLabel1.TextTruncate = Enum.TextTruncate.AtEnd
	local SearchSections = {}

	local SearchContainer = Custom:Create("Frame", {
		Name = "HeaderSearchContainer",
		BackgroundColor3 = Custom.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(204, 13),
		Size = UDim2.fromOffset(180, 28),
	}, Top)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SearchContainer)
	Custom:Create("ImageLabel", {
		Name = "HeaderSearchIcon",
		Image = Custom.Icons.Search,
		ImageColor3 = Custom.ColorRGB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 6),
		Size = UDim2.fromOffset(16, 16),
	}, SearchContainer)
	local Search = Custom:Create("TextBox", {
		Name = "HeaderSearch",
		Text = "",
		PlaceholderText = "Search...",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Custom.White,
		PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, SearchContainer)
	local function UpdateHeaderLayout()

		local Width = Top.AbsoluteSize.X
		local SearchRight = math.max(24, Width - 172)
		local Available = math.max(0, SearchRight - 24)
		local TitleWidth = math.floor(Available * 0.46)
		TextLabel.Size = UDim2.fromOffset(TitleWidth, 22)
		TextLabel1.Size = UDim2.fromOffset(TitleWidth, 16)
		SearchContainer.Position = UDim2.fromOffset(TitleWidth + 24, 13)
		SearchContainer.Size = UDim2.fromOffset(math.max(0, Available - TitleWidth), 28)
	end
	Top:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHeaderLayout)
	UpdateHeaderLayout()

	Search:GetPropertyChangedSignal("Text"):Connect(function()
		for _, update in ipairs(SearchSections) do
			update()
		end
	end)

	local LayersTab = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 9, 0, 70),
		Size = UDim2.new(0, TabWidth, 1, -79),
		Name = "LayersTab",
	}, Main)

	Custom:Create("UICorner", {
		CornerRadius = UDim.new(0, 2),
	}, LayersTab)

	Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 58),
		Size = UDim2.new(1, 0, 0, 1),
		Name = "DecideFrame",
	}, Main)

	local Layers = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, TabWidth + 18, 0, 70),
		Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -79),
		Name = "Layers",
	}, Main)

	Custom:Create("UICorner", {
		CornerRadius = UDim.new(0, 2),
	}, Layers)

	local NameTab = Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 24,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Name = "NameTab",
	}, Layers)

	local LayersReal = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, -33),
		Name = "LayersReal",
	}, Layers)

	local LayersFolder = Custom:Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Name = "LayersFolder",
	}, LayersReal)

	local LayersPageLayout = Custom:Create("UIPageLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Name = "LayersPageLayout",
		GamepadInputEnabled = false,
		TouchInputEnabled = false,
		ScrollWheelInputEnabled = false,
		TweenTime = 0.5,
		EasingDirection = Enum.EasingDirection.InOut,
		EasingStyle = Enum.EasingStyle.Quad,
	}, LayersFolder)

	local ScrollTab = Custom:Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 2.10000002, 0),
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarThickness = 0,
		Active = true,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Name = "ScrollTab",
	}, LayersTab)

	local UIListLayout = Custom:Create("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, ScrollTab)

	local function UpdateSize()
		local _Total = 0

		for _, v in pairs(ScrollTab:GetChildren()) do
			if v.Name ~= "UIListLayout" then
				_Total = _Total + 3 + v.Size.Y.Offset
			end
		end

		ScrollTab.CanvasSize = UDim2.new(0, 0, 0, _Total)
	end

	ScrollTab.ChildAdded:Connect(UpdateSize)
	ScrollTab.ChildRemoved:Connect(UpdateSize)

	Min.Activated:Connect(function()
		CircleClick(Min, Player:GetMouse().X, Player:GetMouse().Y)
		DropShadowHolder.Visible = false

		if not Open_Close.Visible then
			Open_Close.Visible = true
		end
	end)

	Open_Close.Activated:Connect(function()
		DropShadowHolder.Visible = true
		if Open_Close.Visible then
			Open_Close.Visible = false
		end
	end)

	local CloseOverlay = Custom:Create("TextButton", {
		Name = "CloseConfirmationOverlay",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Custom.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Active = true,
		Modal = true,
		ZIndex = 100,
	}, HydrogenGuiX)

	local ClosePanel = Custom:Create("TextButton", {
		Name = "CloseConfirmationPanel",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Custom.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -32, 0, 150),
		Active = true,
		ZIndex = 101,
	}, CloseOverlay)
	Custom:Create("UISizeConstraint", { MaxSize = Vector2.new(320, 150) }, ClosePanel)
	Custom:Create("UICorner", {}, ClosePanel)
	Custom:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1.6,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, ClosePanel)

	Custom:Create("ImageLabel", {
		Name = "CloseConfirmationIcon",
		Image = Custom.Icons.Warning,
		ImageColor3 = Custom.ColorRGB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, 13),
		Size = UDim2.fromOffset(20, 20),
		ZIndex = 102,
	}, ClosePanel)

	Custom:Create("TextLabel", {
		Name = "CloseConfirmationTitle",
		Text = "Close Window",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Custom.White,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(42, 8),
		Size = UDim2.new(1, -56, 0, 20),
		ZIndex = 102,
	}, ClosePanel)

	Custom:Create("TextLabel", {
		Name = "CloseConfirmationSubtitle",
		Text = "Are you sure you want to close?",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(42, 26),
		Size = UDim2.new(1, -56, 0, 14),
		ZIndex = 102,
	}, ClosePanel)

	Custom:Create("Frame", {
		Name = "CloseConfirmationDivider",
		BackgroundColor3 = Custom.White,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 102,
	}, ClosePanel)

	local CloseAccent = Custom:Create("Frame", {
		Name = "CloseConfirmationAccent",
		BackgroundColor3 = Custom.White,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 46),
		Size = UDim2.new(1, -24, 0, 2),
		ZIndex = 103,
	}, ClosePanel)
	Custom:Create("UICorner", {}, CloseAccent)
	Custom:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
			ColorSequenceKeypoint.new(0.5, Custom.ColorRGB),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
		}),
	}, CloseAccent)

	Custom:Create("TextLabel", {
		Name = "CloseConfirmationMessage",
		Text = "The hub will be closed and you will need to run the script again to open it.",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Custom.White,
		TextTransparency = 0.6,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 58),
		Size = UDim2.new(1, -32, 0, 34),
		ZIndex = 102,
	}, ClosePanel)

	local ConfirmClose = Custom:Create("TextButton", {
		Name = "ConfirmClose",
		Text = "Yes",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Custom.White,
		BackgroundColor3 = Custom.ColorRGB,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 16, 1, -46),
		Size = UDim2.new(0.5, -22, 0, 34),
		AutoButtonColor = true,
		ZIndex = 102,
	}, ClosePanel)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, ConfirmClose)

	local CancelClose = Custom:Create("TextButton", {
		Name = "CancelClose",
		Text = "No",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Custom.White,
		BackgroundColor3 = Custom.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 6, 1, -46),
		Size = UDim2.new(0.5, -22, 0, 34),
		AutoButtonColor = true,
		ZIndex = 102,
	}, ClosePanel)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, CancelClose)
	Custom:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, CancelClose)

	CancelClose.Activated:Connect(function()
		CircleClick(CancelClose, Player:GetMouse().X, Player:GetMouse().Y)
		CloseOverlay.Visible = false
	end)

	ConfirmClose.Activated:Connect(function()
		if not CloseOverlay.Visible or Hydrogen_Library.Unloaded then
			return
		end
		Hydrogen_Library.Unloaded = true
		for _, Connection in ipairs(Connections) do
			pcall(function()
				Connection:Disconnect()
			end)
		end
		table.clear(Connections)
		Custom.AFKConnection = nil
		local ToggleGui = Open_Close:FindFirstAncestorOfClass("ScreenGui")
		if ToggleGui then
			ToggleGui:Destroy()
		end
		if NotificationGui then
			NotificationGui:Destroy()
		end
		if HydrogenGuiX then
			HydrogenGuiX:Destroy()
		end
	end)

	Close.Activated:Connect(function()
		CircleClick(Close, Player:GetMouse().X, Player:GetMouse().Y)
		CloseOverlay.Visible = true
	end)

	DropShadowHolder.Size = SizeUi
	MakeDraggable(TextLabel, DropShadowHolder)
	TextLabel.Active = true

	local MoreBlur = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(1, 8, 1, 8),
		Size = UDim2.new(1, 154, 1, 54),
		Visible = false,
		ZIndex = 10,
		Name = "MoreBlur",
	}, Layers)

	local DropShadowHolder1 = Custom:Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0,
		Name = "DropShadowHolder",
	}, MoreBlur)

	local DropShadow1 = Custom:Create("ImageLabel", {
		Image = "",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 35, 1, 35),
		ZIndex = 0,
		Name = "DropShadow",
	}, DropShadowHolder1)

	Custom:Create("UICorner", {}, MoreBlur)

	local ConnectButton = Custom:Create("TextButton", {
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Name = "ConnectButton",
	}, MoreBlur)

	local DropdownSelect = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Custom.Background,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Position = UDim2.new(1, 172, 0.5, 0),
		Size = UDim2.new(0, 160, 1, -16),
		Name = "DropdownSelect",
		ClipsDescendants = true,
		ZIndex = 5,
	}, MoreBlur)

	ConnectButton.Activated:Connect(function()
		if MoreBlur.Visible then
			local tweenInfo = TweenInfo.new(0.2)

			local _Hide = TweenService:Create(MoreBlur, tweenInfo, { BackgroundTransparency = 1 })
			local _Move = TweenService:Create(DropdownSelect, tweenInfo, { Position = UDim2.new(1, 172, 0.5, 0) })

			_Hide:Play()
			_Move:Play()

			task.wait(0.2)
			MoreBlur.Visible = false
		end
	end)

	Custom:Create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = DropdownSelect,
	})

	Custom:Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 2.5,
		Transparency = 0.8,
		Parent = DropdownSelect,
	})

	local DropdownSelectReal = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -10, 1, -10),
		Name = "DropdownSelectReal",
		Parent = DropdownSelect,
	})

	local DropdownFolder = Custom:Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Name = "DropdownFolder",
		Parent = DropdownSelectReal,
	})

	local DropPageLayout = Custom:Create("UIPageLayout", {
		EasingDirection = Enum.EasingDirection.InOut,
		EasingStyle = Enum.EasingStyle.Quad,
		TweenTime = 0.01,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Archivable = false,
		Name = "DropPageLayout",
		GamepadInputEnabled = false,
		TouchInputEnabled = false,
		ScrollWheelInputEnabled = false,
		Parent = DropdownFolder,
	})

	local CreditsOverlay = Custom:Create("TextButton", {
		Name = "CreditsOverlay",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Custom.Background,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 50,
	}, Main)
	Custom:Create("UICorner", {}, CreditsOverlay)
	local CreditsPanel = Custom:Create("TextButton", {
		Name = "CreditsPanel",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Custom.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -40, 1, -40),
		ZIndex = 51,
	}, CreditsOverlay)
	Custom:Create("UISizeConstraint", { MaxSize = Vector2.new(440, 260) }, CreditsPanel)
	Custom:Create("UICorner", {}, CreditsPanel)
	Custom:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1.6,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, CreditsPanel)
	Custom:Create("ImageLabel", {
		Name = "CreditsIcon",
		Image = Custom.Icons.Credits,
		ImageColor3 = Custom.ColorRGB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, 13),
		Size = UDim2.fromOffset(20, 20),
		ZIndex = 52,
	}, CreditsPanel)
	Custom:Create("TextLabel", {
		Name = "CreditsTitle",
		Text = "Credits",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Custom.White,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(42, 8),
		Size = UDim2.new(1, -90, 0, 20),
		ZIndex = 52,
	}, CreditsPanel)
	Custom:Create("TextLabel", {
		Name = "CreditsDescription",
		Text = "The people behind " .. tostring(Title ~= "" and Title or "this hub"),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(42, 26),
		Size = UDim2.new(1, -90, 0, 14),
		ZIndex = 52,
	}, CreditsPanel)
	local CreditsClose = Custom:Create("ImageButton", {
		Name = "CreditsClose",
		Image = Custom.Icons.Close,
		ImageColor3 = Custom.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 15),
		Size = UDim2.fromOffset(20, 20),
		ZIndex = 52,
	}, CreditsPanel)
	Custom:Create("Frame", {
		Name = "CreditsDivider",
		BackgroundColor3 = Custom.White,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 52,
	}, CreditsPanel)
	local CreditsAccent = Custom:Create("Frame", {
		Name = "CreditsAccent",
		BackgroundColor3 = Custom.White,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 46),
		Size = UDim2.new(1, -24, 0, 2),
		ZIndex = 53,
	}, CreditsPanel)
	Custom:Create("UICorner", {}, CreditsAccent)
	Custom:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
			ColorSequenceKeypoint.new(0.5, Custom.ColorRGB),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
		}),
	}, CreditsAccent)
	local CreditsList = Custom:Create("ScrollingFrame", {
		Name = "CreditsList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 56),
		Size = UDim2.new(1, -24, 1, -68),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Custom.ColorRGB,
		ScrollBarThickness = 3,
		Active = true,
		ZIndex = 52,
	}, CreditsPanel)
	Custom:Create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) }, CreditsList)
	Custom:Create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, CreditsList)

	local SocialOrderBase = 1000

	local function SetCredits(Entries)

		for _, child in ipairs(CreditsList:GetChildren()) do
			if child:IsA("GuiObject") and (child.Name == "CreditPerson" or child.Name == "CreditsEmpty") then
				child:Destroy()
			end
		end
		CreditsList.CanvasPosition = Vector2.new(0, 0)
		local Count = 0
		for _, person in ipairs(type(Entries) == "table" and Entries or {}) do
			if type(person) == "table" then
				Count += 1
				local Row = Custom:Create("Frame", {
					Name = "CreditPerson",
					BackgroundColor3 = Custom.Surface,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 56),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = Count,
					ZIndex = 53,
				}, CreditsList)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Row)
				local Bar = Custom:Create("Frame", {
					Name = "ChooseFrame",
					BackgroundColor3 = Custom.ColorRGB,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 2, 0.5, -6),
					Size = UDim2.new(0, 1, 0, 12),
					ZIndex = 54,
				}, Row)
				Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.6 }, Bar)
				Custom:Create("UICorner", {}, Bar)
				local Image = AssetImage(person.AssetId or person.Image or person.Icon or person[3])
				local UserId = tonumber(person.UserId)
				local HasAvatar = Image ~= "" or UserId ~= nil
				local DetailsX = HasAvatar and 62 or 14
				if HasAvatar then
					local Avatar = Custom:Create("ImageLabel", {
						Name = "Avatar",
						Image = Image,
						BackgroundColor3 = Custom.Background,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(12, 8),
						Size = UDim2.fromOffset(40, 40),
						ScaleType = Enum.ScaleType.Crop,
						ZIndex = 54,
					}, Row)
					Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Avatar)
					Custom:Create("UIStroke", {
						Color = Custom.ColorRGB,
						Thickness = 1.6,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}, Avatar)
					if Image == "" then
						task.spawn(function()
							local ok, thumbnail = pcall(function()
								return Players:GetUserThumbnailAsync(
									UserId,
									Enum.ThumbnailType.HeadShot,
									Enum.ThumbnailSize.Size100x100
								)
							end)
							if ok and Avatar.Parent then
								Avatar.Image = thumbnail
							end
						end)
					end
				end
				local Details = Custom:Create("Frame", {
					Name = "Details",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(DetailsX, 9),
					Size = UDim2.new(1, -(DetailsX + 10), 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 54,
				}, Row)
				Custom:Create(
					"UIListLayout",
					{ Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder },
					Details
				)
				Custom:Create("TextLabel", {
					Name = "PersonName",
					Text = tostring(person.Name or person[1] or ""),
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextColor3 = Color3.fromRGB(231, 231, 231),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 16),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 1,
					ZIndex = 55,
				}, Details)
				Custom:Create("TextLabel", {
					Name = "PersonRole",
					Text = tostring(person.Role or person.Position or person[2] or ""),
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = Custom.White,
					TextTransparency = 0.6,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, 14),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 2,
					ZIndex = 55,
				}, Details)
			end
		end
		if Count == 0 then
			Custom:Create("TextLabel", {
				Name = "CreditsEmpty",
				Text = "No credits added yet.",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Custom.White,
				TextTransparency = 0.6,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 32),
				TextWrapped = true,
				ZIndex = 53,
				LayoutOrder = 1,
			}, CreditsList)
		end
	end

	local function SetSocials(Entries)
		for _, child in ipairs(CreditsList:GetChildren()) do
			if child:IsA("GuiObject") and (child.Name == "SocialDivider" or child.Name == "SocialRow") then
				child:Destroy()
			end
		end

		local List = {}
		for _, social in ipairs(type(Entries) == "table" and Entries or {}) do
			if type(social) == "table" then
				table.insert(List, social)
			end
		end
		if #List == 0 then
			return
		end

		local Divider = Custom:Create("Frame", {
			Name = "SocialDivider",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = SocialOrderBase,
			ZIndex = 53,
		}, CreditsList)
		Custom:Create("Frame", {
			Name = "DividerLine",
			BackgroundColor3 = Custom.White,
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 6),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 53,
		}, Divider)
		local DividerAccent = Custom:Create("Frame", {
			Name = "DividerAccent",
			BackgroundColor3 = Custom.White,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 5),
			Size = UDim2.new(1, -24, 0, 2),
			ZIndex = 54,
		}, Divider)
		Custom:Create("UICorner", {}, DividerAccent)
		Custom:Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
				ColorSequenceKeypoint.new(0.5, Custom.ColorRGB),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
			}),
		}, DividerAccent)
		Custom:Create("TextLabel", {
			Name = "SocialTitle",
			Text = "Social Accounts",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Custom.White,
			TextTransparency = 0.35,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(4, 12),
			Size = UDim2.new(1, -8, 0, 16),
			ZIndex = 53,
		}, Divider)

		for index, social in ipairs(List) do
			local Name = tostring(social.Name or social[1] or "")
			local Value = tostring(social.Value or social.Link or social.Text or social[2] or "")
			local Icon = AssetImage(social.Icon or social.AssetId or social.Image or social[3], Custom.Icons.Credits)

			local Row = Custom:Create("Frame", {
				Name = "SocialRow",
				BackgroundColor3 = Custom.Surface,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 56),
				LayoutOrder = SocialOrderBase + index,
				ZIndex = 53,
			}, CreditsList)
			Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Row)

			local Bar = Custom:Create("Frame", {
				Name = "ChooseFrame",
				BackgroundColor3 = Custom.ColorRGB,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0.5, -6),
				Size = UDim2.new(0, 1, 0, 12),
				ZIndex = 54,
			}, Row)
			Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.6 }, Bar)
			Custom:Create("UICorner", {}, Bar)

			local IconHolder = Custom:Create("Frame", {
				Name = "IconHolder",
				BackgroundColor3 = Custom.Background,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 8),
				Size = UDim2.fromOffset(40, 40),
				ZIndex = 54,
			}, Row)
			Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, IconHolder)
			Custom:Create("UIStroke", {
				Color = Custom.ColorRGB,
				Thickness = 1.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}, IconHolder)
			Custom:Create("ImageLabel", {
				Name = "SocialIcon",
				Image = Icon,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(26, 26),
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 55,
			}, IconHolder)

			local Details = Custom:Create("Frame", {
				Name = "Details",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(62, 0),
				Size = UDim2.new(1, -(62 + 84), 1, 0),
				ZIndex = 54,
			}, Row)
			Custom:Create("TextLabel", {
				Name = "SocialName",
				Text = Name,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(231, 231, 231),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 10),
				Size = UDim2.new(1, 0, 0, 16),
				ZIndex = 55,
			}, Details)
			Custom:Create("TextLabel", {
				Name = "SocialValue",
				Text = Value,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Custom.White,
				TextTransparency = 0.6,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 29),
				Size = UDim2.new(1, 0, 0, 14),
				ZIndex = 55,
			}, Details)

			local CopyButton = Custom:Create("TextButton", {
				Name = "CopyButton",
				Text = "Copy",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Custom.White,
				BackgroundColor3 = Custom.ColorRGB,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(64, 28),
				AutoButtonColor = true,
				ZIndex = 55,
			}, Row)
			Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, CopyButton)

			local Busy = false
			CopyButton.Activated:Connect(function()
				CircleClick(CopyButton, Player:GetMouse().X, Player:GetMouse().Y)
				if Busy then
					return
				end
				Busy = true
				local copied = CopyText(Value)
				if copied then
					CopyButton.Text = "Copied"
				else
					CopyButton.Text = "Copy"
					local Fallback = Row:FindFirstChild("CopyFallback")
					if not Fallback then
						Fallback = Custom:Create("TextBox", {
							Name = "CopyFallback",
							Text = Value,
							Font = Enum.Font.GothamBold,
							TextSize = 12,
							TextColor3 = Custom.White,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextEditable = false,
							ClearTextOnFocus = false,
							BackgroundColor3 = Color3.fromRGB(20, 20, 20),
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(62, 27),
							Size = UDim2.new(1, -(62 + 84), 0, 18),
							ClipsDescendants = true,
							ZIndex = 56,
						}, Row)
						Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Fallback)
					end
					Fallback.Visible = true
					pcall(function()
						Fallback:CaptureFocus()
						Fallback.SelectionStart = 1
						Fallback.CursorPosition = #Fallback.Text + 1
					end)
				end
				pcall(function()
					Hydrogen_Library:SetNotification({
						copied and "Copied" or "Copy Failed",
						copied and (Name .. " copied to clipboard") or "Select the text and copy it manually",
						"",
						Type = copied and "Success" or "Error",
						Delay = 2,
					})
				end)
				task.delay(1.5, function()
					if CopyButton.Parent then
						CopyButton.Text = "Copy"
					end
					Busy = false
				end)
			end)
		end
	end

	CreditsButton.Activated:Connect(function()
		CircleClick(CreditsButton, Player:GetMouse().X, Player:GetMouse().Y)
		CreditsOverlay.Visible = not CreditsOverlay.Visible
	end)
	CreditsClose.Activated:Connect(function()
		CircleClick(CreditsClose, Player:GetMouse().X, Player:GetMouse().Y)
		CreditsOverlay.Visible = false
	end)
	CreditsOverlay.Activated:Connect(function()
		CreditsOverlay.Visible = false
	end)
	SetCredits(type(Config.Credits) == "table" and Config.Credits or DefaultCredits)
	SetSocials(type(Config.Socials) == "table" and Config.Socials or DefaultSocials)

	local Tabs = {}

	local ToggleKey = Enum.KeyCode.RightShift
	local function ToggleWindow()
		if Hydrogen_Library.Unloaded then
			return
		end
		if DropShadowHolder.Visible then
			DropShadowHolder.Visible = false
			Open_Close.Visible = true
		else
			DropShadowHolder.Visible = true
			Open_Close.Visible = false
		end
	end
	if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
		table.insert(Connections, UserInputService.InputBegan:Connect(function(Input, GameProcessed)
			if GameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end
			if ToggleKey and Input.KeyCode == ToggleKey then
				ToggleWindow()
			end
		end))
	end
	function Tabs:SetToggleKey(KeyCode)
		if typeof(KeyCode) == "EnumItem" then
			ToggleKey = KeyCode
		end
	end

	local function ConfigPath(Name)
		return FolderName .. "/" .. tostring(Name or "default") .. ".json"
	end
	function Tabs:SaveConfig(Name)
		if type(writefile) ~= "function" then
			return
		end
		pcall(function()
			if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(FolderName) then
				makefolder(FolderName)
			end
			local Data = {}
			for Flag, Object in pairs(ConfigItems) do
				Data[Flag] = Object.Value
			end
			writefile(ConfigPath(Name), HttpService:JSONEncode(Data))
		end)
	end
	function Tabs:LoadConfig(Name)
		if type(readfile) ~= "function" or type(isfile) ~= "function" then
			return
		end
		pcall(function()
			local Path = ConfigPath(Name)
			if not isfile(Path) then
				return
			end
			local Data = HttpService:JSONDecode(readfile(Path))
			if type(Data) ~= "table" then
				return
			end
			for Flag, Value in pairs(Data) do
				local Object = ConfigItems[Flag]
				if Object and Object.Set then
					pcall(function()
						Object:Set(Value)
					end)
				end
			end
		end)
	end
	function Tabs:SetCredits(Entries)
		SetCredits(Entries)
	end
	function Tabs:SetSocials(Entries)
		SetSocials(Entries)
	end
	function Tabs:ShowCredits()
		CreditsOverlay.Visible = true
	end
	function Tabs:HideCredits()
		CreditsOverlay.Visible = false
	end
	local CountTab = 0
	local CountDropdown = 0
	function Tabs:CreateTab(Config)
		local _Name = Config[1] or Config.Name or ""
		local Icon = AssetImage(Config[2] or Config.Icon or "", "")

		local ScrolLayers = Custom:Create("ScrollingFrame", {
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
			ScrollBarThickness = 0,
			Active = true,
			LayoutOrder = CountTab,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Name = "ScrolLayers",
			Parent = LayersFolder,
		})

		Custom:Create("UIListLayout", {
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ScrolLayers,
		})

		local Tab = Custom:Create("Frame", {
			BackgroundColor3 = CountTab == 0 and Custom.Surface or Custom.Background,
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = CountTab,
			Size = UDim2.new(1, 0, 0, 30),
			Name = "Tab",
			Parent = ScrollTab,
		})

		Custom:Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = Tab,
		})

		local TabButton = Custom:Create("TextButton", {
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Name = "TabButton",
		}, Tab)

		Custom:Create("TextLabel", {
			Font = Enum.Font.GothamBold,
			Text = _Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 30, 0, 0),
			Name = "TabName",
		}, Tab)

		Custom:Create("ImageLabel", {
			Image = Icon,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 9, 0, 7),
			Size = UDim2.new(0, 16, 0, 16),
			Name = "FeatureImg",
		}, Tab)

		if CountTab == 0 then
			LayersPageLayout:JumpToIndex(0)
			NameTab.Text = _Name

			local ChooseFrame = Custom:Create("Frame", {
				BackgroundColor3 = Custom.ColorRGB,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0, 9),
				Size = UDim2.new(0, 1, 0, 12),
				Name = "ChooseFrame",
			}, Tab)

			Custom:Create("UIStroke", {
				Color = Custom.ColorRGB,
				Thickness = 1.6,
			}, ChooseFrame)

			Custom:Create("UICorner", {}, ChooseFrame)
		end

		TabButton.Activated:Connect(function()
			CircleClick(TabButton, Player:GetMouse().X, Player:GetMouse().Y)
			local FrameChoose = nil

			for _, s in pairs(ScrollTab:GetChildren()) do
				for _, v in pairs(s:GetChildren()) do
					if v.Name == "ChooseFrame" then
						FrameChoose = v
						break
					end
				end

				if FrameChoose then
					break
				end
			end

			if FrameChoose and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
				for _, TabFrame in pairs(ScrollTab:GetChildren()) do
					if TabFrame.Name == "Tab" then
						TweenService:Create(
							TabFrame,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{ BackgroundTransparency = 1 }
						):Play()
					end
				end

				local _TabT = TweenService:Create(
					Tab,
					TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					{ BackgroundColor3 = Custom.Surface, BackgroundTransparency = 0 }
				)
				local _FTween = TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(0, 2, 0, 9) }
				)

				FrameChoose.Parent = Tab
				_TabT:Play()
				_FTween:Play()

				LayersPageLayout:JumpToIndex(Tab.LayoutOrder)

				task.wait(0.05)
				NameTab.Text = _Name

				TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ Size = UDim2.new(0, 1, 0, 20) }
				):Play()

				task.wait(0.2)
				TweenService:Create(
					FrameChoose,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ Size = UDim2.new(0, 1, 0, 12) }
				):Play()
			end
		end)

		local Sections, CountSection = {}, 0

		function Sections:AddSection(Title, OpenSection)
			local Title = Title or ""
			local OpenSection = OpenSection or false

			local Section = Custom:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = CountSection,
				Size = UDim2.new(1, 0, 0, 30),
				Name = "Section",
			}, ScrolLayers)

			local SectionReal = Custom:Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Custom.Surface,
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 1, 0, 30),
				Name = "SectionReal",
			}, Section)

			Custom:Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}, SectionReal)

			local SectionButton = Custom:Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Name = "SectionButton",
			}, SectionReal)

			local FeatureFrame = Custom:Create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -5, 0.5, 0),
				Size = UDim2.new(0, 20, 0, 20),
				Name = "FeatureFrame",
			}, SectionReal)

			local FeatureImg = Custom:Create("ImageLabel", {
				Image = Custom.Icons.Chevron,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Rotation = -90,
				ImageColor3 = Custom.ColorRGB,
				Size = UDim2.new(1, 6, 1, 6),
				Name = "FeatureImg",
			}, FeatureFrame)

			local SectionTitle = Custom:Create("TextLabel", {
				Font = Enum.Font.GothamBold,
				Text = Title,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.new(1, -50, 0, 13),
				Name = "SectionTitle",
			}, SectionReal)

			local SectionDecideFrame = Custom:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 33),
				Size = UDim2.new(0, 0, 0, 2),
				Name = "SectionDecideFrame",
			}, Section)
			Custom:Create("UICorner", {}, SectionDecideFrame)
			Custom:Create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
					ColorSequenceKeypoint.new(0.5, Custom.ColorRGB),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
				}),
			}, SectionDecideFrame)

			local SectionAdd = Custom:Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = 1,
				Position = UDim2.new(0.5, 0, 0, 38),
				Size = UDim2.new(1, 0, 0, 100),
				Name = "SectionAdd",
			}, Section)

			Custom:Create("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}, SectionAdd)

			Custom:Create("UIListLayout", {
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, SectionAdd)

			local function UpdateSizeScroll()
				local OffsetY = 0

				for _, child in pairs(ScrolLayers:GetChildren()) do
					if child:IsA("GuiObject") and child.Visible then
						OffsetY = OffsetY + 3 + child.Size.Y.Offset
					end
				end

				ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
			end

			local function UpdateSizeSection()
				if OpenSection or Search.Text ~= "" then
					local SectionSizeYWitdh = 38

					for _, v in pairs(SectionAdd:GetChildren()) do
						if v:IsA("GuiObject") and v.Visible then
							SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
						end
					end

					TweenService:Create(FeatureFrame, TweenInfo.new(0.1), { Rotation = 90 }):Play()
					TweenService:Create(Section, TweenInfo.new(0.1), { Size = UDim2.new(1, 1, 0, SectionSizeYWitdh) })
						:Play()
					TweenService
						:Create(SectionAdd, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38) })
						:Play()
					TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 2) }):Play()

					task.wait(0.5)
					UpdateSizeScroll()
				end
			end

			local function ToggleSection()
				CircleClick(SectionButton, Player:GetMouse().X, Player:GetMouse().Y)

				if OpenSection then
					TweenService:Create(FeatureFrame, TweenInfo.new(0.1), { Rotation = 0 }):Play()
					TweenService:Create(Section, TweenInfo.new(0.1), { Size = UDim2.new(1, 1, 0, 30) }):Play()
					TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 0, 0, 2) }):Play()

					OpenSection = false
					task.wait(0.1)
					UpdateSizeScroll()
				else
					OpenSection = true
					UpdateSizeSection()
				end
			end

			local function ApplySearch()
				local query = string.lower(Search.Text)
				local sectionMatch = string.find(string.lower(Title), query, 1, true) ~= nil
				local hasMatch = false
				for _, row in ipairs(SectionAdd:GetChildren()) do
					if row:IsA("GuiObject") then
						local matches = query == "" or sectionMatch
						for _, label in ipairs(row:GetChildren()) do
							if label:IsA("TextLabel") and string.find(string.lower(label.Text), query, 1, true) then
								matches = true
							end
						end
						row.Visible = matches
						hasMatch = hasMatch or matches
					end
				end
				Section.Visible = query == "" or sectionMatch or hasMatch
				if OpenSection or query ~= "" then
					UpdateSizeSection()
				else
					Section.Size = UDim2.new(1, 0, 0, 30)
				end
				UpdateSizeScroll()
			end
			table.insert(SearchSections, ApplySearch)
			SectionAdd.ChildAdded:Connect(function()
				task.defer(ApplySearch)
			end)
			SectionAdd.ChildRemoved:Connect(function()
				task.defer(ApplySearch)
			end)
			task.defer(ApplySearch)

			SectionButton.Activated:Connect(ToggleSection)
			SectionAdd.ChildAdded:Connect(UpdateSizeSection)
			SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

			UpdateSizeScroll()

			local Item, ItemCount = {}, 0
			function Item:AddParagraph(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local SettingFuncs = {}

				local Paragraph = Custom:Create("Frame", {
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
					Name = "Paragraph",
				}, SectionAdd)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Paragraph)

				local ParagraphTitle = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(231, 231, 231),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -16, 0, 13),
					Name = "ParagraphTitle",
				}, Paragraph)

				local ParagraphContent = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Name = "ParagraphContent",
				}, Paragraph)

				local function UpdateParagraphSize()
					ParagraphContent.TextWrapped = false
					local lineCount =
						math.ceil(ParagraphContent.TextBounds.X / math.max(1, ParagraphContent.AbsoluteSize.X))

					ParagraphContent.Size = UDim2.new(1, -16, 0, 12 + (12 * lineCount))
					Paragraph.Size = UDim2.new(1, 0, 0, ParagraphContent.AbsoluteSize.Y + 33)
					ParagraphContent.TextWrapped = true

					UpdateSizeSection()
				end

				UpdateParagraphSize()

				ParagraphContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateParagraphSize)

				function SettingFuncs:Set(Config)
					local Title = Config[1] or Config.Title or ""
					local Content = Config[2] or Config.Content or ""

					ParagraphTitle.Text = Title
					ParagraphContent.Text = Content

					UpdateParagraphSize()
				end

				ItemCount += 1
				return SettingFuncs
			end

			function Item:AddSeperator(Config)
				local Title = Config[1] or Config.Title or ""
				local Sep_Funcs = {}

				local Seperator = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(70, 70, 70),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 1,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 30),
					Name = "Seperator",
				}, SectionAdd)

				local SeperatorTitle = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(231, 231, 231),
					TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
					TextStrokeTransparency = 0.8,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -16, 1, 0),
					Name = "SeperatorTitle",
				}, Seperator)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}, Seperator)

				local Gradient = Custom:Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120)),
					}),
					Rotation = 90,
				}, Seperator)

				function Sep_Funcs:Set(Config)
					local Title = Config[1] or Config.Title or ""

					SeperatorTitle.Text = Title
				end

				ItemCount += 1
				return Sep_Funcs
			end

			function Item:AddLine()
				local LineFuncs = {}

				local Line = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(90, 90, 90),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 7),
					Name = "Line",
				}, SectionAdd)

				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Line)

				Custom:Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80)),
					}),
					Rotation = 0,
				}, Line)

				ItemCount += 1
				return LineFuncs
			end

			function Item:AddButton(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local Icon = AssetImage(Config[3] or Config.Icon, Custom.Icons.Click)
				local Callback = Config[4] or Config.Callback or function() end
				local Funcs_Button = {}

				local Button = Custom:Create("Frame", {
					Name = "Button",
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
				}, SectionAdd)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Button)

				Custom:Create("TextLabel", {
					Name = "ButtonTitle",
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(231, 231, 231),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -72, 0, 13),
				}, Button)

				local ButtonContent = Custom:Create("TextLabel", {
					Name = "ButtonContent",
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Size = UDim2.new(1, -72, 0, 12),
				}, Button)

				local function UpdateButtonSize()
					local bounds = TextService:GetTextSize(
						ButtonContent.Text,
						12,
						Enum.Font.GothamBold,
						Vector2.new(math.max(1, ButtonContent.AbsoluteSize.X), 10000)
					)
					local height = ButtonContent.Text == "" and 0 or math.max(12, bounds.Y)
					ButtonContent.Size = UDim2.new(1, -72, 0, height)
					Button.Size = UDim2.new(1, 0, 0, math.max(44, height + 35))
					ButtonContent.TextWrapped = true
				end

				ButtonContent.TextWrapped = true
				UpdateButtonSize()

				ButtonContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					ButtonContent.TextWrapped = false
					UpdateButtonSize()
					ButtonContent.TextWrapped = true
					UpdateSizeSection()
				end)

				local ButtonButton = Custom:Create("TextButton", {
					Name = "ButtonButton",
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
				}, Button)

				local FeatureFrame1 = Custom:Create("Frame", {
					Name = "FeatureFrame",
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -15, 0.5, 0),
					Size = UDim2.new(0, 25, 0, 25),
				}, Button)

				Custom:Create("ImageLabel", {
					Name = "FeatureImg",
					Image = Icon,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 1, 0),
				}, FeatureFrame1)

				ButtonButton.Activated:Connect(function()
					CircleClick(ButtonButton, Player:GetMouse().X, Player:GetMouse().Y)

					Callback()
				end)

				ItemCount += 1
				return Funcs_Button
			end

			function Item:AddToggle(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local Default = Config[3] or Config.Default or false
				local Callback = Config[4] or Config.Callback or function() end

				local Funcs_Toggle = { Value = Default }

				local Toggle = Custom:Create("Frame", {
					Name = "Toggle",
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
				}, SectionAdd)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Toggle)

				local ToggleTitle = Custom:Create("TextLabel", {
					Name = "ToggleTitle",
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextSize = 13,
					TextColor3 = Color3.fromRGB(231, 231, 231),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -76, 0, 13),
				}, Toggle)

				local ToggleContent = Custom:Create("TextLabel", {
					Name = "ToggleContent",
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextSize = 12,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = 0.6,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Size = UDim2.new(1, -76, 0, 12),
				}, Toggle)

				local function UpdateToggleSize()
					local bounds = TextService:GetTextSize(
						ToggleContent.Text,
						12,
						Enum.Font.GothamBold,
						Vector2.new(math.max(1, ToggleContent.AbsoluteSize.X), 10000)
					)
					local height = ToggleContent.Text == "" and 0 or math.max(12, bounds.Y)
					ToggleContent.Size = UDim2.new(1, -76, 0, height)
					Toggle.Size = UDim2.new(1, 0, 0, math.max(44, height + 35))
					ToggleContent.TextWrapped = true
				end

				UpdateToggleSize()

				ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					UpdateToggleSize()
					UpdateSizeSection()
				end)

				local ToggleButton = Custom:Create("TextButton", {
					Name = "ToggleButton",
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
				}, Toggle)

				local FeatureFrame2 = Custom:Create("Frame", {
					Name = "FeatureFrame2",
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -15, 0.5, 0),
					Size = UDim2.fromOffset(38, 20),
				}, Toggle)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, FeatureFrame2)

				local UIStroke8 = Custom:Create("UIStroke", {
					Color = Color3.fromRGB(255, 255, 255),
					Thickness = 2,
					Transparency = 0.9,
				}, FeatureFrame2)

				local ToggleCircle = Custom:Create("Frame", {
					Name = "ToggleCircle",
					BackgroundColor3 = Color3.fromRGB(230, 230, 230),
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(16, 16),
					Position = UDim2.fromOffset(2, 2),
				}, FeatureFrame2)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 15),
				}, ToggleCircle)

				local function ToggleAnimation(isOn)
					local TitleColor = isOn and Custom.ColorRGB or Color3.fromRGB(230, 230, 230)
					local CirclePosition = isOn and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
					local StrokeColor = isOn and Custom.ColorRGB or Color3.fromRGB(255, 255, 255)
					local StrokeTransparency = isOn and 0 or 0.9
					local FrameColor = isOn and Custom.ColorRGB or Custom.Surface
					local FrameTransparency = 0

					local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

					TweenService:Create(ToggleTitle, tweenInfo, { TextColor3 = TitleColor }):Play()
					TweenService:Create(ToggleCircle, tweenInfo, { Position = CirclePosition }):Play()
					TweenService
						:Create(UIStroke8, tweenInfo, { Color = StrokeColor, Transparency = StrokeTransparency })
						:Play()
					TweenService:Create(
						FeatureFrame2,
						tweenInfo,
						{ BackgroundColor3 = FrameColor, BackgroundTransparency = FrameTransparency }
					):Play()
				end

				ToggleButton.Activated:Connect(function()
					CircleClick(ToggleButton, Player:GetMouse().X, Player:GetMouse().Y)
					Funcs_Toggle.Value = not Funcs_Toggle.Value
					Funcs_Toggle:Set(Funcs_Toggle.Value)
				end)

				function Funcs_Toggle:Set(Value)
					Value = Value == true
					self.Value = Value
					Callback(Value)
					ToggleAnimation(Value)
				end
				Funcs_Toggle:Set(Funcs_Toggle.Value)

				ItemCount += 1
				if Config.Flag ~= nil then
					Funcs_Toggle.Flag = Config.Flag
					ConfigItems[tostring(Config.Flag)] = Funcs_Toggle
				end
				return Funcs_Toggle
			end

			function Item:AddSlider(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local function Pick(A, B, D)
					if A ~= nil then
						return A
					end
					if B ~= nil then
						return B
					end
					return D
				end
				local Increment = Pick(Config[3], Config.Increment, 1)
				local Min = Pick(Config[4], Config.Min, 0)
				local Max = Pick(Config[5], Config.Max, 100)
				local Default = Pick(Config[6], Config.Default, 50)
				local Callback = Config[7] or Config.Callback or function() end

				local Funcs_Slider = { Value = Default }

				local Slider = Custom:Create("Frame", {
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
					Name = "Slider",
				}, SectionAdd)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Slider)

				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -180, 0, 13),
					Name = "SliderTitle",
				}, Slider)

				local SliderContent = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6000000238418579,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Size = UDim2.new(1, -180, 0, 12),
					Name = "SliderContent",
				}, Slider)

				local function UpdateSliderSize()
					SliderContent.TextWrapped = false
					SliderContent.Size = UDim2.new(
						1,
						-180,
						0,
						12 + (12 * math.floor(SliderContent.TextBounds.X / math.max(1, SliderContent.AbsoluteSize.X)))
					)
					Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
					SliderContent.TextWrapped = true
				end

				SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					UpdateSliderSize()
					UpdateSizeSection()
				end)
				UpdateSliderSize()

				local SliderInput = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Custom.ColorRGB,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(1, -155, 0.5, 0),
					Size = UDim2.new(0, 28, 0, 20),
					Name = "SliderInput",
				}, Slider)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 2),
				}, SliderInput)

				local TextBox = Custom:Create("TextBox", {
					Font = Enum.Font.GothamBold,
					Text = "90",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 13,
					TextWrapped = true,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, -1, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
				}, SliderInput)

				local SliderFrame = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.800000011920929,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(1, -20, 0.5, 0),
					Size = UDim2.new(0, 100, 0, 3),
					Name = "SliderFrame",
				}, Slider)

				Custom:Create("UICorner", {}, SliderFrame)

				local SliderDraggable = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Custom.ColorRGB,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(0.899999976, 0, 0, 1),
					Name = "SliderDraggable",
				}, SliderFrame)

				Custom:Create("UICorner", {}, SliderDraggable)

				local SliderCircle = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Custom.ColorRGB,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(1, 4, 0.5, 0),
					Size = UDim2.new(0, 8, 0, 8),
					Name = "SliderCircle",
				}, SliderDraggable)

				Custom:Create("UICorner", {}, SliderCircle)

				Custom:Create("UIStroke", {
					Color = Custom.ColorRGB,
				}, SliderCircle)

				local Dragging = false

				local function Round(Number, Factor)
					local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
					if Result < 0 then
						Result = Result + Factor
					end
					return Result
				end

				function Funcs_Slider:Set(Value)
					Value = math.clamp(Round(Value, Increment), Min, Max)
					Funcs_Slider.Value = Value
					TextBox.Text = tostring(Value)

					TweenService:Create(
						SliderDraggable,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Size = UDim2.fromScale((Value - Min) / (Max - Min), 1) }
					):Play()
				end

				SliderFrame.InputBegan:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						Dragging = true
					end
				end)

				SliderFrame.InputEnded:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						Dragging = false
						Callback(Funcs_Slider.Value)
					end
				end)

				local _LastX = nil
				local SliderConnection = UserInputService.InputChanged:Connect(function(Input)
					if Dragging then
						local CurrPosX = Input.Position.X
						if CurrPosX ~= _LastX then
							_LastX = CurrPosX

							local SizeScale = math.clamp(
								(CurrPosX - SliderFrame.AbsolutePosition.X) / math.max(1, SliderFrame.AbsoluteSize.X),
								0,
								1
							)
							Funcs_Slider:Set(Min + ((Max - Min) * SizeScale))
						end
					end
				end)
				table.insert(Connections, SliderConnection)

				TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					local Valid = TextBox.Text:gsub("[^%d]", "")
					if Valid ~= "" then
						local ValidNumber = math.min(tonumber(Valid), Max)
						TextBox.Text = tostring(ValidNumber)
					else
						TextBox.Text = "0"
					end
				end)

				TextBox.FocusLost:Connect(function()
					if TextBox.Text ~= "" then
						Funcs_Slider:Set(tonumber(TextBox.Text))
						Callback(Funcs_Slider.Value)
					else
						Funcs_Slider:Set(0)
						Callback(Funcs_Slider.Value)
					end
				end)

				Funcs_Slider:Set(tonumber(Default))
				Callback(Funcs_Slider.Value)

				ItemCount += 1
				if Config.Flag ~= nil then
					Funcs_Slider.Flag = Config.Flag
					ConfigItems[tostring(Config.Flag)] = Funcs_Slider
				end
				return Funcs_Slider
			end

			function Item:AddInput(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local Default = Config[3] or Config.Default or ""
				local Callback = Config[4] or Config.Callback or function() end
				local Funcs_Input = { Value = Default }

				local Input = Custom:Create("Frame", {
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
					Name = "Input",
				}, SectionAdd)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Input)

				local InputTitle = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -180, 0, 13),
					Name = "InputTitle",
				}, Input)

				local InputContent = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Size = UDim2.new(1, -180, 0, 12),
					Name = "InputContent",
					Parent = Input,
				})

				local function UpdateInputSize()
					local Ratio = InputContent.TextBounds.X / math.max(1, InputContent.AbsoluteSize.X)
					local Calculated = 12 + (12 * math.floor(Ratio))

					InputContent.Size = UDim2.new(1, -180, 0, Calculated)
					Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
				end

				UpdateInputSize()

				InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					InputContent.TextWrapped = false
					UpdateInputSize()
					InputContent.TextWrapped = true
					UpdateSizeSection()
				end)

				local InputFrame = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Position = UDim2.new(1, -7, 0.5, 0),
					Size = UDim2.new(0, 148, 0, 30),
					Name = "InputFrame",
				}, Input)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, InputFrame)

				local InputTextBox = Custom:Create("TextBox", {
					CursorPosition = -1,
					Font = Enum.Font.GothamBold,
					PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
					PlaceholderText = "Write your input there",
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0.5, 0),
					Size = UDim2.new(1, -10, 1, -8),
					Name = "InputTextBox",
				}, InputFrame)

				function Funcs_Input:Set(Value)
					InputTextBox.Text = Value
					Funcs_Input.Value = Value
					Callback(Value)
				end

				InputTextBox.FocusLost:Connect(function()
					Funcs_Input:Set(InputTextBox.Text)
				end)

				Funcs_Input:Set(Default)

				ItemCount += 1
				if Config.Flag ~= nil then
					Funcs_Input.Flag = Config.Flag
					ConfigItems[tostring(Config.Flag)] = Funcs_Input
				end
				return Funcs_Input
			end

			function Item:AddDropdown(Config)
				local Title = Config[1] or Config.Title or ""
				local Content = Config[2] or Config.Content or ""
				local Multi = Config[3] == true or Config.Multi == true or Config.Multiple == true
				local Options = Config[4] or Config.Options or {}
				local Default = Config[5] or Config.Default or {}
				if type(Default) ~= "table" then
					Default = { Default }
				end
				local Callback = Config[6] or Config.Callback or function() end

				local Funcs_Dropdown = { Value = table.clone(Default), Options = table.clone(Options), Multi = Multi }

				local Dropdown = Custom:Create("Frame", {
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = ItemCount,
					Size = UDim2.new(1, 0, 0, 35),
					Name = "Dropdown",
				}, SectionAdd)

				local DropdownButton = Custom:Create("TextButton", {
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					Name = "ToggleButton",
				}, Dropdown)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, Dropdown)

				local DropdownTitle = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -166, 0, 13),
					Name = "DropdownTitle",
					Parent = Dropdown,
				})

				local DropdownContent = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = Content,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 0, 23),
					Size = UDim2.new(1, -166, 0, 12),
					Name = "DropdownContent",
					Parent = Dropdown,
				})

				local function UpdateDropdownSize()
					local bounds = TextService:GetTextSize(
						Content,
						12,
						Enum.Font.GothamBold,
						Vector2.new(math.max(1, DropdownContent.AbsoluteSize.X), 10000)
					)
					local height = Content == "" and 0 or math.max(12, bounds.Y)
					DropdownContent.Size = UDim2.new(1, -166, 0, height)
					Dropdown.Size = UDim2.new(1, 0, 0, math.max(44, height + 35))
				end
				UpdateDropdownSize()
				DropdownContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					UpdateDropdownSize()
					UpdateSizeSection()
				end)

				local SelectOptionsFrame = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Custom.Surface,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(1, -7, 0.5, 0),
					Size = UDim2.new(0, 148, 0, 30),
					Name = "SelectOptionsFrame",
					LayoutOrder = CountDropdown,
				}, Dropdown)

				Custom:Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}, SelectOptionsFrame)

				DropdownButton.Activated:Connect(function()
					if not MoreBlur.Visible then
						MoreBlur.Visible = true

						local tweenInfo = TweenInfo.new(0.1)

						DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)

						local BlurTween = TweenService:Create(MoreBlur, tweenInfo, { BackgroundTransparency = 0 })
						local DropdownTween =
							TweenService:Create(DropdownSelect, tweenInfo, { Position = UDim2.new(1, -11, 0.5, 0) })

						BlurTween:Play()
						DropdownTween:Play()
					end
				end)

				local OptionSelecting = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					TextTransparency = 0.6,
					TextWrapped = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0.5, 0),
					Size = UDim2.new(1, -30, 1, -8),
					Name = "OptionSelecting",
				}, SelectOptionsFrame)

				local OptionImg = Custom:Create("ImageLabel", {
					Image = Custom.Icons.Chevron,
					ImageColor3 = Color3.fromRGB(231, 231, 231),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 25, 0, 25),
					Name = "OptionImg",
				}, SelectOptionsFrame)

				local ScrollSelect = Custom:Create("ScrollingFrame", {
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 3,
					Active = true,
					LayoutOrder = CountDropdown,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					Name = "ScrollSelect",
				}, DropdownFolder)

				Custom:Create("UIListLayout", {
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, ScrollSelect)

				local SearchBar = Custom:Create("TextBox", {
					Font = Enum.Font.GothamBold,
					PlaceholderText = "Search",
					PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0,
					BorderColor3 = Custom.ColorRGB,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20),
					Name = "SearchBar",
					ClearTextOnFocus = false,
					LayoutOrder = -1,
				}, ScrollSelect)

				SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
					local SearchText = string.lower(SearchBar.Text)

					for _, v in pairs(ScrollSelect:GetChildren()) do
						if v:IsA("Frame") and v.Name == "Option" and v.Name ~= "SearchBar" then
							local OptionText = v:FindFirstChild("OptionText")
							if OptionText then
								v.Visible = string.find(string.lower(OptionText.Text), SearchText, 1, true) ~= nil
							end
						end
					end
				end)

				local DropCount = 0

				function Funcs_Dropdown:Clear()
					self.Value = {}
					self.Options = {}
					DropCount = 0
					OptionSelecting.Text = "Select Options"
					for _, row in ipairs(ScrollSelect:GetChildren()) do
						if row.Name == "Option" then
							row:Destroy()
						end
					end
				end

				function Funcs_Dropdown:Set(Value)
					if Value == nil then
						Value = self.Value
					end
					if type(Value) ~= "table" then
						Value = { Value }
					end
					local selected = {}
					for _, value in ipairs(Value) do
						if table.find(self.Options, value) and not table.find(selected, value) then
							table.insert(selected, value)
							if not Multi then
								break
							end
						end
					end
					self.Value = selected
					for _, row in ipairs(ScrollSelect:GetChildren()) do
						if row.Name == "Option" then
							local active = table.find(selected, row.OptionText.Text) ~= nil
							row.BackgroundColor3 = active and Custom.Surface or Custom.Background
							row.BackgroundTransparency = 0
							row.ChooseFrame.Visible = active
							row.OptionText.TextColor3 = active and Custom.ColorRGB or Custom.White
						end
					end
					OptionSelecting.Text = #selected > 0 and table.concat(selected, ", ") or "Select Options"
					Callback(table.clone(selected))
				end

				function Funcs_Dropdown:AddOption(OptionName)
					OptionName = tostring(OptionName or "Option")
					if table.find(self.Options, OptionName) then
						return
					end
					table.insert(self.Options, OptionName)

					local Option = Custom:Create("Frame", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						LayoutOrder = DropCount,
						Size = UDim2.new(1, 0, 0, 30),
						Name = "Option",
					}, ScrollSelect)

					Custom:Create("UICorner", {
						CornerRadius = UDim.new(0, 3),
					}, Option)

					local OptionButton = Custom:Create("TextButton", {
						Font = Enum.Font.GothamBold,
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Name = "OptionButton",
					}, Option)

					Custom:Create("TextLabel", {
						Font = Enum.Font.GothamBold,
						Text = OptionName,
						TextSize = 13,
						TextColor3 = Color3.fromRGB(230, 230, 230),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 8, 0, 8),
						Size = UDim2.new(1, -38, 0, 16),
						Name = "OptionText",
					}, Option)

					local ChooseFrame = Custom:Create("ImageLabel", {
						Name = "ChooseFrame",
						Image = Custom.Icons.Check,
						ImageColor3 = Custom.ColorRGB,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -8, 0.5, 0),
						Size = UDim2.fromOffset(16, 16),
						Visible = false,
					}, Option)

					OptionButton.Activated:Connect(function()
						CircleClick(OptionButton, Player:GetMouse().X, Player:GetMouse().Y)

						local isOptionSelected = table.find(Funcs_Dropdown.Value, OptionName) == nil

						if Multi then
							if isOptionSelected then
								if not table.find(Funcs_Dropdown.Value, OptionName) then
									table.insert(Funcs_Dropdown.Value, OptionName)
								end
							else
								for i, value in ipairs(Funcs_Dropdown.Value) do
									if value == OptionName then
										table.remove(Funcs_Dropdown.Value, i)
										break
									end
								end
							end
						else
							Funcs_Dropdown.Value = { OptionName }
						end

						Funcs_Dropdown:Set(Funcs_Dropdown.Value)
						if not Multi then
							MoreBlur.Visible = false
							DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
						end
					end)

					local function UpdateCanvasSize()
						local OffsetY = 0

						for _, child in ipairs(ScrollSelect:GetChildren()) do
							if child.Name ~= "UIListLayout" and child.Name ~= "SearchBar" then
								OffsetY = OffsetY + 5 + child.Size.Y.Offset
							end
						end

						ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
					end

					UpdateCanvasSize()

					DropCount += 1
				end

				function Funcs_Dropdown:Refresh(RefreshList, Selecting)
					RefreshList = table.clone(RefreshList or {})
					Selecting = type(Selecting) == "table" and table.clone(Selecting)
						or (Selecting and { Selecting } or {})

					Funcs_Dropdown:Clear()

					for _, Drop in ipairs(RefreshList) do
						Funcs_Dropdown:AddOption(Drop)
					end

					Funcs_Dropdown:Set(Selecting)
				end

				Funcs_Dropdown:Refresh(Funcs_Dropdown.Options, Funcs_Dropdown.Value)

				ItemCount += 1
				CountDropdown += 1
				if Config.Flag ~= nil then
					Funcs_Dropdown.Flag = Config.Flag
					ConfigItems[tostring(Config.Flag)] = Funcs_Dropdown
				end
				return Funcs_Dropdown
			end

			function Item:AddMultipleDropdown(Config)
				Config = table.clone(Config or {})
				Config[3] = true
				Config.Multi = true
				return self:AddDropdown(Config)
			end

			CountSection += 1
			return Item
		end

		CountTab += 1
		return Sections
	end

	return Tabs
end

return Hydrogen_Library
