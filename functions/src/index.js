const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const express = require('express');

admin.initializeApp();
const app = express();

// Configuration for Cortex AI
const CORTEX_API_URL = 'https://cortex-api.googleapis.com/v1/models/cortex-vision:analyze';
const CORTEX_API_KEY = process.env.CORTEX_API_KEY || 'AQ.Ab8RN6Jre_GIXlpSyJt2oCyfbKUZNmT-Tmn73F8fK01ZSX04-A';

/**
 * Analyzes a clothing item image using Cortex AI
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
    // Call Cortex AI with timeout
    const response = await axios.post(
      `${CORTEX_API_URL}?key=${CORTEX_API_KEY}`,
      {
        image_url: imageUrl,
        task: 'clothing_analysis',
        output_format: 'json'
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 30000
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

    // Call Cortex AI with timeout
    const response = await axios.post(
      `${CORTEX_API_URL}?key=${CORTEX_API_KEY}`,
      {
        wardrobe_items: wardrobeItems.slice(0, 10),
        task: 'persona_generation',
        persona_count: 3
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 30000
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

    // Call Cortex AI with timeout
    const response = await axios.post(
      `${CORTEX_API_URL}?key=${CORTEX_API_KEY}`,
      {
        item_attributes: itemAttributes,
        personas: personas,
        task: 'persona_fit'
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 15000
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
exports.updateTrendWall = functions.scheduler
  .onSchedule('every 24 hours', async (context) => {
    try {
      // Call Cortex AI for latest trends
      const response = await axios.post(
        `${CORTEX_API_URL}?key=${CORTEX_API_KEY}`,
        {
          task: 'trend_analysis',
          focus_styles: ['Luxury Loungewear', 'New Preppy', 'Coastal Comfort'],
          trend_count: 5
        },
        {
          headers: {
            'Content-Type': 'application/json',
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
