-- things to do
-- fix ball shoot
-- make moving attacking mobs
--levels
-- upgrades


--[[
Local Side Script
Created by JEFF666mmmmmmm
--]]

-- Services
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RStorage = game:GetService("ReplicatedStorage").remoteEvents

-- Pointer Events
local SendEvent = RStorage:WaitForChild("remoteEventSendToServer")
local AskEvent = RStorage:WaitForChild("AskServerFunction")
local ReciveEvent = RStorage:WaitForChild("remoteEventSendToClient")
local newRotationEvent = RStorage:WaitForChild("newRotationToClient")
local newMoveEvent = RStorage:WaitForChild("newMoveToClient")
local newObjectEvent = RStorage:WaitForChild("newObjectToClient")
local newRemoveEvent = RStorage:WaitForChild("newRemoveToClient")

-- Pointers
local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
local Mouse = LocalPlayer:GetMouse()

-- Gui Pointers
local gui = LocalPlayer.PlayerGui
local guiGameFrame = gui:WaitForChild("ScreenGui").Frame
local ThisUserGui = guiGameFrame:WaitForChild("playerFrame")
local guiPlayerDead = gui.ScreenGui.deadFrame
local turret = ThisUserGui.Turret

local RefObjects = gui:WaitForChild("referenceObjects")
local RefSounds = gui:WaitForChild("referenceSounds")

local guiObjectHealth = gui.ScreenGui.bottomInfoDisplay.playerHeathGui.background.health
local guiObjectHealthMaxSize = guiObjectHealth.AbsoluteSize.X
local guiObjectCurrentHealth = 0
local guiObjectCurrentHealthMax = 0
local guiObjectHealthOld = 0
local guiObjectHealthRegen = 0

local roamObjects = guiGameFrame.gameFrame.roamingObjects
local gameExtras = guiGameFrame.gameFrame.gameExtras
local guiFrame = gui.StartGui.Frame
local playButton = guiFrame.playButton.Button
local endButton = gui.ScreenGui.deadFrame.Frame.Frame.okDiedButton
local displayNameButton = guiFrame.playerName.Frame.Button

-- Player Refernce Data For Later
local playerQuad = 1

local playerPositionX = 0
local playerPositionY = 0
local playerPosition = Vector2.new(playerPositionX, playerPositionY)

local playerSpeed = 0
local playerMoveingTo = {W = false, S = false, A = false, D = false}
local playerMouseHold = false
local inGame = false
local watchKiller = false
local watchKillerid = {}
local moveByServerQuest = {W = false, S = false, A = false, D = false}

-- Max Game Boundries
local minY = 0
local maxY = 1
local minX = 0
local maxX = 1

local gameEntitys = {


}

local movingData = {


}

local lockedData = {


} 


local defaultPlayerInfo = {}

-- Stop Physical Player Movement
Controls:Disable()



-- Update Information From Server
local displayBoolen: BoolValue, nameText: StringValue, displayNameText: StringValue, maxGameBounds: NumberValue, lineColor:Color3Value, bGroundColor:Color3Value, waterColor:Color3Value = AskEvent:InvokeServer("getPlayerInformation")

guiGameFrame.gameFrame.Size = UDim2.new(0, maxGameBounds, 0 , maxGameBounds)
guiGameFrame.gameFrame.BackgroundColor3 = bGroundColor
guiGameFrame.BackgroundColor3 = waterColor

-- Load Background
local function loadMapBackground()

	local thickness = 5
	local lineSpace = 45
	local length = 0
	local count = 0
	local r = maxGameBounds/2

	repeat

		count += lineSpace
		local line = Instance.new("Frame")
		line.Parent = guiGameFrame.gameFrame.lineFrame
		line.BackgroundColor3 = lineColor
		local d = r-count
		d *= d
		length = 2*math.sqrt((r*r)-d)
		line.Size = UDim2.new(0, thickness, 0, length)
		line.Position = UDim2.new(0, count, 0, r - length/2)
		line.BorderSizePixel = 0
		count += thickness

	until count >= maxGameBounds

	count = 0

	repeat

		count += lineSpace
		local line = Instance.new("Frame")
		line.Parent = guiGameFrame.gameFrame.lineFrame
		line.BackgroundColor3 = lineColor

		local d = r-count
		d *= d
		length = 2*math.sqrt((r*r)-d)
		line.Size = UDim2.new(0, length, 0, thickness)
		line.Position = UDim2.new(0, r - length/2, 0, count)
		line.BorderSizePixel = 0
		count += thickness

	until count >= maxGameBounds

