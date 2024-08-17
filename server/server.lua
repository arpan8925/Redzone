local QBCore = exports['qb-core']:GetCoreObject()

local activeRedZones = {}

-- Handle the creation of a red zone
RegisterNetEvent('redzone:createZone')
AddEventHandler('redzone:createZone', function(pos, radius)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    if activeRedZones[playerId] then
        TriggerClientEvent('QBCore:Notify', src, 'First delete your existing redzone to create a new one.', 'error')
        return
    end

    activeRedZones[playerId] = pos

    TriggerClientEvent('redzone:createZone', src, pos, radius, true)
    TriggerClientEvent('redzone:createZone', -1, pos, radius, false)
end)

-- Handle the removal of a red zone
RegisterNetEvent('redzone:removeZone')
AddEventHandler('redzone:removeZone', function(pos)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    if activeRedZones[playerId] then
        activeRedZones[playerId] = nil
        TriggerClientEvent('redzone:removeZone', -1, pos)
    else
        TriggerClientEvent('QBCore:Notify', src, 'No active redzone found.', 'error')
    end
end)