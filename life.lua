-- Define the interval in seconds for both fling and message
local interval = 7
local riseHeight = 3  -- Height above spawn point in studs

-- Function to fling all players and rise above spawn point
local function flingEveryone()
    -- Get all players in the game
    local players = game.Players:GetPlayers()

    -- Iterate through each player and fling them
    for _, player in ipairs(players) do
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Get player's spawn position
                local spawnPosition = player.Character.HumanoidRootPart.Position
                local newPosition = spawnPosition + Vector3.new(0, riseHeight, 0)
                
                -- Teleport player above spawn point
                humanoidRootPart.CFrame = CFrame.new(newPosition)
                
                -- Apply a force to fling the player
                local flingForce = Vector3.new(0, 9e9, 0)  -- Very large force
                humanoidRootPart.Velocity = flingForce
            end
        end
    end
end

-- Function to send a message to all players
local function sendMessage()
    -- Get all players in the game
    local players = game.Players:GetPlayers()

    -- Iterate through each player and send them a message
    for _, player in ipairs(players) do
        game:GetService("Chat"):Chat(player.Character or player, "this code was made by c2vp on ds | add me")
    end
end

-- Infinite loop to perform actions every interval
while true do
    flingEveryone()
    sendMessage()
    wait(interval)
end
