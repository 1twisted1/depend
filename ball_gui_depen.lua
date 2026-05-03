return function(settings)
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local connection

    ------------------------------------------------
    -- HELPERS
    ------------------------------------------------
    local function getBall()
        if settings.baller == "" then return nil end
        return workspace:FindFirstChild(settings.baller)
    end

    local function getSpeed()
        return settings.speed
    end
	 local function gettoggle()
        return settings.enabled
    end

    ------------------------------------------------
    -- CAMERA
    ------------------------------------------------
    local function enableCamera(ball)
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = ball
    end

    local function disableCamera()
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
        end
        camera.CameraType = Enum.CameraType.Custom
    end

    ------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------
    local function updateMovement(ball, dir)
        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector

        local moveDir = (look * dir.Z) + (right * dir.X)

        if moveDir.Magnitude > 0 then
            ball.AssemblyLinearVelocity = moveDir.Unit * getSpeed()
        else
            ball.AssemblyLinearVelocity = Vector3.zero
        end
    end

    ------------------------------------------------
    -- START / STOP
    ------------------------------------------------
    local function start()
        local ball = getBall()
        if not ball then
            warn("[ERROR] No ball selected or ball not found in workspace.")
            settings.enabled = false
            return
        end

        print("[ON] Ball control enabled:", ball.Name)
        enableCamera(ball)

        -- Request network ownership
        local changeOwner = ReplicatedStorage:FindFirstChild("ChangeOwner")
        if changeOwner then
            changeOwner:FireServer(ball)
        else
            warn("[WARN] ChangeOwner RemoteEvent not found in ReplicatedStorage")
        end

        connection = RunService.RenderStepped:Connect(function()
            local dir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir += Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir += Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(1, 0, 0) end

            updateMovement(ball, dir)
        end)
    end

    local function stop()
        settings.enabled = false
        print("[OFF] Ball control disabled")

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
    -- KEYBIND TOGGLE
    ------------------------------------------------
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode ~= settings.keybind then return end

        settings.enabled = not settings.enabled

        if gettoggle() then
            start()
        else
            stop()
        end
    end)
end