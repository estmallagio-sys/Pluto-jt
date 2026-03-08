-- ================================================
--   Jujutsu Infinite - Item Finder & Notifier
--   Mobile Friendly | Purple Garden After Rain Theme
-- ================================================

-- // CONFIG - EDIT THIS SECTION ONLY //
local CONFIG = {
    WebhookURL = "PASTE_YOUR_WEBHOOK_URL_HERE",
    MentionOption = "@everyone",

    Items = {
        -- Known exact names
        "Domain Shard [Unique]",
        "Maximum Scroll [Unique]",

        -- Domain Shard variations
        "Domain Shard",
        "DomainShard",
        "domain_shard",
        "domain shard",
        "Domainshard",
        "Shard",
        "Domain_Shard",
        "DomainFragment",
        "Domain Fragment",
        "domain fragment",
        "Cursed Domain Shard",
        "CursedDomainShard",
        "DShard",
        "D_Shard",
        "ShardItem",
        "Shard_Item",
        "cursed_shard",
        "CursedShard",
        "Cursed Shard",

        -- Maximum Scroll variations
        "Maximum Scroll",
        "MaximumScroll",
        "maximum_scroll",
        "maximum scroll",
        "MaxScroll",
        "Max_Scroll",
        "Max Scroll",
        "Scroll",
        "CursedScroll",
        "Cursed Scroll",
        "cursed_scroll",
        "cursed scroll",
        "ScrollItem",
        "Scroll_Item",
        "MScroll",
        "M_Scroll",
        "maximum_technique_scroll",
        "MaximumTechniqueScroll",
        "Maximum Technique Scroll",
        "TechniqueScroll",
        "Technique Scroll",
        "technique_scroll",
    },

    HopDelay = 5.5,
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

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -80, 0.5, -16)
MinBtn.BackgroundColor3 = THEME.TabActive
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Minimized bubble (shown when minimized)
local MiniBubble = Instance.new("TextButton", ScreenGui)
MiniBubble.Size = UDim2.new(0, 52, 0, 52)
MiniBubble.Position = UDim2.new(0, 16, 0.5, -26)
MiniBubble.BackgroundColor3 = THEME.TopBar
MiniBubble.Text = "🌸"
MiniBubble.TextSize = 24
MiniBubble.Font = Enum.Font.GothamBold
MiniBubble.BorderSizePixel = 0
MiniBubble.Visible = false
MiniBubble.Active = true
MiniBubble.Draggable = true
Instance.new("UICorner", MiniBubble).CornerRadius = UDim.new(0, 14)
local MBS = Instance.new("UIStroke", MiniBubble)
MBS.Color = THEME.ServerCardBorder
MBS.Thickness = 1.5

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    MainFrame.Visible = false
    MiniBubble.Visible = true
end)
MiniBubble.MouseButton1Click:Connect(function()
    isMinimized = false
    MainFrame.Visible = true
    MiniBubble.Visible = false
end)

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
    t.Size = UDim2.new(0.25, 0, 1, 0)
    t.BackgroundColor3 = THEME.TabInactive
    t.BorderSizePixel = 0
    t.Text = name
    t.TextColor3 = THEME.TextSecondary
    t.TextSize = 10
    t.Font = Enum.Font.GothamSemibold
    t.LayoutOrder = order
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)
    return t
end

local TabMain    = makeTab("⚙️ Main", 1)
local TabServers = makeTab("🌐 Servers", 2)
local TabCheck   = makeTab("🔎 Check", 3)
local TabMarket  = makeTab("💰 Market", 4)

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
--   CHECK PAGE (Scan OTHER servers without hopping)
-- ================================================
local CheckPage = Instance.new("Frame", ContentArea)
CheckPage.Size = UDim2.new(1, 0, 1, 0)
CheckPage.BackgroundTransparency = 1
CheckPage.Visible = false

local CheckInfo = Instance.new("TextLabel", CheckPage)
CheckInfo.Size = UDim2.new(1, 0, 0, 36)
CheckInfo.BackgroundColor3 = THEME.ServerCard
CheckInfo.Text = "Scans public servers without joining"
CheckInfo.TextColor3 = THEME.TextSecondary
CheckInfo.TextSize = 11
CheckInfo.Font = Enum.Font.Gotham
CheckInfo.BorderSizePixel = 0
CheckInfo.TextWrapped = true
Instance.new("UICorner", CheckInfo).CornerRadius = UDim.new(0, 8)

