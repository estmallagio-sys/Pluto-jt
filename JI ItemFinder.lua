-- ================================================
--   Jujutsu Infinite - Item Finder & Notifier
--   Mobile Friendly | Purple Garden After Rain Theme
-- ================================================

-- // CONFIG - EDIT THIS SECTION ONLY //
local CONFIG = {
    WebhookURL = "PASTE_YOUR_WEBHOOK_URL_HERE",
    MentionOption = "@everyone",

    Items = {
        "Domain Shard",
        "Maximum Scroll",
    },

    HopDelay = 8,
    TeleportDelay = 2,
    AutoTeleport = true,
}
-- // END CONFIG //


-- ================================================
--   THEME - Purple Garden After Rain / Cloudy
-- ================================================
local THEME = {
    Background       = Color3.fromRGB(28, 22, 38),
    TopBar           = Color3.fromRGB(45, 30, 65),
    TabActive        = Color3.fromRGB(90, 55, 130),
    TabInactive      = Color3.fromRGB(38, 28, 52),
    Button           = Color3.fromRGB(100, 65, 150),
    ServerCard       = Color3.fromRGB(38, 30, 55),
    ServerCardBorder = Color3.fromRGB(110, 75, 160),
    TextPrimary      = Color3.fromRGB(220, 210, 235),
    TextSecondary    = Color3.fromRGB(150, 130, 175),
    TextAccent       = Color3.fromRGB(180, 140, 220),
    Success          = Color3.fromRGB(100, 180, 130),
    Warning          = Color3.fromRGB(200, 160, 80),
    Close            = Color3.fromRGB(180, 70, 90),
    Scrollbar        = Color3.fromRGB(70, 45, 100),
}


-- ================================================
--   SERVICES
-- ================================================
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local LocalPlayer     = Players.LocalPlayer
local PlayerGui       = LocalPlayer:WaitForChild("PlayerGui")

local placeId      = game.PlaceId
local jobId        = game.JobId
local found        = false
local isRunning    = false
local foundServers = {}

-- Auto-load saved webhook
local SAVE_FILE = "JI_webhook.txt"
local function loadWebhook()
    local ok, data = pcall(readfile, SAVE_FILE)
    if ok and data and #data > 10 then
        CONFIG.WebhookURL = data
    end
end
local function saveWebhook(url)
    pcall(writefile, SAVE_FILE, url)
end
loadWebhook()


-- ================================================
--   GUI SETUP
-- ================================================
if PlayerGui:FindFirstChild("JI_ItemFinder") then
    PlayerGui:FindFirstChild("JI_ItemFinder"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JI_ItemFinder"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 430)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -215)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = THEME.ServerCardBorder
MainStroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TopFix = Instance.new("Frame", TopBar)
TopFix.Size = UDim2.new(1, 0, 0.5, 0)
TopFix.Position = UDim2.new(0, 0, 0.5, 0)
TopFix.BackgroundColor3 = THEME.TopBar
TopFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌸 JI Item Finder"
Title.TextColor3 = THEME.TextPrimary
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = THEME.Close
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab Bar
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 56)
TabBar.BackgroundColor3 = THEME.TabInactive
TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeTab(name, order)
    local t = Instance.new("TextButton", TabBar)
    t.Size = UDim2.new(0.5, 0, 1, 0)
    t.BackgroundColor3 = THEME.TabInactive
    t.BorderSizePixel = 0
    t.Text = name
    t.TextColor3 = THEME.TextSecondary
    t.TextSize = 13
    t.Font = Enum.Font.GothamSemibold
    t.LayoutOrder = order
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)
    return t
end

local TabMain    = makeTab("⚙️ Main", 1)
local TabServers = makeTab("🌐 Servers", 2)

-- Content Area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -110)
ContentArea.Position = UDim2.new(0, 10, 0, 100)
ContentArea.BackgroundTransparency = 1


-- ================================================
--   MAIN PAGE
-- ================================================
local MainPage = Instance.new("Frame", ContentArea)
MainPage.Size = UDim2.new(1, 0, 1, 0)
MainPage.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainPage)
StatusLabel.Size = UDim2.new(1, 0, 0, 36)
StatusLabel.BackgroundColor3 = THEME.ServerCard
StatusLabel.Text = "⏸ Idle — Press Start to begin"
StatusLabel.TextColor3 = THEME.TextSecondary
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.BorderSizePixel = 0
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

local ServerLabel = Instance.new("TextLabel", MainPage)
ServerLabel.Size = UDim2.new(1, 0, 0, 30)
ServerLabel.Position = UDim2.new(0, 0, 0, 44)
ServerLabel.BackgroundTransparency = 1
ServerLabel.Text = "🌐 Server: " .. string.sub(jobId, 1, 24) .. "..."
ServerLabel.TextColor3 = THEME.TextSecondary
ServerLabel.TextSize = 11
ServerLabel.Font = Enum.Font.Gotham

