import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'admin_screen.dart';
import 'map_screen.dart';
import 'saved_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  int _adminTapCount = 0;
  DateTime? _adminTapStart;

  final _screens = const [MapScreen(), SavedScreen()];

  void _onNavTap(int i) {
    if (i == _currentIndex) {
      final now = DateTime.now();
      if (_adminTapStart != null && now.difference(_adminTapStart!) < const Duration(seconds: 3)) {
        _adminTapCount++;
        if (_adminTapCount >= 7) {
          _adminTapCount = 0;
          _adminTapStart = null;
          _openAdminIfAuthorized();
          return;
        }
      } else {
        _adminTapCount = 1;
        _adminTapStart = now;
      }
    }
    setState(() => _currentIndex = i);
  }

  Future<void> _openAdminIfAuthorized() async {
    final granted = await showAdminPinDialog(context);
    if (granted && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        backgroundColor: GlutTheme.ash,
        selectedItemColor: GlutTheme.ember,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: AppLocalizations.of(context)!.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: AppLocalizations.of(context)!.navSaved,
          ),
        ],
      ),
    );
  }
}
