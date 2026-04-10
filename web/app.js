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

// ── Data sources ───────────────────────────────────────────────
// Demo data (admin panel is currently static).
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
      assignment: "ER Bay 2 • trauma intake & stabilization",
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
    {
      id: "STF-006",
      name: "Nurse Priya Mishra",
      role: "ER Nurse",
      ward: "ER",
      onDuty: true,
      duty: "Triage Support",
      assignment: "ER Triage • vitals, IV access, documentation",
      since: Date.now() - 1000 * 60 * 60 * 4 - 1000 * 60 * 8,
      lastCheckIn: Date.now() - 1000 * 60 * 3,
      contact: "priya.mishra@goelhospital.com",
    },
    {
      id: "STF-007",
      name: "Tech Saurabh Jain",
      role: "Lab Technician",
      ward: "ER",
      onDuty: true,
      duty: "Stat Labs",
      assignment: "ER Lab Desk • CBC/CMP/troponin queue handling",
      since: Date.now() - 1000 * 60 * 60 * 1 - 1000 * 60 * 52,
      lastCheckIn: Date.now() - 1000 * 60 * 6,
      contact: "saurabh.jain@goelhospital.com",
    },
    {
      id: "STF-008",
      name: "Dr. Sameer Ali",
      role: "Orthopedic (On-call)",
      ward: "ER",
      onDuty: false,
      duty: "On-call",
      assignment: "On-call for fracture reductions / ortho consults",
      since: Date.now() - 1000 * 60 * 60 * 8,
      lastCheckIn: Date.now() - 1000 * 60 * 39,
      contact: "sameer.ali@goelhospital.com",
    },
    {
      id: "STF-009",
      name: "Dr. Isha Tandon",
      role: "Anesthetist",
      ward: "ICU",
      onDuty: true,
      duty: "Airway Lead",
      assignment: "ICU/ER airway • RSI backup, vent protocols",
      since: Date.now() - 1000 * 60 * 60 * 6 - 1000 * 60 * 14,
      lastCheckIn: Date.now() - 1000 * 60 * 4,
      contact: "isha.tandon@goelhospital.com",
    },
    {
      id: "STF-010",
      name: "Nurse Shreya Gupta",
      role: "ICU Nurse",
      ward: "ICU",
      onDuty: true,
      duty: "Meds & Monitoring",
      assignment: "ICU Bed 7–9 • infusions, monitoring, charting",
      since: Date.now() - 1000 * 60 * 60 * 3 - 1000 * 60 * 33,
      lastCheckIn: Date.now() - 1000 * 60 * 2,
      contact: "shreya.gupta@goelhospital.com",
    },
  ],
  fleet: [
    { id: "EMS-LKO-18", status: "standby", lat: 26.8467, lng: 80.9462 },
    { id: "EMS-LKO-09", status: "dispatched", lat: 26.8585, lng: 80.9605 },
    { id: "EMS-LKO-03", status: "available", lat: 26.8382, lng: 80.9341 },
    { id: "EMS-LKO-12", status: "service", lat: 26.8721, lng: 80.9414 },
  ],
  patients: [
    {
      name: "Anjali Patel",
      zone: "Ward A",
      severity: "stable",
      age: 44,
      consignmentType: "Consultation",
      department: "General Medicine",
      schedule: "Today 11:40",
      doctor: "Dr. Neha Kapoor",
      lat: 26.8460,
      lng: 80.9490,
    },
    {
      name: "Ravi Kumar",
      zone: "Trauma Desk",
      severity: "critical",
      age: 52,
      consignmentType: "Surgery",
      department: "Trauma / Ortho",
      schedule: "Today 12:10",
      doctor: "Dr. Aanya Verma",
      lat: 26.8526,
      lng: 80.9412,
    },
    {
      name: "Meera Singh",
      zone: "Ward C",
      severity: "stable",
      age: 38,
      consignmentType: "Consultation",
      department: "Pulmonology",
      schedule: "Today 13:15",
      doctor: "Dr. Neha Kapoor",
      lat: 26.8397,
      lng: 80.9542,
    },
    {
      name: "Sanjay Verma",
      zone: "ER Bay 2",
      severity: "critical",
      age: 61,
      consignmentType: "Procedure",
      department: "Cardiology",
      schedule: "Today 12:35",
      doctor: "Dr. Rohan Mehta",
      lat: 26.8602,
      lng: 80.9521,
    },
    {
      name: "Aarav Sharma",
      zone: "Registration",
      severity: "stable",
      age: 29,
      consignmentType: "Consultation",
      department: "Orthopedics",
      schedule: "Today 14:05",
      doctor: "Dr. Sameer Ali",
      lat: 26.8489,
      lng: 80.9388,
    },
    {
      name: "Farah Khan",
      zone: "ER Bay 1",
      severity: "urgent",
      age: 33,
      consignmentType: "Procedure",
      department: "Obstetrics",
      schedule: "Today 12:55",
      doctor: "Dr. Aanya Verma",
      lat: 26.8436,
      lng: 80.9601,
    },
    {
      name: "Vikram Joshi",
      zone: "Ward B",
      severity: "stable",
      age: 47,
      consignmentType: "Consultation",
      department: "Neurology",
      schedule: "Today 15:20",
      doctor: "Dr. Rohan Mehta",
      lat: 26.8328,
      lng: 80.9469,
    },
    {
      name: "Ritika Srivastava",
      zone: "ICU",
      severity: "critical",
      age: 70,
      consignmentType: "Surgery",
      department: "General Surgery",
      schedule: "Today 13:40",
      doctor: "Dr. Isha Tandon",
      lat: 26.8555,
      lng: 80.9486,
    },
    {
      name: "Mohit Yadav",
      zone: "Lab",
      severity: "urgent",
      age: 56,
      consignmentType: "Diagnostics",
      department: "Lab / Pathology",
      schedule: "Today 12:25",
      doctor: "Tech Saurabh Jain",
      lat: 26.8513,
      lng: 80.9532,
    },
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
  try {
    if (tab === "overview" && !sessionStorage.getItem("eos_demo_emit_overview")) {
      sessionStorage.setItem("eos_demo_emit_overview", "1");
      emitOpsFromModule("ops", "Demo: Overview map", "Hex zones, fleet/patient markers, and zone list (Lucknow demo).", {
        demo: true,
      });
    }
    if (tab === "management" && !sessionStorage.getItem("eos_demo_emit_manage")) {
      sessionStorage.setItem("eos_demo_emit_manage", "1");
      emitOpsFromModule("ops", "Demo: Management", "Patient roster and staff duty views use embedded demo data.", {
        demo: true,
      });
    }
    if (tab === "operations" && !sessionStorage.getItem("eos_demo_emit_operations")) {
      sessionStorage.setItem("eos_demo_emit_operations", "1");
      emitOpsFromModule("ops", "Demo: Operations", "Feed items are demo-seeded; approve flows tie to Firestore when configured.", {
        demo: true,
      });
    }
    if (tab === "comms" && !sessionStorage.getItem("eos_demo_emit_comms")) {
      sessionStorage.setItem("eos_demo_emit_comms", "1");
      emitOpsFromModule("staff", "Demo: Comms", "Live messages appear when Firebase comms collections are enabled.", {
        demo: true,
      });
    }
    if (tab === "insights" && !sessionStorage.getItem("eos_demo_emit_insights")) {
      sessionStorage.setItem("eos_demo_emit_insights", "1");
      emitOpsFromModule("ops", "Demo: Report", "KPI cards and Gemma analytics use demo baselines.", { demo: true });
    }
    if (tab === "billings" && !sessionStorage.getItem("eos_demo_emit_billings")) {
      sessionStorage.setItem("eos_demo_emit_billings", "1");
      emitOpsFromModule(
        "ops",
        "Demo: Billings",
        "Incidents, status filters, quick bill tools; patient push uses Firestore demo_billing/patient_push when configured.",
        { demo: true }
      );
    }
  } catch (_) {}
  if (tab === "management") {
    const activeM = document.querySelector("#tab-management .mgmtNavBtn.active");
    switchMgmtView(activeM && activeM.dataset.mview ? activeM.dataset.mview : "patients");
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
  const fleetEl2 = document.getElementById("ovFleetCount2");
  if (fleetEl2) fleetEl2.textContent = String(demoState.fleet.length);
}

// Sync KPI values in Overview sidebar blocks too.
function refreshOverviewSideStats() {
  const fc = document.getElementById("ovFleetCount");
  if (fc) fc.textContent = String(demoState.fleet.length);
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
  filter: "all", // all | patients | staff
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
  const pat = opsState.items.filter((i) => i.type === "patients").length;
  const st = opsState.items.filter((i) => i.type === "staff").length;
  const elP = document.getElementById("opsKpiPatients");
  const elS = document.getElementById("opsKpiStaff");
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

  if (approveBtn) {
    approveBtn.disabled = it.status === "approved";
    approveBtn.hidden = false;
  }
  if (rejectBtn) rejectBtn.disabled = it.status === "rejected";
  if (holdBtn) holdBtn.textContent = it.status === "hold" ? "Unhold" : "Hold";
  if (askBtn) askBtn.disabled = !opsState.aiEnabled || it.status === "hold";

  opsHydrateAppointmentAssignUI(it);
}

function opsRandomToken() {
  try {
    const a = new Uint8Array(18);
    if (window.crypto && crypto.getRandomValues) crypto.getRandomValues(a);
    else for (let i = 0; i < a.length; i++) a[i] = Math.floor(Math.random() * 256);
    let s = "";
    for (let i = 0; i < a.length; i++) s += String.fromCharCode(a[i]);
    return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  } catch (_) {
    return "tok-" + Date.now() + "-" + Math.floor(Math.random() * 1e9);
  }
}

async function opsLoadDoctorsIntoSelect() {
  const sel = document.getElementById("opsApptDoctorSelect");
  if (!sel || !commsDb) return;
  sel.innerHTML = "";
  const opt0 = document.createElement("option");
  opt0.value = "";
  opt0.textContent = "Select staff…";
  sel.appendChild(opt0);
  try {
    const q = await commsDb.collection("users").where("role", "==", "Doctor").limit(40).get();
    q.docs.forEach((doc) => {
      const m = doc.data() || {};
      const onDuty = m.onDuty === true;
      const o = document.createElement("option");
      o.value = doc.id;
      o.textContent = (m.name || doc.id) + (onDuty ? " · on duty" : "");
      o.dataset.doctorName = m.name ? String(m.name) : "Doctor";
      sel.appendChild(o);
    });
  } catch (_) {
    const o = document.createElement("option");
    o.value = "";
    o.textContent = "(Could not load users — check Firestore rules/index)";
    sel.appendChild(o);
  }
}

function opsHydrateAppointmentAssignUI(it) {
  const bar = document.getElementById("opsApptAssignBar");
  const hint = document.getElementById("opsApptAssignHint");
  const sel = document.getElementById("opsApptDoctorSelect");
  const assignBtn = document.getElementById("opsApptApproveAssignBtn");
  const approveBtn = document.getElementById("opsApproveBtn");
  if (!bar) return;
  bar.style.display = "none";
  bar.hidden = true;
  if (hint) hint.textContent = "";
  if (sel) sel.innerHTML = "";
  if (assignBtn) assignBtn.disabled = false;

  const aid = it && it.payload && it.payload.appointmentId;
  if (!aid || !commsDb) return;

  (async () => {
    try {
      const ds = await commsDb.collection("appointments").doc(aid).get();
      if (!ds.exists) {
        if (hint) {
          bar.style.display = "block";
          bar.hidden = false;
          hint.textContent = "Appointment not found (it may have been deleted).";
        }
        return;
      }
      const d = ds.data() || {};
      const st = opsSafeStr(d.status);
      if (st === "pending_approval") {
        bar.style.display = "block";
        bar.hidden = false;
        if (approveBtn) approveBtn.hidden = true;
        if (hint) hint.textContent = "Patient app shows loading until you approve and assign staff.";
        await opsLoadDoctorsIntoSelect();
      }
    } catch (e) {
      if (hint) hint.textContent = "Could not load appointment: " + (e && e.message ? e.message : String(e));
      bar.style.display = "block";
      bar.hidden = false;
    }
  })();
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
    const apptId = it.payload && it.payload.appointmentId;
    if (apptId && commsDb) {
      commsDb
        .collection("appointments")
        .doc(apptId)
        .update({ status: "cancelled" })
        .catch(() => {});
    }
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

  const apptAssignBtn = document.getElementById("opsApptApproveAssignBtn");
  if (apptAssignBtn && !apptAssignBtn._opsApptBound) {
    apptAssignBtn._opsApptBound = true;
    apptAssignBtn.addEventListener("click", async () => {
      const it = opsState.items.find((x) => x.id === opsState.selectedId);
      const apptId = it && it.payload && it.payload.appointmentId;
      if (!apptId || !commsDb) return;
      const sel = document.getElementById("opsApptDoctorSelect");
      const uid = sel && sel.value;
      if (!uid) {
        alert("Select a staff member to assign.");
        return;
      }
      const opt = sel.selectedOptions && sel.selectedOptions[0];
      const doctorName = (opt && opt.dataset && opt.dataset.doctorName) || "Doctor";
      const now = new Date();
      const start = new Date(now.getTime() + 30 * 60000);
      const end = new Date(start.getTime() + 15 * 60000);
      apptAssignBtn.disabled = true;
      try {
        await commsDb
          .collection("appointments")
          .doc(apptId)
          .update({
            doctorUid: uid,
            doctorNameSnapshot: doctorName,
            status: "scheduled",
            receptionQrToken: opsRandomToken(),
            scheduledStart: firebase.firestore.Timestamp.fromDate(start),
            scheduledEnd: firebase.firestore.Timestamp.fromDate(end),
          });
        if (it) {
          it.status = "approved";
          if (it.payload) it.payload.status = "scheduled";
        }
        renderOpsFeed();
        renderOpsDetail(it);
        refreshOpsKpis();
      } catch (e) {
        alert("Could not approve: " + (e && e.message ? e.message : String(e)));
      } finally {
        apptAssignBtn.disabled = false;
      }
    });
  }
}

function seedOpsFeed() {
  if (opsState.items.length) return;
  const t0 = opsNowTs();
  const seeds = [
    {
      id: "DEMO-OPS-P1",
      type: "patients",
      title: "ER slot request — chest pain",
      summary: "Ravi Kumar · Emergency · consult_general · ETA triage 12m",
      status: "pending",
      payload: {
        appointmentId: "demo-appt-seed-1",
        patientName: "Ravi Kumar",
        department: "Emergency",
        symptoms: "Chest pain, diaphoresis",
      },
    },
    {
      id: "DEMO-OPS-P2",
      type: "patients",
      title: "Follow-up — ortho",
      summary: "Aarav Sharma · General · follow-up · pending assignment",
      status: "pending",
      payload: {
        appointmentId: "demo-appt-seed-2",
        patientName: "Aarav Sharma",
        department: "General",
        symptoms: "Post-fracture follow-up",
      },
    },
    {
      id: "DEMO-OPS-S1",
      type: "staff",
      title: "Shift handoff reminder",
      summary: "ICU · Dr. Isha Tandon ↔ Dr. Rohan Mehta · 18:30",
      status: "pending",
      payload: { ward: "ICU", handoffTime: "18:30" },
    },
    {
      id: "DEMO-OPS-S2",
      type: "staff",
      title: "On-call acknowledgment",
      summary: "Cardiology on-call (Dr. Rohan Mehta) — confirm pager test",
      status: "hold",
      payload: { role: "Cardiology on-call" },
    },
    {
      id: "DEMO-OPS-O1",
      type: "ops",
      title: "Fleet — EMS-LKO-09 reroute",
      summary: "Hazratganj congestion · +4m to Zone 07 · auto-notify dispatch",
      status: "pending",
      payload: { unit: "EMS-LKO-09", zone: "Zone 07" },
    },
    {
      id: "DEMO-OPS-O2",
      type: "ops",
      title: "Bed pressure — ER",
      summary: "ER bays 85% full · suggest surge protocol (demo)",
      status: "approved",
      payload: { ward: "ER", occupancyPct: 85 },
    },
  ];
  seeds.forEach((s, idx) => {
    opsState.items.push({
      id: s.id,
      type: s.type,
      title: s.title,
      summary: s.summary,
      createdAt: t0 - idx * 75000,
      status: s.status,
      payload: s.payload || {},
      aiSuggestion: null,
    });
  });
  opsState.selectedId = opsState.items[0] ? opsState.items[0].id : "";
  renderOpsFeed();
  renderOpsDetailById(opsState.selectedId);
  refreshOpsKpis();
}

const DEMO_ADMIN_ALERTS = [
  { id: "da-1", text: "Demo: 2 patient requests awaiting Operations approval." },
  { id: "da-2", text: "Demo: EMS-LKO-03 available — assign to Zone 12 surge." },
  { id: "da-3", text: "Demo: Staff handoff ICU at 18:30 — confirm in Manage › Staff." },
];

function renderDemoAdminAlertStrip() {
  const host = document.getElementById("demoAlertStrip");
  if (!host) return;
  let dismissed = {};
  try {
    dismissed = JSON.parse(sessionStorage.getItem("eos_demo_alerts_dismissed") || "{}") || {};
  } catch (_) {
    dismissed = {};
  }
  const visible = DEMO_ADMIN_ALERTS.filter((a) => !dismissed[a.id]);
  if (!visible.length) {
    host.innerHTML = "";
    host.hidden = true;
    return;
  }
  host.hidden = false;
  host.innerHTML = "";
  const title = document.createElement("div");
  title.className = "demoAlertStripTitle";
  title.textContent = "Live demo alerts";
  host.appendChild(title);
  visible.forEach((a) => {
    const row = document.createElement("div");
    row.className = "demoAlertStripRow";
    const msg = document.createElement("span");
    msg.className = "demoAlertStripText";
    msg.textContent = a.text;
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "secondary demoAlertStripDismiss";
    btn.textContent = "Dismiss";
    btn.addEventListener("click", () => {
      dismissed[a.id] = true;
      try {
        sessionStorage.setItem("eos_demo_alerts_dismissed", JSON.stringify(dismissed));
      } catch (_) {}
      renderDemoAdminAlertStrip();
    });
    row.appendChild(msg);
    row.appendChild(btn);
    host.appendChild(row);
  });
}

bindOpsActionsOnce();
seedOpsFeed();
renderOpsFeed();
renderOpsDetailById(opsState.selectedId);
refreshOpsKpis();
renderDemoAdminAlertStrip();

// ── Management side navigation (Patients / Staff) ──
const mgmtBtns = Array.from(document.querySelectorAll(".mgmtNavBtn"));
const mgmtViews = {
  patients: document.getElementById("mview-patients"),
  staff: document.getElementById("mview-staff"),
};

function switchMgmtView(name) {
  mgmtBtns.forEach((b) => b.classList.toggle("active", b.dataset.mview === name));
  Object.entries(mgmtViews).forEach(([k, el]) => el && el.classList.toggle("active", k === name));
  const staffBlock = document.getElementById("mgmtStaffBlock");
  const patientBlock = document.getElementById("mgmtPatientsBlock");
  if (staffBlock) staffBlock.hidden = name !== "staff";
  if (patientBlock) patientBlock.hidden = name !== "patients";
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
switchMgmtView("patients");

// ── Management tab ────────────────────────────────────────────
const staffOnDutyDemo = demoState.staff.filter((s) => s.onDuty).length;
let staffCount = staffOnDutyDemo;
let fleetCount = 0;
let dispatched = 0;
let emergencyCount = 0;

const staffCountEl   = document.getElementById("staffCount");
const fleetCountEl   = document.getElementById("fleetCount");
const fleetSubEl     = document.getElementById("fleetSub");
if (staffCountEl) staffCountEl.textContent = String(staffCount);
setBar("staffBar", Math.min(100, Math.round(staffCount / 58 * 100)));

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
      const slot = p.schedule ? " · " + p.schedule : "";
      const cons = p.consignmentType ? " · " + p.consignmentType : "";
      li.textContent = p.name + " · " + p.zone + " · " + p.severity + cons + slot;
      li.style.cursor = "pointer";
      li.setAttribute("role", "button");
      li.setAttribute("tabindex", "0");
      li.setAttribute("aria-label", "View patient " + p.name);
      li.addEventListener("click", () => selectPatient(p));
      li.addEventListener("keydown", (e) => {
        if (e.key === "Enter") selectPatient(p);
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
    const hay = (
      p.name +
      " " +
      p.zone +
      " " +
      p.severity +
      " " +
      p.age +
      " " +
      (p.consignmentType || "") +
      " " +
      (p.department || "") +
      " " +
      (p.schedule || "") +
      " " +
      (p.doctor || "")
    ).toLowerCase();
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
    row.dataset.patientName = p.name;
    row.innerHTML =
      "<div class=\"staffRowTop\">" +
      "<div class=\"staffName\"></div>" +
      "<div class=\"staffTag\"></div>" +
      "</div>" +
      "<div class=\"staffSub\"></div>";
    row.querySelector(".staffName").textContent = p.name;
    row.querySelector(".staffTag").textContent = String(p.consignmentType || p.severity || "—").toUpperCase();
    row.querySelector(".staffSub").textContent =
      (p.zone || "—") +
      " · " +
      (p.department || "—") +
      " · " +
      (p.schedule || "—") +
      " · " +
      (p.severity || "—") +
      " · age " +
      p.age;
    row.addEventListener("click", () => selectPatient(p));
    listEl.appendChild(row);
  });

  if (selectedPatientName && !filtered.some((p) => p.name === selectedPatientName)) {
    selectedPatientName = "";
  }
  if (!selectedPatientName && filtered.length) {
    selectPatient(filtered[0]);
  } else {
    highlightPatientRow(selectedPatientName);
  }
}

document.getElementById("patientSearch")?.addEventListener("input", renderMgmtPatientRoster);

// (Ward view removed from Manage; ward data still used in Overview/Operations.)

// ── Management: staff roster + details ─────────────────────────
let selectedStaffId = "";
let selectedPatientName = "";

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
  document.querySelectorAll("#mgmtStaffList .staffRowClick").forEach((n) => {
    n.classList.toggle("staffRowActive", !!staffId && n.dataset.staffId === staffId);
  });
}

