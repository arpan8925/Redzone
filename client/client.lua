local QBCore = exports['qb-core']:GetCoreObject()

local playerRedZone = nil
local redZoneBlips = {}
local existingRedZones = {}

-- Function to check if the player is a gang member
function IsPlayerGangMember()
    local playerGang = QBCore.Functions.GetPlayerData().gang
    if playerGang and playerGang.name ~= "none" then
        return true
    else
        return false
    end
end

RegisterCommand('redzone', function()
    if not IsPlayerGangMember() then
        QBCore.Functions.Notify('You are not authorized to use this command', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    -- Check if the player has an active red zone
    if playerRedZone then
        -- Debugging: Output current playerRedZone and distance to it
        print("Debug: Player has an active red zone at " .. json.encode(playerRedZone))
        local distanceToActiveRedZone = #(playerPos - playerRedZone)
        print("Debug: Distance to active red zone is " .. distanceToActiveRedZone)

        -- Check if the player is inside their active red zone
        if distanceToActiveRedZone <= Config.RedZoneRadius then
            -- Inside the active red zone, delete it
            TriggerServerEvent('redzone:removeZone', playerRedZone)
            print("Debug: Removing active red zone.")
        else
            -- Outside the active red zone, show an error
            QBCore.Functions.Notify('First delete your existing redzone to create a new one.', 'error')
            print("Debug: Player is outside the active red zone. Cannot create a new one.")
        end
    else
        -- Create a new red zone
        TriggerServerEvent('redzone:createZone', playerPos, Config.RedZoneRadius)
        print("Debug: Creating a new red zone at " .. json.encode(playerPos))
    end
end, false)

-- Event to create a red zone on the client side
RegisterNetEvent('redzone:createZone')
AddEventHandler('redzone:createZone', function(pos, radius, isPlayerRedZone)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    SetBlipColour(blip, 1) -- Red color
    SetBlipAlpha(blip, 128) -- Semi-transparent

    table.insert(redZoneBlips, blip)
    table.insert(existingRedZones, { pos = pos, radius = radius })

    -- Only set playerRedZone if this red zone belongs to the local player
    if isPlayerRedZone then
        playerRedZone = pos  -- Store the player's red zone position
        QBCore.Functions.Notify('Redzone activated at your location', 'success')
        print("Debug: Player's red zone activated at " .. json.encode(pos))
    end
end)

-- Event to remove a red zone on the client side
RegisterNetEvent('redzone:removeZone')
AddEventHandler('redzone:removeZone', function(pos)
    for i, zone in ipairs(existingRedZones) do
        if zone.pos == pos then
            RemoveBlip(redZoneBlips[i])
            table.remove(redZoneBlips, i)
            table.remove(existingRedZones, i)
            break
        end
    end

    if playerRedZone and playerRedZone == pos then
        playerRedZone = nil  -- Clear the player's red zone
        print("Debug: Player's red zone removed.")
    end

    QBCore.Functions.Notify('Redzone deactivated', 'success')
end)
