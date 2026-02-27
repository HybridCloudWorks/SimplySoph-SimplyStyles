const {onCall} = require('firebase-functions/v2/https');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onObjectFinalized} = require('firebase-functions/v2/storage');
const admin = require('firebase-admin');
const {VertexAI} = require('@google-cloud/vertexai');
const vision = require('@google-cloud/vision');
const axios = require('axios');
const googleTrends = require('google-trends-api');

admin.initializeApp();

// Initialize Vision Client
const visionClient = new vision.ImageAnnotatorClient();

const vertexAI = new VertexAI({
  project: 'simplysoph-66c78',
  location: 'us-central1',
});

const model = vertexAI.preview.getGenerativeModel({
  model: 'gemini-1.5-flash',
  generationConfig: {
    maxOutputTokens: 2048,
    temperature: 0.7,
  },
});

exports.vortex_analyzeItem = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const {storagePath} = request.data;
  if (!storagePath) {
    throw new Error('Storage path is required');
  }

  // IDOR Protection: Ensure user can only access their own files
  if (!storagePath.startsWith(`users/${request.auth.uid}/`)) {
    throw new Error('Unauthorized access to storage path');
  }

  // SSRF Protection: Use internal gs:// URI
  const bucketName = admin.storage().bucket().name;
  const gcsUri = `gs://${bucketName}/${storagePath}`;

  const prompt = `Analyze this clothing item and return a JSON object with:
- category (tops/bottoms/dresses/outerwear/shoes/accessories)
- color (primary color)
- style (casual/formal/sporty/elegant/etc)
- brand (if visible, otherwise "Unknown")
- season (spring/summer/fall/winter/all-season)
- occasion (everyday/work/party/athletic/etc)

Return ONLY valid JSON, no markdown.`;

  const result = await model.generateContent({
    contents: [{
      role: 'user',
      parts: [
        {text: prompt},
        {fileData: {mimeType: 'image/jpeg', fileUri: gcsUri}}
      ],
    }],
  });

  const text = result.response.candidates[0].content.parts[0].text;
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  const analysisData = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);

  return {success: true, data: analysisData};
});

