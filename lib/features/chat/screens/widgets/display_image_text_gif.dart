import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayImageTextGif extends StatelessWidget {
  final String message;
  final String type;

  const DisplayImageTextGif({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a text message
    if (type == 'text') {
      return Text(
        message,
        style: const TextStyle(
          fontSize: 16,
        ),
      );
    }
    // Check if it's an image or gif message
    else if (type == 'image' || type == 'gif') {
      // return Image.network(message);
      return CachedNetworkImage(imageUrl: message);
    }
    // If none of the above, return an empty container (or handle other types if needed)
    return const SizedBox.shrink();
  }
}