local CheckStatus = Instance.new("TextLabel", CheckPage)
CheckStatus.Size = UDim2.new(1, 0, 0, 24)
CheckStatus.Position = UDim2.new(0, 0, 0, 44)
CheckStatus.BackgroundTransparency = 1
CheckStatus.Text = "⏸ Press Scan to begin"
CheckStatus.TextColor3 = THEME.TextSecondary
CheckStatus.TextSize = 11
CheckStatus.Font = Enum.Font.Gotham

local CheckProgress = Instance.new("TextLabel", CheckPage)
CheckProgress.Size = UDim2.new(1, 0, 0, 20)
CheckProgress.Position = UDim2.new(0, 0, 0, 66)
CheckProgress.BackgroundTransparency = 1
CheckProgress.Text = ""
CheckProgress.TextColor3 = THEME.TextAccent
CheckProgress.TextSize = 10
CheckProgress.Font = Enum.Font.Gotham

local CheckScrollFrame = Instance.new("ScrollingFrame", CheckPage)
CheckScrollFrame.Size = UDim2.new(1, 0, 1, -140)
CheckScrollFrame.Position = UDim2.new(0, 0, 0, 90)
CheckScrollFrame.BackgroundTransparency = 1
CheckScrollFrame.BorderSizePixel = 0
CheckScrollFrame.ScrollBarThickness = 4
CheckScrollFrame.ScrollBarImageColor3 = THEME.Scrollbar
CheckScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local CheckListLayout = Instance.new("UIListLayout", CheckScrollFrame)
CheckListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CheckListLayout.Padding = UDim.new(0, 5)

local CheckNoneLabel = Instance.new("TextLabel", CheckScrollFrame)
CheckNoneLabel.Size = UDim2.new(1, 0, 0, 40)
CheckNoneLabel.BackgroundTransparency = 1
CheckNoneLabel.Text = "No results yet."
CheckNoneLabel.TextColor3 = THEME.TextSecondary
CheckNoneLabel.TextSize = 12
CheckNoneLabel.Font = Enum.Font.Gotham

local CheckBtn = Instance.new("TextButton", CheckPage)
CheckBtn.Size = UDim2.new(1, 0, 0, 40)
CheckBtn.Position = UDim2.new(0, 0, 1, -44)
CheckBtn.BackgroundColor3 = THEME.Button
CheckBtn.Text = "🔎  Scan Other Servers"
CheckBtn.TextColor3 = THEME.TextPrimary
CheckBtn.TextSize = 13
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.BorderSizePixel = 0
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 10)

local isChecking = false

local function addCheckCard(itemName, serverId, playerCount, maxPlayers)
    CheckNoneLabel.Visible = false
    local card = Instance.new("Frame", CheckScrollFrame)
    card.Size = UDim2.new(1, -4, 0, 66)
    card.BackgroundColor3 = THEME.ServerCard
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", card)
    cs.Color = THEME.ServerCardBorder
    cs.Thickness = 1

    local il = Instance.new("TextLabel", card)
    il.Size = UDim2.new(1, -90, 0, 22)
    il.Position = UDim2.new(0, 8, 0, 5)
    il.BackgroundTransparency = 1
    il.Text = "🎯 " .. itemName
    il.TextColor3 = THEME.TextAccent
    il.TextSize = 12
    il.Font = Enum.Font.GothamBold
    il.TextXAlignment = Enum.TextXAlignment.Left

    local pl = Instance.new("TextLabel", card)
    pl.Size = UDim2.new(1, -90, 0, 18)
    pl.Position = UDim2.new(0, 8, 0, 26)
    pl.BackgroundTransparency = 1
    pl.Text = "👥 " .. playerCount .. "/" .. maxPlayers .. "  |  ID: " .. string.sub(serverId,1,16) .. "..."
    pl.TextColor3 = THEME.TextSecondary
    pl.TextSize = 10
    pl.Font = Enum.Font.Gotham
    pl.TextXAlignment = Enum.TextXAlignment.Left

    local jb = Instance.new("TextButton", card)
    jb.Size = UDim2.new(0, 72, 0, 28)
    jb.Position = UDim2.new(1, -80, 0.5, -14)
    jb.BackgroundColor3 = THEME.Button
    jb.Text = "Join →"
    jb.TextColor3 = THEME.TextPrimary
    jb.TextSize = 11
    jb.Font = Enum.Font.GothamBold
    jb.BorderSizePixel = 0
    Instance.new("UICorner", jb).CornerRadius = UDim.new(0, 6)
    jb.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
    end)

    CheckScrollFrame.CanvasSize = UDim2.new(0, 0, 0, CheckListLayout.AbsoluteContentSize.Y + 10)
