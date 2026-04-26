# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**掃除案件管理** (Cleaning Job Management) — A mobile-first single-page web application for managing weekly cleaning jobs. Staff use it to track property visits, share memos in real time, and optimize daily routes on Google Maps.

## Running Locally

No build step. Open `index.html` directly in a browser, or serve it with any HTTP server:

```bash
python3 -m http.server 8000
# Then open http://localhost:8000
```

There are no tests, no linter, no package manager.

## Architecture

The entire application lives in a single file: **`index.html`**.

It is structured in three logical sections:

1. **HTML (top)** — Screen containers and modal dialogs. Screens are `<div class="screen">` elements toggled visible via `showScreen()`. Language is Japanese (`lang="ja"`).
2. **Inline CSS (via Tailwind)** — Tailwind CSS is loaded from CDN. Mobile-first; safe-area insets handle iPhone notch devices.
3. **Inline JavaScript (~650 lines)** — All application logic. No frameworks; vanilla JS only.

### External Dependencies (all CDN)

| Library | Version | Purpose |
|---|---|---|
| Tailwind CSS | latest | Styling |
| Firebase JS SDK | 10.7.1 compat | Firestore real-time database |
| Google Maps JS API | latest | Route optimization |

### State

A single `state` object holds all runtime state:

```js
const state = {
  properties: [],     // current week's Firestore documents
  staff: [],          // staff list (also persisted in Firestore settings/staff)
  currentUser: '',    // selected staff member (persisted in localStorage)
  detailId: null,     // property ID shown in the detail modal
  memoUnsub: null,    // Firestore onSnapshot unsubscribe fn for active memo listener
  importData: [],     // CSV rows parsed for import preview
};
```

### Firestore Schema

```
properties/{docId}
  name: string
  address: string
  weekOf: string          # ISO date of the week's Monday (YYYY-MM-DD)
  weeklyVisits: number    # 1 or 2 visits per week
  visitedCount: number    # completed visits this week
  gomi: string            # garbage/waste notes
  autoLockCode: string    # entry code (blurred in UI by default)
  fixedSchedule: string   # e.g. "水曜 14:00"
  createdAt: timestamp

  memos/{memoId}          # sub-collection
    author: string
    body: string
    createdAt: timestamp

settings/staff
  members: [{id, name, defaultStart}]

settings/schedule
  wed: string             # Wednesday time
  friStart: string
  friEnd: string
```

Properties are queried by `weekOf` to show only the current week's jobs.

### Key Workflows

- **Real-time sync**: `onSnapshot()` on `properties` filtered by `weekOf` drives the home and properties screens. The memo listener for an open detail modal is managed separately via `state.memoUnsub` — it is attached when the modal opens and detached when it closes.
- **CSV Import**: A custom CSV parser (no library) reads Excel-exported CSV files and batch-writes documents to Firestore. The import screen shows a preview before committing.
- **Route optimization**: Uses `google.maps.DirectionsService` with `optimizeWaypoints: true`. Staff addresses are geocoded on the fly; the route start point is the selected staff member's `defaultStart`.
- **Auto-lock codes**: The `autoLockCode` field is blurred in the UI. A toggle button reveals it. No authentication layer exists — access relies on keeping the URL private.

### Navigation

`showScreen(n)` hides all `.screen` elements and shows the nth one (1-indexed). The bottom nav bar calls this directly via `onclick`.

## Credentials

Firebase and Google Maps API keys are **hardcoded in `index.html`**. These are client-side keys for a Firebase project (`soujikanri-b6ee9`) and a Maps API key restricted to this app. Do not rotate them without updating the file.
