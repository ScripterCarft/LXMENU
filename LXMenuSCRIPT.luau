local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScripterCarft/LXMENU/main/LXMenuUI.luau"))()

UI.init()


--dragger
local dragger
local parent
local dragging
local dragStart
local userInputService = game:GetService("UserInputService")
local startPos

--player
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local humanoid

local success, result = pcall(function()
	if player:FindFirstChild("PlayerScripts"):FindFirstChild("PlayerModule") then
		return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	else
		return nil
	end
end)

local character

--flight
local cam = game.Workspace.CurrentCamera
local speed
local keys = {a = false, d = false, w = false, s = false}
local selectedPlr = nil
local flying = false
local Weld
local torso

local ghostCharacter

local DefaultKeys = {
	["FlightKey"] = Enum.KeyCode.X,
	["SafeTeleportKey"] = Enum.KeyCode.N,
	["OpenMenuKey"] = Enum.KeyCode.K
	
}

local MaxValues = {
	["FlightSpeed"] = 20,
	["WalkSpeed"] = 200,
	["JumpHeight"] = 50
}

local config = {
	["ButtonColor"] = {
		["On"] = Color3.new(0.231373, 0.741176, 0.376471),
		["Off"] = Color3.new(0.054902, 0.054902, 0.054902)
	}
}

local Types

local cooldown = false

local Settings

function addPlayer(plr)
	local templ = UI["76"]:Clone()
	templ.Parent = 	UI["70"]
	templ.DisplayName.Text = plr.DisplayName
	templ["Polygon 1"].PlayerName.Text = "@"..plr.Name
	templ.Picture.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" ..plr.UserId.. "&width=180&height=180&format=png"

	local connection = templ.MouseButton1Click:Connect(function()
		UI["59"].Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" ..plr.UserId.. "&width=180&height=180&format=png"
		UI["5d"].Text = plr.DisplayName
		UI["5e"].Text = plr.Name
		selectedPlr = plr
	end)

	game.Players.PlayerRemoving:Connect(function(plr2)
		if plr2 == plr then
			connection:Disconnect()
			templ:Destroy()
			if selectedPlr  == plr2 then
				UI["59"].Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .."156".. "&width=180&height=180&format=png"
				UI["5d"].Text = "N/A"
				UI["5e"].Text = "N/A"
				selectedPlr = nil
			end
		end
	end)
end

