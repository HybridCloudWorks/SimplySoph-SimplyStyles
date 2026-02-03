# App Vision & Roadmap (The "Aggressive" Path)

## 🚀 The Lofty Goal (Q2 2026)

Our primary, aggressive goal is **not** revenue. It is **100,000 Activated Users**.

- **Definition of "Activated User":** A user who has successfully uploaded at least **15 items**, generating their first meaningful "Prime Persona."

This metric proves we have a sticky product. Every feature will be measured by its ability to drive this single metric.

---

## ✅ V1.0: The "Hook" (Target: Q1 2026)

**Goal:** Launch the fastest, most stable version of the "magic moment" (seeing your Persona). We will validate the core "hook" and get our first 10,000 Activated Users.

### Core Engine (v1)

- [ ] **Secure Onboarding:** MFA required, anonymous profile (sizes, preferences).
- [ ] **Wardrobe Ingestion:** Camera & File Upload.
- [ ] **"Image-to-Metrics" AI (CRITICAL):**
  - [ ] **Privacy Failsafe:** Must auto-redact faces/backgrounds OR replace user photos with stock images. This is a non-negotiable trust feature.
  - [ ] **AI Analysis:** Identify Color, Style, Brand, and Category.
- [ ] **"Prime Persona" (v1):** The "magic moment." After 15 items, the app generates the user's _single_ dominant Persona.

### User-Facing Features (v1)

- [ ] **Digital Closet:** View and manage the wardrobe.
- [ ] **AI-Driven Styles (v1):** The "Best Friend." Recommends outfits using **only** clothes the user already owns. This builds trust.
- [ ] **"Glam Room" (v1 - Test):** A _minimal_ feed of affiliate-linked items. This is a low-priority feature to gather initial purchase-intent data, not a core driver.

---

## ⚡ V1.5: The "Stickiness" (Target: Q2 2026)

**Goal:** Immediately follow V1.0 with a high-impact update. Use data from our first users to launch the features that create retention and _intelligently_ monetize.

### Core Engine (v2)

- [ ] **Multiple Personas:** The #1 most-requested retention feature. Allow users to create and name multiple Personas (e.G., "Work," "Weekend," "Gala").
- [ ] **Trend-Based Scoring:** The AI "Vortex" now adds a "weighted score" to items based on current demographic trends.

### User-Facing Features (v1.5)

- [ ] **"Complete the Look" (CRITICAL INNOVATION):**
  - This becomes our **primary monetization feature**.
  - The "AI-Driven Styles" feature will now proactively suggest _one_ new item (with affiliate link) to _complete_ an outfit.
  - **Example:** "This outfit (your jeans + your top) would be 10/10 with _these_ [link] red heels."
  - This is helpful, not a "sales" feature, and directly ties our core value to revenue.
- [ ] **"Glam Room" (v2 - Smart):** The "Glam Room" feed is now personalized, recommending items that match the user's "Prime Persona."

---

## ⏳ V2.0: The "Community" (Target: H2 2026)

**Goal:** With a proven, sticky, and monetizing product, we now pour fuel on the fire by building the viral community loop.

### User-Facing Features (v2)

- [ ] **Sharable Personas:** Anonymously share and browse a "Persona Library."
- [ ] **"Persona Matching":** Users can "download" a Persona and see how well it matches their existing wardrobe.
- [ ] **"Complete the Persona" (Monetization v3):**
  - The ultimate revenue driver.
  - **Example:** "You are a 60% match for this 'LA Minimalist' Persona. Buy these 3 [linked] items to complete the look."

---

## 🌟 Future Scope (v3.0+)

- [ ] **E-Commerce Module:** Full dropshipping integration.
- [ ] **Brand Partnerships:** Sponsored "Glam Room" spots and "Brand Personas."

---

# Future Features Roadmap

## 🎯 Next Features to Build

### 1. Outfit Builder

**Description**: Mix & match items with AI suggestions  
**Priority**: High  
**Complexity**: Medium  
**Timeline**: 2-3 weeks

**Features**:

- Drag-and-drop interface to combine clothing items
- AI suggests complementary pieces from wardrobe
- Color coordination analysis
- Style compatibility scoring
- Save outfit combinations
- Share outfits with friends

**Technical Requirements**:

- Flutter drag-and-drop UI
- Vertex AI for outfit compatibility
- Firestore collection: `outfits`
- Image compositing for outfit preview

**Extensions Needed**:

- ✅ Already have: Vertex AI, Vector Search
- ⬜ New: None required

---

### 2. Virtual Try-On

**Description**: AR clothing visualization  
**Priority**: Medium  
**Complexity**: High  
**Timeline**: 4-6 weeks

**Features**:

- Camera-based AR try-on
- Body measurement detection
- Real-time clothing overlay
- Size recommendation
- Fit prediction

