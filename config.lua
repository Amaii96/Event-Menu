Config = {}

-- 🌐 SPRACHEINSTELLUNG / LANGUAGE SETTING
Config.Language = "de" -- 'de' für Deutsch / 'en' for English

-- 🛠️ STRATEGIE-SCHALTER
Config.UseOxTarget = false -- true = Spieler können den Link via ox_target anklicken | false = Kein ox_target
Config.ShowNotes   = true -- true = Globale Notizen im HUD anzeigen | false = Notizen im HUD komplett verbieten

-- 🚀 EVENT BEITRITTS-EINSTELLUNGEN
Config.NotifyScript = "ox_lib"   -- "ox_lib", "esx", "qb" oder "chat" für die Benachrichtigungen

-- Hier kannst du die Befehle umbenennen, falls ein anderes Script die alten Namen blockiert:
Config.JoinCommand  = "eventjoin"   -- Ändern, wenn ein seperates Script verwendet wird. Wird auch zur Analyse für Teilnehmer Anzahl verwendet.
Config.LeaveCommand = "eventleave"  -- Ändern, wenn ein seperates Script verwendet wird. Wird auch zur Analyse für Teilnehmer Anzahl verwendet.

-- 🎨 HUD DESIGN EINSTELLUNGEN
Config.HUD = {
    HauptFarbe = "#ff8c00",         -- Die Hauptfarbe für Ränder, Teilnehmer und Buttons
    TextFarbe = "#ffffff",          -- Haupt-Textfarbe
    
    -- Schriftgrößen / Font Sizes
    SchriftgroesseName = "20px",
    SchriftgroesseCountdown = "13px",
    SchriftgroesseNotiz = "12px",
    
    -- Abstände zum Bildschirmrand
    AbstandOben = "30px",
    AbstandLinks = "30px"
}

-- 📝 LOKALISIERUNG / TRANSLATIONS
Config.Translations = {
    ["de"] = {
        menuTitle = "Event Ankündigung",
        labelName = "Event Name:",
        labelDate = "Datum:",
        labelTime = "Uhrzeit:",
        labelDiscord = "Discord Nachrichten-Link (wenn Third-Eye aktiv zum anklicken für mehr infos):",
        labelNote = "Globale Info (optional):",
        labelDispatch = "Dispatch Notiz (optional):",
        btnStart = "Ankündigung einblenden",
        btnStop = "Ankündigung ausblenden",
        btnClose = "Menü schließen",
        hudHeader = "📢 EVENT ANKÜNDIGUNG",
        startIn = "Startet in: ",
        activeSince = "🔴 Aktiv seit: ",
        loading = "Lädt Countdown...",
        hours = "h", minutes = "m", seconds = "s", days = "d"
    },
    ["en"] = {
        menuTitle = "Event Announcement",
        labelName = "Event Name:",
        labelDate = "Date:",
        labelTime = "Time:",
        labelDiscord = "Discord Message-Link:",
        labelNote = "Global Info(optional):",
        labelDispatch = "Dispatch Note (optional):",
        btnStart = "Show Announcement",
        btnStop = "Hide Announcement",
        btnClose = "Close Menu",
        hudHeader = "📢 EVENT ANNOUNCEMENT",
        startIn = "Starts in: ",
        activeSince = "🔴 Active since: ",
        loading = "Loading Countdown...",
        hours = "h", minutes = "m", seconds = "s", days = "d"
    }
}
