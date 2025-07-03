import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
  // Cache for custom markers to avoid recreating them
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Creates a custom marker with restaurant/brand logo
  static Future<BitmapDescriptor> createCustomMarker({
    required String logoAssetPath,
    required Color backgroundColor,
    required Color borderColor,
    double size = 120,
    double logoSize = 60,
  }) async {
    final String cacheKey = '${logoAssetPath}_${backgroundColor.value}_${borderColor.value}_${size}_${logoSize}';
    
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(2, 2), radius - 5, paint);

    // Draw main circle background
    paint.maskFilter = null;
    paint.color = backgroundColor;
    canvas.drawCircle(center, radius - 5, paint);

    // Draw border
    paint.color = borderColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawCircle(center, radius - 5, paint);

    // Load and draw logo
    try {
      final ByteData data = await rootBundle.load(logoAssetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: logoSize.toInt(),
        targetHeight: logoSize.toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image logoImage = frameInfo.image;

      final double logoOffset = (size - logoSize) / 2;
      canvas.drawImage(
        logoImage,
        Offset(logoOffset, logoOffset),
        Paint(),
      );
    } catch (e) {
      // Fallback: draw a simple icon if logo loading fails
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white;
      canvas.drawCircle(center, logoSize / 3, paint);
    }

    // Draw pointer at bottom
    final Path pointer = Path();
    pointer.moveTo(center.dx, size - 5);
    pointer.lineTo(center.dx - 15, radius + 10);
    pointer.lineTo(center.dx + 15, radius + 10);
    pointer.close();

    paint.style = PaintingStyle.fill;
    paint.color = backgroundColor;
    canvas.drawPath(pointer, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = borderColor;
    paint.strokeWidth = 3;
    canvas.drawPath(pointer, paint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final BitmapDescriptor marker = BitmapDescriptor.fromBytes(pngBytes);
    _markerCache[cacheKey] = marker;
    return marker;
  }

  /// Creates a simple colored marker for categories
  static Future<BitmapDescriptor> createSimpleMarker({
    required Color color,
    double size = 100,
    String? text,
  }) async {
    final String cacheKey = 'simple_${color.value}_${size}_${text ?? ''}';
    
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius * 0.8);

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(2, 2), radius * 0.7, paint);

    // Draw main circle
    paint.maskFilter = null;
    paint.color = color;
    canvas.drawCircle(center, radius * 0.7, paint);

    // Draw border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.7, paint);

    // Draw text if provided
    if (text != null && text.isNotEmpty) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw pointer
    final Path pointer = Path();
    pointer.moveTo(center.dx, size - 10);
    pointer.lineTo(center.dx - 12, center.dy + radius * 0.7 - 5);
    pointer.lineTo(center.dx + 12, center.dy + radius * 0.7 - 5);
    pointer.close();

    paint.style = PaintingStyle.fill;
    paint.color = color;
    canvas.drawPath(pointer, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    canvas.drawPath(pointer, paint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final BitmapDescriptor marker = BitmapDescriptor.fromBytes(pngBytes);
    _markerCache[cacheKey] = marker;
    return marker;
  }

  /// Creates a cluster marker for multiple items
  static Future<BitmapDescriptor> createClusterMarker({
    required int count,
    required Color color,
    double size = 100,
  }) async {
    final String cacheKey = 'cluster_${count}_${color.value}_${size}';
    
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(2, 2), radius - 5, paint);

    // Draw outer ring
    paint.maskFilter = null;
    paint.color = color.withOpacity(0.3);
    canvas.drawCircle(center, radius - 5, paint);

    // Draw inner circle
    paint.color = color;
    canvas.drawCircle(center, radius * 0.6, paint);

    // Draw border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.6, paint);

    // Draw count text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final BitmapDescriptor marker = BitmapDescriptor.fromBytes(pngBytes);
    _markerCache[cacheKey] = marker;
    return marker;
  }

  /// Clears the marker cache to free memory
  static void clearCache() {
    _markerCache.clear();
  }
}
