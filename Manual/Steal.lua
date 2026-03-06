-- [[ OYB HUB PREMIUM - MODULE: STEAL ]] --

local API = getgenv().OYB_API
local StealPage = API.UI.StealPage
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local searchRow = Instance.new("Frame", StealPage)
searchRow.Size = UDim2.new(1, -10, 0, 30); searchRow.Position = UDim2.new(0, 0, 0, 2); searchRow.BackgroundTransparency = 1

local searchBox = Instance.new("TextBox", searchRow)
searchBox.Size = UDim2.new(1, -85, 1, 0); searchBox.PlaceholderText = "Search units..."; searchBox.Text = ""
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.Font = "Gotham"; searchBox.TextSize = 11; searchBox.ClearTextOnFocus = false; Instance.new("UICorner", searchBox)
local sp = Instance.new("UIPadding", searchBox); sp.PaddingLeft = UDim.new(0, 8)

local filterBtn = Instance.new("TextButton", searchRow)
filterBtn.Size = UDim2.new(0, 75, 1, 0); filterBtn.Position = UDim2.new(1, -75, 0, 0); filterBtn.Text = "Filter  v"
filterBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); filterBtn.TextColor3 = Color3.new(1,1,1); filterBtn.Font = "GothamBold"; filterBtn.TextSize = 11
Instance.new("UICorner", filterBtn)

local dupBtn = Instance.new("TextButton", StealPage)
dupBtn.Size = UDim2.new(1, -10, 0, 24); dupBtn.Position = UDim2.new(0, 0, 0, 36)
dupBtn.Text = "Show Duplicates: ON"; dupBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 55)
dupBtn.TextColor3 = Color3.new(1,1,1); dupBtn.Font = "GothamBold"; dupBtn.TextSize = 10; Instance.new("UICorner", dupBtn)

local unitsScroll = Instance.new("ScrollingFrame", StealPage)
unitsScroll.Size = UDim2.new(1, -10, 1, -66); unitsScroll.Position = UDim2.new(0, 0, 0, 64)
unitsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20); unitsScroll.BorderSizePixel = 0; unitsScroll.ScrollBarThickness = 3; unitsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", unitsScroll)
local unitsLayout = Instance.new("UIListLayout", unitsScroll); unitsLayout.Padding = UDim.new(0, 8); unitsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
unitsLayout.SortOrder = Enum.SortOrder.LayoutOrder
local unitspad = Instance.new("UIPadding", unitsScroll); unitspad.PaddingTop = UDim.new(0, 6)

local noUnitLabel = Instance.new("TextLabel", unitsScroll); noUnitLabel.Size = UDim2.new(1, 0, 0, 50); noUnitLabel.BackgroundTransparency = 1;
noUnitLabel.Text = "No Characters Found"; noUnitLabel.TextColor3 = Color3.fromRGB(150, 150, 150); noUnitLabel.Font = "GothamBold"; noUnitLabel.TextSize = 12; noUnitLabel.Visible = false

local filterPopup = Instance.new("Frame", API.UI.ScreenGui); filterPopup.Size = UDim2.new(0, 155, 0, 0); filterPopup.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
filterPopup.ClipsDescendants = true; filterPopup.Visible = false; filterPopup.ZIndex = 20
Instance.new("UICorner", filterPopup).CornerRadius = UDim.new(0, 8)
local popupStroke = Instance.new("UIStroke", filterPopup); popupStroke.Thickness = 2; popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
task.spawn(function() while task.wait() do popupStroke.Color = Color3.fromHSV(tick()%5/5, 0.8, 1) end end)

local function UpdatePopupPos()
    local ap = filterBtn.AbsolutePosition; local as = filterBtn.AbsoluteSize; filterPopup.Position = UDim2.new(0, ap.X + as.X - 155, 0, ap.Y + as.Y + 4)
end