function initUi()
	while ghostCharacter do
		wait()
	end
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	humanoid:SetAttribute("FlightSpeed", 5)
	speed = humanoid:GetAttribute("FlightSpeed")


	dragger = UI["5"]
	parent = dragger.Parent
	
	--DRAGGER

	local function update(input)
		local delta = input.Position - dragStart
		parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	dragger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = parent.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragger.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging then
				update(input)
			end
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging then
				update(input)
			end
		end
	end)
	
	
	--inits
	
	
	Types = {
		["KeyBinds"] = UI["119"]:Clone(),
	}

	Settings = {
		["Key Binds"] = {
			["Name"] = "Key Binds",
			["Type"] = Types.KeyBinds,
			["Trigger"] = function(self)
				for _, setting in pairs(self.Settings) do
					local settingFrame = setting.Template
					local settingBtn = settingFrame:FindFirstChildOfClass("TextButton")
					settingBtn.MouseButton1Click:Connect(function()
						userInputService.InputBegan:Once(function(input)
							if input.UserInputType == Enum.UserInputType.Keyboard then
								local isKeyUsed = false
								for _, otherSetting in pairs(self.Settings) do
									if otherSetting.Key == input.KeyCode then
										isKeyUsed = true
										break
									end
								end
								if isKeyUsed or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.W then
									warn("Dieser Key wird bereits in einer anderen Einstellung verwendet.")
								else
									setting.Key = input.KeyCode
									settingFrame:FindFirstChildOfClass("TextButton"):FindFirstChildOfClass("TextLabel").Text = input.KeyCode.Name
									cooldown = true
									task.wait(0.1)
									cooldown = false
								end
							end
						end)
					end)
				end
			end,
			["Reset"] = function(self)
				for _, otherSetting in pairs(self.Settings) do
					otherSetting.Key = DefaultKeys[tostring(otherSetting.Name)]
					otherSetting.Template:FindFirstChildOfClass("TextButton"):FindFirstChildOfClass("TextLabel").Text = DefaultKeys[tostring(otherSetting.Name)].Name
				end
			end,
			["Settings"] = {
				["FlightKey"] = {
					["Name"] = "FlightKey",
					["Description"] = "Change Flight State",
					["Key"] = Enum.KeyCode.X,
					["Custom"] = function(self)
						return self.Key ~= DefaultKeys.FlightKey
					end,
					["Template"] = Types.KeyBinds.Container.Settings.Setting:Clone(),
				},
				["SafeTeleportKey"] = {
					["Name"] = "SafeTeleportKey",
					["Description"] = "Teleport your Character for 0.1s in Ghost",
					["Key"] = Enum.KeyCode.N,
					["Custom"] = function(self)
						return self.Key ~= DefaultKeys.SafeTeleportKey
					end,
					["Template"] = Types.KeyBinds.Container.Settings.Setting:Clone(),
				},
				["OpenMenuKey"] = {
					["Name"] = "OpenMenuKey",
					["Description"] = "Open the menu with a Hotkey",
					["Key"] = Enum.KeyCode.K,
					["Custom"] = function(self)
						return self.Key ~= DefaultKeys.OpenMenuKey
					end,
					["Template"] = Types.KeyBinds.Container.Settings.Setting:Clone(),
				}
			}
		}
	}
	
	
	local SettingTypes = {
		["Switch"] = UI[""]
	}
	
	
	
	
	
	for _, setting in pairs(Settings) do
		local Template = setting.Type
		Template.Container.TopBar.Title.Text = setting.Name
		Template.Parent = UI["114"]

		Template.Container.TopBar.Reset.MouseButton1Click:Connect(function()
			setting:Reset()
		end)

		setting:Trigger()
		local TemplSetting = Template.Container.Settings.Setting

		for _, sting in pairs(Template.Container.Settings:GetChildren()) do
			if sting:IsA("Frame") then
				sting:Destroy()
			end
		end

		for _, setting2 in pairs(setting.Settings) do
			local Template2 = setting2.Template
			Template2.Parent = Template.Container.Settings
			Template2["Frame 13"].SettingName.Text = setting2.Description
			Template2["KeySelection"].Key.Text = setting2.Key.Name
		end
	end


	for _, settingSection in pairs(UI["114"]:GetChildren()) do
		if settingSection:IsA("Frame") and settingSection.Name ~= "Z" then
			settingSection.Container.TopBar.Drop.Rotation = 270
			settingSection.Container.TopBar.Drop.MouseButton1Click:Connect(function()
				if settingSection.AutomaticSize == Enum.AutomaticSize.None then
					settingSection.AutomaticSize = Enum.AutomaticSize.Y
					settingSection.Container.TopBar.Drop.Rotation = 0
				else
					settingSection.AutomaticSize = Enum.AutomaticSize.None
					settingSection.Container.TopBar.Drop.Rotation = 270
				end
			end)
		end
	end
	
	--BAR
	
	
	local function updateCharacterMod(slider)
		if game.Players.LocalPlayer.Character then
			local character = game.Players.LocalPlayer.Character
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				local Name = slider:FindFirstChildOfClass("NumberValue").Name
				local Value = MaxValues[slider:FindFirstChildOfClass("NumberValue").Name]
				if Name ~= "FlightSpeed" then
					humanoid[Name] = Value * slider.Size.X.Scale
				else
					humanoid:SetAttribute(Name, Value * slider.Size.X.Scale)
				end
			end
		end
	end
	
	
	local function setSlider(slider)
		local current
		if slider:FindFirstChildOfClass("NumberValue").Name ~= "FlightSpeed" then
			current = humanoid[slider:FindFirstChildOfClass("NumberValue").Name]
		else
			current = humanoid:GetAttribute(slider:FindFirstChildOfClass("NumberValue").Name)
		end
		local max = MaxValues[slider:FindFirstChildOfClass("NumberValue").Name]
		local percentage = current / max
		slider.Size = UDim2.new(percentage, 0, 1, 0)
		updateCharacterMod(slider)
	end


	local function updateTextBoxVal(slider)
		if slider.Parent.Parent:FindFirstChild("Frame TextButton"):FindFirstChild("x1i") then
			slider.Parent.Parent["Frame TextButton"]["x1i"].Text =  math.round(MaxValues[slider:FindFirstChildOfClass("NumberValue").Name] * slider.Size.X.Scale)
		end
	end
	
	
	local function createDraggableSliderForEachFrame()
		for _, slider in pairs(UI["1"]:GetDescendants()) do
			if slider.Name == "Frame 1" and slider:IsA("Frame") then
				local parentFrame = slider.Parent
				local dragging = false
				local dragStart, initialScale

				parentFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						dragStart = input.Position
						initialScale = slider.Size

						local mouse = game.Players.LocalPlayer:GetMouse()
						local relativeX = (mouse.X - parentFrame.AbsolutePosition.X) / parentFrame.AbsoluteSize.X
						relativeX = math.clamp(relativeX, 0, 1)
						slider.Size = UDim2.new(relativeX, 0, initialScale.Y.Scale, 0)
						updateTextBoxVal(slider)
						updateCharacterMod(slider)
					end
				end)

				userInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local mouse = game.Players.LocalPlayer:GetMouse()
						local relativeX = (mouse.X - parentFrame.AbsolutePosition.X) / parentFrame.AbsoluteSize.X
						relativeX = math.clamp(relativeX, 0, 1)
						slider.Size = UDim2.new(relativeX, 0, initialScale.Y.Scale, 0)
						updateTextBoxVal(slider)
						updateCharacterMod(slider)
					end
				end)

				parentFrame.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
			end
		end
	end

	createDraggableSliderForEachFrame()

	
	for _, value in pairs(UI["10"]:GetDescendants())  do
		if value:IsA("NumberValue") then
			if value.Name ~= "FlightSpeed" then
				value.Value = humanoid[value.Name]
			else
				value.Value = humanoid:GetAttribute(value.Name)
			end
		end
		if value.Name == "Frame 1" then
			setSlider(value)
			updateTextBoxVal(value)
		end
		if value.Name == "x1i" then
			value.FocusLost:Connect(function()
				value.Text = value.Text:gsub("[^0-9.]", "")
				if value.Text == "" then
					value.Text = value.Parent.Parent:FindFirstChild("Bar"):FindFirstChild("Frame 1"):FindFirstChildOfClass("NumberValue").Value
				end
				setHumanoid(value.Parent.Parent:FindFirstChild("Bar"):FindFirstChild("Frame 1"):FindFirstChildOfClass("NumberValue").Name, value.Text)
				setSlider(value.Parent.Parent:FindFirstChild("Bar"):FindFirstChild("Frame 1"))
			end)
		end
	end
	
	for _, btn in pairs(UI["3f"]:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.MouseButton1Click:Connect(function()
				if btn["Frame 3"].ImageColor3 == config.ButtonColor.On then
					btn["Frame 3"].ImageColor3 = Color3.new(1, 1, 1)
				else
					btn["Frame 3"].ImageColor3 = config.ButtonColor.On
				end
				if btn.Name == "1" then
					flying = not flying
					if flying then start() end
				elseif btn.Name == "2" then
					toggleNoClip()
				elseif btn.Name == "3" then
					healPlayer()
				elseif btn.Name == "4" then
					toggleGhostCharacter()
				end
			end)
		end
	end
	
	
	for _, plr in pairs(game.Players:GetChildren()) do
		if plr ~= player then
			addPlayer(plr)
		end
	end
	
	
	for _, btn in pairs(UI["60"]:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.MouseButton1Click:Connect(function()
				if selectedPlr then
					if btn.Name == "2" then
						teleportToPlayer(player, selectedPlr)
					elseif btn.Name == "1" then
						changeCameraSubject()
					end
				end
			end)
		end
	end

	
end

initUi()

local toggleKey = Settings["Key Binds"].Settings.FlightKey.Key


UI["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

userInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Settings["Key Binds"].Settings.OpenMenuKey.Key and not cooldown then
		UI["2"].Visible = not UI["2"].Visible
	end
end)

local function getTorso(char)
	if char then
		if char:FindFirstChild("LowerTorso") then
			return char.LowerTorso
		else
			return char.Torso
		end
	end
	if character:FindFirstChild("LowerTorso") then
		return character.LowerTorso
	else
		return character.Torso
	end
end

function addCore()
	if workspace:FindFirstChild("Core") then
		workspace.Core:Destroy()
	end

	local Core = Instance.new("Part")
	Core.Name = "Core"
	Core.CanCollide = false
	Core.Size = Vector3.new(0.05, 0.05, 0.05)

	spawn(function()
		Core.Parent = workspace
		Weld = Instance.new("Weld", Core)
		Weld.Part0 = Core
		Weld.Part1 = getTorso()

		Weld.C0 = CFrame.new(0, 0, 0)
	end)

	workspace:WaitForChild("Core")
	torso = workspace.Core
end

player.Character.Humanoid.Died:Connect(function()
	flying = false
	local is = false
	while not is do
		wait()
		if player.Character.Humanoid.Health > 0 then
			is = true
			UI = UI.init()
			initUi()
			addCore()
			UI["1"].Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
	end
end)

addCore()

torso = workspace.Core

function start()
	local pos = Instance.new("BodyPosition", torso)
	local gyro = Instance.new("BodyGyro", torso)
	pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
	pos.position = torso.Position
	gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	gyro.cframe = torso.CFrame
	UI["3f"]["1"]["Frame 3"].ImageColor3 = config.ButtonColor.On
	repeat
		wait()
		speed = humanoid:GetAttribute("FlightSpeed")
		EnableNoClip()
		local new = gyro.cframe - gyro.cframe.p + pos.position
		local direction = workspace.CurrentCamera.CoordinateFrame.lookVector
		if keys.w then new = new + direction * speed end
		if keys.s then new = new - direction * speed end
		if keys.d then new = new * CFrame.new(speed, 0, 0) end
		if keys.a then new = new * CFrame.new(-speed, 0, 0) end
		pos.position = new.p
		gyro.cframe = workspace.CurrentCamera.CoordinateFrame
	until not flying
	DisableNoClip()
	UI["3f"]["1"]["Frame 3"].ImageColor3 = Color3.new(1,1,1)
	if gyro then gyro:Destroy() end
	if pos then pos:Destroy() end
	flying = false
end


local function getUpperTorso(char)
	if character:FindFirstChild("UpperTorso") then
		return char.UpperTorso
	else
		return char.Torso
	end
end


function teleportToPlayer(player, player2)
	if player2.Character.HumanoidRootPart then
		character.HumanoidRootPart.CFrame = player2.Character.HumanoidRootPart.CFrame 
	else
		character.HumanoidRootPart.CFrame = getUpperTorso(player2.Character).CFrame 
	end
end

function changeCameraSubject(SubjectCharacter)
	cam.CameraType = Enum.CameraType.Custom
	if SubjectCharacter then
		cam.CameraSubject = SubjectCharacter.Humanoid
	else
		if selectedPlr then
			if cam.CameraSubject == selectedPlr.Character.Humanoid then
				cam.CameraSubject = player.Character.Humanoid
			else	
				cam.CameraSubject = selectedPlr.Character.Humanoid
			end
		else
			cam.CameraSubject = player.Character.Humanoid
		end
	end
end


function healPlayer()
	character.Humanoid.Health = character.Humanoid.MaxHealth
end


local isNoClip = false

local function createGhostCharacter()
	-- Erstelle ein neues Modell für den Klon
	local clone = Instance.new("Model")
	clone.Name = "ClonedCharacter"

	-- Kopiere alle Teile und Komponenten des Charakters
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") or part:IsA("Accessory") or part:IsA("Humanoid") or part:IsA("Shirt") or part:IsA("Pants") then
			local partClone = part:Clone()
			partClone.Parent = clone
		end
	end

	-- Setze die Transparenz und Kollisionseigenschaften des Klons
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 0.2
			if part.Name == "HumanoidRootPart" then
				part.Transparency = 1
			end
			part.CanCollide = false
		elseif part:IsA("Humanoid") then
			part.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end

	-- Setze die Position des Klons auf die Mitte des Workspaces
	local offset = character.PrimaryPart.CFrame.LookVector * 3
	local newCFrame = character.PrimaryPart.CFrame + offset
	local primaryPart = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		primaryPart.CFrame = newCFrame
	else
		warn("Der Klon hat keinen HumanoidRootPart oder BasePart.")
	end

	-- Elternteil des Klons auf Workspace setzen
	clone.Parent = workspace

	-- Fixe mögliche Welds, Joints und Motor6Ds
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("Weld") or part:IsA("JointInstance") or part:IsA("Motor6D") then
			part:Destroy()
		end
	end

	return clone
end

local function shortTpPlayer(character, char)
	cooldown = true
	local start = character.HumanoidRootPart.CFrame
	character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
	wait(0.1)
	character.HumanoidRootPart.CFrame = start
	cooldown = false
end

local WalkSpeedalt = 16

local function DisableMovement()
	if success and result then
		result:Disable()
	else
		WalkSpeedalt = player.Character.Humanoid.WalkSpeed
		player.Character.Humanoid.WalkSpeed = 0
	end
end

local function EnableMovement()
	if success and result then
		result:Enable()
	else
		player.Character.Humanoid.WalkSpeed = WalkSpeedalt
	end
end

EnableMovement()

local connection

function toggleGhostCharacter()
	print(ghostCharacter)
	if ghostCharacter then
		connection:Disconnect()
		if player.Character.PrimaryPart then
			player.Character:SetPrimaryPartCFrame(ghostCharacter.HumanoidRootPart.CFrame)
			ghostCharacter:Destroy()
			ghostCharacter = nil
			print("JET")
			changeCameraSubject(player.Character)
			character = player.Character
			Weld.Part1 = getTorso()
			if isNoClip then
				EnableNoClip()
			end
			EnableMovement()
		else
			ghostCharacter:Destroy()
			ghostCharacter = nil
		end
		return
	end
	local wasflying = false
	if flying then
		wasflying = true
		flying = false
		start()
	end
	ghostCharacter = createGhostCharacter()
	character = ghostCharacter
	Weld.Part1 = getTorso()

	if isNoClip then
		EnableNoClip()
	end

	local humanoid = ghostCharacter:FindFirstChildWhichIsA("Humanoid")
	DisableMovement()

	local function onRenderStep()
		print("YOUR")
		changeCameraSubject(ghostCharacter)
		local moveDirection = Vector3.new()
		if userInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + cam.CFrame.LookVector
		end
		if userInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - cam.CFrame.LookVector
		end
		if userInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - cam.CFrame.RightVector
		end
		if userInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + cam.CFrame.RightVector
		end
		if userInputService:IsKeyDown(Enum.KeyCode.Space) then
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
		moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z) -- Normalisiere die Richtung und ignoriere Y-Achse
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit -- Normalisiere die Richtung
			humanoid:Move(moveDirection, false)
		else
			humanoid:Move(Vector3.new(0, 0, 0), false) -- Stoppt die Bewegung
		end
	end

	userInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Settings["Key Binds"].Settings.SafeTeleportKey.Key and not cooldown then
			shortTpPlayer(player.Character, ghostCharacter)
		end
	end)

	-- Verbindung zu RenderStep herstellen
	connection = runService.RenderStepped:Connect(onRenderStep)

	-- Behandle das Sterben des neuen Charakters
	humanoid.Died:Connect(function()
		toggleGhostCharacter()
	end)

	player.Character.Humanoid.Died:Connect(function()
		toggleGhostCharacter()
	end)

	if wasflying then
		flying = true
		start()
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	addPlayer(plr)
end)


