// ── Tab switching ─────────────────────────────────────────────
const tabButtons = Array.from(document.querySelectorAll(".dockBtn"));
const tabSections = {
  overview: document.getElementById("tab-overview"),
  management: document.getElementById("tab-management"),
  operations: document.getElementById("tab-operations"),
  insights: document.getElementById("tab-insights"),
  billings: document.getElementById("tab-billings"),
  comms: document.getElementById("tab-comms"),
};
const tabTitles = {
  overview: "Overview",
  management: "Manage",
  operations: "Operations",
  insights: "Report",
  billings: "Billings",
  comms: "Comms",
};
const pageTitleEl = document.getElementById("pageTitle");

// ── Demo dataset (so analytics/Gemma has context) ──────────────
const demoState = {
  wards: {
    ICU: { used: 9, total: 12 },
    ER: { used: 14, total: 20 },
    General: { used: 38, total: 60 },
  },
  staff: [
    {
      id: "STF-001",
      name: "Dr. Aanya Verma",
      role: "Emergency Physician",
      ward: "ER",
      onDuty: true,
      duty: "Triage Lead",
      assignment: "ER Bay 2 • Trauma intake & stabilization",
      since: Date.now() - 1000 * 60 * 60 * 3 - 1000 * 60 * 17,
      lastCheckIn: Date.now() - 1000 * 60 * 7,
      contact: "aanya.verma@goelhospital.com",
    },
    {
      id: "STF-002",
      name: "Nurse Kavya Singh",
      role: "ICU Nurse",
      ward: "ICU",
      onDuty: true,
      duty: "Ventilator Rounds",
      assignment: "ICU Bed 4–6 • vitals monitoring & meds",
      since: Date.now() - 1000 * 60 * 60 * 5 - 1000 * 60 * 2,
      lastCheckIn: Date.now() - 1000 * 60 * 2,
      contact: "kavya.singh@goelhospital.com",
    },
    {
      id: "STF-003",
      name: "Dr. Rohan Mehta",
      role: "Cardiologist (On-call)",
      ward: "ICU",
      onDuty: false,
      duty: "On-call",
      assignment: "On call for cardiac consults",
      since: Date.now() - 1000 * 60 * 60 * 12,
      lastCheckIn: Date.now() - 1000 * 60 * 45,
      contact: "rohan.mehta@goelhospital.com",
    },
    {
      id: "STF-004",
      name: "Tech Arjun Rao",
      role: "Radiology Tech",
      ward: "ER",
      onDuty: true,
      duty: "Portable X-Ray",
      assignment: "ER Bay 1–3 • imaging requests queue",
      since: Date.now() - 1000 * 60 * 60 * 1 - 1000 * 60 * 28,
      lastCheckIn: Date.now() - 1000 * 60 * 11,
      contact: "arjun.rao@goelhospital.com",
    },
    {
      id: "STF-005",
      name: "Dr. Neha Kapoor",
      role: "General Physician",
      ward: "General",
      onDuty: true,
      duty: "Ward Coverage",
      assignment: "Ward A • rounds, discharge review, consults",
      since: Date.now() - 1000 * 60 * 60 * 2 - 1000 * 60 * 41,
      lastCheckIn: Date.now() - 1000 * 60 * 5,
      contact: "neha.kapoor@goelhospital.com",
    },
  ],
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
    if (!section) continue;
    section.classList.toggle("active", name === tab);
  }
  tabButtons.forEach((btn) => {
    const on = btn.dataset.tab === tab;
    btn.classList.toggle("active", on);
    if (btn.getAttribute("role") === "tab") {
      btn.setAttribute("aria-selected", on ? "true" : "false");
    }
  });
  pageTitleEl.textContent = tabTitles[tab];

  // If map is visible after tab switch, resize map
  if (tab === "overview" || tab === "management") {
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
  const trayTime = document.getElementById("trayTime");
  const trayDate = document.getElementById("trayDate");
  if (trayTime) trayTime.textContent = h + ":" + m;
  if (trayDate) trayDate.textContent = d + "-" + mo + "-" + y;
}
updateTray();
setInterval(updateTray, 1000);

// ── System health bar (tray) ──────────────────────────────────
function setSystemHealth(state) {
  const box = document.querySelector(".sysHealth");
  const fill = document.getElementById("sysHealthFill");
  const text = document.getElementById("sysHealthText");
  if (!box || !fill || !text) return;

  box.classList.remove("good", "overload", "failed");
  box.classList.add(state);
  text.textContent = state === "good" ? "good" : state === "overload" ? "overload" : "failed";
  fill.style.width = state === "good" ? "100%" : state === "overload" ? "66%" : "30%";
}

function computeSystemHealth() {
  // Tiny student-y heuristic. Uses demo counts + online status.
  const online = navigator.onLine !== false;
  const critical = demoState.patients.filter((p) => p.severity === "critical").length;
  const load = (typeof emergencyCount === "number" ? emergencyCount : 7) + critical;

  if (!online) return "failed";
  if (load >= 14) return "failed";
  if (load >= 9) return "overload";
  return "good";
}

function refreshOverviewKpis() {
  const fleetEl = document.getElementById("ovFleetCount");
  if (fleetEl) fleetEl.textContent = String(demoState.fleet.length);
  const patEl = document.getElementById("ovPatientCount");
  if (patEl) patEl.textContent = String(demoState.patients.length);
  const bedsEl = document.getElementById("ovBedsFree");
  if (bedsEl) {
    const w = demoState.wards;
    const free =
      (w.ICU.total - w.ICU.used) + (w.ER.total - w.ER.used) + (w.General.total - w.General.used);
    bedsEl.textContent = String(free);
  }

  const fleetEl2 = document.getElementById("ovFleetCount2");
  if (fleetEl2) fleetEl2.textContent = String(demoState.fleet.length);
  const patEl2 = document.getElementById("ovPatientCount2");
  if (patEl2) patEl2.textContent = String(demoState.patients.length);
  const bedsEl2 = document.getElementById("ovBedsFree2");
  if (bedsEl2) {
    const w = demoState.wards;
    const free =
      (w.ICU.total - w.ICU.used) + (w.ER.total - w.ER.used) + (w.General.total - w.General.used);
    bedsEl2.textContent = String(free);
  }
}

// Sync KPI values in Overview sidebar blocks too.
function refreshOverviewSideStats() {
  const fc = document.getElementById("ovFleetCount");
  const pc = document.getElementById("ovPatientCount");
  const bc = document.getElementById("ovBedsFree");
  if (fc) fc.textContent = String(demoState.fleet.length);
  if (pc) pc.textContent = String(demoState.patients.length);
  if (bc) {
    const w = demoState.wards;
    const free =
      (w.ICU.total - w.ICU.used) + (w.ER.total - w.ER.used) + (w.General.total - w.General.used);
    bc.textContent = String(free);
  }
}

