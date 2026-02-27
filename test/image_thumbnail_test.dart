import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// We will test the logic that we plan to extract.
// For now, I'll just write a test that simulates the resizing operation
// to ensure I understand how the 'image' package works and to have a baseline.

void main() {
  test('Image resizing logic works correctly', () {
    // 1. Create a large dummy image (e.g. 1000x1000)
    final originalImage = img.Image(width: 1000, height: 1000);
    // Fill with some color
    img.fill(originalImage, color: img.ColorRgb8(255, 0, 0));

    // Encode to JPG as the service expects Uint8List bytes
    final originalBytes = Uint8List.fromList(img.encodeJpg(originalImage));

    // 2. Perform the resizing logic (mirrors what is in ImageService)
    final decodedImage = img.decodeImage(originalBytes);
    expect(decodedImage, isNotNull);

    const thumbnailSize = 300;

    // Resize maintaining aspect ratio
    final thumbnail = img.copyResize(
      decodedImage!,
      width: decodedImage.width > decodedImage.height ? thumbnailSize : null,
      height: decodedImage.height >= decodedImage.width ? thumbnailSize : null,
    );

    // 3. Verify the result
    expect(thumbnail.width, thumbnailSize);
    expect(thumbnail.height, thumbnailSize);

    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);
    expect(thumbnailBytes, isNotEmpty);
    expect(thumbnailBytes.length, lessThan(originalBytes.length));
  });
}
