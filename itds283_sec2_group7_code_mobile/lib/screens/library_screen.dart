import 'package:flutter/material.dart';

class LibraryBook {
  final String title;
  final String author;
  final String imageUrl;
  bool isDownloaded;

  LibraryBook({
    required this.title,
    required this.author,
    required this.imageUrl,
    this.isDownloaded = false,
  });
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<LibraryBook> _books = [
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: false,
    ),
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: true,
    ),
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: false,
    ),
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: true,
    ),
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: true,
    ),
    LibraryBook(
      title: 'Aaaaa Aaaa',
      author: 'Joshua Williamson',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
      isDownloaded: true,
    ),
  ];

  void _toggleDownload(int index) {
    setState(() {
      _books[index].isDownloaded = !_books[index].isDownloaded;
    });

    final book = _books[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(book.isDownloaded
            ? '"${book.title}" downloaded'
            : '"${book.title}" removed from downloads'),
        backgroundColor: const Color(0xFF00D13B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildGrid()),
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
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.black87),
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

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) => _buildBookCard(index),
    );
  }

  Widget _buildBookCard(int index) {
    final book = _books[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              color: const Color(0xFFB2EEF4),
              child: Image.network(
                book.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Title + download icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                book.title,
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
              onTap: () => _toggleDownload(index),
              child: Icon(
                book.isDownloaded
                    ? Icons.cloud_off_outlined
                    : Icons.cloud_download_outlined,
                size: 18,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          book.author,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}