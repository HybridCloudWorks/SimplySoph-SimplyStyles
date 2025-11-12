# BigQuery & Vertex AI Setup Guide

## BigQuery Setup - Stream Firestore to BigQuery

### Step 1: Enable BigQuery API
1. Go to https://console.cloud.google.com/apis/library/bigquery.googleapis.com?project=simplysoph-66c78
2. Click **Enable**

### Step 2: Install BigQuery Export Extensions

Install **4 separate extensions** (one per collection):

#### Extension 1: Export wardrobe_items
1. Firebase Console → Extensions → Install extension
2. Search: **Stream Collections to BigQuery**
3. Configure:
   - **Collection path**: `wardrobe_items`
   - **Dataset ID**: `simplysoph_analytics`
   - **Table ID**: `wardrobe_items`
   - **Dataset location**: `us-central1`
   - **Backup collection**: Leave empty
   - **Transform function**: Leave empty
   - **Clustering fields**: `userId,category`
   - **Time partitioning**: `createdAt`
   - **Wildcard field**: Leave empty
4. Click **Install**

#### Extension 2: Export style_personas
1. Install another instance
2. Configure:
   - **Collection path**: `style_personas`
   - **Dataset ID**: `simplysoph_analytics`
   - **Table ID**: `style_personas`
   - **Dataset location**: `us-central1`
   - **Clustering fields**: `userId`
   - **Time partitioning**: `createdAt`
3. Click **Install**

#### Extension 3: Export users
1. Install another instance
2. Configure:
   - **Collection path**: `users`
   - **Dataset ID**: `simplysoph_analytics`
   - **Table ID**: `users`
   - **Dataset location**: `us-central1`
   - **Clustering fields**: Leave empty
   - **Time partitioning**: `createdAt`
3. Click **Install**

#### Extension 4: Export recommendations (future)
1. Install another instance
2. Configure:
   - **Collection path**: `recommendations`
   - **Dataset ID**: `simplysoph_analytics`
   - **Table ID**: `recommendations`
   - **Dataset location**: `us-central1`
   - **Clustering fields**: `userId`
   - **Time partitioning**: `createdAt`
3. Click **Install**

### Step 3: Verify BigQuery Dataset
1. Go to https://console.cloud.google.com/bigquery?project=simplysoph-66c78
2. Check left sidebar for `simplysoph_analytics` dataset
3. Should see tables: `wardrobe_items`, `style_personas`, `users`, `recommendations`

### Step 4: Test Queries

#### Query 1: Most Popular Categories
```sql
SELECT 
  category, 
  COUNT(*) as count
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
GROUP BY category
ORDER BY count DESC
LIMIT 10;
```

#### Query 2: Most Popular Colors
```sql
SELECT 
  color, 
  COUNT(*) as count
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
GROUP BY color
ORDER BY count DESC
LIMIT 10;
```

#### Query 3: User Growth Over Time
```sql
SELECT 
  DATE(timestamp) as date,
  COUNT(*) as new_users
FROM `simplysoph-66c78.simplysoph_analytics.users`
GROUP BY date
ORDER BY date DESC;
```

#### Query 4: Average Items Per User
```sql
SELECT 
  AVG(item_count) as avg_items
FROM (
  SELECT 
    userId,
    COUNT(*) as item_count
  FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
  GROUP BY userId
);
```

#### Query 5: Style Persona Distribution
```sql
SELECT 
  JSON_EXTRACT_SCALAR(personas, '$[0].name') as persona_name,
  COUNT(*) as count
FROM `simplysoph-66c78.simplysoph_analytics.style_personas`
GROUP BY persona_name
ORDER BY count DESC;
```

---

## Vertex AI Setup - Enable Gemini in Vertex

### Step 1: Enable Vertex AI API
1. Go to https://console.cloud.google.com/apis/library/aiplatform.googleapis.com?project=simplysoph-66c78
2. Click **Enable**

### Step 2: Enable Required APIs
```bash
# Enable all required APIs
gcloud services enable aiplatform.googleapis.com --project=simplysoph-66c78
gcloud services enable storage.googleapis.com --project=simplysoph-66c78
gcloud services enable compute.googleapis.com --project=simplysoph-66c78
```

Or via Console:
1. https://console.cloud.google.com/apis/library/aiplatform.googleapis.com?project=simplysoph-66c78
2. https://console.cloud.google.com/apis/library/storage.googleapis.com?project=simplysoph-66c78
3. https://console.cloud.google.com/apis/library/compute.googleapis.com?project=simplysoph-66c78

