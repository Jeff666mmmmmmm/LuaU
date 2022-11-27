--[[
Player Join Script
Created by JEFF666mmmmmmm
--]]

local RStorage = game:GetService("ReplicatedStorage").remoteEvents

local Players = game:GetService("Players")
local ReciveEvent = RStorage:WaitForChild("remoteEventSendToServer")
local AskEvent = RStorage:WaitForChild("AskServerFunction")
local SendEvent = RStorage:WaitForChild("remoteEventSendToClient")

local newRotationEvent = RStorage:WaitForChild("newRotationToClient")
local newMoveEvent = RStorage:WaitForChild("newMoveToClient")
local newObjectEvent = RStorage:WaitForChild("newObjectToClient")
local newRemoveEvent = RStorage:WaitForChild("newRemoveToClient")

-- Allow auto save to run
local run = false

-- Get dataStore service
local DataStore = game:GetService("DataStoreService")


local gamePlayers = {}

local quad1 = {}
local quad2 = {}
local quad3 = {}
local quad4 = {}
local quad5 = {}
local quad6 = {}
local quad7 = {}
local quad8 = {}
local quad9 = {}
local quad10 = {}
local quad11 = {}
local quad12 = {}
local quad13 = {}
local quad14 = {}
local quad15 = {}
local quad16 = {}
local quad17 = {}
local quad18 = {}
local quad19 = {}
local quad20 = {}
local quad21 = {}
local quad22 = {}
local quad23 = {}
local quad24 = {}
local quad25 = {}

local objectsToUpdate = {}


local defaultPlayerInfo = {}

local givenTime = os.time()

local dayList = {
	d0 = os.date("%j", givenTime - 86400),
	d1 = os.date("%j", givenTime),
	d2 = os.date("%j", givenTime + 86400),
	d3 = os.date("%j", givenTime + 172800),
	d4 = os.date("%j", givenTime + 259200),
	
	w0 = os.date("%a", givenTime - 86400),
	w1 = os.date("%a", givenTime),
	w2 = os.date("%a", givenTime + 86400),
	w3 = os.date("%a", givenTime + 172800),
	w4 = os.date("%a", givenTime + 259200)
	
}

local waterColor = Color3.fromRGB(71, 175, 255)
local bGroundColor = Color3.fromRGB(20, 191, 63)
local lineColor = Color3.fromRGB(19, 171, 57)
local nowDay = tonumber(dayList.d1)

if (nowDay > -1 and nowDay < 75) or (nowDay > 345 and nowDay < 366) then
	bGroundColor = Color3.fromRGB(160, 255, 134)
	waterColor = Color3.fromRGB(181, 225, 255)

	if nowDay > 350 and nowDay < 361 then
		changed = true
		waterColor = Color3.fromRGB(181, 225, 255)
		lineColor = Color3.fromRGB(255, 120, 122)
	end

end

if nowDay > 75 and nowDay < 165 then
	

end

if nowDay > 165 and nowDay < 255 then
	

end

if nowDay > 255 and nowDay < 345 then
	bGroundColor = Color3.fromRGB(104, 197, 61)
	lineColor = Color3.fromRGB(120, 161, 74)

	if nowDay == 303 or nowDay == 304 or nowDay == 305 then
		changed = true
	end


end


if changed == false then
	if dayList.w1 == "Sat" then
		bGroundColor = Color3.fromRGB(145, 33, 23)
		lineColor = Color3.fromRGB(159, 0, 159)
		waterColor = Color3.fromRGB(0, 89, 255)
	end
end

local maxGameSize = 3600
local sizePerQuad = maxGameSize/36

local randomNumberString = {"a", "y", "O", "X", "l", "m", "t", "H", "r", "E"}
-- Get new unique id
local function getNewId()
	
	return (randomNumberString[math.random(1,10)]..math.random(-214748364, 214748364)..randomNumberString[math.random(1,10)])
end

local function objcectToQuad(object, givenQuad)
	
	if object["position"].X > (givenQuad * sizePerQuad) then end
	
end


