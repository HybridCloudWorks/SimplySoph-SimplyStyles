# V1.0 TODO List

This list is for tracking the initial "Persona MVP" build.

### 🏛️ Phase 1: Foundation & Security (The "Non-Negotiables")
- [ ] Set up project repo (Git).
- [x] Choose tech stack (e.g., Firebase, Supabase, Flutter/React Native, Python/Node.js backend).
- [x] Implement core User Authentication system.
- [ ] **Force Multi-Factor Authentication (MFA)** on all accounts.
- [x] Create database schema for **Anonymous Profiles** (sizes, preferences, etc.).
- [ ] Create database schema for **Persona Assets** (item_id, user_id, color, style, brand, stock_image_url).
- [ ] **[RESEARCH]** Finalize security protocol for PII-free data storage.

### 🧠 Phase 2: Core AI Engine (The "Vortex" v1)
- [ ] **[RESEARCH]** Choose image recognition/vision API (e.g., Google Vision AI, Clarifai, or build custom model).
- [ ] Build the "Image-to-Metrics" pipeline:
    - [ ] **[CRITICAL]** Build AI function to detect and **redact faces/backgrounds** from user-uploaded images.
    - [ ] Build AI function to identify **Color** from an image.
    - [ ] Build AI function to identify **Style/Category** (e.g., "v-neck sweater," "denim jeans").
    - [ ] Build function to search for and save a **stock photo** of the identified item.
- [ ] Build the "Prime Persona" (v1) algorithm:
    - [ ] Function to analyze all `Persona Assets` for a user.
    - [ ] Function to determine a "dominant style" (e.g., 40% "Boho," 30% "Classic," 30% "Sporty").

### 📱 Phase 3: User Interface (The App)
- [ ] Build "My Profile" screen (for sizes, etc.).
- [ ] Build **Wardrobe Ingestion Flow**:
    - [ ] Camera access UI.
    - [ ] File upload UI.
    - [ ] Loading/processing screen while "Vortex" AI is working.
- [ ] Build "Digital Closet" UI (gallery view of all `Persona Assets`).
- [ ] Build "AI-Driven Styles" UI:
    - [ ] "Get Styled" button.
    - [ ] Screen to display AI-recommended outfits (e.g., "Wear this top with this bottom").
- [ ] Build "Glam Room" (v1) UI:
    - [ ] A vertical feed (like Instagram) of curated items.
    - [ ] Commenting feature.
    - [ ] "Buy Now" button (opens affiliate link in a web browser).

### 💸 Phase 4: Monetization & Launch Prep
- [ ] Sign up for affiliate programs (e.g., Amazon Associates, Rakuten, direct brand partnerships).
- [ ] Create internal admin panel to add/manage "Glam Room" items and affiliate links.
- [ ] Final security audit.
- [ ] Deploy backend and submit app to stores.