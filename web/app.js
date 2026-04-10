// ── Tab switching ─────────────────────────────────────────────
const tabButtons = Array.from(document.querySelectorAll(".dockBtn"));
const tabSections = {
  management: document.getElementById("tab-management"),
  map: document.getElementById("tab-map"),
  insights: document.getElementById("tab-insights"),
  billings: document.getElementById("tab-billings"),
  comms: document.getElementById("tab-comms"),
  security: document.getElementById("tab-security"),
};
const tabTitles = {
  management: "Management",
  map: "Map & Demographics",
  insights: "Insights And Analytics",
  billings: "Billings",
  comms: "Internal Comms",
  security: "Auth & Security",
};
const pageTitleEl = document.getElementById("pageTitle");

function switchTab(tab) {
  for (const [name, section] of Object.entries(tabSections)) {
    section.classList.toggle("active", name === tab);
  }
  tabButtons.forEach((btn) => btn.classList.toggle("active", btn.dataset.tab === tab));
  pageTitleEl.textContent = tabTitles[tab];

  // If map is visible after tab switch, resize map
  if (tab === "map" || tab === "management") {
    tryResizeMapsSoon();
  }
}
tabButtons.forEach((btn) => btn.addEventListener("click", () => switchTab(btn.dataset.tab)));

// ── Windows-style tray clock ──────────────────────────────────
function updateTray() {
  const now = new Date();
  const h = String(now.getHours()).padStart(2, "0");
  const m = String(now.getMinutes()).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");
  const mo = String(now.getMonth() + 1).padStart(2, "0");
  const y = now.getFullYear();
  document.getElementById("trayTime").textContent = h + ":" + m;
  document.getElementById("trayDate").textContent = d + "-" + mo + "-" + y;
  document.getElementById("headerDate").textContent = d + "/" + mo + "/" + y;
}
updateTray();
setInterval(updateTray, 1000);

// ── Management side navigation (Fleet/Patients/Staff/Wards) ──
const mgmtBtns = Array.from(document.querySelectorAll(".mgmtNavBtn"));
const mgmtViews = {
  fleet: document.getElementById("mview-fleet"),
  patients: document.getElementById("mview-patients"),
  staff: document.getElementById("mview-staff"),
  wards: document.getElementById("mview-wards"),
};

function switchMgmtView(name) {
  mgmtBtns.forEach((b) => b.classList.toggle("active", b.dataset.mview === name));
  Object.entries(mgmtViews).forEach(([k, el]) => el && el.classList.toggle("active", k === name));
  // Resize maps when fleet view opens
  if (name === "fleet") tryResizeMapsSoon();
}

mgmtBtns.forEach((b) => b.addEventListener("click", () => switchMgmtView(b.dataset.mview)));

// ── Management tab ────────────────────────────────────────────
let staffCount = 42;
let fleetCount = 10;
let dispatched = 2;
let emergencyCount = 7;
let credCounter = 3;

const staffCountEl   = document.getElementById("staffCount");
const fleetCountEl   = document.getElementById("fleetCount");
const fleetSubEl     = document.getElementById("fleetSub");
const emergencyCountEl = document.getElementById("emergencyCount");

function setBar(id, pct) {
  const el = document.getElementById(id);
  if (el) el.style.width = pct + "%";
}

document.getElementById("addStaffBtn").addEventListener("click", () => {
  staffCount += 1;
  staffCountEl.textContent = String(staffCount);
  setBar("staffBar", Math.min(100, Math.round(staffCount / 58 * 100)));
});
document.getElementById("removeStaffBtn").addEventListener("click", () => {
  if (staffCount > 0) staffCount -= 1;
  staffCountEl.textContent = String(staffCount);
  setBar("staffBar", Math.min(100, Math.round(staffCount / 58 * 100)));
});

document.getElementById("dispatchFleetBtn").addEventListener("click", () => {
  if (fleetCount > 0) { fleetCount -= 1; dispatched += 1; }
  fleetCountEl.textContent = String(fleetCount);
  fleetSubEl.textContent = dispatched + " dispatched · " + (fleetCount + dispatched) + " total";
  setBar("fleetBar", Math.round(fleetCount / (fleetCount + dispatched) * 100));
});
document.getElementById("returnFleetBtn").addEventListener("click", () => {
  if (dispatched > 0) { dispatched -= 1; fleetCount += 1; }
  fleetCountEl.textContent = String(fleetCount);
  fleetSubEl.textContent = dispatched + " dispatched · " + (fleetCount + dispatched) + " total";
  setBar("fleetBar", Math.round(fleetCount / (fleetCount + dispatched) * 100));
});

