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
            TriggerServerEvent('redzone:removeZone', playerRedZone)
        else
            QBCore.Functions.Notify('First delete your existing redzone to create a new one.', 'error')
        end
    else
        TriggerServerEvent('redzone:createZone', playerPos, Config.RedZoneRadius)
    end
end, false)

RegisterNetEvent('redzone:createZone')
AddEventHandler('redzone:createZone', function(pos, radius, isPlayerRedZone)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)

    table.insert(redZoneBlips, blip)
    table.insert(existingRedZones, { pos = pos, radius = radius })

    if isPlayerRedZone then
        playerRedZone = pos
        QBCore.Functions.Notify('Redzone activated at your location', 'success')
    end
end)

RegisterNetEvent('redzone:removeZone')
AddEventHandler('redzone:removeZone', function(pos)
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
    end

    QBCore.Functions.Notify('Redzone deactivated', 'success')
end)