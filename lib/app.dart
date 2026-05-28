import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'screens/home_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/history_screen.dart';

class LocalDropApp extends StatelessWidget {
  const LocalDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalDrop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ReceiveScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: GlassBottomBar(
            selectedIndex: _currentIndex,
            onTabSelected: (index) => setState(() => _currentIndex = index),
            barHeight: 52,
            iconSize: 20,
            labelFontSize: 10,
            iconLabelSpacing: 2,
            horizontalPadding: 8,
            verticalPadding: 6,
            spacing: 0,
            selectedIconColor: iconColor,
            unselectedIconColor: iconColor.withValues(alpha: 0.5),
            textStyle: TextStyle(
              fontSize: 10,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              GlassBottomBarTab(
                icon: Icon(Icons.devices_rounded),
                label: '设备',
              ),
              GlassBottomBarTab(
                icon: Icon(Icons.swap_horiz_rounded),
                label: '传输',
              ),
              GlassBottomBarTab(
                icon: Icon(Icons.history_rounded),
                label: '历史',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
