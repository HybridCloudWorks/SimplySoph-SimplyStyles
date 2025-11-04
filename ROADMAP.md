# App Vision & Roadmap

---

## 🚀 Core Vision

To create an AI-powered "Persona" system that acts as a personal stylist. It helps users understand their own wardrobe, discover new styles, and connect with fashion by analyzing their clothes (color, brand, style) and comparing them to trend-based "Personas."

## ✅ Version 1.0: The "Persona MVP"

The goal of V1.0 is to build and validate the **core Persona engine** and the **private, personal stylist loop**. The user must get value from the app *by themselves* before we introduce community features.

### Core Engine (The "Vortex" AI - v1)
* **User Onboarding:**
    * [ ] Secure account creation (MFA required).
    * [ ] Anonymous Profile: User can input sizes, measurements, and favorite colors (NO PII).
* **Wardrobe Ingestion:**
    * [ ] Allow upload of clothing items via Camera or PNG/JPG.
* **AI "Image-to-Metrics" System (CRITICAL):**
    * [ ] **Privacy Failsafe:** System *must* automatically remove faces/backgrounds from any saved image.
    * [ ] **Ideal Path:** Analyze the image for "Persona Metrics" (Color, Style, Category) and then find a generic/stock photo of the item online to store. The user's original photo is **discarded**.
* **"Persona Asset" Creation:**
    * [ ] Each item is saved to the user's database with its metrics (color, style, etc.).
* **"Prime Persona" (v1):**
    * [ ] An initial algorithm that analyzes the user's *entire* closet to generate their **single** "Prime Persona." This defines their dominant style(s).

### User-Facing Features (v1.0)
* **Digital Closet:**
    * [ ] A "View My Wardrobe" screen where users can see all their "Persona Assets."
* **AI-Driven Styles (The "Best Friend"):**
    * [ ] A "Get Styled" feature.
    * [ ] The AI uses the user's "Prime Persona" to recommend **outfit combinations** from clothes they **already own**.
* **The "Glam Room" (v1):**
    * [ ] A simple, curated feed of "Hot" new fashion items.
    * [ ] Items are presented with "Hot or Not" commenting.
    * [ ] **Monetization (v1):** All items in the "Glam Room" will have an **affiliate link** for purchase. This is the sole V1.0 revenue stream.
* **Brand Policy:**
    * [ ] All affiliate links and "Glam Room" content will **only** be from high-quality, authentic brands, as defined by our partnership policy.

---

## ⏳ Version 2.0: The "Community & Commerce Engine"

The goal of V2.0 is to expand the app from a personal tool to a **social community**, and to scale monetization. This build-out *relies on* the V1.0 engine working perfectly.

### Core Engine (The "Vortex" AI - v2)
* [ ] **Trend-Based Scoring:** Upgrade the AI to include the "weighted score" based on *real-time* trend data for specific demographics.
* [ ] **Multiple Personas:** Allow users to create and save *multiple* Prime Personas (e.g., "Work," "Weekend," "Gala").

### User-Facing Features (v2.0)
* **Sharable Personas (The Social Loop):**
    * [ ] Allow users to **anonymously** share their "Prime Personas."
    * [ ] Create a "Persona Library" where users can browse and "download" Personas from other users.
* **"Complete the Look" (Monetization v2):**
    * [ ] When a user "downloads" a new Persona, the app will:
        1.  Show them what items they *already own* that match it.
        2.  Recommend **new clothes (with affiliate links)** to help them "complete" the Persona.
* **Enhanced "Glam Room" (v2):**
    * [ ] Allow brands to sponsor "Glam Room" features.
    * [ ] Integrate AI to show "Glam Room" items that *specifically* match a user's Prime Persona.

---

## 🌟 Future Scope (v3.0+)

* **E-Commerce Module:**
    * [ ] Architect the app to *support* a future dropshipping model.
    * [ ] Build the full payment and fulfillment system to sell clothes directly.
* **Advanced AI:**
    * [ ] AI-driven "What to buy next" predictions.
    * [ ] Deeper analysis of fabric, cut, and quality.

---

## 🛠️ Technical Foundation

The application is architected to be a production-ready, scalable, and secure platform from day one.

### Technology Stack
*   **Frontend**: Flutter (cross-platform for iOS & Android)
*   **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
*   **AI Engine**: Gemini Cortex API (or a similar high-quality vision/language model)

### Architecture Highlights
*   **Clean Architecture**: The code is organized with a strict separation of concerns, separating the UI (widgets), business logic (services/state), and data models.
*   **State Management**: We use the `Provider` pattern in Flutter for efficient and predictable state management.
*   **Serverless & Scalable**: By leveraging Firebase, the backend infrastructure (database, functions, storage) scales automatically with user demand.
*   **Security First**: Security is not an afterthought. We use Firebase's robust security rules for both Firestore and Storage to ensure users can only access their own data. All API keys and sensitive credentials are stored securely in the backend (Cloud Functions environment variables) and are never exposed to the client.

### Fashion Style Classification

SimplyStyles uses a curated classification system based on three core Gen Z fashion trends:

**Luxury Loungewear** represents premium-priced, comfortable clothing worn as everyday fashion. This category emphasizes quality materials, elevated design, and the blending of comfort with style. Items typically feature soft fabrics, relaxed silhouettes, and sophisticated color palettes.

**New Preppy** captures bright colors, playful prints, and matching sets. This modern take on preppy fashion incorporates bold patterns, cheerful color combinations, and coordinated pieces. Brands like Roller Rabbit exemplify this aesthetic with their vibrant, pattern-rich collections.

**Coastal Comfort** embodies relaxed, beach-inspired streetwear. This category features casual silhouettes, ocean-inspired colors, and laid-back styling. Brands like Aviator Nation and Pink Palm Puff represent this aesthetic with their comfortable, California-cool designs.

These categories serve as the foundation for persona generation and recommendation matching, providing a structured yet flexible framework for understanding user style preferences.
