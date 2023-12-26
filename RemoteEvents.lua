-- Services
local DataStore = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PlayerService = game:GetService('Players')
local DebrisService = game:GetService("Debris")
local BadgeService = game:GetService("BadgeService")
local ServerStorage = game:GetService("ServerStorage")

-- Remote events
local NotificationEvent = ReplicatedStorage:WaitForChild("Event_notification")
local DeathEvent = ReplicatedStorage:WaitForChild("Event_die")
local BuyGamePassEvent = ReplicatedStorage:WaitForChild("Event_buypass")
local BuyItemEvent = ReplicatedStorage:WaitForChild("Event_Buyitem")
local OpenQuestGuiEvent = ReplicatedStorage:WaitForChild("Event_TriggerQuestGui")
local OpenCustomePickaxeGuiEvent = ReplicatedStorage:WaitForChild("Event_PickaxeShop")
local TriggerShopGuiEvent = ReplicatedStorage:WaitForChild("Event_TriggerCam")
local UpdateBackPackNumberEvent = ReplicatedStorage:WaitForChild("Event_updatebackpacknumber")
local UpdateBackPackEvent = ReplicatedStorage:WaitForChild("Event_updatebackpack")
local UpdatePickaxeEvent = ReplicatedStorage:WaitForChild("Event_updatepickaxe")
local TeleportEvent = ReplicatedStorage:WaitForChild("Event_Teleport")

-- Replicated items
local PickaxeFolder = ReplicatedStorage.pickfolder
local BackpackFolder = ReplicatedStorage.backfolder
local PickaxeSkinsFolder = ReplicatedStorage.pickskins
local PickaxeModelFolder = ReplicatedStorage.pickmodel
local EffectsFolder = ReplicatedStorage.effects
local AudioFolder = ReplicatedStorage.audio

-- Ore Data
local OreData = require(ReplicatedStorage.OreDataModuleScript)

-- Get a random direction
local function randomDirection()
	
	-- Get random seed for each X Y Z
	local x = math.random() * 2 - 1
	local y = math.random() * 2 - 1
	local z = math.random() * 2 - 1

	return Vector3.new(x, y, z).Unit
end

-- Is audio valid function
local function IsValidAudio(AudioId)
	if AudioId and typeof(AudioId) == "number" then
		
		-- Ask roblox to find audio
		local Success, AssetInfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, AudioId)

		-- If audio exists, return true or false
		if Success and AssetInfo.AssetTypeId == 3 then
			return true
		else
			return false
		end
	else
		-- Not a number
		return false
	end
end

-- Get datastore function
local function getDataFromDataStore(sectionName, user)
	local attempts = 0
	local maxAttempts = 2

	-- Get datastore section from text given
	local sectionSuccess, DataStoreSection = pcall(function()
		return DataStore:GetDataStore(sectionName)
	end)

	-- Section not found
	if not sectionSuccess then

		-- Notify user of error
		NotificationEvent:FireClient(user, "Internal DataStore getData Roblox Error", nil, "Error", 25)
		warn("F - getDataFromDataStore - Failed retrieving data section " .. user.userId .. ": " .. sectionName)
	end

	-- Attempt to get datastore data if not max attempts and section found
	while attempts < maxAttempts and sectionSuccess do

		local success, result = pcall(function()
			return DataStoreSection:GetAsync(user.userId)
		end)

		if success then

			-- Return result or nil if empty
			return result or nil
		else
			-- Failed and trys once more
			attempts = attempts + 1

			if attempts < maxAttempts then
				task.wait(5)
			else
				-- Notify user of error
				NotificationEvent:FireClient(user, "Internal DataStore getData Roblox Error", nil, "Error", 25)
				warn("F - getDataFromDataStore - Failed retrieving data user " .. user.userId)
			end
		end
	end

	return nil
end