document.getElementById("addEmergencyBtn").addEventListener("click", () => {
  emergencyCount += 1;
  emergencyCountEl.textContent = String(emergencyCount);
});
document.getElementById("resolveEmergencyBtn").addEventListener("click", () => {
  if (emergencyCount > 0) emergencyCount -= 1;
  emergencyCountEl.textContent = String(emergencyCount);
});

document.getElementById("refreshWardsBtn") && document.getElementById("refreshWardsBtn").addEventListener("click", () => {
  const icu = 8 + Math.floor(Math.random() * 4);
  const er  = 12 + Math.floor(Math.random() * 7);
  document.getElementById("icuText").innerHTML = icu + '<span style="font-size:18px;color:#6a7899">/12</span>';
  document.getElementById("erText").innerHTML  = er  + '<span style="font-size:18px;color:#6a7899">/20</span>';
  setBar("icuBar", Math.round(icu / 12 * 100));
  setBar("erBar",  Math.round(er  / 20 * 100));
});

document.getElementById("genCredBtn").addEventListener("click", () => {
  const nameRaw = document.getElementById("credName").value.trim();
  if (!nameRaw) return;
  credCounter += 1;
  const role  = document.getElementById("credRole").value;
  const alias = nameRaw.toLowerCase().replace(/\s+/g, "");
  const email = role + credCounter + "@goelhospital.com";
  const pass  = "GH@" + (1000 + credCounter);
  document.getElementById("credOut").textContent = email + " | " + pass;
});

// ── Map tab + Patients list (shared) ──────────────────────────
const patientListEl = document.getElementById("patientList");
function addPatientRow(name, zone) {
  const li = document.createElement("li");
  const ts = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  li.textContent = "📍 " + name + " — " + zone + " · " + ts;
  patientListEl.prepend(li);
}
addPatientRow("Anjali Patel", "Ward A");
addPatientRow("Ravi Kumar", "Trauma Desk");

document.getElementById("addPatientBtn").addEventListener("click", () => {
  const name = document.getElementById("patientName").value.trim();
  const zone = document.getElementById("patientZone").value.trim();
  if (!name || !zone) return;
  addPatientRow(name, zone);
  document.getElementById("patientName").value = "";
  document.getElementById("patientZone").value = "";
});

const gemmaHints = [
  "Age 40-60 trend high in central district. Cardiac and trauma cases peak 7 PM–11 PM.",
  "North zone: 28% rise in respiratory cases this week. Recommend ICU alert threshold.",
  "Pediatric admissions +9% vs last week. Ward B occupancy expected to hit 90% by evening.",
  "Fleet utilisation pattern: Ambulance 3 and 5 have highest dispatch frequency — schedule service.",
  "Billing anomaly: 3 bills from Dr. Sharma flagged for review due to missing diagnosis codes.",
];
let gemmaIdx = 0;
document.getElementById("refreshGemmaBtn").addEventListener("click", () => {
  gemmaIdx = (gemmaIdx + 1) % gemmaHints.length;
  document.getElementById("gemmaHint").textContent = gemmaHints[gemmaIdx];
  document.getElementById("gemmaTs").textContent = "Model: Gemma 4 · Updated " + new Date().toLocaleTimeString();
});

// ── Open-source maps (Leaflet + OpenStreetMap) ────────────────
let osmMain;
let osmMgmt;
let osmMarkersMain = [];
let osmMarkersMgmt = [];
const demoMarkers = [
  { type: "fleet", label: "Ambulance 3", lat: 28.6139, lng: 77.2090 },
  { type: "patient", label: "Patient: Anjali P", lat: 28.6109, lng: 77.2140 },
  { type: "patient", label: "Patient: Ravi K", lat: 28.6172, lng: 77.2062 },
  { type: "fleet", label: "Ambulance 1", lat: 28.6097, lng: 77.2051 },
  { type: "patient", label: "Patient: Meera S", lat: 28.6160, lng: 77.2178 },
];

function showMapError(id, msg) {
  const el = document.getElementById(id);
  if (!el) return;
  el.style.display = "flex";
  el.innerHTML =
    "<div><b>Map not loaded</b><br/>" +
    msg +
    "<br/><br/>Common fixes:<br/>" +
    "- Check if your network blocks tile servers<br/>" +
    "- Try again on a different connection<br/>" +
    "- Ensure JavaScript is enabled</div>";
}

function tryResizeMapsSoon() {
  setTimeout(() => {
    try {
      if (osmMain) osmMain.invalidateSize();
      if (osmMgmt) osmMgmt.invalidateSize();
    } catch (_) {}
  }, 250);
}

function clearLeafletMarkers(arr) {
  arr.forEach((m) => m.remove());
  arr.length = 0;
}