end

CheckBtn.MouseButton1Click:Connect(function()
    if isChecking then
        isChecking = false
        CheckBtn.Text = "🔎  Scan Other Servers"
        CheckStatus.Text = "⏸ Stopped"
        CheckStatus.TextColor3 = THEME.TextSecondary
        return
    end

    isChecking = true
    CheckBtn.Text = "⏹  Stop Scanning"
    CheckStatus.Text = "🔄 Fetching server list..."
    CheckStatus.TextColor3 = THEME.TextPrimary

    task.spawn(function()
        local scanned = 0
        local hits = 0
        local blacklist = {}       -- servers already picked as the 100th
        local recentPool = {}      -- last batch of servers seen
        local cycleCount = 0       -- counts up to 100 then picks one

        while isChecking do
            -- Fetch a fresh page of servers
            local ok, result = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
                )
            end)

            if not ok or not result or not result.data then
                CheckStatus.Text = "⚠️ Failed to fetch, retrying..."
                CheckStatus.TextColor3 = THEME.Warning
                task.wait(8)
            else
                -- Build pool of valid servers (not current, not blacklisted)
                recentPool = {}
                for _, server in ipairs(result.data) do
                    if server.id ~= jobId and not blacklist[server.id] then
                        table.insert(recentPool, server)
                    end
                end

                -- Count through them
                for _, server in ipairs(recentPool) do
                    if not isChecking then break end
                    scanned = scanned + 1
                    cycleCount = cycleCount + 1
                    CheckStatus.Text = "🔄 Scanning... (" .. cycleCount .. "/100)"
                    CheckStatus.TextColor3 = THEME.TextPrimary
                    CheckProgress.Text = "Servers checked: " .. scanned .. "  |  Flagged: " .. hits
                    task.wait(0.1)

                    -- Every 100 servers, pick this one to hop into and scan for real
                    if cycleCount >= 100 then
                        cycleCount = 0
                        blacklist[server.id] = true  -- blacklist so it's never the 100th again

                        CheckStatus.Text = "🎯 Hopping into server #" .. scanned .. " to scan..."
                        CheckStatus.TextColor3 = THEME.TextAccent

                        -- Teleport in, scan, result comes back via the existing DescendantAdded watcher
                        -- Flag it as a check hop so we come back after
                        hits = hits + 1
                        addCheckCard("Scanning this server...", server.id, server.playing or 0, server.maxPlayers or 20)
                        sendWebhook("🔎 Hopping to check server", server.id)

                        task.wait(1)
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        -- After teleport the script re-executes in the new server automatically
                        -- if auto execute is on
                        return
                    end
                end

                -- If pool ran out before hitting 100, reset cycle and refetch
                CheckStatus.Text = "🔄 Refreshing server list..."
                task.wait(5)
            end
        end

        CheckBtn.Text = "🔎  Scan Other Servers"
        CheckStatus.Text = "⏸ Scan stopped"
        CheckStatus.TextColor3 = THEME.TextSecondary
    end)
end)


-- ================================================
--   AUTO EXECUTE (runs scan on script load if saved)
-- ================================================
local AE_FILE = "JI_autoexec.txt"
local autoExecEnabled = false
local function loadAutoExec()
    local ok, data = pcall(readfile, AE_FILE)
    if ok and data == "true" then autoExecEnabled = true end
end
loadAutoExec()

-- Auto execute toggle in main page
local AutoExecLabel = Instance.new("TextLabel", MainPage)
AutoExecLabel.Size = UDim2.new(0.6, 0, 0, 24)
AutoExecLabel.Position = UDim2.new(0, 0, 1, -100)
AutoExecLabel.BackgroundTransparency = 1
AutoExecLabel.Text = "⚡ Auto-Start on Execute"
AutoExecLabel.TextColor3 = THEME.TextSecondary
AutoExecLabel.TextSize = 11
AutoExecLabel.Font = Enum.Font.Gotham
AutoExecLabel.TextXAlignment = Enum.TextXAlignment.Left