exports.vortex_generatePersonas = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const userId = request.auth.uid;
  const wardrobeSnapshot = await admin.firestore()
    .collection('wardrobe_items')
    .where('userId', '==', userId)
    .get();

  const wardrobeItems = wardrobeSnapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));

  if (wardrobeItems.length < 5) {
    throw new Error('Need at least 5 items to generate personas');
  }

  const itemsSummary = wardrobeItems.slice(0, 10)
    .map(item => `${item.category}: ${item.color} ${item.styleTag || 'casual'}`)
    .join(', ');

  const prompt = `Based on this wardrobe: ${itemsSummary}

Generate 3 style personas as JSON array with:
- name (e.g., "Casual Chic")
- description
- keyPieces (array of 3 items)
- colorPalette (array of 3 colors)

Return ONLY valid JSON array, no markdown.`;

  const result = await model.generateContent(prompt);
  const text = result.response.candidates[0].content.parts[0].text;
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  const personas = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);

  const batch = admin.firestore().batch();
  const existingPersonas = await admin.firestore()
    .collection('style_personas')
    .where('userId', '==', userId)
    .get();

  existingPersonas.docs.forEach(doc => batch.delete(doc.ref));

  const personaRefs = [];
  personas.forEach(persona => {
    const personaRef = admin.firestore().collection('style_personas').doc();
    personaRefs.push(personaRef);
    batch.set(personaRef, {
      userId,
      ...persona,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // Link items to personas based on matching criteria
  for (const item of wardrobeItems) {
    const matchingPersonas = [];
    
    for (let i = 0; i < personas.length; i++) {
      const persona = personas[i];
      let matchScore = 0;
      
      // Check if item category matches key pieces
      if (persona.keyPieces.some(piece => 
        piece.toLowerCase().includes(item.category.toLowerCase()) ||
        item.category.toLowerCase().includes(piece.toLowerCase())
      )) {
        matchScore += 30;
      }
      
      // Check color matching
      if (persona.colorPalette.some(color => 
        item.color?.toLowerCase().includes(color.toLowerCase()) ||
        item.colors?.some(itemColor => itemColor.toLowerCase().includes(color.toLowerCase()))
      )) {
        matchScore += 20;
      }
      
      // Check style matching
      if (item.styleTag && persona.name.toLowerCase().includes(item.styleTag.toLowerCase())) {
        matchScore += 25;
      }
      
      // If match score is high enough, link the persona
      if (matchScore >= 30) {
        matchingPersonas.push(personaRefs[i].id);
      }
    }
    
    if (matchingPersonas.length > 0) {
      batch.update(admin.firestore().collection('wardrobe_items').doc(item.id), {
        personaIds: matchingPersonas,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  await batch.commit();
  return {success: true, personaCount: personas.length};
});

exports.vortex_calculateFit = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const userId = request.auth.uid;
  const {itemAttributes} = request.data;

  if (!itemAttributes) {
    throw new Error('Item attributes are required');
  }

  const personasSnapshot = await admin.firestore()
    .collection('style_personas')
    .where('userId', '==', userId)
    .get();

  const personas = personasSnapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));

  if (personas.length === 0) {
    throw new Error('No personas found');
  }

  const personasSummary = personas.map(p => p.name).join(', ');
  const prompt = `Item: ${JSON.stringify(itemAttributes)}
Personas: ${personasSummary}

Rate fit (0-100) for each persona as JSON: {"personaFits": [{"personaId": "id", "score": 85, "reason": "text"}]}

Return ONLY valid JSON, no markdown.`;

  const result = await model.generateContent(prompt);
  const text = result.response.candidates[0].content.parts[0].text;
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  const fitData = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);

  return {success: true, data: fitData};
});

exports.vortex_updateDailyTrends = onSchedule({schedule: 'every 24 hours', region: 'us-central1'}, async () => {
  const prompt = `Generate 5 current fashion trends as JSON array with:
- name
- description
- keyItems (array of 3 items)
- targetAudience (Gen Z/Millennial/etc)

Focus on: Luxury Loungewear, New Preppy, Coastal Comfort

Return ONLY valid JSON array, no markdown.`;

  const result = await model.generateContent(prompt);
  const text = result.response.candidates[0].content.parts[0].text;
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  const trends = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);

  const batch = admin.firestore().batch();
  trends.forEach(trend => {
    const trendRef = admin.firestore().collection('trends').doc();
    batch.set(trendRef, {
      ...trend,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`Updated ${trends.length} trends`);
});

exports.onImageUpload = onObjectFinalized({region: 'us-central1'}, async (event) => {
  const filePath = event.data.name;
  
  if (!filePath.includes('/wardrobe/original/')) {
    return null;
  }

  const pathParts = filePath.split('/');
  const userId = pathParts[1];
  const fileName = pathParts[pathParts.length - 1];
  const itemId = fileName.replace('.jpg', '');

  const bucket = admin.storage().bucket(event.data.bucket);
  const file = bucket.file(filePath);
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 3600000,
  });

  const prompt = `Analyze this clothing item and return JSON:
{
  "category": "top/bottom/dress/shoes/accessory",
  "color": "primary color",
  "dominantColors": ["color1", "color2"],
  "brand": "brand name or Unknown",
  "styleTag": "casual/formal/sporty/elegant",
  "tags": ["tag1", "tag2", "tag3"]
}

Return ONLY valid JSON.`;

  try {
    const result = await model.generateContent({
      contents: [{
        role: 'user',
        parts: [
          {text: prompt},
          {inlineData: {mimeType: 'image/jpeg', data: (await file.download())[0].toString('base64')}}
        ],
      }],
    });

    const text = result.response.candidates[0].content.parts[0].text;
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    const analysis = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);

    const itemsSnapshot = await admin.firestore()
      .collection('wardrobe_items')
      .where('userId', '==', userId)
      .where('storageItemId', '==', itemId)
      .limit(1)
      .get();

    if (!itemsSnapshot.empty) {
      await itemsSnapshot.docs[0].ref.update({
        ...analysis,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`AI analysis complete for item ${itemId}`);
    }
  } catch (error) {
    console.error('AI analysis failed:', error);
  }

  return null;
});

// --- NEW INTEGRATIONS ---

// 1. Google Vision AI Integration
exports.scanItemWithVision = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const { storagePath } = request.data;
  if (!storagePath) {
    throw new Error('Storage path is required');
  }

  // IDOR Protection: Ensure user can only access their own files
  if (!storagePath.startsWith(`users/${request.auth.uid}/`)) {
    throw new Error('Unauthorized access to storage path');
  }

  try {
    // SSRF Protection: Use internal gs:// URI
    const bucketName = admin.storage().bucket().name;
    const gcsUri = `gs://${bucketName}/${storagePath}`;

    // Perform label detection and logo detection
    const [result] = await visionClient.annotateImage({
      image: { source: { imageUri: gcsUri } },
      features: [
        { type: 'LABEL_DETECTION' },
        { type: 'LOGO_DETECTION' },
        { type: 'IMAGE_PROPERTIES' },
        { type: 'OBJECT_LOCALIZATION' }
      ],
    });

    const labels = result.labelAnnotations.map(label => label.description);
    const logos = result.logoAnnotations.map(logo => logo.description);
    const colors = result.imagePropertiesAnnotation.dominantColors.colors
      .sort((a, b) => b.pixelFraction - a.pixelFraction)
      .slice(0, 3)
      .map(c => `rgb(${c.color.red}, ${c.color.green}, ${c.color.blue})`);

    return {
      success: true,
      data: {
        labels,
        logos,
        dominantColors: colors,
        fullResponse: result // Optional: return full response for debugging
      }
    };
  } catch (error) {
    console.error('Google Vision API Error:', error);
    throw new Error('Failed to analyze image with Google Vision');
  }
});

