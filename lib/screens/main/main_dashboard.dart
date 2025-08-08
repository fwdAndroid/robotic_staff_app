import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robotic_staff_app/screens/main/pages/account_screen.dart';
import 'package:robotic_staff_app/screens/main/pages/user_request_screen.dart';

class MainDashboard extends StatefulWidget {
  final String staffId; // Pass the staff document ID
  final int initialPageIndex;
  final String staffName;

  const MainDashboard({
    super.key,
    this.initialPageIndex = 0,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;

    // Initialize screens with the correct staffId
    _screens = [
      UserRequestScreen(staffId: widget.staffId, staffName: widget.staffName),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(color: Colors.white),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2, size: 25, color: Color(0xff0A5EFE)),
              label: "Users",
            ),
            BottomNavigationBarItem(
              label: "Account",
              icon: Icon(Icons.settings, size: 25, color: Color(0xff0A5EFE)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