local fHeader = Instance.new("Frame", filterPopup); fHeader.Size = UDim2.new(1,0,0,28); fHeader.BackgroundColor3 = Color3.fromRGB(30,30,30); fHeader.ZIndex = 21; Instance.new("UICorner", fHeader).CornerRadius = UDim.new(0, 8)
local fTitle = Instance.new("TextLabel", fHeader); fTitle.Size = UDim2.new(0.7,0,1,0); fTitle.BackgroundTransparency = 1; fTitle.Text = "Filter Ranks"
fTitle.TextColor3 = Color3.fromRGB(0,170,255); fTitle.Font = "GothamBold"; fTitle.TextSize = 11; fTitle.ZIndex = 22
local ftp = Instance.new("UIPadding", fTitle); ftp.PaddingLeft = UDim.new(0, 8)
local fCloseBtn = Instance.new("TextButton", fHeader); fCloseBtn.Size = UDim2.new(0, 22, 0, 22); fCloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
fCloseBtn.BackgroundColor3 = Color3.fromRGB(180,30,30); fCloseBtn.Text = "X"; fCloseBtn.TextColor3 = Color3.new(1,1,1); fCloseBtn.Font = "GothamBold"; fCloseBtn.TextSize = 10; fCloseBtn.ZIndex = 22; Instance.new("UICorner", fCloseBtn).CornerRadius = UDim.new(0, 4)

local fClearBtn = Instance.new("TextButton", filterPopup); fClearBtn.Size = UDim2.new(1, -10, 0, 22); fClearBtn.Position = UDim2.new(0, 5, 0, 32); fClearBtn.BackgroundColor3 = Color3.fromRGB(60,20,20); fClearBtn.Text = "Clear Filters";
fClearBtn.TextColor3 = Color3.fromRGB(255,80,80); fClearBtn.Font = "GothamBold"; fClearBtn.TextSize = 10; fClearBtn.ZIndex = 21; Instance.new("UICorner", fClearBtn).CornerRadius = UDim.new(0, 5)

local fScroll = Instance.new("ScrollingFrame", filterPopup); fScroll.Size = UDim2.new(1, -6, 1, -60); fScroll.Position = UDim2.new(0, 3, 0, 58); fScroll.BackgroundTransparency = 1; fScroll.ScrollBarThickness = 2; fScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; fScroll.ZIndex = 21
local fLayout = Instance.new("UIListLayout", fScroll); fLayout.Padding = UDim.new(0, 4); local fpd = Instance.new("UIPadding", fScroll); fpd.PaddingTop = UDim.new(0, 2)

local FilterCategories = {}
for _, r in ipairs(API.Constants.Ranks) do table.insert(FilterCategories, r) end
table.insert(FilterCategories, "Lucky Blocks")

local filterRankBtns = {}
for _, r in ipairs(FilterCategories) do
    local fb = Instance.new("TextButton", fScroll)
    fb.Size = UDim2.new(1, 0, 0, 26); fb.Text = r; fb.BackgroundColor3 = Color3.fromRGB(35,35,35); fb.TextColor3 = Color3.new(1,1,1); fb.Font = "GothamBold"; fb.TextSize = 10; fb.ZIndex = 22; Instance.new("UICorner", fb).CornerRadius = UDim.new(0, 5)
    fb.MouseButton1Click:Connect(function()
        if API.State.ActiveFilters[r] then 
            API.State.ActiveFilters[r] = nil; fb.BackgroundColor3 = Color3.fromRGB(35,35,35); fb.TextColor3 = Color3.new(1,1,1)
        else 
            API.State.ActiveFilters[r] = true; fb.BackgroundColor3 = Color3.fromRGB(0,120,255); fb.TextColor3 = Color3.new(1,1,1) 
        end
        if API.Functions.UpdateUnits then API.Functions.UpdateUnits() end 
    end)
    filterRankBtns[r] = fb
end

