import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom clipper that clips a circular segment defined by [startAngle] and [sweepAngle].
class SegmentClipper extends CustomClipper<Path> {
  final double startAngle; // in radians
  final double sweepAngle; // in radians

  SegmentClipper(this.startAngle, this.sweepAngle);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Draw a pie slice from the center using the arc
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SegmentClipper oldClipper) {
    return oldClipper.startAngle != startAngle ||
        oldClipper.sweepAngle != sweepAngle;
  }
}

/// A widget that displays a circle divided into segments, each showing a different image.
/// Supports 1 to 4 images, and adjusts each image so that its center aligns with the center
/// (centroid) of its corresponding segment.
class MultiImageAvatar extends StatelessWidget {
  final List<String> imageUrls;
  final double size;

  const MultiImageAvatar({
    super.key,
    required this.imageUrls,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrls[0]),
      );
    }

    // Validate the number of images (supports 1 to 4 images)
    if (imageUrls.isEmpty || imageUrls.length > 4) {
      throw Exception('MultiImageAvatar supports 1 to 4 images.');
    }

    final int count = imageUrls.length;
    final double sweepAngle = 2 * math.pi / count;
    final double radius = size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          children: List.generate(count, (index) {
            final double startAngle = sweepAngle * index;
            // Calculate the middle (bisector) angle for this segment.
            final double midAngle = startAngle + sweepAngle / 2;

            // Calculate the distance from the circle's center to the centroid of the segment.
            // For a circular sector, the centroid is at: (2R * sin(θ/2)) / (3*(θ/2))
            final double d = (2 * radius * math.sin(sweepAngle / 2)) /
                (3 * (sweepAngle / 2));

            // Compute the offset from the overall center that will place the image's center
            // at the centroid of this segment.
            final double offsetX = d * math.cos(midAngle);
            final double offsetY = d * math.sin(midAngle);

            return ClipPath(
              clipper: SegmentClipper(startAngle, sweepAngle),
              child: Transform.translate(
                offset: Offset(offsetX, offsetY),
                // The image is sized to cover the whole circle.
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
