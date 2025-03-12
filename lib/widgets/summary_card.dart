import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:sycx_flutter_app/models/summary.dart';
import 'package:sycx_flutter_app/services/unsplash.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/screens/summary_details.dart';

class SummaryCard extends StatefulWidget {
  final Summary summary;
  final Function(String) onTogglePin;
  final bool isEmpty;

  const SummaryCard({
    super.key,
    required this.summary,
    required this.onTogglePin,
    this.isEmpty = false,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchRandomImage();
  }

  Future<void> _fetchRandomImage() async {
    final title = _getCardTitle();
    final imageUrl = await Unsplash.getRandomImageUrl(title);
    if (imageUrl != null) {
      setState(() {
        _imageUrl = imageUrl;
      });
    } else {
      // Fetch fallback image URL based on the file type of the first original document
      final fallbackImageUrl = await Unsplash.getFallbackImageUrl(
        widget.summary.originalDocuments.isNotEmpty
            ? widget.summary.originalDocuments.first.type ?? ''
            : '',
      );
      setState(() {
        _imageUrl = fallbackImageUrl;
      });
    }
  }

  /// Determine the card's display title
  String _getCardTitle() {
    // Handle empty card state
    if (widget.isEmpty) return 'Create Summary';

    // Prioritize title from the summary model
    return widget.summary.title ??
        (widget.summary.originalDocuments.isNotEmpty
            ? widget.summary.originalDocuments.first.title
            : 'Untitled');
  }

  /// Format the creation date for display
  String _getFormattedDate() {
    try {
      return DateFormat('MMM d, yyyy').format(widget.summary.createdAt);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Date not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Empty state card (create new summary)
    if (widget.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed('/upload'),
        child: _buildCardContent(context),
      );
    }

    // Regular summary card with detail view navigation
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, _) => SummaryDetails(
        summary: widget.summary,
        imageUrl: _imageUrl ?? '',
      ),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: _buildCardContent(context),
      ),
    );
  }

  /// Build the main card content
  Widget _buildCardContent(BuildContext context) {
    final cardTitle = _getCardTitle();
    final dateStr = _getFormattedDate();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCardImage(cardTitle),
                _buildGradientOverlay(),
                _buildCardInfo(cardTitle, dateStr),
              ],
            ),
          ),
        ),
        // Pin button only for non-empty cards
        if (!widget.isEmpty) _buildPinButton(),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(String title, String date) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subheadingStyle.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEmpty
                      ? 'Create your first summary!'
                      : 'Created on $date',
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () => widget.onTogglePin(widget.summary.id),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            widget.summary.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            key: ValueKey<bool>(widget.summary.isPinned),
            color: AppColors.primaryButtonColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String title) {
    if (_imageUrl != null) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackImage(title),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
      );
    }

    return _buildFallbackImage(title);
  }

  Widget _buildFallbackImage(String title) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.description,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
