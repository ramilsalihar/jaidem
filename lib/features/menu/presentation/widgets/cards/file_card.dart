import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FileCard extends StatelessWidget {
  const FileCard({super.key, required this.file});

  final FileModel file;

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось открыть ссылку'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (file.usefulLinks.isNotEmpty) {
          _openUrl(context, file.usefulLinks);
        } else if (file.file != null && file.file!.isNotEmpty) {
          // If no useful link but has a file, open the file URL
          _openUrl(context, file.file!);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Left side - Title
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.title,
                    style: context.textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Middle - Subdivision
            Expanded(
              flex: 2,
              child: Text(
                file.subdivision,
                style: context.textTheme.headlineSmall,
              ),
            ),

            const SizedBox(width: 12),

            // Right side - Icons
            Row(
              children: [
                // PDF Icon
                if (file.file != null && file.file!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _openUrl(context, file.file!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/icons/file.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Handle bookmark functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Закладка добавлена'),
                        duration: Duration(seconds: 1),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}