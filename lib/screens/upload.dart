import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sycx_flutter_app/services/database.dart';
import 'package:sycx_flutter_app/services/summary.dart';
import 'package:sycx_flutter_app/utils/constants.dart';
import 'package:sycx_flutter_app/widgets/animated_button.dart';
import 'package:sycx_flutter_app/widgets/custom_app_bar.dart';
import 'package:sycx_flutter_app/widgets/custom_bottom_nav_bar.dart';
import 'package:sycx_flutter_app/widgets/loading.dart';
import 'package:sycx_flutter_app/widgets/padded_round_slider_value_indicator_shape.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:sycx_flutter_app/models/user.dart' as app_user;

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  UploadState createState() => UploadState();
}

class UploadState extends State<Upload> with TickerProviderStateMixin {
  List<PlatformFile> uploadedFiles = [];
  double summaryDepth = 1.0;
  bool isLoading = false;
  late AnimationController _animationController;
  late AnimationController _loadingAnimationController;
  late AnimationController _deleteAnimationController;
  late AnimationController _previewAnimationController;
  PlatformFile? _previewFile;
  dynamic _filePreviewContent;
  PdfViewerController? _pdfViewerController;

  int _currentPdfPage = 1;
  int _totalPdfPages = 0;

  static int maxFileSize = 1024 * 1024 * 1024; // 1GB

  // User data
  app_user.User? _currentUser;
  final Database _database = Database();

  String _getSummaryDepthLabel() {
    switch (summaryDepth.round()) {
      case 0:
        return 'Minimal';
      case 1:
        return 'Short';
      case 2:
        return 'Medium';
      case 3:
        return 'Standard';
      case 4:
        return 'Comprehensive';
      default:
        return 'Default';
    }
  }

  String _getDetailRetained() {
    switch (summaryDepth.round()) {
      case 0:
        return '5-10%';
      case 1:
        return '10-20%';
      case 2:
        return '20-30%';
      case 3:
        return '30-40%';
      case 4:
        return '40-60%';
      default:
        return '15-25%';
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _deleteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _previewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _pdfViewerController = PdfViewerController();
    _loadUserData();
    CustomBottomNavBar.updateLastMainRoute('/upload');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingAnimationController.dispose();
    _deleteAnimationController.dispose();
    _previewAnimationController.dispose();
    _pdfViewerController?.dispose();
    super.dispose();
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'rtf',
        'odt',
        'html',
        'htm',
        'pptx',
        'ppt',
        'xlsx',
        'xls',
        'jpg',
        'jpeg',
        'png',
        'webp'
      ],
    );

