Config = {}

-- 🌐 SPRACHEINSTELLUNG / LANGUAGE SETTING
Config.Language = "de" -- 'de' für Deutsch / 'en' for English

-- 🌌 DIMENSIONS-EINSTELLUNG
Config.EventDimension = 1 -- Trag hier die ID deiner Event-Dimension ein!

-- 🛠️ STRATEGIE-SCHALTER
Config.UseOxTarget = true -- true = Spieler können den Link via ox_target anklicken | false = Kein ox_target
Config.ShowNotes   = true -- true = Globale Notizen im HUD anzeigen | false = Notizen im HUD komplett verbieten

-- 🎨 HUD DESIGN EINSTELLUNGEN
Config.HUD = {
    TextFarbe = "#ffffff",         -- Haupt-Textfarbe
    
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
        menuTitle = "Event Management",
        labelName = "Event Name:",
        labelDate = "Datum auswählen:",
        labelTime = "Uhrzeit:",
        labelDiscord = "Discord Link:",
        labelNote = "Globale Notiz für alle Spieler (optional):",
        labelDispatch = "Dispatch Notiz für die Polizei (optional):",
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
        menuTitle = "Event Management",
        labelName = "Event Name:",
        labelDate = "Select Date:",
        labelTime = "Time:",
        labelDiscord = "Discord Link:",
        labelNote = "Global Note for all players (optional):",
        labelDispatch = "Dispatch Note for police (optional):",
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
