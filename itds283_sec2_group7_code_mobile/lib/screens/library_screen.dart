import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';
import '../providers/library_provider.dart';
import '../routes/app_routes.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LibraryProviderWidget.of(context).fetchLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = LibraryProviderWidget.of(context);

    if (libraryProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D13B)),
        ),
      );
    }

    final books = libraryProvider.items;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: books.isEmpty
                  ? const Center(
                      child: Text(
                        "You haven't purchased any books yet.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : _buildGrid(books, libraryProvider, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Library',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
          ),
          const Text(
            'Your collection of purchased books.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<LibraryItem> books,
    LibraryProvider provider,
    BuildContext context,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _LibraryBookCard(
        book: books[index],
        index: index,
        provider: provider,
      ),
    );
  }
}

class _LibraryBookCard extends StatefulWidget {
  final LibraryItem book;
  final int index;
  final LibraryProvider provider;

  const _LibraryBookCard({
    required this.book,
    required this.index,
    required this.provider,
  });

  @override
  State<_LibraryBookCard> createState() => _LibraryBookCardState();
}

class _LibraryBookCardState extends State<_LibraryBookCard> {
  bool _isDownloading = false;

  Future<void> _handleDownloadToggle() async {
    if (widget.book.pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not available for this book')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = widget.book.pdfUrl.split('/').last;
    final file = File('${dir.path}/$fileName');

    if (widget.book.isDownloaded) {
      // 🛑 ลบไฟล์จริงออกจากเครื่อง
      if (await file.exists()) {
        await file.delete();
      }
      widget.provider.toggleDownload(widget.index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${widget.book.title}" removed from downloads'),
            backgroundColor: const Color(0xFF00D13B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      if (_isDownloading) return;

      setState(() => _isDownloading = true);

      try {
        final response = await http.get(Uri.parse(widget.book.pdfUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          widget.provider.toggleDownload(widget.index);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '"${widget.book.title}" downloaded successfully!',
                ),
                backgroundColor: const Color(0xFF00D13B),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              content: Text('Download failed. Please check your connection.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.read,
                arguments: {'bookIndex': widget.index},
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFB2EEF4),
                child: Image.network(
                  widget.book.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.book.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D13B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _handleDownloadToggle,
              child: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00D13B),
                      ),
                    )
                  : Icon(
                      widget.book.isDownloaded
                          ? Remix
                                .checkbox_circle_fill
                          : Remix.download_cloud_2_line,
                      size: 20,
                      color: widget.book.isDownloaded
                          ? const Color(0xFF00D13B)
                          : Colors.black45,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          widget.book.author,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