-- Set datastore function
local function setDataToDataStore(sectionName, user, data, deadline)

	-- If deadline to set data then end early
	if deadline then

		DataStore:GetDataStore(sectionName):SetAsync(user.userId, data)
		return
	end

	local attempts = 0
	local maxAttempts = 2

	-- Get datastore section from text given
	local _, DataStoreSection = pcall(function()
		return DataStore:GetDataStore(sectionName)
	end)

	-- Section not found
	if not DataStoreSection then

		-- Notify user of error
		NotificationEvent:FireClient(user, "Internal DataStore setData Roblox Error", nil, "Error", 25)
		warn("F - setDataToDataStore - Failed set data section " .. user.userId .. ": " .. sectionName)
		return
	end

	-- Attempt to set datastore data
	while attempts < maxAttempts do

		local success, result = pcall(function()
			
			DataStoreSection:SetAsync(user.userId, data)
		end)

		if not success then

			-- Failed and tries once more
			attempts = attempts + 1

			if attempts < maxAttempts then
				task.wait(5)
			else
				-- Notify user of error
				NotificationEvent:FireClient(user, "Internal DataStore setData Roblox Error", nil, "Error", 25)
				warn("F - setDataToDataStore - Failed setting data for user " .. user.userId .. ": " .. result, false)
			end
		end
	end
end

-- Award badgte
local function awardBadge(user, badge)

	local joinbadgeId = nil
	badge = badge or "SetNil"
	
	-- User asks for join badge
	if badge == "joinBadge" then
		
		joinbadgeId = (2124888302)
	end

	-- If no badge with given the name is found
	if not joinbadgeId then
		
		warn("F - awardBadge - No badge of ("..badge..") exists")
	end

	-- Get badge information
	local success, badgeInfo = pcall(function()
		
		return BadgeService:GetBadgeInfoAsync(joinbadgeId)
	end)
	
	-- If badge info found and is allowed to be awarded
	if success and badgeInfo.IsEnabled then

		-- Award badge
		pcall(function()
			
			BadgeService:AwardBadge(user.UserId, joinbadgeId)
		end)
	end
end

-- Load user pickaxe
local function loadpickaxe(user, isSkinNew)

	-- User not loaded in
	if not user:WaitForChild("isLoaded", 15) then

		warn("F - loadpickaxe - No pickaxe loaded")
		return
	end

	-- Get user bools
	local userSavingBools = user.savingnonboolstats

	-- Remove old pickaxe from backpack
	if user.Backpack:FindFirstChild("Pickaxe") then

		user.Backpack.Pickaxe:Destroy()
	end

	-- Remove old pickaxe from character
	if user.Character:FindFirstChild("Pickaxe") then
		
		user.Character.Pickaxe:Destroy()
	end

	-- Generate new pickaxe model
	local newPickaxe = PickaxeModelFolder["model"..userSavingBools.pickaxemodel.Value].Pickaxe:Clone()
	newPickaxe.Parent = user.Backpack
	
	-- Add pickaxe animations
	local pickaxeAnimationsClone = PickaxeModelFolder.Animations:Clone()
	pickaxeAnimationsClone.Parent = newPickaxe

	-- Create value for skin to use
	local storedSkin = nil

	-- Load skin
	if isSkinNew then

		storedSkin = PickaxeSkinsFolder["skin"..userSavingBools.PickaxeSkin.Value]
	else

		storedSkin = PickaxeSkinsFolder["skin"..PickaxeFolder["pick"..userSavingBools.pickaxenumber.Value]:GetAttribute("skin")]
	end

	newPickaxe.Handle.Color = storedSkin.Handle.Color 
	newPickaxe.Handle.Material = storedSkin.Handle.Material

	-- Get olny the materials and shorten code
	local pickaxeObjects = newPickaxe.Union

	-- Set pickaxe color and material
	pickaxeObjects.Base.Color = storedSkin.Base.Color
	pickaxeObjects.Base.Material = storedSkin.Base.Material

	pickaxeObjects.Top.Color = storedSkin.Top.Color
	pickaxeObjects.Top.Material = storedSkin.Top.Material

	pickaxeObjects.FrontWedge.Color = storedSkin.FrontWedge.Color
	pickaxeObjects.FrontWedge.Material = storedSkin.FrontWedge.Material

	pickaxeObjects.BackWedge.Color = storedSkin.BackWedge.Color
	pickaxeObjects.BackWedge.Material = storedSkin.BackWedge.Material

	-- Load stored audio if user chose a set audio, -1 = no music, 0 = user chosen music
	if userSavingBools.music.Value ~= 0 and userSavingBools.music.Value ~= -1 then

		-- Load audio
		local audioClone = AudioFolder["music"..userSavingBools.music.Value]:Clone()
		audioClone.Parent = newPickaxe.Handle

		-- Load audio script
		local audioScriptClone = ServerStorage.AudioScript:Clone()
		audioScriptClone.Parent = audioClone
	end

	-- Load user chosen music
	if userSavingBools.music.Value == 0 and user.stats.vip_pass.Value == true then

		-- Load empty audio
		local audioClone = AudioFolder.music1:Clone()
		audioClone.Parent = newPickaxe.Handle

		-- Load audio script
		local audioScriptClone = ServerStorage.AudioScript:Clone()
		audioScriptClone.Parent = audioClone

		-- Set audio to chosen song
		audioClone.SoundId = ("rbxassetid://"..user.stats.AudioID.Value)
	end

	-- Load effect to pickaxe
	if userSavingBools.effect.Value ~= 0 then

		local effectClone = EffectsFolder["trail"..userSavingBools.effect.Value]:Clone()
		effectClone.Parent = newPickaxe.Handle
	end

	-- Update hitpower from current pickaxe owned
	user.stats.HitPower.Value = PickaxeFolder["pick"..userSavingBools.pickaxenumber.Value]:GetAttribute("storage")	