// 2. PyTrends Integration (via google-trends-api for Node.js)
exports.getFashionTrends = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const { keyword = 'fashion trends', geo = 'US' } = request.data;

  try {
    const results = await googleTrends.interestOverTime({
      keyword: keyword,
      geo: geo,
      startTime: new Date(Date.now() - (30 * 24 * 60 * 60 * 1000)), // Last 30 days
    });

    const parsedResults = JSON.parse(results);
    
    // Also get related queries
    const related = await googleTrends.relatedQueries({
      keyword: keyword,
      geo: geo,
    });
    const parsedRelated = JSON.parse(related);

    return {
      success: true,
      data: {
        interestOverTime: parsedResults.default.timelineData,
        relatedQueries: parsedRelated.default.rankedList
      }
    };
  } catch (error) {
    console.error('Google Trends API Error:', error);
    throw new Error('Failed to fetch trends data');
  }
});

// 3. Shein API Integration (RapidAPI)
exports.searchShein = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const { query, limit = 20 } = request.data;
  const rapidApiKey = process.env.RAPIDAPI_KEY; // Ensure this is set in Firebase config

  if (!rapidApiKey) {
    console.warn('RAPIDAPI_KEY not set');
    // For development/demo purposes, return mock data or throw
    // throw new Error('API Key configuration missing');
  }

  try {
    const options = {
      method: 'GET',
      url: 'https://shein-business-api.p.rapidapi.com/search', // Verify endpoint
      params: {
        keywords: query,
        limit: limit,
        country: 'US',
        language: 'en'
      },
      headers: {
        'x-rapidapi-key': rapidApiKey,
        'x-rapidapi-host': 'shein-business-api.p.rapidapi.com'
      }
    };

    const response = await axios.request(options);
    return {
      success: true,
      data: response.data
    };
  } catch (error) {
    console.error('Shein API Error:', error);
    // Return a graceful error or mock data if API fails
    return {
      success: false,
      error: error.message,
      details: error.response ? error.response.data : null
    };
  }
});

// 4. Zappos API Integration (RapidAPI)
exports.searchZappos = onCall({region: 'us-central1'}, async (request) => {
  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const { query, limit = 20 } = request.data;
  const rapidApiKey = process.env.RAPIDAPI_KEY;

  try {
    const options = {
      method: 'GET',
      url: 'https://zappos1.p.rapidapi.com/search', // Verify endpoint
      params: {
        query: query,
        limit: limit,
        country: 'US'
      },
      headers: {
        'x-rapidapi-key': rapidApiKey,
        'x-rapidapi-host': 'zappos1.p.rapidapi.com'
      }
    };

    const response = await axios.request(options);
    return {
      success: true,
      data: response.data
    };
  } catch (error) {
    console.error('Zappos API Error:', error);
    return {
      success: false,
      error: error.message,
      details: error.response ? error.response.data : null
    };
  }
});