local function onGetRequest(player: Instance, request: StringValue, movetoData, rotationData: IntValue)

	if request == "update" then
		
		local user = gamePlayers[player.UserId]
		if user then
			
			-- Math problem D = time(1.03*33 OR 34)*speed
			local CPUchange = math.round((os.clock() - user.lastCPUupdate) * (34) * user.speed)
			
			if user.movingTo.W ~= movetoData.W then
				user["position"] = Vector2.new(user["position"].X, user["position"].Y - CPUchange)
			end
			
			if user.movingTo.S ~= movetoData.S then
				user["position"] = Vector2.new(user["position"].X, user["position"].Y + CPUchange)
			end
			
			if user.movingTo.A ~= movetoData.A then
				user["position"] = Vector2.new(user["position"].X + CPUchange, user["position"].Y)
			end
			
			if user.movingTo.D ~= movetoData.D then
				user["position"] = Vector2.new(user["position"].X - CPUchange, user["position"].Y)
			end
			
			-- Update last position change
			user["lastCPUupdate"] = os.clock()

			user["movingTo"] = movetoData
			user["rotation"] = rotationData
			
		
			
			newMoveEvent:FireAllClients(user.id, "entity", user.position, movetoData.W, movetoData.S, movetoData.A, movetoData.D)
			SendEvent:FireAllClients("updateR", (player.UserId), nil, nil, gamePlayers[player.UserId].speed, nil, nil, rotationData)
		end
	end
	
end

ReciveEvent.OnServerEvent:Connect(onGetRequest)


Players.PlayerAdded:Connect(function(player)
	
	local information = game.ServerStorage.defaultPlayerDataFile:Clone()
	information.Parent = game.ServerStorage.playerData
	information.Name = player.UserId

	-- Get the datastore
	local D = DataStore:GetDataStore(player.UserId)

	-- Grabs value for later refernce
	local Value = D:GetAsync("money") or 0
	
end)

Players.PlayerRemoving:Connect(function(player)
	
	if table.find(gamePlayers, player.UserId) then
		gamePlayers[player.UserId] = nil
		SendEvent:FireAllClients("remove", player.UserId, nil, nil, nil, nil, "entity", nil)
	end
	
	-- Get the datastore
	local D = DataStore:GetDataStore(player.UserId)

	-- Grabs value for later saving
	local money = game.ServerStorage.playerData:FindFirstChild(player.UserId)

	if money then
		-- Sets information to datastore
		--D:SetAsync("money", money)	

	end
	
end)

-- REQUEST INFORMATION
local function GetData(player, ask)
	
	if ask == "getPlayerInformation" then
		local displayName = player.DisplayName

		if player.Name == player.DisplayName then
			displayName = "{nil}"
		end

		return false, player.Name, displayName, maxGameSize, lineColor, bGroundColor, waterColor

	end

	if ask == "addPlayerInformation" and not table.find(gamePlayers, player.UserId) then
		
		
		gamePlayers[player.UserId] = {defaultPlayerInfo}
		local user = gamePlayers[player.UserId]
		
		user["position"] = Vector2.new(math.random(0, maxGameSize), math.random(0, maxGameSize))
		user["quad"] = 1
		user["radius"] = 50
		user["displayName"] = player.DisplayName
		user["id"] = player.UserId
		user["speed"] = 12
		user["tank"] = "Tank"
		user["health"] = 1000
		user["maxHealth"] = 1000
		user["healthRegen"] = 1
		user["bodyDamage"] = 20
		user["bodyBounce"] = 400
		user["rotation"] = 0
		user["movingTo"] = {W = false, S = false, A = false, D = false}
		user["dead"] = false
		user["lastCPUupdate"] = os.clock()
		
		local userData = {user.position, user.quad, user.radius, user.displayName, user.id, user.speed, user.tank, user.health, user.maxHealth, user.healthRegen, user.bodyDamage, user.bodyBounce, user.rotation, user.movingTo}
		
		newObjectEvent:FireAllClients(user.id, "entity", userData)
		return true, user.position, user.health, user.maxHealth, user.displayName, user.speed, user.tank
	end
	
	if ask == "getDayInformation" then
		
		return dayList
	end
	
	if ask == "loadEntitys" then
		local count = 0
		for i, objects in pairs(gamePlayers) do
			local user = gamePlayers[i]
			local userData = {user.position, user.quad, user.radius, user.displayName, user.id, user.speed, user.tank, user.health, user.maxHealth, user.healthRegen, user.bodyDamage, user.bodyBounce, user.rotation, user.movingTo}
			newObjectEvent:FireClient(player, userData)
			count += 1
		end
		
		for i = 0, 1, 1 do
			for index, object in pairs(quad1) do
				local user = quad1[index]
				local userData = {user.position, user.quad, user.radius, user.displayName, user.id, user.speed, user.tank, user.health, user.maxHealth, user.healthRegen, user.bodyDamage, user.bodyBounce, user.rotation, user.movingTo}
				newObjectEvent:FireClient(player, userData)
				count += 1

			end

		end
		
		return count
	end
	
