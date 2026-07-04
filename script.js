let countdownInterval = null;
let eventActive = false; // Speichert den aktuellen Status des Events
let isButtonCooldown = false; // ⏳ NEU: Verhindert Button-Spam

let textLib = {
    startIn: "Startet in: ",
    activeSince: "🔴 Aktiv seit: ",
    loading: "Lädt Countdown...",
    hours: "h", minutes: "m", seconds: "s", days: "d",
    btnStart: "Ankündigung einblenden",
    btnStop: "Ankündigung ausblenden"
}; 
let allowNotes = true;
let effectsTriggered = false;

window.addEventListener("message", function(event) {
    const hud = document.getElementById("eventInfo");
    const admin = document.getElementById("adminMenu");
    
    if (event.data.action === "openAdmin") { 
        admin.style.display = "block"; 
    }

    if (event.data.action === "loadConfig") {
        const cfg = event.data.config;
        if (event.data.lang) textLib = event.data.lang;
        allowNotes = event.data.showNotes;

        for (let key in textLib) {
            let el = document.getElementById("title_" + key);
            if (el) el.innerText = textLib[key];
        }
        document.getElementById("header").innerText = textLib.hudHeader || "📢 EVENT ANKÜNDIGUNG";
        document.getElementById("countdown").innerText = textLib.loading;

        hud.style.top = cfg.AbstandOben;
        hud.style.left = cfg.AbstandLinks;
        hud.style.color = cfg.TextFarbe;
        document.getElementById("name").style.fontSize = cfg.SchriftgroesseName;
        document.getElementById("countdown").style.fontSize = cfg.SchriftgroesseCountdown;
        document.getElementById("note").style.fontSize = cfg.SchriftgroesseNotiz;
        
        document.documentElement.style.setProperty('--dynamic-hud-color', '#ff8c00'); 
        updateToggleButton();
    }

    if (event.data.action === "updateCount") {
        document.getElementById("playerCount").innerText = `👥 Teilnehmer: ${event.data.count}`;
    }

    if (event.data.action === "show") {
        eventActive = true;
        updateToggleButton();

        if (countdownInterval) clearInterval(countdownInterval);
        effectsTriggered = false; 

        const rawDate = event.data.date; 
        const rawTime = event.data.time; 

        // 🛠️ Formatiert YYYY-MM-DD sauber zu DD.MM.YYYY
        if (rawDate && rawDate.includes("-")) {
            const parts = rawDate.split("-");
            document.getElementById("date").innerText = `${parts[2]}.${parts[1]}.${parts[0]}`;
        } else {
            document.getElementById("date").innerText = rawDate;
        }
        
        document.getElementById("time").innerText = rawTime + " Uhr";
        document.getElementById("name").innerText = event.data.name;
        
        const noteElement = document.getElementById("note");
        if (allowNotes && event.data.note && event.data.note.trim() !== "") {
            noteElement.innerText = "ℹ️ " + event.data.note;
            noteElement.style.display = "block";
        } else {
            noteElement.style.display = "none";
        }

        hud.className = "design-hud"; 
        hud.style.display = "block";

        const targetDateTime = new Date(`${rawDate}T${rawTime}:00`);

        countdownInterval = setInterval(function() {
            const now = new Date().getTime();
            const distance = targetDateTime.getTime() - now;

            if (distance > 0) {
                const days = Math.floor(distance / (1000 * 60 * 60 * 24));
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);

                let timerString = textLib.startIn;
                if (days > 0) timerString += `${days}${textLib.days} `;
                timerString += `${hours.toString().padStart(2, '0')}${textLib.hours} ${minutes.toString().padStart(2, '0')}${textLib.minutes} ${seconds.toString().padStart(2, '0')}${textLib.seconds}`;
                document.getElementById("countdown").innerText = timerString;
            } else {
                if (!effectsTriggered) {
                    effectsTriggered = true;
                    fetch(`https://${GetParentResourceName()}/triggerStartEventEffects`, { method: 'POST' });
                }

                const elapsed = now - targetDateTime.getTime();
                const eHours = Math.floor(elapsed / (1000 * 60 * 60));
                const eMinutes = Math.floor((elapsed % (1000 * 60 * 60)) / (1000 * 60));
                document.getElementById("countdown").innerText = `${textLib.activeSince}${eHours}${textLib.hours} ${eMinutes}${textLib.minutes}`;
            }
        }, 1000);
    }

    if (event.data.action === "forceShow") { hud.style.display = "block"; }
    if (event.data.action === "hide") { 
        hud.style.display = "none"; 
        if (countdownInterval) clearInterval(countdownInterval); 
        eventActive = false;
        updateToggleButton();
    }
    if (event.data.action === "openDiscord" && event.data.url !== "#") { window.open(event.data.url, '_blank'); }
});

// Funktion steuert das Aussehen des Toggle-Buttons
function updateToggleButton() {
    const btn = document.getElementById("btnToggle");
    if (!btn || isButtonCooldown) return; // ⏳ Verhindert visuelle Updates während des Cooldowns

    if (eventActive) {
        btn.innerText = textLib.btnStop || "Ankündigung ausblenden";
        btn.className = "action-btn toggle-btn stop-btn";
        btn.disabled = false;
    } else {
        btn.innerText = textLib.btnStart || "Ankündigung einblenden";
        btn.className = "action-btn toggle-btn start-btn";
        btn.disabled = false;
    }
}

// 🔄 NEU: Funktion für die Cooldown-Logik
function startButtonCooldown() {
    isButtonCooldown = true;
    const btn = document.getElementById("btnToggle");
    let timeLeft = 3; // ⏳ Cooldown Zeit in Sekunden

    btn.disabled = true;
    btn.style.opacity = "0.6";
    btn.style.cursor = "not-allowed";
    btn.innerText = `Bitte warten... (${timeLeft}s)`;

    const cooldownInterval = setInterval(() => {
        timeLeft--;
        if (timeLeft <= 0) {
            clearInterval(cooldownInterval);
            isButtonCooldown = false;
            btn.disabled = false;
            btn.style.opacity = "1";
            btn.style.cursor = "pointer";
            updateToggleButton(); // Setzt das korrekte Design wieder ein
        } else {
            btn.innerText = `Bitte warten... (${timeLeft}s)`;
        }
    }, 1000);
}

// Entscheidet ob das Event gestartet oder gestoppt werden soll
function toggleEventState() {
    if (isButtonCooldown) return; // ⏳ Klick-Blockierung bei Spam

    startButtonCooldown(); // Aktiviert den Cooldown für 3 Sekunden

    if (eventActive) {
        fetch(`https://${GetParentResourceName()}/stopEvent`, { method: 'POST' });
    } else {
        const payload = {
            name: document.getElementById("inputName").value,
            date: document.getElementById("inputDate").value,
            time: document.getElementById("inputTime").value,
            discord: document.getElementById("inputDiscord").value,
            style: "hud", 
            note: document.getElementById("inputNote").value,
            dispatch: document.getElementById("inputDispatch").value
        };
        fetch(`https://${GetParentResourceName()}/startEvent`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
    }
}

function closeAdminMenu() { fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' }); document.getElementById("adminMenu").style.display = "none"; }
document.addEventListener("keydown", function(e) { if (e.key === "Escape") { closeAdminMenu(); } });