### Step 3: Grant Vertex AI Permissions

1. Go to https://console.cloud.google.com/iam-admin/iam?project=simplysoph-66c78
2. Find service account: `simplysoph-66c78@appspot.gserviceaccount.com`
3. Click **Edit** (pencil icon)
4. Click **Add Another Role**
5. Add these roles:
   - **Vertex AI User**
   - **Vertex AI Service Agent**
   - **Storage Object Viewer**
6. Click **Save**

### Step 4: Update Cloud Functions to Use Vertex AI

**Current**: Direct Gemini API calls  
**New**: Vertex AI Gemini endpoint (better for production)

#### Update functions/package.json
```json
{
  "dependencies": {
    "@google-cloud/aiplatform": "^3.0.0",
    "@google-cloud/vertexai": "^1.0.0"
  }
}
```

#### Update functions/index.js

Add at top:
```javascript
const {VertexAI} = require('@google-cloud/vertexai');

const vertexAI = new VertexAI({
  project: 'simplysoph-66c78',
  location: 'us-central1',
});

const model = vertexAI.preview.getGenerativeModel({
  model: 'gemini-1.5-flash',
});
```

Replace Gemini API calls with Vertex AI:
```javascript
// OLD: Direct Gemini API
const response = await fetch('https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${GEMINI_API_KEY}`,
  },
  body: JSON.stringify(payload),
});

// NEW: Vertex AI Gemini
const result = await model.generateContent({
  contents: [{
    role: 'user',
    parts: [{
      inlineData: {
        mimeType: 'image/jpeg',
        data: imageBase64,
      },
    }, {
      text: 'Analyze this clothing item...',
    }],
  }],
});

const response = result.response.text();
```

### Step 5: Deploy Updated Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### Step 6: Test Vertex AI Integration

Test via Cloud Functions:
```javascript
// Call your function
const response = await fetch('https://us-central1-simplysoph-66c78.cloudfunctions.net/vortex_analyzeItem', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_TOKEN',
  },
  body: JSON.stringify({
    imageUrl: 'https://example.com/shirt.jpg',
  }),
});

const result = await response.json();
console.log(result); // Should show Vertex AI analysis
```

---

## BigQuery ML with Gemini (Advanced)

### Step 1: Create Gemini Model in BigQuery
```sql
CREATE OR REPLACE MODEL `simplysoph-66c78.simplysoph_analytics.gemini_model`
REMOTE WITH CONNECTION `us-central1.vertex-ai-connection`
OPTIONS (
  ENDPOINT = 'gemini-1.5-flash'
);
```

### Step 2: Use Gemini in SQL Queries
```sql
-- Analyze fashion trends with Gemini
SELECT
  category,
  ML.GENERATE_TEXT(
    MODEL `simplysoph-66c78.simplysoph_analytics.gemini_model`,
    (SELECT CONCAT('What are the current trends for ', category, ' clothing?') as prompt),
    STRUCT(0.7 AS temperature, 100 AS max_output_tokens)
  ) as trend_analysis
FROM (
  SELECT DISTINCT category
  FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
)
LIMIT 5;
```

### Step 3: Create Scheduled Queries (Weekly Trend Reports)

1. Go to BigQuery Console
2. Click **Scheduled queries**
3. Click **Create scheduled query**
4. Query:
```sql
-- Weekly trend analysis
INSERT INTO `simplysoph-66c78.simplysoph_analytics.trend_reports`
SELECT
  CURRENT_DATE() as report_date,
  category,
  COUNT(*) as item_count,
  ML.GENERATE_TEXT(
    MODEL `simplysoph-66c78.simplysoph_analytics.gemini_model`,
    (SELECT CONCAT('Analyze trends for ', category) as prompt)
  ) as ai_insights
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY category;
```
5. Schedule: **Every Monday at 9 AM**
6. Click **Save**

---

## Vertex AI Model Garden (Optional Advanced Features)

### Fashion-Specific Models

#### 1. Image Embeddings for Similar Items
```javascript
const {PredictionServiceClient} = require('@google-cloud/aiplatform');

const client = new PredictionServiceClient();

