-- AUTO FISH & CASH FARM - BRIDGER WESTERN
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Config = {
    Key = Enum.KeyCode.F6,
    Enabled = false,
    Mode = "FISH", -- Cambiar a "ENEMY" si prefieres solo matar mobs
    Delay = 1.0,
    FishSpotNames = {"Fish", "Water", "Dock", "Rod"}, -- Nombres comunes de spots de pesca
    EnemyNames = {"Enemy", "Mob", "Outlaw", "Wolf"} -- Nombres de enemigos para farmear cash
}

local function FindTarget(TargetType)
    local Targets = {}
    
    for _, Object in pairs(workspace:GetChildren()) do
        if Object:IsA("Model") or Object:IsA("BasePart") then
            local NameMatch = false
            local List = TargetType == "FISH" and Config.FishSpotNames or Config.EnemyNames
            
            for _, Keyword in ipairs(List) do
                if string.find(Object.Name:lower(), Keyword:lower()) then
                    NameMatch = true
                    break
                end
            end
            
            if NameMatch then
                local Dist = (Object.PrimaryPart.Position - RootPart.Position).Magnitude
                if Dist < 50 then -- Rango de búsqueda
                    table.insert(Targets, {Obj = Object, Dist = Dist})
                end
            end
        end
    end
    
    -- Ordenar por distancia más cercana
    table.sort(Targets, function(a, b) return a.Dist < b.Dist end)
    return #Targets > 0 and Targets[1].Obj or nil
end

local function Interact(Object)
    local Click = Object:FindFirstChildOfClass("ClickDetector")
    if Click then Click:MouseClick(Player); wait(Config.Delay); return end
    
    local Prompt = Object:FindFirstChildOfClass("ProximityPrompt")
    if Prompt then Prompt:Triggered(Player); wait(Config.Delay); return end
    
    -- Si es un enemigo, intentar atacarlo con ataque básico o evento remoto
    local Remote = Object:FindFirstChild("RemoteEvent") or Object:FindFirstChild("Attack")
    if Remote then 
        Remote:FireServer() 
        wait(Config.Delay) 
    end
end

local function Loop()
    while Config.Enabled do
        local Target = FindTarget(Config.Mode)
        
        if Target then
            -- Moverse hacia el objetivo si está lejos
            if (Target.PrimaryPart.Position - RootPart.Position).Magnitude > 15 then
                local Path = game:GetService("PathfindingService"):CreatePath()
                Path:ComputeAsync(RootPart.Position, Target.PrimaryPart.Position)
                for _, Waypoint in pairs(Path:GetWaypoints()) do
                    Humanoid:MoveTo(Waypoint.Position)
                    Humanoid.MoveToFinished:Wait(2)
                end
            else
                -- Si está cerca, interactuar
                Interact(Target)
            end
        else
            wait(1)
        end
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.Key then
        Config.Enabled = not Config.Enabled
        print("AutoFarm: " .. tostring(Config.Enabled))
        if Config.Enabled then task.spawn(Loop) end
    end
end)

print("Script cargado. Presiona F6.")