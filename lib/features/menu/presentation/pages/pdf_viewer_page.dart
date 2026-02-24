import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  final String pdfUrl;
  final String title;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    try {
      final uri = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Жүктөө мүмкүн болбоду: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _sharePdf() {
    Share.share(widget.pdfUrl, subject: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => context.router.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                '$_currentPage / $_totalPages',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: Colors.grey.shade700),
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: Colors.grey.shade700),
            onPressed: _downloadPdf,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PDF жүктөлбөй калды',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _error = null;
                          _isLoading = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.shade300],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Кайра аракет',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SfPdfViewer.network(
              widget.pdfUrl,
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _isLoading = false;
                  _totalPages = details.document.pages.count;
                });
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _isLoading = false;
                  _error = details.description;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          if (_isLoading && _error == null)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PDF жүктөлүүдө...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _error == null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildZoomButton(
                      icon: Icons.zoom_out_rounded,
                      onTap: () {
                        if (_pdfViewerController.zoomLevel > 1) {
                          _pdfViewerController.zoomLevel -= 0.25;
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildZoomButton(
                      icon: Icons.first_page_rounded,
                      onTap: () => _pdfViewerController.firstPage(),
                    ),
                    const SizedBox(width: 8),
                    _buildZoomButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _pdfViewerController.previousPage(),
                    ),
                    const SizedBox(width: 8),
                    _buildZoomButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _pdfViewerController.nextPage(),
                    ),
                    const SizedBox(width: 8),
                    _buildZoomButton(
                      icon: Icons.last_page_rounded,
                      onTap: () => _pdfViewerController.lastPage(),
                    ),
                    const SizedBox(width: 16),
                    _buildZoomButton(
                      icon: Icons.zoom_in_rounded,
                      onTap: () {
                        if (_pdfViewerController.zoomLevel < 3) {
                          _pdfViewerController.zoomLevel += 0.25;
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.grey.shade700,
          size: 24,
        ),
      ),
    );
  }
}
