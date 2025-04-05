local GetService = game.GetService

local Services = setmetatable({}, {
    __index = function(self, Property)
        local Good, Service = pcall(GetService, game, Property);
        if (Good) then
            self[Property] = cloneref(Service);
            return Service
        end
    end
});

local GetPlayers = Services.Players.GetPlayers
local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local GetPropertyChangedSignal, Changed = 
    game.GetPropertyChangedSignal,
    game.Changed

local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local Tfind, sort, concat, pack, unpack;
do
    local table = table
    Tfind, sort, concat, pack, unpack = 
        table.find, 
        table.sort,
        table.concat,
        table.pack,
        table.unpack
end

local lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte;
do
    local string = string
    lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
        string.lower,
        string.find,
        string.split, 
        string.sub,
        string.format,
        string.len,
        string.match,
        string.gmatch,
        string.gsub,
        string.byte
end

local random, floor, round, abs, atan, cos, sin, rad;
do
    local math = math
    random, floor, round, abs, atan, cos, sin, rad, clamp = 
        math.random,
        math.floor,
        math.round,
        math.abs,
        math.atan,
        math.cos,
        math.sin,
        math.rad,
        math.clamp
end

local Instancenew = Instance.new
local Vector3new = Vector3.new
local Vector2new = Vector2.new
local UDim2new = UDim2.new
local UDimnew = UDim.new
local CFramenew = CFrame.new
local BrickColornew = BrickColor.new
local Drawingnew = Drawing.new
local Color3new = Color3.new
local Color3fromRGB = Color3.fromRGB
local Color3fromHSV = Color3.fromHSV
local ToHSV = Color3new().ToHSV

local Camera = Services.Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget


local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer.GetMouse(LocalPlayer);

local Destroy, Clone = game.Destroy, game.Clone

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect

local Connections = {}
local AddConnection = function(...)
    local ConnectionsToAdd = {...}
    for i = 1, #ConnectionsToAdd do
        Connections[#Connections + 1] = ConnectionsToAdd[i]
    end
    return ...
end

local UIElements = Services.InsertService:LoadLocalAsset("rbxassetid://100082257485583");
local GuiObjects = UIElements.GuiObjects
local Spring = loadstring(game:HttpGet('https://raw.githubusercontent.com/Fraktality/spr/refs/heads/master/spr.lua'))()

local Debounce = function(Func)
	local Debounce_ = false
	return function(...)
		if (not Debounce_) then
			Debounce_ = true
			Func(...);
			Debounce_ = false
		end
	end
end

local Utils = {
	Categories = {
		Widget = {
			Widgets = {}
		}
	},

	Config = {
		Tabs = {}
	}
}

local currentconfig = ""

Utils.SmoothScroll = function(content, SmoothingFactor)
	content.ScrollingEnabled = false

	local input = Clone(content);

	input.ClearAllChildren(input);
	input.BackgroundTransparency = 1
	input.ScrollBarImageTransparency = 1
	input.ZIndex = content.ZIndex + 1
	input.Name = "_smoothinputframe"
	input.ScrollingEnabled = true
	input.Parent = content.Parent

	local function syncProperty(prop)
        AddConnection(CConnect(GetPropertyChangedSignal(content, prop), function()
			if prop == "ZIndex" then
				input[prop] = content[prop] + 1
			else
				input[prop] = content[prop]
			end
		end));
	end

	syncProperty "CanvasSize"
	syncProperty "Position"
	syncProperty "Rotation"
	syncProperty "ScrollingDirection"
	syncProperty "ScrollBarThickness"
	syncProperty "BorderSizePixel"
	syncProperty "ElasticBehavior"
	syncProperty "SizeConstraint"
	syncProperty "ZIndex"
	syncProperty "BorderColor3"
	syncProperty "Size"
	syncProperty "AnchorPoint"
	syncProperty "Visible"

	local smoothConnection = AddConnection(CConnect(Services.RunService.RenderStepped, function()
		local a = content.CanvasPosition
		local b = input.CanvasPosition
		local c = SmoothingFactor
		local d = (b - a) * c + a

		content.CanvasPosition = d
	end));

	AddConnection(CConnect(content.AncestryChanged, function()
		if content.Parent == nil then
			Destroy(input);
			Disconnect(smoothConnection);
		end
	end));
end


Utils.MultColor3 = function(Color, Delta)
	return Color3new(clamp(Color.R * Delta, 0, 1), clamp(Color.G * Delta, 0, 1), clamp(Color.B * Delta, 0, 1))
end

Utils.Draggable = function(UI, DragUi)
	local DragSpeed = 0
	local StartPos
	local DragToggle, DragInput, DragStart

	if not DragUi then
		DragUi = UI
	end

	local function UpdateInput(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y);

		Spring.target(UI, 0.7, 8, {
			Position = Position
		})
	end
    local CoreGui = Services.CoreGui
    local UserInputService = Services.UserInputService

	AddConnection(CConnect(UI.InputBegan, function(Input)
		if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not UserInputService.GetFocusedTextBox(UserInputService)) then
			DragToggle = true
			DragStart = Input.Position
			StartPos = UI.Position

			local Objects = CoreGui.GetGuiObjectsAtPosition(CoreGui, DragStart.X, DragStart.Y);

			AddConnection(CConnect(Input.Changed, function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					DragToggle = false
				end
			end));
		end
	end));

	AddConnection(CConnect(UI.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			DragInput = Input
		end
	end));

	AddConnection(CConnect(UserInputService.InputChanged, function(Input)
		if (Input == DragInput and DragToggle) then
			UpdateInput(Input);
		end
	end));
