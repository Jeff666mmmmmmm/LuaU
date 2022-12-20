local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local P = 8

local X = 0
local Y = 0

local m = 0
local changeQ = true

local Visualtype = "D"
local VisualtypeText = "Distance"

local function newSquares()
	changeQ = false
	task.wait(0.1)
	script.Parent.Quality.Text = ("Quality: "..P.." Video Type: "..VisualtypeText)
	
	for i,v in pairs(script.Parent:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	local X1 = 0
	local Y1 = 0

	while Y1 < 200 do
	
		local new = Instance.new("Frame")
		new.Parent = script.Parent
		new.Position = UDim2.new(0, X1, 0, Y1)
		new.Size = UDim2.new(0, P, 0, P)
		new.Name = (X1.."N"..Y1)
		new.BorderSizePixel = 0
		
		script.Parent[X1.."N"..Y1].BackgroundColor3 = Color3.fromRGB(141, 47, 47)
	
		X1 += P
		if X1 > 200 then
			X1 = 0
			Y1 += P
			task.wait(0.03)
		end
	end
	
	changeQ = true
end
newSquares()


mouse.Move:Connect(function()
	m = 8
	script.Parent.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
end)

local function onInputBegan(input, gameProcessed)

	if not gameProcessed then

		if input.KeyCode == Enum.KeyCode.R then
			if changeQ == true then
				Visualtype = "C"
				VisualtypeText = "Color"
				script.Parent.Quality.Text = ("Quality: "..P.." Video Type: "..VisualtypeText)
			end
		end

		if input.KeyCode == Enum.KeyCode.T then
			if changeQ == true then
				Visualtype = "D"
				VisualtypeText = "Distance"
				script.Parent.Quality.Text = ("Quality: "..P.." Video Type: "..VisualtypeText)
			end
		end
		
		if input.KeyCode == Enum.KeyCode.F then
			if changeQ == true then
				Visualtype = "H"
				VisualtypeText = "Heat"
				script.Parent.Quality.Text = ("Quality: "..P.." Video Type: "..VisualtypeText)
			end
		end

		if input.KeyCode == Enum.KeyCode.E then	
			if changeQ == true then
				local oldP = P

				if P == 5 then
					P = 4
				end
				if P == 8 then
					P = 5
				end
				if P == 10 then
					P = 8
				end
				if P == 20 then
					P = 10
				end
				if P == 25 then
					P = 20
				end	

				if oldP ~= P then
					newSquares()
				end
			end
		end

		if input.KeyCode == Enum.KeyCode.Q then	
			if changeQ == true then
				local oldP = P

				if P == 20 then
					P = 25
				end
				if P == 10 then
					P = 20
				end
				if P == 8 then
					P = 10
				end
				if P == 5 then
					P = 8
				end
				if P == 4 then
					P = 5
				end

				if oldP ~= P then
					newSquares()
				end
			end
		end

	end	
end
UserInputService.InputBegan:Connect(onInputBegan)

X = 0
Y = 0

while true do task.wait(0.1)
	while changeQ do

		local unitRay = camera:ScreenPointToRay(script.Parent[X.."N"..Y].AbsolutePosition.X, script.Parent[X.."N"..Y].AbsolutePosition.Y)
		local ray = workspace:Raycast(unitRay.Origin, unitRay.Direction * 255)

		if ray then

			if Visualtype == "C" then
				script.Parent[X.."N"..Y].BackgroundColor3 = ray.Instance.Color
			end

			if Visualtype == "D" then
				script.Parent[X.."N"..Y].BackgroundColor3 = Color3.fromRGB(0, math.round(ray.Distance), 0)
			end
			
			if Visualtype == "H" then
				
				local H = ray.Instance:FindFirstChild("Heat")
				if H then
					script.Parent[X.."N"..Y].BackgroundColor3 = Color3.fromRGB((math.round(ray.Distance)+H.Value), 0, 0)
				else
					script.Parent[X.."N"..Y].BackgroundColor3 = Color3.fromRGB(255-math.round(ray.Distance), 255-math.round(ray.Distance), 255-math.round(ray.Distance))
				end
				
			end

		end


		X += P
		if X > 200 then
			X = 0
			Y += P
			--task.wait(0.05)
		end

		if Y  > (200-P) then
			Y = 0
			X = 0
			if m > 0 then
				task.wait(0.03)
				m -= 1
			else

				for i = 0, 5 do
					task.wait(0.4)
					if m > 0 then break end
				end

			end

		end
	end
end
