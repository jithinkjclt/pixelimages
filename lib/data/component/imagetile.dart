import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile(
      {Key? key, required this.url, required this.height, required this.onTap})
      : super(key: key);
  final String url;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            url,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(

              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