function markerColor(type) {
  if (type === "fleet") return "#ff5252";
  if (type === "patient") return "#4da8ff";
  return "#4ddb8e";
}

function addLeafletMarkers(map, arr) {
  clearLeafletMarkers(arr);
  demoMarkers.forEach((p) => {
    const marker = L.circleMarker([p.lat, p.lng], {
      radius: 8,
      color: markerColor(p.type),
      fillColor: markerColor(p.type),
      fillOpacity: 0.9,
      weight: 2,
    }).addTo(map);
    marker.bindPopup("<b>" + p.label + "</b>");
    arr.push(marker);
  });
}

function initLeafletMap(id, errorId) {
  const el = document.getElementById(id);
  if (!el) return null;
  if (!window.L) {
    showMapError(errorId, "Leaflet library failed to load.");
    return null;
  }
  const map = L.map(el, { zoomControl: true }).setView([28.6139, 77.2090], 12);
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: '&copy; <a href=\"https://www.openstreetmap.org/copyright\">OpenStreetMap</a>',
  }).addTo(map);
  return map;
}

function initOpenSourceMaps() {
  osmMain = initLeafletMap("mapMain", "mapError");
  osmMgmt = initLeafletMap("mapMgmt", "mapErrorMgmt");
  if (osmMain) addLeafletMarkers(osmMain, osmMarkersMain);
  if (osmMgmt) addLeafletMarkers(osmMgmt, osmMarkersMgmt);
  tryResizeMapsSoon();
}

// Leaflet loads via script tag; run after DOM is ready
window.addEventListener("load", () => {
  initOpenSourceMaps();
});

// ── Insights tab – Gemma 4 via Gemini API ────────────────────
let geminiApiKey = "";

document.getElementById("saveKeyBtn").addEventListener("click", () => {
  const k = document.getElementById("gemmaApiKey").value.trim();
  if (k) { geminiApiKey = k; addChat("System", "Gemini API key saved. Gemma 4 is now active."); }
});

const chatListEl  = document.getElementById("chatList");

function addChat(role, text) {
  const li = document.createElement("li");
  li.className = role === "You" ? "user" : role === "thinking" ? "agent thinking" : "agent";
  li.textContent = (role === "thinking" ? "" : role + ": ") + text;
  chatListEl.appendChild(li);
  document.getElementById("chatLog").scrollTop = 99999;
}

addChat("Gemma 4", "Ready. Ask me about ICU trends, billing anomalies, fleet efficiency, or patient demographics.");

async function askGemma4(prompt) {
  const systemCtx =
    "You are Gemma 4, an AI analytics agent for Goel Hospital emergency operations admin panel. " +
    "Answer concisely with data-driven insights. Current stats: ICU 9/12, ER 14/20, Fleet 10/12 active, " +
    "7 emergencies in queue, avg response time 8 min. Today is " + new Date().toDateString() + ".";

  if (!geminiApiKey) {
    return "No Gemini API key set. Add your key in the field above to enable live Gemma 4 responses.";
  }

  const body = {
    contents: [
      { role: "user", parts: [{ text: systemCtx + "\n\nUser question: " + prompt }] }
    ],
    generationConfig: { maxOutputTokens: 300, temperature: 0.4 }
  };

  const res = await fetch(
    "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent?key=" + geminiApiKey,
    { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) }
  );

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    return "API error " + res.status + ": " + (err?.error?.message || "Unknown error.");
  }

  const data = await res.json();
  return data?.candidates?.[0]?.content?.parts?.[0]?.text || "No response from model.";
}

document.getElementById("sendChatBtn").addEventListener("click", async () => {
  const inputEl = document.getElementById("chatInput");
  const text    = inputEl.value.trim();
  if (!text) return;
  inputEl.value = "";
  addChat("You", text);
  const thinkId = Date.now();
  addChat("thinking", "Gemma 4 is thinking…");
  const reply = await askGemma4(text);
  const tEl = chatListEl.querySelector(".thinking");
  if (tEl) tEl.remove();
  addChat("Gemma 4", reply);
});

// ── Billings tab ──────────────────────────────────────────────
let billId = 90;
let currentBill = "";
let financeOk = false;
const billLogsEl = document.getElementById("billLogs");
function addBillLog(text) {
  const li = document.createElement("li");
  li.textContent = "[" + new Date().toLocaleTimeString() + "] " + text;
  billLogsEl.prepend(li);
}