end
AskEvent.OnServerInvoke = GetData

task.wait(8)
local LocalNewId = getNewId()

quad1[LocalNewId] = {defaultPlayerInfo}
local user = quad1[LocalNewId]

user["position"] = Vector2.new(500, 500)
user["quad"] = 1
user["radius"] = 50
user["displayName"] = "Billy"
user["id"] = LocalNewId
user["speed"] = 12
user["tank"] = "Tank"
user["health"] = 800
user["maxHealth"] = 100
user["healthRegen"] = 1
user["bodyDamage"] = 1111
user["bodyBounce"] = 0
user["rotation"] = 0
user["movingTo"] = {W = false, S = false, A = false, D = false}
user["dead"] = false
user["lastCPUupdate"] = os.clock()

local userData = {user.position, user.quad, user.radius, user.displayName, user.id, user.speed, user.tank, user.health, user.maxHealth, user.healthRegen, user.bodyDamage, user.bodyBounce, user.rotation, user.movingTo}

newObjectEvent:FireAllClients(LocalNewId, "entity", userData)
local landmines = 0
local function createlandmine()
	landmines += 1
	local LocalNewId = getNewId()

	quad1[LocalNewId] = {defaultPlayerInfo}
	local user = quad1[LocalNewId]
	user["position"] = Vector2.new(math.random(0, maxGameSize), math.random(0, maxGameSize))
	user["quad"] = 1
	user["radius"] = 15
	user["displayName"] = "LandMine"
	user["id"] = LocalNewId
	user["speed"] = 0
	user["tank"] = "LandMine"
	user["health"] = 1
	user["maxHealth"] = 1
	user["healthRegen"] = 0
	user["bodyDamage"] = 85
	user["bodyBounce"] = 150
	user["rotation"] = 0
	user["movingTo"] = {W = false, S = false, A = false, D = false}
	user["dead"] = false
	user["lastCPUupdate"] = os.clock()

	local userData = {user.position, user.quad, user.radius, user.displayName, user.id, user.speed, user.tank, user.health, user.maxHealth, user.healthRegen, user.bodyDamage, user.bodyBounce, user.rotation, user.movingTo}

	newObjectEvent:FireAllClients(LocalNewId, "entity", userData)
	
	
end

-- Auto save WARNING ENDS SCRIPT RUNNING BELOW
while run == true do task.wait (100)

	-- Grabs all the users in game
	for i, player in pairs(game.Players:GetChildren()) do

		-- Get the datastore
		local D = DataStore:GetDataStore(player.UserId)

		-- Grabs value for later saving
		local money = game.ServerStorage.playerData:FindFirstChild(player.UserId)

		if not money then continue end
		-- Sets information to datastore
		--D:SetAsync("money", money)		
	end

end