function tickSystemHealth() {
  try {
    setSystemHealth(computeSystemHealth());
  } catch (_) {
    setSystemHealth("overload");
  }
}

tickSystemHealth();
setInterval(tickSystemHealth, 2500);
refreshOverviewKpis();
refreshOverviewSideStats();

// ── Operations: human-in-loop feed ────────────────────────────
const opsState = {
  items: [],
  selectedId: "",
  filter: "all", // all | fleet | patients | staff
  aiEnabled: true,
};

function opsNowTs() {
  return Date.now();
}

function opsFmtTime(ms) {
  try {
    return new Date(ms).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch (_) {
    return "";
  }
}

function opsTypeLabel(t) {
  if (t === "fleet") return "Fleet";
  if (t === "patients") return "Patients";
  if (t === "staff") return "Staff";
  return "Ops";
}

function opsStatusLabel(s) {
  if (s === "approved") return "Approved";
  if (s === "rejected") return "Rejected";
  if (s === "hold") return "Hold";
  return "Pending";
}

function addOpsItem(partial) {
  const id = partial.id || ("OPS-" + Math.floor(Math.random() * 900000));
  const item = Object.assign(
    {
      id,
      type: "ops",
      title: "",
      summary: "",
      createdAt: opsNowTs(),
      status: "pending",
      payload: {},
      aiSuggestion: null,
    },
    partial
  );
  opsState.items.unshift(item);
  // Keep list sane.
  if (opsState.items.length > 120) opsState.items.length = 120;
  if (!opsState.selectedId) opsState.selectedId = item.id;
  renderOpsFeed();
  renderOpsDetailById(opsState.selectedId);
  refreshOpsKpis();
}

function emitOpsFromModule(type, title, summary, payload) {
  addOpsItem({
    type,
    title,
    summary,
    payload: payload || {},
    createdAt: opsNowTs(),
    status: "pending",
  });
}

function filteredOpsItems() {
  if (opsState.filter === "all") return opsState.items;
  return opsState.items.filter((i) => i.type === opsState.filter);
}

function refreshOpsKpis() {
  const fleet = opsState.items.filter((i) => i.type === "fleet").length;
  const pat = opsState.items.filter((i) => i.type === "patients").length;
  const st = opsState.items.filter((i) => i.type === "staff").length;
  const elF = document.getElementById("opsKpiFleet");
  const elP = document.getElementById("opsKpiPatients");
  const elS = document.getElementById("opsKpiStaff");
  if (elF) elF.textContent = String(fleet);
  if (elP) elP.textContent = String(pat);
  if (elS) elS.textContent = String(st);

  const badge = document.getElementById("opsFeedBadge");
  if (badge) {
    const pending = opsState.items.filter((i) => i.status === "pending").length;
    badge.textContent = "Pending: " + pending;
  }
}

function renderOpsFeed() {
  const list = document.getElementById("opsFeedList");
  if (!list) return;
  list.innerHTML = "";

  const items = filteredOpsItems();
  if (!items.length) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.style.padding = "10px 2px";
    empty.textContent = "No updates yet.";
    list.appendChild(empty);
    return;
  }

  items.forEach((it) => {
    const row = document.createElement("div");
    row.className = "opsFeedRow" + (it.id === opsState.selectedId ? " active" : "");
    row.setAttribute("role", "button");
    row.setAttribute("tabindex", "0");
    row.setAttribute("aria-label", "Open update " + it.id);
    row.dataset.opsId = it.id;

    row.innerHTML =
      "<div class=\"opsFeedTop\">" +
      "<span class=\"opsTag opsTag--" + it.type + "\">" + opsTypeLabel(it.type) + "</span>" +
      "<span class=\"opsTime\">" + opsFmtTime(it.createdAt) + "</span>" +
      "</div>" +
      "<div class=\"opsTitle\"></div>" +
      "<div class=\"opsSub\"></div>" +
      "<div class=\"opsStatus opsStatus--" + it.status + "\">" + opsStatusLabel(it.status) + "</div>";

    row.querySelector(".opsTitle").textContent = it.title || it.id;
    row.querySelector(".opsSub").textContent = it.summary || "";

    function open() {
      opsState.selectedId = it.id;
      renderOpsFeed();
      renderOpsDetailById(it.id);
    }
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => {
      if (e.key === "Enter") open();
    });

    list.appendChild(row);
  });
}

function renderOpsDetailById(id) {
  const it = opsState.items.find((x) => x.id === id);
  renderOpsDetail(it || null);
}

function renderOpsDetail(it) {
  const out = document.getElementById("opsDetailsText");
  const actions = document.getElementById("opsDetailActions");
  if (!out) return;
  if (!it) {
    out.textContent = "Select an update to review.";
    if (actions) actions.hidden = true;
    return;
  }

  if (actions) actions.hidden = false;

  const payload = it.payload || {};
  const ai = it.aiSuggestion;
  const aiBox = ai
    ? ("<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Gemini suggestion</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
        (ai.decision || "needs-human") +
        "</span><br/>" +
        (ai.reason || "") +
        "</div></div>")
    : "";

  out.innerHTML =
    "<div class=\"detailsTitle\">" +
    it.title +
    "</div>" +
    "<div class=\"detailsBlocks\">" +
    "<div class=\"detailsGrid\">" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Source</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
    opsTypeLabel(it.type) +
    "</span></div></div>" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Status</div><div class=\"detailsValue\">" +
    opsStatusLabel(it.status) +
    "</div></div>" +
    "</div>" +
    "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Summary</div><div class=\"detailsValue\">" +
    (it.summary || "—") +
    "</div></div>" +
    "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Payload</div><div class=\"detailsValue\"><pre style=\"margin:0;white-space:pre-wrap;word-break:break-word;background:#060e1a;border:1px solid #1a2a42;padding:10px;border-radius:10px;max-height:220px;overflow:auto\">" +
    String(JSON.stringify(payload, null, 2)).replace(/</g, "&lt;") +
    "</pre></div></div>" +
    aiBox +
    "</div>";

  const approveBtn = document.getElementById("opsApproveBtn");
  const rejectBtn = document.getElementById("opsRejectBtn");
  const askBtn = document.getElementById("opsAskGeminiBtn");
  const holdBtn = document.getElementById("opsHoldBtn");

  if (approveBtn) approveBtn.disabled = it.status === "approved";
  if (rejectBtn) rejectBtn.disabled = it.status === "rejected";
  if (holdBtn) holdBtn.textContent = it.status === "hold" ? "Unhold" : "Hold";
  if (askBtn) askBtn.disabled = !opsState.aiEnabled || it.status === "hold";
}

