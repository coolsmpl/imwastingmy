-- Constants
local FLING_FORCE = 9e9 -- Adjust as needed
local SPIN_SPEED = 9e9 -- Adjust as needed
local ANIMATION_IDS = {
    3333499508, 3695333486, 3333136415, 3338042785, 4940561610,
    4940564896, 4841399916, 4641985101, 4555782893, 4265725525,
    3338097973, 3333432454, 3333387824, 4406555273, 4212455378,
    4049037604, 3695300085, 3695322025, 5915648917, 5915714366,
    5918726674, 5917459365, 5915712534, 5915713518, 5937558680,
    5918728267, 5937560570, 507776043, 507777268, 507771019
}

-- Functions
local function findNonSittingPlayers()
    local players = game.Players:GetPlayers()
    local nonSittingPlayers = {}
    for _, player in ipairs(players) do
        if not player.Character.Humanoid.Sit then
            table.insert(nonSittingPlayers, player)
        end
    end
    return nonSittingPlayers
end

local function flingPlayer(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local flingVector = Vector3.new(0, FLING_FORCE, 0)
            rootPart.Velocity = flingVector
            rootPart.RotVelocity = Vector3.new(math.random(-SPIN_SPEED, SPIN_SPEED), math.random(-SPIN_SPEED, SPIN_SPEED), math.random(-SPIN_SPEED, SPIN_SPEED))
        end
    end
end

local function playRandomAnimation()
    local randomAnimationId = ANIMATION_IDS[math.random(1, #ANIMATION_IDS)]
    if randomAnimationId then
        humanoid.AnimationId = "rbxassetid://" .. randomAnimationId
        humanoid:PlayAnimation(humanoid.AnimationId)
    end
end

-- Kick and server hop function
local function kickAndServerHop()
    print("Kicking and server hopping...")
    game.Players.LocalPlayer:Kick("Automatic kick and server hop")
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end

-- Main loop
local startTime = tick() -- Get the initial time
while true do
    local elapsedTime = tick() - startTime
    if elapsedTime >= 120 then
        kickAndServerHop()
        break -- Exit the loop after kicking and server hopping
    end

    local nonSittingPlayers = findNonSittingPlayers()
    if #nonSittingPlayers > 0 then
        for _, player in ipairs(nonSittingPlayers) do
            flingPlayer(player)
        end
    else
        -- If no non-sitting players, rise above spawn and play random animations
        local spawnPoint = game.Workspace:WaitForChild("SpawnPoint") -- Adjust to your spawn point name
        script.Parent.CFrame = spawnPoint.CFrame + Vector3.new(0, 20, 0) -- Adjust the height as needed
        playRandomAnimation()
    end
    wait(1) -- Adjust the interval as needed
end
