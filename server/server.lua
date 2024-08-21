local QBCore = exports['qb-core']:GetCoreObject()

local activeRedZones = {}

RegisterNetEvent('arp-gang:server:createZone')
AddEventHandler('arp-gang:server:createZone', function(pos, radius)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    activeRedZones[playerId] = pos

    TriggerClientEvent('arp-gang:client:createZone', src, pos, radius, true)
    TriggerClientEvent('arp-gang:client:createZone', -1, pos, radius, false)
end)

RegisterNetEvent('arp-gang:server:removeZone')
AddEventHandler('arp-gang:server:removeZone', function(pos)
    local src = source
    local playerId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    if activeRedZones[playerId] then
        activeRedZones[playerId] = nil
        TriggerClientEvent('arp-gang:client:removeZone', -1, pos)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Already a Redzone Activated of Another Player', 'error')
    end
end)
