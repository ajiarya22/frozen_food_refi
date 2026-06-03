import 'package:flutter/material.dart';
import 'services/api_service.dart'; 
import 'session.dart';  

//  HALAMAN LOGIN ADMIN
class LoginAdminPage extends StatefulWidget { 
  const LoginAdminPage({super.key});
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {

  // ── CONTROLLER: baca teks yang diketik user ──
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>(); //validasi seleruh form             

  // ── STATE ──  
  bool _obscurePassword = true;  //pasword disembunyikan
  bool _isLoading       = false; 

  // ── WARNA GLOBAL──
  static const Color _purple     = Color(0xFF2727B8); 
  static const Color _bgScreen   = Color(0xFFF0F2FF); 
  static const Color _fieldBg    = Colors.white;      
  static const Color _borderIdle = Color(0xFFE2E5F8); 


  //  FUNGSI LOGIN
  void _handleLogin() async { //mengatur proses login
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);        

    try {
      final result = await ApiService().loginAdmin( 
        _emailController.text.trim(), //trim hapus spasi         
        _passwordController.text,
      );

      setState(() => _isLoading = false); //spiner hilang
      if (!mounted) return;
      

      if (result['status'] == 'success') { //login berhasil
        AdminSession.save(result['data']); //simpan data

        // notifikasi hijau → login berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login Berhasil'), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/admin-dashboard');

      } else {
        _showErrorSnackBar(result['message'] ?? 'Login gagal'); 
      }

    } catch (e) { //untuk menangkap eror
      print("ERROR ASLI: $e");       
      _showErrorSnackBar("Error: $e"); //penanganan error.
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE24B4A), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() { //membersihkan controler ketika halaman di tutup
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildField({ // Ini fungsi / cetakan templatenya
    required TextEditingController controller,
    required String label,       
    required String hint,        
    required IconData prefixIcon, 
    bool isPassword = false,      
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // label di atas field
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666680),
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false, //untk mwnywmbunykan passwrd
          keyboardType: isPassword
              ? TextInputType.visiblePassword  
              : TextInputType.emailAddress,    
          validator: validator,

          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w500,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),

            prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400, size: 20), //mata password

            // tombol mata → hanya muncul di field password
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword); //tombol mata
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined 
                          : Icons.visibility_outlined,    
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  )
                : null, 

            filled: true,
            fillColor: _fieldBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),

            border: OutlineInputBorder(              
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _borderIdle, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(       
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _purple, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(        
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( //kerangka halaman
      backgroundColor: _bgScreen,
      body: Column(
        children: [

          // ── HEADER UNGU ──────────────────────
          Container(
            color: _purple,
            child: SafeArea(      //agar ui tidak tertutup      
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // tombol back dengan efek ripple saat ditekan
                    Material(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell( //agar icon bisa di pencet
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => Navigator.maybePop(context), //kembali halamn sebelumnya
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [

                        // logo bulat toko
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo_refi.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon( 
                                Icons.storefront_rounded,
                                color: Colors.white70,
                                size: 100,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // nama toko di samping logo
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PANEL PENGELOLA',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Refi Frozen Food',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GELOMBANG: transisi visual header → form ──
          ClipPath(
            clipper: _WaveClipper(), 
            child: Container(height: 36, color: _purple),
          ),

          // ── FORM LOGIN ───────────────────────
          Expanded( //wadh validasi input terhubung ke _formKey
            child: SingleChildScrollView( 
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              child: Form(
                key: _formKey, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'MASUK KE AKUN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // field email/username
                    _buildField(
                      controller: _emailController,
                      label: 'Username / Email',
                      hint: 'admin',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Username tidak boleh kosong';
                        return null; // null = valid
                      },
                    ),

                    const SizedBox(height: 16),

                    // field password (isPassword: true → sembunyikan teks + tombol mata)
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'minimal 6 digit',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password tidak boleh kosong';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // tombol login
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin, //agar tidak di pencet berulang
                        style: ElevatedButton.styleFrom( //tombol masuk
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            // tampil spinner jika sedang proses login
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator( //spiner
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            // tampil teks + icon jika tidak loading
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Masuk Sekarang',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> { //membuat efek glombang

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(    
      size.width * 0.5,        
      size.height * 1.6,      
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false; // jangan gambar ulang saat rebuild → hemat performa
}