import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 1. Import màn hình Home và Library từ thư mục features
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Thiết lập hiển thị tràn viền (Edge-to-Edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  runApp(const PetAIApp());
}

class PetAIApp extends StatelessWidget {
  const PetAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D9488), // Màu Teal
        fontFamily: 'Inter',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 2. Cập nhật danh sách màn hình
  final List<Widget> _screens = [
    HomeScreen(), // Tab 0
    const LibraryScreen(), // Tab 1: Đã kết nối với file library_screen.dart
    const Center(child: Text("Ghép đôi")), // Tab 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng IndexedStack để giữ trạng thái cuộn khi chuyển tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF0D9488),
        type: BottomNavigationBarType.fixed, // Giúp các icon không bị nhảy khi nhấn
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Quét AI'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Ghép đôi'),
        ],
      ),
    );
  }
}