local scriptkey = shared.key

if scriptkey ~= 'FBYhfabvydf73.HJFadfhudsia.DSHsdfDFh6d878as' then
    return
end


local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local BodyVelocity, BodyGyro
local speedReset = false
local desyncConnection

local function GetChar(plr)
    local p = plr or LocalPlayer
    return p.Character, p.Character and p.Character:FindFirstChild("HumanoidRootPart"), p.Character and p.Character:FindFirstChildOfClass("Humanoid")
end

local Vault = Library:CreateWindow({ Title = "Vault | Paradox", NotifySide = "Right", Footer = "version: 2.0.0", ShowCustomCursor = false })
local Tabs = { ['MainTab'] = Vault:AddTab("Main", "user"), ['VisualsTab'] = Vault:AddTab("Visuals", "scan-eye"), ['ExploitsTab'] = Vault:AddTab("Exploits", "shield-alert"), ['AutomationTab'] = Vault:AddTab("Automation", "workflow"), ['UI Settings'] = Vault:AddTab("Config", "bolt") }

local MovementBox = Tabs['MainTab']:AddLeftTabbox()
local MovementTab1 = MovementBox:AddTab("Movement", "sport-shoe")
local MovementTab2 = MovementBox:AddTab("Settings", "settings")

MovementTab1:AddToggle("Flight", { Text = "Flight" }):AddKeyPicker("FlightKey", { Default = "None", SyncToggleState = true })
MovementTab1:AddToggle("AutoFall", { Text = "Auto Fall" }):AddKeyPicker("AutoFallKey", { Default = "None", SyncToggleState = true })
MovementTab1:AddToggle("Noclip", { Text = "Noclip" }):AddKeyPicker("NoclipKey", { Default = "None", SyncToggleState = true })
MovementTab1:AddToggle("SpeedToggle", { Text = "Speed" }):AddKeyPicker("SpeedKey", { Default = "None", SyncToggleState = true })
MovementTab1:AddToggle("HighJump", { Text = "High Jump" }):AddKeyPicker("HJumpKey", { Default = "None", SyncToggleState = true })
MovementTab1:AddToggle("InfJump", { Text = "Inf Jump" }):AddKeyPicker("IJumpKey", { Default = "None", SyncToggleState = true })

MovementTab2:AddSlider("FlightSpeed", { Text = "Flight Speed", Default = 100, Min = 5, Max = 300 })
MovementTab2:AddSlider("SpeedValue", { Text = "Speed Value", Default = 100, Min = 0, Max = 600 })
MovementTab2:AddSlider("JumpHeight", { Text = "Jump Height", Default = 100, Min = 0, Max = 500 })

local VTabSettings = Tabs['VisualsTab']:AddLeftGroupbox("ESP Settings")
VTabSettings:AddToggle("ESPboxes", { Text = "ESP Boxes", Default = true })
VTabSettings:AddSlider("textsize", { Text = "Text Size", Default = 16, Min = 8, Max = 32 })
VTabSettings:AddDropdown("espFont", { Text = "Font", Values = {"SourceSans", "Roboto", "Code", "Fantasy", "Arcade"}, Default = "SourceSans" })
VTabSettings:AddSlider("EspUpdate", { Text = "Refresh Rate", Default = 144, Min = 1, Max = 240 })

local PlayerESPSettings = Tabs['VisualsTab']:AddRightGroupbox("Player ESP")
PlayerESPSettings:AddToggle("PlayerESP", { Text = "Player ESP" }):AddColorPicker("PlrESPColor", { Default = Color3.fromRGB(255, 255, 255) })
PlayerESPSettings:AddSlider("PlayerESPDistance", { Text = "Distance", Default = 2000, Min = 0, Max = 10000 })
PlayerESPSettings:AddDropdown("PlayerESPBars", { Text = "Bars", Values = {"Health"}, Multi = true })

local MobESPSettings = Tabs['VisualsTab']:AddLeftGroupbox("Mob ESP")
MobESPSettings:AddToggle("MobESP", { Text = "Mob ESP" }):AddColorPicker("MobESPColor", { Default = Color3.fromRGB(255, 255, 255) })
MobESPSettings:AddSlider("MobESPDistance", { Text = "Mob Distance", Default = 2000, Min = 0, Max = 10000 })

