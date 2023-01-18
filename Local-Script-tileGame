-- things to do
-- ENCODER FOR GAME MAP

--[[
Local Side Script
Created by JEFF666mmmmmmm
--]]

-- Services
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RStorage = game:GetService("ReplicatedStorage").remoteEvents


local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
local Mouse = LocalPlayer:GetMouse()

-- Gui Pointers
local gui = LocalPlayer.PlayerGui
local backgroundGui = gui:WaitForChild("userScreen").Frame
local guiGameFrame = backgroundGui.gameFrame
local thisPlayer = guiGameFrame.playerFrame

local RefObjects = gui.userScreen.reservedData
local RefSounds = gui.userScreen.reservedSounds

local ReservedRef = gui.userScreen.reservedReference


-- Player Refernce Data For Later
local playerQuad = 1

local playerPositionX = 160
local playerPositionY = 160

local defaultSpeed = 6
local additonalSpeed = 0
local playerSpeed = defaultSpeed + additonalSpeed

local playerMouseHold = false
local inGame = true

local mainMapString = "a1D006c1EED002c1"


local gameEntitys = {


}

local movingData = {


}

local lockedData = {


} 


local defaultPlayerInfo = {}

-- Changeable for size
local quadPerRow = 50
local posInQuadRate = 50

-- Precalucation
local maxGameSize = quadPerRow * posInQuadRate
local sizePerQuad = maxGameSize/(quadPerRow)

-- Stop Physical Player Movement
Controls:Disable()

local function loadMap(givenMapID)

	guiGameFrame.gameItems:ClearAllChildren()

	local countX = 0
	local countY = 0
	local lastTile = ""
	local letter = ""
	local didletter = false
	local findLength = false

	for v in givenMapID:gmatch(".") do

		if findLength then
			letter = letter..v

			if #letter == 4 then
				local length = string.split(letter, "D")

				for i = 1, length[2] do
					if lastTile ~= "EE" then
						
						local clone = RefObjects:FindFirstChild(lastTile)
						if not clone then
							clone = RefObjects.a0
						end
						
						local clone = clone.tile:Clone()
						clone.Parent = guiGameFrame.gameItems
						clone.Name = ("U"..(countY + quadPerRow - (quadPerRow - countX ))+1)
						clone.Position = UDim2.new(0, countX * posInQuadRate, 0,  countY)

					end	

					countX += 1

					if countX == quadPerRow then
						countX = 0
						countY += quadPerRow
					end
				end
				didletter = false
				findLength = false
			end
			continue
		end

		if didletter == false then
			if v == "D" then

				letter = v
				findLength = true
			end
			didletter = true
			letter = v

		else
			lastTile = (letter..v)
			if (letter..v) ~= "EE" then
				
				local clone = RefObjects:FindFirstChild(letter..v)
				if not clone then
					clone = RefObjects.a0
				end
				
				local clone = clone.tile:Clone()
				clone.Parent = guiGameFrame.gameItems
				clone.Name = ("U"..(countY + quadPerRow - (quadPerRow - countX))+1)
				clone.Position = UDim2.new(0, countX * posInQuadRate, 0,  countY)

			end
			countX += 1
			if countX == quadPerRow then 
				countX = 0
				countY += quadPerRow
			end
			didletter = false
		end

	end

end

loadMap(mainMapString)
task.wait(2)

local mapString = ""
local mapitems = script.Parent.userScreen.Frame.gameFrame.gameItems:GetChildren()
local lastItem = ""
local lastItemPosition = 0
local itemCount = 0


for i = 1, #mapitems do

	local newId = mapitems[i]:GetAttribute("typeOfTile")
	local tileNumber = string.split(mapitems[i].Name, "U")
	tileNumer = tonumber(tileNumber[2])


	if newId == lastItem and i ~= #mapitems and lastItemPosition == tileNumer -1 then
		itemCount += 1
		lastItemPosition = tileNumer
	else

		if (tileNumer - lastItemPosition > 1) then
			mapString = mapString.."EE"
			
			if (tileNumer - lastItemPosition > 2) then
				if tileNumer - lastItemPosition < 9 then
					mapString = mapString.."D00"..(tileNumer - lastItemPosition)-2
				else
					if tileNumer - lastItemPosition < 99 then
						mapString = mapString.."D"..(tileNumer - lastItemPosition)-2
					else
						mapString = mapString.."D0"..(tileNumer - lastItemPosition)-2
					end
				end
			end

		end
		
		
		if itemCount > 0 then
			if itemCount < 9 then
				mapString = mapString.."D00"..itemCount
			else
				if itemCount < 99 then
					mapString = mapString.."D0"..itemCount
				else
					mapString = mapString.."D00"..itemCount
				end
			end

		end
		
		itemCount = 0
		if (lastItem ~= newId) or (lastItem == newId and lastItemPosition ~= tileNumer -1) then
			mapString = mapString..newId
		end
		lastItemPosition = tileNumer
		lastItem = newId

	end