document.getElementById("createBillBtn").addEventListener("click", () => {
  const patient   = document.getElementById("billPatient").value.trim();
  const diagnosis = document.getElementById("billDiagnosis").value.trim();
  const amount    = document.getElementById("billAmount").value.trim();
  if (!patient || !amount) return;
  billId += 1;
  currentBill = "BL-2026-" + String(billId).padStart(4, "0");
  financeOk = false;
  document.getElementById("billIdOut").textContent = currentBill + " · " + patient + " · INR " + amount;
  document.getElementById("billQr").textContent = "QR: [ " + currentBill + " | " + patient + " | " + amount + " ]";
  document.getElementById("approvalStatus").textContent = "Pending Finance";
  document.getElementById("finBadge").style.background = "";
  document.getElementById("adminBadge").style.background = "";
  addBillLog("Created " + currentBill + " for " + patient + " (" + diagnosis + ") INR " + amount);
  const c = Number(document.getElementById("pendingApprovalCount").textContent);
  document.getElementById("pendingApprovalCount").textContent = String(c + 1);
});

document.getElementById("financeApproveBtn").addEventListener("click", () => {
  if (!currentBill) return;
  financeOk = true;
  document.getElementById("approvalStatus").textContent = "Finance Approved · Awaiting Admin";
  document.getElementById("finBadge").style.background = "#1e5c3a";
  addBillLog("Finance approved " + currentBill);
});

document.getElementById("adminApproveBtn").addEventListener("click", () => {
  if (!currentBill || !financeOk) { alert("Finance must approve first."); return; }
  document.getElementById("approvalStatus").textContent = "Fully Cleared";
  document.getElementById("adminBadge").style.background = "#1e5c3a";
  addBillLog("Admin finalised " + currentBill + " — cleared");
  const c = Number(document.getElementById("pendingApprovalCount").textContent);
  if (c > 0) document.getElementById("pendingApprovalCount").textContent = String(c - 1);
});

// ── Internal Comms ────────────────────────────────────────────
let activeChannel = "#alerts";
let dutyOn = true;
const commsFeedEl = document.getElementById("commsFeed");

function addComms(text) {
  const li = document.createElement("li");
  const ts = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  li.textContent = "[" + ts + "] " + text;
  commsFeedEl.prepend(li);
}

addComms("#alerts | System: Shift handover at 7 PM. All ward leads to confirm.");
addComms("#ems-handshake | Ops: Ambulance 3 EMS sync complete.");

document.querySelectorAll(".channelItem").forEach((btn) => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".channelItem").forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    activeChannel = btn.dataset.channel;
    const inp = document.getElementById("commsInput");
    if (inp) inp.placeholder = "Message " + activeChannel + "…";
  });
});

document.getElementById("toggleDutyBtn").addEventListener("click", () => {
  dutyOn = !dutyOn;
  const badge = document.getElementById("dutyBadge");
  badge.textContent = dutyOn ? "On Duty" : "Off Duty";
  badge.className = "badge " + (dutyOn ? "green" : "red");
  const role = document.getElementById("commsRole").value;
  addComms(activeChannel + " | " + role + ": duty → " + (dutyOn ? "ON" : "OFF"));
  const c = Number(document.getElementById("onDutyCount").textContent);
  document.getElementById("onDutyCount").textContent = String(dutyOn ? c + 1 : Math.max(0, c - 1));
});

document.getElementById("sendCommsBtn").addEventListener("click", () => {
  const input = document.getElementById("commsInput");
  const text  = input.value.trim();
  if (!text) return;
  const role = document.getElementById("commsRole").value;
  addComms(activeChannel + " | " + role + ": " + text);
  input.value = "";
});

// ── Auth & Security ───────────────────────────────────────────
const auditLogsEl = document.getElementById("auditLogs");
function addAudit(text) {
  const li = document.createElement("li");
  li.textContent = "[" + new Date().toLocaleTimeString() + "] " + text;
  auditLogsEl.prepend(li);
}
addAudit("System: Auth monitor started. All policies active.");

document.getElementById("loginBtn").addEventListener("click", () => {
  const email = document.getElementById("loginEmail").value.trim();
  const pass  = document.getElementById("loginPassword").value;
  const msgEl = document.getElementById("loginMsg");
  if (email === "doctor3@goelhospital.com" && pass === "GH@1004") {
    msgEl.textContent = "✓ Logged in as doctor3 (Doctor role)";
    msgEl.style.color = "#4ddb8e";
    addAudit("Login success: " + email);
  } else if (!email || !pass) {
    msgEl.textContent = "Please enter email and password.";
    msgEl.style.color = "#ff8a8a";
  } else {
    msgEl.textContent = "✗ Invalid credentials.";
    msgEl.style.color = "#ff8a8a";
    addAudit("Failed login: " + (email || "empty"));
  }
});