end
loadMapBackground()

if displayBoolen == true then
	displayNameButton.Text = ("X")
else
	displayNameButton.Text = ("")
end

if displayNameText ~= "{nil}" then
	displayNameButton.Parent.TextLabel.Text = (displayNameText)
else
	guiFrame.playerName.Frame.Visible = false
end

-- Move A 2d Gui Object
local function moveObject(object: ObjectValue, goal: UDim2, timeLength: NumberValue, stopOldTween: boolean)

	object:TweenPosition(
		goal,
		Enum.EasingDirection.In,
		Enum.EasingStyle.Linear,
		timeLength,
		stopOldTween
	)
end

-- Move A Players Turret
local function moveTurret(object: ObjectValue, goal: IntValue, rotationStart: IntValue)

	if goal > rotationStart then
		for count = rotationStart, goal, 2 do task.wait(0.03)
			object.Rotation = object.Rotation + 2
		end
	else
		for count = rotationStart, goal, -2 do task.wait(0.03)
			object.Rotation = object.Rotation - 2
		end
	end

end

local function removeObject(id: StringValue, oType: StringValue)
	if oType == "ball" then

		local find = roamObjects:FindFirstChild(id)
		if find then

			find:TweenSize(
				UDim2.new(0, 0, 0, 0),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Linear,
				0.3
			)
			task.wait(0.3)
			find:Destroy()
		end
	end

	if oType == "entity" then

		local find = roamObjects:FindFirstChild(id)
		if find then
			if gameEntitys[id].tank ~= "LandMine" then
			find.player.BackgroundColor3 = Color3.fromRGB(122, 36, 36)
			find.player.player.BackgroundColor3 = Color3.fromRGB(255, 41, 41)
			find.Turret.Turret.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			find:TweenSize(
				UDim2.new(0, 0, 0, 0),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Linear,
				0.3
			)
			task.wait(0.3)
				find:Destroy()
			else
				find:Destroy()
				local clone = RefSounds.bomb1:Clone()
				clone.Parent = gameExtras
				clone.PlaybackSpeed = (1 + (math.random(0, 5)/10))
				clone.Volume = (0.5)
				clone:Play()
				
				local clone2 = RefObjects.land_mine_explosion:Clone()
				clone2.Parent = gameExtras
				clone2.Position = UDim2.new(0, gameEntitys[id].position.X, 0, gameEntitys[id].position.Y) 
				clone2:TweenSize(
					UDim2.new(0, 200, 0, 200),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Back,
					0.2
				)
				task.wait(0.22)
				clone2:Destroy()
				task.wait(0.28)
				clone:Destroy()
				gameEntitys[id]["dead"] = true
				gameEntitys[id] = nil
			end
		end
	end

end

-- Create A New 2d Object
local function createNewObject(oType: StringValue, location: Vector2, movingTo: Vector2, speed: NumberValue, rotation: IntValue, name: StringValue, id: StringValue, tankType: StringValue)

	-- Create Ball Object
	if oType == "ball" then
		local ball = RefObjects.ball:Clone()
		ball.Name = ("B"..math.random(0, 9999))
		ball.Position = UDim2.new(0, location.X, 0, location.Y)
		ball.Parent = roamObjects
		ball.Rotation = turret.Rotation

		if speed > 0 then
			moveObject(ball, UDim2.new(0, location.X + ball.Rotation, 0, location.Y + ball.Rotation), 2, true)
		end
		task.wait(2)
		removeObject(ball.Name, "ball")
	end
	-- Create A New Entity
	if oType == "entity" then
		local person = RefObjects[tankType]:Clone()
		person.Name = id
		person.Position = UDim2.new(0, location.X, 0, location.Y)
		person.Parent = roamObjects
		
		if tankType == "Tank" then
			person.Turret.Rotation = rotation
			person.player.textName.Text = name
		end
		
		if speed > 0 then
			moveObject(person, UDim2.new(0, movingTo.X, 0, movingTo.Y), speed * 2, true)
		end
		
	end

