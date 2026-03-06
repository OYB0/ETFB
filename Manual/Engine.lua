-- [[ OYB HUB PREMIUM - MODULE: ENGINE ]] --

local API = getgenv().OYB_API
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetBestTargetByName(uName)
    local best, highest = nil, -math.huge
    if API.Constants.LuckyBlocksFolder then
        for _, b in pairs(API.Constants.LuckyBlocksFolder:GetChildren()) do
            if API.Functions.GetBaseName(b.Name) == uName then return b end
        end
    end
    if API.Constants.BrainrotsFolder then
        for _, folder in pairs(API.Constants.BrainrotsFolder:GetChildren()) do
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
    if API.Constants.BrainrotsFolder and API.Constants.BrainrotsFolder:FindFirstChild(rank) then
        for _, child in pairs(API.Constants.BrainrotsFolder[rank]:GetChildren()) do
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
                        
                        if API.State.AutoRankTarget == "LuckyBlocks" and API.Constants.LuckyBlocksFolder then
                            for _, b in pairs(API.Constants.LuckyBlocksFolder:GetChildren()) do
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
                        -- [تم الإصلاح للأجهزة الضعيفة]: تحسين منطق الالتقاط ليكون أسرع وأقل لاق
                        local start = tick();
                        local holdTime = prompt.HoldDuration or 0
                        
                        -- تنفيذ الضغطة الأولى فوراً
                        fireproximityprompt(prompt);
                        
                        -- إذا كان الزر يحتاج وقت (Hold)، ننتظر قليلاً بدلاً من تكرار الضغط آلاف المرات
                        if holdTime > 0 then
                            task.wait(holdTime + 0.1) 
                        end
                        
                        -- حلقة فحص نهائية للتأكد من نجاح الأخذ
                        repeat 
                            fireproximityprompt(prompt);
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                                -- تقليل ضغط الفيزياء أثناء عملية Hold
                                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0);
                                -- نحدث الـ CFrame بتكرار أقل لتوفير موارد الجهاز
                                if math.random(1, 3) == 1 then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position.X, API.State.FarmDepth, LocalPlayer.Character.HumanoidRootPart.Position.Z) 
                                end
                            end
                            task.wait(0.1) -- تم التعديل من 0.05 لتقليل اللاق بشكل كبير
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
    for _, r in pairs(API.Constants.Ranks) do
        if not API.State.PermanentCache[r] then API.State.PermanentCache[r] = {}; changed = true end
        if API.Constants.BrainrotsFolder and API.Constants.BrainrotsFolder:FindFirstChild(r) then
            for _, m in pairs(API.Constants.BrainrotsFolder[r]:GetChildren()) do
                local actualModel = m:FindFirstChildOfClass("Model") or m
                local baseName = API.Functions.GetBaseName(actualModel.Name)
                if not table.find(API.State.PermanentCache[r], baseName) then table.insert(API.State.PermanentCache[r], baseName); changed = true end
            end
        end
    end
    
    if API.Constants.LuckyBlocksFolder then
        for _, b in pairs(API.Constants.LuckyBlocksFolder:GetChildren()) do
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
