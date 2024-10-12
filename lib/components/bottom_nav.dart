import 'package:Beepo/screens/activity/activity_hub.dart';
import 'package:Beepo/screens/profile/profile_screen.dart';
import 'package:Beepo/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../screens/messaging/chat_tabs_screen.dart';

class BottomNavHome extends StatefulWidget {
  const BottomNavHome({super.key});

  @override
  State<BottomNavHome> createState() => _BottomNavHomeState();
}

class _BottomNavHomeState extends State<BottomNavHome> {
  int index = 0;
  List<Widget> body = [
    const ChatTabsScreen(),
    const WalletScreen(),
    const ActivityHubScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: body[index],
        extendBody: false,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: index,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.grey,
          selectedItemColor: const Color(0xffFF9C34),
          onTap: (int selectedPage) {
            setState(() => index = selectedPage);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.message),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.wallet),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.star),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.security_user),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