local AutoExecToggle = Instance.new("TextButton", MainPage)
AutoExecToggle.Size = UDim2.new(0, 48, 0, 24)
AutoExecToggle.Position = UDim2.new(1, -50, 1, -100)
AutoExecToggle.BorderSizePixel = 0
AutoExecToggle.TextSize = 10
AutoExecToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", AutoExecToggle).CornerRadius = UDim.new(0, 12)

local function updateAutoExecToggle()
    if autoExecEnabled then
        AutoExecToggle.BackgroundColor3 = THEME.Success
        AutoExecToggle.TextColor3 = Color3.fromRGB(255,255,255)
        AutoExecToggle.Text = "ON"
    else
        AutoExecToggle.BackgroundColor3 = THEME.TabInactive
        AutoExecToggle.TextColor3 = THEME.TextSecondary
        AutoExecToggle.Text = "OFF"
    end
end
updateAutoExecToggle()

AutoExecToggle.MouseButton1Click:Connect(function()
    autoExecEnabled = not autoExecEnabled
    pcall(writefile, AE_FILE, tostring(autoExecEnabled))
    updateAutoExecToggle()
end)


-- ================================================
--   MARKET PAGE
-- ================================================
local MarketPage = Instance.new("Frame", ContentArea)
MarketPage.Size = UDim2.new(1, 0, 1, 0)
MarketPage.BackgroundTransparency = 1
MarketPage.Visible = false

-- Market webhook label
local MktWebhookLabel = Instance.new("TextLabel", MarketPage)
MktWebhookLabel.Size = UDim2.new(1, 0, 0, 20)
MktWebhookLabel.Position = UDim2.new(0, 0, 0, 0)
MktWebhookLabel.BackgroundTransparency = 1
MktWebhookLabel.TextSize = 11
MktWebhookLabel.Font = Enum.Font.Gotham
MktWebhookLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Market webhook box
local MktWebhookBox = Instance.new("TextBox", MarketPage)
MktWebhookBox.Size = UDim2.new(1, 0, 0, 32)
MktWebhookBox.Position = UDim2.new(0, 0, 0, 22)
MktWebhookBox.BackgroundColor3 = THEME.ServerCard
MktWebhookBox.BorderSizePixel = 0
MktWebhookBox.PlaceholderText = "Paste market webhook URL..."
MktWebhookBox.PlaceholderColor3 = THEME.TextSecondary
MktWebhookBox.TextColor3 = THEME.TextPrimary
MktWebhookBox.TextSize = 10
MktWebhookBox.Font = Enum.Font.Gotham
MktWebhookBox.ClearTextOnFocus = false
MktWebhookBox.TextXAlignment = Enum.TextXAlignment.Left
MktWebhookBox.TextTruncate = Enum.TextTruncate.AtEnd
Instance.new("UICorner", MktWebhookBox).CornerRadius = UDim.new(0, 8)
local MWBStroke = Instance.new("UIStroke", MktWebhookBox)
MWBStroke.Color = THEME.ServerCardBorder
MWBStroke.Thickness = 1
local MWBPad = Instance.new("UIPadding", MktWebhookBox)
MWBPad.PaddingLeft = UDim.new(0, 8)

-- Load/save market webhook
local MKT_SAVE_FILE = "JI_market_webhook.txt"
local marketWebhookURL = "NONE"
local function loadMarketWebhook()
    local ok, data = pcall(readfile, MKT_SAVE_FILE)
    if ok and data and #data > 10 then
        marketWebhookURL = data
        MktWebhookBox.Text = data
        MktWebhookLabel.Text = "✅ Market webhook saved"
        MktWebhookLabel.TextColor3 = THEME.Success
    else
        MktWebhookLabel.Text = "⚠️ Paste your market webhook"
        MktWebhookLabel.TextColor3 = THEME.Warning
    end
end
loadMarketWebhook()

MktWebhookBox.FocusLost:Connect(function()
    local url = MktWebhookBox.Text
    if url and #url > 10 then
        marketWebhookURL = url
        pcall(writefile, MKT_SAVE_FILE, url)
        MktWebhookLabel.Text = "✅ Market webhook saved"
        MktWebhookLabel.TextColor3 = THEME.Success
    else
        MktWebhookLabel.Text = "⚠️ Paste your market webhook"
        MktWebhookLabel.TextColor3 = THEME.Warning
    end
end)

