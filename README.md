# Srijati Baseline Survey MIS

A field enumeration and survey management application built for the **Srijati Foundation** Baseline Livelihood Survey MIS. The application empowers field enumerators to collect, draft, and synchronize survey data across rural households with offline-first capabilities and bilingual localization (Bengali / English).

## Key Features

- **Field Enumerator Authentication:** Secure phone & password login against the remote MIS API, with an Offline Demo mode for remote areas without cell connectivity.
- **Multilingual Support (Bengali & English):** Dynamic language switching with on-the-fly server translation sync (`/api/translations`) and local storage fallback.
- **Multi-Step Baseline Survey Stepper:**
  - **Step 1:** Household Identification & Location (HH Code, Respondent Name, Block, Panchayat, Village).
  - **Step 2:** Land & Agriculture (Total land owned in acres, with real-time highlighted reviewer remarks for flagged corrections).
  - **Step 3:** Review & Local Save.
- **Offline-First Draft Management:**
  - Saves in-progress survey drafts locally on the device.
  - Dedicated Saved Drafts screen with view, edit, and delete functionality.
  - One-tap sync button to batch-upload pending local drafts to `/api/forms/submit`.
- **Submitted Forms Tracking:** Remote dashboard querying the enumerator's submitted records and statuses from the server (`/api/forms/my-submitted`).
- **Correction / Review Workflow:** Flags records requiring enumerator attention (`/api/forms/my-corrections`) with reviewer comments and one-tap "Fix" direct navigation to the flagged field.

## Architecture

- **State Management & Localization:** `TranslationProvider` inherited widget providing reactive translations and locale switching across the widget tree.
- **Storage Layer (`LocalDatabase`):**
  - Uses SQLite (`sqflite`) for native Android/mobile persistent storage.
  - Uses `SharedPreferences` for resilient web/emulator execution and offline draft persistence.
- **Network Layer:** RESTful communication with the Srijati MIS server (`/api`), proxied seamlessly in web preview and direct on mobile devices.