end

print (mapString)
print (mainMapString)

print (mapString == mainMapString)


-- Get Objects position within quad with given X Y
local function positionToQuad(X, Y)
	-- X and Y must be more than 0 and less than max game size
	return((math.floor(Y/posInQuadRate)+1)*quadPerRow-(quadPerRow-(math.floor(X/posInQuadRate)+1)))
end

playerQuad = positionToQuad(playerPositionX, playerPositionY)


local function updateScreenFromMove(side)
	
	-- if player stops moving but other keys may be still pressed, with no side given
	if side == nil then
		if UserInput:IsKeyDown(Enum.KeyCode.W) then
			updateScreenFromMove("U")
		end
		if UserInput:IsKeyDown(Enum.KeyCode.S) then
			updateScreenFromMove("F")
		end
		if UserInput:IsKeyDown(Enum.KeyCode.A) then
			updateScreenFromMove("L")
		end
		if UserInput:IsKeyDown(Enum.KeyCode.D) then
			updateScreenFromMove("R")
		end
		
	else
		-- Body update
		thisPlayer.body.ZIndex = ReservedRef.playerFrame["look"..side].ZIndex
		thisPlayer.body.insideBody.ZIndex = ReservedRef.playerFrame["look"..side].insideBody.ZIndex
		
		-- Head update
		thisPlayer.body.head.topHair.Size = ReservedRef.playerFrame["look"..side].head.topHair.Size
		thisPlayer.body.head.topHair.Position = ReservedRef.playerFrame["look"..side].head.topHair.Position
		
		-- Right arm update
		thisPlayer.body.upperRightArm.Visible = ReservedRef.playerFrame["look"..side].upperRightArm.Visible
		thisPlayer.body.upperRightArm.ZIndex = ReservedRef.playerFrame["look"..side].upperRightArm.ZIndex
		thisPlayer.body.upperRightArm.Rotation = ReservedRef.playerFrame["look"..side].upperRightArm.Rotation
		
		-- Left arm update
		thisPlayer.body.upperLeftArm.Visible = ReservedRef.playerFrame["look"..side].upperLeftArm.Visible
		thisPlayer.body.upperLeftArm.ZIndex = ReservedRef.playerFrame["look"..side].upperLeftArm.ZIndex
		thisPlayer.body.upperLeftArm.Rotation = ReservedRef.playerFrame["look"..side].upperLeftArm.Rotation
		
		-- Left leg update
		thisPlayer.body.leftLeg.Size = ReservedRef.playerFrame["look"..side].leftLeg.Size
		thisPlayer.body.leftLeg.Position = ReservedRef.playerFrame["look"..side].leftLeg.Position
		thisPlayer.body.leftLeg.leftFoot.Size = ReservedRef.playerFrame["look"..side].leftLeg.leftFoot.Size
		thisPlayer.body.leftLeg.leftFoot.Position = ReservedRef.playerFrame["look"..side].leftLeg.leftFoot.Position
		thisPlayer.body.leftLeg.leftFoot.BorderSizePixel = ReservedRef.playerFrame["look"..side].leftLeg.leftFoot.BorderSizePixel
		thisPlayer.body.leftLeg.leftFoot.BackgroundColor3 = ReservedRef.playerFrame["look"..side].leftLeg.leftFoot.BackgroundColor3
		
		-- Right leg update
		thisPlayer.body.rightLeg.Size = ReservedRef.playerFrame["look"..side].rightLeg.Size
		thisPlayer.body.rightLeg.Position = ReservedRef.playerFrame["look"..side].rightLeg.Position
		thisPlayer.body.rightLeg.rightFoot.Size = ReservedRef.playerFrame["look"..side].rightLeg.rightFoot.Size
		thisPlayer.body.rightLeg.rightFoot.Position = ReservedRef.playerFrame["look"..side].rightLeg.rightFoot.Position
		thisPlayer.body.rightLeg.rightFoot.BorderSizePixel = ReservedRef.playerFrame["look"..side].rightLeg.rightFoot.BorderSizePixel
		thisPlayer.body.rightLeg.rightFoot.BackgroundColor3 = ReservedRef.playerFrame["look"..side].rightLeg.rightFoot.BackgroundColor3
		
	end
end

