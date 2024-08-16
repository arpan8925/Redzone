local QBCore = exports['qb-core']:GetCoreObject()

local activeRedZones = {}  -- Stores active red zones per player

-- Handle the creation of a red zone
RegisterNetEvent('redzone:createZone')
AddEventHandler('redzone:createZone', function(pos, radius)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    -- Debugging: Output current player ID and whether they have an active red zone
    print("Debug: Player ID " .. playerId .. " attempting to create a red zone.")
    if activeRedZones[playerId] then
        TriggerClientEvent('QBCore:Notify', src, 'First delete your existing redzone to create a new one.', 'error')
        print("Debug: Player ID " .. playerId .. " already has an active red zone.")
        return
    end

    -- Store the player's red zone
    activeRedZones[playerId] = pos
    print("Debug: Red zone created for Player ID " .. playerId .. " at " .. json.encode(pos))

    -- Broadcast to the specific client that created the red zone
    TriggerClientEvent('redzone:createZone', src, pos, radius, true)

    -- Broadcast to all other clients that a red zone has been created (not their own)
    TriggerClientEvent('redzone:createZone', -1, pos, radius, false)
end)

-- Handle the removal of a red zone
RegisterNetEvent('redzone:removeZone')
AddEventHandler('redzone:removeZone', function(pos)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    -- Remove the player's red zone
    if activeRedZones[playerId] then
        activeRedZones[playerId] = nil
        print("Debug: Red zone removed for Player ID " .. playerId)
    else
        print("Debug: No red zone found for Player ID " .. playerId)
    end

    -- Broadcast to all clients with the position to remove the correct red zone
    TriggerClientEvent('redzone:removeZone', -1, pos)
end)
