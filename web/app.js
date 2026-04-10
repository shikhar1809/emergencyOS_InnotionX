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

// ── Demo dataset (so analytics/Gemma has context) ──────────────
const demoState = {
  wards: {
    ICU: { used: 9, total: 12 },
    ER: { used: 14, total: 20 },
    General: { used: 38, total: 60 },
  },
  fleet: [
    { id: "EMS-LKO-18", status: "standby", lat: 26.8467, lng: 80.9462 },
    { id: "EMS-LKO-09", status: "dispatched", lat: 26.8585, lng: 80.9605 },
    { id: "EMS-LKO-03", status: "available", lat: 26.8382, lng: 80.9341 },
    { id: "EMS-LKO-12", status: "service", lat: 26.8721, lng: 80.9414 },
  ],
  patients: [
    { name: "Anjali Patel", zone: "Ward A", severity: "stable", age: 44, lat: 26.8460, lng: 80.9490 },
    { name: "Ravi Kumar", zone: "Trauma Desk", severity: "critical", age: 52, lat: 26.8526, lng: 80.9412 },
    { name: "Meera Singh", zone: "Ward C", severity: "stable", age: 38, lat: 26.8397, lng: 80.9542 },
    { name: "Sanjay Verma", zone: "ER Bay 2", severity: "critical", age: 61, lat: 26.8602, lng: 80.9521 },
  ],
  billings: [
    { id: "BL-2026-0090", patient: "Anjali Patel", amount: 12500, status: "cleared" },
    { id: "BL-2026-0091", patient: "Ravi Kumar", amount: 35600, status: "pending_finance" },
    { id: "BL-2026-0092", patient: "Meera Singh", amount: 8900, status: "pending_admin" },
  ],
  comms: {
    alerts: 6,
    shifts: 4,
    handshake: 2,
  },
};

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

const addStaffBtn = document.getElementById("addStaffBtn");
addStaffBtn && addStaffBtn.addEventListener("click", () => {
  staffCount += 1;
  staffCountEl && (staffCountEl.textContent = String(staffCount));
  setBar("staffBar", Math.min(100, Math.round(staffCount / 58 * 100)));
});
const removeStaffBtn = document.getElementById("removeStaffBtn");
removeStaffBtn && removeStaffBtn.addEventListener("click", () => {
  if (staffCount > 0) staffCount -= 1;
  staffCountEl && (staffCountEl.textContent = String(staffCount));
  setBar("staffBar", Math.min(100, Math.round(staffCount / 58 * 100)));
});

const dispatchFleetBtn = document.getElementById("dispatchFleetBtn");
dispatchFleetBtn && dispatchFleetBtn.addEventListener("click", () => {
  if (fleetCount > 0) { fleetCount -= 1; dispatched += 1; }
  fleetCountEl && (fleetCountEl.textContent = String(fleetCount));
  fleetSubEl && (fleetSubEl.textContent = dispatched + " dispatched · " + (fleetCount + dispatched) + " total");
  setBar("fleetBar", Math.round(fleetCount / (fleetCount + dispatched) * 100));
});
const returnFleetBtn = document.getElementById("returnFleetBtn");
returnFleetBtn && returnFleetBtn.addEventListener("click", () => {
  if (dispatched > 0) { dispatched -= 1; fleetCount += 1; }
  fleetCountEl && (fleetCountEl.textContent = String(fleetCount));
  fleetSubEl && (fleetSubEl.textContent = dispatched + " dispatched · " + (fleetCount + dispatched) + " total");
  setBar("fleetBar", Math.round(fleetCount / (fleetCount + dispatched) * 100));
});

// (buttons may not exist in current layout; keep safe)
const addEmergencyBtn = document.getElementById("addEmergencyBtn");
addEmergencyBtn && addEmergencyBtn.addEventListener("click", () => {
  emergencyCount += 1;
  emergencyCountEl && (emergencyCountEl.textContent = String(emergencyCount));
});
const resolveEmergencyBtn = document.getElementById("resolveEmergencyBtn");
resolveEmergencyBtn && resolveEmergencyBtn.addEventListener("click", () => {
  if (emergencyCount > 0) emergencyCount -= 1;
  emergencyCountEl && (emergencyCountEl.textContent = String(emergencyCount));
});