function bindOpsActionsOnce() {
  const approveBtn = document.getElementById("opsApproveBtn");
  const rejectBtn = document.getElementById("opsRejectBtn");
  const askBtn = document.getElementById("opsAskGeminiBtn");
  const holdBtn = document.getElementById("opsHoldBtn");
  const stop = document.getElementById("opsAiStop");
  const badge = document.getElementById("opsFeedBadge");

  if (badge && !badge._opsBound) badge._opsBound = true;

  stop && stop.addEventListener("change", () => {
    opsState.aiEnabled = !stop.checked;
    renderOpsDetailById(opsState.selectedId);
  });

  document.querySelectorAll(".opsFilterBtn").forEach((b) => {
    if (b._opsBound) return;
    b._opsBound = true;
    b.addEventListener("click", () => {
      document.querySelectorAll(".opsFilterBtn").forEach((x) => x.classList.remove("active"));
      b.classList.add("active");
      opsState.filter = b.dataset.filter || "all";
      renderOpsFeed();
    });
  });

  approveBtn && approveBtn.addEventListener("click", () => {
    const it = opsState.items.find((x) => x.id === opsState.selectedId);
    if (!it) return;
    it.status = "approved";
    renderOpsFeed();
    renderOpsDetail(it);
    refreshOpsKpis();
  });
  rejectBtn && rejectBtn.addEventListener("click", () => {
    const it = opsState.items.find((x) => x.id === opsState.selectedId);
    if (!it) return;
    it.status = "rejected";
    renderOpsFeed();
    renderOpsDetail(it);
    refreshOpsKpis();
  });
  holdBtn && holdBtn.addEventListener("click", () => {
    const it = opsState.items.find((x) => x.id === opsState.selectedId);
    if (!it) return;
    it.status = it.status === "hold" ? "pending" : "hold";
    renderOpsFeed();
    renderOpsDetail(it);
    refreshOpsKpis();
  });

  askBtn && askBtn.addEventListener("click", () => {
    const it = opsState.items.find((x) => x.id === opsState.selectedId);
    if (!it) return;
    if (!opsState.aiEnabled) {
      alert("AI paused by admin (Stop AI is enabled).");
      return;
    }
    if (it.status === "hold") {
      alert("This item is on hold; unhold to ask Gemini.");
      return;
    }
    askBtn.disabled = true;
    askBtn.textContent = "Asking…";
    (async () => {
      let suggestion = null;
      try {
        suggestion = await suggestOpsDecision(it);
      } catch (e) {
        suggestion = { decision: "needs-human", reason: "Client error: " + (e && e.message ? e.message : String(e)) };
      }
      it.aiSuggestion = suggestion;
      renderOpsDetail(it);
      askBtn.disabled = false;
      askBtn.textContent = "Ask Gemini";
    })();
  });
}

function seedOpsFeed() {
  if (opsState.items.length) return;
  addOpsItem({
    id: "OPS-BOOT-1",
    type: "staff",
    title: "Shift update: ER coverage ok",
    summary: "ER Shift A has 12 staff; last check-in 10:42.",
    payload: { module: "staff", ward: "ER", onDuty: 12 },
  });
  addOpsItem({
    id: "OPS-BOOT-2",
    type: "patients",
    title: "Consult request: cardiology",
    summary: "Patient Ravi Kumar requested cardiology consult.",
    payload: { module: "patients", patient: "Ravi Kumar", request: "consultation", specialty: "Cardiology" },
  });
  addOpsItem({
    id: "OPS-BOOT-3",
    type: "fleet",
    title: "Unit EMS-LKO-09 dispatched",
    summary: "Assigned to incident by admin; status now dispatched.",
    payload: { module: "fleet", unit: "EMS-LKO-09", action: "assign" },
  });
}

bindOpsActionsOnce();
seedOpsFeed();
renderOpsFeed();
renderOpsDetailById(opsState.selectedId);
refreshOpsKpis();

// ── Management side navigation (Patients / Fleet / Staff) ──
const mgmtBtns = Array.from(document.querySelectorAll(".mgmtNavBtn"));
const mgmtViews = {
  patients: document.getElementById("mview-patients"),
  fleet: document.getElementById("mview-fleet"),
  staff: document.getElementById("mview-staff"),
};

function switchMgmtView(name) {
  mgmtBtns.forEach((b) => b.classList.toggle("active", b.dataset.mview === name));
  Object.entries(mgmtViews).forEach(([k, el]) => el && el.classList.toggle("active", k === name));
  const unitsBlock = document.getElementById("mgmtUnitsBlock");
  const staffBlock = document.getElementById("mgmtStaffBlock");
  const patientBlock = document.getElementById("mgmtPatientsBlock");
  if (unitsBlock) unitsBlock.hidden = name === "staff" || name === "patients";
  if (staffBlock) staffBlock.hidden = name !== "staff";
  if (patientBlock) patientBlock.hidden = name !== "patients";
  // Resize maps when fleet view opens
  if (name === "fleet") tryResizeMapsSoon();
  if (name === "patients") {
    refreshMgmtPatientsQuickView();
    renderMgmtPatientRoster();
  }
  if (name === "staff") {
    renderMgmtStaffList();
    if (!selectedStaffId) {
      const firstOnDuty = demoState.staff.find((s) => s.onDuty) || demoState.staff[0];
      if (firstOnDuty) selectStaff(firstOnDuty.id);
    }
  }
}

mgmtBtns.forEach((b) => b.addEventListener("click", () => switchMgmtView(b.dataset.mview)));

// ── Management tab ────────────────────────────────────────────
let staffCount = 42;
let fleetCount = 10;
let dispatched = 2;
let emergencyCount = 7;

const staffCountEl   = document.getElementById("staffCount");
const fleetCountEl   = document.getElementById("fleetCount");
const fleetSubEl     = document.getElementById("fleetSub");

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

// ── Management: patients quick view ────────────────────────────
function refreshMgmtPatientsQuickView() {
  const incEl = document.getElementById("mgmtIncomingCount");
  if (incEl) incEl.textContent = String(emergencyCount);
  const crit = demoState.patients.filter((p) => p.severity === "critical").length;
  const critEl = document.getElementById("mgmtCriticalCount");
  if (critEl) critEl.textContent = String(crit);
  const list = document.getElementById("mgmtPatientsMiniList");
  if (list) {
    list.innerHTML = "";
    demoState.patients.slice(0, 6).forEach((p) => {
      const li = document.createElement("li");
      li.textContent = p.name + " · " + p.zone + " · " + p.severity;
      li.style.cursor = "pointer";
      li.setAttribute("role", "button");
      li.setAttribute("tabindex", "0");
      li.setAttribute("aria-label", "View patient " + p.name);
      li.addEventListener("click", () => renderMgmtDetails("patient", p));
      li.addEventListener("keydown", (e) => {
        if (e.key === "Enter") renderMgmtDetails("patient", p);
      });
      list.appendChild(li);
    });
  }
}