local ItemsLabel = Instance.new("TextLabel", MainPage)
ItemsLabel.Size = UDim2.new(1, 0, 0, 26)
ItemsLabel.Position = UDim2.new(0, 0, 0, 74)
ItemsLabel.BackgroundTransparency = 1
ItemsLabel.Text = "👀 Watching: " .. table.concat(CONFIG.Items, ", ")
ItemsLabel.TextColor3 = THEME.TextAccent
ItemsLabel.TextSize = 11
ItemsLabel.Font = Enum.Font.GothamSemibold
ItemsLabel.TextWrapped = true

local WebhookLabel = Instance.new("TextLabel", MainPage)
WebhookLabel.Size = UDim2.new(1, 0, 0, 20)
WebhookLabel.Position = UDim2.new(0, 0, 0, 104)
WebhookLabel.BackgroundTransparency = 1
WebhookLabel.TextSize = 11
WebhookLabel.Font = Enum.Font.Gotham

if CONFIG.WebhookURL == "PASTE_YOUR_WEBHOOK_URL_HERE" then
    WebhookLabel.Text = "⚠️ Webhook not configured!"
    WebhookLabel.TextColor3 = THEME.Warning
else
    WebhookLabel.Text = "✅ Webhook saved & ready"
    WebhookLabel.TextColor3 = THEME.Success
end

-- Webhook input box
local WebhookBox = Instance.new("TextBox", MainPage)
WebhookBox.Size = UDim2.new(1, 0, 0, 32)
WebhookBox.Position = UDim2.new(0, 0, 0, 126)
WebhookBox.BackgroundColor3 = THEME.ServerCard
WebhookBox.BorderSizePixel = 0
WebhookBox.PlaceholderText = "Paste webhook URL here..."
WebhookBox.PlaceholderColor3 = THEME.TextSecondary
WebhookBox.Text = CONFIG.WebhookURL ~= "PASTE_YOUR_WEBHOOK_URL_HERE" and CONFIG.WebhookURL or ""
WebhookBox.TextColor3 = THEME.TextPrimary
WebhookBox.TextSize = 10
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.ClearTextOnFocus = false
WebhookBox.TextXAlignment = Enum.TextXAlignment.Left
WebhookBox.TextTruncate = Enum.TextTruncate.AtEnd
Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0, 8)
local WBStroke = Instance.new("UIStroke", WebhookBox)
WBStroke.Color = THEME.ServerCardBorder
WBStroke.Thickness = 1
local WBPad = Instance.new("UIPadding", WebhookBox)
WBPad.PaddingLeft = UDim.new(0, 8)

-- Auto save when user finishes typing
WebhookBox.FocusLost:Connect(function()
    local url = WebhookBox.Text
    if url and #url > 10 then
        CONFIG.WebhookURL = url
        saveWebhook(url)
        WebhookLabel.Text = "✅ Webhook saved & ready"
        WebhookLabel.TextColor3 = THEME.Success
    else
        WebhookLabel.Text = "⚠️ Webhook not configured!"
        WebhookLabel.TextColor3 = THEME.Warning
    end
end)

local FoundLabel = Instance.new("TextLabel", MainPage)
FoundLabel.Size = UDim2.new(1, 0, 0, 26)
FoundLabel.Position = UDim2.new(0, 0, 0, 165)
FoundLabel.BackgroundTransparency = 1
FoundLabel.Text = "🎯 Servers Found: 0"
FoundLabel.TextColor3 = THEME.TextPrimary
FoundLabel.TextSize = 12
FoundLabel.Font = Enum.Font.GothamSemibold

local StartBtn = Instance.new("TextButton", MainPage)
StartBtn.Size = UDim2.new(1, 0, 0, 48)
StartBtn.Position = UDim2.new(0, 0, 1, -54)
StartBtn.BackgroundColor3 = THEME.Button
StartBtn.Text = "▶  Start Scanning"
StartBtn.TextColor3 = THEME.TextPrimary
StartBtn.TextSize = 15
StartBtn.Font = Enum.Font.GothamBold
StartBtn.BorderSizePixel = 0
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 10)


-- ================================================
--   SERVERS PAGE
-- ================================================
local ServersPage = Instance.new("Frame", ContentArea)
ServersPage.Size = UDim2.new(1, 0, 1, 0)
ServersPage.BackgroundTransparency = 1
ServersPage.Visible = false