end

Utils.Categories.Widget.setStatus = function(Widget, Boolean)
	local bgColor = Boolean and Color3.fromRGB(105, 105, 151) or Color3.fromRGB(35, 35, 48)
	local DotsColor = Boolean and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	local UIStrokeColor = Boolean and Color3.fromRGB(65, 65, 93) or Color3.fromRGB(46, 46, 63)
	local Position = Boolean and UDim2.new(0, 0, 0, 0) or UDim2.new(-0.055, 0, 0, 0)
	local TitlePosition = Boolean and UDim2.new(0.08, 0, 0.154, 0) or UDim2.new(0.028, 0, 0.154, 0)
	local DescriptionPosition = Boolean and UDim2.new(0.08, 0, 0.492, 0) or UDim2.new(0.028, 0, 0.492, 0)

	Spring.target(Widget.Status, 1, 8, {
		Position = Position
	})

	Spring.target(Widget.Title, 1, 8, {
		Position = TitlePosition
	})

	Spring.target(Widget.Description, 1, 8, {
		Position = DescriptionPosition
	})

	Spring.target(Widget.UIStroke, 1, 8, {
		Color = UIStrokeColor
	})

	Spring.target(Widget.Status, 1, 8, {
		BackgroundColor3 = bgColor
	})

	Spring.target(Widget.Status.Bar, 1, 8, {
		BackgroundColor3 = bgColor
	})

	Spring.target(Widget.Status.ImageLabel, 1, 8, {
		ImageColor3 = DotsColor
	})
end

Utils.Categories.Widget.Hover = function(Widget, Boolean)
	local UIStrokeColor = Boolean and Color3.fromRGB(65, 65, 93) or Color3.fromRGB(46, 46, 63)
	local WidgetStatusColor = Boolean and Color3.fromRGB(65, 65, 93) or Color3.fromRGB(35, 35, 48)
	local WidgetStatusDotsColor = Boolean and Color3.fromRGB(31, 31, 31) or Color3.fromRGB(255, 255, 255)
	local Position = Boolean and UDim2.new(0, 0, 0, 0) or UDim2.new(-0.055, 0, 0, 0)
	local TitlePosition = Boolean and UDim2.new(0.08, 0, 0.154, 0) or UDim2.new(0.028, 0, 0.154, 0)
	local DescriptionPosition = Boolean and UDim2.new(0.08, 0, 0.492, 0) or UDim2.new(0.028, 0, 0.492, 0)

	if currentconfig ~= Widget then

	Spring.target(Widget.Status, .8, 5, {
		Position = Position
	})

	Spring.target(Widget.Title, .8, 5, {
		Position = TitlePosition
	})

	Spring.target(Widget.Description, .8, 5, {
		Position = DescriptionPosition
	})
		
	end
	