-- Status label
local MktStatus = Instance.new("TextLabel", MarketPage)
MktStatus.Size = UDim2.new(1, 0, 0, 30)
MktStatus.Position = UDim2.new(0, 0, 0, 60)
MktStatus.BackgroundColor3 = THEME.ServerCard
MktStatus.BorderSizePixel = 0
MktStatus.Text = "⏸ Watcher off"
MktStatus.TextColor3 = THEME.TextSecondary
MktStatus.TextSize = 12
MktStatus.Font = Enum.Font.Gotham
Instance.new("UICorner", MktStatus).CornerRadius = UDim.new(0, 8)

-- Items watching info
local MktItemsInfo = Instance.new("TextLabel", MarketPage)
MktItemsInfo.Size = UDim2.new(1, 0, 0, 40)
MktItemsInfo.Position = UDim2.new(0, 0, 0, 98)
MktItemsInfo.BackgroundTransparency = 1
MktItemsInfo.Text = "🔔 Alerting on: Domain Shard, Maximum Scroll, Cursed Tools, Cursed Hands & rare tradeables"
MktItemsInfo.TextColor3 = THEME.TextAccent
MktItemsInfo.TextSize = 10
MktItemsInfo.Font = Enum.Font.Gotham
MktItemsInfo.TextWrapped = true

-- Last refresh label
local MktLastRefresh = Instance.new("TextLabel", MarketPage)
MktLastRefresh.Size = UDim2.new(1, 0, 0, 20)
MktLastRefresh.Position = UDim2.new(0, 0, 0, 142)
MktLastRefresh.BackgroundTransparency = 1
MktLastRefresh.Text = "Last refresh: —"
MktLastRefresh.TextColor3 = THEME.TextSecondary
MktLastRefresh.TextSize = 10
MktLastRefresh.Font = Enum.Font.Gotham

-- Market log scroll
local MktScroll = Instance.new("ScrollingFrame", MarketPage)
MktScroll.Size = UDim2.new(1, 0, 1, -210)
MktScroll.Position = UDim2.new(0, 0, 0, 165)
MktScroll.BackgroundTransparency = 1
MktScroll.BorderSizePixel = 0
MktScroll.ScrollBarThickness = 4
MktScroll.ScrollBarImageColor3 = THEME.Scrollbar
MktScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local MktListLayout = Instance.new("UIListLayout", MktScroll)
MktListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MktListLayout.Padding = UDim.new(0, 5)

local MktNoneLabel = Instance.new("TextLabel", MktScroll)
MktNoneLabel.Size = UDim2.new(1, 0, 0, 30)
MktNoneLabel.BackgroundTransparency = 1
MktNoneLabel.Text = "No market alerts yet."
MktNoneLabel.TextColor3 = THEME.TextSecondary
MktNoneLabel.TextSize = 11
MktNoneLabel.Font = Enum.Font.Gotham

-- Toggle watcher button
local MktToggleBtn = Instance.new("TextButton", MarketPage)
MktToggleBtn.Size = UDim2.new(1, 0, 0, 38)
MktToggleBtn.Position = UDim2.new(0, 0, 1, -42)
MktToggleBtn.BackgroundColor3 = THEME.Button
MktToggleBtn.Text = "▶  Start Market Watcher"
MktToggleBtn.TextColor3 = THEME.TextPrimary
MktToggleBtn.TextSize = 13
MktToggleBtn.Font = Enum.Font.GothamBold
MktToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", MktToggleBtn).CornerRadius = UDim.new(0, 10)


-- ================================================
--   MARKET WATCHER LOGIC
-- ================================================

-- All tradeable/valuable items to watch for
local MARKET_WATCHLIST = {
    -- Known exact names
    "Domain Shard [Unique]", "Maximum Scroll [Unique]",

    -- Domain Shard variations
    "Domain Shard", "DomainShard", "domain_shard", "Domainshard",
    "Shard", "Domain_Shard", "DomainFragment", "Domain Fragment",
    "Cursed Domain Shard", "CursedDomainShard", "DShard", "D_Shard",
    "ShardItem", "Shard_Item", "CursedShard", "Cursed Shard",

    -- Maximum Scroll variations
    "Maximum Scroll", "MaximumScroll", "maximum_scroll", "MaxScroll",
    "Max_Scroll", "Max Scroll", "Scroll", "CursedScroll", "Cursed Scroll",
    "cursed_scroll", "ScrollItem", "Scroll_Item", "MScroll", "M_Scroll",
    "MaximumTechniqueScroll", "Maximum Technique Scroll", "TechniqueScroll",
    "Technique Scroll", "technique_scroll",

    -- Cursed tools
    "Cursed Tool", "CursedTool", "cursed_tool",
    "Cursed Blade", "CursedBlade",
    "Inverted Spear", "InvertedSpear", "inverted_spear",
    "Dragon Bone", "DragonBone", "dragon_bone",
    "Playful Cloud", "PlayfulCloud", "playful_cloud",
    "Split Soul", "SplitSoul", "split_soul",

    -- Cursed hands / techniques
    "Cursed Hand", "CursedHand", "cursed_hand",
    "Limitless", "Six Eyes", "SixEyes",
    "Infinity", "Reversal", "Hollow Purple", "HollowPurple",
    "Red", "Blue",

    -- Rarity labels
    "Mythic", "Legendary", "Cursed Spirit", "CursedSpirit",
    "Grade 1", "Grade1", "Special Grade", "SpecialGrade",
}