function renderMgmtPatientRoster() {
  const listEl = document.getElementById("mgmtPatientRoster");
  if (!listEl) return;
  const qEl = document.getElementById("patientSearch");
  const q = qEl ? qEl.value.trim().toLowerCase() : "";

  const filtered = demoState.patients.filter((p) => {
    if (!q) return true;
    const hay = (p.name + " " + p.zone + " " + p.severity + " " + p.age).toLowerCase();
    return hay.includes(q);
  });

  listEl.innerHTML = "";
  if (!filtered.length) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.textContent = "No patients match your search.";
    listEl.appendChild(empty);
    return;
  }

  filtered.forEach((p) => {
    const row = document.createElement("div");
    row.className = "staffRow staffRowClick";
    row.innerHTML =
      "<div class=\"staffRowTop\">" +
      "<div class=\"staffName\"></div>" +
      "<div class=\"staffTag\"></div>" +
      "</div>" +
      "<div class=\"staffSub\"></div>";
    row.querySelector(".staffName").textContent = p.name;
    row.querySelector(".staffTag").textContent = String(p.severity || "").toUpperCase();
    row.querySelector(".staffSub").textContent = (p.zone || "—") + " · age " + p.age;
    row.addEventListener("click", () => renderMgmtDetails("patient", p));
    listEl.appendChild(row);
  });
}

document.getElementById("patientSearch")?.addEventListener("input", renderMgmtPatientRoster);

// (Ward view removed from Manage; ward data still used in Overview/Operations.)

// ── Management: staff roster + details ─────────────────────────
let selectedStaffId = "";

function formatUptime(ms) {
  const s = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (h <= 0) return m + "m";
  return h + "h " + m + "m";
}

function staffDutyLabel(s) {
  return (s.onDuty ? "On duty" : "Off duty") + " • " + (s.duty || s.role);
}

function highlightStaffRow(staffId) {
  document.querySelectorAll(".staffRowClick").forEach((n) => {
    n.classList.toggle("staffRowActive", !!staffId && n.dataset.staffId === staffId);
  });
}

function mgmtAnalyticsHtml() {
  const w = demoState.wards;
  const bedsFree =
    (w.ICU.total - w.ICU.used) + (w.ER.total - w.ER.used) + (w.General.total - w.General.used);
  return (
    "<div class=\"detailsTitle\">Analytics</div>" +
    "<div class=\"detailsBlocks\">" +
    "<div class=\"detailsGrid\">" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Fleet</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
    demoState.fleet.length +
    "</span></div></div>" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Patients</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
    demoState.patients.length +
    "</span></div></div>" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Beds free</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
    bedsFree +
    "</span></div></div>" +
    "<div class=\"detailsBlock\"><div class=\"detailsLabel\">On duty</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
    demoState.staff.filter((x) => x.onDuty).length +
    "</span></div></div>" +
    "</div>" +
    "</div>"
  );
}