end

Utils.Categories.Widget.Click = function(Widget, Boolean)
	local TitleColor = Boolean and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 79)

	Spring.target(Widget.Title, .8, 5, {
		TextColor3 = TitleColor
	})

end

Utils.Categories.Widget.ToggleCheckmark = function(Check, Boolean, Slow)
	local Transparency = Boolean and 0 or 1
	Speed = tonumber(Slow) and Slow or 5

	Spring.target(Check, 1, Speed, {
		BackgroundTransparency = Transparency
	})

	Spring.target(Check.Tick, 1, Speed, {
		ImageTransparency = Transparency
	})
end

Utils.Categories.Widget.OpenConfigonClick = function(Widget, Window)
	local ConfigContainer = Window.Container.Config
	local ConfigBG = Window.Container.configbg
	local Alert = Window.Container.Alert
	local AlertText = Alert
	for _, v in pairs(Utils.Config.Tabs) do
		if Widget == nil and v.Visible then
			-- Fade out Alert if currently not hidden
			if Alert.Visible and AlertText then
				Spring.target(AlertText, 1, 5, {
					TextTransparency = 1
				})
			end

			-- Reverse animation
			for _, element in pairs(v.Widget:GetChildren()) do
				if element.Name == "Divider" then
					Spring.target(element, 1, 4, {
						BackgroundTransparency = 1
					})
				end

				if element:IsA("Frame") then
					for _, desc in pairs(element:GetDescendants()) do
						if desc:IsA("TextLabel") or desc:IsA("TextButton") then
							Spring.target(desc, 1, 5, {
								TextTransparency = 1
							})
						elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") and desc.Name ~= "Tick" then
							Spring.target(desc, 1, 5, {
								ImageTransparency = 1
							})
						elseif desc:IsA("Frame")  then
							Spring.target(desc, 1, 5, {
								BackgroundTransparency = 1
							})

							if desc.Name == "Check" then
								Utils.Categories.Widget.ToggleCheckmark(desc, false, 5)
							end
						elseif desc:IsA("UIStroke") then
							Spring.target(desc, 1, 5, {
								Transparency = 1
							})
						end
					end
				end
			end

			Spring.target(v.Widget, 1, 5, {
				BackgroundTransparency = 1
			})

			local stroke = v.Widget:FindFirstChildWhichIsA("UIStroke")
			if stroke then
				Spring.target(stroke, 1, 5, {
					Transparency = 1
				})
			end

			Spring.target(ConfigBG, 1, 5, {
				BackgroundTransparency = 1
			})

			Spring.target(ConfigBG.UIStroke, 1, 5, {
				Transparency = 1
			})

			Spring.target(ConfigBG.UIStroke, 1, 5, {
				Transparency = 1
			})

			task.delay(0.5, function()

				if ConfigBG.BackgroundTransparency < 1 then
					return
				end

				v.Visible = false
				ConfigContainer.Visible = false
				ConfigBG.Visible = false
				Alert.Visible = true

				Alert.TextTransparency = 1

				if AlertText then
					Spring.target(AlertText, 1, 5, {
						TextTransparency = 0
					})
				end
			end)

			return
		end
	end

	for _, v in pairs(Utils.Config.Tabs) do
		v.Visible = false
		Alert.Visible = false

		for _, v1 in pairs(Utils.Categories.Widget.Widgets) do
			Utils.Categories.Widget.setStatus(v1, false)
		end

		if v.Name == Widget.Title.Text then
			Utils.Categories.Widget.setStatus(Widget, true)
			v.Visible = true
			v.BackgroundTransparency = 1
			v.Widget.Visible = true

			for _, element in pairs(v.Widget:GetChildren()) do
				if element:IsA("Frame") then
					element.Visible = true
					element.BackgroundTransparency = 1
					v.Widget.BackgroundTransparency = 1

					Spring.target(v.Widget, 1, 5, {
						BackgroundTransparency = 0
					})

					local stroke = v.Widget:FindFirstChildWhichIsA("UIStroke")
					if stroke then
						stroke.Transparency = 1
						Spring.target(stroke, 1, 5, {
							Transparency = 0
						})
					end

					local title = element:FindFirstChild("Title")
					if title and title:IsA("TextLabel") then
						title.TextTransparency = 1
						Spring.target(title, 1, 6, {
							TextTransparency = 0
						})
					end

					local value = element:FindFirstChild("Value")
					if value and value:IsA("TextLabel") then
						value.TextTransparency = 1
						Spring.target(value, 1, 6, {
							TextTransparency = 0
						})
					end

					local barFrame = element:FindFirstChild("BarFrame")
					if barFrame and barFrame:FindFirstChild("Bar") then
						local bar = barFrame.Bar
						local originalSize = bar.Size
						bar.Size = UDim2.fromScale(0, originalSize.Y.Scale)

						Spring.target(bar, 0.6, 4, {
							Size = originalSize
						})
					end

					local Check = element:FindFirstChild("Check")
					if Check then
						local CheckEnabled = Check.Parent.Title.TextColor3 == Color3.fromRGB(255, 255, 255)
						Check.BackgroundTransparency = 1
						Check.Tick.ImageTransparency = 1
						Utils.Categories.Widget.ToggleCheckmark(Check, CheckEnabled, 5)
					end

					if element.Name == "Divider" then
						element.BackgroundTransparency = 1

						Spring.target(element, 1, 4, {
							BackgroundTransparency = 0
						})
					end

					for _, desc in pairs(element:GetDescendants()) do
						if desc:IsA("TextLabel") or desc:IsA("TextButton") then
							desc.TextTransparency = 1
							Spring.target(desc, 1, 5, {
								TextTransparency = 0
							})
						elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") and desc.Name ~= "Tick" then
							desc.ImageTransparency = 1
							Spring.target(desc, 1, 5, {
								ImageTransparency = 0
							})
						elseif desc:IsA("Frame") and desc.Name ~= "Check" then
							desc.BackgroundTransparency = 1
							Spring.target(desc, 1, 5, {
								BackgroundTransparency = 0
							})
						elseif desc:IsA("UIStroke") then
							desc.Transparency = 1
							Spring.target(desc, 1, 5, {
								Transparency = 0
							})
						end
					end
				end
			end

			Spring.target(ConfigBG, 1, 5, {
				BackgroundTransparency = 0
			})

			Spring.target(ConfigBG.UIStroke, 1, 5, {
				Transparency = 0
			})
		end
	end

	ConfigContainer.Visible = true
	ConfigBG.Visible = true