function highlightPatientRow(patientName) {
  document.querySelectorAll("#mgmtPatientRoster .staffRowClick").forEach((n) => {
    n.classList.toggle("staffRowActive", !!patientName && n.dataset.patientName === patientName);
  });
}

function selectPatient(p) {
  if (!p) return;
  selectedPatientName = p.name;
  highlightPatientRow(selectedPatientName);
  renderMgmtDetails("patient", p);
}

function renderMgmtDetails(kind, payload) {
  if (kind === "fleet") {
    return;
  }

  if (kind === "staff") {
    const det = document.getElementById("mgmtStaffDetail");
    const ph = document.getElementById("mgmtStaffDetailPlaceholder");
    if (!det) return;
    if (ph) ph.hidden = true;
    det.hidden = false;

    const s = payload;
    const now = Date.now();
    const uptime = s.onDuty ? formatUptime(now - (s.since || now)) : "—";
    const last = s.lastCheckIn
      ? new Date(s.lastCheckIn).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      : "—";
    det.innerHTML =
      "<div class=\"detailsBlocks\">" +
      "<div class=\"detailsGrid\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Name</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
      s.name +
      "</span></div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Status</div><div class=\"detailsValue\">" +
      (s.onDuty ? "Online (on duty)" : "Off duty") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Ward</div><div class=\"detailsValue\">" +
      (s.ward || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Uptime</div><div class=\"detailsValue\">" +
      uptime +
      "</div></div>" +
      "</div>" +
      "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Duty</div><div class=\"detailsValue\">" +
      (s.duty || s.role || "—") +
      "</div></div>" +
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
      "<div class=\"detailsBlock\" style=\"margin-top:10px\"><div class=\"detailsLabel\">Contact</div><div class=\"detailsValue\">" +
      (s.contact || "—") +
      "</div></div>" +
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
    const det = document.getElementById("mgmtPatientDetail");
    const ph = document.getElementById("mgmtPatientDetailPlaceholder");
    if (!det) return;
    if (ph) ph.hidden = true;
    det.hidden = false;

    const p = payload;
    det.innerHTML =
      "<div class=\"detailsBlocks\">" +
      "<div class=\"detailsGrid\">" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Name</div><div class=\"detailsValue\"><span class=\"detailsValueStrong\">" +
      p.name +
      "</span></div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Consignment</div><div class=\"detailsValue\">" +
      (p.consignmentType || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Severity</div><div class=\"detailsValue\">" +
      p.severity +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Zone</div><div class=\"detailsValue\">" +
      p.zone +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Department</div><div class=\"detailsValue\">" +
      (p.department || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Scheduled</div><div class=\"detailsValue\">" +
      (p.schedule || "—") +
      "</div></div>" +
      "<div class=\"detailsBlock\"><div class=\"detailsLabel\">Assigned</div><div class=\"detailsValue\">" +
      (p.doctor || "—") +
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
  }
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
    // Manage → Staff should show only online staff (demo == onDuty).
    if (!s.onDuty) return false;
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

  if (selectedStaffId && !filtered.some((s) => s.id === selectedStaffId)) {
    selectedStaffId = "";
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
    row.querySelector(".staffTag").textContent = "ONLINE";
    const uptime = s.since ? formatUptime(Date.now() - s.since) : "—";
    const duty = s.duty || s.role || "—";
    row.querySelector(".staffSub").textContent =
      (s.ward ? s.ward + " · " : "") + duty + " · " + uptime + " · " + (s.assignment || "—");
    row.addEventListener("click", () => selectStaff(s.id));
    listEl.appendChild(row);
  });

  if (!selectedStaffId) {
    const first = filtered[0];
    if (first) selectStaff(first.id);
  }

  highlightStaffRow(selectedStaffId);
}

const staffSearchEl = document.getElementById("staffSearch");
staffSearchEl && staffSearchEl.addEventListener("input", () => renderMgmtStaffList());

// Fleet actions removed from admin panel.

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
let selectedHexZoneName = "";
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

// Lucknow overview hex grid (shared spacing for zone centers + polygon size).
const LUCKNOW_HEX_SPACING_M = 520;
const LUCKNOW_HEX_DISK_RING = 2;

function buildLucknowHexZones() {
  const centerLat = 26.8467;
  const centerLng = 80.9462;
  const hexSpacingM = LUCKNOW_HEX_SPACING_M;
  const cells = hexDiskRadius(LUCKNOW_HEX_DISK_RING);
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
    const name = "Zone " + String(i + 1).padStart(2, "0");
    const inflow = inflows[i] != null ? inflows[i] : 16 + i;
    const recentAdm = Math.max(0, Math.round(inflow / 10) + ((i % 3) - 1));
    const admFrom = ["ER Bay 2", "Trauma Desk", "Ward A", "Ward C", "ICU", "Registration"].at(i % 6);
    return {
      q,
      r,
      lat,
      lng,
      name,
      inflow24h: inflow,
      admissions6h: recentAdm,
      latestAdmissionFrom: admFrom + " · " + (10 + (i % 40)) + " min ago",
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
    fillOpacity: 0.16,
    className: "hexMapCell",
  };
}

function hexTierFilterOn(id) {
  const el = document.getElementById(id);
  return el ? el.checked : true;
}

function hexStyleForZone(z) {
  const hi = hexTierFilterOn("hexFilterHigh");
  const lo = hexTierFilterOn("hexFilterLow");
  const base = { className: "hexMapCell" };
  if (selectedHexZoneName && z.name === selectedHexZoneName) {
    return Object.assign(base, {
      color: "#35c97a",
      weight: 2.5,
      fillColor: "#35c97a",
      fillOpacity: 0.5,
    });
  }
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
    fillOpacity: 0.16,
  });
}

