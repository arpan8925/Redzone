local QBCore = exports['qb-core']:GetCoreObject()

local playerRedZone = nil
local redZoneBlips = {}
local redZoneBlipIcons = {}
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
AddEventHandler('arp-gang:client:createZone', function(pos, radius, isPlayerRedZone, zonetime)
    print(zonetime)
    -- Create the redzone blip (circle)
    local blip = AddBlipForRadius(pos.x, pos.y, pos.z, radius)
    SetBlipColour(blip, 75)
    SetBlipAlpha(blip, 128)

    -- Create the redzone blip icon
    local blipicon = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(blipicon, 303)
    SetBlipScale(blipicon, 1.0)
    SetBlipColour(blipicon, 75)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Avoid For Safety')
    EndTextCommandSetBlipName(blipicon)

    table.insert(redZoneBlips, blip)
    table.insert(redZoneBlipIcons, blipicon)
    table.insert(existingRedZones, { pos = pos, radius = radius })

    if isPlayerRedZone then
        playerRedZone = pos
        local redzonetime = zonetime / 60000
        redzonetime = math.floor(redzonetime)  -- Convert to integer by rounding down
        QBCore.Functions.Notify(string.format('RedZone activated at your location. It will expire in %d minute(s).', redzonetime), 'success')
    end
end)

RegisterNetEvent('arp-gang:client:removeZone')
AddEventHandler('arp-gang:client:removeZone', function(pos)
    for i = #existingRedZones, 1, -1 do
        local zone = existingRedZones[i]
        if zone.pos == pos then
            RemoveBlip(redZoneBlips[i])
            RemoveBlip(redZoneBlipIcons[i])
            table.remove(redZoneBlips, i)
            table.remove(redZoneBlipIcons, i)
            table.remove(existingRedZones, i)
        end
    end

    if playerRedZone and playerRedZone == pos then
        playerRedZone = nil
        QBCore.Functions.Notify('RedZone Removed', 'success')
    end
end)