end

local UILibrary =  {}
UILibrary.__index = UILibrary

UILibrary.new = function()
	local NewUI = {}
	local UI = Instance.new("ScreenGui");
	setmetatable(NewUI, UILibrary);
	NewUI.UI = UI
	
	return NewUI
end

function UILibrary:LoadWindow(MainUI)
    local Window = Clone(GuiObjects.Load.Window)
    Window.Parent = MainUI.UI

    Utils.Draggable(Window);

    local WindowLibrary = {}
    WindowLibrary.CategoryLibrary = {}

	local PageCount = 0
	local SelectedPage

    function WindowLibrary.CategoryLibrary.NewTab(Title)
        local Tab = Clone(GuiObjects.Elements.Categories.Tab.Tab)
        local Header = Tab.Header

        Header["2"].Text = Title

        Tab.Parent = Window.Container.Categories

        local WidgetLibrary = {}

        function WidgetLibrary.NewWidget(Title, Description, Enabled, Callback)
            local Widget = Clone(GuiObjects.Elements.Categories.Elements.Widget)
			Utils.Categories.Widget.setStatus(Widget, false)
			Utils.Categories.Widget.Hover(Widget, false)
			Utils.Categories.Widget.Click(Widget, Enabled)

            Widget.Title.Text = Title
            Widget.Description.Text = Description

			Widget.ClipsDescendants = true

			local function ToggleStateFunction(Widget, Enabled, Callback)
				AddConnection(CConnect(Widget.Toggle.MouseButton2Click, function()
					if currentconfig == Widget then
						currentconfig = nil
						Utils.Categories.Widget.OpenConfigonClick(nil, Window)
						Utils.Categories.Widget.setStatus(Widget, false)
					else
						currentconfig = Widget
						Utils.Categories.Widget.Hover(Widget, false)
						Utils.Categories.Widget.OpenConfigonClick(Widget, Window)
						Utils.Categories.Widget.setStatus(Widget, true)
					end
				end))

				AddConnection(CConnect(Widget.Toggle.MouseButton1Click, function()
					Enabled = not Enabled

					Utils.Categories.Widget.Click(Widget, Enabled)
					Utils.Categories.Widget.ToggleCheckmark(Widget.Check, Enabled)
	
					Callback(Enabled, "MouseButton1Click");
				end))

				AddConnection(CConnect(Widget.Toggle.MouseEnter, function()
					Utils.Categories.Widget.Hover(Widget, true)
				end))

				AddConnection(CConnect(Widget.Toggle.MouseLeave, function()
					Utils.Categories.Widget.Hover(Widget, false)
				end))
			end

			ToggleStateFunction(Widget, Enabled, Callback)

			local ConfigLibrary = {}

			function ConfigLibrary.Widget()
				local ConfigWidget = Clone(GuiObjects.Elements.Config.Widget.Tab);
				ConfigWidget.Name = Widget.Title.Text

				local ElementsLibrary = {}

				local function ToggleFunction(Toggle, Enabled, Callback)
					Utils.Categories.Widget.ToggleCheckmark(Toggle.Check, Enabled)
					local TitleColor = Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 79)

					Spring.target(Toggle.Title, 1, 5, {
						TextColor3 = TitleColor
					})

					AddConnection(CConnect(Toggle.Trigger.MouseButton1Click, function()
						Enabled = not Enabled
						local TitleColor = Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 79)

						Spring.target(Toggle.Title, 1, 5, {
							TextColor3 = TitleColor
						})

						Utils.Categories.Widget.ToggleCheckmark(Toggle.Check, Enabled)

						Callback(Enabled)
					end))
				end

				ElementsLibrary.Toggle = function(Title, Enabled, Callback)
					local Toggle = Clone(GuiObjects.Elements.Config.Elements.Toggle)
					ToggleFunction(Toggle, Enabled, Callback)

					Toggle.Title.Text = Title
					Toggle.Parent = ConfigWidget.Widget
				end

				ElementsLibrary.Slider = function(Title, Args, Callback)
					local Slider = Clone(GuiObjects.Elements.Config.Elements.Slider)
					local BarFrame = Slider.BarFrame
					local Bar = BarFrame.Bar
					local Circle = Bar.Circle
					local Hitbox = BarFrame.Hitbox
					local TitleLabel = Slider.Title
					local ValueLabel = Slider.Value
				
					TitleLabel.Text = Title
				
					local Moving = false
					local Min = Args.Min
					local Max = Args.Max
					local Step = Args.Step or 1
					local Default = clamp(Args.Default or Min, Min, Max)

					ValueLabel.Text = Default
				
					local function SetBar(Value)
						local Percent = (Value - Min) / (Max - Min)

						Spring.target(Bar, 0.6, 5, {
							Size = UDim2.fromScale(Percent, 1)
						})

						--Bar.Size = UDim2.fromScale(Percent, 1)

						Callback(Value)
					end
				
					local function Update()
						local BarSize = BarFrame.AbsoluteSize.X
						local BarPos = BarFrame.AbsolutePosition.X
						local MouseX = Mouse.X
						local Position = clamp(MouseX - BarPos, 0, BarSize)
				
						local Value = Min + (Max - Min) * (Position / BarSize)
						Value = math.floor(Value / Step + 0.5) * Step
						Value = clamp(Value, Min, Max)
				
						ValueLabel.Text = tostring(Value)
						SetBar(Value)
					end
				
					AddConnection(CConnect(Hitbox.MouseButton1Down, function()
						Moving = true

						local TitleColor = Color3.fromRGB(255, 255, 255)

						Spring.target(TitleLabel, 1, 5, {
							TextColor3 = TitleColor
						})

						Update()
					end))
				
					AddConnection(CConnect(Services.UserInputService.InputEnded, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Moving = false
							local TitleColor = Color3.fromRGB(60, 60, 79)

							Spring.target(TitleLabel, 1, 5, {
								TextColor3 = TitleColor
							})
						end
					end))
				
					AddConnection(CConnect(Mouse.Move, Debounce(function()
						if Moving then
							Update()
						end
					end)))
				
					-- Set default value
					SetBar(Default)
					Slider.Parent = ConfigWidget.Widget
				
					return Slider
				end
				
				ElementsLibrary.Dropdown = function(Title, Options, Multi, Callback)
					local DropdownTab = Clone(GuiObjects.Elements.Config.Elements.Dropdown.Dropdown)
					local DropdownSelection = DropdownTab.DropdownSelection
					local DropdownElement = DropdownTab.DropdownElement
					local TextButton = GuiObjects.Elements.Config.Elements.Dropdown.TextButton
					local Button = DropdownElement.Hitbox
					local Icon = DropdownElement.Icon
					local TitleLabel = DropdownElement.Title
				
					local Opened = false
					local Selected = {}
				
					-- Initialize default selection from Options
					for k, v in pairs(Options) do
						if v == true then
							Selected[k] = true
						end
					end
				
					local function UpdateTitle()
						local keys = {}
						for k in pairs(Selected) do
							table.insert(keys, k)
						end
						local display = table.concat(keys, ", ")
						TitleLabel.Text = Title .. ": " .. (display ~= "" and display or "None")
					end
				
					local function SetZIndex(index)
						DropdownTab.ZIndex = index
						DropdownSelection.ZIndex = index
				
						for _, button in pairs(DropdownSelection:GetChildren()) do
							if button:IsA("TextButton") then
								button.ZIndex = index
							end
						end
					end
				
					local function ToggleDropdown(forceClose)
						Opened = forceClose and false or not Opened

						if forceClose then
						--SetZIndex(Opened and 2 or 1)
						end
					
						if Opened then
							-- Make visible first
							SetZIndex(Opened and 2 or 1)
							DropdownSelection.Visible = true
					
							-- Reset all button visibility + transparency
							for _, button in pairs(DropdownSelection:GetChildren()) do
								if button:IsA("TextButton") then
									button.Visible = true
									button.TextTransparency = 1
								end
							end
					
							-- Animate dropdown open
							Spring.target(DropdownSelection, 1, 6, {
								Size = UDim2.new(1, -10, 0, DropdownSelection.UIListLayout.AbsoluteContentSize.Y)
							})

							local TitleColor = Color3.fromRGB(255, 255, 255)

						    Spring.target(DropdownTab.Title, 1, 5, {
							   TextColor3 = TitleColor
						    })

							Spring.target(Icon, 0.6, 6, { Rotation = 180 })
					
							-- Delay slightly, then fade text in
							task.delay(0.1, function()
								for _, button in pairs(DropdownSelection:GetChildren()) do
									if button:IsA("TextButton") then
										Spring.target(button, 1, 9, {
											TextTransparency = 0
										})
									end
									task.wait(.05)
								end
							end)
						else
							-- Fade text out first
							for _, button in pairs(DropdownSelection:GetChildren()) do
								if button:IsA("TextButton") then
									Spring.target(button, 1, 9, {
										TextTransparency = 1
									})
								end
								task.wait(.05)
							end
					
							-- Then close the frame after short delay
							task.delay(0.25, function()
								Spring.target(DropdownSelection, 1, 6, {
									Size = UDim2.new(1, -10, 0, 0)
								})

								local TitleColor = Color3.fromRGB(60, 60, 79)

								Spring.target(DropdownTab.Title, 1, 5, {
									TextColor3 = TitleColor
								 })
					
								Spring.target(Icon, 0.6, 6, { Rotation = 0 })
					
								-- Finally hide everything after collapse
								task.delay(0.2, function()
									if not Opened then
										for _, button in pairs(DropdownSelection:GetChildren()) do
											if button:IsA("TextButton") then
												button.Visible = false
											end
										end
										DropdownSelection.Visible = false
										SetZIndex(Opened and 2 or 1)
									end
								end)
							end)
						end
					end
					
				
					-- Listen for outside clicks to close
					AddConnection(CConnect(Services.UserInputService.InputBegan, function(input)
						if Opened and input.UserInputType == Enum.UserInputType.MouseButton1 then
							local guiObjs = Services.CoreGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
				
							local clickedInside = false
							for _, obj in pairs(guiObjs) do
								if DropdownTab:IsAncestorOf(obj) then
									clickedInside = true
									break
								end
							end
				
							if not clickedInside then
								ToggleDropdown(true) -- force close
							end
						end
					end))
				
					for OptionName in pairs(Options) do
						local OptionButton = Clone(TextButton)
						OptionButton.Text = OptionName
				
						AddConnection(CConnect(OptionButton.MouseButton1Click, function()
							if Multi then
								if Selected[OptionName] then
									Selected[OptionName] = nil
								else
									Selected[OptionName] = true
								end
							else
								Selected = {[OptionName] = true}
								ToggleDropdown(true)
							end
				
							-- Update all button visuals
							for _, button in pairs(DropdownSelection:GetChildren()) do
								if button:IsA("TextButton") then
									local name = button.Text
									local isSelected = Selected[name]
									Spring.target(button, 1, 6, {
										TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 79)
									})
								end
							end
				
							UpdateTitle()
							Callback(Selected)
						end))
				
						Spring.target(OptionButton, 1, 6, {
							TextColor3 = Selected[OptionName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 79)
						})
				
						OptionButton.ZIndex = 1
						OptionButton.Parent = DropdownSelection
					end
				
					AddConnection(CConnect(Button.MouseButton1Click, ToggleDropdown))
				
					-- Initial Setup
					UpdateTitle()
					SetZIndex(1)
					DropdownSelection.Visible = false
					DropdownSelection.Size = UDim2.new(1, -10, 0, 0)
					DropdownTab.Title.Text = Title
				
					DropdownTab.Parent = ConfigWidget.Widget -- Change this if needed
					return DropdownTab
				end				
							
				ElementsLibrary.Divider = function()
					local Divider = Clone(GuiObjects.Elements.Config.Elements.Divider)

					Divider.Parent = ConfigWidget.Widget
				end

				ConfigWidget.Parent = Window.Container.Config
				table.insert(Utils.Config.Tabs, ConfigWidget)
				return ElementsLibrary
			end


			table.insert(Utils.Categories.Widget.Widgets, Widget)
            Widget.Parent = Tab
			return ConfigLibrary
        end

        return WidgetLibrary
    end

    return WindowLibrary.CategoryLibrary
end

print("UI Loaded...");

return UILibrary
