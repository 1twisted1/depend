return function(settings)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- BALL
------------------------------------------------
local function getBall()
    if not settings.baller or settings.baller == "" then
        return nil
    end
    return workspace:FindFirstChild(settings.baller)
end

local function getSpeed()
    return settings.speed
end

------------------------------------------------
-- INPUT STATE
------------------------------------------------
local connection

------------------------------------------------
-- CAMERA
------------------------------------------------
local function enableCamera()
    local ball = getBall()
    if not ball then return end

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = ball
end

local function disableCamera()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        camera.CameraSubject = humanoid
    end
end

------------------------------------------------
-- MOVEMENT
------------------------------------------------
local function updateMovement(dir)
    local ball = getBall()
    if not ball then return end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector

    local forward = look
    local strafe = right

    if forward.Magnitude > 0 then forward = forward.Unit end
    if strafe.Magnitude > 0 then strafe = strafe.Unit end

    local moveDir = (forward * dir.Z) + (strafe * dir.X)

    local targetVel = Vector3.zero

    if moveDir.Magnitude > 0 then
        targetVel = moveDir.Unit * getSpeed()
    end

    ball.AssemblyLinearVelocity = targetVel
end

------------------------------------------------
-- START / STOP
------------------------------------------------
local function start()
    print("[ON] Flying ball enabled")

    local ball = getBall()
    if ball then
        game:GetService("ReplicatedStorage").ChangeOwner:FireServer(ball)
    end

    enableCamera()

    if connection then connection:Disconnect() end

    connection = RunService.RenderStepped:Connect(function()
        if not settings.enabled then return end

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

    local ball = getBall()
    if ball then
        ball.AssemblyLinearVelocity = Vector3.zero
    end

    disableCamera()

    if connection then
        connection:Disconnect()
        connection = nil
    end
end

------------------------------------------------
-- TOGGLE
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == settings.keybind then
        settings.enabled = not settings.enabled

        if settings.enabled then
            start()
        else
            stop()
        end
    end
end)

end