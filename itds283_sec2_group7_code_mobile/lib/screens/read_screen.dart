import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../providers/library_provider.dart';

class ReadScreen extends StatefulWidget {
  final int bookIndex;
  const ReadScreen({super.key, required this.bookIndex});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _showControls = true;
  final Set<int> _bookmarkedPages = {};
  bool _isDownloading = false;

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  Future<void> _handleDownload(LibraryProvider provider, bool isDownloaded) async {
    if (isDownloaded) {
      provider.toggleDownload(widget.bookIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from downloads'), duration: Duration(seconds: 1)),
      );
      return;
    }

    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isDownloading = false);
      provider.toggleDownload(widget.bookIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download complete!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = LibraryProviderWidget.of(context);
    final book = libraryProvider.items[widget.bookIndex];
    final bool isDownloaded = book.isDownloaded;
    final bool isCurrentPageBookmarked = _bookmarkedPages.contains(_currentPage);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PDF Viewer
          GestureDetector(
            onTap: _toggleControls,
            child: book.pdfUrl.isNotEmpty
                ? SfPdfViewer.network(
                    book.pdfUrl,
                    controller: _pdfController,
                    onDocumentLoaded: (details) {
                      setState(() => _totalPages = details.document.pages.count);
                    },
                    onPageChanged: (details) {
                      setState(() => _currentPage = details.newPageNumber);
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          book.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white54,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'PDF not available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
          ),

          // Top bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 15,
                right: 15,
              ),
              color: const Color(0xFF4DB050).withOpacity(0.95),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Remix.arrow_left_s_line, color: Colors.white, size: 28),
                  ),
                  Text(
                    book.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isCurrentPageBookmarked) {
                          _bookmarkedPages.remove(_currentPage);
                        } else {
                          _bookmarkedPages.add(_currentPage);
                        }
                      });
                    },
                    child: Icon(
                      isCurrentPageBookmarked ? Remix.bookmark_fill : Remix.bookmark_line,
                      color: isCurrentPageBookmarked ? Colors.yellow : Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -150,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 15, bottom: 25, left: 15, right: 15),
              color: const Color(0xFF4DB050).withOpacity(0.95),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.4),
                      trackHeight: 2.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    ),
                    child: Slider(
                      value: _currentPage.toDouble(),
                      min: 1,
                      max: _totalPages.toDouble(),
                      onChanged: (value) {
                        int newPage = value.toInt();
                        if (_currentPage != newPage) {
                          setState(() => _currentPage = newPage);
                          _pdfController.jumpToPage(newPage);
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bookmarked pages indicator
                      Row(
                        children: _bookmarkedPages.take(3).map((page) =>
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () => _pdfController.jumpToPage(page),
                              child: Chip(
                                label: Text('p.$page', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: Colors.black38,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                      GestureDetector(
                        onTap: () => _handleDownload(libraryProvider, isDownloaded),
                        child: _isDownloading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(
                                isDownloaded ? Remix.check_line : Remix.download_line,
                                color: isDownloaded ? Colors.greenAccent : Colors.white,
                                size: 24,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}