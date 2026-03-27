import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final PageController _pageController = PageController();

  // State หลักของแอปอ่านหนังสือ
  int _currentPage = 1;
  final int _totalPages = 12; // จำนวนหน้าสมมติ

  bool _showControls = true; // เปิด/ปิด แถบเครื่องมือ บน-ล่าง
  bool _showSidebar = false; // เปิด/ปิด แถบเมนูด้านซ้าย

  // ฟังก์ชันสลับการโชว์เครื่องมือ (ทำงานเมื่อเอานิ้วแตะกลางจอ)
  void _toggleControls() {
    setState(() {
      // ถ้าเปิดแถบซ้ายอยู่ ให้ปิดแถบซ้ายก่อน
      if (_showSidebar) {
        _showSidebar = false;
      } else {
        _showControls = !_showControls;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // พื้นหลังสีดำเวลาเลื่อนหน้าจะได้ดูเนียน
      body: Stack(
        children: [
          // 🛑 1. เลเยอร์ล่างสุด: ภาพหนังสือ (PageView)
          GestureDetector(
            onTap: _toggleControls, // แตะจอเพื่อซ่อน/โชว์เมนู
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1; // index เริ่มที่ 0 หน้าเริ่มที่ 1
                });
              },
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                // รูปภาพ Placeholder
                return Image.network(
                  'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          ),

          // 🛑 2. แถบเครื่องมือด้านบน (Top Bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -100, // เลื่อนขึ้นไปซ่อนด้านบน
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
                  const Icon(
                    Remix.bookmark_line,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // 🛑 3. แถบเครื่องมือด้านล่าง (Bottom Bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -150, // เลื่อนลงไปซ่อนด้านล่าง
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
                        setState(() {
                          _currentPage = value.toInt();
                        });
                        _pageController.jumpToPage(_currentPage - 1);
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
                      const Icon(
                        Remix.download_line,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🛑 4. พื้นที่สีดำโปร่งแสง (จะโชว์เฉพาะตอนเปิด Sidebar เพื่อกันไม่ให้ไปกดโดนหน้าหนังสือ)
          if (_showSidebar)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSidebar = false;
                  _showControls = true;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(
                  0.4,
                ), // ทำให้จอมืดลงเพื่อเน้นเมนู
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // 🛑 5. แถบเมนูด้านซ้าย (Sidebar) แก้ไขให้ทำงานอิสระ ไม่บังจอ
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: _showSidebar ? 0 : -150, // เลื่อนซ่อนไปทางซ้ายให้สุด
            width: 120, // ล็อคความกว้างไว้ที่ 120
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  bool isCurrent = (index + 1) == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentPage = index + 1;
                        _showSidebar = false;
                        _showControls = true;
                      });
                      _pageController.jumpToPage(index);
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
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            height: 80,
                            color: Colors.grey.shade300,
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
