local QBCore = exports['qb-core']:GetCoreObject()

local activeRedZones = {}

RegisterNetEvent('arp-gang:server:createZone')
AddEventHandler('arp-gang:server:createZone', function(pos, radius)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerId = Player.PlayerData.citizenid

    if activeRedZones[playerId] then
        local existingZone = activeRedZones[playerId]
        local distance = #(vector3(pos.x, pos.y, pos.z) - vector3(existingZone.pos.x, existingZone.pos.y, existingZone.pos.z))
        
        if distance > radius then
            TriggerClientEvent('QBCore:Notify', src, 'You already have an active RedZone. You can only create a new one inside your existing RedZone.', 'error')
            return
        end
    end

    activeRedZones[playerId] = {
        pos = pos,
        radius = radius,
        creationTime = os.time()
    }

    TriggerClientEvent('arp-gang:client:createZone', src, pos, radius, true)
    TriggerClientEvent('arp-gang:client:createZone', -1, pos, radius, false)

    SetTimeout(1500000, function()
        if activeRedZones[playerId] and activeRedZones[playerId].pos == pos then
            activeRedZones[playerId] = nil
            TriggerClientEvent('arp-gang:client:removeZone', -1, pos)
            TriggerClientEvent('QBCore:Notify', src, 'Your RedZone has expired and been removed', 'info')
        end
    end)
end)

RegisterNetEvent('arp-gang:server:removeZone')
AddEventHandler('arp-gang:server:removeZone', function(pos)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerId = Player.PlayerData.citizenid

    if activeRedZones[playerId] then
        activeRedZones[playerId] = nil
        TriggerClientEvent('arp-gang:client:removeZone', -1, pos)
    else
        TriggerClientEvent('QBCore:Notify', src, 'A RedZone is already active in this location', 'error')
    end
end)

