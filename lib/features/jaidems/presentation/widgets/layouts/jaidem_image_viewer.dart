import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class JaidemImageViewer extends StatelessWidget {
  const JaidemImageViewer({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.backgroundColor,
      child: Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: AppColors.grey,
        ),
      ),
    );
  }
}
