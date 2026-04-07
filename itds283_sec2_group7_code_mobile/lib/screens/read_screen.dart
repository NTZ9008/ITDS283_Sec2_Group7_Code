import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';

class ReadScreen extends StatefulWidget {
  final int bookIndex;
  const ReadScreen({super.key, required this.bookIndex});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _showControls = true;
  final Set<int> _bookmarkedPages = {};
  bool _isDownloading = false;
  File? _localFile;
  bool _isCheckingFile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocalFile();
    });
  }

  Future<void> _checkLocalFile() async {
    if (!mounted) return;
    final libraryProvider = LibraryProviderWidget.of(context);
    final authProvider = AuthProviderWidget.of(
      context,
    );
    final book = libraryProvider.items[widget.bookIndex];
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkKey =
          'bookmarks_${authProvider.username}_${book.bookId ?? book.title}';
      final savedBookmarks = prefs.getStringList(bookmarkKey);
      if (savedBookmarks != null && mounted) {
        setState(() {
          _bookmarkedPages.addAll(savedBookmarks.map(int.parse));
        });
      }
    } catch (e) {
      print("Load Bookmark Error: $e");
    }

    if (book.pdfUrl.isNotEmpty) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = book.pdfUrl.split('/').last;
        final file = File('${dir.path}/$fileName');

        if (await file.exists()) {
          if (mounted) setState(() => _localFile = file);
        }
      } catch (e) {
        print("Error reading local file: $e");
      }
    }

    if (mounted) setState(() => _isCheckingFile = false);
  }

  Future<void> _saveBookmarks() async {
    final libraryProvider = LibraryProviderWidget.of(context);
    final authProvider = AuthProviderWidget.of(
      context,
    );
    final book = libraryProvider.items[widget.bookIndex];
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkKey =
          'bookmarks_${authProvider.username}_${book.bookId ?? book.title}';
      final stringList = _bookmarkedPages.map((e) => e.toString()).toList();
      await prefs.setStringList(bookmarkKey, stringList);
    } catch (e) {
      print("Save Bookmark Error: $e");
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  Future<void> _handleDownload(
    LibraryProvider provider,
    bool isDownloaded,
    String pdfUrl,
  ) async {
    if (pdfUrl.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = pdfUrl.split('/').last;
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      await file.delete();
      provider.toggleDownload(widget.bookIndex);
      setState(() => _localFile = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from device storage'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          provider.toggleDownload(widget.bookIndex);
          setState(() => _localFile = file);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download complete! Saved to device.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download file. Please check connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFile) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D13B)),
        ),
      );
    }

    final libraryProvider = LibraryProviderWidget.of(context);
    final book = libraryProvider.items[widget.bookIndex];
    final bool isDownloaded = _localFile != null;
    final bool isCurrentPageBookmarked = _bookmarkedPages.contains(
      _currentPage,
    );
    final sortedBookmarks = _bookmarkedPages.toList()..sort();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Remix.pages_line, color: Color(0xFF00D13B)),
                    SizedBox(width: 10),
                    Text(
                      'Pages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _totalPages > 0 ? _totalPages : 1,
                  itemBuilder: (context, index) {
                    final pageNum = index + 1;
                    final isCurrent = _currentPage == pageNum;
                    final isBookmarked = _bookmarkedPages.contains(pageNum);

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              _pdfController.jumpToPage(pageNum);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFF00D13B).withOpacity(0.2)
                                    : Colors.grey.shade200,
                                border: Border.all(
                                  color: isCurrent
                                      ? const Color(0xFF00D13B)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$pageNum',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrent
                                        ? const Color(0xFF00D13B)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                if (isBookmarked) {
                                  _bookmarkedPages.remove(pageNum);
                                } else {
                                  _bookmarkedPages.add(pageNum);
                                }
                              });
                              _saveBookmarks();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                isBookmarked
                                    ? Remix.bookmark_fill
                                    : Remix.bookmark_line,
                                color: isBookmarked
                                    ? Colors.amber
                                    : Colors.black26,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: book.pdfUrl.isNotEmpty
                ? (_localFile != null
                      ? SfPdfViewer.file(
                          _localFile!,
                          controller: _pdfController,
                          canShowScrollHead: false,
                          pageLayoutMode: PdfPageLayoutMode.single,
                          scrollDirection: PdfScrollDirection.horizontal,
                          onDocumentLoaded: (details) => setState(
                            () => _totalPages = details.document.pages.count,
                          ),
                          onPageChanged: (details) => setState(
                            () => _currentPage = details.newPageNumber,
                          ),
                        )
                      : SfPdfViewer.network(
                          book.pdfUrl,
                          controller: _pdfController,
                          canShowScrollHead: false,
                          pageLayoutMode: PdfPageLayoutMode.single,
                          scrollDirection: PdfScrollDirection.horizontal,
                          onDocumentLoaded: (details) => setState(
                            () => _totalPages = details.document.pages.count,
                          ),
                          onPageChanged: (details) {
                            if (_currentPage != details.newPageNumber) {
                              setState(
                                () => _currentPage = details.newPageNumber,
                              );
                            }
                          },
                        ))
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: book.imageUrl,
                          fit: BoxFit.contain,
                          height: 200,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                                color: Colors.white54,
                              ),
                          errorWidget: (context, url, error) => const Icon(
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
                    child: const Icon(
                      Remix.arrow_left_s_line,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                      _saveBookmarks();
                    },
                    child: Icon(
                      isCurrentPageBookmarked
                          ? Remix.bookmark_fill
                          : Remix.bookmark_line,
                      color: isCurrentPageBookmarked
                          ? Colors.yellow
                          : Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -150,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 25,
                left: 15,
                right: 15,
              ),
              color: const Color(0xFF4DB050).withOpacity(0.95),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              thumbColor: Colors.white,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withOpacity(0.4),
                              trackHeight: 2.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                            ),
                            child: Slider(
                              value: _currentPage.toDouble(),
                              min: 1,
                              max: _totalPages.toDouble() > 1
                                  ? _totalPages.toDouble()
                                  : 1,
                              onChanged: (value) {
                                setState(() => _currentPage = value.toInt());
                              },
                              onChangeEnd: (value) {
                                _pdfController.jumpToPage(value.toInt());
                              },
                            ),
                          ),
                          ...sortedBookmarks.map((page) {
                            final double percent = _totalPages > 1
                                ? (page - 1) / (_totalPages - 1)
                                : 0;
                            const double padding = 24.0;
                            final double availableWidth =
                                constraints.maxWidth - (padding * 2);
                            final double leftPosition =
                                padding + (percent * availableWidth);

                            return Positioned(
                              left: leftPosition - 4,
                              child: IgnorePointer(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black45,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(
                          Remix.menu_line,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _handleDownload(
                          libraryProvider,
                          isDownloaded,
                          book.pdfUrl,
                        ),
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isDownloaded
                                    ? Remix.check_line
                                    : Remix.download_line,
                                color: isDownloaded
                                    ? Colors.greenAccent
                                    : Colors.white,
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
