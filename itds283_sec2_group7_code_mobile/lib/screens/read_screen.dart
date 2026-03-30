import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../providers/library_provider.dart';

class ReadScreen extends StatefulWidget {
  final int bookIndex; 

  const ReadScreen({super.key, required this.bookIndex});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 1;
  final int _totalPages = 12;

  bool _showControls = true;
  bool _showSidebar = false;

  final Set<int> _bookmarkedPages = {}; 
  
  bool _isDownloading = false;

  void _toggleControls() {
    setState(() {
      if (_showSidebar) {
        _showSidebar = false;
      } else {
        _showControls = !_showControls;
      }
    });
  }

  Future<void> _handleDownload(LibraryProvider provider, bool isDownloaded) async {
    if (isDownloaded) {
      provider.toggleDownload(widget.bookIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from downloads'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_isDownloading) return; 

    setState(() {
      _isDownloading = true; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading chapter...'),
        duration: Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });
      
      provider.toggleDownload(widget.bookIndex);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download complete!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentPageBookmarked = _bookmarkedPages.contains(_currentPage);
    
    final libraryProvider = LibraryProviderWidget.of(context);
    final book = libraryProvider.items[widget.bookIndex];
    final bool isDownloaded = book.isDownloaded;

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleControls, 
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1;
                });
              },
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageOffset = 0;
                    
                    if (_pageController.hasClients && _pageController.position.haveDimensions) {
                      pageOffset = _pageController.page! - index;
                    } else {
                      pageOffset = (_currentPage - 1 - index).toDouble();
                    }

                    double scale = 1 - (pageOffset.abs() * 0.15).clamp(0.0, 1.0);
                    double opacity = 1 - (pageOffset.abs() * 0.5).clamp(0.0, 1.0);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                );
              },
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
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
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
                      max: _totalPages.toDouble(),
                      onChanged: (value) {
                        int newPage = value.toInt();
                        if (_currentPage != newPage) {
                          setState(() {
                            _currentPage = newPage;
                          });
                          _pageController.animateToPage(
                            newPage - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showSidebar = true;
                            _showControls = false;
                          });
                        },
                        child: const Icon(
                          Remix.menu_line,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _handleDownload(libraryProvider, isDownloaded),
                        child: _isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
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

          if (_showSidebar)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSidebar = false;
                  _showControls = true;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.4), 
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: _showSidebar ? 0 : -150, 
            width: 120, 
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  bool isCurrent = (index + 1) == _currentPage;
                  bool isThisIndexBookmarked = _bookmarkedPages.contains(index + 1);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSidebar = false;
                        _showControls = true;
                      });
                      _pageController.animateToPage(
                        index, 
                        duration: const Duration(milliseconds: 400), 
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      color: isCurrent ? Colors.grey.shade200 : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isThisIndexBookmarked)
                                const Icon(Remix.bookmark_fill, color: Colors.yellow, size: 12),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: Image.network(book.imageUrl, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}