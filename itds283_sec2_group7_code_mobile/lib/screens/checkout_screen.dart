import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/library_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentStep = 0;

  bool _isLoadingQR = false;
  String _qrPayload = '';
  bool _isProcessingCheckout = false;

  final Map<String, dynamic> checkoutData = {
    'fullName': '',
    'phoneNumber': '',
    'province': '',
    'city': '',
    'address': '',
    'postalCode': '',
    'paymentMethod': 'QR',
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _fetchQRPayload() async {
    setState(() => _isLoadingQR = true);
    final auth = AuthProviderWidget.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final String? promoCode = args['promoCode'];

    try {
      final uri =
          Uri.parse(
            'https://ebookapi.arlifzs.site/api/orders/qr-payment',
          ).replace(
            queryParameters: (promoCode != null && promoCode.isNotEmpty)
                ? {'promoCode': promoCode}
                : null,
          );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _qrPayload = data['qrPayload'] ?? '');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to get QR')),
        );
      }
    } catch (e) {
      print("QR Error: $e");
    } finally {
      setState(() => _isLoadingQR = false);
    }
  }

  Future<void> _submitCheckoutData() async {
    setState(() => _isProcessingCheckout = true);
    final auth = AuthProviderWidget.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    try {
      final response = await http.post(
        Uri.parse('https://ebookapi.arlifzs.site/api/orders/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({
          "promoCode": args['promoCode'],
          "paymentMethod": checkoutData['paymentMethod'],
          "fullName": checkoutData['fullName'],
          "phone": checkoutData['phoneNumber'],
          "province": checkoutData['province'],
          "city": checkoutData['city'],
          "address": checkoutData['address'],
          "postalCode": checkoutData['postalCode'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (checkoutData['items'] != null) {
          LibraryProviderWidget.of(context).addItems(checkoutData['items']);
          final cartProvider = CartProviderWidget.of(context);
          for (var item in checkoutData['items']) {
            final cartItem = cartProvider.items
                .where((e) => e.title == item['title'])
                .firstOrNull;
            if (cartItem != null) {
              cartProvider.removeItem(cartItem);
            }
          }
        }

        _goToNextStep(3);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Checkout failed!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Checkout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network Error!'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessingCheckout = false);
    }
  }

  void _nextStep() async {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      if (_nameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _provinceController.text.isEmpty ||
          _cityController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _postalController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all information before confirming'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_phoneController.text.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number must be exactly 10 digits'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_postalController.text.length != 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postal code must be exactly 5 digits'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      checkoutData['fullName'] = _nameController.text;
      checkoutData['phoneNumber'] = _phoneController.text;
      checkoutData['province'] = _provinceController.text;
      checkoutData['city'] = _cityController.text;
      checkoutData['address'] = _addressController.text;
      checkoutData['postalCode'] = _postalController.text;

      await _fetchQRPayload();
      _goToNextStep(1);
    } else if (_currentStep == 1) {
      _goToNextStep(2);
    } else if (_currentStep == 2) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      checkoutData['items'] = args['items'];
      checkoutData['totalPaid'] = args['total'];

      await _submitCheckoutData();
    }
  }

  void _goToNextStep(int nextStep) {
    if (nextStep <= 3) {
      _pageController.animateToPage(
        nextStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = nextStep);
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0 && _currentStep < 3) {
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else if (_currentStep == 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final List<dynamic> checkoutItems = args['items'] ?? [];
    final double subtotal = args['subtotal'] ?? 0.0;
    final double discount = args['discount'] ?? 0.0;
    final double total = args['total'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Offstage(offstage: _currentStep == 3, child: _buildHeader()),
            Offstage(offstage: _currentStep == 3, child: _buildStepper()),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Form(),
                  _buildStep2Payment(),
                  _buildStep3Review(checkoutItems, subtotal, discount, total),
                  _buildStep4Success(),
                ],
              ),
            ),

            Offstage(offstage: _currentStep == 3, child: _buildBottomButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: const Icon(Remix.arrow_left_s_line, size: 30),
          ),
          const SizedBox(width: 10),
          const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIcon(Remix.tablet_line, 'Form', 0),
          Expanded(
            child: Divider(
              color: _currentStep >= 1 ? Colors.black : Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          _buildStepIcon(Remix.bank_card_line, 'Payment', 1),
          Expanded(
            child: Divider(
              color: _currentStep >= 2 ? Colors.black : Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          _buildStepIcon(Remix.checkbox_line, 'Review', 2),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, String label, int stepIndex) {
    bool isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.black : Colors.grey.shade400,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.black : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isProcessingCheckout || _isLoadingQR ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D13B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _isProcessingCheckout
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStep1Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Enter your Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Full Name*', _nameController, 'Enter Full Name'),
          _buildTextField(
            'Phone Number*',
            _phoneController,
            '0xxxxxxxxx',
            isPhone: true,
          ),
          _buildTextField('Province*', _provinceController, 'Enter Province'),
          _buildTextField(
            'City/District*',
            _cityController,
            'Enter City/District',
          ),
          _buildTextField(
            'Street Address*',
            _addressController,
            'Enter street address',
          ),
          _buildTextField(
            'Postal Code*',
            _postalController,
            'Enter postal code',
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Payment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Remix.qr_code_line, color: Colors.white),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Qr Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Radio(
                  value: true,
                  groupValue: true,
                  onChanged: (val) {},
                  activeColor: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _isLoadingQR
              ? const CircularProgressIndicator()
              : _qrPayload.isNotEmpty
              ? Image.network(
                  'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$_qrPayload',
                  width: 200,
                  height: 200,
                )
              : const Text(
                  'Failed to load QR code. Is your backend cart empty?',
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  Widget _buildStep3Review(
    List<dynamic> items,
    double subtotal,
    double discount,
    double total,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildReviewItemCard(
                    item['title'],
                    item['price'],
                    item['quantity'],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 40),
          _buildSummaryRow('Subtotal', subtotal),
          if (discount > 0)
            _buildSummaryRow('Discount', discount, isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.black12, thickness: 1),
          ),
          _buildSummaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isDiscount ? const Color(0xFF00D13B) : Colors.black,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isDiscount ? const Color(0xFF00D13B) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItemCard(String title, double price, int qty) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.cyan.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Remix.book_read_line, color: Colors.blueAccent),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            'x$qty',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Success() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Checkout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D13B),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00D13B), width: 5),
            ),
            child: const Icon(
              Remix.check_line,
              size: 60,
              color: Color(0xFF00D13B),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Successfully',
            style: TextStyle(
              color: Color(0xFF00D13B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildActionButton(
            'Back Home',
            const Color(0xFF00D13B),
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            ),
          ),
          const SizedBox(height: 15),
          _buildActionButton('Go to library', const Color(0xFF0066FF), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
            Navigator.pushNamed(context, '/lib');
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPhone = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: isPhone || isNumber
                  ? TextInputType.phone
                  : TextInputType.text,
              inputFormatters: isPhone || isNumber
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(isPhone ? 10 : 5),
                    ]
                  : [],
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