end

-- User Left Clicks
Mouse.Button1Down:Connect(function()
	if inGame == true then
		playerMouseHold = true

		while playerMouseHold == true do
			createNewObject("ball", playerPosition + (turret.Turret.ballSpawn.AbsolutePosition - (guiGameFrame.AbsoluteSize/2)), nil, 20)
			task.wait(0.5)
		end
	end
end)

-- End Click
Mouse.Button1Up:Connect(function()

	playerMouseHold = false

end)

-- Update Information To Server
local function updateToSever()

	SendEvent:FireServer("update", playerMoveingTo, turret.Rotation)

end

-- Max Allowed player Bounds
local function getNewMaxBounds()
	minY = 0 + ThisUserGui.player.player.AbsoluteSize.Y/2
	maxY = guiGameFrame.gameFrame.AbsoluteSize.Y - ThisUserGui.player.player.AbsoluteSize.Y/2

	minX = 0 + ThisUserGui.player.player.AbsoluteSize.X/2
	maxX = guiGameFrame.gameFrame.AbsoluteSize.X - ThisUserGui.player.player.AbsoluteSize.X/2
	
end

getNewMaxBounds()

-- Position Map
local function onChanged(id, X, Y)
	local find = gui.ScreenGui.positionCounter.mapItems:FindFirstChild(id)
	if find then
		find.Position = UDim2.new(0, 120/maxX*(X),0, 120/maxY*(Y))
	end
end

-- User Uses Keyboard
UserInput.InputBegan:Connect(function(key: InputObject, gameProcessed:boolean)
	if gameProcessed or inGame == false then return end

	if (key.KeyCode == Enum.KeyCode.W) then
		playerMoveingTo.W = true
		updateToSever()
		while UserInput:IsKeyDown(Enum.KeyCode.W) do task.wait(0.03)
			if not moveByServerQuest.W then
				playerPositionY = math.clamp(playerPosition.Y -(playerSpeed/2), minY, maxY)
				playerPosition = Vector2.new(playerPositionX, playerPositionY)
				guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
			end
		end
		playerMoveingTo.W = false
		updateToSever()
	end

	if (key.KeyCode == Enum.KeyCode.S) then
		playerMoveingTo.S = true
		updateToSever()
		while UserInput:IsKeyDown(Enum.KeyCode.S) do task.wait(0.03)
			if not moveByServerQuest.S then
				playerPositionY = math.clamp(playerPosition.Y +(playerSpeed/2), minY, maxY)
				playerPosition = Vector2.new(playerPositionX, playerPositionY)
				guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
			end
		end
		playerMoveingTo.S = false
		updateToSever()
	end

	if (key.KeyCode == Enum.KeyCode.A) then
		playerMoveingTo.A = true
		updateToSever()
		while UserInput:IsKeyDown(Enum.KeyCode.A) do task.wait(0.03)
			if not moveByServerQuest.A then
				playerPositionX = math.clamp(playerPosition.X -(playerSpeed/2), minX, maxX)
				playerPosition = Vector2.new(playerPositionX, playerPositionY)
				guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
			end
		end
		playerMoveingTo.A = false
		updateToSever()
	end

	if (key.KeyCode == Enum.KeyCode.D) then
		playerMoveingTo.D = true
		updateToSever()
		while UserInput:IsKeyDown(Enum.KeyCode.D) do task.wait(0.03)
			if not moveByServerQuest.D then
				playerPositionX = math.clamp(playerPosition.X +(playerSpeed/2), minX, maxX)
				playerPosition = Vector2.new(playerPositionX, playerPositionY)
				guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
			end		
		end
		playerMoveingTo.D = false
		updateToSever()
	end


end)

-- Request To Rotate An Object
local function onGetRequestRotation(id: StringValue, dataType: StringValue, rotation: IntValue)

	if dataType == "entity" then
		
			moveTurret(roamObjects[id].Turret, rotation, roamObjects[id].Turret.Rotation)
	
	end

end
newRotationEvent.OnClientEvent:Connect(onGetRequestRotation)