end

-- Load in finial user information from join
local function loadInUser(user)
	
	-- Ensure character is in workspace
	workspace:WaitForChild(user.Name, 15)

	local savingStatsFolder = user.savingstats
	local savingNonBoolStatsFolder = user.savingnonboolstats

	-- Update effect
	if savingNonBoolStatsFolder.effect.Value ~= 0 and savingStatsFolder["effect"..savingNonBoolStatsFolder.effect.Value].Value == false then

		savingNonBoolStatsFolder.effect.Value = 0
	end

	-- Update music
	if savingNonBoolStatsFolder.music.Value ~= 0 and savingNonBoolStatsFolder.music.Value ~= -1 and savingStatsFolder["music"..savingNonBoolStatsFolder.music.Value].Value == false then
		
		savingNonBoolStatsFolder.music.Value = -1 
	end

	-- Update skin
	if savingStatsFolder["skin"..savingNonBoolStatsFolder.PickaxeSkin.Value].Value == false then
		savingNonBoolStatsFolder.PickaxeSkin.Value = 1 
	end

	-- Update pickaxe number
	if savingStatsFolder["pick"..savingNonBoolStatsFolder.pickaxenumber.Value].Value == false then
		savingNonBoolStatsFolder.pickaxenumber.Value = 1 
	end

	-- Update backpack number
	if savingStatsFolder["back"..savingNonBoolStatsFolder.backpacknumber.Value].Value == false then
		savingNonBoolStatsFolder.backpacknumber.Value = 1
	end
	
	-- Create user backpack
	local clone = ReplicatedStorage.backfolder["back"..savingNonBoolStatsFolder.backpacknumber.Value]:Clone()
	clone.Parent = workspace[user.Name]
	clone.Name = "PlayerBackPack"

	user.stats.BackPacksize.Value = ReplicatedStorage.backfolder["back"..savingNonBoolStatsFolder.backpacknumber.Value]:GetAttribute("storage")
	
	-- Update user stats if own the gamepass
	if MarketplaceService:UserOwnsGamePassAsync(user.UserId, 23438610) then
		user.stats.vip_pass.Value = true
		user.stats.speed.Value += 2
		user.Character.Humanoid.WalkSpeed += user.stats.speed.Value
	end
	
	-- Add isLoaded bool to inform other scripts
	local isLoaded = Instance.new("BoolValue")

	isLoaded.Name = "isLoaded"
	isLoaded.Value = true
	isLoaded.Parent = user

end

