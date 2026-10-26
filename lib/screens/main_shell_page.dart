import 'package:flutter/material.dart';
import '../auth/sistem_autentikasi.dart';
import 'dashboard_overview_page.dart';
import 'stopwatch_page.dart';
import 'bantuan_page.dart';

/// MainShellPage dengan BottomNavigationBar 3 Menu Sesuai Ketentuan Tugas:
/// 1. Halaman Utama (dengan 5 Menu Vertikal di dalamnya)
/// 2. Stopwatch
/// 3. Bantuan cara penggunaan aplikasi dan Logout
class MainShellPage extends StatefulWidget {
  final SistemAutentikasi autentikasi;
  final int initialTabIndex;

  const MainShellPage({
    super.key,
    required this.autentikasi,
    this.initialTabIndex = 0,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardOverviewPage(),
      const StopwatchPage(),
      BantuanPage(autentikasi: widget.autentikasi),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0F1E36),
            unselectedItemColor: const Color(0xFF868E96),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, height: 1.4),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 1.4),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded, color: Color(0xFF0F1E36)),
                label: 'Halaman Utama',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer_rounded, color: Color(0xFF0F1E36)),
                label: 'Stopwatch',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline_rounded),
                activeIcon: Icon(Icons.help_rounded, color: Color(0xFF0F1E36)),
                label: 'Bantuan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

