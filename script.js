let countdownInterval = null;
let textLib = {
    startIn: "Startet in: ",
    activeSince: "🔴 Aktiv seit: ",
    loading: "Lädt Countdown...",
    hours: "h", minutes: "m", seconds: "s", days: "d"
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
    }

    if (event.data.action === "updateCount") {
        document.getElementById("playerCount").innerText = `👥 Teilnehmer: ${event.data.count}`;
    }

    if (event.data.action === "show") {
        if (countdownInterval) clearInterval(countdownInterval);
        effectsTriggered = false; 

        const rawDate = event.data.date; 
        const rawTime = event.data.time; 

        if (rawDate && rawDate.includes("-")) {
            const parts = rawDate.split("-");
            document.getElementById("date").innerText = `${parts}.${parts}.${parts}`;
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
    if (event.data.action === "hide") { hud.style.display = "none"; if (countdownInterval) clearInterval(countdownInterval); }
    if (event.data.action === "openDiscord" && event.data.url !== "#") { window.open(event.data.url, '_blank'); }
});

function submitEvent() {
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
function stopEvent() { fetch(`https://${GetParentResourceName()}/stopEvent`, { method: 'POST' }); }
function closeAdminMenu() { fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' }); document.getElementById("adminMenu").style.display = "none"; }
document.addEventListener("keydown", function(e) { if (e.key === "Escape") { closeAdminMenu(); } });
