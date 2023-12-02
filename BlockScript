-- Services and constants
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local OreData = require(ReplicatedStorage.OreDataModule)

-- Remote events
local SwingPickaxeEvent = ReplicatedStorage:WaitForChild("Event_swingpickaxe")
local CollectOreEvent = ReplicatedStorage:WaitForChild("Event_collectore")
local OreHealthEvent = ReplicatedStorage:WaitForChild("Event_orehealth")

local OresFolder = game.Workspace.Ores

local playersInDebounce  = {}

-- Function to get ore probabilities based on depth
local function getOreProbabilities(depth)
	if depth < 0 and depth > -100 then
		-- Layer 1: 0 to -100
		return {40, 25, 15, 10, 6, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	elseif depth < -100 and depth > -200 then
		-- Layer 2: -100 to -200
		return {20, 40, 20, 12, 5, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0}
	elseif depth < -200 and depth > -300 then
		-- Layer 3: -200 to -300 (placeholder)
		return {5, 20, 30, 15, 10, 5, 7, 5, 2, 1, 0, 0, 0, 0, 0}
	elseif depth < -300 and depth > -400 then
		-- Layer 4: -300 to -400 (placeholder)
		return {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	else
		-- Default case if the depth doesn't match any layer
		return {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	end
end

-- Function to randomly select an ore type based on probabilities
local function selectOreType(probabilities)
	local total = 0
	for _, chance in ipairs(probabilities) do
		total += chance
	end

	local randomNum = math.random(0, total)
	local cumulative = 0

	for i, chance in ipairs(probabilities) do
		cumulative += chance
		if randomNum <= cumulative then
			return i
		end
	end
	
	-- Default ore type
	return 1 
end

-- Create new ore function
local function createNewOre(block)
	local depth = block.Position.Y
	local probabilities = getOreProbabilities(depth)
	local oreNumber = selectOreType(probabilities)

	local oreInfo = OreData["p"..oreNumber]
	local oreType = oreInfo.n
	local oreHealth = oreInfo.h

	-- Set visuals
	for B = 1, 6 do
		block["ore"..B].Material = oreInfo.m
		block["ore"..B].Color = oreInfo.c
	end
	
	-- Set data
	block:SetAttribute("health", oreHealth)
	block:SetAttribute("maxHealth", oreHealth)  
	block:SetAttribute("ore", "p"..oreNumber)
end

-- Manage ore
local function handleOreInteraction(oreBlock)
	oreBlock.Touched:Connect(function(hit)
		
		-- If touch is a humanoid then continue
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid")
		if not humanoid then return end
		
		-- If humanoid is a user then continue
		local player = Players:GetPlayerFromCharacter(humanoid.Parent)
		if not player or playersInDebounce[player.UserId] then return end
		
		-- If user contains a pickaxe and stats data has loaded
		local pickaxe = player.Character and player.Character:FindFirstChild("Pickaxe")
		local stats = player:FindFirstChild("stats")
		if not pickaxe or not stats or stats.TotalBackPackinput.Value >= stats.BackPacksize.Value then return end

		-- Retrive data
		local oreNumber = oreBlock:GetAttribute("ore")
		local Pickaxe = player.Character:FindFirstChild("Pickaxe")
		
		-- Contine if has backpack storage and pickaxe in hand
		if Pickaxe and stats.TotalBackPackinput.Value < stats.BackPacksize.Value then

			-- Check Player Debounce
			local p = table.find(playersInDebounce, player.UserId)if p == nil and oreBlock:GetAttribute("maxHealth") > 0 then

				table.insert(playersInDebounce, player.UserId)
				
				-- Hit ore
				player.Character.Humanoid.WalkSpeed = 5
				SwingPickaxeEvent:FireClient(player)
				task.wait (0.45)
				
				-- Retrive ore data
				local health = oreBlock:GetAttribute("health")
				local maxHealth = oreBlock:GetAttribute("maxHealth")
				
				health -= stats.HitPower.Value
				
				-- Subtracts ore health and tells client
				oreBlock:SetAttribute("health", health)
				OreHealthEvent:FireClient(player, oreBlock)

				-- If ore has reached minimum health break it
				if health <= 0 then
					
					-- Prevent all new touch events
					oreBlock.CanTouch = false

					
					-- Creates slot for saving data if it does not yet exist
					if not stats.Inventory:FindFirstChild(oreNumber) then
						local new = Instance.new("IntValue")
						new.Parent = stats.Inventory
						new.Name = oreNumber
					end
					
					-- Add ore to player stat
					local oreRecived = (math.random(1,2))
					player.stats.Inventory[oreNumber].Value += oreRecived
					
					-- Update quest data
					player.savingnonboolstats.Blocks.Value	= player.savingnonboolstats.Blocks.Value +1
					player.stats.Quest_Ore.Value = player.stats.Quest_Ore.Value + 1 
					
					-- Add ore to backpack storage
					stats.TotalBackPackinput.Value = stats.TotalBackPackinput.Value + (OreData[oreNumber].w*oreRecived)
					CollectOreEvent:FireClient(player, OreData[oreNumber].n, oreRecived)

					-- Slow player then reset speed
					player.Character.Humanoid.WalkSpeed = 10
					task.wait (0.2)
					player.Character.Humanoid.WalkSpeed = 16 + stats.speed.Value
					task.wait(0.2)
					
					-- Remove user from debounce
					table.remove(playersInDebounce, table.find(playersInDebounce, player.UserId))	
					
					-- Hides ore block
					oreBlock.Transparency = 1
					oreBlock.CanCollide = false
					for count = 1, 6 do oreBlock["ore"..count].Transparency = 1 end

					-- Waits an undetermind time to regenerate
					task.wait(math.random(5,10)*8+150)
					
					-- Update ore to new generation
					createNewOre(oreBlock)

					-- unhide ore once it has reset
					task.wait (1)
					oreBlock.Transparency = 0
					oreBlock.CanCollide = true
					oreBlock.CanTouch = true
					for count = 1, 6 do oreBlock["ore"..count].Transparency = 0 end

				else
					
					-- Slow player then reset speed
					player.Character.Humanoid.WalkSpeed = 10
					task.wait (0.2)
					player.Character.Humanoid.WalkSpeed = 16 + stats.speed.Value
					task.wait(0.2)
					
					-- Remove user from debounce
					table.remove(playersInDebounce, table.find(playersInDebounce, player.UserId))							
				end

			end
		end


	end)
end

-- Initial ore setup
for _, oreBlock in pairs(OresFolder:GetChildren()) do
	createNewOre(oreBlock)
	handleOreInteraction(oreBlock)
end