document.getElementById("refreshWardsBtn") && document.getElementById("refreshWardsBtn").addEventListener("click", () => {
  const icu = 8 + Math.floor(Math.random() * 4);
  const er  = 12 + Math.floor(Math.random() * 7);
  document.getElementById("icuText").innerHTML = icu + '<span style="font-size:18px;color:#6a7899">/12</span>';
  document.getElementById("erText").innerHTML  = er  + '<span style="font-size:18px;color:#6a7899">/20</span>';
  setBar("icuBar", Math.round(icu / 12 * 100));
  setBar("erBar",  Math.round(er  / 20 * 100));
});

const genCredBtn = document.getElementById("genCredBtn");
genCredBtn && genCredBtn.addEventListener("click", () => {
  const nameRaw = document.getElementById("credName").value.trim();
  if (!nameRaw) return;
  credCounter += 1;
  const role  = document.getElementById("credRole").value;
  const alias = nameRaw.toLowerCase().replace(/\s+/g, "");
  const email = role + credCounter + "@goelhospital.com";
  const pass  = "GH@" + (1000 + credCounter);
  document.getElementById("credOut").textContent = email + " | " + pass;
});

// ── Patients lists (Management + Map tab) ─────────────────────
const mgmtPatientListEl = document.getElementById("mgmtPatientList");
const mapPatientListEl = document.getElementById("mapPatientList");

function addPatientRow(targetListEl, name, zone) {
  const li = document.createElement("li");
  const ts = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  li.textContent = "📍 " + name + " — " + zone + " · " + ts;
  targetListEl && targetListEl.prepend(li);
}
demoState.patients.forEach((p) => {
  addPatientRow(mgmtPatientListEl, p.name, p.zone);
  addPatientRow(mapPatientListEl, p.name, p.zone);
});

const mgmtAddPatientBtn = document.getElementById("mgmtAddPatientBtn");
mgmtAddPatientBtn && mgmtAddPatientBtn.addEventListener("click", () => {
  const name = document.getElementById("mgmtPatientName").value.trim();
  const zone = document.getElementById("mgmtPatientZone").value.trim();
  if (!name || !zone) return;
  addPatientRow(mgmtPatientListEl, name, zone);
  document.getElementById("mgmtPatientName").value = "";
  document.getElementById("mgmtPatientZone").value = "";
});

const mapAddPatientBtn = document.getElementById("mapAddPatientBtn");
mapAddPatientBtn && mapAddPatientBtn.addEventListener("click", () => {
  const name = document.getElementById("mapPatientName").value.trim();
  const zone = document.getElementById("mapPatientZone").value.trim();
  if (!name || !zone) return;
  addPatientRow(mapPatientListEl, name, zone);
  document.getElementById("mapPatientName").value = "";
  document.getElementById("mapPatientZone").value = "";
});

const gemmaHints = [
  "Age 40-60 trend high in central district. Cardiac and trauma cases peak 7 PM–11 PM.",
  "North zone: 28% rise in respiratory cases this week. Recommend ICU alert threshold.",
  "Pediatric admissions +9% vs last week. Ward B occupancy expected to hit 90% by evening.",
  "Fleet utilisation pattern: Ambulance 3 and 5 have highest dispatch frequency — schedule service.",
  "Billing anomaly: 3 bills from Dr. Sharma flagged for review due to missing diagnosis codes.",
];
let gemmaIdx = 0;
function applyGemmaHint(hint, hintId, tsId) {
  const hintEl = document.getElementById(hintId);
  const tsEl = document.getElementById(tsId);
  if (hintEl) hintEl.textContent = hint;
  if (tsEl) tsEl.textContent = "Model: Gemma 4 · Updated " + new Date().toLocaleTimeString();
}

