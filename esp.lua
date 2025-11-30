local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    PaddingInStuds = 1.5,
    MinBoxSize = 2,
    BarGap = 2,
    BarWidth = 2,
    TextSize = 8,
    Font = 3,
    StaticDistance = 300,
    StaticSize = Vector2.new(4, 6)
}

local function CreateLine()
    local Line = Drawing.new("Square")
    Line.Visible = false
    Line.Transparency = 1
    Line.Thickness = 0
    Line.Filled = true
    return Line
end

local function CreateText()
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Center = true
    Text.Outline = true
    Text.Color = Color3.new(1, 1, 1)
    Text.Font = Settings.Font
    Text.Size = Settings.TextSize
    return Text
end

local function AddESP(player)
    local BlackTop = CreateLine(); BlackTop.Color = Color3.new(0,0,0); BlackTop.ZIndex = 1
    local BlackBottom = CreateLine(); BlackBottom.Color = Color3.new(0,0,0); BlackBottom.ZIndex = 1
    local BlackLeft = CreateLine(); BlackLeft.Color = Color3.new(0,0,0); BlackLeft.ZIndex = 1
    local BlackRight = CreateLine(); BlackRight.Color = Color3.new(0,0,0); BlackRight.ZIndex = 1

    local WhiteTop = CreateLine(); WhiteTop.Color = Color3.new(1,1,1); WhiteTop.ZIndex = 2
    local WhiteBottom = CreateLine(); WhiteBottom.Color = Color3.new(1,1,1); WhiteBottom.ZIndex = 2
    local WhiteLeft = CreateLine(); WhiteLeft.Color = Color3.new(1,1,1); WhiteLeft.ZIndex = 2
    local WhiteRight = CreateLine(); WhiteRight.Color = Color3.new(1,1,1); WhiteRight.ZIndex = 2

    local HealthOutline = CreateLine(); HealthOutline.Color = Color3.new(0,0,0); HealthOutline.ZIndex = 1
    local HealthBar = CreateLine(); HealthBar.ZIndex = 2
    local NameTag = CreateText(); NameTag.ZIndex = 3

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local function Hide()
            BlackTop.Visible = false; BlackBottom.Visible = false; BlackLeft.Visible = false; BlackRight.Visible = false
            WhiteTop.Visible = false; WhiteBottom.Visible = false; WhiteLeft.Visible = false; WhiteRight.Visible = false
            HealthOutline.Visible = false; HealthBar.Visible = false
            NameTag.Visible = false
        end

        if not player.Character then Hide(); return end
        local Char = player.Character
        local RootPart = Char:FindFirstChild("HumanoidRootPart")
        local Humanoid = Char:FindFirstChild("Humanoid")

        if not RootPart or not Humanoid or Humanoid.Health <= 0 then Hide(); return end

        local Distance = (Camera.CFrame.Position - RootPart.Position).Magnitude
        local ViewportHeight = Camera.ViewportSize.Y
        local FOV_Rad = math.rad(Camera.FieldOfView)
        local PPS = ViewportHeight / (2 * Distance * math.tan(FOV_Rad / 2))

        local minX, minY, maxX, maxY

        if Distance > Settings.StaticDistance then
            local RootScreen, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local BoxW_Pixel = Settings.StaticSize.X * PPS
                local BoxH_Pixel = Settings.StaticSize.Y * PPS

                minX = RootScreen.X - (BoxW_Pixel / 2)
                maxX = RootScreen.X + (BoxW_Pixel / 2)
                minY = RootScreen.Y - (BoxH_Pixel / 2)
                maxY = RootScreen.Y + (BoxH_Pixel / 2)
            else
                Hide(); return
            end
        else
            minX, minY = 99999, 99999
            maxX, maxY = -99999, -99999
            local AnyPartOnScreen = false
            for _, part in pairs(Char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Handle" then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(part.Position)
                    if OnScreen then
                        AnyPartOnScreen = true
                        if ScreenPos.X < minX then minX = ScreenPos.X end
                        if ScreenPos.X > maxX then maxX = ScreenPos.X end
                        if ScreenPos.Y < minY then minY = ScreenPos.Y end
                        if ScreenPos.Y > maxY then maxY = ScreenPos.Y end
                    end
                end
            end
            if not AnyPartOnScreen then Hide(); return end

            local Padding = PPS * Settings.PaddingInStuds
            minX = minX - Padding
            maxX = maxX + Padding
            minY = minY - Padding
            maxY = maxY + Padding
        end

        local Left = math.floor(minX)
        local Top = math.floor(minY)
        local Right = math.floor(maxX)
        local Bottom = math.floor(maxY)

        local W = Right - Left
        local H = Bottom - Top

        W = math.max(W, Settings.MinBoxSize)
        H = math.max(H, Settings.MinBoxSize)

        BlackTop.Position = Vector2.new(Left - 1, Top - 1); BlackTop.Size = Vector2.new(W + 3, 3); BlackTop.Visible = true
        BlackBottom.Position = Vector2.new(Left - 1, Top + H - 1); BlackBottom.Size = Vector2.new(W + 3, 3); BlackBottom.Visible = true
        BlackLeft.Position = Vector2.new(Left - 1, Top - 1); BlackLeft.Size = Vector2.new(3, H + 3); BlackLeft.Visible = true
        BlackRight.Position = Vector2.new(Left + W - 1, Top - 1); BlackRight.Size = Vector2.new(3, H + 3); BlackRight.Visible = true

        WhiteTop.Position = Vector2.new(Left, Top); WhiteTop.Size = Vector2.new(W, 1); WhiteTop.Visible = true
        WhiteBottom.Position = Vector2.new(Left, Top + H); WhiteBottom.Size = Vector2.new(W + 1, 1); WhiteBottom.Visible = true
        WhiteLeft.Position = Vector2.new(Left, Top); WhiteLeft.Size = Vector2.new(1, H); WhiteLeft.Visible = true
        WhiteRight.Position = Vector2.new(Left + W, Top); WhiteRight.Size = Vector2.new(1, H); WhiteRight.Visible = true

        local Health = math.clamp(Humanoid.Health, 0, Humanoid.MaxHealth)
        local HP_Percentage = Health / Humanoid.MaxHealth
        local BarColor = Color3.fromHSV(HP_Percentage * 0.33, 1, 1)
        local BarX = Left - Settings.BarGap - Settings.BarWidth - 2
        local FillHeight = math.floor((H + 1) * HP_Percentage)

        HealthOutline.Position = Vector2.new(BarX, Top - 1)
        HealthOutline.Size = Vector2.new(Settings.BarWidth + 2, H + 3)
        HealthOutline.Visible = true

        HealthBar.Position = Vector2.new(BarX + 1, (Top + H + 1) - FillHeight)
        HealthBar.Size = Vector2.new(Settings.BarWidth, FillHeight)
        HealthBar.Color = BarColor
        HealthBar.Visible = true

        NameTag.Text = player.Name
        NameTag.Position = Vector2.new(Left + (W / 2), Top - Settings.TextSize - 2)
        NameTag.Visible = true

        if not player.Parent then
            BlackTop:Remove(); BlackBottom:Remove(); BlackLeft:Remove(); BlackRight:Remove()
            WhiteTop:Remove(); WhiteBottom:Remove(); WhiteLeft:Remove(); WhiteRight:Remove()
            HealthOutline:Remove(); HealthBar:Remove()
            NameTag:Remove()
            connection:Disconnect()
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then AddESP(v) end
end
Players.PlayerAdded:Connect(AddESP)