    if (result != null) {
      // Validate file sizes before adding to uploadedFiles
      final validFiles = result.files.where((file) {
        if (file.size > maxFileSize) {
          Fluttertoast.showToast(
            msg: "File ${file.name} exceeds 1GB limit",
            toastLength: Toast.LENGTH_LONG,
          );
          return false;
        }
        return true;
      }).toList();

      setState(() {
        uploadedFiles = validFiles;
      });
    }
  }

  void removeFile(int index) {
    setState(() {
      uploadedFiles.removeAt(index);
    });
  }

  Future<void> _loadUserData() async {
    try {
      // Get the current user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final user = await _database.getUser(firebaseUser.uid);
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> summarize() async {
    // Validate file upload
    if (uploadedFiles.isEmpty) {
      Fluttertoast.showToast(msg: "Please upload at least one file");
      return;
    }

    setState(() {
      isLoading = true;
    });
    _loadingAnimationController.forward();

    try {
      // Convert PlatformFile to File for API upload
      final fileInputs =
          await Future.wait(uploadedFiles.map((platformFile) async {
        final file = File(platformFile.path!);
        return file;
      }));

      final summaries = await SummaryService.summarizeDocuments(
        files: fileInputs,
        summaryDepth: summaryDepth,
        userId: _currentUser!.id,
      );

      setState(() {
        isLoading = false;
      });
      _loadingAnimationController.reverse();
      if (mounted) {
        Navigator.pushNamed(context, '/summaries', arguments: summaries);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _loadingAnimationController.reverse();
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _loadFilePreview(PlatformFile file) async {
    setState(() {
      _filePreviewContent = null;
      _currentPdfPage = 1;
      _totalPdfPages = 0;
    });

    switch (file.extension?.toLowerCase()) {
      case 'txt':
      case 'md':
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
      case 'js':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'swift':
      case 'kt':
      case 'rb':
      case 'php':
      case 'sql':
        final content = await File(file.path!).readAsString();
        setState(() {
          _filePreviewContent = content;
        });
        break;
      case 'pdf':
        setState(() {
          _filePreviewContent = 'pdf';
        });
        break;
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
        setState(() {
          _filePreviewContent =
              "Preview not available for this file type. Please use a specialized viewer.";
        });
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        setState(() {
          _filePreviewContent = File(file.path!);
        });
        break;
      case 'svg':
        final content = await File(file.path!).readAsString();
        setState(() {
          _filePreviewContent = content;
        });
        break;
      default:
        setState(() {
          _filePreviewContent = "Preview not available for this file type.";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        user: _currentUser,
        showBackground: false,
        title: 'SycX',
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          if (isLoading) const Loading(),
          if (_previewFile != null) _buildPreviewOverlay(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentRoute: '/upload',
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    final size = MediaQuery.of(context).size;
    final previewHeight = size.height * 0.78;
    final previewWidth = size.width * 0.98;

    return AnimatedBuilder(
      animation: _previewAnimationController,
      builder: (context, child) {
        return Positioned(
          top: (size.height - previewHeight) / 2,
          left: (size.width - previewWidth) / 2,
          child: GestureDetector(
            onTap: () {
              _previewAnimationController.reverse().then((_) {
                setState(() {
                  _previewFile = null;
                  _filePreviewContent = null;
                });
              });
            },
            child: AnimatedOpacity(
              opacity: _previewAnimationController.value,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: previewWidth,
                      height: previewHeight,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFillColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Preview: ${_previewFile!.name}',
                                    style: AppTextStyles.titleStyle.copyWith(
                                        color: AppColors.primaryTextColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryButtonColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: AppColors.primaryTextColor),
                                    onPressed: () {
                                      _previewAnimationController
                                          .reverse()
                                          .then((_) {
                                        setState(() {
                                          _previewFile = null;
                                          _filePreviewContent = null;
                                        });
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildPreviewContent(
                                previewWidth, previewHeight - 60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(double width, double height) {
    if (_filePreviewContent == null) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Preview content is null',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    }

    if (_filePreviewContent == 'pdf') {
      return Column(
        children: [
          Expanded(
            child: SfPdfViewer.file(
              File(_previewFile!.path!),
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _totalPdfPages = details.document.pages.count;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPdfPage = details.newPageNumber;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentPdfPage > 1
                    ? () => _pdfViewerController?.previousPage()
                    : null,
              ),
              Text('$_currentPdfPage / $_totalPdfPages'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _currentPdfPage < _totalPdfPages
                    ? () => _pdfViewerController?.nextPage()
                    : null,
              ),
            ],
          ),
        ],
      );
    }

    if (_filePreviewContent is String) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _filePreviewContent as String,
            style: AppTextStyles.bodyTextStyle,
          ),
        ),
      );
    } else if (_filePreviewContent is File) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.file(
          _filePreviewContent as File,
          fit: BoxFit.contain,
        ),
      );
    } else if (_previewFile!.extension?.toLowerCase() == 'svg') {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: SvgPicture.string(
          _filePreviewContent as String,
          fit: BoxFit.contain,
        ),
      );
    } else if (_filePreviewContent is Image) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: _filePreviewContent,
      );
    } else {
      return Center(
        child: Text(
          "Preview not available for this file type.",
          style: AppTextStyles.bodyTextStyle,
        ),
      );
    }
  }

  Widget _buildUploadedFiles() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Files (${uploadedFiles.length} files)',
                style: AppTextStyles.titleStyle,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    uploadedFiles.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: AppTextStyles.buttonTextStyle,
                ),
              ),
            ],
          ),
          uploadedFiles.isEmpty
              ? Card(
                  elevation: 2,
                  color: AppColors.textFieldFillColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    leading: const Icon(
                      Icons.cloud_upload,
                      color: AppColors.primaryButtonColor,
                      size: 28,
                    ),
                    title: Text(
                      "No files uploaded yet",
                      style: AppTextStyles.bodyTextStyle,
                    ),
                    subtitle: Text(
                      "Upload files to see them here",
                      style: AppTextStyles.bodyTextStyle.copyWith(
                        color: AppColors.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: uploadedFiles.length,
                  itemBuilder: (context, index) {
                    final file = uploadedFiles[index];
                    return AnimatedBuilder(
                      animation: _deleteAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 1 - _deleteAnimationController.value,
                          child: Transform.scale(
                            scale: 1 - (_deleteAnimationController.value * 0.2),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        color: AppColors.textFieldFillColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Icon(_getFileIcon(file.extension),
                              color: AppColors.gradientMiddle),
                          title: Text(file.name,
                              style: AppTextStyles.bodyTextStyle),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: AppTextStyles.bodyTextStyle.copyWith(
                                  color: AppColors.secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Wrap(
                                spacing: 4,
                                children: [
                                  _buildTag('Document'),
                                  const SizedBox(
                                    width: 1.5,
                                  ),
                                  _buildTag(file.extension?.toUpperCase() ??
                                      'Unknown'),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.gradientEnd),
                                onPressed: () => removeFile(index),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _previewFile = file as PlatformFile?;
                            });
                            _loadFilePreview(file);
                            _previewAnimationController.forward();
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInstructions(),
                const SizedBox(height: defaultMargin),
                _buildUploadArea(),
                const SizedBox(height: defaultMargin),
                _buildUploadedFiles(),
                const SizedBox(height: defaultMargin),
                _buildSummarizationPreferences(),
                const SizedBox(height: defaultMargin),
                _buildSummarizeButton(),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController, curve: Curves.easeOut))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.easeOut))
                .value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Content',
              style: AppTextStyles.headingStyleWithShadow,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your files and let SycX summarize them for you.',
              style: AppTextStyles.subheadingStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: Card(
        color: AppColors.textFieldFillColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.gradientStart, size: 34),
                  const SizedBox(width: 12),
                  Text(
                    'How to use:',
                    style: AppTextStyles.titleStyle.copyWith(
                      color: AppColors.primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildInstructionStep(
                      '1', 'Upload file', 'Tap "Upload" and select document.'),
                  _buildInstructionStep(
                      '2', 'Preview', 'Tap file cards to view contents.'),
                  _buildInstructionStep(
                      '3', 'Manage', 'Remove files using the delete icon.'),
                  _buildInstructionStep(
                      '4', 'Clear all', 'Use "Clear All" to remove all files.'),
                  _buildInstructionStep(
                      '5', 'Set depth', 'Adjust slider for summary detail.'),
                  _buildInstructionStep(
                      '6', 'Generate', 'Tap "Summarize" to process files.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyTextStyle.copyWith(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: pickFiles,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            padding: const EdgeInsets.all(2),
            color: AppColors.textFieldBorderColor,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload,
                        size: 48, color: AppColors.gradientStart),
                    const SizedBox(height: 16),
                    Text(
                      'Click to Upload',
                      style: AppTextStyles.bodyTextStyle.copyWith(
                        color: AppColors.textFieldFillColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supports multiple file types',
                      style: AppTextStyles.bodyTextStyle.copyWith(
                        color: AppColors.textFieldFillColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gradientMiddle.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyTextStyle.copyWith(
          fontSize: 10,
          color: AppColors.primaryTextColor,
        ),
      ),
    );
  }

  Widget _buildSummarizationPreferences() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.8, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary Depth',
            style: AppTextStyles.titleStyle
                .copyWith(color: AppColors.primaryTextColorDark),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color.lerp(AppColors.gradientStart,
                  AppColors.gradientEnd, summaryDepth / 3),
              inactiveTrackColor: AppColors.secondaryTextColor.withOpacity(0.3),
              thumbColor: Color.lerp(AppColors.gradientStart,
                  AppColors.gradientEnd, summaryDepth / 3),
              overlayColor: Color.lerp(AppColors.gradientStart,
                      AppColors.gradientEnd, summaryDepth / 3)
                  ?.withOpacity(0.3),
              valueIndicatorColor: Color.lerp(AppColors.gradientStart,
                  AppColors.gradientEnd, summaryDepth / 3),
              valueIndicatorTextStyle: AppTextStyles.bodyTextStyle,
              valueIndicatorShape: const PaddedRoundSliderValueIndicatorShape(
                  padding: EdgeInsets.symmetric(horizontal: 16.0)),
            ),
            child: Slider(
              value: summaryDepth,
              onChanged: (value) {
                setState(() {
                  summaryDepth = value;
                });
              },
              min: 0,
              max: 4,
              divisions: 4,
              label: _getSummaryDepthLabel(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Selected: ${_getSummaryDepthLabel()}',
                  style: AppTextStyles.bodyTextStyle
                      .copyWith(color: AppColors.primaryTextColorDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'Detail retained: ${_getDetailRetained()}',
                  style: AppTextStyles.bodyTextStyle
                      .copyWith(color: AppColors.primaryTextColorDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarizeButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Tween<Offset>(
            begin: const Offset(0, 50),
            end: Offset.zero,
          )
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.9, 1.0, curve: Curves.easeOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.9, 1.0, curve: Curves.easeOut)))
                .value,
            child: child,
          ),
        );
      },
      child: AnimatedButton(
        text: 'Summarize',
        onPressed: summarize,
        backgroundColor: AppColors.primaryButtonColor,
        textColor: AppColors.primaryButtonTextColor,
      ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
