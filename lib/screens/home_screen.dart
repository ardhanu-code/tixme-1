import 'package:flutter/material.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/screens/movies/movie_screen.dart';
import 'package:tixme/screens/tickets/ticket_screen.dart';
import 'package:tixme/services/session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> screens = [MovieScreen(), TicketScreen()];
  int _selectedIndex = 0;
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await AuthPreferences.getUsername();
    final userEmail = await AuthPreferences.getEmail();
    setState(() {
      username = user;
      email = userEmail;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColor.primary,

        selectedFontSize: 14,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_outlined),
            label: 'Ticket',
          ),
        ],
      ),
    );
  }
}
