local RS = game:GetService("ReplicatedStorage")
local SummonObjects = RS:FindFirstChild("SummonObjects")
local SplashBlock = SummonObjects and SummonObjects:FindFirstChild("liquidSplashBlock")

local waterFolder = game.Workspace.Water
-- Table to track players in water
local playersInWater = {}

-- Function to check if a player has left the water
local function checkIfPlayerLeftWater(player, waterBlock)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local playerPosition = player.Character.HumanoidRootPart.Position
		local waterPosition = waterBlock.Position
		local waterSize = waterBlock.Size
		local inX = math.abs(playerPosition.X - waterPosition.X) < waterSize.X / 2
		local inY = math.abs(playerPosition.Y - waterPosition.Y) < waterSize.Y / 2
		local inZ = math.abs(playerPosition.Z - waterPosition.Z) < waterSize.Z / 2

		if not (inX and inY and inZ) then
			-- Player has left the water, reset speed and remove from table
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16 -- Reset to normal speed
			end
			playersInWater[player.UserId] = nil
		end
	end
end

-- Function to summon block when player enters water
local function spawnWaterSplash(player, water)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local clone = SplashBlock:Clone()
		
		-- Move Effect block to Y, top of water and X Z of player
		local playerPosition = player.Character.HumanoidRootPart.Position
		local waterTopY = water.Position.Y + (water.Size.Y/2)
		clone.Position = Vector3.new(playerPosition.X, waterTopY, playerPosition.Z)
		clone.Parent = game.Workspace

		-- Change the color of the BlockEffect to match the water
		local blockEffect = clone:FindFirstChild("BlockEffect")
		if blockEffect then
			blockEffect.Color = ColorSequence.new(water.Color, water.Color)
		end
		
		
		if math.random(1,2) == 1 then
			clone.splash.Playing = false
		end
		
		-- Disable the effect after 0.5 seconds and delete the block after 0.8 seconds
		delay(0.2, function()
			if blockEffect then
				blockEffect.Enabled = false
			end
			wait(0.8)
			clone:Destroy()
		end)
	end
end

-- Function to handle the player entering the water block
local function onEnter(waterBlock)
	return function(hit)
		
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		
		if humanoid and player then
			-- Reduce walk speed and track the player
			humanoid.WalkSpeed = 8
			playersInWater[player.UserId] = waterBlock
			
			spawnWaterSplash(player, waterBlock)
		end
	end
end

-- Connect water blocks to the onEnter function
for _, subfolder in pairs(waterFolder:GetChildren()) do
	if subfolder:FindFirstChild("water") then
		subfolder.water.Touched:Connect(onEnter(subfolder.water))
	end
end

-- Periodically check if players have left the water
while wait(2) do
	for userId, waterBlock in pairs(playersInWater) do
		local player = game.Players:GetPlayerByUserId(userId)
		if player then
			checkIfPlayerLeftWater(player, waterBlock)
		else
			-- Player left the game, remove from the table
			playersInWater[userId] = nil
		end
	end
end
