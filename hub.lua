local players = game:GetService("Players")
local run = game:GetService("RunService")
local ts = game:GetService("TweenService")
local lp = players.LocalPlayer

local cfg = {
    walkspeed_boost = 60,
    jumppower_boost = 90,
    fly_speed = 60,
    fly_vert_speed = 40,
    rescan = 1.0,
    teleport_speed = true,
    tween_time = 0.15,
    esp_color = Color3.fromRGB(255, 215, 0),
}

local pg = lp:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "ChilliStyleHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = pg

local outer = Instance.new("Frame")
outer.Size = UDim2.new(0, 130, 0, 220)
outer.Position = UDim2.new(1, -140, 0.3, 0)
outer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
outer.Active = true
outer.ZIndex = 998
outer.Parent = gui
Instance.new("UICorner", outer).CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.ZIndex = 999
titleBar.Parent = outer

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -26, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "HUB"
title.ZIndex = 999
title.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -26, 0, 1)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Text = "-"
minBtn.Active = true
minBtn.ZIndex = 999
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local scroller = Instance.new("ScrollingFrame")
scroller.Size = UDim2.new(1, 0, 1, -26)
scroller.Position = UDim2.new(0, 0, 0, 26)
scroller.BackgroundTransparency = 1
scroller.BorderSizePixel = 0
scroller.ScrollBarThickness = 4
scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.ZIndex = 999
scroller.Parent = outer

local frame = scroller

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 5)
list.Parent = frame

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 6)
pad.Parent = frame

local collapsed = false
minBtn.Activated:Connect(function()
    collapsed = not collapsed
    scroller.Visible = not collapsed
    outer.Size = collapsed and UDim2.new(0, 130, 0, 26) or UDim2.new(0, 130, 0, 220)
    minBtn.Text = collapsed and "+" or "-"
end)

