// features/auth/view/signup_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (!mounted || date == null) return;
    dobCtrl.text = "${date.day}/${date.month}/${date.year}";
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔸 Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Signup successful"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // go back to login
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.blueStart, AppColors.blueEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "CRM SIGNUP",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _input(
                        hint: "First name",
                        controller: firstNameCtrl,
                        validator: (v) =>
                            v!.isEmpty ? "First name is required" : null,
                      ),

                      _input(
                        hint: "Last name",
                        controller: lastNameCtrl,
                        validator: (v) =>
                            v!.isEmpty ? "Last name is required" : null,
                      ),

                      _input(
                        hint: "Email",
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return "Email is required";
                          if (!v.contains('@')) return "Invalid email";
                          return null;
                        },
                      ),

                      // 📅 Date of Birth
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextFormField(
                          controller: dobCtrl,
                          readOnly: true,
                          onTap: _pickDate,
                          validator: (v) =>
                              v!.isEmpty ? "Date of birth required" : null,
                          decoration: InputDecoration(
                            hintText: "dd / mm / yyyy",
                            suffixIcon:
                                const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

               _input(
  hint: "Phone number",
  controller: phoneCtrl,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  validator: (v) {
    if (v == null || v.isEmpty) {
      return "Phone number is required";
    }
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(v)) {
      return "Enter valid 10 digit Indian number";
    }
    return null;
  },
),




                      _input(
                        hint: "Password",
                        controller: passwordCtrl,
                        isPassword: true,
                        validator: (v) =>
                            v!.length < 6
                                ? "Minimum 6 characters"
                                : null,
                      ),

                      _input(
                        hint: "Confirm password",
                        controller: confirmPasswordCtrl,
                        isPassword: true,
                        validator: (v) =>
                            v != passwordCtrl.text
                                ? "Passwords do not match"
                                : null,
                      ),

                      const SizedBox(height: 24),

                      // 🚀 Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.blueStart,
                                  AppColors.blueEnd,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔁 Login Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              "Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: AppColors.blueStart,
                                fontWeight:
                                    FontWeight.bold,
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
      ),
    );
  }

Widget _input({
  required String hint,
  required TextEditingController controller,
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ));
  }
}