local secCount = 0
while true do task.wait(0.1) if landmines < 10 then createlandmine() end

	for i, objects in pairs(gamePlayers) do
		
		local user = gamePlayers[i]
		
		-- Math problem D = time(1.03*33 OR 34)*speed
		local CPUchange = math.round((os.clock() - user.lastCPUupdate) * (34) * user.speed)

		-- time snap to speed move count, 0.51/17 = 0.03
		if user["movingTo"].W == true then
			user["position"] = Vector2.new(user["position"].X, user["position"].Y - CPUchange)
		end
		
		if user["movingTo"].S == true then
			user["position"] = Vector2.new(user["position"].X, user["position"].Y + CPUchange)
		end
		
		if user["movingTo"].D == true then
			user["position"] = Vector2.new(user["position"].X + CPUchange, user["position"].Y)
		end
		
		if user["movingTo"].A == true then
			user["position"] = Vector2.new(user["position"].X - CPUchange, user["position"].Y)
		end
		
		-- HEALTH MANAGMENT
		secCount += 1
		
		if secCount > 9 then
			secCount = 0
			user["health"] += user.healthRegen
		
			if user.health > user.maxHealth then
				user["health"] = user.maxHealth
			end
			
			
		end
		
		-- Update last position change
		user["lastCPUupdate"] = os.clock()
		
		user.position = Vector2.new(math.clamp(user.position.X, 37, maxGameSize - 37), math.clamp(user.position.Y, 37, maxGameSize-37))

		for index, object in pairs(quad1) do
			
			-- Get distance between the 2 objects
			local dx = user.position.X - quad1[index].position.X
			local dy = user.position.Y - quad1[index].position.Y
			local distance = math.sqrt(dx * dx + dy * dy)
			
			
			-- If colliding
			if distance < user.radius + quad1[index].radius then
				
				user["health"] -= quad1[index].bodyDamage
				quad1[index]["health"] -= user.bodyDamage
					
				if quad1[index].health <= 0 then
					
					newRemoveEvent:FireAllClients(quad1[index].id, "entity", user.id)
					
					quad1[index]["dead"] = true
					if quad1[index].displayName == "LandMine" then
						landmines -= 1
					end
					
				end
				
				if user.health <= 0 then
					newRemoveEvent:FireAllClients(user.id, "entity", quad1[index].id)

					user["dead"] = true
					if user.displayName == "LandMine" then
						landmines -= 1
					end
				end
				
				local addV = Vector2.new(0, 0)
				local add1 = Vector2.new(0, 0)
				local add2 = Vector2.new(0, 0)
				
				if user.position.X > quad1[index]["position"].X then
					addV += Vector2.new(55,0)--math.round((user["position"].X - quad1[index]["position"].X)/2+50), 0)
					add1 += Vector2.new(quad1[index].bodyBounce,0)
					add2 += Vector2.new(user.bodyBounce,0)
				else
					addV -= Vector2.new(55,0)--math.round((user["position"].X - quad1[index]["position"].X)/2+50), 0)
					add1 -= Vector2.new(quad1[index].bodyBounce,0)
					add2 -= Vector2.new(user.bodyBounce,0)
				end
				
				if user.position.Y > quad1[index]["position"].Y then
					addV += Vector2.new(0, 55)-- math.round((user["position"].Y - quad1[index]["position"].Y)/2+50))
					add1 += Vector2.new(0, quad1[index].bodyBounce)
					add2 += Vector2.new(0, user.bodyBounce)
				else
					addV -= Vector2.new(0,55)-- math.round((user["position"].Y - quad1[index]["position"].Y)/2+50))
					add1 -= Vector2.new(0, quad1[index].bodyBounce)
					add2 -= Vector2.new(0, user.bodyBounce)
				end
				
				user.position += addV + add1
				user.position = Vector2.new(math.clamp(user.position.X, 0, maxGameSize), math.clamp(user.position.Y, 0, maxGameSize))
				quad1[index].position -= addV + add2
				quad1[index].position = Vector2.new(math.clamp(quad1[index].position.X, 0, maxGameSize), math.clamp(quad1[index].position.Y, 0, maxGameSize))
				
				newMoveEvent:FireAllClients(user.id, "entity", user.position)
				
				if not quad1[index].dead then 
					newMoveEvent:FireAllClients(quad1[index].id, "entity", quad1[index].position)
				end
				
				SendEvent:FireAllClients("health", user.id, user.health, user.maxHealth)
				
				
				-- TRASH COLLECTION
				if quad1[index].dead then
					local r = table.find(quad1, index)
					table.remove(quad1, r)
				end
				if user.dead then
					local r = table.find(gamePlayers, i)
					table.remove(gamePlayers, r)
				end
					
			else
				
			end
			
			
			
		end


	end
end