local ServersBtn = Instance.new("TextButton", ServersPage)
ServersBtn.Size = UDim2.new(1, 0, 0, 42)
ServersBtn.BackgroundColor3 = THEME.Button
ServersBtn.Text = "🔍  Scan for Item Servers"
ServersBtn.TextColor3 = THEME.TextPrimary
ServersBtn.TextSize = 14
ServersBtn.Font = Enum.Font.GothamBold
ServersBtn.BorderSizePixel = 0
Instance.new("UICorner", ServersBtn).CornerRadius = UDim.new(0, 10)

local ScrollFrame = Instance.new("ScrollingFrame", ServersPage)
ScrollFrame.Size = UDim2.new(1, 0, 1, -52)
ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = THEME.Scrollbar
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", ScrollFrame)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)

local NoneLabel = Instance.new("TextLabel", ScrollFrame)
NoneLabel.Size = UDim2.new(1, 0, 0, 40)
NoneLabel.BackgroundTransparency = 1
NoneLabel.Text = "No servers found yet.\nPress Scan to search."
NoneLabel.TextColor3 = THEME.TextSecondary
NoneLabel.TextSize = 12
NoneLabel.Font = Enum.Font.Gotham
NoneLabel.TextWrapped = true


-- ================================================
--   TAB SWITCHING
-- ================================================
local function switchTab(tab)
    if tab == "main" then
        MainPage.Visible = true
        ServersPage.Visible = false
        TabMain.BackgroundColor3 = THEME.TabActive
        TabMain.TextColor3 = THEME.TextPrimary
        TabServers.BackgroundColor3 = THEME.TabInactive
        TabServers.TextColor3 = THEME.TextSecondary
    else
        MainPage.Visible = false
        ServersPage.Visible = true
        TabServers.BackgroundColor3 = THEME.TabActive
        TabServers.TextColor3 = THEME.TextPrimary
        TabMain.BackgroundColor3 = THEME.TabInactive
        TabMain.TextColor3 = THEME.TextSecondary
    end
end

switchTab("main")
TabMain.MouseButton1Click:Connect(function() switchTab("main") end)
TabServers.MouseButton1Click:Connect(function() switchTab("servers") end)


-- ================================================
--   ADD SERVER CARD
-- ================================================
local function addServerCard(itemName, serverId)
    NoneLabel.Visible = false

    local card = Instance.new("Frame", ScrollFrame)
    card.Size = UDim2.new(1, -4, 0, 72)
    card.BackgroundColor3 = THEME.ServerCard
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", card)
    cs.Color = THEME.ServerCardBorder
    cs.Thickness = 1

    local it = Instance.new("TextLabel", card)
    it.Size = UDim2.new(1, -10, 0, 24)
    it.Position = UDim2.new(0, 10, 0, 6)
    it.BackgroundTransparency = 1
    it.Text = "🎯 " .. itemName
    it.TextColor3 = THEME.TextAccent
    it.TextSize = 13
    it.Font = Enum.Font.GothamBold
    it.TextXAlignment = Enum.TextXAlignment.Left

    local st = Instance.new("TextLabel", card)
    st.Size = UDim2.new(1, -100, 0, 18)
    st.Position = UDim2.new(0, 10, 0, 30)
    st.BackgroundTransparency = 1
    st.Text = "ID: " .. string.sub(serverId, 1, 22) .. "..."
    st.TextColor3 = THEME.TextSecondary
    st.TextSize = 10
    st.Font = Enum.Font.Gotham
    st.TextXAlignment = Enum.TextXAlignment.Left

    local jb = Instance.new("TextButton", card)
    jb.Size = UDim2.new(0, 76, 0, 26)
    jb.Position = UDim2.new(1, -86, 0.5, -13)
    jb.BackgroundColor3 = THEME.Button
    jb.Text = "Join →"
    jb.TextColor3 = THEME.TextPrimary
    jb.TextSize = 12
    jb.Font = Enum.Font.GothamBold
    jb.BorderSizePixel = 0
    Instance.new("UICorner", jb).CornerRadius = UDim.new(0, 6)

    jb.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
    end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end


