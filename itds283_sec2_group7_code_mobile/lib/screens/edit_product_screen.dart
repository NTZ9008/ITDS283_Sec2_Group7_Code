import 'package:flutter/material.dart';
import 'my_products_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductItem product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _authorController;
  late final TextEditingController _describeController;
  late final TextEditingController _priceController;
  String? _selectedCategory;
  String? _pdfFileName;

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

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name')),
      );
      return;
    }

    final updated = ProductItem(
      title: name,
      author: _authorController.text.trim(),
      category: _selectedCategory ?? '',
      description: _describeController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      imageUrl: widget.product.imageUrl,
    );

    Navigator.pop(context, updated);
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
                    _fieldLabel('Name of auther'),
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

  Widget _buildPdfPicker() {
    return GestureDetector(
      onTap: () {
        // TODO: เรียกใช้งาน FilePicker ของจริงตรงนี้
        setState(() {
          _pdfFileName = 'updated_ebook_file.pdf'; // สมมติว่าเลือกไฟล์ใหม่แล้ว
        });
      },
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
              color: _pdfFileName == null
                  ? Colors.black38
                  : const Color(0xFF006B3F),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              _pdfFileName ?? 'Update PDF File (Optional)',
              style: TextStyle(
                fontSize: 14,
                color: _pdfFileName == null
                    ? Colors.black54
                    : const Color(0xFF006B3F),
                fontWeight: _pdfFileName == null
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
            ),
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
    return Center(
      child: Container(
        width: 200,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.product.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.add, size: 36, color: Colors.black38),
                ),
              )
            : const Icon(Icons.add, size: 36, color: Colors.black38),
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
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006B3F),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
