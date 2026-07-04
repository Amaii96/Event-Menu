local currentDiscordLink = "#"
local isHUDActive = false      
local isHUDVisible = false     
local policeDispatchText = ""
local dispatchCoords = nil

Citizen.CreateThread(function()
    Citizen.Wait(2000) 
    SendNUIMessage({
        action = "loadConfig",
        config = Config.HUD,
        lang = Config.Translations[Config.Language] or Config.Translations["de"],
        showNotes = Config.ShowNotes
    })
end)

-- 👁️ Empfängt alle Fehlermeldungen und Logs und schreibt sie in F8
RegisterNetEvent("eventhud:client:f8Print", function(msg)
    print(msg)
end)

-- Ein-/Ausblenden Command für Spieler
RegisterCommand("eventhud", function()
    if not isHUDActive then return end
    isHUDVisible = not isHUDVisible
    if isHUDVisible then SendNUIMessage({ action = "forceShow" }) else SendNUIMessage({ action = "hide" }) end
end, false)

RegisterNetEvent("eventhud:client:openAdminMenu", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openAdmin" })
end)

RegisterNetEvent("eventhud:client:showEvent", function(data)
    currentDiscordLink = data.discord or "#"
    isHUDActive = true
    isHUDVisible = true
    policeDispatchText = data.dispatch or "" 
    
    if data.adminCoords then dispatchCoords = data.adminCoords end

    SendNUIMessage({
        action = "show",
        name = data.name,
        date = data.date,
        time = data.time,
        style = data.style,
        note = data.note
    })
    
    if Config.UseOxTarget then
        exports.ox_target:addGlobalPlayer({
            {
                name = 'event_hud_discord',
                icon = 'fa-brands fa-discord',
                label = Config.Language == "en" and "Open Event Discord" or "Event Discord Link öffnen",
                canInteract = function() return isHUDActive and isHUDVisible and currentDiscordLink ~= "#" end,
                onSelect = function() SendNUIMessage({ action = "openDiscord", url = currentDiscordLink }) end
            },
            {
                name = 'event_hud_toggle',
                icon = 'fa-solid fa-eye-slash',
                label = Config.Language == "en" and "Toggle Event HUD" or "Event-HUD an/ausblenden",
                canInteract = function() return isHUDActive end,
                onSelect = function() ExecuteCommand("eventhud") end
            }
        })
    end
end)

-- START CALLBACK
RegisterNUICallback("triggerStartEventEffects", function(_, cb)
    if isHUDActive then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
        if policeDispatchText and policeDispatchText ~= "" and dispatchCoords then
            TriggerServerEvent("eventhud:server:sendPoliceDispatch", dispatchCoords, policeDispatchText)
        end
    end
    cb("ok")
end)

RegisterNetEvent("eventhud:client:hideEventGlobal", function()
    isHUDActive = false
    isHUDVisible = false
    policeDispatchText = ""
    SendNUIMessage({ action = "hide" })
end)

-- CALLBACKS DURCHFÜHREN
RegisterNUICallback("startEvent", function(data, cb)
    data.adminCoords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("eventhud:server:startEventGlobal", data) 
    cb("ok") 
end)
RegisterNUICallback("stopEvent", function(_, cb) TriggerServerEvent("eventhud:server:stopEventGlobal") cb("ok") end)
RegisterNUICallback("closeMenu", function(_, cb) SetNuiFocus(false, false) cb("ok") end)
RegisterNetEvent("eventhud:client:updatePlayerCount", function(count) if isHUDActive then SendNUIMessage({ action = "updateCount", count = count }) end end)