**Technical Requirements**:

- ARCore (Android) / ARKit (iOS)
- ML Kit for body pose detection
- 3D clothing models
- Real-time rendering

**Flutter Packages**:

- `arcore_flutter_plugin`
- `ar_flutter_plugin`
- `google_ml_kit`

**Extensions Needed**:

- ⬜ New: ML Kit Body Pose Detection
- ⬜ New: 3D model storage in Firebase Storage

---

### 3. Style Challenges

**Description**: Weekly fashion challenges with prizes  
**Priority**: High  
**Complexity**: Medium  
**Timeline**: 2-3 weeks

**Features**:

- Weekly themed challenges ("Monochrome Monday", "Vintage Vibes")
- User submissions with photos
- Community voting
- Leaderboard and prizes
- Push notifications for new challenges

**Technical Requirements**:

- Firestore collection: `challenges`, `submissions`, `votes`
- Cloud Functions for challenge creation
- Push notifications (FCM)
- Voting system with fraud prevention

**Extensions Needed**:

- ⬜ New: Cloud Messaging for push notifications
- ✅ Already have: Comment Toxicity (for submission moderation)

---

### 4. Influencer Marketplace

**Description**: Connect users with stylists  
**Priority**: Medium  
**Complexity**: High  
**Timeline**: 4-6 weeks

**Features**:

- Stylist profiles with portfolios
- Booking system for consultations
- Video call integration
- Payment processing
- Review and rating system
- Commission tracking

**Technical Requirements**:

- Firestore collections: `stylists`, `bookings`, `reviews`
- Stripe integration for payments
- Video call (Agora/Twilio)
- Calendar scheduling

**Flutter Packages**:

- `stripe_flutter`
- `agora_rtc_engine`
- `table_calendar`

**Extensions Needed**:

- ⬜ New: Stripe Payments extension
- ⬜ New: Video call integration (Vonage/Agora)

---

### 5. Shopping Integration

**Description**: Buy recommended items  
**Priority**: High  
**Complexity**: Medium  
**Timeline**: 3-4 weeks

**Features**:

- AI recommends items to complete wardrobe
- Affiliate links to retailers (Amazon, Zara, H&M)
- Price tracking and alerts
- "Shop the Look" from influencer outfits
- Wishlist and cart

**Technical Requirements**:

- Affiliate API integrations (Amazon Associates, ShopStyle)
- Product database in Firestore
- Price tracking Cloud Functions
- Deep linking to retailer apps

**Extensions Needed**:

- ✅ Already have: Shorten URLs (for affiliate links)
- ⬜ New: Product catalog sync

**Revenue Model**:

- 5-10% affiliate commission
- Potential: $5-20 per user per month

---

### 6. Closet Analytics

**Description**: "You wear this 80% of the time"  
**Priority**: Medium  
**Complexity**: Low  
**Timeline**: 1-2 weeks

**Features**:

- Track outfit usage frequency
- "Most worn" and "Never worn" items
- Cost per wear calculation
- Seasonal usage patterns
- Wardrobe utilization score
- Suggestions to wear neglected items

**Technical Requirements**:

- Firestore collection: `outfit_logs`
- BigQuery for analytics queries
- Data visualization charts
- Cloud Functions for daily aggregation

**Extensions Needed**:

- ✅ Already have: BigQuery Export, Distributed Counter
- ⬜ New: None required

**Sample Queries**:

```sql
-- Most worn items
SELECT itemId, COUNT(*) as wear_count
FROM outfit_logs
WHERE userId = 'user123'
GROUP BY itemId
ORDER BY wear_count DESC
LIMIT 10;

-- Cost per wear
SELECT
  i.name,
  i.price,
  COUNT(o.id) as wears,
  i.price / COUNT(o.id) as cost_per_wear
FROM wardrobe_items i
LEFT JOIN outfit_logs o ON i.id = o.itemId
GROUP BY i.id;
```

---

### 7. Sustainability Score

**Description**: Track clothing lifecycle  
**Priority**: Low  
**Complexity**: Medium  
**Timeline**: 2-3 weeks

**Features**:

- Carbon footprint per item
- Sustainability rating (A-F)
- Eco-friendly brand recommendations
- Donation/resale suggestions
- Clothing lifecycle tracking
- "Green Wardrobe" badge

**Technical Requirements**:

- Sustainability database (brand ratings, materials)
- Carbon calculation algorithms
- Firestore collection: `sustainability_data`
- Integration with Good On You API

**Data Sources**:

- Good On You API (brand ratings)
- Material sustainability database
- Carbon footprint calculations

**Extensions Needed**:

- ⬜ New: External API integration for brand ratings
- ✅ Already have: Extract Image Text (read material labels)

---

### 8. Outfit Calendar

