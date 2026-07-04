local DiscordWebhook = "DEIN_DISCORD_WEBHOOK_HIER" 
local activeEventData = nil
local participants = {} 
local eventStarterName = "Niemand" -- 🔄 NEU: Speichert den Namen des Starters
local eventStarterId = 0          -- 🔄 NEU: Speichert die ID des Starters

local ErlaubteGruppen = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["mod"] = true,
    ["projektleitung"] = true,
}

-- Hilfsfunktion: Prüft die Rechte des Spielers
local function HatSpielerRechte(playerId)
    local playerGroup = "user"
    if GetResourceState("es_extended") == "started" then
        local xPlayer = exports["es_extended"]:getSharedObject().GetPlayerFromId(playerId)
        if xPlayer then playerGroup = xPlayer.getGroup() end
    elseif GetResourceState("qb-core") == "started" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        if xPlayer then playerGroup = QBCore.Functions.GetPermission(playerId) end
    else
        return true 
    end
    return ErlaubteGruppen[playerGroup] or false
end

local function SendNotification(target, text, type)
    if Config.NotifyScript == "ox_lib" then
        TriggerClientEvent("ox_lib:notify", target, {type = type, description = text})
    elseif Config.NotifyScript == "esx" then
        TriggerClientEvent("esx:showNotification", target, text)
    elseif Config.NotifyScript == "qb" then
        TriggerClientEvent("QBCore:Notify", target, text, type)
    else
        TriggerClientEvent("chat:addMessage", target, { args = { "^1[Event]", text } })
    end
end

local function UpdateParticipantCount()
    local count = 0
    for _ in pairs(participants) do count = count + 1 end
    TriggerClientEvent("eventhud:client:updatePlayerCount", -1, count)
    return count
end

RegisterCommand("eventmenu", function(source, args, rawCommand)
    local playerId = source
    if playerId == 0 then return end 

    if HatSpielerRechte(playerId) then
        TriggerClientEvent("eventhud:client:openAdminMenu", playerId)
    else
        SendNotification(playerId, "Du hast keine Rechte für dieses Menü!", "error")
    end
end, false)

RegisterNetEvent("eventhud:server:startEventGlobal", function(data)
    local adminId = source
    
    if not HatSpielerRechte(adminId) then
        local cheatMsg = ("[WARNUNG] Exploit-Versuch! Spieler %s (ID: %s) hat versucht, das Event '%s' ohne Rechte zu starten!"):format(GetPlayerName(adminId), adminId, data.name)
        RconPrint("^1" .. cheatMsg .. "\n")
        TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. cheatMsg)
        return
    end

    -- 🔄 Merkt sich, wer das Event gestartet hat
    eventStarterId = adminId
    eventStarterName = GetPlayerName(adminId) or "Unbekannter Admin"
    
    participants = {} 
    activeEventData = data
    TriggerClientEvent("eventhud:client:showEvent", -1, data)
    SendDiscordLog(data)
    UpdateParticipantCount()
    
    local startMsg = ("[Event-HUD] Global Event '%s' wurde von Admin %s (ID: %s) gestartet."):format(data.name, eventStarterName, eventStarterId)
    RconPrint(startMsg .. "\n")
    TriggerClientEvent("eventhud:client:f8Print", -1, "^2" .. startMsg)
end)

