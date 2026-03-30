import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0; // 0=Form, 1=Payment, 2=Review, 3=Success

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalController = TextEditingController();
  String? _selectedProvince;
  String? _selectedCity;

  final List<String> _provinces = [
    'Bangkok', 'Chiang Mai', 'Phuket', 'Khon Kaen', 'Nakhon Ratchasima'
  ];
  final List<String> _cities = [
    'Nong Khaem', 'Bang Rak', 'Chatuchak', 'Lat Phrao', 'Huai Khwang'
  ];

  final List<Map<String, dynamic>> _cartItems = [
    {'title': 'Aaaa', 'price': 100.0},
    {'title': 'Aaaaa', 'price': 100.0},
  ];
  final double _shippingFee = 10.0;

  double get _itemsTotal =>
      _cartItems.fold(0.0, (s, i) => s + (i['price'] as double));
  double get _subtotal => _itemsTotal + _shippingFee;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentStep == 3 ? _buildSuccessPage() : _buildCheckoutFlow(),
      ),
    );
  }

  Widget _buildCheckoutFlow() {
    return Column(
      children: [
        _buildHeader(),
        _buildStepper(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _currentStep == 0
                ? _buildFormPage()
                : _currentStep == 1
                    ? _buildPaymentPage()
                    : _buildReviewPage(),
          ),
        ),
        _buildConfirmButton(),
      ],
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEPPER ──
  Widget _buildStepper() {
    final steps = [
      {'icon': Icons.list_alt_outlined, 'label': 'Form'},
      {'icon': Icons.credit_card_outlined, 'label': 'Payment'},
      {'icon': Icons.check_box_outlined, 'label': 'Review'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          final color = (isActive || isDone)
              ? const Color(0xFF00D13B)
              : Colors.black38;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(steps[i]['icon'] as IconData, size: 22, color: color),
                      const SizedBox(height: 4),
                      Text(
                        steps[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: isDone
                          ? const Color(0xFF00D13B)
                          : Colors.black12,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── PAGE 1: FORM ──
  Widget _buildFormPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _label('Full Name*'),
        _textField(_fullNameController, 'Enter Full Name'),
        const SizedBox(height: 14),
        _label('Phone Number*'),
        _textField(_phoneController, '+66',
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _label('Select Province'),
        _dropdown(
          value: _selectedProvince,
          hint: 'Select Province',
          items: _provinces,
          onChanged: (v) => setState(() => _selectedProvince = v),
        ),
        const SizedBox(height: 14),
        _label('Select City'),
        _dropdown(
          value: _selectedCity,
          hint: 'Select City',
          items: _cities,
          onChanged: (v) => setState(() => _selectedCity = v),
        ),
        const SizedBox(height: 14),
        _label('Street Address*'),
        _textField(_addressController, 'Enter street address'),
        const SizedBox(height: 14),
        _label('Postal Code*'),
        _textField(_postalController, 'Enter postal code',
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
      );

  Widget _textField(TextEditingController c, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── PAGE 2: PAYMENT ──
  Widget _buildPaymentPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.qr_code_2,
                        size: 30, color: Colors.black54),
                  ),
                  const SizedBox(width: 14),
                  const Text('Qr Payment',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A6B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'THAI QR  PAYMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3A6B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 170,
                      height: 170,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: CustomPaint(painter: _QRPainter()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── PAGE 3: REVIEW ──
  Widget _buildReviewPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._cartItems.map((item) => _buildReviewItem(item)),
        const SizedBox(height: 16),
        const Divider(color: Colors.black12),
        const SizedBox(height: 8),
        _reviewRow('Total', '\$${_itemsTotal.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _reviewRow('Shipping Fee', '\$${_shippingFee.toStringAsFixed(2)}'),
        const Divider(color: Colors.black12, height: 28),
        _reviewRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}',
            isBold: true),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFB2EEF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Color(0xFF5B9BD5), size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text('\$${(item['price'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Row(
            children: [
              _miniBtn(Icons.remove),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('1',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              _miniBtn(Icons.add),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData icon) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 12, color: Colors.black54),
      );

  Widget _reviewRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            )),
      ],
    );
  }

  // ── PAGE 4: SUCCESS ──
  Widget _buildSuccessPage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF00D13B), width: 4),
                  ),
                  child: const Icon(Icons.check,
                      color: Color(0xFF00D13B), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sucessfully',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D13B),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D13B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Back Home',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Go to library',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── CONFIRM BUTTON ──
  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() => _currentStep++),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D13B),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ── QR CODE PAINTER ──
class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;
    final cell = size.width / 21;

    canvas.drawRect(Offset.zero & size, white);

    void fill(int col, int row) => canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell - 0.5, cell - 0.5), paint);

    void corner(int x, int y) {
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 7; j++) {
          if (i == 0 || i == 6 || j == 0 || j == 6) fill(x + i, y + j);
        }
      }
      for (int i = 2; i <= 4; i++) {
        for (int j = 2; j <= 4; j++) {
          fill(x + i, y + j);
        }
      }
    }

    corner(0, 0);
    corner(14, 0);
    corner(0, 14);

    final data = [
      [9,0],[10,0],[11,0],[9,2],[11,2],[10,4],[9,5],
      [0,9],[2,9],[4,9],[0,11],[2,11],[4,10],[3,11],
      [9,9],[11,9],[10,10],[9,11],[11,11],[10,9],
      [14,9],[16,9],[18,9],[15,10],[14,11],[16,11],[18,10],
      [9,14],[11,14],[10,15],[9,16],[11,16],[10,18],
      [14,14],[16,14],[18,14],[15,15],[14,16],[16,16],[18,16],[17,18],
    ];
    for (final c in data) {
      fill(c[0], c[1]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