local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = outer.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - dragStart
        outer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local function make_toggle(text, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.LayoutOrder = order
    b.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Text = text .. ": OFF"
    b.Active = true
    b.ZIndex = 999
    b.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    local state = false
    b.Activated:Connect(function()
        state = not state
        b.Text = text .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(180, 60, 60)
    end)
    return b, function() return state end
end

local char, hrp, hum
local ready = false
local collected = {}

local function bind_char(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart", 10)
    hum = c:WaitForChild("Humanoid", 10)
    ready = hrp ~= nil and hum ~= nil
    for k in pairs(collected) do collected[k] = nil end
end

if lp.Character then bind_char(lp.Character) end
lp.CharacterAdded:Connect(bind_char)

local function is_egg(inst)
    if not (inst:IsA("BasePart") or inst:IsA("Model")) then return false end
    local n = inst.Name:lower()
    if n:find("egg") or n:find("brainrot") or n:find("rot") then return true end
    if inst:GetAttribute("IsEgg") or inst:FindFirstChild("EggPrompt") then return true end
    return false
end

local function get_pos(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst.PrimaryPart then return inst.PrimaryPart.Position end
    local m = inst:FindFirstChildWhichIsA("BasePart", true)
    return m and m.Position or nil
end

local function fire_collect(inst)
    local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then fireproximityprompt(prompt) return end
    local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
    if part and hrp then
        firetouchinterest(hrp, part, 0)
        task.wait()
        firetouchinterest(hrp, part, 1)
    end
end

local function tp_to(pos)
    if cfg.teleport_speed then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
    else
        local tw = ts:Create(hrp, TweenInfo.new(cfg.tween_time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))})
        tw:Play()
        tw.Completed:Wait()
    end
end

local espObjects = {}

local function update_esp(enabled)
    for inst, draw in pairs(espObjects) do
        if not inst.Parent or not enabled then
            draw:Remove()
            espObjects[inst] = nil
        end
    end
    if not enabled then return end
    for _, inst in ipairs(workspace:GetDescendants()) do
        if is_egg(inst) and not espObjects[inst] then
            local pos = get_pos(inst)
            if pos then
                local ok, d = pcall(function()
                    local dr = Drawing.new("Text")
                    dr.Size = 16
                    dr.Color = cfg.esp_color
                    dr.Outline = true
                    dr.Center = true
                    return dr
                end)
                if ok then espObjects[inst] = d end
            end
        end
    end
end

local function esp_step(enabled)
    if not enabled then return end
    local cam = workspace.CurrentCamera
    for inst, draw in pairs(espObjects) do
        if not inst.Parent then
            draw:Remove()
            espObjects[inst] = nil
        else
            local pos = get_pos(inst)
            if pos then
                pcall(function()
                    local sp, onScreen = cam:WorldToViewportPoint(pos)
                    draw.Visible = onScreen
                    draw.Position = Vector2.new(sp.X, sp.Y)
                    draw.Text = inst.Name .. " [" .. math.floor((hrp and (hrp.Position - pos).Magnitude) or 0) .. "m]"
                end)
            end
        end
    end
end

local function auto_buy_step()
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("ProximityPrompt") then
            local n = (inst.ActionText or "") .. (inst.ObjectText or "") .. inst.Name
            n = n:lower()
            if n:find("buy") or n:find("purchase") or n:find("satin") then
                local p = inst.Parent
                local pos = p and (p:IsA("BasePart") and p.Position or (p.PrimaryPart and p.PrimaryPart.Position))
                if pos and hrp and (hrp.Position - pos).Magnitude < 15 then
                    fireproximityprompt(inst)
                end
            end
        end
    end
end

local function egg_sweep()
    if not ready then return end
    local eggs = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if is_egg(inst) and not collected[inst] then
            local pos = get_pos(inst)
            if pos then table.insert(eggs, {inst = inst, pos = pos}) end
        end
    end
    table.sort(eggs, function(a, b)
        return (a.pos - hrp.Position).Magnitude < (b.pos - hrp.Position).Magnitude
    end)
    for _, e in ipairs(eggs) do
        if not e.inst or not e.inst.Parent then continue end
        tp_to(e.pos)
        fire_collect(e.inst)
        collected[e.inst] = true
        task.wait(0.05)
    end
end

local flying = false
local bv, bg, vert = nil, nil, 0

local function fly_apply(enabled)
    if enabled and not flying and ready then
        flying = true
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new()
        bv.Parent = hrp
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 3000
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        hum.PlatformStand = false
    elseif not enabled and flying then
        flying = false
        vert = 0
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
end

local speedBtn, speedOn = make_toggle("SPEED", 1)
local jumpBtn, jumpOn = make_toggle("JUMP", 2)
local flyBtn, flyOn = make_toggle("FLY", 3)
local espBtn, espOn = make_toggle("ESP", 4)
local stealBtn, stealOn = make_toggle("AUTO STEAL", 5)
local buyBtn, buyOn = make_toggle("AUTO BUY", 6)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(1, 0, 0, 28)
upBtn.LayoutOrder = 7
upBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 12
upBtn.Text = "FLY UP"
upBtn.Active = true
upBtn.ZIndex = 999
upBtn.Parent = frame
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 6)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(1, 0, 0, 28)
downBtn.LayoutOrder = 8
downBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 12
downBtn.Text = "FLY DOWN"
downBtn.Active = true
downBtn.ZIndex = 999
downBtn.Parent = frame
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 6)

local holdingUp, holdingDown = false, false
upBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdingUp = true end
end)
upBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdingUp = false end
end)
downBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdingDown = true end
end)
downBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdingDown = false end
end)

local lastEspState = false

run.RenderStepped:Connect(function()
    if not ready then return end
    if speedOn() then hum.WalkSpeed = cfg.walkspeed_boost else hum.WalkSpeed = 16 end
    if jumpOn() then hum.JumpPower = cfg.jumppower_boost else hum.JumpPower = 50 end

    fly_apply(flyOn())
    vert = (holdingUp and cfg.fly_vert_speed or 0) - (holdingDown and cfg.fly_vert_speed or 0)
    if flying and bv and bv.Parent then
        local move = hum.MoveDirection
        local horiz = Vector3.new()
        if move.Magnitude > 0.05 then horiz = move.Unit * cfg.fly_speed end
        bv.Velocity = Vector3.new(horiz.X, vert, horiz.Z)
        if move.Magnitude > 0.05 then bg.CFrame = CFrame.new(Vector3.new(), move) end
    end

    if espOn() ~= lastEspState then
        update_esp(espOn())
        lastEspState = espOn()
    end
    esp_step(espOn())
end)

task.spawn(function()
    while true do
        if stealOn() then egg_sweep() end
        if buyOn() then auto_buy_step() end
        update_esp(espOn())
        task.wait(cfg.rescan)
    end
end)
