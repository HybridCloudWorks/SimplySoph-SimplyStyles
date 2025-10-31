const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// Configuration for Gemini Cortex AI
const GEMINI_CORTEX_API_URL = 'https://your-gemini-cortex-endpoint.com/api';
const GEMINI_CORTEX_API_KEY = functions.config().gemini.apikey;

/**
 * Analyzes a clothing item image using Gemini Cortex AI
 */
exports.analyzeClothingItem = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to analyze items.'
    );
  }

  const { imageUrl, userPreferences } = data;

  if (!imageUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Image URL is required.'
    );
  }

  try {
    // Call Gemini Cortex AI
    const response = await axios.post(
      `${GEMINI_CORTEX_API_URL}/analyze-clothing`,
      {
        imageUrl: imageUrl,
        task: 'clothing_analysis',
        preferences: userPreferences || {},
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${GEMINI_CORTEX_API_KEY}`,
        },
      }
    );

    return {
      success: true,
      data: response.data,
    };
  } catch (error) {
    console.error('Error analyzing clothing item:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to analyze clothing item.',
      error.message
    );
  }
});

/**
 * Generates style personas based on user's wardrobe
 */
exports.generateStylePersonas = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated.'
    );
  }

  const userId = context.auth.uid;

  try {
    // Fetch user's wardrobe items
    const wardrobeSnapshot = await admin
      .firestore()
      .collection('wardrobe_items')
      .where('userId', '==', userId)
      .get();

    const wardrobeItems = wardrobeSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    if (wardrobeItems.length < 5) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Need at least 5 items to generate personas.'
      );
    }

    // Call Gemini Cortex AI
    const response = await axios.post(
      `${GEMINI_CORTEX_API_URL}/generate-personas`,
      {
        wardrobeItems: wardrobeItems,
        task: 'persona_generation',
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${GEMINI_CORTEX_API_KEY}`,
        },
      }
    );

    const personas = response.data.personas || [];

    // Save personas to Firestore
    const batch = admin.firestore().batch();
    
    // Delete existing personas
    const existingPersonas = await admin
      .firestore()
      .collection('style_personas')
      .where('userId', '==', userId)
      .get();
    
    existingPersonas.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // Add new personas
    personas.forEach(persona => {
      const personaRef = admin.firestore().collection('style_personas').doc();
      batch.set(personaRef, {
        userId: userId,
        ...persona,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();

    return {
      success: true,
      personaCount: personas.length,
    };
  } catch (error) {
    console.error('Error generating personas:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to generate personas.',
      error.message
    );
  }
});

/**
 * Calculates how well an item fits with user's personas
 */
exports.calculatePersonaFit = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated.'
    );
  }

  const userId = context.auth.uid;
  const { itemAttributes } = data;

  if (!itemAttributes) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Item attributes are required.'
    );
  }

  try {
    // Fetch user's personas
    const personasSnapshot = await admin
      .firestore()
      .collection('style_personas')
      .where('userId', '==', userId)
      .get();

    const personas = personasSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    if (personas.length === 0) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'No personas found. Please build your wardrobe first.'
      );
    }

    // Call Gemini Cortex AI
    const response = await axios.post(
      `${GEMINI_CORTEX_API_URL}/calculate-fit`,
      {
        itemAttributes: itemAttributes,
        personas: personas,
        task: 'persona_fit',
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${GEMINI_CORTEX_API_KEY}`,
        },
      }
    );

    return {
      success: true,
      data: response.data,
    };
  } catch (error) {
    console.error('Error calculating persona fit:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to calculate persona fit.',
      error.message
    );
  }
});

/**
 * Scheduled function to update trend wall daily
 */
exports.updateTrendWall = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      // Call Gemini Cortex AI for latest trends
      const response = await axios.post(
        `${GEMINI_CORTEX_API_URL}/analyze-trends`,
        {
          task: 'trend_discovery',
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${GEMINI_CORTEX_API_KEY}`,
          },
        }
      );

      const trends = response.data.trends || [];

      // Update Firestore
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
      return null;
    } catch (error) {
      console.error('Error updating trend wall:', error);
      return null;
    }
  });