local FILTER_H   = 295
local filterBusy = false
API.Functions.SetFilterOpen = function(open)
    if filterBusy then return end
    filterBusy = true; API.State.FilterOpen = open; filterBtn.Text = open and "Filter  ^" or "Filter  v"
    if open then UpdatePopupPos(); filterPopup.Visible = true end
    local tw = TweenService:Create(filterPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 155, 0, open and FILTER_H or 0)})
    tw:Play(); tw.Completed:Connect(function() filterBusy = false; if not open then filterPopup.Visible = false end end)
end

filterBtn.MouseButton1Click:Connect(function() API.Functions.SetFilterOpen(not API.State.FilterOpen) end)
fCloseBtn.MouseButton1Click:Connect(function() API.Functions.SetFilterOpen(false) end)
fClearBtn.MouseButton1Click:Connect(function()
    API.State.ActiveFilters = {}
    for _, fb2 in pairs(filterRankBtns) do fb2.BackgroundColor3 = Color3.fromRGB(35,35,35); fb2.TextColor3 = Color3.new(1,1,1) end
    if API.Functions.UpdateUnits then API.Functions.UpdateUnits() end 
end)

UserInputService.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not API.State.FilterOpen then return end
    local mp = inp.Position; local fp = filterPopup.AbsolutePosition; local fs = filterPopup.AbsoluteSize
    local onPopup = mp.X >= fp.X and mp.X <= fp.X+fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y+fs.Y
    local bp = filterBtn.AbsolutePosition; local bs = filterBtn.AbsoluteSize
    local onBtn = mp.X >= bp.X and mp.X <= bp.X+bs.X and mp.Y >= bp.Y and mp.Y <= bp.Y+bs.Y
    if not onPopup and not onBtn then API.Functions.SetFilterOpen(false) end
end)

local UiButtonsCache = {}
local function AddToggleDynamic(uid, displayName, spawned, parent, targetTable, layoutOrder)
    local existing = UiButtonsCache[uid]
    local newTextColor = spawned and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    local newBgColor = targetTable[uid] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)

    if existing then
        if existing.Text ~= displayName then existing.Text = displayName end
        if existing.TextColor3 ~= newTextColor then existing.TextColor3 = newTextColor end
        if existing.BackgroundColor3 ~= newBgColor then existing.BackgroundColor3 = newBgColor end
        if existing.LayoutOrder ~= layoutOrder then existing.LayoutOrder = layoutOrder end
        return 
    end
    
    local btn = Instance.new("TextButton")
    btn.Name = tostring(uid) 
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = newBgColor
    btn.Text = displayName
    btn.TextColor3 = newTextColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.LayoutOrder = layoutOrder 
    Instance.new("UICorner", btn)
    btn:SetAttribute("UID", uid)
    
    btn.MouseButton1Click:Connect(function()
        -- [تم الإصلاح هنا: استخدام المرجع المباشر API.State بدلاً من الجدول المؤقت القديم لمنع الجلتش بعد الـ Clear]
        API.State.SelectedUnits[uid] = not API.State.SelectedUnits[uid]
        btn.BackgroundColor3 = API.State.SelectedUnits[uid] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
    end)
    
    btn.Parent = parent
    UiButtonsCache[uid] = btn 
end

