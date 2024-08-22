local QBCore = exports['qb-core']:GetCoreObject()

local playerRedZone = nil
local redZoneBlips = {}
local existingRedZones = {}

function IsPlayerGangMember()
    local playerGang = QBCore.Functions.GetPlayerData().gang
    return playerGang and playerGang.name ~= "none"
end

Citizen.CreateThread(function()
    local textDisplayed = false
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local isInZone = false

        for _, zone in ipairs(existingRedZones) do
            local distanceToZone = #(playerPos - zone.pos)
            if distanceToZone <= zone.radius then
                isInZone = true
                if not textDisplayed then
                    exports['qb-drawtext']:DrawText('You are inside of a Redzone', 'center')
                    textDisplayed = true
                end
                break
            end
        end

        if not isInZone and textDisplayed then
            exports['qb-drawtext']:HideText()
            textDisplayed = false
        end
    end
end)


RegisterCommand('redzone', function()
    if not IsPlayerGangMember() then
        QBCore.Functions.Notify('You are not authorized to use this command', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    for _, zone in ipairs(existingRedZones) do
        local distanceToZone = #(playerPos - zone.pos)
        if distanceToZone <= zone.radius then
            TriggerServerEvent('arp-gang:server:removeZone', zone.pos)
            return
        end
    end

    TriggerServerEvent('arp-gang:server:createZone', playerPos, Config.RedZoneRadius)
end, false)

RegisterNetEvent('arp-gang:client:createZone')
AddEventHandler('arp-gang:client:createZone', function(pos, radius, isPlayerRedZone)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    
    SetBlipColour(blip, 75)
    SetBlipAlpha(blip, 128)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('REDZONE')

    table.insert(redZoneBlips, blip)
    table.insert(existingRedZones, { pos = pos, radius = radius })

    if isPlayerRedZone then
        playerRedZone = pos
        QBCore.Functions.Notify('RedZone activated at your location. It will expire in 60 seconds.', 'success')
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