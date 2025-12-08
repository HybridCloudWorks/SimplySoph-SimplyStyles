const {onCall} = require('firebase-functions/v2/https');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onObjectFinalized} = require('firebase-functions/v2/storage');
const admin = require('firebase-admin');
const {VertexAI} = require('@google-cloud/vertexai');

admin.initializeApp();

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

  const {imageUrl} = request.data;
  if (!imageUrl) {
    throw new Error('Image URL is required');
  }

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
        {fileData: {mimeType: 'image/jpeg', fileUri: imageUrl}}
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
    .map(item => `${item.category}: ${item.color} ${item.style}`)
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

  personas.forEach(persona => {
    const personaRef = admin.firestore().collection('style_personas').doc();
    batch.set(personaRef, {
      userId,
      ...persona,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

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