function setHumanoid(Name, Value)
	if Name ~= "FlightSpeed" then
		humanoid[Name] = Value
	else
		humanoid:SetAttribute(Name, Value)
	end
end


function EnableNoClip()
	character.HumanoidRootPart.CanCollide = false
	getTorso().CanCollide = false
	getUpperTorso(character).CanCollide = false
	isNoClip = true
end

humanoid.Jumping:Connect(function(isJumping)
	if isNoClip then
		EnableNoClip()
	end
end)

function DisableNoClip(char)
	if char then
		char.HumanoidRootPart.CanCollide = true
		getTorso(char).CanCollide = true
		getUpperTorso(char).CanCollide = true
	else
		character.HumanoidRootPart.CanCollide = true
		getTorso().CanCollide = true
		getUpperTorso(character).CanCollide = true
	end
	isNoClip = false
end


function toggleNoClip()
	if not isNoClip then
		EnableNoClip()
	else
		DisableNoClip()
	end
end

player:GetMouse().KeyDown:connect(function(key)
	if not torso or not torso.Parent then
		flying = false
		return
	end
	
	toggleKey = Settings["Key Binds"].Settings.FlightKey.Key
	if key == toggleKey.Name:lower() then
		flying = not flying
		if flying then start() end
	end
	keys[key] = true
end)

player:GetMouse().KeyUp:connect(function(key)
	keys[key] = false
end)

if flying then start() end
