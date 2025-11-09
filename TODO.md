# V1.0 "The Hook" - Coded TODO List

This list is for the initial MVP. **Do not** add V1.5/V2.0 features here. Focus is speed.

### 🏛️ Phase 1: Foundation (1-2 weeks)
- [ ] Initialize Git repository.
- [x] Decide and set up tech stack (Backend, Database, App Framework).
- [x] Implement core User Authentication (e.g., Firebase Auth).
- [ ] **Force Multi-Factor Authentication (MFA)** from day one.
- [x] Database Schema (v1):
    - [x] `users`: (user_id, [NO PII], profile_metrics: {sizes, colors, etc.})
    - [ ] `wardrobe_items`: (item_id, user_id, persona_metrics: {color, style, brand}, image_url)
- [ ] **[RESEARCH]** Finalize security protocol. How will we guarantee PII/photo-free storage?

### 🧠 Phase 2: The "Vortex" AI (The hard part)
- [ ] **[RESEARCH]** Select and test Image Recognition APIs (Google Vision, Clarifai, etc.).
- [ ] Build the "Image-to-Metrics" pipeline:
    - [ ] **[CRITICAL-SAFETY]** Build the AI function to **redact faces/backgrounds**. This must run *before* any image is stored.
    - [ ] **[AI-TASK]** Build Color identification function.
    - [ ] **[AI-TASK]** Build Style/Category identification function (e.g., "v-neck sweater").
    - [ ] **[AI-TASK]** Build Brand identification (if possible, low-priority).
    - [ ] **[FEATURE]** Build the "Stock Photo Finder" function to replace user photos.
- [ ] Build "Prime Persona" (v1) algorithm:
    - [ ] Function to analyze all `wardrobe_items` for a user.
    - [ ] Function to calculate and save the user's "dominant style" (e.g., 70% "Classic").

### 📱 Phase 3: The "Hook" UI (The App)
- [ ] Build "Onboarding" flow (Account creation, Profile metrics input).
- [ ] Build **Wardrobe Ingestion Flow**:
    - [ ] Camera access UI.
    - [ ] File upload UI.
    - [ ] "Analyzing your item..." loading/processing screen.
- [ ] Build "Digital Closet" UI (A simple gallery of `wardrobe_items`).
- [ ] Build "Prime Persona" (v1) UI:
    - [ ] A simple, delightful screen showing the user's Persona *after* they hit 15 items. This must feel like a "reward."
- [ ] Build "AI-Driven Styles" (v1) UI:
    - [ ] "Get Styled" button.
    - [ ] UI to display recommended *combinations* of their own clothes.
- [ ] Build "Glam Room" (v1) UI:
    - [ ] A *very simple* feed. Do not over-engineer this.
    - [ ] "Buy" button (opens affiliate link in-app browser).

### 🚀 Phase 4: Launch Prep
- [ ] Set up basic affiliate link management (even a simple spreadsheet/Airtable).
- [ ] Final security and privacy audit.
- [ ] Deploy backend and submit apps to stores.