-- Request To Move An Object
local function onGetRequestMove(id: StringValue, dataType: StringValue, posTo: Vector2, moveW: boolean, moveS: boolean, moveA: boolean, moveD: boolean)

	if dataType == "entity" and id ~= LocalPlayer.UserId then
		local find = false
		
		for i, o in pairs(gameEntitys) do
		if o.id == id then find = true end
		end
		if find then
			onChanged(id, posTo.X, posTo.Y)
			moveObject(roamObjects[id], UDim2.new(0, posTo.X, 0, posTo.Y), 0.5, false)

		end
	end
	
	if id == LocalPlayer.UserId then
		onChanged(id, posTo.X, posTo.Y)
		
		playerPositionY = posTo.Y
		playerPositionX = posTo.X
		playerPosition = posTo
		local makeMove = false
		local diff = Vector2.new(math.round(playerPositionX-posTo.X), math.round(playerPositionY-posTo.Y))
		if diff.X > 40 or diff.Y > 40 then
			makeMove = true
		end
		
		moveByServerQuest = {W = moveW, S = moveS, A = moveA, D = moveD}
		
		if (not moveW and not moveS and not moveA and not moveD) or makeMove and inGame then
			guiGameFrame.gameFrame:TweenPosition(
				UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y+ guiGameFrame.AbsoluteSize.Y/2),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Linear,
				0.2,
				false
			)
		end
		
		
	end
	
end
newMoveEvent.OnClientEvent:Connect(onGetRequestMove)

-- Request To Create An Object
local function onGetRequestCreate(id: StringValue, dataType: StringValue, object: Player_Array)

	if dataType == "entity" then
		local find = false

		for i, o in pairs(gameEntitys) do
			if o.id == id then find = true end
		end

		if not find and id ~= LocalPlayer.UserId then

			createNewObject("entity", object[1], object[1], 0, object[13], object[4], object[5], object[7])

			gameEntitys[id] = {defaultPlayerInfo}
			local user = gameEntitys[id]
			--position, quad, radius, displayName, id, speed, tank, health, maxHealth, healthregen, bodyDamage, bodyBounce, rotation, movingTo
			user["position"] = object[1]
			user["quad"] = object[2]
			user["radius"] = object[3]
			user["displayName"] = object[4]
			user["id"] = object[5]
			user["speed"] = object[6]
			user["tank"] = object[7]
			user["health"] = object[8]
			user["maxHealth"] = object[9]
			user["healthRegen"] = object[10]
			user["bodyDamage"] = object[11]
			user["bodyBounce"] = object[12]
			user["rotation"] = object[13]
			user["movingTo"] = object[14]
			user["dead"] = false
			user["lastCPUupdate"] = os.clock()
			
			local clone = RefObjects.defaultMapCircle:Clone()
			clone.Parent = gui.ScreenGui.positionCounter.mapItems
			clone.Name = id
			clone.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
			onChanged(id, object[1].X, object[1].Y)
			
		elseif not find and id == LocalPlayer.UserId then
			
			guiObjectHealthRegen = object[10]
			guiObjectCurrentHealthMax = object[9]
			guiObjectCurrentHealth = object[8]
			
			local clone = RefObjects.defaultMapCircle:Clone()
			clone.Parent = gui.ScreenGui.positionCounter.mapItems
			clone.Name = id
			onChanged(id, object[1].X, object[1].Y)
			
		end
	end

end
newObjectEvent.OnClientEvent:Connect(onGetRequestCreate)

-- Request To Destroy An Object
local function onGetRequestRemove(id: StringValue, dataType: StringValue, killerid: StringValue)

	if dataType == "entity" then

		if id ~= LocalPlayer.UserId then

			local find = false

			for i, o in pairs(gameEntitys) do
				if o.id == id then find = true end
			end
			if find then
				removeObject(id, "entity")
				gui.ScreenGui.positionCounter.mapItems[id]:Destroy()
			end

		else
			inGame = false

			guiPlayerDead.Visible = true
			guiGameFrame.playerFrame.Visible = false
			
			local Info = gameEntitys[killerid]

			if Info then

				watchKillerid = {
					dead = false,
					KillerInfo = killerid
				}

				watchKiller = true
			end
			
		end
	end