API.Functions.UpdateUnits = function()
    API.State.LiveModelsCache = {} 
    local liveGroups = {} 
    
    if API.Constants.BrainrotsFolder then
        for _, folder in pairs(API.Constants.BrainrotsFolder:GetChildren()) do
            for _, m in pairs(folder:GetChildren()) do
                local actualModel = m:FindFirstChildOfClass("Model") or m
                local baseName = API.Functions.GetBaseName(actualModel.Name)
                if not liveGroups[baseName] then liveGroups[baseName] = {} end
                table.insert(liveGroups[baseName], { model = m, time = API.Functions.GetUnitTime(m), id = API.Functions.GetModelUID(actualModel) })
            end
        end
    end
    
    if API.Constants.LuckyBlocksFolder then
        for _, b in pairs(API.Constants.LuckyBlocksFolder:GetChildren()) do
            local baseName = API.Functions.GetBaseName(b.Name)
            if not liveGroups[baseName] then liveGroups[baseName] = {} end
            table.insert(liveGroups[baseName], { model = b, time = API.Functions.GetUnitTime(b), id = API.Functions.GetModelUID(b) })
        end
    end

    for _, list in pairs(liveGroups) do table.sort(list, function(a, b) return a.time > b.time end) end

    local validUIDs = {}
    local found = false
    local hasFilter = next(API.State.ActiveFilters) ~= nil
    local unitsToDisplay = {} 

    for rank, units in pairs(API.State.PermanentCache) do
        if type(units) == "table" then
            for _, uName in pairs(units) do
                local isLuckyBlock = (uName:lower():find("lucky block") ~= nil) or (uName:lower():find("natural lucky block") ~= nil) or (uName:lower():find("eventspawnluckyblock") ~= nil)
                local passesFilter = not hasFilter
                if hasFilter then
                    if isLuckyBlock and API.State.ActiveFilters["Lucky Blocks"] then passesFilter = true
                    elseif API.State.ActiveFilters[rank] then passesFilter = true end
                end

                if passesFilter then
                    if API.State.SearchText == "" or uName:lower():find(API.State.SearchText:lower(), 1, true) then
                        local list = liveGroups[uName] or {}
                        local total = #list
                        
                        if API.State.ShowDuplicates and total > 0 then
                            for i, data in ipairs(list) do
                                local uid = uName .. "::" .. data.id
                                API.State.LiveModelsCache[uid] = data.model 
                                local btnLabel = API.Functions.BeautifyName(uName) .. " [" .. i .. "/" .. total .. "]"
                                if data.time >= 0 then btnLabel = btnLabel .. " (" .. data.time .. "s)" end
                                table.insert(unitsToDisplay, {uid = uid, label = btnLabel, spawned = true, nameForSort = API.Functions.BeautifyName(uName):lower()})
                            end
                        else
                            local uid = uName
                            local spawned = (total > 0)
                            local btnLabel = API.Functions.BeautifyName(uName)
                            if spawned then btnLabel = btnLabel .. " (SPAWNED)" end
                            table.insert(unitsToDisplay, {uid = uid, label = btnLabel, spawned = spawned, nameForSort = API.Functions.BeautifyName(uName):lower()})
                        end
                    end
                end
            end
        end
    end

    table.sort(unitsToDisplay, function(a, b)
        if a.spawned ~= b.spawned then return a.spawned end
        return a.nameForSort < b.nameForSort 
    end)

    for index, data in ipairs(unitsToDisplay) do
        validUIDs[data.uid] = true
        AddToggleDynamic(data.uid, data.label, data.spawned, unitsScroll, API.State.SelectedUnits, index)
        found = true
    end

    for _, child in pairs(unitsScroll:GetChildren()) do
        if child:IsA("TextButton") then
            local childUid = child:GetAttribute("UID")
            if not validUIDs[childUid] then 
                UiButtonsCache[childUid] = nil
                child:Destroy()
                API.State.SelectedUnits[childUid] = nil
            end
        end
    end
    noUnitLabel.Visible = not found
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function() API.State.SearchText = searchBox.Text; API.Functions.UpdateUnits() end)
dupBtn.MouseButton1Click:Connect(function()
    API.State.ShowDuplicates = not API.State.ShowDuplicates
    dupBtn.Text = API.State.ShowDuplicates and "Show Duplicates: ON" or "Show Duplicates: OFF"
    dupBtn.BackgroundColor3 = API.State.ShowDuplicates and Color3.fromRGB(0,120,55) or Color3.fromRGB(150,35,35)
    API.State.SelectedUnits = {} 
    if API.Functions.UpdateUnits then API.Functions.UpdateUnits() end
end)
