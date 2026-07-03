local DiscordWebhook = "DEIN_DISCORD_WEBHOOK_HIER" 
local activeEventData = nil

local ErlaubteGruppen = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["mod"] = true,
    ["projektleitung"] = true,
}

RegisterCommand("eventmenu", function(source, args, rawCommand)
    local xPlayer = nil
    local playerGroup = "user"

    if GetResourceState("es_extended") == "started" then
        xPlayer = exports["es_extended"]:getSharedObject().GetPlayerFromId(source)
        if xPlayer then playerGroup = xPlayer.getGroup() end
    elseif GetResourceState("qb-core") == "started" then
        local QBCore = exports['qb-core']:GetCoreObject()
        xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then playerGroup = QBCore.Functions.GetPermission(source) end
    else
        TriggerClientEvent("eventhud:client:openAdminMenu", source)
        return
    end

    if ErlaubteGruppen[playerGroup] then
        TriggerClientEvent("eventhud:client:openAdminMenu", source)
    else
        TriggerClientEvent("ox_lib:notify", source, {type = "error", description = "Du hast keine Rechte für dieses Menü!"})
    end
end, false)

RegisterNetEvent("eventhud:server:startEventGlobal", function(data)
    activeEventData = data
    TriggerClientEvent("eventhud:client:showEvent", -1, data)
    SendDiscordLog(data)
end)

RegisterNetEvent("eventhud:server:stopEventGlobal", function()
    activeEventData = nil
    TriggerClientEvent("eventhud:client:hideEventGlobal", -1)
end)

-- 🚨 POLIZEI-NOTRUF MIT EXTRASCHREIBSCHUTZ FÜR DIE DISPATCH-NOTIZ
RegisterNetEvent("eventhud:server:sendPoliceDispatch", function(coords, dispatchText)
    local message = "[LEITSTELLE] Anonyme Meldung: " .. dispatchText
    
    if GetResourceState("es_extended") == "started" then
        local xPlayers = exports["es_extended"]:getSharedObject().GetExtendedPlayers("job", "police")
        for _, xPlayer in ipairs(xPlayers) do
            TriggerClientEvent("esx:showNotification", xPlayer.source, "🚨 " .. message)
            TriggerClientEvent("esx_phone:addSpecialBlip", xPlayer.source, coords, "Event Aktivität", 20000)
        end
    elseif GetResourceState("qb-core") == "started" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local players = QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(players) do
            local player = QBCore.Functions.GetPlayer(playerId)
            if player and player.PlayerData.job.name == "police" then
                TriggerClientEvent("QBCore:Notify", playerId, message, "error", 10000)
                TriggerClientEvent("qb-phone:client:addPoliceBlip", playerId, coords)
            end
        end
    end
end)

RegisterNetEvent("esx:playerLoaded", function(source)
    if activeEventData then TriggerClientEvent("eventhud:client:showEvent", source, activeEventData) end
end)
RegisterNetEvent("QBCore:Server:PlayerLoaded", function(player)
    if activeEventData and player then TriggerClientEvent("eventhud:client:showEvent", player.PlayerData.source, activeEventData) end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if activeEventData then
            local count = 0
            for _, playerId in ipairs(GetPlayers()) do
                if GetPlayerRoutingBucket(playerId) == Config.EventDimension then count = count + 1 end
            end
            TriggerClientEvent("eventhud:client:updatePlayerCount", -1, count)
        end
    end
end)

function SendDiscordLog(data)
    if DiscordWebhook == "DEIN_DISCORD_WEBHOOK_HIER" then return end
    local zusatzNotiz = (data.note and data.note ~= "") and data.note or "Keine"
    local dispatchNotiz = (data.dispatch and data.dispatch ~= "") and data.dispatch or "Keine"
    local embed = {
        {
            ["title"] = "📢 Neues Event angekündigt!",
            ["color"] = 16744192, 
            ["fields"] = {
                {["name"] = "📌 Event-Name", ["value"] = data.name, ["inline"] = true},
                {["name"] = "📅 Datum", ["value"] = data.date, ["inline"] = true},
                {["name"] = "🕒 Uhrzeit", ["value"] = data.time, ["inline"] = true},
                {["name"] = "📝 Globale Notiz", ["value"] = zusatzNotiz, ["inline"] = false},
                {["name"] = "🚨 Dispatch Notiz", ["value"] = dispatchNotiz, ["inline"] = false},
                {["name"] = "🔗 Discord", ["value"] = data.discord, ["inline"] = false}
            }
        }
    }
    PerformHttpRequest(DiscordWebhook, function(statusCode, text, headers) end, 'POST', json.encode({username = "Event Manager", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