**Description**: Plan outfits for the week  
**Priority**: High  
**Complexity**: Low  
**Timeline**: 1-2 weeks

**Features**:

- Weekly calendar view
- Drag outfits to specific days
- Weather-based suggestions
- Event-based recommendations ("Job interview Monday")
- Reminders and notifications
- Sync with Google Calendar

**Technical Requirements**:

- Firestore collection: `outfit_calendar`
- Weather API integration (OpenWeatherMap)
- Calendar UI component
- Push notifications for reminders

**Flutter Packages**:

- `table_calendar`
- `weather`
- `flutter_local_notifications`

**Extensions Needed**:

- ⬜ New: Weather API integration
- ✅ Already have: Trigger Email (for reminders)

---

## 📊 Feature Priority Matrix

### Phase 1 (MVP+) - Next 1-2 Months

1. ✅ Outfit Builder (High priority, medium complexity)
2. ✅ Style Challenges (High priority, medium complexity)
3. ✅ Outfit Calendar (High priority, low complexity)
4. ✅ Closet Analytics (Medium priority, low complexity)

### Phase 2 (Growth) - 3-4 Months

5. ✅ Shopping Integration (High priority, medium complexity)
6. ✅ Influencer Marketplace (Medium priority, high complexity)

### Phase 3 (Advanced) - 6+ Months

7. ✅ Virtual Try-On (Medium priority, high complexity)
8. ✅ Sustainability Score (Low priority, medium complexity)

---

## 💰 Revenue Impact

### High Revenue Potential

1. **Shopping Integration** - $5-20/user/month (affiliate commissions)
2. **Influencer Marketplace** - 15-20% commission on bookings
3. **Premium Features** - $4.99/month subscription

### Engagement Boosters

1. **Style Challenges** - Increase DAU by 30-50%
2. **Outfit Calendar** - Increase retention by 25%
3. **Closet Analytics** - Increase session time by 40%

### Brand Differentiators

1. **Virtual Try-On** - Unique selling point
2. **Sustainability Score** - Appeal to eco-conscious Gen Z
3. **AI Outfit Builder** - Core value proposition

---

## 🔧 Technical Dependencies

### Required Flutter Packages

```yaml
dependencies:
  # AR/ML
  arcore_flutter_plugin: ^0.1.0
  ar_flutter_plugin: ^0.7.3
  google_ml_kit: ^0.18.0

  # Payments
  stripe_flutter: ^10.0.0

  # Video
  agora_rtc_engine: ^6.3.0

  # Calendar
  table_calendar: ^3.1.0

  # Weather
  weather: ^3.1.1

  # Notifications
  flutter_local_notifications: ^17.0.0

  # Charts
  fl_chart: ^0.68.0
```

### Required Firebase Extensions

- ⬜ Cloud Messaging (push notifications)
- ⬜ Stripe Payments (marketplace)
- ⬜ Scheduled Functions (daily analytics)

### Required External APIs

- OpenWeatherMap API (weather)
- Good On You API (sustainability)
- Amazon Associates API (shopping)
- ShopStyle API (shopping)

---

## 📈 Success Metrics

### Outfit Builder

- 60% of users create at least 1 outfit
- Average 5 outfits per user
- 30% share outfits

### Style Challenges

- 40% participation rate
- 3x increase in user-generated content
- 50% increase in weekly active users

### Shopping Integration

- 20% click-through rate on recommendations
- 5% conversion rate
- $10 average order value

### Closet Analytics

- 70% of users check analytics weekly
- 25% increase in wardrobe utilization
- 15% reduction in "never worn" items

---

## 🚀 Implementation Order

### Week 1-2: Outfit Calendar

- Simple, high impact
- Builds on existing wardrobe data
- Quick win for users

### Week 3-5: Outfit Builder

- Core feature for engagement
- Leverages existing AI capabilities
- Foundation for other features

### Week 6-8: Closet Analytics

- Uses existing BigQuery data
- Low complexity, high value
- Encourages daily usage

### Week 9-12: Style Challenges

- Community building
- Viral growth potential
- Monetization through partnerships

### Month 4-5: Shopping Integration

- Revenue generation
- Affiliate partnerships
- Completes the wardrobe ecosystem

### Month 6+: Advanced Features

- Influencer Marketplace
- Virtual Try-On
- Sustainability Score

---

## 📝 Notes

**Last Updated**: Current session  
**Status**: Planning phase  
**Next Action**: Prioritize Phase 1 features and create detailed specs

**Dependencies**:

- All features build on existing 17 extensions
- No major infrastructure changes needed
- Can be developed incrementally

**Risk Mitigation**:

- Start with low-complexity features (Calendar, Analytics)
- Validate with users before building complex features (AR, Marketplace)
- Use existing extensions to minimize costs