function renderMgmtDetails(kind, payload) {
  const det = document.getElementById("detailsText");
  if (!det) return;

  const base = mgmtAnalyticsHtml();

  if (kind === "fleet") {
    const f = payload;
    const activeFleetCreds = activeFleetCredAccounts().filter((a) => a.kind === "fleet");
    const guessCred =
      activeFleetCreds.find((a) => String(a.displayName || "").toUpperCase() === String(f.id || "").toUpperCase()) ||
      activeFleetCreds[activeFleetCreds.length - 1] ||
      null;
    det.innerHTML =
      base +
      "<div class=\"detailsTitle\" style=\"margin-top:12px\">Fleet unit</div>" +
      "<div class=\"detailsBlocks\">" +
      "<div class=\"detailsGrid\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Unit</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
      f.id +
      "</span></div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Status</div><div class=\"detailsValue\">" +
      fleetStatusLabel(f) +
      "</div></div>" +
      "</div>" +
      "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Credentials</div><div class=\"detailsValue\">" +
      (guessCred ?
        ("<span class=\"detailsValueStrong\">" + guessCred.email + "</span><br/>Pass: " + guessCred.password)
      : "No fleet credentials issued yet. Use Manage credentials to create one.") +
      "</div></div>" +
      "<div class=\"row\" style=\"margin-top:10px;gap:8px\">" +
      "<button type=\"button\" id=\"fleetAssignBtn\" aria-label=\"Assign unit to incident\">Assign</button>" +
      "<button type=\"button\" class=\"secondary\" id=\"fleetCallBackBtn\" aria-label=\"Call back unit\">Call back</button>" +
      "<button type=\"button\" class=\"danger\" id=\"fleetRevokeBtn\" aria-label=\"Revoke unit\">Revoke</button>" +
      "<button type=\"button\" class=\"secondary\" id=\"fleetOpenCredBtn\" aria-label=\"Open credentials console\">Credentials</button>" +
      "</div>" +
      "</div>";

    document.getElementById("fleetAssignBtn")?.addEventListener("click", () => {
      alert("Assigned " + f.id + " to incident (demo).");
      f.status = "dispatched";
      renderMgmtFleetSidebar();
      refreshOverviewKpis();
      tickSystemHealth();
      renderMgmtDetails("fleet", f);
      emitOpsFromModule(
        "fleet",
        "Fleet assigned: " + f.id,
        "Unit assigned to an incident. Status → dispatched.",
        { unit: f.id, action: "assign", status: f.status }
      );
    });
    document.getElementById("fleetCallBackBtn")?.addEventListener("click", () => {
      f.status = "standby";
      renderMgmtFleetSidebar();
      renderMgmtDetails("fleet", f);
      emitOpsFromModule(
        "fleet",
        "Fleet call-back: " + f.id,
        "Unit called back. Status → standby.",
        { unit: f.id, action: "callback", status: f.status }
      );
    });
    document.getElementById("fleetRevokeBtn")?.addEventListener("click", () => {
      f.status = "service";
      renderMgmtFleetSidebar();
      tickSystemHealth();
      renderMgmtDetails("fleet", f);
      emitOpsFromModule(
        "fleet",
        "Fleet revoked: " + f.id,
        "Unit access revoked for now. Status → service.",
        { unit: f.id, action: "revoke", status: f.status }
      );
    });
    document.getElementById("fleetOpenCredBtn")?.addEventListener("click", () => {
      openFleetCredModal();
    });
    return;
  }

  if (kind === "staff") {
    const s = payload;
    const now = Date.now();
    const uptime = s.onDuty ? formatUptime(now - (s.since || now)) : "—";
    const last = s.lastCheckIn
      ? new Date(s.lastCheckIn).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      : "—";
    det.innerHTML =
      base +
      "<div class=\"detailsTitle\" style=\"margin-top:12px\">Staff</div>" +
      "<div class=\"detailsBlocks\">" +
      "<div class=\"detailsGrid\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Name</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
      s.name +
      "</span></div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Status</div><div class=\"detailsValue\">" +
      (s.onDuty ? "On duty" : "Off duty") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Ward</div><div class=\"detailsValue\">" +
      (s.ward || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Uptime</div><div class=\"detailsValue\">" +
      uptime +
      "</div></div>" +
      "</div>" +
      "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Assignment</div><div class=\"detailsValue\">" +
      (s.assignment || "—") +
      "</div></div>" +
      "<div class=\"detailsGrid\" style=\"margin-top:10px\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Role</div><div class=\"detailsValue\">" +
      (s.role || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Last check-in</div><div class=\"detailsValue\">" +
      last +
      "</div></div>" +
      "</div>" +
      "<div class=\"row\" style=\"margin-top:10px;gap:8px\">" +
      "<button type=\"button\" id=\"staffDutyBtn\" aria-label=\"Change staff duty\">" +
      (s.onDuty ? "Mark off-duty" : "Mark on-duty") +
      "</button>" +
      "<button type=\"button\" class=\"secondary\" id=\"staffCallReceptionBtn\" aria-label=\"Call reception\">Call reception</button>" +
      "</div>" +
      "</div>";

    document.getElementById("staffDutyBtn")?.addEventListener("click", () => {
      s.onDuty = !s.onDuty;
      if (s.onDuty) s.since = Date.now();
      renderMgmtStaffList();
      refreshOverviewKpis();
      tickSystemHealth();
      renderMgmtDetails("staff", s);
      emitOpsFromModule(
        "staff",
        "Staff duty change: " + s.name,
        s.onDuty ? "Marked on-duty." : "Marked off-duty.",
        { staffId: s.id, name: s.name, action: "duty", onDuty: s.onDuty, ward: s.ward }
      );
    });
    document.getElementById("staffCallReceptionBtn")?.addEventListener("click", () => {
      alert("Reception called for " + s.name + " (demo).");
      emitOpsFromModule(
        "staff",
        "Reception call: " + s.name,
        "Reception called (demo).",
        { staffId: s.id, name: s.name, action: "call_reception", ward: s.ward }
      );
    });
    return;
  }

  if (kind === "patient") {
    const p = payload;
    det.innerHTML =
      base +
      "<div class=\"detailsTitle\" style=\"margin-top:12px\">Patient</div>" +
      "<div class=\"detailsBlocks\">" +
      "<div class=\"detailsGrid\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Name</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
      p.name +
      "</span></div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Severity</div><div class=\"detailsValue\">" +
      p.severity +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Zone</div><div class=\"detailsValue\">" +
      p.zone +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Age</div><div class=\"detailsValue\">" +
      p.age +
      "</div></div>" +
      "</div>" +
      "<div class=\"row\" style=\"margin-top:10px;gap:8px\">" +
      "<button type=\"button\" id=\"patientEscalateBtn\" aria-label=\"Escalate patient\">Escalate</button>" +
      "<button type=\"button\" class=\"secondary\" id=\"patientCallNurseBtn\" aria-label=\"Call nurse\">Call nurse</button>" +
      "</div>" +
      "</div>";
    document.getElementById("patientEscalateBtn")?.addEventListener("click", () => {
      alert("Escalated " + p.name + " (demo).");
      emitOpsFromModule(
        "patients",
        "Patient escalated: " + p.name,
        "Escalation requested. Severity: " + p.severity + ".",
        { name: p.name, action: "escalate", severity: p.severity, zone: p.zone, age: p.age }
      );
    });
    document.getElementById("patientCallNurseBtn")?.addEventListener("click", () => {
      alert("Nurse notified for " + p.name + " (demo).");
      emitOpsFromModule(
        "patients",
        "Nurse called: " + p.name,
        "Nurse notified for patient (demo).",
        { name: p.name, action: "call_nurse", severity: p.severity, zone: p.zone, age: p.age }
      );
    });
    return;
  }

  det.innerHTML = base + "<p class=\"muted\" style=\"margin-top:12px\">Select an item to see details.</p>";
}

function renderStaffDetails(s) {
  renderMgmtDetails("staff", s);
}

function selectStaff(staffId) {
  const s = demoState.staff.find((x) => x.id === staffId);
  if (!s) return;
  selectedStaffId = staffId;
  highlightStaffRow(staffId);
  renderStaffDetails(s);
}

function renderMgmtStaffList() {
  const listEl = document.getElementById("mgmtStaffList");
  if (!listEl) return;

  const qEl = document.getElementById("staffSearch");
  const q = qEl ? qEl.value.trim().toLowerCase() : "";
  const filtered = demoState.staff.filter((s) => {
    if (!q) return true;
    const hay = (s.name + " " + s.role + " " + s.ward + " " + s.duty).toLowerCase();
    return hay.includes(q);
  });

  listEl.innerHTML = "";
  if (!filtered.length) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.textContent = "No staff match your search.";
    listEl.appendChild(empty);
    return;
  }

  filtered.forEach((s) => {
    const row = document.createElement("div");
    row.className = "staffRow staffRowClick";
    row.dataset.staffId = s.id;
    row.innerHTML =
      "<div class=\"staffRowTop\">" +
      "<div class=\"staffName\"></div>" +
      "<div class=\"staffTag\"></div>" +
      "</div>" +
      "<div class=\"staffSub\"></div>";
    row.querySelector(".staffName").textContent = s.name;
    row.querySelector(".staffTag").textContent = s.onDuty ? "ON DUTY" : "OFF DUTY";
    row.querySelector(".staffSub").textContent = (s.ward ? s.ward + " · " : "") + staffDutyLabel(s);
    row.addEventListener("click", () => selectStaff(s.id));
    listEl.appendChild(row);
  });

  highlightStaffRow(selectedStaffId);
}

const staffSearchEl = document.getElementById("staffSearch");
staffSearchEl && staffSearchEl.addEventListener("input", () => renderMgmtStaffList());

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
  updatePatientsTabStats();
});
const resolveEmergencyBtn = document.getElementById("resolveEmergencyBtn");
resolveEmergencyBtn && resolveEmergencyBtn.addEventListener("click", () => {
  if (emergencyCount > 0) emergencyCount -= 1;
  updatePatientsTabStats();
});

// ── Patients tab (dedicated) ──────────────────────────────────
const patientsPatientListEl = document.getElementById("patientsPatientList");
const patientsRosterListEl = document.getElementById("patientsRosterList");

function addPatientRow(targetListEl, name, zone) {
  const li = document.createElement("li");
  const ts = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  li.textContent = "📍 " + name + " — " + zone + " · " + ts;
  targetListEl && targetListEl.prepend(li);
}

function updatePatientsTabStats() {
  const inc = document.getElementById("patientsIncomingStat");
  if (inc) inc.textContent = String(emergencyCount);
  const crit = demoState.patients.filter((p) => p.severity === "critical").length;
  const cEl = document.getElementById("patientsCriticalStat");
  if (cEl) cEl.textContent = String(crit);
  const tEl = document.getElementById("patientsTrackedStat");
  if (tEl && patientsPatientListEl) {
    tEl.textContent = String(patientsPatientListEl.querySelectorAll("li").length);
  }
}

demoState.patients.forEach((p) => {
  addPatientRow(patientsPatientListEl, p.name, p.zone);
  if (patientsRosterListEl) {
    const li = document.createElement("li");
    li.textContent = p.name + " · " + p.zone + " · " + p.severity + " · age " + p.age;
    patientsRosterListEl.appendChild(li);
  }
});
updatePatientsTabStats();

