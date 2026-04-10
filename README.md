# EmergencyOS – InnovationX

> real-time emergency operations platform for Goel Hospital, Lucknow.
> built during a hackathon sprint. still rough in a few places but core flows work.

this is a full-stack demo that ties together an admin ops panel, a patient-facing app, and a staff/fleet app — all talking through Firebase. the idea was: what if a mid-size hospital could get a situation-room style dashboard without paying for enterprise software?

---

## live links

| what | url |
|------|-----|
| admin panel | https://emergencyos-innovationx.web.app |
| patient app | https://emergencyos-innovationx-patient.web.app |
| staff app | https://emergencyos-innovation-staff.web.app |
| firebase console | https://console.firebase.google.com/project/emergencyos-innovationx |
| github | https://github.com/shikhar1809/emergencyOS_InnotionX |

---

## what it does

**admin panel** (`web/`) — the main ops dashboard. has a few screens:
- **Overview** — leaflet map of Lucknow with hex zone grid (zones A–S). click a zone and you get demographics, patient forecast, clinical mix for that area. the selected hex turns green on the map
- **Manage** — patient roster and staff on-duty list. can mark staff on/off duty, escalate patients, call nurse etc.
- **Operations** — human-in-the-loop feed. incoming slot requests from the patient app show up here, admin approves/rejects with optional Gemini suggestion
- **Billings** — 24 demo billing incidents across various departments. can push a billing notice directly to the patient app. quick-bill tool with finance → admin approval flow
- **Report** — KPI cards, 7-day export, shift handoffs, Gemma 4 analytics chat (needs Gemini API key)
- **Comms** — internal messaging over Firestore, presence tracking, channel-based (#announcements, #alerts etc)

**patient app** (`patient_app/`) — Flutter web. patients can see their bills, demo appointment flows, push notifications from admin

**staff app** (`staff_app/`) — Flutter web. dashboard + alerts view for hospital staff / fleet operators

---

## tech stack

- **frontend (admin)** — vanilla js + css, no framework. leaflet.js for maps (osm + carto tiles). firebase hosting
- **patient + staff** — flutter web (dart). firebase hosting
- **backend / infra** — firebase firestore (realtime db), firebase hosting, cloud functions (in `/functions`, not fully wired yet)
- **AI** — Gemini API (gemma-3-27b-it) for ops suggestions and the analytics chat in Report tab. totally optional, works fine without a key
- **maps** — leaflet 1.9.4, vendor-bundled + unpkg CDN fallback. tiles from CartoDB dark + OSM
- **auth** — demo-mode only right now. firebase auth hooks are there but not enforced in the UI

---

## vision

the goal was basically: *give a hospital's night-shift admin the kind of real-time awareness that only big systems have*.

most hospital ops tools are either expensive enterprise stuff or just spreadsheets. we wanted something that:
1. shows WHERE the demand is coming from (hence the lucknow hex zone map with inflow predictions)
2. keeps the human in the loop for approvals instead of full automation (gemini suggests, admin decides)
3. connects admin ↔ patient ↔ staff in one system instead of three separate apps
4. can run as a static site with just Firebase — no backend servers to manage

obviously theres a lot still to do — proper auth, real patient data integration, mobile-native patient app, etc. but the core flows (zone intel, billing lifecycle, ops feed, patient push) are working in demo mode.

---

## run locally

```bash
npm install
npm run dev:admin    # localhost:3000  (admin panel)
npm run dev:patient  # localhost:3001  (patient app, needs flutter build first)
npm run dev:staff    # localhost:3002  (staff app, needs flutter build first)
npm run dev:all      # all three at once
```

build flutter apps first if you haven't:
```bash
npm run build:patient
npm run build:staff
```

---

## deploy

```bash
# admin only
firebase deploy --only hosting:admin

# patient + staff (after flutter build)
firebase deploy --only hosting:patient
firebase deploy --only hosting:staff
```

---

## notes

- `web/gemini-config.js` is gitignored — copy from `gemini-config.example.js` and add your key if you want the AI features
- the `/__/firebase/init.js` 404 on localhost is expected — firebase injects it automatically on hosting
- billings and ops feed use demo/seed data. firestore rules are open for demo, dont deploy to prod without locking those down
- map tiles might not load on restricted networks (corporate proxies etc) — vendor leaflet is bundled so the hex grid still renders even if tiles are blocked
