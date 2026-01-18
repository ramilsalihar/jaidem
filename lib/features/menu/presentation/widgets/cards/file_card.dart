import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Шилтемени ачуу мүмкүн болбоду'),
                ],
              ),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Ката: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  IconData _getFileIcon() {
    final fileName = file.file?.toLowerCase() ?? '';
    if (fileName.contains('.pdf')) return Icons.picture_as_pdf_rounded;
    if (fileName.contains('.doc') || fileName.contains('.docx')) return Icons.description_rounded;
    if (fileName.contains('.xls') || fileName.contains('.xlsx')) return Icons.table_chart_rounded;
    if (fileName.contains('.ppt') || fileName.contains('.pptx')) return Icons.slideshow_rounded;
    if (fileName.contains('.jpg') || fileName.contains('.png') || fileName.contains('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Color _getFileColor() {
    final fileName = file.file?.toLowerCase() ?? '';
    if (fileName.contains('.pdf')) return const Color(0xFFE53935);
    if (fileName.contains('.doc') || fileName.contains('.docx')) return const Color(0xFF1976D2);
    if (fileName.contains('.xls') || fileName.contains('.xlsx')) return const Color(0xFF43A047);
    if (fileName.contains('.ppt') || fileName.contains('.pptx')) return const Color(0xFFFF7043);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final fileColor = _getFileColor();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (file.usefulLinks.isNotEmpty) {
          _openUrl(context, file.usefulLinks);
        } else if (file.file != null && file.file!.isNotEmpty) {
          _openUrl(context, file.file!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: fileColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: fileColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (file.subdivision.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              file.subdivision,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (file.file != null && file.file!.isNotEmpty)
                    _buildActionButton(
                      icon: Icons.download_rounded,
                      color: AppColors.green,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _openUrl(context, file.file!);
                      },
                    ),
                  if (file.usefulLinks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.open_in_new_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _openUrl(context, file.usefulLinks);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
