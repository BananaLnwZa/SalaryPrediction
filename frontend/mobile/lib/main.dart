import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Calculator',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Kanit'),
      home: const SalaryCalculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SalaryCalculator extends StatefulWidget {
  const SalaryCalculator({super.key});

  @override
  State<SalaryCalculator> createState() => _SalaryCalculatorState();
}

class _SalaryCalculatorState extends State<SalaryCalculator>
    with TickerProviderStateMixin {
  int? age;
  int? gender;
  int? educationLevel;
  int? yearsOfExperience;

  double? salary;
  String? currency;

  bool loading = false;
  String? error;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> calculateSalary() async {
    if (age == null ||
        gender == null ||
        educationLevel == null ||
        yearsOfExperience == null) {
      setState(() {
        error = 'กรุณากรอกข้อมูลให้ครบถ้วน';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      salary = null;
      currency = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/salary'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'Age': age,
          'Gender': gender,
          'Education_Level': educationLevel,
          'Years_of_Experience': yearsOfExperience,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          salary = data['Salary']?.toDouble();
          currency = data['currency'] ?? 'USD';
        });

        // Trigger result animation
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        setState(() {
          error = 'เซิร์ฟเวอร์ตอบกลับด้วย error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup')) {
          error =
              'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบว่า API server ทำงานอยู่';
        } else {
          error = 'เกิดข้อผิดพลาด: $e';
        }
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBEB), // yellow-50
              Color(0xFFFDF2F8), // pink-50
              Color(0xFFEFF6FF), // blue-50
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFBBF24), // yellow-400
                                Color(0xFFF472B6), // pink-400
                                Color(0xFF60A5FA), // blue-400
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'ประเมินเงินเดือน',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFDE68A), // yellow-300
                                  Color(0xFFF9A8D4), // pink-300
                                  Color(0xFF93C5FD), // blue-300
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Form Fields
                      _buildInputField(
                        label: 'อายุ',
                        value: age?.toString() ?? '',
                        onChanged: (value) =>
                            setState(() => age = int.tryParse(value)),
                        placeholder: '20 - 55',
                        borderColor: const Color(0xFFFEF3C7), // yellow-200
                        focusColor: const Color(0xFFFBBF24), // yellow-400
                        backgroundColor: const Color(
                          0xFFFFFBEB,
                        ).withOpacity(0.5), // yellow-50/50
                        isNumber: true,
                      ),

                      const SizedBox(height: 24),

                      _buildDropdownField(
                        label: 'เพศ',
                        value: gender,
                        onChanged: (value) => setState(() => gender = value),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('หญิง')),
                          DropdownMenuItem(value: 1, child: Text('ชาย')),
                        ],
                        placeholder: 'เลือกเพศ',
                        borderColor: const Color(0xFFFCE7F3), // pink-200
                        focusColor: const Color(0xFFF472B6), // pink-400
                        backgroundColor: const Color(
                          0xFFFDF2F8,
                        ).withOpacity(0.5), // pink-50/50
                      ),

                      const SizedBox(height: 24),

                      _buildDropdownField(
                        label: 'ระดับการศึกษา',
                        value: educationLevel,
                        onChanged: (value) =>
                            setState(() => educationLevel = value),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('ปริญญาตรี')),
                          DropdownMenuItem(value: 1, child: Text('ปริญญาโท')),
                          DropdownMenuItem(value: 2, child: Text('ปริญญาเอก')),
                        ],
                        placeholder: 'เลือกระดับการศึกษา',
                        borderColor: const Color(0xFFDBEAFE), // blue-200
                        focusColor: const Color(0xFF60A5FA), // blue-400
                        backgroundColor: const Color(
                          0xFFEFF6FF,
                        ).withOpacity(0.5), // blue-50/50
                      ),

                      const SizedBox(height: 24),

                      _buildInputField(
                        label: 'ประสบการณ์การทำงาน (ปี)',
                        value: yearsOfExperience?.toString() ?? '',
                        onChanged: (value) => setState(
                          () => yearsOfExperience = int.tryParse(value),
                        ),
                        placeholder: '0 - 30',
                        borderColor: const Color(0xFFFEF3C7), // yellow-200
                        focusColor: const Color(0xFFFBBF24), // yellow-400
                        backgroundColor: const Color(
                          0xFFFFFBEB,
                        ).withOpacity(0.5), // yellow-50/50
                        isNumber: true,
                      ),

                      const SizedBox(height: 32),

                      // Calculate Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFBBF24), // yellow-400
                              Color(0xFFF472B6), // pink-400
                              Color(0xFF60A5FA), // blue-400
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                loading ||
                                    educationLevel == null ||
                                    yearsOfExperience == null
                                ? null
                                : calculateSalary,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: loading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'กำลังคำนวณ...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'คำนวณเงินเดือน',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Error Message
                      if (error != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2), // red-50
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFECACA), // red-200
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF87171), // red-400
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C), // red-700
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Result
                      if (salary != null) ...[
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFECFDF5), // green-50
                                      Color(0xFFECFDF5), // emerald-50
                                      Color(0xFFF0FDFA), // teal-50
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0), // green-200
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'เงินเดือนประเมิน',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF166534), // green-800
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          ShaderMask(
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                                  colors: [
                                                    Color(
                                                      0xFF059669,
                                                    ), // green-600
                                                    Color(
                                                      0xFF047857,
                                                    ), // emerald-600
                                                    Color(
                                                      0xFF0F766E,
                                                    ), // teal-600
                                                  ],
                                                ).createShader(bounds),
                                            child: Text(
                                              salary!
                                                  .toStringAsFixed(0)
                                                  .replaceAllMapped(
                                                    RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                    ),
                                                    (Match m) => '${m[1]},',
                                                  ),
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency ?? 'บาท',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(
                                                0xFF15803D,
                                              ), // green-700
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String placeholder,
    required Color borderColor,
    required Color focusColor,
    required Color backgroundColor,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151), // gray-700
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: focusColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF1F2937), // gray-800
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    required List<DropdownMenuItem<int>> items,
    required String placeholder,
    required Color borderColor,
    required Color focusColor,
    required Color backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151), // gray-700
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: DropdownButtonFormField<int>(
            value: value,
            onChanged: onChanged,
            items: items,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF1F2937), // gray-800
              fontSize: 16,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