local NpcESPSettings = Tabs['VisualsTab']:AddLeftGroupbox("Npc ESP")
NpcESPSettings:AddToggle("NpcESP", { Text = "Npc ESP" }):AddColorPicker("NpcESPColor", { Default = Color3.fromRGB(255, 255, 255) })
NpcESPSettings:AddSlider("NpcESPDistance", { Text = "Npc Distance", Default = 2000, Min = 0, Max = 10000 })

local JobESPSettings = Tabs['VisualsTab']:AddRightGroupbox("Job ESP")
JobESPSettings:AddToggle("JobESP", { Text = "Job ESP" })

local ExploitsGb = Tabs['ExploitsTab']:AddLeftGroupbox("Features")
ExploitsGb:AddToggle("Desync", { 
    Text = "Desync",
    Default = false,
    Callback = function(Value)
        _G.DesyncEnabled = Value
        
        -- Cleanup previous connection if it exists
        if desyncConnection then 
            desyncConnection:Disconnect() 
            desyncConnection = nil
        end

        -- Cleanup Proxy if it exists from a previous run
        local existingProxy = workspace:FindFirstChild("AntiFlickerProxy")
        if existingProxy then existingProxy:Destroy() end

        if _G.DesyncEnabled then
            local RunService = game:GetService("RunService")
            local player = game.Players.LocalPlayer
            local camera = workspace.CurrentCamera
            
            -- Create the Proxy
            local proxy = Instance.new("Part")
            proxy.Name = "AntiFlickerProxy"
            proxy.Transparency = 1
            proxy.CanCollide = false
            proxy.Anchored = true
            proxy.Parent = workspace
            
            camera.CameraSubject = proxy

            desyncConnection = RunService.Heartbeat:Connect(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and _G.DesyncEnabled then
                    local realCFrame = root.CFrame
                    proxy.CFrame = realCFrame
                    
                    -- The "Abyss" Teleport
                    root.CFrame = realCFrame * CFrame.new(0, 5000, 0)
                    
                    RunService.RenderStepped:Wait() 
                    
                    -- Return to Ground
                    if root then
                        root.CFrame = realCFrame
                    end
                end
            end)
        else
            -- Shutdown Logic
            local player = game.Players.LocalPlayer
            local camera = workspace.CurrentCamera
            
            -- Reset Camera Subject to Humanoid
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = player.Character.Humanoid
            end
            
            -- Final Proxy cleanup
            local proxy = workspace:FindFirstChild("AntiFlickerProxy")
            if proxy then proxy:Destroy() end
        end
    end
}):AddKeyPicker("DesyncKey", { 
    Default = "None", 
    SyncToggleState = true 
})

RunService.Stepped:Connect(function()
    local char, hrp, hum = GetChar() if not char or not hrp or not hum then return end
    if Toggles.Noclip.Value then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if Toggles.Flight.Value then
        if not BodyVelocity then 
            BodyVelocity = Instance.new("BodyVelocity", hrp) BodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
            BodyGyro = Instance.new("BodyGyro", hrp) BodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
            hum.PlatformStand = true 
        end
        local md = Vector3.new(0,0,0) local cf = Camera.CFrame
        if UserInputService:IsKeyDown("W") then md += cf.LookVector end if UserInputService:IsKeyDown("S") then md -= cf.LookVector end
        if UserInputService:IsKeyDown("A") then md -= cf.RightVector end if UserInputService:IsKeyDown("D") then md += cf.RightVector end
        if UserInputService:IsKeyDown("Space") then md += Vector3.new(0,1,0) elseif UserInputService:IsKeyDown("LeftControl") then md -= Vector3.new(0,1,0) end
        BodyVelocity.Velocity = md * Options.FlightSpeed.Value BodyGyro.CFrame = cf
    else if BodyVelocity then BodyVelocity:Destroy(); BodyGyro:Destroy(); BodyVelocity, BodyGyro = nil, nil; hum.PlatformStand = false end end
    if Toggles.SpeedToggle.Value then hum.WalkSpeed = Options.SpeedValue.Value speedReset = false else
        if not speedReset then hum.WalkSpeed = 16 speedReset = true end
    end
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox("Features")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(v) Library.KeybindFrame.Visible = v end })
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Vault-Themes"); SaveManager:SetFolder("Vault-Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"]); ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
