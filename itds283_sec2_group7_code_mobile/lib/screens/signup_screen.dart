import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1ECA5A), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5E4BE), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Create an account to continue!",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    // ช่อง First Name
                    _buildTextField(_firstNameController, 'First Name'),
                    
                    // ช่อง Last Name
                    _buildTextField(_lastNameController, 'Last Name'),
                    
                    // ช่อง Email
                    _buildTextField(_emailController, 'Email Address'),
                    
                    // ช่อง วันเกิด (Date of Birth)
                    _buildTextField(
                      _dobController,
                      'Date of Birth (DD/MM/YYYY)',
                      icon: Icons.calendar_today_outlined,
                    ),

                    // ช่อง เบอร์โทรศัพท์ (🛑 แก้ไขใหม่หมด เหลือแค่เบอร์ไทย 10 หลัก)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone, 
                        // 🛑 จำกัดให้กรอกเฉพาะตัวเลขและไม่เกิน 10 ตัว
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, 
                          LengthLimitingTextInputFormatter(10), 
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Phone Number (e.g., 0xxxxxxxxx)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          suffixIcon: Icon(Icons.phone_iphone, color: Colors.black26, size: 20),
                        ),
                      ),
                    ),

                    // ช่อง Password
                    _buildTextField(
                      _passwordController,
                      'Password',
                      isPassword: true,
                      icon: Icons.visibility_off,
                    ),

                    const SizedBox(height: 10),

                    // ปุ่ม Register 
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: ใส่ Logic สมัครสมาชิกตรงนี้
                          print("กด Register!");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B58F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ปุ่มย้อนกลับไปหน้า Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // 🛑 ย้อนกลับหน้าเดิม
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2B58F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างช่องกรอกข้อมูล
  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: icon != null ? Icon(icon, color: Colors.black26, size: 20) : null,
        ),
      ),
    );
  }
}