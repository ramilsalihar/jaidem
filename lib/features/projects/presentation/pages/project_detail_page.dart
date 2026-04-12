import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/projects/data/models/project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  bool _isInterested = false;
  int? _interestId;
  bool _isLoading = true;
  bool _isToggling = false;
  int _interestedCount = 0;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _interestedCount = widget.project.interestedCount;
    _checkInterestStatus();
  }

  Future<void> _checkInterestStatus() async {
    try {
      final userId = sl<SharedPreferences>().getString(AppConstants.userId);
      if (userId == null) return;

      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.projectInterested}',
        queryParameters: {
          'project': widget.project.id,
          'jaidemchi': userId,
        },
      );

      if (response.statusCode == 200 && mounted) {
        final results = response.data['results'] as List? ?? [];
        setState(() {
          if (results.isNotEmpty) {
            _isInterested = true;
            _interestId = results.first['id'] as int;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleInterest() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    try {
      if (_isInterested && _interestId != null) {
        // Remove interest
        await DioNetwork.appAPI.delete(
          '${ApiConst.baseUrl}${ApiConst.projectInterested}$_interestId/',
        );
        if (mounted) {
          setState(() {
            _isInterested = false;
            _interestId = null;
            _interestedCount--;
            _changed = true;
          });
        }
      } else {
        // Express interest
        final response = await DioNetwork.appAPI.post(
          '${ApiConst.baseUrl}${ApiConst.projectInterested}',
          data: {
            'project': widget.project.id,
            'jaidemchi': int.tryParse(sl<SharedPreferences>().getString(AppConstants.userId) ?? '') ?? 0,
          },
        );
        if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
          setState(() {
            _isInterested = true;
            _interestId = response.data['id'] as int;
            _interestedCount++;
            _changed = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final plainText = _stripHtml(project.text);
    final hasImages = project.images.isNotEmpty;

    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(_changed);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade700, size: 22),
            ),
          ),
          title: Text(
            context.tr('projects'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              if (hasImages)
                SizedBox(
                  height: 220,
                  child: project.images.length == 1
                      ? Image.network(
                          project.images.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : PageView.builder(
                          itemCount: project.images.length,
                          itemBuilder: (context, index) => Image.network(
                            project.images[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          ),
                        ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date + interested count
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(project.dateCreated),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                        if (_interestedCount > 0) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.people_outline_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '$_interestedCount ${context.tr('interested')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full description
                    if (plainText.isNotEmpty)
                      Text(
                        plainText,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Interested button
                    _buildInterestedButton(),

                    SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 220,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.primary, size: 40),
      ),
    );
  }

  Widget _buildInterestedButton() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _isToggling ? null : () {
        HapticFeedback.mediumImpact();
        _toggleInterest();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isInterested ? Colors.grey.shade100 : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: _isInterested
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isToggling)
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isInterested ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
              )
            else
              Icon(
                _isInterested ? Icons.check_circle_rounded : Icons.star_rounded,
                color: _isInterested ? Colors.grey.shade600 : Colors.white,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              _isInterested
                  ? context.tr('not_interested')
                  : context.tr('i_am_interested'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isInterested ? Colors.grey.shade600 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
