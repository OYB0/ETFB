-- [[ OYB HUB PREMIUM - MODULE: AUTO RANK ]] --

local API = getgenv().OYB_API
local AutoRankPage = API.UI.AutoRankPage

local targetToggleBtn = Instance.new("TextButton", AutoRankPage)
targetToggleBtn.Size = UDim2.new(1, -30, 0, 30); targetToggleBtn.Position = UDim2.new(0, 15, 0, 5)
targetToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); targetToggleBtn.Text = "FARMING: BRAINROTS"
targetToggleBtn.TextColor3 = Color3.new(1,1,1); targetToggleBtn.Font = "GothamBold"; targetToggleBtn.TextSize = 11; Instance.new("UICorner", targetToggleBtn)

targetToggleBtn.MouseButton1Click:Connect(function()
    if API.State.AutoRankTarget == "Brainrots" then
        API.State.AutoRankTarget = "LuckyBlocks"
        targetToggleBtn.Text = "FARMING: LUCKY BLOCKS"
        targetToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
    else
        API.State.AutoRankTarget = "Brainrots"
        targetToggleBtn.Text = "FARMING: BRAINROTS"
        targetToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)

local autoRankScroll = Instance.new("ScrollingFrame", AutoRankPage)
autoRankScroll.Size = UDim2.new(1, -30, 1, -45); autoRankScroll.Position = UDim2.new(0, 15, 0, 40)
autoRankScroll.BackgroundColor3 = Color3.fromRGB(20,20,20); autoRankScroll.BorderSizePixel = 0
autoRankScroll.ScrollBarThickness = 3; autoRankScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UICorner", autoRankScroll)
local autoRankLayout = Instance.new("UIListLayout", autoRankScroll)
autoRankLayout.Padding = UDim.new(0, 8); autoRankLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local arp = Instance.new("UIPadding", autoRankScroll); arp.PaddingTop = UDim.new(0, 6)

for _, r in ipairs(API.Constants.Ranks) do
    local b = Instance.new("TextButton", autoRankScroll)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = r; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        API.State.SelectedRanksAuto[r] = not API.State.SelectedRanksAuto[r]
        b.BackgroundColor3 = API.State.SelectedRanksAuto[r] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 35)
    end)
end