local function sendMarketWebhook(itemName, price, refreshCount)
    if marketWebhookURL == "NONE" or #marketWebhookURL < 10 then return end
    local data = {
        embeds = {{
            title = "💰 CASH MARKET ALERT — Jujutsu Infinite",
            color = 6736998,
            fields = {
                { name = "📦 Item",          value = "**" .. itemName .. "**", inline = true },
                { name = "💵 Price",          value = tostring(price),          inline = true },
                { name = "👤 Player",         value = LocalPlayer.Name,         inline = true },
                { name = "🔄 Market Refresh", value = "#" .. refreshCount,      inline = true },
            },
            footer = { text = "JI Market Watcher • Purple Garden Edition" },
            timestamp = DateTime.now():ToIsoDate()
        }},
        content = "@everyone 💰 **" .. itemName .. "** is in the Cash Market!"
    }
    pcall(function()
        request({
            Url = marketWebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ================================================
--   TEST WEBHOOK (funny mock market)
-- ================================================
local GAME_LINK = "https://www.roblox.com/games/15615556549/Jujutsu-Infinite"

local function sendTestWebhook(webhookUrl, webhookName)
    if not webhookUrl or #webhookUrl < 10 then return false end
    local fakeItems = {
        { name = "Domain Shard [Unique]",    price = "ARE YOU KIDDING ME 💀" },
        { name = "Domain Shard [Unique]",    price = "ANOTHER ONE???" },
        { name = "Domain Shard [Unique]",    price = "BRO STOP 😭" },
        { name = "Maximum Scroll [Unique]",  price = "OK NOW IM CRYING" },
        { name = "Domain Shard [Unique]",    price = "THIS IS NOT REAL" },
        { name = "Cursed Hand [Unique]",     price = "SOMEONE CALL AN AMBULANCE" },
        { name = "Special Grade Item",       price = "FREE (just kidding lol)" },
        { name = "Sukuna's Finger 💅",       price = "priceless 🫵" },
    }
    local fields = {}
    for _, item in ipairs(fakeItems) do
        table.insert(fields, { name = "📦 " .. item.name, value = "💵 " .. item.price, inline = true })
    end
    table.insert(fields, { name = "🔗 Go Touch Grass Instead", value = GAME_LINK, inline = false })
    table.insert(fields, { name = "👤 Sent By", value = LocalPlayer.Name .. " (just testing 🌸)", inline = true })

    local data = {
        embeds = {{
            title = "🧪 WEBHOOK TEST — Fake Cash Market (none of this is real 💀)",
            color = 7864319,
            description = "✅ Your **" .. webhookName .. " webhook** is working!\nThis is what alerts look like when rare items hit the market.\n\n*The market below is completely fake and statistically impossible lmao*",
            fields = fields,
            footer = { text = "JI Item Finder • Purple Garden Edition • Test Message 🌸" },
            timestamp = DateTime.now():ToIsoDate()
        }},
        content = "🧪 **WEBHOOK TEST** — Calm down this is fake, but your webhook works! 🌸"
    }
    local ok = pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
    return ok
end

-- Test buttons on Market page
local MktTestBtn = Instance.new("TextButton", MarketPage)
MktTestBtn.Size = UDim2.new(0.48, 0, 0, 30)
MktTestBtn.Position = UDim2.new(0, 0, 1, -82)
MktTestBtn.BackgroundColor3 = THEME.TabActive
MktTestBtn.Text = "🧪 Test Market Hook"
MktTestBtn.TextColor3 = THEME.TextPrimary
MktTestBtn.TextSize = 11
MktTestBtn.Font = Enum.Font.GothamBold
MktTestBtn.BorderSizePixel = 0
Instance.new("UICorner", MktTestBtn).CornerRadius = UDim.new(0, 8)

local ItemTestBtn = Instance.new("TextButton", MarketPage)
ItemTestBtn.Size = UDim2.new(0.48, 0, 0, 30)
ItemTestBtn.Position = UDim2.new(0.52, 0, 1, -82)
ItemTestBtn.BackgroundColor3 = THEME.TabActive
ItemTestBtn.Text = "🧪 Test Item Hook"
ItemTestBtn.TextColor3 = THEME.TextPrimary
ItemTestBtn.TextSize = 11
ItemTestBtn.Font = Enum.Font.GothamBold
ItemTestBtn.BorderSizePixel = 0
Instance.new("UICorner", ItemTestBtn).CornerRadius = UDim.new(0, 8)

MktTestBtn.MouseButton1Click:Connect(function()
    MktTestBtn.Text = "Sending..."
    local ok = sendTestWebhook(marketWebhookURL, "Market")
    task.wait(1)
    MktTestBtn.Text = ok and "✅ Sent!" or "❌ Failed!"
    task.wait(2)
    MktTestBtn.Text = "🧪 Test Market Hook"
end)

ItemTestBtn.MouseButton1Click:Connect(function()
    ItemTestBtn.Text = "Sending..."
    local ok = sendTestWebhook(CONFIG.WebhookURL, "Item Finder")
    task.wait(1)
    ItemTestBtn.Text = ok and "✅ Sent!" or "❌ Failed!"
    task.wait(2)
    ItemTestBtn.Text = "🧪 Test Item Hook"
end)

local function addMarketCard(itemName, price)
    MktNoneLabel.Visible = false
    local card = Instance.new("Frame", MktScroll)
    card.Size = UDim2.new(1, -4, 0, 48)
    card.BackgroundColor3 = THEME.ServerCard
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", card)
    cs.Color = THEME.ServerCardBorder
    cs.Thickness = 1

    local il = Instance.new("TextLabel", card)
    il.Size = UDim2.new(0.7, 0, 1, 0)
    il.Position = UDim2.new(0, 8, 0, 0)
    il.BackgroundTransparency = 1
    il.Text = "💰 " .. itemName
    il.TextColor3 = THEME.TextAccent
    il.TextSize = 12
    il.Font = Enum.Font.GothamBold
    il.TextXAlignment = Enum.TextXAlignment.Left

    local pl = Instance.new("TextLabel", card)
    pl.Size = UDim2.new(0.3, -8, 1, 0)
    pl.Position = UDim2.new(0.7, 0, 0, 0)
    pl.BackgroundTransparency = 1
    pl.Text = tostring(price) .. " 💵"
    pl.TextColor3 = THEME.Success
    pl.TextSize = 11
    pl.Font = Enum.Font.GothamBold
    pl.TextXAlignment = Enum.TextXAlignment.Right

    MktScroll.CanvasSize = UDim2.new(0, 0, 0, MktListLayout.AbsoluteContentSize.Y + 10)
end

-- Also alert on every refresh regardless of items
local function sendRefreshWebhook(refreshCount, itemList)
    if marketWebhookURL == "NONE" or #marketWebhookURL < 10 then return end
    local itemText = #itemList > 0 and table.concat(itemList, ", ") or "No rare items"
    local data = {
        embeds = {{
            title = "🔄 Cash Market Refreshed — Jujutsu Infinite",
            color = 7864319,
            fields = {
                { name = "🔄 Refresh #",    value = tostring(refreshCount), inline = true },
                { name = "🌟 Rare Items",   value = itemText,               inline = false },
            },
            footer = { text = "JI Market Watcher • Purple Garden Edition" },
            timestamp = DateTime.now():ToIsoDate()
        }},
        content = #itemList > 0 and ("@everyone 🌟 Rare items in market: **" .. itemText .. "**") or nil
    }
    pcall(function()
        request({
            Url = marketWebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local isWatching = false
local refreshCount = 0
local lastMarketSnapshot = {}

local function scanMarket()
    local rareFound = {}
    -- Search entire game tree for market GUI elements
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            for _, watchItem in ipairs(MARKET_WATCHLIST) do
                if string.find(obj.Text, watchItem, 1, true) then
                    -- Try to find a nearby price label
                    local price = "?"
                    local parent = obj.Parent
                    if parent then
                        for _, sibling in ipairs(parent:GetChildren()) do
                            if sibling:IsA("TextLabel") and sibling ~= obj then
                                local txt = sibling.Text
                                if string.find(txt, "%d") then
                                    price = txt
                                end
                            end
                        end
                    end
                    -- Avoid duplicate alerts for same item same refresh
                    local key = watchItem
                    if not lastMarketSnapshot[key] then
                        lastMarketSnapshot[key] = true
                        table.insert(rareFound, watchItem)
                        addMarketCard(watchItem, price)
                        sendMarketWebhook(watchItem, price, refreshCount)
                    end
                end
            end
        end
    end
    return rareFound
end

MktToggleBtn.MouseButton1Click:Connect(function()
    if isWatching then
        isWatching = false
        MktToggleBtn.Text = "▶  Start Market Watcher"
        MktStatus.Text = "⏸ Watcher off"
        MktStatus.TextColor3 = THEME.TextSecondary
        return
    end

    isWatching = true
    MktToggleBtn.Text = "⏹  Stop Watcher"
    MktStatus.Text = "👀 Watching market..."
    MktStatus.TextColor3 = THEME.TextPrimary

    task.spawn(function()
        local lastScan = {}

        while isWatching do
            -- Detect market refresh by watching for GUI changes
            local currentSnapshot = {}
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("TextLabel") and string.find(obj.Name:lower(), "market") then
                    currentSnapshot[obj.Name] = obj.Text
                end
            end

            -- Check if market GUI content changed = refresh happened
            local changed = false
            for k, v in pairs(currentSnapshot) do
                if lastScan[k] ~= v then
                    changed = true
                    break
                end
            end

            if changed then
                refreshCount = refreshCount + 1
                lastMarketSnapshot = {}
                MktLastRefresh.Text = "Last refresh: #" .. refreshCount .. " at " .. os.date("%H:%M:%S")
                MktStatus.Text = "🔄 Market refreshed! Scanning..."
                MktStatus.TextColor3 = THEME.TextAccent

                local rareItems = scanMarket()
                sendRefreshWebhook(refreshCount, rareItems)

                if #rareItems > 0 then
                    MktStatus.Text = "🌟 " .. #rareItems .. " rare item(s) found!"
                    MktStatus.TextColor3 = THEME.Success
                else
                    MktStatus.Text = "👀 Refreshed — no rares this time"
                    MktStatus.TextColor3 = THEME.TextSecondary
                end

                lastScan = currentSnapshot
            end

            task.wait(1)
        end
    end)
end)


-- ================================================
--   TAB SWITCHING
-- ================================================
local function switchTab(tab)
    MainPage.Visible = false
    ServersPage.Visible = false
    CheckPage.Visible = false
    MarketPage.Visible = false
    for _, t in ipairs({TabMain, TabServers, TabCheck, TabMarket}) do
        t.BackgroundColor3 = THEME.TabInactive
        t.TextColor3 = THEME.TextSecondary
    end
    if tab == "main" then
        MainPage.Visible = true
        TabMain.BackgroundColor3 = THEME.TabActive
        TabMain.TextColor3 = THEME.TextPrimary
    elseif tab == "servers" then
        ServersPage.Visible = true
        TabServers.BackgroundColor3 = THEME.TabActive
        TabServers.TextColor3 = THEME.TextPrimary
    elseif tab == "check" then
        CheckPage.Visible = true
        TabCheck.BackgroundColor3 = THEME.TabActive
        TabCheck.TextColor3 = THEME.TextPrimary
    elseif tab == "market" then
        MarketPage.Visible = true
        TabMarket.BackgroundColor3 = THEME.TabActive
        TabMarket.TextColor3 = THEME.TextPrimary
    end
end

switchTab("main")
TabMain.MouseButton1Click:Connect(function() switchTab("main") end)
TabServers.MouseButton1Click:Connect(function() switchTab("servers") end)
TabCheck.MouseButton1Click:Connect(function() switchTab("check") end)
TabMarket.MouseButton1Click:Connect(function() switchTab("market") end)


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

-- Auto execute scan if enabled
if autoExecEnabled then
    task.wait(2)
    StatusLabel.Text = "⚡ Auto-starting..."
    StatusLabel.TextColor3 = THEME.TextAccent
    task.wait(1)
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
end
