local QBCore = exports['qb-core']:GetCoreObject()

local playerRedZone = nil
local redZoneBlips = {}
local existingRedZones = {}

function IsPlayerGangMember()
    local playerGang = QBCore.Functions.GetPlayerData().gang
    return playerGang and playerGang.name ~= "none"
end

RegisterCommand('redzone', function()
    if not IsPlayerGangMember() then
        QBCore.Functions.Notify('You are not authorized to use this command', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    if playerRedZone then
        local distanceToActiveRedZone = #(playerPos - playerRedZone)

        if distanceToActiveRedZone <= Config.RedZoneRadius then
            TriggerServerEvent('arp-gang:server:removeZone', playerRedZone)
        else
            QBCore.Functions.Notify('First delete your existing RedZone to create a new one.', 'error')
        end
    else
        TriggerServerEvent('arp-gang:server:createZone', playerPos, Config.RedZoneRadius)
    end
end, false)

RegisterNetEvent('arp-gang:client:createZone')
AddEventHandler('arp-gang:client:createZone', function(pos, radius, isPlayerRedZone)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)

    table.insert(redZoneBlips, blip)
    table.insert(existingRedZones, { pos = pos, radius = radius })

    if isPlayerRedZone then
        playerRedZone = pos
        QBCore.Functions.Notify('RedZone activated at your location', 'success')
    end
end)

RegisterNetEvent('arp-gang:client:removeZone')
AddEventHandler('arp-gang:client:removeZone', function(pos)
    for i = #existingRedZones, 1, -1 do
        local zone = existingRedZones[i]
        if zone.pos == pos then
            RemoveBlip(redZoneBlips[i])
            table.remove(redZoneBlips, i)
            table.remove(existingRedZones, i)
        end
    end

    if playerRedZone and playerRedZone == pos then
        playerRedZone = nil
        QBCore.Functions.Notify('RedZone Removed', 'success')
    end

end)