end
newRemoveEvent.OnClientEvent:Connect(onGetRequestRemove)


-- BLOCK HEALTH GUI
local function updateHealth(health: NumberValue, max: NumberValue)

	if health < 0 then 
		health = 0
	end

	-- Update Gui
	guiObjectHealth.Size = UDim2.new(0, guiObjectHealthOld/max * guiObjectHealthMaxSize, 1, 0)

	-- TWEEN HEALTH
	local Tween = guiObjectHealth:TweenSize(
		UDim2.new(0, (health/max * guiObjectHealthMaxSize), 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.7,
		true 
	)

	-- End
	guiObjectHealth.Parent.Parent.number.Text = (health.."/"..max)

	guiObjectHealthOld = health

end

-- Start Game
local function onPlayButtonActivated()
	watchKiller = false
	gui.StartGui.Enabled = false
	guiGameFrame.playerFrame.Visible = true
	gui.ScreenGui.positionCounter.Visible = true
	gui.ScreenGui.bottomInfoDisplay.Visible = true
	
	local find = gui.ScreenGui.positionCounter.mapItems:FindFirstChild(LocalPlayer.UserId)
	if find then
		find:Destroy()
	end
	
	local canJoin: BoolValue, joinpos: Vector2, health: IntValue, maxhealth: IntValue, display: StringValue, speed: IntValue, tank: StringValue = AskEvent:InvokeServer("addPlayerInformation")
	
	if canJoin == true then
		
		
		playerSpeed = speed
		
		playerPositionX = joinpos.X
		playerPositionY = joinpos.Y
		playerPosition = Vector2.new(playerPositionX, playerPositionY)
		guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y+ guiGameFrame.AbsoluteSize.Y/2)
		
		updateHealth(health, maxhealth)
		
		-- Update current user turret rotation function
		local rotateTurretFunction = Mouse.Move:Connect(function()

			local frameCenter = turret.AbsolutePosition
			local x = math.atan2(Mouse.Y - frameCenter.Y, Mouse.X - frameCenter.X)
			turret.Rotation = math.deg(x)
		end)

		
		inGame = true

	else
		warn("Denied game entry")
	end
	--task.wait(5)
	--gameEntitys = {}
	--guiGameFrame.gameFrame.roamingObjects:ClearAllChildren()
	--gui.ScreenGui.positionCounter.mapItems:ClearAllChildren()
	--task.wait(5)
	--local num = AskEvent:InvokeServer("loadEntitys")
	--print (num)
	
end
playButton.Activated:Connect(onPlayButtonActivated)

local function onDisplayName()

	displayBoolen = not displayBoolen

	if displayBoolen == true then
		displayNameButton.Text = ("X")
	else
		displayNameButton.Text = ("")
	end
end
displayNameButton.Activated:Connect(onDisplayName)

local function onEndButtonActivated()
	gui.StartGui.Enabled = true
	guiGameFrame.playerFrame.Visible = false
	gui.ScreenGui.positionCounter.Visible = false
	gui.ScreenGui.bottomInfoDisplay.Visible = false
	
	guiPlayerDead.Visible = false
	

end
endButton.Activated:Connect(onEndButtonActivated)

local dayTable = {}

local dayTable = AskEvent:InvokeServer("getDayInformation")