RegisterNetEvent("eventhud:server:stopEventGlobal", function()
    local adminId = source
    
    if not HatSpielerRechte(adminId) then
        local cheatMsg = ("[WARNUNG] Exploit-Versuch! Spieler %s (ID: %s) hat versucht, das Event ohne Rechte zu beenden!"):format(GetPlayerName(adminId), adminId)
        RconPrint("^1" .. cheatMsg .. "\n")
        TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. cheatMsg)
        return
    end

    local stopperName = GetPlayerName(adminId) or "Unbekannter Admin"
    local finalCount = UpdateParticipantCount()
    
    -- 💡 DER NEUE DYNAMISCHE PRINT BEI FREMDBEENDIGUNG
    local stopMsg = ""
    if adminId == eventStarterId then
        -- Der gleiche Admin beendet es selbst
        stopMsg = ("[Event-HUD] Global Event beendet von %s (ID: %s). Finale Teilnehmerzahl: %s."):format(stopperName, adminId, finalCount)
    else
        -- 🔄 EIN ANDERER Admin beendet es!
        stopMsg = ("[Event-HUD] FREMDBEENDIGUNG: Event (gestartet von %s [ID: %s]) wurde vorzeitig beendet von Admin %s (ID: %s). Teilnehmerzahl: %s."):format(eventStarterName, eventStarterId, stopperName, adminId, finalCount)
    end

    activeEventData = nil
    participants = {} 
    eventStarterName = "Niemand"
    eventStarterId = 0
    collectgarbage("collect") 
    
    TriggerClientEvent("eventhud:client:hideEventGlobal", -1)
    
    RconPrint(stopMsg .. "\n")
    TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. stopMsg)
end)

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
    if activeEventData then 
        TriggerClientEvent("eventhud:client:showEvent", source, activeEventData) 
        TriggerClientEvent("eventhud:client:updatePlayerCount", source, UpdateParticipantCount())
    end
end)
RegisterNetEvent("QBCore:Server:PlayerLoaded", function(player)
    if activeEventData and player then 
        TriggerClientEvent("eventhud:client:showEvent", player.PlayerData.source, activeEventData) 
        TriggerClientEvent("eventhud:client:updatePlayerCount", player.PlayerData.source, UpdateParticipantCount())
    end
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    if participants[playerId] then
        participants[playerId] = nil
        UpdateParticipantCount()
    end
end)

-- 🟢 COMMAND: Event beitreten
RegisterCommand(Config.JoinCommand, function(source, args, rawCommand)
    local playerId = source
    
    if not activeEventData then
        local errorMsg = ("[Event-HUD] Beitritts-Fehler: Spieler %s (ID: %s) wollte beitreten, aber es laeuft kein Event."):format(GetPlayerName(playerId), playerId)
        RconPrint(errorMsg .. "\n")
        TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. errorMsg)
        SendNotification(playerId, "Aktuell ist kein globales Event aktiv!", "error")
        return
    end

    if participants[playerId] then
        SendNotification(playerId, "Du bist bereits für das Event angemeldet!", "error")
        return
    end

    participants[playerId] = true
    SendNotification(playerId, "Du nimmst nun am Event teil!", "success")
    UpdateParticipantCount()
    
    local msg = ("[Event-HUD] Spieler %s (ID: %s) hat sich ueber /%s angemeldet."):format(GetPlayerName(playerId), playerId, Config.JoinCommand)
    RconPrint(msg .. "\n")
    TriggerClientEvent("eventhud:client:f8Print", -1, "^2" .. msg)
end, false)

-- 🔴 COMMAND: Event verlassen
RegisterCommand(Config.LeaveCommand, function(source, args, rawCommand)
    local playerId = source

    if not participants[playerId] then
        local errorMsg = ("[Event-HUD] Abmelde-Fehler: Spieler %s (ID: %s) wollte das Event verlassen, war aber nicht angemeldet."):format(GetPlayerName(playerId), playerId)
        RconPrint(errorMsg .. "\n")
        TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. errorMsg)
        SendNotification(playerId, "Du bist für kein aktives Event angemeldet!", "error")
        return
    end

    participants[playerId] = nil
    SendNotification(playerId, "Du hast die Event-Teilnahme beendet.", "inform")
    UpdateParticipantCount()
    
    local msg = ("[Event-HUD] Spieler %s (ID: %s) hat sich ueber /%s abgemeldet."):format(GetPlayerName(playerId), playerId, Config.LeaveCommand)
    RconPrint(msg .. "\n")
    TriggerClientEvent("eventhud:client:f8Print", -1, "^1" .. msg)
end, false)

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