function refreshHexStyles() {
  if (!hexPolyLayer) return;
  hexPolyLayer.eachLayer((layer) => {
    const z = layer._hexZone;
    if (z) layer.setStyle(hexStyleForZone(z));
  });
}

function highlightZoneRow(name) {
  document.querySelectorAll(".zoneRow").forEach((n) => {
    n.classList.toggle("zoneRowActive", !!name && n.dataset.zoneName === name);
  });
}

function setSelectedZone(z) {
  if (!z) return;
  selectedHexZoneName = z.name;
  highlightZoneRow(selectedHexZoneName);
  refreshHexStyles();
  showHexZonePanel(z);

  const n = document.getElementById("ovSelectedZoneName");
  if (n) n.textContent = z.name || "—";
  const t = document.getElementById("ovSelectedZoneTier");
  if (t) t.textContent = z.tier === "high" ? "High" : z.tier === "low" ? "Low" : "Mid";
  const i = document.getElementById("ovSelectedZoneInflow");
  if (i) i.textContent = String(z.inflow24h ?? "—");
}

function renderOverviewZoneList() {
  const listEl = document.getElementById("ovZoneList");
  if (!listEl) return;
  listEl.innerHTML = "";

  if (!Array.isArray(lucknowHexZones) || lucknowHexZones.length === 0) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.textContent = "Loading zones…";
    listEl.appendChild(empty);
    return;
  }

  const zones = [...lucknowHexZones].sort((a, b) => String(a.name).localeCompare(String(b.name)));
  if (!selectedHexZoneName && zones.length) {
    // Pick a sensible default so the UI isn't empty.
    setSelectedZone(zones[Math.floor(zones.length / 2)]);
  }
  zones.forEach((z) => {
    const row = document.createElement("div");
    row.className = "zoneRow";
    row.dataset.zoneName = z.name;
    row.setAttribute("role", "button");
    row.setAttribute("tabindex", "0");
    row.setAttribute("aria-label", "Select " + z.name);
    row.innerHTML =
      "<div class=\"zoneRowTop\">" +
      "<div class=\"zoneName\"></div>" +
      "<div class=\"zoneTag\"></div>" +
      "</div>" +
      "<div class=\"zoneSub\"></div>";
    row.querySelector(".zoneName").textContent = z.name;
    row.querySelector(".zoneTag").textContent =
      z.tier === "high" ? "HIGH" : z.tier === "low" ? "LOW" : "MID";
    row.querySelector(".zoneSub").textContent = "Inflow 24h: " + String(z.inflow24h ?? "—");

    function open() {
      setSelectedZone(z);
      if (osmMain && window.L) {
        try {
          osmMain.setView([z.lat, z.lng], Math.max(osmMain.getZoom(), 12));
        } catch (_) {}
      }
    }
    row.addEventListener("click", open);
    row.addEventListener("keydown", (e) => {
      if (e.key === "Enter") open();
    });
    listEl.appendChild(row);
  });

  highlightZoneRow(selectedHexZoneName);
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
  const ac = document.getElementById("hexZoneAdmCount");
  if (ac) ac.textContent = String(z.admissions6h ?? "—") + " (demo)";
  const af = document.getElementById("hexZoneAdmFrom");
  if (af) af.textContent = String(z.latestAdmissionFrom || "—");
  const pop = document.getElementById("hexZonePop");
  if (pop) pop.textContent = z.populationBand + " residents (model)";
  const comp = document.getElementById("hexZoneComplaints");
  if (comp) comp.textContent = z.complaints.join(" · ");
  const dm = document.getElementById("hexZoneDemo");
  if (dm) dm.textContent = z.demoBlurb;
}