local function updateDaySlider(object: ObjectValue, info: IntValue, weekDay: StringValue)
	local changed = false
	object.inside.label.Text = weekDay
	if (info > -1 and info < 75) or (info > 345 and info < 366) then
		guiFrame.dayFrame.seasonLabel.Text = "Winter"
		guiFrame.dayFrame.seasonLabel.TextColor = Color3.fromRGB(138, 218, 255)
		object.inside.BackgroundColor3 = Color3.fromRGB(146, 174, 180)
		
		if info == 358 or info == 359 or info == 360 then
			changed = true
			object.inside.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
		
	end
	
	if info > 75 and info < 165 then
		guiFrame.dayFrame.seasonLabel.Text = "Spring"
		guiFrame.dayFrame.seasonLabel.TextColor = Color3.fromRGB(26, 255, 0)
		object.inside.BackgroundColor3 = Color3.fromRGB(96, 234, 32)

	end
	
	if info > 165 and info < 255 then
		guiFrame.dayFrame.seasonLabel.Text = "Summer"
		guiFrame.dayFrame.seasonLabel.TextColor = Color3.fromRGB(14, 122, 0)
		object.inside.BackgroundColor3 = Color3.fromRGB(12, 165, 1)

	end
	
	if info > 255 and info < 345 then
		guiFrame.dayFrame.seasonLabel.Text = "Fall"
		guiFrame.dayFrame.seasonLabel.TextColor3 = Color3.fromRGB(255, 137, 2)
		object.inside.BackgroundColor3 = Color3.fromRGB(208, 121, 0)
		
		if info == 303 or info == 304 or info == 305 then
			changed = true
			object.inside.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
		end
		
		
	end
	
	if changed == false then
		if weekDay == "Sat" then
			object.inside.BackgroundColor3 = Color3.fromRGB(0, 185, 213)
			object.inside.label.Text = "Quick"
			object.inside.label.TextColor3 = Color3.fromRGB(255, 0, 209)
		end
	end
end

local ima = guiFrame.dayFrame

for i = 0, 4, 1 do

	updateDaySlider(ima["day"..i], tonumber(dayTable["d"..(i)]), dayTable["w"..(i)])

	ima["day"..i].MouseEnter:Connect(function()

		ima["day"..i].inside:TweenSize(
			UDim2.new(1, 3, 1, 3),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Linear,
			0.3,
			true
		)


	end)

	ima["day"..i].MouseLeave:Connect(function()

		ima["day"..i].inside:TweenSize(
			UDim2.new(1, -6, 1, -6),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Linear,
			0.15,
			true
		)
	end)


end

-- Recive a request from the server
local function onGetRequest(request: StringValue, id: StringValue, info, info2)

	if request == "health" and id == LocalPlayer.UserId then

		updateHealth(info, info2)
		guiObjectCurrentHealth = info
		guiObjectCurrentHealthMax = info2
	end

end
ReciveEvent.OnClientEvent:Connect(onGetRequest)

local loop count = 0
while true do task.wait(0.03)
	if inGame then
		onChanged(LocalPlayer.UserId, playerPositionX, playerPositionY)
		count += 1
		if count == 3 then
			count = 0
			guiObjectCurrentHealth = guiObjectCurrentHealth + guiObjectHealthRegen
			if guiObjectCurrentHealth > guiObjectCurrentHealthMax then
				guiObjectCurrentHealth = guiObjectCurrentHealthMax
			end
			updateHealth(guiObjectCurrentHealth, guiObjectCurrentHealthMax)
		end
		if moveByServerQuest.W then

			playerPositionY = math.clamp(playerPosition.Y -playerSpeed, minY, maxY)
			playerPosition = Vector2.new(playerPositionX, playerPositionY)
			guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
		end

		if moveByServerQuest.S then

			playerPositionY = math.clamp(playerPosition.Y +playerSpeed, minY, maxY)
			playerPosition = Vector2.new(playerPositionX, playerPositionY)
			guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
		end

		if moveByServerQuest.A then
			playerPositionX = math.clamp(playerPosition.X -playerSpeed, minX, maxX)
			playerPosition = Vector2.new(playerPositionX, playerPositionY)
			guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
		end

		if moveByServerQuest.D then
			playerPositionX = math.clamp(playerPosition.X +playerSpeed, minX, maxX)
			playerPosition = Vector2.new(playerPositionX, playerPositionY)
			guiGameFrame.gameFrame.Position = UDim2.new(0, -playerPosition.X + guiGameFrame.AbsoluteSize.X/2, 0, -playerPosition.Y + guiGameFrame.AbsoluteSize.Y/2)
		end
		
	elseif watchKiller then
		if roamObjects:FindFirstChild(watchKillerid.KillerInfo) then

			guiGameFrame.gameFrame.Position = UDim2.new(0, -roamObjects[watchKillerid.KillerInfo].Position.X.Offset + guiGameFrame.AbsoluteSize.X/2, 0, -roamObjects[watchKillerid.KillerInfo].Position.Y.Offset + guiGameFrame.AbsoluteSize.Y/2)
			task.wait(0.1)
		else
			watchKiller = false
		end

	end

end
