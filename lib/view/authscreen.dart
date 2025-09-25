import 'package:bbs_booking_system/controller/authController.dart';
import 'package:bbs_booking_system/view/admin/navbaradmin.dart';
import 'package:bbs_booking_system/view/navbar.dart';
import 'package:bbs_booking_system/view/lupapassword.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AuthService _auth = AuthService();

  int selectedButtonIndex = 0;
  bool rememberMe = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isUsernameValid = true;
  bool _isPasswordMatching = true;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau Password Kosong!'),
        ),
      );
      return;
    }

    final user =
        await _auth.signInWithEmailAndPassword(email, password, rememberMe);
    if (user != null) {
      print("Login successful");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Sukses!'),
        ),
      );
      if (user.email! == 'bbs@admin.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBarAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBar()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password tidak sesuai!'),
        ),
      );
      print("Login failed");
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final displayName = _nameController.text.trim();

    setState(() {
      _isUsernameValid = displayName.length <= 12;
      _isPasswordMatching = password == confirmPassword;
    });

    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon Isi Username, Email dan Password'),
        ),
      );
      return;
    }

    if (!_isUsernameValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal username 12 karakter!'),
        ),
      );
      return;
    }

    if (!_isPasswordMatching) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak sesuai!'),
        ),
      );
      return;
    }

    if (!_validatePassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak Sesuai dengan ketentuan!'),
        ),
      );
      return;
    }

    if (await _auth.isUsernameTaken(displayName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Username Sudah Di Gunakan. Tolong Ubah Username Anda.'),
        ),
      );
      return;
    }

    bool registered = false;
    _auth.signUpUser(email, password, displayName, rememberMe);
    registered = true;

    if (registered) {
      print("Register successful");

      //reset isi regisnya
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();

      setState(() {
        selectedButtonIndex = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign Up Berhasil!'),
        ),
      );
    }
  }

  bool _validatePassword(String password) {
    final minLength = password.length >= 6;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    
    return minLength &&
        hasUppercase &&
        hasLowercase &&
        hasDigit ;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color yellowColor = Colors.yellow.withOpacity(1);
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      backgroundColor: kuningBBS,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenWidth - 175,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(200, 100),
                        ),
                        color: Colors.black,
                      ),
                    ),
                    ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(yellowColor, BlendMode.modulate),
                      child: Center(
                        child: Image.asset(
                          'assets/images/lampugantung.png',
                          width: screenWidth - 125,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: selectedButtonIndex == 0
                              ? screenHeight * 0.28
                              : screenHeight * 0.10),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight * 0.03),
                                ToggleButtons(
                                  isSelected: [
                                    selectedButtonIndex == 0,
                                    selectedButtonIndex == 1,
                                  ],
                                  onPressed: (index) {
                                    setState(() {
                                      selectedButtonIndex = index;
                                    });
                                  },
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenHeight * 0.01),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: screenWidth * 0.05,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenHeight * 0.01),
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: screenWidth * 0.05,
                                        ),
                                      ),
                                    ),
                                  ],
                                  selectedColor: Colors.white,
                                  color: Colors.black,
                                  fillColor: kuningBBS,
                                  borderRadius: BorderRadius.circular(20),
                                  borderWidth: 2,
                                  borderColor: Colors.transparent,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                selectedButtonIndex == 0
                                    ? Column(
                                        children: [
                                          _buildTextField(_emailController,
                                              'Email', screenWidth),
                                          _buildPasswordField(
                                              _passwordController,
                                              'Password',
                                              screenWidth),
                                          SizedBox(height: screenHeight * 0.02),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.02),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: rememberMe,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          rememberMe =
                                                              value ?? false;
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      'Ingat akun',
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.03),
                                                    ),
                                                  ],
                                                ),
                                                //LUPA PASSWORD
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LupaPassword()),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Lupa Password?',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.03,
                                                      color: kuningBBS,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: screenHeight * 0.03),
                                            child: ElevatedButton(
                                              onPressed: _login,
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: kuningBBS,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                                child: Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: screenWidth * 0.045,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _buildTextField(_nameController,
                                              'Username', screenWidth),
                                          if (!_isUsernameValid)
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.06),
                                              child: Text(
                                                'Maksimal username 12 karakter',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: screenWidth * 0.03,
                                                ),
                                              ),
                                            ),
                                          _buildTextField(_emailController,
                                              'Email', screenWidth),
                                          _buildPasswordField(
                                              _passwordController,
                                              'Password',
                                              screenWidth),
                                          _buildPasswordRequirements(
                                              _passwordController.text),
                                          _buildConfirmPasswordField(
                                              _confirmPasswordController,
                                              'Konfirmasi Password',
                                              screenWidth),
                                          if (!_isPasswordMatching)
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.06),
                                              child: Text(
                                                'Password berbeda',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: screenWidth * 0.03,
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: screenHeight * 0.03),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _register();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: kuningBBS,
                                              ),
                                              child: Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: screenWidth * 0.045,
                                                ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenWidth * 0.02),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hoverColor: Color.fromARGB(255, 71, 169, 146),
        ),
        onChanged: (text) {
          if (controller == _nameController) {
            setState(() {
              _isUsernameValid = text.length <= 12;
            });
          }
        },
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String labelText, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenWidth * 0.02),
      child: TextField(
        controller: controller,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: labelText,
          hoverColor: Color.fromARGB(255, 71, 169, 146),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        onChanged: (text) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(
      TextEditingController controller, String labelText, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenWidth * 0.02),
      child: TextField(
        controller: controller,
        obscureText: !_confirmPasswordVisible,
        decoration: InputDecoration(
          labelText: labelText,
          hoverColor: Color.fromARGB(255, 71, 169, 146),
          suffixIcon: IconButton(
            icon: Icon(
              _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
          ),
        ),
        onChanged: (text) {
          setState(() {
            _isPasswordMatching = text == _passwordController.text;
          });
        },
      ),
    );
  }

  Widget _buildPasswordRequirements(String password) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: (screenWidth * 0.05)),
      child: Column(
        children: [
          _buildRequirementItem("Minimal 6 karakter", password.length >= 6),
          _buildRequirementItem(
              "Karakter huruf besar", password.contains(RegExp(r'[A-Z]'))),
          _buildRequirementItem(
              "Karakter huruf kecil", password.contains(RegExp(r'[a-z]'))),
          _buildRequirementItem("Angka", password.contains(RegExp(r'[0-9]'))),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool fulfilled) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check : Icons.close,
          color: fulfilled ? Colors.green : Colors.red,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: screenWidth * 0.03),
        ),
      ],
    );
  }
}