async function getImageEmbedding(imageUrl) {
  const endpoint = `projects/simplysoph-66c78/locations/us-central1/publishers/google/models/multimodalembedding@001`;
  
  const request = {
    endpoint,
    instances: [{
      image: {
        gcsUri: imageUrl,
      },
    }],
  };
  
  const [response] = await client.predict(request);
  return response.predictions[0].imageEmbedding;
}
```

#### 2. Visual Search (Find Similar Clothing)
```javascript
async function findSimilarItems(targetImageUrl, wardrobeItems) {
  const targetEmbedding = await getImageEmbedding(targetImageUrl);
  
  const similarities = await Promise.all(
    wardrobeItems.map(async (item) => {
      const itemEmbedding = await getImageEmbedding(item.imageUrl);
      const similarity = cosineSimilarity(targetEmbedding, itemEmbedding);
      return { item, similarity };
    })
  );
  
  return similarities
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, 10);
}
```

---

## Monitoring & Cost Management

### Set Budget Alerts

1. Go to https://console.cloud.google.com/billing/budgets?project=simplysoph-66c78
2. Click **Create budget**
3. Configure:
   - **Name**: SimplyStyles Monthly Budget
   - **Budget amount**: $50/month
   - **Alert thresholds**: 50%, 90%, 100%
   - **Email notifications**: Your email
4. Click **Finish**

### Monitor BigQuery Costs
```sql
-- Check BigQuery usage
SELECT
  DATE(creation_time) as date,
  SUM(total_bytes_processed) / POW(10, 12) as tb_processed,
  SUM(total_bytes_processed) / POW(10, 12) * 5 as estimated_cost_usd
FROM `simplysoph-66c78.region-us-central1.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY date
ORDER BY date DESC;
```

### Monitor Vertex AI Costs
1. Go to https://console.cloud.google.com/vertex-ai/dashboard?project=simplysoph-66c78
2. Check **Predictions** tab for usage
3. View **Billing** for costs

---

## Cost Estimates

### BigQuery (Free Tier)
- **Storage**: 10 GB free
- **Queries**: 1 TB/month free
- **Streaming inserts**: $0.05 per 200 MB
- **Estimated**: $0-5/month for MVP

### Vertex AI Gemini
- **Gemini 1.5 Flash**: $0.00025 per image
- **1000 images/month**: $0.25
- **10K images/month**: $2.50
- **100K images/month**: $25

### Total Estimated Costs
- **MVP (100 users)**: $5-10/month
- **Growth (1K users)**: $20-30/month
- **Scale (10K users)**: $100-150/month

---

## Verification Checklist

### BigQuery
- [ ] BigQuery API enabled
- [ ] 4 extensions installed (wardrobe_items, style_personas, users, recommendations)
- [ ] Dataset `simplysoph_analytics` created
- [ ] Test queries run successfully
- [ ] Budget alerts configured

### Vertex AI
- [ ] Vertex AI API enabled
- [ ] Service account permissions granted
- [ ] Cloud Functions updated to use Vertex AI
- [ ] Functions deployed successfully
- [ ] Test API calls work
- [ ] Monitoring dashboard configured

### Integration
- [ ] BigQuery receiving Firestore data
- [ ] Vertex AI processing images
- [ ] Gemini model accessible in BigQuery
- [ ] Cost monitoring active
- [ ] Documentation updated

---

## Next Steps After Setup

1. **Test Data Flow**: Add wardrobe item → Check BigQuery
2. **Test AI**: Upload image → Verify Vertex AI analysis
3. **Create Dashboards**: Use Looker Studio with BigQuery
4. **Set Up Alerts**: Monitor costs and errors
5. **Optimize Queries**: Add indexes and partitioning

---

## Troubleshooting

### BigQuery Extension Not Streaming
- Check extension logs in Firebase Console
- Verify BigQuery API is enabled
- Check service account permissions
- Ensure dataset location matches (us-central1)

### Vertex AI Permission Errors
- Verify all APIs are enabled
- Check IAM roles for service account
- Ensure project billing is active
- Try re-deploying functions

### High Costs
- Check BigQuery query costs (use query validator)
- Reduce Vertex AI calls (cache results)
- Use partitioning and clustering
- Set up budget alerts

---

## Resources

- **BigQuery Console**: https://console.cloud.google.com/bigquery?project=simplysoph-66c78
- **Vertex AI Console**: https://console.cloud.google.com/vertex-ai?project=simplysoph-66c78
- **BigQuery Pricing**: https://cloud.google.com/bigquery/pricing
- **Vertex AI Pricing**: https://cloud.google.com/vertex-ai/pricing
- **Gemini API Docs**: https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini
