-- [[ OYB HUB PREMIUM - MODULE: ENGINE ]] --

local API = getgenv().OYB_API
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetFolders()
    return workspace:FindFirstChild("ActiveBrainrots"), workspace:FindFirstChild("ActiveLuckyBlocks")
end

local function GetBestTargetByName(uName)
    local best, highest = nil, -math.huge
    local BrainrotsFolder, LuckyBlocksFolder = GetFolders()

    if LuckyBlocksFolder then
        for _, b in pairs(LuckyBlocksFolder:GetChildren()) do
            if API.Functions.GetBaseName(b.Name) == uName then return b end
        end
    end
    if BrainrotsFolder then
        for _, folder in pairs(BrainrotsFolder:GetChildren()) do
            for _, child in pairs(folder:GetChildren()) do
                local actualModel = child:FindFirstChildOfClass("Model") or child
                if API.Functions.GetBaseName(actualModel.Name) == uName then 
                    local t = API.Functions.GetUnitTime(child)
                    if not best or t > highest then highest = t; best = child end 
                end
            end
        end
    end
    return best
end

local function GetBestTargetByRank(rank)
    local best, highest = nil, -math.huge
    local BrainrotsFolder, _ = GetFolders()

    if BrainrotsFolder and BrainrotsFolder:FindFirstChild(rank) then
        for _, child in pairs(BrainrotsFolder[rank]:GetChildren()) do
            local actualModel = child:FindFirstChildOfClass("Model") or child
            if actualModel and actualModel.Parent then
                local t = API.Functions.GetUnitTime(child)
                if not best or t > highest then highest = t; best = child end
            end
        end
    end
    return best
end

task.spawn(function()
    while task.wait(0.1) do
        if API.State.AutoFarmEnabled and not API.State.IsMoving then
            local target = nil
            
            for uidStr, active in pairs(API.State.SelectedUnits) do
                if active then
                    local sep = uidStr:find("::")
                    if sep then
                        local exactModel = API.State.LiveModelsCache[uidStr]
                        if exactModel and exactModel.Parent then
                            target = exactModel; break
                        else
                            API.State.SelectedUnits[uidStr] = nil
                        end
                    else
                        target = GetBestTargetByName(uidStr)
                        if target then break end
                    end
                end
            end
            
            if not target then
                for i = #API.Constants.Ranks, 1, -1 do
                    local rank = API.Constants.Ranks[i]
                    if API.State.SelectedRanksAuto[rank] then
                        local BrainrotsFolder, LuckyBlocksFolder = GetFolders()
                        if API.State.AutoRankTarget == "LuckyBlocks" and LuckyBlocksFolder then
                            for _, b in pairs(LuckyBlocksFolder:GetChildren()) do
                                if API.Functions.GetTargetRank(b.Name) == rank then
                                    target = b; break
                                end
                            end
                            if target then break end
                        elseif API.State.AutoRankTarget == "Brainrots" then
                            local bestUnit = GetBestTargetByRank(rank)
                            if bestUnit then target = bestUnit; break end
                        end
                    end
                end
            end
            
            if target and target.Parent then
                local rp = target:FindFirstChild("Root") or target:FindFirstChild("RootPart") or target:FindFirstChildOfClass("Part") or target:FindFirstChildOfClass("MeshPart")
                if not rp and target:IsA("BasePart") then rp = target end 
                local prompt = target:FindFirstChildOfClass("ProximityPrompt", true) or (rp and rp:FindFirstChildOfClass("ProximityPrompt")) or (rp and rp:FindFirstChild("TakePrompt"))
                
                if rp and prompt and target.Parent then
                    API.Functions.CustomMove(rp.Position, false, target)
                    if target and target.Parent then 
                        local start = tick();
                        
                        -- [تم التنظيف الشامل لمنع הلاق]: حلقة بسيطة جداً لا تضغط على معالج اللعبة
                        repeat 
                            fireproximityprompt(prompt)
                            task.wait(0.1) 
                        until not target or not target.Parent or (tick()-start) > 3.5 or not API.State.AutoFarmEnabled 
                    end
                    API.Functions.CustomMove(API.State.SafeZonePos, true)
                end
            end
        end
    end
end)

local function UpdatePermanentCacheInternal()
    local changed = false
    local BrainrotsFolder, LuckyBlocksFolder = GetFolders()

    for _, r in pairs(API.Constants.Ranks) do
        if not API.State.PermanentCache[r] then API.State.PermanentCache[r] = {}; changed = true end
        if BrainrotsFolder and BrainrotsFolder:FindFirstChild(r) then
            for _, m in pairs(BrainrotsFolder[r]:GetChildren()) do
                local actualModel = m:FindFirstChildOfClass("Model") or m
                local baseName = API.Functions.GetBaseName(actualModel.Name)
                if not table.find(API.State.PermanentCache[r], baseName) then table.insert(API.State.PermanentCache[r], baseName); changed = true end
            end
        end
    end
    
    if LuckyBlocksFolder then
        for _, b in pairs(LuckyBlocksFolder:GetChildren()) do
            local baseName = API.Functions.GetBaseName(b.Name)
            local targetR = API.Functions.GetTargetRank(b.Name)
            if targetR ~= "Unknown" then
                if not API.State.PermanentCache[targetR] then API.State.PermanentCache[targetR] = {}; changed = true end
                if not table.find(API.State.PermanentCache[targetR], baseName) then table.insert(API.State.PermanentCache[targetR], baseName); changed = true end
            end
        end
    end
    if changed then API.Functions.SaveJSON(API.Constants.CacheFileName, API.State.PermanentCache) end
end

task.spawn(function()
    while task.wait(1) do
        UpdatePermanentCacheInternal()
        if API.UI.StealPage and API.UI.StealPage.Visible and API.Functions.UpdateUnits then 
            API.Functions.UpdateUnits() 
        end
    end
end)
