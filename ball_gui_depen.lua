

return function(settings)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- BALL
------------------------------------------------
local ball = workspace:WaitForChild(settings.baller)
local function getSpeed()
    return settings.speed
end

------------------------------------------------
-- INPUT STATE
------------------------------------------------
local inputDir = Vector3.zero
local connection

------------------------------------------------
-- CAMERA (SPECTATE MODE)
------------------------------------------------
local function enableCamera()
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = ball
	print("[CAMERA] Spectate ON (free look)")
end

local function disableCamera()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		camera.CameraSubject = humanoid
	end

	print("[CAMERA] Spectate OFF")
end

------------------------------------------------
-- MOVEMENT (FULL 3D FLY MODE)
------------------------------------------------
local function updateMovement(dir)
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local forward = look
	local strafe = right

	if forward.Magnitude > 0 then forward = forward.Unit end
	if strafe.Magnitude > 0 then strafe = strafe.Unit end

	local moveDir =
		(forward * dir.Z) +
		(strafe * dir.X)

	local currentVel = ball.AssemblyLinearVelocity
	local targetVel = Vector3.zero

	if moveDir.Magnitude > 0 then
		targetVel = moveDir.Unit * getSpeed()
	end

	-- 🔥 FULL 3D VELOCITY (NO Y LOCK AT ALL)
	ball.AssemblyLinearVelocity = targetVel
end

------------------------------------------------
-- START / STOP
------------------------------------------------
local function start()
	print("[ON] Flying ball enabled")
	enableCamera()
    local args = {
        [1] = workspace.baller
    }

    game:GetService("ReplicatedStorage").ChangeOwner:FireServer(unpack(args))

	connection = RunService.RenderStepped:Connect(function()
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir += Vector3.new(0, 0, 1)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir += Vector3.new(0, 0, -1)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir += Vector3.new(-1, 0, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir += Vector3.new(1, 0, 0)
        end
        updateMovement(dir)
    end)
end

local function stop()
	print("[OFF] Flying ball disabled")

	inputDir = Vector3.zero
	ball.AssemblyLinearVelocity = Vector3.zero
	disableCamera()

	if connection then
		connection:Disconnect()
		connection = nil
	end
end
--newinput

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == settings.keybind then
        print("----- TOGGLE -----")
        print("ENABLED:", settings.enabled)
        print("inputDir:", inputDir)
        print("LookVector:", camera.CFrame.LookVector)
        print("Velocity:", ball.AssemblyLinearVelocity)
		settings.enabled = not settings.enabled

		if settings.enabled then
			start()
		else
			stop()
		end
	end
end)
end