const mgmtRefreshGemmaBtn = document.getElementById("mgmtRefreshGemmaBtn");
mgmtRefreshGemmaBtn && mgmtRefreshGemmaBtn.addEventListener("click", () => {
  gemmaIdx = (gemmaIdx + 1) % gemmaHints.length;
  applyGemmaHint(gemmaHints[gemmaIdx], "mgmtGemmaHint", "mgmtGemmaTs");
});

const mapRefreshGemmaBtn = document.getElementById("mapRefreshGemmaBtn");
mapRefreshGemmaBtn && mapRefreshGemmaBtn.addEventListener("click", () => {
  gemmaIdx = (gemmaIdx + 1) % gemmaHints.length;
  applyGemmaHint(gemmaHints[gemmaIdx], "mapGemmaHint", "mapGemmaTs");
});

// ── Open-source maps (Leaflet + OpenStreetMap) ────────────────
let osmMain;
let osmMgmt;
let osmMarkersMain = [];
let osmMarkersMgmt = [];
const demoMarkers = [
  ...demoState.fleet.map((f) => ({ type: "fleet", label: f.id + " (" + f.status + ")", lat: f.lat, lng: f.lng })),
  ...demoState.patients.map((p) => ({ type: "patient", label: "Patient: " + p.name + " (" + p.severity + ")", lat: p.lat, lng: p.lng })),
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
  // Lucknow-ish center (matches your reference screenshot)
  const map = L.map(el, { zoomControl: true }).setView([26.8467, 80.9462], 12);
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

const saveKeyBtn = document.getElementById("saveKeyBtn");
saveKeyBtn && saveKeyBtn.addEventListener("click", () => {
  const keyEl = document.getElementById("gemmaApiKey");
  const k = (keyEl ? keyEl.value : "").trim();
  if (k) {
    geminiApiKey = k;
    addChat("System", "Gemini API key saved. Gemma 4 is now active.");
  } else {
    addChat("System", "Please paste your Gemini API key first.");
  }
});

const chatListEl  = document.getElementById("chatList");

function addChat(role, text) {
  const li = document.createElement("li");
  li.className = role === "You" ? "user" : role === "thinking" ? "agent thinking" : "agent";
  li.textContent = (role === "thinking" ? "" : role + ": ") + text;
  chatListEl.appendChild(li);
  document.getElementById("chatLog").scrollTop = 99999;
}

if (chatListEl) {
  addChat("Gemma 4", "Ready. Ask me about ICU trends, billing anomalies, fleet efficiency, or patient demographics.");
}

async function askGemma4(prompt) {
  // Compact snapshot so the model can do better answers
  const snapshot = {
    wards: demoState.wards,
    fleet: demoState.fleet,
    patients: demoState.patients,
    billings: demoState.billings,
    comms: demoState.comms,
  };
  const systemCtx =
    "You are Gemma 4, an AI analytics agent for Goel Hospital emergency operations admin panel. " +
    "Answer concisely with data-driven insights. Today is " + new Date().toDateString() + ". " +
    "Here is the current admin panel snapshot JSON:\n" + JSON.stringify(snapshot);

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

const sendChatBtn = document.getElementById("sendChatBtn");
const chatInputEl = document.getElementById("chatInput");

async function runGemmaChat() {
  if (!chatListEl) {
    alert("Chat UI not found (chatList missing).");
    return;
  }
  const text = (chatInputEl ? chatInputEl.value : "").trim();
  if (!text) {
    addChat("System", "Type a question first.");
    return;
  }
  if (chatInputEl) chatInputEl.value = "";

  addChat("You", text);
  addChat("thinking", "Gemma 4 is thinking…");

  let reply = "";
  try {
    reply = await askGemma4(text);
  } catch (e) {
    reply = "Client error: " + (e && e.message ? e.message : String(e));
  }

  // remove latest thinking row (if present)
  const thinkingEls = chatListEl.querySelectorAll(".thinking");
  const lastThinking = thinkingEls.length ? thinkingEls[thinkingEls.length - 1] : null;
  if (lastThinking) lastThinking.remove();

  addChat("Gemma 4", reply);
}

sendChatBtn && sendChatBtn.addEventListener("click", runGemmaChat);
chatInputEl && chatInputEl.addEventListener("keydown", (e) => {
  if (e.key === "Enter") runGemmaChat();
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
let commsActiveChannel = "announcements";
let dutyOn = true;

const commsFeedEl = document.getElementById("commsFeed");
const commsInputEl = document.getElementById("commsInput");
const commsChannelTitleEl = document.getElementById("commsChannelTitle");
const commsChannelDescEl = document.getElementById("commsChannelDesc");
const commsMemberCountEl = document.getElementById("commsMemberCount");
const commsRosterGroupsEl = document.getElementById("commsRosterGroups");

const commsChannelMeta = {
  announcements: { title: "# announcements", desc: "Broadcast updates and critical notices." },
  alerts: { title: "# alerts", desc: "High-priority operational alerts and hazard notices." },
  "shift-updates": { title: "# shift-updates", desc: "Shift handovers, staffing changes, quick coordination." },
  "ems-handshake": { title: "# ems-handshake", desc: "Coordination with incoming EMS units." },
  admin: { title: "# admin", desc: "Admin-only operations coordination and approvals." },
};

// Firebase init (used by Internal Comms + Presence)
let commsDb = null;
function initCommsFirebaseIfPossible() {
  try {
    if (!window.firebase || !window.__FIREBASE_CONFIG__) return null;
    if (!firebase.apps.length) firebase.initializeApp(window.__FIREBASE_CONFIG__);
    return firebase.firestore();
  } catch (_) {
    return null;
  }
}
commsDb = initCommsFirebaseIfPossible();

function formatTime(ts) {
  try {
    const d = ts?.toDate ? ts.toDate() : ts ? new Date(ts) : new Date();
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch (_) {
    return "";
  }
}

function formatLastSeen(ts) {
  if (!ts) return "";
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  const diffMs = Date.now() - d.getTime();
  const mins = Math.max(0, Math.round(diffMs / 60000));
  if (mins < 1) return "just now";
  if (mins < 60) return mins + "m ago";
  const hrs = Math.round(mins / 60);
  if (hrs < 24) return hrs + "h ago";
  const days = Math.round(hrs / 24);
  return days + "d ago";
}

function isHazardMessage(msg) {
  return msg?.role === "HAZARD ALERT" || (msg?.text && String(msg.text).startsWith("🚨"));
}

function renderCommsMessages(msgs) {
  if (!commsFeedEl) return;
  commsFeedEl.innerHTML = "";
  if (!Array.isArray(msgs) || msgs.length === 0) {
    const li = document.createElement("li");
    li.className = "muted";
    li.textContent = "No messages yet in #" + commsActiveChannel + ".";
    commsFeedEl.appendChild(li);
    return;
  }

  let prevSenderUid = null;
  msgs.forEach((msg) => {
    const li = document.createElement("li");
    const showHeader = msg.senderUid !== prevSenderUid;
    prevSenderUid = msg.senderUid;

    if (!showHeader) {
      // Compact continuation message.
      const cont = document.createElement("div");
      cont.style.marginLeft = "44px";
      const text = document.createElement("div");
      text.className = "commsMsgText" + (isHazardMessage(msg) ? " hazard" : "");
      text.textContent = msg.text || "";
      cont.appendChild(text);
      li.appendChild(cont);
      commsFeedEl.appendChild(li);
      return;
    }

    const group = document.createElement("div");
    group.className = "commsMsgGroup";

    const avatar = document.createElement("div");
    avatar.className = "commsAvatar";
    const initial = (msg.senderName || "S").trim().slice(0, 1).toUpperCase();
    avatar.textContent = initial || "S";

    const body = document.createElement("div");

    const meta = document.createElement("div");
    meta.className = "commsMsgMeta";

    const sender = document.createElement("div");
    sender.className = "commsMsgSender";
    sender.textContent = msg.senderName || "System";

    const role = document.createElement("div");
    role.className = "commsMsgRole";
    role.textContent = msg.role || "";

    const time = document.createElement("div");
    time.className = "commsMsgTime";
    time.textContent = formatTime(msg.timestamp);

    meta.appendChild(sender);
    if (role.textContent) meta.appendChild(role);
    meta.appendChild(time);

    const text = document.createElement("div");
    text.className = "commsMsgText" + (isHazardMessage(msg) ? " hazard" : "");
    text.textContent = msg.text || "";

    body.appendChild(meta);
    body.appendChild(text);

    group.appendChild(avatar);
    group.appendChild(body);
    li.appendChild(group);
    commsFeedEl.appendChild(li);
  });

  // Scroll to bottom (latest)
  const feedScroll = commsFeedEl.closest(".feedScroll");
  if (feedScroll) feedScroll.scrollTop = feedScroll.scrollHeight;
}

let commsUnsubMessages = null;
function subscribeCommsChannel(channelId) {
  commsActiveChannel = channelId;

  const meta = commsChannelMeta[channelId] || { title: "# " + channelId, desc: "" };
  if (commsChannelTitleEl) commsChannelTitleEl.textContent = meta.title;
  if (commsChannelDescEl) commsChannelDescEl.textContent = meta.desc;
  if (commsInputEl) commsInputEl.placeholder = "Message #" + channelId + "…";

  if (!commsDb) {
    renderCommsMessages([
      {
        senderUid: "system",
        senderName: "System",
        role: "Offline",
        text:
          "Firebase is not configured for this build yet. Add your Firebase Web config in window.__FIREBASE_CONFIG__ to enable live comms + presence.",
        timestamp: new Date(),
      },
    ]);
    return;
  }

  if (commsUnsubMessages) commsUnsubMessages();
  commsUnsubMessages = commsDb
    .collection("comms")
    .doc(channelId)
    .collection("messages")
    .orderBy("timestamp", "asc")
    .limitToLast(80)
    .onSnapshot(
      (snap) => {
        const msgs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        renderCommsMessages(msgs);
      },
      (err) => {
        renderCommsMessages([
          {
            senderUid: "system",
            senderName: "System",
            role: "Error",
            text: "Error loading messages: " + (err?.message || String(err)),
            timestamp: new Date(),
          },
        ]);
      }
    );
}

function sendCommsMessage() {
  if (!commsDb || !commsInputEl) return;
  const text = commsInputEl.value.trim();
  if (!text) return;

  const role = document.getElementById("commsRole")?.value || "Staff";
  commsDb
    .collection("comms")
    .doc(commsActiveChannel)
    .collection("messages")
    .add({
      channel: commsActiveChannel,
      senderUid: "admin-web",
      senderName: "Admin Panel",
      role,
      text,
      timestamp: firebase.firestore.FieldValue.serverTimestamp(),
    })
    .then(() => {
      commsInputEl.value = "";
    })
    .catch((err) => alert("Failed to send: " + (err?.message || String(err))));
}

// Presence roster
let commsUnsubRoster = null;
function renderRoster(presences) {
  if (!commsRosterGroupsEl) return;
  commsRosterGroupsEl.innerHTML = "";

  const byRole = new Map();
  (presences || []).forEach((p) => {
    const role = p.role || "Staff";
    if (!byRole.has(role)) byRole.set(role, []);
    byRole.get(role).push(p);
  });

  const rolesOrdered = Array.from(byRole.keys()).sort();
  rolesOrdered.forEach((role) => {
    const title = document.createElement("div");
    title.className = "commsRosterGroupTitle";
    title.textContent = role;
    commsRosterGroupsEl.appendChild(title);

    byRole.get(role).forEach((p) => {
      const row = document.createElement("div");
      row.className = "commsRosterRow";

      const dot = document.createElement("div");
      dot.className = "presenceDot" + (p.state === "idle" ? " idle" : "");

      const info = document.createElement("div");

      const name = document.createElement("div");
      name.className = "commsRosterName";
      name.textContent = p.name || "Unknown";

      const meta = document.createElement("div");
      meta.className = "commsRosterMeta";
      const dept = p.department ? " · " + p.department : "";
      meta.textContent = (p.state || "online") + dept + " · " + formatLastSeen(p.lastSeen);

      info.appendChild(name);
      info.appendChild(meta);

      row.appendChild(dot);
      row.appendChild(info);
      commsRosterGroupsEl.appendChild(row);
    });
  });
}

function subscribeRoster() {
  if (!commsDb) return;
  if (commsUnsubRoster) commsUnsubRoster();
  commsUnsubRoster = commsDb
    .collection("presence")
    .where("online", "==", true)
    .orderBy("role")
    .orderBy("name")
    .onSnapshot((snap) => {
      const list = snap.docs.map((d) => ({ uid: d.id, ...d.data() }));
      renderRoster(list);
      if (commsMemberCountEl) commsMemberCountEl.textContent = list.length + " online";
    });
}

// Presence self updates (admin web)
const commsPresenceId = "admin-web";
function setPresenceOnline() {
  if (!commsDb) return;
  const role = document.getElementById("commsRole")?.value || "Admin";
  commsDb.collection("presence").doc(commsPresenceId).set(
    {
      name: "Admin Panel",
      role,
      department: "Operations",
      online: true,
      state: document.hidden ? "idle" : "online",
      lastSeen: firebase.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

function setPresenceOffline() {
  if (!commsDb) return;
  const role = document.getElementById("commsRole")?.value || "Admin";
  commsDb.collection("presence").doc(commsPresenceId).set(
    {
      name: "Admin Panel",
      role,
      department: "Operations",
      online: false,
      state: "offline",
      lastSeen: firebase.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

let commsPresenceTimer = null;
function startPresenceHeartbeat() {
  if (!commsDb) return;
  if (commsPresenceTimer) return;
  setPresenceOnline();
  commsPresenceTimer = setInterval(setPresenceOnline, 45000);
}

function stopPresenceHeartbeat() {
  if (commsPresenceTimer) clearInterval(commsPresenceTimer);
  commsPresenceTimer = null;
  setPresenceOffline();
}

document.querySelectorAll(".channelItem").forEach((btn) => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".channelItem").forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    subscribeCommsChannel(btn.dataset.channel);
  });
});

document.getElementById("sendCommsBtn")?.addEventListener("click", sendCommsMessage);
commsInputEl?.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    sendCommsMessage();
  }
});

document.getElementById("toggleDutyBtn")?.addEventListener("click", () => {
  dutyOn = !dutyOn;
  const badge = document.getElementById("dutyBadge");
  if (badge) {
    badge.textContent = dutyOn ? "On Duty" : "Off Duty";
    badge.className = "badge " + (dutyOn ? "green" : "red");
  }
  const c = Number(document.getElementById("onDutyCount")?.textContent || "0");
  const next = dutyOn ? c + 1 : Math.max(0, c - 1);
  const countEl = document.getElementById("onDutyCount");
  if (countEl) countEl.textContent = String(next);
});

document.getElementById("commsRole")?.addEventListener("change", () => {
  // Refresh own presence role quickly.
  setPresenceOnline();
});

document.addEventListener("visibilitychange", () => {
  if (!commsDb) return;
  if (document.hidden) {
    stopPresenceHeartbeat();
  } else {
    startPresenceHeartbeat();
  }
});
window.addEventListener("beforeunload", () => {
  try {
    stopPresenceHeartbeat();
  } catch (_) {}
});

// init
subscribeCommsChannel(commsActiveChannel);
subscribeRoster();
startPresenceHeartbeat();

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
