import 'package:agriadmin/Screens/equipment_screen.dart';
import 'package:agriadmin/Screens/user_screen.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  final String userId;
  const NavigationBar({Key? key, required this.userId}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  late String id;
  List<Widget> _pages = const [];
  int currentIndex = 0;

  @override
  void initState() {
    _pages = [
      UserScreen(
        userId: widget.userId,
      ),
      EquipmentScreen(userId: widget.userId),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int value) {
          currentIndex = value;
          setState(() {});
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.yard), label: "Crops"),
          BottomNavigationBarItem(
              icon: Icon(Icons.construction), label: "Equipment"),
        ],
      ),
    );
  }
}
