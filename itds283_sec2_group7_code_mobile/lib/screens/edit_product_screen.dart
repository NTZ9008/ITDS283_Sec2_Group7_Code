import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'my_products_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductItem product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  late final TextEditingController _nameController;
  late final TextEditingController _authorController;
  late final TextEditingController _describeController;
  late final TextEditingController _priceController;

  String? _selectedCategory;
  File? _imageFile;
  File? _pdfFile;
  String? _pdfFileName;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Finance',
    'Math',
    'Science',
    'English',
    'Bio',
    'Chemi',
    'Physics',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.title);
    _authorController = TextEditingController(text: p.author);
    _describeController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toStringAsFixed(2));
    _selectedCategory = _categories.contains(p.category) ? p.category : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _describeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('seller_token') ?? prefs.getString('token');
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF006B3F),
              ),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (picked != null && mounted) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF006B3F),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked != null && mounted) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter a product name');
      return;
    }

    if (widget.product.id == null) {
      _showSnack('ไม่พบ ID หนังสือ ไม่สามารถแก้ไขได้');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/books/${widget.product.id}'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = name;
      request.fields['author'] = _authorController.text.trim();
      request.fields['category'] = _selectedCategory ?? widget.product.category;
      request.fields['description'] = _describeController.text.trim();
      request.fields['price'] = _priceController.text.trim().isEmpty
          ? '0'
          : _priceController.text.trim();

      if (_imageFile != null) {
        final ext = path
            .extension(_imageFile!.path)
            .toLowerCase()
            .replaceAll('.', '');
        final mimeType = ext == 'png' ? 'png' : 'jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            contentType: MediaType('image', mimeType),
          ),
        );
      }

      if (_pdfFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            _pdfFile!.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('แก้ไขหนังสือสำเร็จ'),
              backgroundColor: Color(0xFF00D13B),
            ),
          );
          Navigator.pop(
            context,
            ProductItem(
              id: widget.product.id,
              title: name,
              author: _authorController.text.trim(),
              category: _selectedCategory ?? widget.product.category,
              description: _describeController.text.trim(),
              price: double.tryParse(_priceController.text.trim()) ?? 0.0,
              imageUrl: _imageFile != null
                  ? _imageFile!.path
                  : widget
                        .product
                        .imageUrl, // ใช้ของเดิมที่ผ่าน fromJson มาแล้ว
            ),
          );
        }
      } else {
        _showSnack('แก้ไขไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    _buildPdfPicker(),
                    const SizedBox(height: 24),
                    _fieldLabel('Product Name'),
                    _textField(_nameController),
                    const SizedBox(height: 16),
                    _fieldLabel('Name of Author'),
                    _textField(_authorController),
                    const SizedBox(height: 16),
                    _fieldLabel('Category'),
                    _dropdown(),
                    const SizedBox(height: 16),
                    _fieldLabel('Describe'),
                    _multilineField(_describeController),
                    const SizedBox(height: 16),
                    _fieldLabel('Price'),
                    _priceField(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
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
          const SizedBox(height: 12),
          const Text(
            'Edit Products',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          width: 200,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : widget.product.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _addIcon(),
                  ),
                )
              : _addIcon(),
        ),
      ),
    );
  }

  Widget _addIcon() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.black38),
      SizedBox(height: 6),
      Text(
        'Change Cover',
        style: TextStyle(fontSize: 12, color: Colors.black45),
      ),
    ],
  );

  Widget _buildPdfPicker() {
    final displayName =
        _pdfFileName ??
        (widget.product.pdfUrl.isNotEmpty
            ? widget.product.pdfUrl.split('/').last
            : null);

    return GestureDetector(
      onTap: _pickPdf,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file_rounded,
              color: displayName == null
                  ? Colors.black38
                  : const Color(0xFF006B3F),
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                displayName ?? 'Update PDF File (Optional)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: displayName == null
                      ? Colors.black54
                      : const Color(0xFF006B3F),
                  fontWeight: displayName == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
  );

  Widget _textField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  Widget _multilineField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  Widget _priceField() {
    return SizedBox(
      width: 120,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '0.00',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text(
            'Select Category',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          items: _categories
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006B3F),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