const patientsAddPatientBtn = document.getElementById("patientsAddPatientBtn");
patientsAddPatientBtn &&
  patientsAddPatientBtn.addEventListener("click", () => {
    const name = document.getElementById("patientsPatientName").value.trim();
    const zone = document.getElementById("patientsPatientZone").value.trim();
    if (!name || !zone) return;
    addPatientRow(patientsPatientListEl, name, zone);
    document.getElementById("patientsPatientName").value = "";
    document.getElementById("patientsPatientZone").value = "";
    updatePatientsTabStats();
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

const patientsRefreshGemmaBtn = document.getElementById("patientsRefreshGemmaBtn");
patientsRefreshGemmaBtn &&
  patientsRefreshGemmaBtn.addEventListener("click", () => {
    gemmaIdx = (gemmaIdx + 1) % gemmaHints.length;
    applyGemmaHint(gemmaHints[gemmaIdx], "patientsGemmaHint", "patientsGemmaTs");
  });

const mapRefreshGemmaBtn = document.getElementById("mapRefreshGemmaBtn");
mapRefreshGemmaBtn && mapRefreshGemmaBtn.addEventListener("click", () => {
  gemmaIdx = (gemmaIdx + 1) % gemmaHints.length;
  applyGemmaHint(gemmaHints[gemmaIdx], "mapGemmaHint", "mapGemmaTs");
});

// ── Management: fleet sidebar + credentials (staff / fleet login) ──
let fleetCredSeq = 100;
const fleetCredAccounts = [];
const fleetCredLogsEl = document.getElementById("fleetCredLogs");

function pushFleetCredLog(line) {
  const ts = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  const entry = "[" + ts + "] " + line;
  if (fleetCredLogsEl) {
    const li = document.createElement("li");
    li.textContent = entry;
    fleetCredLogsEl.prepend(li);
  }
}

function findFleetUnit(id) {
  return demoState.fleet.find((f) => f.id === id);
}

function fleetStatusLabel(f) {
  if (f.status === "dispatched") return "Dispatched • en route";
  if (f.status === "standby") return "Standby • available";
  if (f.status === "available") return "Available • in district";
  if (f.status === "service") return "Off-line • workshop / service";
  return f.status;
}

function highlightSidebarFleet(fleetId) {
  document.querySelectorAll(".sideUnitClick").forEach((n) => {
    n.classList.toggle("sideUnitActive", !!fleetId && n.dataset.fleetId === fleetId);
  });
}

function selectFleetOnMap(fleetId) {
  const fleet = findFleetUnit(fleetId);
  if (!fleet) return;
  highlightSidebarFleet(fleetId);
  renderMgmtDetails("fleet", fleet);
  if (osmMgmt && window.L) {
    try {
      osmMgmt.setView([fleet.lat, fleet.lng], 14);
    } catch (_) {}
  }
  tryResizeMapsSoon();
}

function renderMgmtFleetSidebar() {
  const el = document.getElementById("mgmtFleetUnits");
  if (!el) return;
  el.innerHTML = "";
  demoState.fleet.forEach((f) => {
    const div = document.createElement("div");
    div.className = "sideUnit sideUnitClick";
    div.dataset.fleetId = f.id;
    div.innerHTML = "<div class=\"sideUnitTitle\"></div><div class=\"sideUnitSub\"></div>";
    div.querySelector(".sideUnitTitle").textContent = f.id;
    div.querySelector(".sideUnitSub").textContent = fleetStatusLabel(f);
    div.addEventListener("click", () => selectFleetOnMap(f.id));
    el.appendChild(div);
  });
}

function activeFleetCredAccounts() {
  return fleetCredAccounts.filter((a) => !a.revoked);
}

function refreshFleetCredSelects() {
  const act = activeFleetCredAccounts();
  const revSel = document.getElementById("fleetCredRevokeSelect");
  const resetSel = document.getElementById("fleetCredResetSelect");
  if (revSel) {
    revSel.innerHTML = "";
    if (!act.length) {
      const o = document.createElement("option");
      o.value = "";
      o.textContent = "No active accounts";
      revSel.appendChild(o);
    } else {
      act.forEach((a) => {
        const o = document.createElement("option");
        o.value = a.id;
        o.textContent = a.email + " (" + a.kind + ")";
        revSel.appendChild(o);
      });
    }
  }
  if (resetSel) {
    resetSel.innerHTML = "";
    if (!act.length) {
      const o = document.createElement("option");
      o.value = "";
      o.textContent = "No active accounts";
      resetSel.appendChild(o);
    } else {
      act.forEach((a) => {
        const o = document.createElement("option");
        o.value = a.id;
        o.textContent = a.email + " (" + a.kind + ")";
        resetSel.appendChild(o);
      });
    }
  }
}

function openFleetCredModal() {
  const m = document.getElementById("fleetCredModal");
  if (!m) return;
  m.hidden = false;
  m.setAttribute("aria-hidden", "false");
  refreshFleetCredSelects();
}

function closeFleetCredModal() {
  const m = document.getElementById("fleetCredModal");
  if (!m) return;
  m.hidden = true;
  m.setAttribute("aria-hidden", "true");
}

function showCredPanel(tab) {
  ["create", "revoke", "reset", "logs"].forEach((t) => {
    const p = document.getElementById("credPanel-" + t);
    if (p) p.hidden = t !== tab;
  });
  document.querySelectorAll(".credTabBtn").forEach((b) => {
    const on = b.dataset.credtab === tab;
    b.classList.toggle("active", on);
    b.classList.toggle("secondary", !on);
  });
}

document.getElementById("fleetCredModalClose")?.addEventListener("click", closeFleetCredModal);
document.getElementById("fleetCredModalBackdrop")?.addEventListener("click", closeFleetCredModal);

document.querySelectorAll(".credTabBtn").forEach((btn) => {
  btn.addEventListener("click", () => showCredPanel(btn.dataset.credtab));
});

document.getElementById("fleetCredCreateBtn")?.addEventListener("click", () => {
  const nameRaw = document.getElementById("fleetCredName").value.trim();
  const kind = document.getElementById("fleetCredRole").value;
  const out = document.getElementById("fleetCredCreateOut");
  if (!nameRaw) {
    if (out) out.textContent = "Enter a name or call sign.";
    return;
  }
  fleetCredSeq += 1;
  const slug = nameRaw.toLowerCase().replace(/[^a-z0-9]+/g, ".").replace(/^\.|\.$/g, "") || "user";
  const email =
    kind === "fleet" ?
      "fleet." + slug + "." + fleetCredSeq + "@goelhospital.com"
    : "staff." + slug + "." + fleetCredSeq + "@goelhospital.com";
  const password = "GH@" + (2000 + fleetCredSeq);
  const id = "CR-" + fleetCredSeq;
  fleetCredAccounts.push({
    id,
    email,
    displayName: nameRaw,
    kind: kind === "fleet" ? "fleet" : "staff",
    password,
    revoked: false,
  });
  if (out) {
    out.textContent =
      "Created " +
      email +
      " · password " +
      password +
      " · use on staff app or Fleet Portal (demo).";
  }
  document.getElementById("fleetCredName").value = "";
  pushFleetCredLog("CREATE " + email + " (" + kind + ")");
  refreshFleetCredSelects();
});

document.getElementById("fleetCredRevokeBtn")?.addEventListener("click", () => {
  const sel = document.getElementById("fleetCredRevokeSelect");
  const id = sel && sel.value;
  if (!id) return;
  const acc = fleetCredAccounts.find((a) => a.id === id);
  if (!acc || acc.revoked) return;
  acc.revoked = true;
  pushFleetCredLog("REVOKE " + acc.email);
  refreshFleetCredSelects();
  alert("Revoked: " + acc.email + " (demo — session only)");
});

document.getElementById("fleetCredResetBtn")?.addEventListener("click", () => {
  const sel = document.getElementById("fleetCredResetSelect");
  const id = sel && sel.value;
  const out = document.getElementById("fleetCredResetOut");
  if (!id) return;
  const acc = fleetCredAccounts.find((a) => a.id === id && !a.revoked);
  if (!acc) {
    if (out) out.textContent = "Pick an active account.";
    return;
  }
  const newPass = "GH@" + (8000 + Math.floor(Math.random() * 900));
  acc.password = newPass;
  if (out) out.textContent = "New password for " + acc.email + ": " + newPass;
  pushFleetCredLog("RESET password " + acc.email);
});

// ── Open-source maps (Leaflet + OpenStreetMap) ────────────────
let osmMain;
let osmMgmt;
let osmMarkersMain = [];
let osmMarkersMgmt = [];
let lucknowHexZones = [];
let hexPolyLayer = null;
const demoMarkers = [
  ...demoState.fleet.map((f) => ({ type: "fleet", label: f.id + " (" + f.status + ")", lat: f.lat, lng: f.lng })),
  ...demoState.patients.map((p) => ({ type: "patient", label: "Patient: " + p.name + " (" + p.severity + ")", lat: p.lat, lng: p.lng })),
];

function hexDiskRadius(Ring) {
  const cells = [];
  for (let q = -Ring; q <= Ring; q++) {
    const rMin = Math.max(-Ring, -q - Ring);
    const rMax = Math.min(Ring, -q + Ring);
    for (let r = rMin; r <= rMax; r++) cells.push([q, r]);
  }
  return cells;
}

function axialToCenterLatLng(q, r, centerLat, centerLng, sizeM) {
  const x = sizeM * Math.sqrt(3) * (q + r / 2);
  const y = sizeM * (3 / 2) * r;
  const lat = centerLat + y / 111320;
  const lng = centerLng + x / (111320 * Math.cos((centerLat * Math.PI) / 180));
  return [lat, lng];
}

function hexVerticesPointy(centerLat, centerLng, Rm) {
  const cosLat = Math.cos((centerLat * Math.PI) / 180);
  const corners = [];
  for (let i = 0; i < 6; i++) {
    const ang = Math.PI / 6 + (i * Math.PI) / 3;
    const dx = Rm * Math.cos(ang);
    const dy = Rm * Math.sin(ang);
    corners.push([centerLat + dy / 111320, centerLng + dx / (111320 * cosLat)]);
  }
  return corners;
}

function buildLucknowHexZones() {
  const centerLat = 26.8467;
  const centerLng = 80.9462;
  const hexSpacingM = 480;
  const cells = hexDiskRadius(2);
  const inflows = [12, 47, 8, 36, 5, 51, 18, 42, 7, 39, 14, 44, 9, 33, 49, 11, 28, 41, 22];
  const pops = ["~48k", "~22k", "~61k", "~31k", "~19k", "~55k"];
  const complaintSets = [
    ["Chest pain / cardiac workup", "Hypertensive urgency", "Syncope"],
    ["RTA polytrauma", "Fracture fall", "Head injury"],
    ["Respiratory distress", "COPD exacerbation", "Pneumonia suspect"],
    ["GI bleed", "Acute abdomen", "Dehydration"],
    ["Stroke protocol", "TIA", "Neurology referral"],
    ["Pediatric fever", "Seizure", "Respiratory"],
    ["Burn / scald", "Toxicology screen", "Overdose"],
    ["Obstetric emergency", "Antepartum bleed", "Labor triage"],
  ];
  const fleetLines = [
    "Two active units within 8 min; Hazratganj detour common 17:00–20:00.",
    "Primary corridor: Sitapur Rd; utility lane closures +3–4 min variance.",
    "Strong overlap with adjacent zone handoffs; EMS handshake queue avg 2 cases.",
    "Night shift single-unit cover; backup staged at Kaiserbagh.",
    "High ambulance turnover near teaching hospital cluster.",
    "Low winter fog risk; add +2 min ETA after 22:00 in model.",
    "Gomti bridge approach clear; river-road pinch Sat–Sun evenings.",
    "ICU bypass routing tested; fleet GPS ping every 42s.",
  ];
  const demoLines = [
    "Median age 52 · male 58% · comorbid diabetes 31%.",
    "Median age 34 · trauma skew · weekend +22% volume vs weekday.",
    "Median age 61 · cardiac + respiratory mix peaks 19:00–23:00.",
    "Pediatric share 14%; school-term afternoons elevated.",
    "Senior cohort 67%; fall-related presentations trending up week over week.",
    "Working-age dominant; occupational injury notes in 9% of charts.",
  ];
  const zones = cells.map(([q, r], i) => {
    const [lat, lng] = axialToCenterLatLng(q, r, centerLat, centerLng, hexSpacingM);
    const name = "Zone " + String.fromCharCode(65 + i);
    return {
      q,
      r,
      lat,
      lng,
      name,
      inflow24h: inflows[i] != null ? inflows[i] : 16 + i,
      populationBand: pops[i % pops.length],
      complaints: complaintSets[i % complaintSets.length],
      fleetBlurb: fleetLines[i % fleetLines.length],
      demoBlurb: demoLines[i % demoLines.length],
    };
  });
  const sorted = [...zones].sort((a, b) => b.inflow24h - a.inflow24h);
  sorted.slice(0, 6).forEach((z) => {
    z.tier = "high";
  });
  sorted.slice(-6).forEach((z) => {
    z.tier = "low";
  });
  zones.forEach((z) => {
    if (!z.tier) z.tier = "mid";
  });
  return zones;
}

function hexDefaultStyle() {
  return {
    color: "#5b8fd8",
    weight: 1.5,
    fillColor: "#3f7cff",
    fillOpacity: 0.07,
    className: "hexMapCell",
  };
}

function hexStyleForZone(z) {
  const hi = document.getElementById("hexFilterHigh")?.checked;
  const lo = document.getElementById("hexFilterLow")?.checked;
  const base = { className: "hexMapCell" };
  if (z.tier === "high" && hi) {
    return Object.assign(base, {
      color: "#35c97a",
      weight: 2,
      fillColor: "#35c97a",
      fillOpacity: 0.34,
    });
  }
  if (z.tier === "low" && lo) {
    return Object.assign(base, {
      color: "#ff5252",
      weight: 2,
      fillColor: "#ff5252",
      fillOpacity: 0.3,
    });
  }
  return Object.assign(base, {
    color: "#5b8fd8",
    weight: 1.5,
    fillColor: "#3f7cff",
    fillOpacity: 0.07,
  });
}

function refreshHexStyles() {
  if (!hexPolyLayer) return;
  hexPolyLayer.eachLayer((layer) => {
    const z = layer._hexZone;
    if (z) layer.setStyle(hexStyleForZone(z));
  });
}

function showHexZonePanel(z) {
  const ph = document.getElementById("hexZonePlaceholder");
  const det = document.getElementById("hexZoneDetails");
  if (ph) ph.hidden = true;
  if (det) det.hidden = false;
  const nameEl = document.getElementById("hexZoneName");
  if (nameEl) nameEl.textContent = z.name;
  const badge = document.getElementById("hexZoneTierBadge");
  if (badge) {
    badge.textContent =
      z.tier === "high" ? "High inflow" : z.tier === "low" ? "Low inflow" : "Typical inflow";
    badge.className =
      "badge " + (z.tier === "high" ? "green" : z.tier === "low" ? "red" : "muted");
  }
  const inf = document.getElementById("hexZoneInflow");
  if (inf) inf.textContent = String(z.inflow24h) + " presentations (24h est.)";
  const pop = document.getElementById("hexZonePop");
  if (pop) pop.textContent = z.populationBand + " residents (model)";
  const comp = document.getElementById("hexZoneComplaints");
  if (comp) comp.textContent = z.complaints.join(" · ");
  const fl = document.getElementById("hexZoneFleet");
  if (fl) fl.textContent = z.fleetBlurb;
  const dm = document.getElementById("hexZoneDemo");
  if (dm) dm.textContent = z.demoBlurb;
}

function addHexGridToMainMap(map) {
  if (!map || !window.L) return;
  lucknowHexZones = buildLucknowHexZones();
  const hexSpacingM = 480;
  if (hexPolyLayer) {
    try {
      map.removeLayer(hexPolyLayer);
    } catch (_) {}
  }
  hexPolyLayer = L.layerGroup().addTo(map);
  lucknowHexZones.forEach((z) => {
    const verts = hexVerticesPointy(z.lat, z.lng, hexSpacingM * 0.97);
    const poly = L.polygon(verts, hexStyleForZone(z)).addTo(hexPolyLayer);
    poly._hexZone = z;
    poly.on("click", (e) => {
      L.DomEvent.stopPropagation(e);
      showHexZonePanel(z);
    });
  });
  const hi = document.getElementById("hexFilterHigh");
  const lo = document.getElementById("hexFilterLow");
  if (hi && !hi._hexBound) {
    hi._hexBound = true;
    hi.addEventListener("change", refreshHexStyles);
  }
  if (lo && !lo._hexBound) {
    lo._hexBound = true;
    lo.addEventListener("change", refreshHexStyles);
  }
}

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

function initLeafletMap(id, errorId, useDarkBasemap) {
  const el = document.getElementById(id);
  if (!el) return null;
  if (!window.L) {
    showMapError(errorId, "Leaflet library failed to load.");
    return null;
  }
  const map = L.map(el, { zoomControl: true }).setView([26.8467, 80.9462], 12);
  if (useDarkBasemap) {
    L.tileLayer("https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png", {
      maxZoom: 20,
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> ' +
        '&copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: "abcd",
    }).addTo(map);
  } else {
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href=\"https://www.openstreetmap.org/copyright\">OpenStreetMap</a>',
    }).addTo(map);
  }
  return map;
}

