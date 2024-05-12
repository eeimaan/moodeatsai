import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/provider/provider.dart';
import 'package:moodeatsai/screens/save_recipe_screen.dart';
import 'package:provider/provider.dart';
import 'package:moodeatsai/screens/screens.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late BottomNavigationProvider _bottomNavigationProvider;

  @override
  void initState() {
    super.initState();
    _bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
       SchedulerBinding.instance!.addPostFrameCallback((_) {
        _bottomNavigationProvider.selectedIndex = 1;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, indexValue, child) => Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(indexValue.selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          useLegacyColorScheme: false,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: <BottomNavigationBarItem>[
            _buildNavItem(Icons.collections, indexValue.selectedIndex == 0),
            _buildNavItem(Icons.restaurant, indexValue.selectedIndex == 1),
            _buildNavItem(Icons.settings, indexValue.selectedIndex == 2),
          ],
          currentIndex: indexValue.selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  static const List<Widget> _widgetOptions = <Widget>[
  SaveRecipeScreen(
      title: 'Here are your save recipes',
    ),
    HomeScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    _bottomNavigationProvider.selectedIndex = index;
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.darkYellow : Colors.transparent,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
      label: '',
    );
  }
}
