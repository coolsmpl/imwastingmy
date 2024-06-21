-- Thank you to: Mr. Harun, Mr. Krone

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local delayTime = 90 -- Adjust the delay time (in seconds) as needed
local DiscordWebhookURL = "" -- Add your webhook URL here

local BlacklistedPlayers = {}
local WhitelistedPlayers = {}
local ModsTable = {}
local kroneTable = {}
local BLSV, WLSV, MDSV, KRONE = false, false, false, false

local Settings = {
    ServerHops = 1,
    Distance = 18,
    Globals = {"Executions", "List"}
}

local kroneUserids = {4710732523, 354902977}

-- Function to teleport with error handling and Discord notification
local function teleport()
    local success, err = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    if not success then
        -- Send error to Discord Webhook
        local data = {
            content = "Error occurred while teleporting: " .. tostring(err)
        }
        local headers = {
            ["Content-Type"] = "application/json"
        }
        local requestInfo = {
            Url = DiscordWebhookURL,
            Method = "POST",
            Headers = headers,
            Body = HttpService:JSONEncode(data)
        }
        local webhookSuccess, response = pcall(function()
            HttpService:RequestAsync(requestInfo)
        end)
        if not webhookSuccess then
            warn("Failed to send error to Discord Webhook: " .. tostring(response))
        end
    end
end

-- Delay before teleporting
task.delay(delayTime, teleport)

-- Check functions
local function checkBlacklist(player)
    if table.find(BlacklistedPlayers, player.UserId) then
        table.insert(BlacklistedPlayers, player)
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Blacklisted Player Detected: " .. player.DisplayName, "All")
        BLSV = true
    end
end

local function checkKrone(player)
    if table.find(kroneUserids, player.UserId) then
        table.insert(kroneTable, player)
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("krone | owner Detected: " .. player.DisplayName, "All")
        KRONE = true
    end
end

local function checkWhitelist(player)
    if table.find(WhitelistedPlayers, tostring(player.UserId)) then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Whitelisted Player Detected: " .. player.DisplayName, "All")
    end
    WLSV = true
end

local function checkAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            checkBlacklist(player)
            checkKrone(player)
            checkWhitelist(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        checkBlacklist(player)
        checkKrone(player)
        checkWhitelist(player)
    end
end)
checkAllPlayers()

-- Continuously monitor and handle players
local function monitorPlayers()
    while true do
        wait()
        if #BlacklistedPlayers > 0 then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not table.find(BlacklistedPlayers, player) then
                    player:Destroy()
                    if player.Character then
                        player.Character:Destroy()
                        wait(0.1)
                    end
                end
            end
        end
        if #WhitelistedPlayers > 0 then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and table.find(WhitelistedPlayers, player) then
                    player:Destroy()
                    if player.Character then
                        player.Character:Destroy()
                        wait(0.1)
                    end
                end
            end
        end
        if #kroneTable > 0 then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and table.find(kroneTable, player) then
                    player:Destroy()
                    if player.Character then
                        player.Character:Destroy()
                        wait(0.1)
                    end
                end
            end
        end
    end
end

coroutine.wrap(monitorPlayers)()

-- Set game lighting
game:GetService("Lighting").ClockTime = 0

-- Server hop functionality
local function ServerHop()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and response and response.data then
        local AvailableServers = response.data
        while true do
            wait()
            local RandomServer = AvailableServers[math.random(#AvailableServers)]
            if RandomServer.playing < RandomServer.maxPlayers - 1 and RandomServer.playing > 12 and RandomServer.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, RandomServer.id)
            end
        end
    else
        warn("Failed to retrieve server list. Retrying...")
        ServerHop()
    end
end

local function hop()
    while true do
        local success, errorMessage = pcall(ServerHop)
        if not success then
            warn("Server hop error: " .. errorMessage)
        end
        wait()
    end
end

-- Automatically server hop after 90 seconds
task.delay(90, hop)

-- Dance animations
local animations = {3333499508, 3695333486, 3333136415, 3338042785, 4940561610, 4940564896, 4841399916, 4641985101, 4555782893, 4265725525, 3338097973, 3333432454, 3333387824, 4406555273, 4212455378, 4049037604, 3695300085, 3695322025, 5915648917, 5915714366, 5918726674, 5917459365, 5915712534, 5915713518, 5937558680, 5918728267, 5937560570, 507776043, 507777268, 507771019}
local randomDance = animations[math.random(1, #animations)]
local WaveAnim = Instance.new("Animation")
WaveAnim.AnimationId = "rbxassetid://" .. tostring(randomDance)

local function PlayWaveAnim()
    local wave = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(WaveAnim)
    wave:Play(1, 5, 1)
end
PlayWaveAnim()

if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
    coroutine.wrap(function()
        while wait() do
            if LocalPlayer.CharacterAdded then
                LocalPlayer.CharacterAdded:wait()
                wait(1)
                PlayWaveAnim()
            end
        end
    end)()
end

local CF = LocalPlayer.Character.HumanoidRootPart.CFrame
local numb = 0

local function Nearby(TP, WP)
    local WC, TC = WP.Character or nil, TP.Character or nil
    if WC and TC then
        local WPS, TPS = WC.PrimaryPart.Position or nil, TC.PrimaryPart.Position or nil
        if WPS and TPS then
            return ((WPS - TPS).magnitude <= Settings.Distance)
        else
            return false
        end
    end
    return false
end

-- Main function for handling target players
local function shhhlol(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid.RootPart
    
    local im = TargetPlayer.Character
    local so = im.HumanoidRootPart
    
    local function onPlayerDetected()
        task.wait()
        if Nearby(LocalPlayer, TargetPlayer) then
            if Humanoid and Humanoid.Health ~= 0 then
                Character:MoveTo(im.HumanoidRootPart.Position)
                local BB = HumanoidRootPart.Position
                local ORGCF = RootPart.CFrame
                for _, part in pairs(im:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                Character:WaitForChild("RightHand").CFrame = so.CFrame
                so.CFrame = HumanoidRootPart.CFrame
                task.wait()
                for _, part in pairs(im:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                Character:MoveTo(BB)
                RootPart.CFrame = ORGCF
                im:Destroy()
            end
        end
    end

    coroutine.wrap(function()
        while wait() do
            if TargetPlayer then
                task.wait()
                onPlayerDetected()
            end
        end
    end)()
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        shhhlol(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        shhhlol(v)
    end
end)

-- Prevent character from sitting
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Sit then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
    end
end)

-- Ensure parts are non-collidable
RunService.Stepped:Connect(function()
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Spam promotional message
local function spam()
    while true do
        wait()
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("made by c2vp | lol")
    end
end

coroutine.wrap(spam)()
