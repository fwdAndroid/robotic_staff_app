import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robotic_staff_app/screens/auth/request_password_screen.dart';
import 'package:robotic_staff_app/screens/main/main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(child: Image.asset('assets/logo.png', height: 200)),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email")),
                  );
                  return;
                }

                // Query staff collection for staffId by email
                QuerySnapshot snapshot = await FirebaseFirestore.instance
                    .collection('staff')
                    .where('email', isEqualTo: email)
                    .get();

                String? staffId;
                if (snapshot.docs.isNotEmpty) {
                  staffId =
                      snapshot.docs.first.id; // Firestore document ID here
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestPasswordScreen(staffId: staffId!),
                  ),
                );
              },
              child: const Text(
                "Request Password?",
                style: TextStyle(color: Color(0xff0A5EFE)),
              ),
            ),
            const SizedBox(height: 12),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginAdmin,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xff0A5EFE),
                      fixedSize: const Size(285, 54),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> loginAdmin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('staff')
          .where('email', isEqualTo: email)
          .where(
            'password',
            isEqualTo: password,
          ) // ⚠️ Use hashed password in real apps
          .get();

      if (snapshot.docs.isNotEmpty) {
        var staffDoc = snapshot.docs.first;
        String staffId = staffDoc.id; // Firestore document ID
        String staffName = staffDoc['name'] ?? 'Unknown';

        // Update status to online
        await FirebaseFirestore.instance
            .collection('staff')
            .doc(staffId)
            .update({'status': 'online'});

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainDashboard(staffId: staffId, staffName: staffName),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }
}
