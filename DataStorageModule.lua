-- Module table
local MyModule = {}

-- Services
local DataStore = game:GetService("DataStoreService")

-- Improved error handling function
local function handleDataStoreError(operation, userId, message)
	warn(string.format("DataStore Error [%s] for User [%s]: %s", operation, userId, message))
end

-- Enhanced getDataFromDataStore function
function MyModule.getDataFromDataStore(sectionName, user)
	local maxAttempts = 3
	local retryDelay = 2 -- seconds
	
	-- Get information
	local function attemptFetch()
		local success, result = pcall(function()
			local store = DataStore:GetDataStore(sectionName)
			return store:GetAsync(user.userId)
		end)

		return success, result
	end
	
	-- Repeat attempts
	for attempt = 1, maxAttempts do
		local success, result = attemptFetch()

		if success then
			return result
		else
			if attempt < maxAttempts then
				wait(retryDelay)
			else
				handleDataStoreError("Fetch", user.userId, result)
			end
		end
	end

	return nil
end

-- Enhanced setDataToDataStore function
function MyModule.setDataToDataStore(sectionName, user, data, expedite)
	local maxAttempts = expedite and 1 or 3
	local retryDelay = 2
	
	-- Save information
	local function attemptSave()
		local success, result = pcall(function()
			local store = DataStore:GetDataStore(sectionName)
			store:SetAsync(user.userId, data)
		end)

		return success
	end
	
	-- Repeat attempts
	for attempt = 1, maxAttempts do
		local success = attemptSave()

		if success then
			return
		else
			if attempt < maxAttempts then
				wait(retryDelay)
			else
				handleDataStoreError("Save", user.userId, "Max attempts reached")
			end
		end
	end
end


-- Get orderd data
function MyModule.getOrderedDataStore(dataStoreName)
	local success, orderedDataStore = pcall(function()
		return DataStore:GetOrderedDataStore(dataStoreName)
	end)

	if not success then
		handleDataStoreError("GetOrderedDataStore", "N/A", dataStoreName)
		return nil
	end

	return orderedDataStore
end

-- Get sorted data
function MyModule.getSortedDataStore(dataStoreName, sortAscending, pageSize)
	
	-- Get information
	local success, orderedDataStore = pcall(function()
		return DataStore:GetOrderedDataStore(dataStoreName)
	end)
	
	if not success then
		handleDataStoreError("GetOrderedDataStore", "N/A", dataStoreName)
		return nil
	end

	local success, data = pcall(function()
		return orderedDataStore:GetSortedAsync(sortAscending, pageSize)
	end)

	if success then
		return data
	else
		handleDataStoreError("GetSortedData", "N/A", dataStoreName)
		return nil
	end
end

-- Get current page
function MyModule.getCurrentPage(dataStorePages)
	if not dataStorePages then
		warn("DataStorePages object is nil")
		return nil
	end
	
	-- Get information
	local success, currentPage = pcall(function()
		return dataStorePages:GetCurrentPage()
	end)

	if success then
		return currentPage
	else
		warn("Failed to get the current page")
		return nil
	end
end

-- Utility function to fix the data type
function MyModule.checkDataType(value, expectedType)
	if type(value) ~= expectedType then
		
		-- Value was not correct
		warn(string.format("Expected data type [%s], got [%s]", expectedType, type(value)))
		return nil
	end

	return value
end

return MyModule
