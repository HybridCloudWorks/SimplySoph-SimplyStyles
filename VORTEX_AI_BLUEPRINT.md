# The "Vortex" AI: A Hybrid Pipeline Strategy

This document outlines the technical blueprint for the V1.0 AI engine, codenamed "The Vortex." Our goal is an asynchronous microservice that provides a "magical" user experience without compromising privacy or app performance. The app should upload a photo and immediately return to its main screen. The user will receive a push notification when the analysis is complete.

This "off-device" processing feels professional and doesn't drain the user's battery.

## Pipeline Stages

A single API will not suffice. The "Vortex" is an **orchestrator** that intelligently combines several best-in-class tools for distinct jobs.

### 1. The "Safety" Pre-Scan (On-Device)

Before an image ever leaves the user's phone, we will perform a high-speed, on-device check for privacy.

*   **Job:** Detect if a person or face is in the shot.
*   **Technology:** TensorFlow Lite (Android/Flutter) / Core ML (iOS).
*   **Why:**
    *   **Innovation & Trust:** This allows us to truthfully claim, "We don't even see your un-redacted photos." It's a massive privacy win.
    *   **Speed:** The check is instant, allowing the app to provide immediate feedback (e.g., "Please crop out your face before uploading!").
    *   **Clean Code:** This logic lives entirely within the mobile app, completely separate from our backend systems.

### 2. The "Vortex" Orchestrator (Backend Microservice)

This is the "brain" of the operation. It's a small, separate service that manages the AI tasks.

*   **Job:** To receive a safe image URL, send it to other APIs, and "translate" the raw results into our app's specific language (i.e., our "Persona" metrics).
*   **Technology:** Python (FastAPI) or Node.js (TypeScript) running on a serverless platform like Google Cloud Run or as a Firebase Cloud Function.
*   **Why:**
    *   **Innovation:** FastAPI is the modern standard for high-performance, AI-driven APIs.
    *   **Clean Code & Scalability:** This service is stateless and can be scaled near-infinitely. We can update our AI logic (e.g., swap out an API) here, and the mobile app never has to change.

### 3. The "Heavy Lifter" (External API)

This is where the core V1.0 AI processing power comes from. The "Vortex" service will call this API.

*   **Job:** Identify objects, colors, and potentially brands from the image.
*   **Recommended API:** **Google Cloud Vision API.**
*   **Why:**
    *   **Object Detection:** It provides specific labels like "v-neck sweater" or "high-heeled shoes" with bounding boxes, not just "clothing."
    *   **Color Properties:** It extracts dominant colors and their pixel fractions (e.g., 70% blue, 20% white), which is perfect for our Persona metrics.
    *   **Logo Detection:** It has excellent capabilities for identifying brand logos.

### 4. The "Style" Hack (V1.0 Logic)

Google Vision is not designed to understand subjective "style" (like "boho" or "edgy"). For V1.0, we will **infer** style within our Vortex service. This becomes our "secret sauce."

*   **Logic Example:**
    *   `IF (object = "leather jacket" AND color = "black") THEN style.append("Edgy")`
    *   `IF ("Floral" in image_text_annotations) THEN style.append("Boho")`

### 5. The "Stock Photo" Finder (External API)

*   **Job:** Find a clean, professional photo of the item to replace the user's original (and likely imperfect) photo. This makes the digital closet look beautiful.
*   **Technology:** **Google Custom Search API**, filtered to only search specific high-quality retail or stock photo sites.

---

## "Clean Code" Architecture: V1.0 Blueprint

### 1. Mobile App (Flutter)

```dart
// Pseudocode for the "Upload" button
Future<void> onUploadPressed(ImageFile image) async {

    // STEP 1: On-Device Safety Scan
    bool hasFace = await TFLite.detectFaces(image);
    if (hasFace) {
        showFaceWarningPopup();
        return; // Stop!
    }

    // If safe, upload to our secure storage (e.g., Firebase Storage)
    String uploadedImageUrl = await FirebaseStorage.upload(image);

    // STEP 2: Trigger the "Vortex" microservice (and forget)
    // We don't wait for the result. We just tell it to start.
    await Api.triggerVortexAnalysis(imageUrl: uploadedImageUrl, userId: user.id);

    // Go back to the closet. The app feels "fast."
    showToast("Adding your item! We'll notify you when it's ready.");
    Navigator.pop();
}
```

### 2. "Vortex" Microservice (Python / FastAPI)

```python
# main.py (FastAPI service)
# Dependencies: fastapi, uvicorn, google-cloud-vision

from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import google.cloud.vision as vision

app = FastAPI()

# Pydantic model ensures "clean" data
class ImageProcessRequest(BaseModel):
    imageUrl: str
    userId: str

@app.post("/analyze-item")
async def analyze_item(request: ImageProcessRequest):
    """
    This is our main orchestration endpoint.
    It's triggered by the app after a safe upload.
    """
    
    # STEP 3: Call the "Heavy Lifter" (Google Vision)
    client = vision.ImageAnnotatorClient()
    image = vision.Image()
    image.source.image_uri = request.imageUrl

    response = client.annotate_image({
        'image': image,
        'features': [
            {'type_': vision.Feature.Type.OBJECT_LOCALIZATION},
            {'type_': vision.Feature.Type.IMAGE_PROPERTIES},
            {'type_': vision.Feature.Type.LOGO_DETECTION},
        ],
    })

    # STEP 4: "Translate" results into our Persona metrics
    metrics = translate_vision_to_persona(response)

    # STEP 5: Find a stock photo
    stock_photo_url = find_stock_photo(metrics.get('brand'), metrics.get('object_name'))

    # STEP 6: Save to the user's database
    save_to_database(
        user_id=request.userId,
        metrics=metrics,
        display_image_url=stock_photo_url
    )
    
    # STEP 7: Send a push notification to the user
    send_push_notification(request.userId, "Your new item is ready!")

    return {"status": "success"}

def translate_vision_to_persona(response):
    """
    This is our V1.0 "Secret Sauce".
    This is pure business logic, not ML.
    """
    metrics = {'colors': [], 'brand': 'Unknown', 'object_name': 'Clothing', 'styles': []}
    
    # Logic to parse Google's complex response...
    # ...
    
    # Our "Style" hack
    if metrics.get('object_name') == 'Leather Jacket':
        metrics['styles'].append('Edgy')
    if response.text_annotations and 'Floral' in response.text_annotations[0].description: # Read text
        metrics['styles'].append('Boho')

    return metrics

# ... (other helper functions for DB, push notifications, etc.)

```

---

## Key Dependencies for Research & Development

*   **On-Device:** `tensorflow-lite` (Flutter) or `CoreML` (Swift).
*   **Backend Service:** `fastapi`, `uvicorn`, `pydantic` (Python).
*   **Cloud AI:** `google-cloud-vision` (Python/Node.js library).
*   **Search:** `google-api-python-client` (for Custom Search API).