-- ================================================
--   DISCORD WEBHOOK
-- ================================================
local function sendWebhook(itemName, serverId)
    if CONFIG.WebhookURL == "PASTE_YOUR_WEBHOOK_URL_HERE" then return end
    local link = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. serverId
    local data = {
        embeds = {{
            title = "🌸 RARE ITEM FOUND — Jujutsu Infinite",
            color = 7864319,
            fields = {
                { name = "📦 Item",      value = "**" .. itemName .. "**", inline = true },
                { name = "👤 Found By", value = LocalPlayer.Name,          inline = true },
                { name = "🌐 Server",   value = "`" .. serverId .. "`",    inline = false },
                { name = "🔗 Rejoin",   value = link,                      inline = false },
            },
            footer = { text = "JI Item Finder • Purple Garden Edition" },
            timestamp = DateTime.now():ToIsoDate()
        }},
        content = CONFIG.MentionOption .. " **" .. itemName .. "** spotted!"
    }
    pcall(function()
        request({
            Url = CONFIG.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end


-- ================================================
--   ITEM SCANNER
-- ================================================
local function scanCurrentServer()
    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, itemName in ipairs(CONFIG.Items) do
            if obj.Name == itemName then
                return itemName, obj
            end
        end
    end
    return nil, nil
end

workspace.DescendantAdded:Connect(function(obj)
    if not isRunning then return end
    task.wait(0.1)
    for _, itemName in ipairs(CONFIG.Items) do
        if obj.Name == itemName then
            found = true
            isRunning = false
            StatusLabel.Text = "🎉 Found: " .. itemName .. "!"
            StatusLabel.TextColor3 = THEME.Success
            StartBtn.Text = "▶  Start Scanning"
            table.insert(foundServers, { item = itemName, id = jobId })
            FoundLabel.Text = "🎯 Servers Found: " .. #foundServers
            addServerCard(itemName, jobId)
            sendWebhook(itemName, jobId)
            if CONFIG.AutoTeleport then
                task.wait(CONFIG.TeleportDelay)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end)


-- ================================================
--   SERVER HOPPER
-- ================================================
local function hopServer()
    local ok, result = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
    end)
    if not ok or not result or not result.data then
        StatusLabel.Text = "⚠️ Failed fetching servers, retrying..."
        StatusLabel.TextColor3 = THEME.Warning
        task.wait(10)
        return
    end
    for _, server in ipairs(result.data) do
        if server.id ~= jobId and server.playing < server.maxPlayers then
            StatusLabel.Text = "🔄 Hopping to new server..."
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
            return
        end
    end
    StatusLabel.Text = "⚠️ No open servers found, retrying..."
    StatusLabel.TextColor3 = THEME.Warning
    task.wait(15)
end


-- ================================================
--   SERVERS SCAN BUTTON
-- ================================================
ServersBtn.MouseButton1Click:Connect(function()
    ServersBtn.Text = "🔄 Scanning..."
    task.wait(0.5)
    local itemName, itemObj = scanCurrentServer()
    if itemName and itemObj then
        local already = false
        for _, s in ipairs(foundServers) do
            if s.id == jobId then already = true break end
        end
        if not already then
            table.insert(foundServers, { item = itemName, id = jobId })
            FoundLabel.Text = "🎯 Servers Found: " .. #foundServers
            addServerCard(itemName, jobId)
            sendWebhook(itemName, jobId)
        end
        ServersBtn.Text = "✅ Item found in this server!"
    else
        ServersBtn.Text = "❌ No items in current server"
    end
    task.wait(2)
    ServersBtn.Text = "🔍  Scan for Item Servers"
end)


-- ================================================
--   START / STOP
-- ================================================
StartBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        found = false
        StartBtn.Text = "▶  Start Scanning"
        StatusLabel.Text = "⏸ Stopped"
        StatusLabel.TextColor3 = THEME.TextSecondary
        return
    end

    isRunning = true
    found = false
    StartBtn.Text = "⏹  Stop"

    task.spawn(function()
        while isRunning do
            StatusLabel.Text = "🔍 Scanning current server..."
            StatusLabel.TextColor3 = THEME.TextPrimary
            local itemName, itemObj = scanCurrentServer()

            if itemName and itemObj then
                found = true
                isRunning = false
                StatusLabel.Text = "🎉 Found: " .. itemName .. "!"
                StatusLabel.TextColor3 = THEME.Success
                StartBtn.Text = "▶  Start Scanning"
                local already = false
                for _, s in ipairs(foundServers) do
                    if s.id == jobId then already = true break end
                end
                if not already then
                    table.insert(foundServers, { item = itemName, id = jobId })
                    FoundLabel.Text = "🎯 Servers Found: " .. #foundServers
                    addServerCard(itemName, jobId)
                    sendWebhook(itemName, jobId)
                end
                if CONFIG.AutoTeleport then
                    task.wait(CONFIG.TeleportDelay)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = itemObj.CFrame + Vector3.new(0, 5, 0)
                    end
                end
                break
            end

            StatusLabel.Text = "⏳ Hopping in " .. CONFIG.HopDelay .. "s..."
            StatusLabel.TextColor3 = THEME.TextSecondary
            task.wait(CONFIG.HopDelay)

            if isRunning then hopServer() end
        end
    end)
end)

print("[JI ItemFinder] ✅ Loaded — Purple Garden Edition 🌸")