function addHexGridToMainMap(map) {
  ensureLeafletGlobal();
  if (!map || !window.L) return;
  lucknowHexZones = buildLucknowHexZones();
  const hexSpacingM = LUCKNOW_HEX_SPACING_M;
  if (hexPolyLayer) {
    try {
      map.removeLayer(hexPolyLayer);
    } catch (_) {}
  }
  hexPolyLayer = L.layerGroup().addTo(map);
  const bounds = L.latLngBounds([]);
  lucknowHexZones.forEach((z) => {
    const verts = hexVerticesPointy(z.lat, z.lng, hexSpacingM * 0.97);
    const poly = L.polygon(verts, hexStyleForZone(z)).addTo(hexPolyLayer);
    poly._hexZone = z;
    poly.on("click", (e) => {
      L.DomEvent.stopPropagation(e);
      setSelectedZone(z);
    });
    try {
      bounds.extend(poly.getBounds());
    } catch (_) {}
  });
  try {
    if (bounds.isValid()) map.fitBounds(bounds, { padding: [16, 16] });
  } catch (_) {}

  renderOverviewZoneList();
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

function addLeafletMarkers(map, arr, opts) {
  ensureLeafletGlobal();
  if (!map || !window.L) return;
  clearLeafletMarkers(arr);
  const o = opts || {};
  const includeFleet = o.includeFleet !== false;
  const includePatients = o.includePatients !== false;

  demoMarkers.forEach((p) => {
    if (p.type === "fleet" && !includeFleet) return;
    if (p.type === "patient" && !includePatients) return;
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

function ensureLeafletGlobal() {
  // Leaflet 1.9 dist bundled here attaches to `window.leaflet`, not `window.L`.
  if (typeof window !== "undefined" && !window.L && window.leaflet) {
    window.L = window.leaflet;
  }
}

function initLeafletMap(id, errorId, useDarkBasemap) {
  ensureLeafletGlobal();
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
  ensureLeafletGlobal();
  osmMain = initLeafletMap("mapMain", "mapError", false);
  osmMgmt = initLeafletMap("mapMgmt", "mapErrorMgmt", false);
  if (osmMain) {
    addLeafletMarkers(osmMain, osmMarkersMain, { includeFleet: true, includePatients: true });
    addHexGridToMainMap(osmMain);
  }
  // Manage map: keep fleet + patients.
  if (osmMgmt) addLeafletMarkers(osmMgmt, osmMarkersMgmt, { includeFleet: false, includePatients: true });
  renderMgmtFleetSidebar();
  renderMgmtStaffList();
  tryResizeMapsSoon();
  [120, 450, 900].forEach((ms) => setTimeout(() => tryResizeMapsSoon(), ms));
}

// Leaflet loads via script tag; run after DOM is ready
window.addEventListener("load", () => {
  initOpenSourceMaps();
});

// ── Insights tab – Gemma 4 via Gemini API ────────────────────
let geminiApiKey = "";

const GEMINI_KEY_STORAGE = "emergencyos_gemini_key";

function resolveInitialGeminiKey() {
  const fromWindow =
    typeof window.__GEMINI_API_KEY__ === "string" ? window.__GEMINI_API_KEY__.trim() : "";
  let fromStorage = "";
  try {
    fromStorage = (localStorage.getItem(GEMINI_KEY_STORAGE) || "").trim();
  } catch (_) {}
  return fromWindow || fromStorage;
}

const chatListEl = document.getElementById("chatList");

function applyGeminiKeyToUi(k, announce) {
  geminiApiKey = k;
  const keyEl = document.getElementById("gemmaApiKey");
  if (keyEl) keyEl.value = k;
  if (announce && chatListEl) {
    addChat("System", "Gemini API key loaded. Gemma 4 is active.");
  }
}

const saveKeyBtn = document.getElementById("saveKeyBtn");
saveKeyBtn && saveKeyBtn.addEventListener("click", () => {
  const keyEl = document.getElementById("gemmaApiKey");
  const k = (keyEl ? keyEl.value : "").trim();
  if (k) {
    try {
      localStorage.setItem(GEMINI_KEY_STORAGE, k);
    } catch (_) {}
    applyGeminiKeyToUi(k, false);
    addChat("System", "Gemini API key saved. Gemma 4 is now active.");
  } else {
    addChat("System", "Please paste your Gemini API key first.");
  }
});

const _initialGemini = resolveInitialGeminiKey();
if (_initialGemini) {
  geminiApiKey = _initialGemini;
}

function addChat(role, text) {
  const li = document.createElement("li");
  li.className = role === "You" ? "user" : role === "thinking" ? "agent thinking" : "agent";
  li.textContent = (role === "thinking" ? "" : role + ": ") + text;
  chatListEl.appendChild(li);
  document.getElementById("chatLog").scrollTop = 99999;
}

if (chatListEl) {
  const keyElBoot = document.getElementById("gemmaApiKey");
  if (keyElBoot && geminiApiKey) keyElBoot.value = geminiApiKey;
  addChat("Gemma 4", "Ready. Ask me about ICU trends, billing anomalies, fleet efficiency, or patient demographics.");
  if (geminiApiKey) {
    addChat("System", "Gemini API key loaded from config or saved session. Gemma 4 is active.");
  }
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
const BILLING_DEMO_INCIDENTS = [
  {
    id: "INC-DEMO-001",
    title: "Demo incident · Cardiac consultation",
    status: "pending",
    patient: "Priya Sharma",
    mrn: "MRN-10492",
    openedAt: "2026-04-10 09:12",
    department: "Cardiology / ER",
    chiefComplaint: "Chest tightness, palpitations",
    triage: "ESI-2",
    billRef: "BL-2026-0091",
    amountInr: 8450,
    notes: "Initial consult and ECG completed. Labs and echo scheduled; final amount may change.",
  },
  {
    id: "INC-2026-0148",
    title: "Post-operative follow-up",
    status: "completed",
    patient: "Ravi Kumar",
    mrn: "MRN-10102",
    openedAt: "2026-04-09 14:40",
    department: "General Surgery",
    chiefComplaint: "Wound check",
    triage: "ESI-4",
    billRef: "BL-2026-0088",
    amountInr: 2200,
    notes: "Bill cleared by finance and admin. Patient discharged with instructions.",
  },
  {
    id: "INC-2026-0140",
    title: "Insurance partial · Ortho imaging",
    status: "partially_completed",
    patient: "Meera Singh",
    mrn: "MRN-10355",
    openedAt: "2026-04-08 11:05",
    department: "Orthopedics",
    chiefComplaint: "Knee injury — MRI review",
    triage: "ESI-3",
    billRef: "BL-2026-0092",
    amountInr: 18900,
    notes: "Patient share collected. TPA pending for MRI component; finance flagged partial clearance.",
  },
];

const BILLING_STATUS_LABEL = {
  pending: "Pending",
  completed: "Completed",
  partially_completed: "Partially completed",
};

let billingIncidentFilter = "all";
let billingSelectedIncidentId = null;

function billingEscapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function billingStatusBadgeClass(status) {
  if (status === "completed") return "badge green";
  if (status === "partially_completed") return "badge amber";
  return "badge red";
}

function getFilteredBillingIncidents() {
  if (billingIncidentFilter === "all") return BILLING_DEMO_INCIDENTS;
  return BILLING_DEMO_INCIDENTS.filter((i) => i.status === billingIncidentFilter);
}

function renderBillingIncidentList() {
  const listEl = document.getElementById("billingIncidentList");
  if (!listEl) return;
  listEl.innerHTML = "";
  const items = getFilteredBillingIncidents();
  items.forEach((inc) => {
    const div = document.createElement("div");
    div.className = "sideUnit sideUnitClick billingIncidentRow";
    div.setAttribute("role", "listitem");
    div.dataset.incidentId = inc.id;
    if (billingSelectedIncidentId === inc.id) div.classList.add("sideUnitActive");
    div.innerHTML =
      '<div class="sideUnitTitle">' +
      billingEscapeHtml(inc.title) +
      '</div><div class="sideUnitSub">' +
      billingEscapeHtml(inc.patient) +
      ' · <span class="' +
      billingStatusBadgeClass(inc.status) +
      '" style="font-size:10px;padding:2px 8px">' +
      billingEscapeHtml(BILLING_STATUS_LABEL[inc.status] || inc.status) +
      "</span></div>";
    div.addEventListener("click", () => selectBillingIncident(inc.id));
    listEl.appendChild(div);
  });
  if (!items.length) {
    const empty = document.createElement("p");
    empty.className = "muted";
    empty.style.fontSize = "12px";
    empty.textContent = "No incidents for this filter.";
    listEl.appendChild(empty);
  }
}

function selectBillingIncident(id) {
  billingSelectedIncidentId = id;
  const inc = BILLING_DEMO_INCIDENTS.find((x) => x.id === id);
  const badgeEl = document.getElementById("billingSelectedBadge");
  const headingEl = document.getElementById("billingDetailHeading");
  const placeholderEl = document.getElementById("billingDetailPlaceholder");
  const bodyEl = document.getElementById("billingDetailBody");
  const actionsEl = document.getElementById("billingDetailActions");
  renderBillingIncidentList();

  if (!inc || !bodyEl || !placeholderEl || !headingEl || !actionsEl) return;

  headingEl.textContent = inc.title;
  placeholderEl.hidden = true;
  bodyEl.hidden = false;
  actionsEl.hidden = false;
  if (badgeEl) {
    badgeEl.textContent = BILLING_STATUS_LABEL[inc.status] || inc.status;
    badgeEl.className =
      "badge " + (inc.status === "completed" ? "green" : inc.status === "partially_completed" ? "amber" : "red");
  }

  bodyEl.innerHTML =
    '<div class="fleetDetailGrid">' +
    '<div><div class="fleetDetailLabel">Incident ID</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.id) +
    "</div></div>" +
    '<div><div class="fleetDetailLabel">MRN</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.mrn) +
    "</div></div>" +
    '<div><div class="fleetDetailLabel">Patient</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.patient) +
    "</div></div>" +
    '<div><div class="fleetDetailLabel">Opened</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.openedAt) +
    "</div></div>" +
    "</div>" +
    '<div class="fleetDetailBlock"><div class="fleetDetailLabel">Department</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.department) +
    "</div></div>" +
    '<div class="fleetDetailBlock"><div class="fleetDetailLabel">Chief complaint</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.chiefComplaint) +
    "</div></div>" +
    '<div class="fleetDetailGrid">' +
    '<div><div class="fleetDetailLabel">Triage</div><div class="fleetDetailValue fleetDetailValue--emg">' +
    billingEscapeHtml(inc.triage) +
    "</div></div>" +
    '<div><div class="fleetDetailLabel">Bill ref / preview</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.billRef) +
    " · INR " +
    billingEscapeHtml(String(inc.amountInr)) +
    "</div></div>" +
    "</div>" +
    '<div class="fleetDetailBlock"><div class="fleetDetailLabel">Notes</div><div class="fleetDetailValue">' +
    billingEscapeHtml(inc.notes) +
    "</div></div>";

  const hintEl = document.getElementById("billingSendPatientHint");
  if (hintEl) hintEl.textContent = "";
}

async function sendBillingRequestToPatientApp() {
  const inc = BILLING_DEMO_INCIDENTS.find((x) => x.id === billingSelectedIncidentId);
  const hintEl = document.getElementById("billingSendPatientHint");
  if (!inc) {
    if (hintEl) hintEl.textContent = "Select an incident first.";
    return;
  }
  const payload = {
    incidentId: inc.id,
    title: inc.title,
    patientLabel: inc.patient,
    billRef: inc.billRef,
    amountInr: inc.amountInr,
    status: inc.status,
    message: "Hospital billing: please review " + inc.billRef + " (" + inc.title + ").",
    token: String(Date.now()),
    sentAtIso: new Date().toISOString(),
  };

  if (!commsDb || !window.firebase || !firebase.firestore) {
    if (hintEl) hintEl.textContent = "Firebase not available — logged locally only.";
    addBillLog("Patient app push (offline demo): " + inc.id + " — " + payload.message);
    try {
      localStorage.setItem("eos_demo_billing_push", JSON.stringify(payload));
    } catch (_) {}
    return;
  }

  try {
    await commsDb.collection("demo_billing").doc("patient_push").set({
      ...payload,
      sentAt: firebase.firestore.FieldValue.serverTimestamp(),
    });
    if (hintEl) hintEl.textContent = "Sent to patient channel (demo_billing / patient_push).";
    addBillLog("Patient app push: " + inc.id + " via Firestore.");
  } catch (e) {
    const msg = e && e.message ? e.message : String(e);
    if (hintEl) hintEl.textContent = "Firestore error — check rules. Logged locally.";
    addBillLog("Patient app push failed: " + msg);
    try {
      localStorage.setItem("eos_demo_billing_push", JSON.stringify(payload));
    } catch (_) {}
  }
}

document.querySelectorAll(".billingFilterBtn").forEach((btn) => {
  btn.addEventListener("click", () => {
    billingIncidentFilter = btn.dataset.bfilter || "all";
    document.querySelectorAll(".billingFilterBtn").forEach((b) => b.classList.toggle("active", b === btn));
    const stillVisible = getFilteredBillingIncidents().some((i) => i.id === billingSelectedIncidentId);
    if (!stillVisible) {
      billingSelectedIncidentId = null;
      const placeholderEl = document.getElementById("billingDetailPlaceholder");
      const bodyEl = document.getElementById("billingDetailBody");
      const actionsEl = document.getElementById("billingDetailActions");
      const headingEl = document.getElementById("billingDetailHeading");
      const badgeEl = document.getElementById("billingSelectedBadge");
      if (headingEl) headingEl.textContent = "No incident selected";
      if (placeholderEl) placeholderEl.hidden = false;
      if (bodyEl) bodyEl.hidden = true;
      if (actionsEl) actionsEl.hidden = true;
      if (badgeEl) {
        badgeEl.textContent = "None";
        badgeEl.className = "badge muted";
      }
    }
    renderBillingIncidentList();
  });
});

const billingSendPatientBtn = document.getElementById("billingSendPatientBtn");
billingSendPatientBtn && billingSendPatientBtn.addEventListener("click", () => {
  sendBillingRequestToPatientApp();
});

renderBillingIncidentList();

let billId = 90;
let currentBill = "";
let financeOk = false;
const billLogsEl = document.getElementById("billLogs");
function addBillLog(text) {
  if (!billLogsEl) return;
  const li = document.createElement("li");
  li.textContent = "[" + new Date().toLocaleTimeString() + "] " + text;
  billLogsEl.prepend(li);
}

/** Static demo lines shown when Billings tab loads (newest first after seed). */
function seedDemoBillLogs() {
  if (!billLogsEl) return;
  const lines = [
    "[06:12:08] Night batch: queued 12 OPD settlements for finance review",
    "[07:45:22] Insurance pre-auth received for BL-2026-0074 (cardiology)",
    "[08:20:01] Created BL-2026-0088 for Vikram Joshi (Appendectomy) INR 185000",
    "[08:55:33] Finance approved BL-2026-0088",
    "[09:10:14] Admin finalised BL-2026-0088 — cleared",
    "[09:42:50] Created BL-2026-0089 for Sonia Reddy (CT thorax) INR 12400",
    "[10:05:19] Finance approved BL-2026-0089",
    "[10:48:02] Flagged BL-2026-0077 — missing ICD-10 on discharge summary",
    "[11:22:41] Refund initiated BL-2026-0062 duplicate charge (INR 3200)",
    "[11:58:17] UPI settlement reconciled: 28 bills · INR 4.2L",
  ];
  for (let i = lines.length - 1; i >= 0; i -= 1) {
    const li = document.createElement("li");
    li.textContent = lines[i];
    billLogsEl.prepend(li);
  }
}
seedDemoBillLogs();

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
    if (!window.firebase) return null;
    // Preferred: on Firebase Hosting, /__/firebase/init.js auto-initializes firebase.
    // Fallback: allow legacy builds to set window.__FIREBASE_CONFIG__.
    if (!firebase.apps.length) {
      if (window.__FIREBASE_CONFIG__) {
        firebase.initializeApp(window.__FIREBASE_CONFIG__);
      } else {
        return null;
      }
    }
    return firebase.firestore();
  } catch (_) {
    return null;
  }
}
commsDb = initCommsFirebaseIfPossible();

// ── Operations: realtime from Firestore ─────────────────────────
let opsUnsubAppointments = null;
let opsApptInitialLoad = true;
const opsSeen = {
  appointmentAdd: new Set(),
  checkIn: new Set(),
};

function opsSafeStr(x) {
  return x == null ? "" : String(x);
}

function emitPendingAppointmentOps(id, data) {
  const pName = opsSafeStr(data.patientNameSnapshot) || opsSafeStr(data.patientName) || "Patient";
  const dept = opsSafeStr(data.department) || "—";
  const symptoms = opsSafeStr(data.symptoms);
  const summary = symptoms ? pName + " — " + symptoms.slice(0, 80) : pName + " — awaiting admin assign";
  emitOpsFromModule(
    "patients",
    "Slot request: " + dept,
    summary,
    Object.assign({ appointmentId: id }, data)
  );
}

function opsSubscribeAppointmentsIfPossible() {
  if (!commsDb) return;
  if (opsUnsubAppointments) return;

  try {
    opsUnsubAppointments = commsDb
      .collection("appointments")
      .orderBy("createdAt", "desc")
      .limit(60)
      .onSnapshot(
        (snap) => {
          if (opsApptInitialLoad) {
            opsApptInitialLoad = false;
            snap.docs.forEach((doc) => {
              const id = doc.id;
              const data = doc.data() || {};
              const status = opsSafeStr(data.status);
              if (status === "pending_approval" && !opsSeen.appointmentAdd.has(id)) {
                opsSeen.appointmentAdd.add(id);
                emitPendingAppointmentOps(id, data);
              }
            });
            return;
          }

          snap.docChanges().forEach((chg) => {
            const id = chg.doc.id;
            const data = chg.doc.data() || {};
            const status = opsSafeStr(data.status);

            if (chg.type === "added" && !opsSeen.appointmentAdd.has(id)) {
              if (status === "pending_approval") {
                opsSeen.appointmentAdd.add(id);
                emitPendingAppointmentOps(id, data);
              }
            }

            if (chg.type !== "removed") {
              if (status === "checked_in" && !opsSeen.checkIn.has(id)) {
                opsSeen.checkIn.add(id);
                const pName = opsSafeStr(data.patientNameSnapshot) || "Patient";
                const docName = opsSafeStr(data.doctorNameSnapshot) || "Doctor";
                emitOpsFromModule(
                  "patients",
                  "Reception check-in",
                  pName + " checked-in for " + docName,
                  Object.assign({ appointmentId: id }, data)
                );
              }
            }
          });
        },
        (_) => {
          // If query fails (missing index/field), keep demo feed instead of crashing.
        }
      );
  } catch (_) {
    // No-op
  }
}

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
opsSubscribeAppointmentsIfPossible();

