-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- REMOTE EVENTS
local OreHealthEvent = ReplicatedStorage:WaitForChild("Event_orehealth")
local SwingPickaxeEvent = ReplicatedStorage:WaitForChild("Event_swingpickaxe")
local CollectOreEvent = ReplicatedStorage:WaitForChild("Event_collectore")

local Walls = game.Workspace.Walls
local players = {}

-- WALL VISUAL VARIABLES/DATA
local wallInfo = {
	p1 = {healthMultiplier = 2, material = Enum.Material.Cobblestone, color = Color3.new(0.415686, 0.223529, 0.0352941)},
	p2 = {healthMultiplier = 6, material = Enum.Material.Fabric, color = Color3.new(0.356863, 0.364706, 0.411765)},
	p3 = {healthMultiplier = 11, material = Enum.Material.Marble, color = Color3.new(0.223529, 0.298039, 0.231373)},
	p4 = {healthMultiplier = 20, material = Enum.Material.Slate, color = Color3.new(0.690196, 0.494118, 0.352941)}
}

-- FUNCTION TO DETERMINE WALL TYPE BASED ON DEPTH
local function getWallType(wall)
	local depth = wall.Position.Y
	if depth < 0 and depth > -80 then return 1
	elseif depth < -80 and depth > -140 then return 2
	elseif depth < -140 and depth > -200 then return 3
	elseif depth < -200 and depth > -260 then return 4
	end
	return 1
end

-- FUNCTION TO CREATE A NEW WALL
local function createNewWall(wall)
	local wallType = getWallType(wall)
	local wallData = wallInfo["p" .. wallType]

	local health = math.random(25, 40) * wallData.healthMultiplier
	wall:SetAttribute("health", health)
	wall:SetAttribute("maxHealth", health)

	wall.Color = wallData.color
	wall.gui.text.Text = (health.."/"..health)
	wall.gui2.text.Text = (health.."/"..health)
end

-- Function to handle wall breaking
local function handleWallBreak(wall)
	createNewWall(wall)
	wall.gui.text.Size = UDim2.new(0, (wall.Size.X * 50), 0, (wall.Size.Y * 50))
	wall.gui2.text.Size = UDim2.new(0, (wall.Size.X * 50), 0, (wall.Size.Y * 50))

	wall.Touched:Connect(function(hit)
		-- Check parent of hit exists and also is a humanoid
		local humanoid = hit
		if not hit.Parent then return end
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		
		if humanoid then
			
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			-- Check that its a player, player has not hit recently, and the wall is avaible to break
			if player and not table.find(players, player.UserId) and wall.CanCollide == true then
				
				local pickaxe = player.Character:FindFirstChild("Pickaxe")
				if pickaxe then
					table.insert(players, player.UserId)

					local health = wall:GetAttribute("health")
					local maxHealth = wall:GetAttribute("maxHealth")
					local stats = player:FindFirstChild("stats")

					-- Reduce the wall's health based on player's hit power
					health = health - (stats and stats.HitPower.Value or 1)
					wall:SetAttribute("health", health)
					SwingPickaxeEvent:FireClient(player)

					-- Update GUI with new health
					wall.gui.text.Text = (health.."/"..maxHealth)
					wall.gui2.text.Text = (health.."/"..maxHealth)

					-- Check if the wall's health is below or equal to zero
					if health <= 0 then
						-- Wall is broken, handle destruction and reward
						SwingPickaxeEvent:FireClient(player)
						wall.CanCollide = false
						wall.Transparency = 1
						wall.gui.text.Visible = false
						wall.gui2.text.Visible = false

						-- Reward player
						local reward = (12 * getWallType(wall))
						player.leaderstats.Money.Value += reward
						CollectOreEvent:FireClient(player, "Money", reward)
						
						-- Remove player from debounce list
						table.remove(players, table.find(players, player.UserId))
						
						-- Generate debris
						local x = wall.Size.X / 5
						local y = wall.Size.Y / 5
						local model = Instance.new("Model")
						model.Parent = wall.items

						local start1 = (wall.Position.X - (wall.Size.X / 2)) + x / 2
						local start2 = (wall.Position.Y - (wall.Size.Y / 2)) + y / 2
						local xcount, ycount = 0, 0

						for count = 1, 25 do
							if xcount == 5 then
								ycount = ycount + 1
								xcount = 0
								start1 = start1 + x
								start2 = wall.Position.Y - (wall.Size.Y / 2)
							end

							local newPart = Instance.new("Part")
							newPart.Anchored = false
							newPart.Parent = model
							newPart.CustomPhysicalProperties = PhysicalProperties.new(1)
							newPart.Transparency = 0.3
							newPart.Size = Vector3.new(x - 0.2, y - 0.2, 1.5)
							newPart.Position = Vector3.new(start1, start2, wall.Position.Z)
							newPart.Color = wall.Color
							newPart.Material = Enum.Material.Slate
							Debris:AddItem(newPart, math.random(1, 10)*2 + 20)

							start2 = start2 + y
							xcount = xcount + 1
							if xcount == 3 and ycount == 3 then
								model.PrimaryPart = newPart
							end
						end

						-- Rotate the debris model
						local x, y, z = wall.CFrame.Rotation:ToEulerAnglesYXZ()
						model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(x, y, z))

						-- Wall becomes invisible and non-collidable
						wall.Transparency = 1
						wall.CanCollide = false
						wall.gui.text.Visible = false
						wall.gui2.text.Visible = false
						player.Character.Humanoid.WalkSpeed = 16 + (stats and stats.speed.Value or 0)


						-- After 10 seconds, make debris non-collidable
						task.wait(10)
						for _, part in ipairs(model:GetChildren()) do
							part.Anchored = true
							part.CanCollide = false
						end

						-- Regenerate a new wall after a delay
						task.wait((math.random(5, 9)) * 10 + 70)
						createNewWall(wall)
						wall.Transparency = 0
						wall.CanCollide = true
						wall.gui.text.Visible = true
						wall.gui2.text.Visible = true
						
					else
						-- Wall is not broken and so sets updated values	
						wall:SetAttribute("ht",health)	
						wall.gui.text.Text = (health.."/"..maxHealth)
						wall.gui2.text.Text = (health.."/"..maxHealth)
						task.wait (0.5)
						OreHealthEvent:FireClient(player, wall)
						player.Character.Humanoid.WalkSpeed = 10
						task.wait (0.3)
						player.Character.Humanoid.WalkSpeed = 16 + stats.speed.Value
						task.wait(0.5)
						-- Remove player from debounce list
						table.remove(players, table.find(players, player.UserId))
					end

				end
			end
		end
	end)
end


-- PROCESS EACH WALL IN WALLS FOLDER
for _, wall in pairs(Walls:GetChildren()) do
	handleWallBreak(wall)
end	