function initOpenSourceMaps() {
  osmMain = initLeafletMap("mapMain", "mapError", true);
  osmMgmt = initLeafletMap("mapMgmt", "mapErrorMgmt", true);
  if (osmMain) {
    addLeafletMarkers(osmMain, osmMarkersMain);
    addHexGridToMainMap(osmMain);
  }
  if (osmMgmt) addLeafletMarkers(osmMgmt, osmMarkersMgmt);
  renderMgmtFleetSidebar();
  renderMgmtStaffList();
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
    hexZones: buildLucknowHexZones().map((z) => ({
      name: z.name,
      tier: z.tier,
      inflow24h: z.inflow24h,
    })),
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

async function suggestOpsDecision(item) {
  const it = item || null;
  if (!it) return { decision: "needs-human", reason: "No item selected." };
  if (!geminiApiKey) return { decision: "needs-human", reason: "No Gemini API key set (Gemma 4 panel)." };

  const snapshot = {
    wards: demoState.wards,
    fleet: demoState.fleet,
    patients: demoState.patients,
    staff: demoState.staff.map((s) => ({ id: s.id, name: s.name, ward: s.ward, onDuty: s.onDuty, role: s.role })),
    billings: demoState.billings,
  };

  const systemCtx =
    "You are Gemma 4 helping an admin review hospital Operations feed items. " +
    "Return a short suggestion ONLY in valid JSON with keys: decision, reason, nextSteps. " +
    "decision must be one of: approve, reject, needs-human. " +
    "Keep reason under 2 lines. nextSteps is an array of short strings.\n\n" +
    "Today is " + new Date().toDateString() + ".\n\n" +
    "Snapshot JSON:\n" + JSON.stringify(snapshot) + "\n\n" +
    "Ops item JSON:\n" + JSON.stringify({ id: it.id, type: it.type, title: it.title, summary: it.summary, payload: it.payload, status: it.status });

  const body = {
    contents: [{ role: "user", parts: [{ text: systemCtx }] }],
    generationConfig: { maxOutputTokens: 220, temperature: 0.2 },
  };

  const res = await fetch(
    "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent?key=" + geminiApiKey,
    { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) }
  );

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    return { decision: "needs-human", reason: "API error " + res.status + ": " + (err?.error?.message || "Unknown error.") };
  }

  const data = await res.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text || "";
  // Try parse JSON; fallback to raw text.
  try {
    const cleaned = text.trim().replace(/^```json/i, "```").replace(/^```/, "").replace(/```$/, "").trim();
    const parsed = JSON.parse(cleaned);
    return {
      decision: parsed.decision || "needs-human",
      reason: parsed.reason || "",
      nextSteps: Array.isArray(parsed.nextSteps) ? parsed.nextSteps : [],
      raw: text,
    };
  } catch (_) {
    return { decision: "needs-human", reason: (text || "No structured suggestion returned.").slice(0, 240), nextSteps: [], raw: text };
  }
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

