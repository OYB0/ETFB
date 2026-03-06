-- [[ OYB HUB PREMIUM - MODULE: SETTINGS ]] --

local API = getgenv().OYB_API
local SettingsPage = API.UI.SettingsPage

local settingsScroll = Instance.new("ScrollingFrame", SettingsPage)
settingsScroll.Size = UDim2.new(1, -30, 1, 0); settingsScroll.Position = UDim2.new(0, 15, 0, 0)
settingsScroll.BackgroundTransparency = 1; settingsScroll.ScrollBarThickness = 3; settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", settingsScroll).Padding = UDim.new(0, 8)

local function createSetting(text, default, key)
    local f = Instance.new("Frame", settingsScroll); f.Size = UDim2.new(0.9, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = text
    l.TextColor3 = Color3.new(1,1,1); l.Font = "GothamBold"; l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    local b = Instance.new("TextBox", f); b.Size = UDim2.new(0.35, 0, 0.8, 0); b.Position = UDim2.new(0.65, 0, 0.1, 0)
    b.Text = tostring(default); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.fromRGB(0, 255, 150); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    b.FocusLost:Connect(function() 
        API.Config[key] = tonumber(b.Text) or default
        API.Functions.SaveJSON(API.Constants.CacheFileName:gsub("UnitCache", "Config"), API.Config) 
    end)
end

local modeBtn = Instance.new("TextButton", settingsScroll)
modeBtn.Size = UDim2.new(0.9, 0, 0, 40); modeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
modeBtn.Text = "MODE: " .. API.Config.MoveMode; modeBtn.TextColor3 = Color3.new(1,1,1); modeBtn.Font = "GothamBold"; Instance.new("UICorner", modeBtn)
modeBtn.MouseButton1Click:Connect(function()
    API.Config.MoveMode = (API.Config.MoveMode == "Tween") and "Teleport" or "Tween"
    modeBtn.Text = "MODE: " .. API.Config.MoveMode
    API.Functions.SaveJSON(API.Constants.CacheFileName:gsub("UnitCache", "Config"), API.Config)
end)

createSetting("Tween Speed", API.Config.TweenSpeed, "TweenSpeed")
createSetting("TP Distance",  API.Config.TPDistance, "TPDistance")
createSetting("TP Delay",     API.Config.TPDelay,    "TPDelay")
