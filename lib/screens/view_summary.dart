import 'package:flutter/material.dart';
import 'package:SycX/models/summary.dart';
import 'package:SycX/widgets/custom_app_bar_mini.dart';
import 'package:SycX/widgets/custom_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewSummary extends StatefulWidget {
  final Summary summary;

  const ViewSummary({super.key, required this.summary});

  @override
  ViewSummaryState createState() => ViewSummaryState();
}

class ViewSummaryState extends State<ViewSummary> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _checkPdfUrl();
  }

  void _checkPdfUrl() {
    if (widget.summary.pdfUrl == null || widget.summary.pdfUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarMini(
        title: widget.summary.title ?? 'View Summary',
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: _buildPdfViewer(),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/view_summary',
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('PDF unavailable'));
    }

    // Add a Container with a defined height to constrain the PDF viewer
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
      child: SfPdfViewer.network(
        widget.summary.pdfUrl!,
        controller: _pdfViewerController,
        onDocumentLoaded: (_) => setState(() => _isLoading = false),
        onDocumentLoadFailed: (_) => setState(() => _hasError = true),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