local function isPlayerBlocked(letter, change)
	
	playerQuad = positionToQuad(playerPositionX, playerPositionY)
	
	local find = guiGameFrame.gameItems:FindFirstChild("U"..playerQuad)
	-- Speed when on tile
	if find then
		local tileType = find:GetAttribute("typeOfTile")
		additonalSpeed = RefObjects[tileType].speed.Value
		
		-- If can not move on said tile, return do not move
		if RefObjects[tileType].moveIn.Value == false then

			return true
		end
		
	else 
		additonalSpeed = 0
	end
	playerSpeed = defaultSpeed + additonalSpeed
	

	
	-- if move in X pos
	if letter == "X" then
		local find2 = guiGameFrame.gameItems:FindFirstChild("U"..playerQuad + change)
		if find2 then
			local tileType = find2:GetAttribute("typeOfTile")
			-- If can not move on said tile, return do not move
			if RefObjects[tileType].moveIn.Value == false then
				if playerPositionX + playerSpeed + 15 > guiGameFrame.gameItems["U"..playerQuad + change].Position.X.Offset and playerPositionX - playerSpeed -15 < guiGameFrame.gameItems["U"..playerQuad + change].Position.X.Offset + posInQuadRate  then

					return true
				end
			end
		end
		
	-- if move in Y pos	
	else
		local find2 = guiGameFrame.gameItems:FindFirstChild("U"..playerQuad - (change*quadPerRow))
		if find2 then
			local tileType = find2:GetAttribute("typeOfTile")
			-- If can not move on said tile, return do not move
			if RefObjects[tileType].moveIn.Value == false then
				if playerPositionY + playerSpeed + 2 > guiGameFrame.gameItems["U"..playerQuad - (change*quadPerRow)].Position.Y.Offset and playerPositionY - playerSpeed -5 < guiGameFrame.gameItems["U"..playerQuad - (change*quadPerRow)].Position.Y.Offset + posInQuadRate  then

					return true
				end
			end
		end
		
	end
	-- nothing returns as unable to move, so returns as moveable
	return false
end

-- User Uses Keyboard
UserInput.InputBegan:Connect(function(key: InputObject, gameProcessed:boolean)
	if gameProcessed or inGame == false then return end

	if (key.KeyCode == Enum.KeyCode.W) then
		updateScreenFromMove("U")
		while UserInput:IsKeyDown(Enum.KeyCode.W) do task.wait(0.04)
			if not isPlayerBlocked("Y", 1) then
				playerPositionY = playerPositionY -playerSpeed
				backgroundGui.gameFrame.Position = UDim2.new(0, -playerPositionX + backgroundGui.AbsoluteSize.X/2, 0, -playerPositionY + backgroundGui.AbsoluteSize.Y/2)
				thisPlayer.Position = UDim2.new(0, playerPositionX, 0, playerPositionY)
			end
		end
		updateScreenFromMove()
	end

	if (key.KeyCode == Enum.KeyCode.S) then
		updateScreenFromMove("F")
		while UserInput:IsKeyDown(Enum.KeyCode.S) do task.wait(0.04)
			if not isPlayerBlocked("Y", -1) then
				playerPositionY = playerPositionY +playerSpeed
				backgroundGui.gameFrame.Position = UDim2.new(0, -playerPositionX + backgroundGui.AbsoluteSize.X/2, 0, -playerPositionY + backgroundGui.AbsoluteSize.Y/2)
				thisPlayer.Position = UDim2.new(0, playerPositionX, 0, playerPositionY)
			end	
		end
		updateScreenFromMove()
	end

	if (key.KeyCode == Enum.KeyCode.A) then
		updateScreenFromMove("L")
		while UserInput:IsKeyDown(Enum.KeyCode.A) do task.wait(0.04)
			if not isPlayerBlocked("X", -1) then
				playerPositionX = playerPositionX -playerSpeed
				backgroundGui.gameFrame.Position = UDim2.new(0, -playerPositionX + backgroundGui.AbsoluteSize.X/2, 0, -playerPositionY + backgroundGui.AbsoluteSize.Y/2)
				thisPlayer.Position = UDim2.new(0, playerPositionX, 0, playerPositionY)
			end
		end
		updateScreenFromMove()
	end

	if (key.KeyCode == Enum.KeyCode.D) then
		updateScreenFromMove("R")
		while UserInput:IsKeyDown(Enum.KeyCode.D) do task.wait(0.04)
			if not isPlayerBlocked("X", 1) then
				playerPositionX = playerPositionX +playerSpeed
				backgroundGui.gameFrame.Position = UDim2.new(0, -playerPositionX + backgroundGui.AbsoluteSize.X/2, 0, -playerPositionY + backgroundGui.AbsoluteSize.Y/2)
				thisPlayer.Position = UDim2.new(0, playerPositionX, 0, playerPositionY)
			end	
		end		
		updateScreenFromMove()
	end


end)