-- Buy item request
BuyItemEvent.OnServerEvent:Connect(function(user, buyRequest, itemid)

	-- Get data
	local userCash = user:WaitForChild("leaderstats", 10).Money or 0
	itemid = itemid or 1

	-- Get user bools
	local userSavingBools = user.savingnonboolstats

	-- Request to buy a backpack, ensure itemid is valid
	if buyRequest == "BackPack" and BackpackFolder:FindFirstChild("back"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, contine
		if userCash.Value >= BackpackFolder["back"..itemid]:GetAttribute("price") and user.savingstats["back"..itemid].Value == false then

			-- Update stats in game
			user.savingstats["back"..itemid].Value = true
			userCash.Value -= BackpackFolder["back"..itemid]:GetAttribute("price")
			user.stats.BackPacksize.Value = BackpackFolder["back"..itemid]:GetAttribute("storage")
			userSavingBools.backpacknumber.Value = itemid

			-- Update dateStore for item
			setDataToDataStore("back"..itemid, user, true, false)

			-- Remove old backpack
			if user.Character:FindFirstChild("PlayerBackPack")then

				user.Character.PlayerBackPack:Destroy()
			end

			-- Generate new backpack 
			local newBackpackclone = BackpackFolder["back"..itemid]:Clone()
			newBackpackclone.Parent = user.Character
			newBackpackclone.Name = "PlayerBackPack"

			-- Notify user
			NotificationEvent:FireClient(user, BackpackFolder["back"..itemid]:GetAttribute("name"), "1", "BuyItem")

			return
		end 

		-- Request to buy a pickaxe, ensure itemid is valid
	elseif buyRequest == "Pickaxe" and PickaxeFolder:FindFirstChild("pick"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, contine
		if userCash.Value >= PickaxeFolder["pick"..itemid]:GetAttribute("price") and user.savingstats["pick"..itemid].Value == false then

			-- Update stats in game
			user.savingstats["pick"..itemid].Value = true
			userCash.Value -= PickaxeFolder["pick"..itemid]:GetAttribute("price")
			userSavingBools.pickaxenumber.Value = itemid
			userSavingBools.PickaxeSkin.Value = PickaxeFolder["pick"..itemid]:GetAttribute("skin")
			user.savingstats["skin"..PickaxeFolder["pick"..itemid]:GetAttribute("skin")].Value = true

			-- Update dateStore for item
			setDataToDataStore("pick"..itemid, user, true, false)

			-- Generate new pickaxe
			loadpickaxe(user, true)

			-- Notify user
			NotificationEvent:FireClient(user, PickaxeFolder["pick"..itemid]:GetAttribute("name"), "1", "BuyItem")

			return
		end

		-- Request to buy a pickaxe skin, ensure itemid is valid
	elseif buyRequest == "skin" and PickaxeSkinsFolder:FindFirstChild("skin"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, and is avaible to buy, contine
		if userCash.Value >= PickaxeSkinsFolder["skin"..itemid]:GetAttribute("price") and user.savingstats["skin"..itemid].Value == false and PickaxeSkinsFolder["skin"..itemid]:GetAttribute("buy") == true then

			-- Update stats in gam
			user.savingstats["skin"..itemid].Value = true
			userCash.Value -= PickaxeSkinsFolder["skin"..itemid]:GetAttribute("price")

			-- Update dateStore for item
			setDataToDataStore("skin"..itemid, user, true, false)

			-- Notify user
			NotificationEvent:FireClient(user, PickaxeSkinsFolder["skin"..itemid]:GetAttribute("name").." Skin", "1", "BuyItem")

			return
		end

		-- Request to buy a pickaxe model, ensure itemid is valid
	elseif buyRequest == "model" and PickaxeModelFolder:FindFirstChild("model"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, and is avaible to buy, contine
		if userCash.Value >= PickaxeModelFolder["model"..itemid]:GetAttribute("price") and user.savingstats["model"..itemid].Value == false and PickaxeModelFolder["model"..itemid]:GetAttribute("buy") == true then

			-- Update stats in gam
			user.savingstats["model"..itemid].Value = true
			userCash.Value -= PickaxeModelFolder["model"..itemid]:GetAttribute("price")

			-- Update dateStore for item
			setDataToDataStore("model"..itemid, user, true, false)

			-- Notify user
			NotificationEvent:FireClient(user, PickaxeModelFolder["model"..itemid]:GetAttribute("name").." Frame", "1", "BuyItem")

			return
		end 

		-- Request to buy a trail, ensure itemid is valid
	elseif buyRequest == "trail" and EffectsFolder:FindFirstChild("trail"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, and is avaible to buy, contine
		if userCash.Value >= EffectsFolder["trail"..itemid]:GetAttribute("price") and user.savingstats["effect"..itemid].Value == false and EffectsFolder["trail"..itemid]:GetAttribute("buy") == true then

			-- Update stats in gam
			user.savingstats["effect"..itemid].Value = true
			userCash.Value -= EffectsFolder["trail"..itemid]:GetAttribute("price")

			-- Update dateStore for item
			setDataToDataStore("trail"..itemid, user, true, false)

			-- Notify user
			NotificationEvent:FireClient(user, EffectsFolder["trail"..itemid]:GetAttribute("name").." Trail", "1", "BuyItem")

			return
		end 

		-- Request to buy music, ensure itemid is valid
	elseif buyRequest == "music" and AudioFolder:FindFirstChild("music"..itemid) then

		-- If user has sufficent cash, and does not own item aredy, and is avaible to buy, contine
		if userCash.Value >= AudioFolder["music"..itemid]:GetAttribute("price") and user.savingstats["music"..itemid].Value == false and AudioFolder["music"..itemid]:GetAttribute("buy") == true then

			-- Update stats in game
			user.savingstats["music"..itemid].Value = true
			userCash.Value -= AudioFolder["music"..itemid]:GetAttribute("price")

			-- Update dateStore for item
			setDataToDataStore("music"..itemid, user, true, false)

			-- Notify user
			NotificationEvent:FireClient(user, AudioFolder["music"..itemid]:GetAttribute("name").." Music", "1", "BuyItem")

			return
		end
	end 
end)

-- Update backpack storage text
UpdateBackPackNumberEvent.OnServerEvent:Connect(function(user)

	-- If user has a backpack
	if user.Character:FindFirstChild("PlayerBackPack") then

		-- Change text
		user.Character.PlayerBackPack.Text.gui.TextLabel.Text = ((user.stats.TotalBackPackinput.Value.."/"..user.stats.BackPacksize.Value.." Storage"))
	end
end)

-- Equipt backpack
UpdateBackPackEvent.OnServerEvent:Connect(function(user, number)
	
	-- Set default values
	number = number or 1

	-- If backpack exists and user owns it
	if user.savingstats:FindFirstChild("back"..number) and user.savingstats["back"..number].Value == true then

		-- Destroy old backpack if found
		if user.Character:FindFirstChild("PlayerBackPack") then
			user.Character.PlayerBackPack:Destroy()
		end

		-- Update backpack number
		user.savingnonboolstats.backpacknumber.Value = number

		-- Generate new backpack
		local clone = BackpackFolder["back"..number]:Clone()
		clone.Parent = user.Character
		clone.Name = "PlayerBackPack"

		if user.savingstats["back"..number].Value == true then
			user.stats.BackPacksize.Value = BackpackFolder["back"..number]:GetAttribute("storage")
		end
	end
end)

-- Request to generate new pickaxe
UpdatePickaxeEvent.OnServerEvent:Connect(function(user, number, load, skin, audio, model, effect, AudioID)

	-- Set default values
	number = number or 0
	skin = skin or 0
	audio = audio or 0
	model = model or 0
	effect = effect or 0

	-- Generates chosen pickaxe
	if load == "equipt" then

		-- If pickaxe number exists
		if user.savingstats:FindFirstChild("pick"..number) then

			-- If user owns this pickaxe
			if user.savingstats:FindFirstChild("pick"..number).Value == true then

				-- Update in game stats
				user.savingnonboolstats.pickaxenumber.Value = number
				user.savingnonboolstats.PickaxeSkin.Value = PickaxeFolder["pick"..number]:GetAttribute("skin")
				user.savingstats["skin"..PickaxeFolder["pick"..number]:GetAttribute("skin")].Value = true

				-- Generate orignal pickaxe
				loadpickaxe(user, false)
			end
		end

		-- Request for custome pickaxe
	elseif load == "new" then

		-- User saving bools
		local bools = user.savingstats
		
		-- Find value
		local findSkin = bools:FindFirstChild("skin"..skin)
		local findAudio = bools:FindFirstChild("music"..audio)
		local findModel = bools:FindFirstChild("model"..model)
		local findEffect = bools:FindFirstChild("effect"..effect)
		
		-- Custome skin, bool found and user owns skin
		if skin ~= 0 and findSkin and findSkin.Value == true then

			user.savingnonboolstats.PickaxeSkin.Value = skin
		end

		-- Set audio, bool found and user owns audio
		if audio ~= -1 and findAudio and findAudio.Value == true then
			
			user.savingnonboolstats.music.Value = audio
		end

		-- Custome audio
		if audio == 0 then

			-- Check to make sure valid audio id
			if IsValidAudio(AudioID) == true then

				-- Check to see if user has vip
				if user.stats.vip_pass == true then

					user.savingnonboolstats.music.Value = 0
					user.stats.AudioID.Value = (AudioID or 0)

					-- Update Info
					setDataToDataStore("MusicID", user, user.stats.AudioID.Value, false)
				end
			else
				-- Notify user of error
				NotificationEvent:FireClient(user, "Invalid Audio ID", nil, "Error", 25)
			end
		end

		-- No audio
		if audio == -1 then
			user.savingnonboolstats.music.Value = -1
		end 

		-- Custome model, bool found and user owns model
		if model ~= 0 and findModel and findModel.Value == true then

			user.savingnonboolstats.pickaxemodel.Value = model
		end

		-- Custome effect, bool found and user owns effect
		if effect ~= 0 and findEffect and findEffect.Value == true then

			user.savingnonboolstats.effect.Value = effect
		else
			-- No trail
			user.savingnonboolstats.effect.Value = 0
		end

		-- Generate new pickaxe
		loadpickaxe(user, true)
	end
end)

-- Teleport user request
TeleportEvent.OnServerEvent:Connect(function(user, location)

	-- Get height
	local userHeight = user.Character:FindFirstChild("HumanoidRootPart").Position.Y or 0

	-- Request to surface
	if location == "Surface" then

		-- Max height
		if userHeight > 0 then
			userHeight = 0 
		end

		-- Correct cost
		if userHeight < 0 then
			userHeight = math.abs(userHeight)
			userHeight = userHeight/2
			userHeight = math.round(userHeight)
		end

		-- Min cost
		if userHeight < 15 then
			userHeight = 15
		end

		-- Vip discount
		if user.stats.vip_pass.Value == true then
			userHeight -= math.round(userHeight*.05)
		end

		-- Update in game stats
		if userHeight <= user.leaderstats.Money.Value then
			user.leaderstats.Money.Value -= userHeight

			-- Teleport user
			user.Character:MoveTo(workspace.SurfaceMineshaft.Teleport_part.Position)
		end
	end
end)

-- Buy gamepass
BuyGamePassEvent.OnServerEvent:Connect(function(user, id, info)

	-- Ensure request is for gamepass
	if info == "VIP" then

		-- Prompt purchase
		MarketplaceService:PromptGamePassPurchase(user, id)
	end 
end)

-- Manage recept
MarketplaceService.ProcessReceipt = function(ReceiptInfo)
	local Purchasing_Player = PlayerService:GetPlayerByUserId(ReceiptInfo.PlayerId)

	-- User recives cash type one
	if ReceiptInfo.ProductId == 1211101864 then
		if Purchasing_Player and Purchasing_Player:FindFirstChild('leaderstats') then
			Purchasing_Player.leaderstats.Money.Value += 550

			-- Notify user
			NotificationEvent:FireClient(Purchasing_Player, "Money", "550", "Money")
		end 
	end

	-- User recives cash type two
	if ReceiptInfo.ProductId == 1211101865 then
		if Purchasing_Player and Purchasing_Player:FindFirstChild('leaderstats') then
			Purchasing_Player.leaderstats.Money.Value += 2600

			-- Notify user
			NotificationEvent:FireClient(Purchasing_Player, "Money", "2600", "Money")
		end
	end	

	-- Tell roblox that transaction cleared
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Drops users backpack
local function dropBackPack(user, character)

	-- Gather value for data analysis
	local itemsValue = 0

	local characterPosition = character.HumanoidRootPart.Position

	local dropedItemsFolder = Instance.new("Folder")
	dropedItemsFolder.Name = "dropedItemsFolder"
	dropedItemsFolder.Parent = workspace.DebrisReadyFolder

	-- Ignore user with raycast
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Terrain}

	-- Gather all items in backpack
	for _, item in pairs(user.stats.Inventory:GetChildren()) do
		
		-- Loop through amount per ore, max at 6 ores
		for i = 1, math.clamp(item.Value, 1, 6) do

			task.wait(0.1)

			itemsValue += OreData[item.Name].value
			
			-- Create part for users can collect
			local part = Instance.new("Part")

			part.Parent = dropedItemsFolder
			part.Size = Vector3.new(1, 1, 1)
			part.Material = OreData[item.Name].material
			part.Color = OreData[item.Name].color
			part.Anchored = true
			part:SetAttribute("ore", item.Name)
			DebrisService:AddItem(part, math.random(1, 20) + 100)
			
			-- Direction raycast will be preformed
			local raycastDirection = randomDirection()
			
			-- Max distance raycast will travel
			local raycastDistance = math.random(2, 14)

			-- Perform the raycast
			local rayResult = workspace:Raycast(characterPosition, raycastDirection * raycastDistance, raycastParams)

			-- Check if the raycast worked
			if rayResult then

				if rayResult.Position then

					part.Position = rayResult.Position
				else

					part.Position = (characterPosition + raycastDirection * raycastDistance)
				end
			else

				part.Position = (characterPosition + raycastDirection * raycastDistance)
			end
			
			-- Create light to see better
			local light = Instance.new("PointLight")
			light.Parent = part
			light.Brightness = 8
			light.Range = 3
			light.Color = part.Color

		end

		item:Destroy()
	end

	-- Run user death gui
	DeathEvent:FireClient(user, "userDied", itemsValue)
	
	-- Wait for character to respawn to allow collecting
	task.wait(6)

	-- Gather all items in backpack
	for _, object in pairs(dropedItemsFolder:GetChildren()) do
		object.Anchored = false

		-- Function to handle part hit
		object.Touched:Connect(function(hit)

			-- If touch is a humanoid then continue
			local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid")

			if not humanoid then 
				return 
			end

			-- If humanoid is a user then continue
			local user = PlayerService:GetPlayerFromCharacter(humanoid.Parent)

			if not user then
				return 
			end

			-- Find user stats
			local stats = user:FindFirstChild("stats")
			
			-- If stats not found or backpack has no room
			if not stats or stats.TotalBackPackinput.Value >= stats.BackPacksize.Value then
				return
			end

			local oreNumber = object:GetAttribute("ore")

			-- Creates slot for saving data if it does not yet exist
			if not stats.Inventory:FindFirstChild(oreNumber) then
				local new = Instance.new("IntValue")
				new.Parent = stats.Inventory
				new.Name = oreNumber
			end

			-- Add ore to user stat
			user.stats.Inventory[oreNumber].Value += 1

			-- Add ore to backpack storage
			stats.TotalBackPackinput.Value = stats.TotalBackPackinput.Value + (OreData[oreNumber].weight)

			-- Notify user
			NotificationEvent:FireClient(user, OreData[oreNumber or "p1"].name, 1, "Ore")

			object:Destroy()
		end)
	end

	-- Set folder to be removed after
	DebrisService:AddItem(dropedItemsFolder, 125)
end

-- User join function
PlayerService.PlayerAdded:Connect(function(user)

	-- Clone user stats
	local clone = ServerStorage.stats:Clone()
	clone.Parent = user		

	-- Handle datastore, money leaderstat
	local LeaderStat = Instance.new("Folder", user)
	LeaderStat.Name = "leaderstats"

	local MoneyValue = Instance.new("NumberValue", LeaderStat)
	MoneyValue.Name = "Money"
	MoneyValue.Value = getDataFromDataStore("Money", user) or 15

	-- Create folder for user bool stats
	local savingBoolStatsFolder = Instance.new("Folder", user)
	savingBoolStatsFolder.Name = "savingstats"

	-- Get all bool values from user datastore
	for i, boolValue in pairs(ServerStorage.savingstats:GetChildren()) do

		local UserBoolValue = Instance.new("BoolValue", savingBoolStatsFolder)
		UserBoolValue.Name = boolValue.Name
		UserBoolValue.Value = getDataFromDataStore(boolValue.Name, user) or boolValue.Value
	end

	-- Create folder for user no bool stats
	local savingNonBoolStatsFolder = Instance.new("Folder", user)
	savingNonBoolStatsFolder.Name = "savingnonboolstats"

	-- Get all non bool values from user datastore
	for i, Infovalue in pairs(ReplicatedStorage.savingnonboolstats:GetChildren()) do

		local UserNonBoolValue = Instance.new("NumberValue", savingNonBoolStatsFolder)
		UserNonBoolValue.Name = Infovalue.Name
		UserNonBoolValue.Value = getDataFromDataStore(Infovalue.Name, user) or Infovalue.Value
	end

	-- Load information
	loadInUser(user)

	-- Award join badge to user
	awardBadge(user, "joinBadge")

	-- Load user's inital pickaxe
	loadpickaxe(user, false)

	-- Character added function
	user.CharacterAdded:Connect(function(character)

		-- Load user pickaxe
		loadpickaxe(user, false)

		character:WaitForChild("Humanoid").Died:Connect(function()		

			if character:FindFirstChild("HumanoidRootPart") then

				-- Run code concurent with main script
				task.spawn(function()

					-- Handle dropping user backpack
					dropBackPack(user, character)
				end)

				-- Destroy Pickaxe in backpack
				if user.Backpack:FindFirstChild("Pickaxe") then

					user.Backpack.Pickaxe:Destroy() 
				end

				-- Destroy Pickaxe on character
				if character:FindFirstChild("Pickaxe") then

					character.Pickaxe:Destroy()
				end

				-- Destroy backpack
				if character:FindFirstChild("PlayerBackPack") then

					character.PlayerBackPack:Destroy()
				end

				-- Generate new backpack
				local number = user.savingnonboolstats.backpacknumber.Value
				local clone = BackpackFolder["back"..number]:Clone()
				clone.Parent = character
				clone.Name = "PlayerBackPack"

				-- Clear user backpack
				user.stats.TotalBackPackinput.Value = 0
			end
		end)
	end)
end)

-- User leave function
PlayerService.PlayerRemoving:Connect(function(user)

	-- Save user money
	setDataToDataStore("Money", user, user.leaderstats.Money.Value, false)

	-- If user is loaded in
	if user:FindFirstChild("savingnonboolstats") then

		-- Save non bool stats
		for i, userValue in pairs(ReplicatedStorage.savingnonboolstats:GetChildren()) do

			setDataToDataStore(userValue.Name, user, user.savingnonboolstats[userValue.Name].Value, true)
		end
	end
end)

-- Open backpack shop button 1 gui
workspace.Shop1.OpenShop1.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if PlayerService:FindFirstChild(hit.Parent.Name) then
			
			-- Fire to client to trigger gui
			TriggerShopGuiEvent:FireClient(PlayerService:GetPlayerFromCharacter(hit.Parent), 1, workspace.Shop1)
		end
	end 
end)

-- Open backpack shop button 2 gui
workspace.Shop1.OpenShop2.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if PlayerService:FindFirstChild(hit.Parent.Name) then
			
			-- Fire to client to trigger gui
			TriggerShopGuiEvent:FireClient(PlayerService:GetPlayerFromCharacter(hit.Parent), 1, workspace.Shop1)
		end
	end 
end)


-- Open pickaxe shop button 1 gui
workspace.Shop2.OpenShop1.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if PlayerService:FindFirstChild(hit.Parent.Name) then
			
			-- Fire to client to trigger gui
			TriggerShopGuiEvent:FireClient(PlayerService:GetPlayerFromCharacter(hit.Parent), 2, workspace.Shop2)
		end
	end 
end)

-- Open pickaxe shop button 2 gui
workspace.Shop2.OpenShop2.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if PlayerService:FindFirstChild(hit.Parent.Name) then
			
			-- Fire to client to trigger gui
			TriggerShopGuiEvent:FireClient(PlayerService:GetPlayerFromCharacter(hit.Parent), 2, workspace.Shop2)
		end
	end 
end)

-- Open create pickaxe menu gui
workspace.SpecialShop.OpenShop.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if PlayerService:FindFirstChild(hit.Parent.Name) then
			
			-- Fire to client to trigger gui
			OpenCustomePickaxeGuiEvent:FireClient(PlayerService:GetPlayerFromCharacter(hit.Parent))
		end 
	end 
end)

-- Open quest menu gui
ProximityPromptService.PromptTriggered:Connect(function(promptObject, user)
	
	-- Fire to client to trigger gui
	OpenQuestGuiEvent:FireClient(user, promptObject)
end)

-- Create new spawn function to handle infinity loop for saving user data
task.spawn(function()
	while true do

		-- Delay loop
		task.wait(120)
		for i, user in pairs(game.Players:GetChildren()) do

			-- Save user money
			setDataToDataStore("Money", user, user.leaderstats.Money.Value, false)

			-- Save non bool stats
			for i, InfoValue in pairs(ReplicatedStorage.savingnonboolstats:GetChildren()) do

				setDataToDataStore(InfoValue.Name, user, user.savingnonboolstats[InfoValue.Name].Value, false)
			end
		end
	end
end)
