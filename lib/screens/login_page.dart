import 'package:flutter/material.dart';

import '../auth/sistem_autentikasi.dart';

class LoginPage extends StatefulWidget {
  final SistemAutentikasi autentikasi;

  const LoginPage({super.key, required this.autentikasi});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _pesanError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _pesanError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.autentikasi.isTerkunci) {
      setState(() {
        _pesanError =
            "Anda telah salah memasukkan login sebanyak ${widget.autentikasi.batasPercobaan} kali. Sistem terkunci.";
      });
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final success = widget.autentikasi.prosesLoginGUI(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      try {
        await widget.autentikasi.simpanSession(_usernameController.text);
      } catch (_) {}
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login berhasil! Selamat datang, ${_usernameController.text.trim()}.",
          ),
          backgroundColor: const Color(0xFF006D32),
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (widget.autentikasi.isTerkunci) {
          _pesanError =
              "Anda telah salah memasukkan login sebanyak ${widget.autentikasi.batasPercobaan} kali. Akses diblokir.";
        } else {
          _pesanError =
              "Username atau password salah. Sisa kesempatan mencoba: ${widget.autentikasi.sisaKesempatan} kali lagi.";
        }
      });
    }
  }

  void _handleReset() {
    setState(() {
      widget.autentikasi.resetPercobaan();
      _pesanError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Batas percobaan login berhasil di-reset."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTerkunci = widget.autentikasi.isTerkunci;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1E36), Color(0xFF1E3A5F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F1E36).withOpacity(0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 34, 32, 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F1E36), Color(0xFF1E3A5F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F1E36)
                                      .withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 32,
                              color: Color(0xFFE2C499),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1E36).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PORTAL ADMINISTRATOR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                                color: Color(0xFF0F1E36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Payroll Management System",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1E36),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Sistem Pengelolaan Payroll & Data Karyawan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (_pesanError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _pesanError!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _usernameController,
                          enabled: !isTerkunci,
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "Masukkan username admin",
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF0F1E36),
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF0F1E36),
                                width: 1.8,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Username tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          enabled: !isTerkunci,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Masukkan password",
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF0F1E36),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF0F1E36),
                                width: 1.8,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Password tidak boleh kosong";
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 22),

                        FilledButton(
                          onPressed: (_isLoading || isTerkunci)
                              ? null
                              : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F1E36),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            shadowColor: const Color(0xFF0F1E36)
                                .withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isTerkunci ? "Akun Terblokir" : "Login",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    if (!isTerkunci) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ],
                                ),
                        ),

                        if (isTerkunci) ...[
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _handleReset,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Reset Percobaan Login"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.key_rounded,
                                size: 16,
                                color: Color(0xFFC5A880),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
