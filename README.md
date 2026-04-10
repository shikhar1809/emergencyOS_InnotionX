# EmergencyOS · InnovationX

**Goel Hospital — emergency operations demo stack:** static **admin** panel (Leaflet overview, billings, comms hooks), **patient** and **staff** Flutter web apps, Firebase Hosting, and optional Cloud Functions.

**Repository:** [github.com/shikhar1809/emergencyOS_InnotionX](https://github.com/shikhar1809/emergencyOS_InnotionX)  
**Firebase project:** `emergencyos-innovationx`

---

## Live pages (Firebase Hosting)

| App | What it is | URL |
| --- | --- | --- |
| **Admin panel** | Operations admin UI (maps, zones, billings, reports, internal comms) | [emergencyos-innovationx.web.app](https://emergencyos-innovationx.web.app) |
| **Patient app** | Patient-facing Flutter web (home, bills, demo flows) | [emergencyos-innovationx-patient.web.app](https://emergencyos-innovationx-patient.web.app) |
| **Staff app** | Staff Flutter web (dashboard, alerts) | [emergencyos-innovation-staff.web.app](https://emergencyos-innovation-staff.web.app) |
| **Staff app (alt target)** | Same build, alternate hosting target | [emergencyos-innovationx-staff.web.app](https://emergencyos-innovationx-staff.web.app) |

**Firebase console:** [console.firebase.google.com/project/emergencyos-innovationx](https://console.firebase.google.com/project/emergencyos-innovationx/overview)

---

## Admin panel — in-app sections (one URL)

Open the [admin URL](https://emergencyos-innovationx.web.app) and use the bottom dock:

| Section | Focus |
| --- | --- |
| **Overview** | Lucknow hex zones (A–S), map, zone intelligence |
| **Manage** | Patient roster, staff, embedded maps |
| **Operations** | Human-in-loop feed, approvals |
| **Comms** | Internal comms (Firebase when configured) |
| **Report** | KPIs, demo exports, Gemma / Gemini chat |
| **Billings** | Demo incidents, patient push, quick bill / QR flow |

---

## Local development

From the repo root:

```bash
npm install
```

| Page / app | Command | URL |
| --- | --- | --- |
| Admin (static `web/`) | `npm run dev:admin` | [http://localhost:3000](http://localhost:3000) |
| Patient (needs `flutter build web` first) | `npm run dev:patient` | [http://localhost:3001](http://localhost:3001) |
| Staff (needs `flutter build web` first) | `npm run dev:staff` | [http://localhost:3002](http://localhost:3002) |
| All three | `npm run dev:all` | 3000 / 3001 / 3002 |

Build Flutter web outputs:

```bash
npm run build:patient
npm run build:staff
```

---

## Deploy (summary)

- **Admin:** `firebase deploy --only hosting:admin` (publishes `web/`)
- **Patient / staff:** build Flutter web, then `firebase deploy --only hosting:patient` / `hosting:staff` as configured in `firebase.json` and `.firebaserc`

---

## Configuration notes

- **`web/gemini-config.js`** is gitignored; use env or local file for Gemini keys (see admin Report tab).
- **`functions/`** — Firebase Functions when used with this project.
