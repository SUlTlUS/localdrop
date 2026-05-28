import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'screens/home_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/app_background.dart';

class LocalDropApp extends StatelessWidget {
  const LocalDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    const transparent = Colors.transparent;

    return MaterialApp(
      title: 'LocalDrop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
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

    return GlassPage(
      // Same structure as the package demos: GlassPage owns the background,
      // Scaffold extends behind the bar, and GlassBottomBar lives directly in
      // Scaffold.bottomNavigationBar.
      background: const AppBackground(child: SizedBox.expand()),
      statusBarStyle: GlassStatusBarStyle.auto,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: GlassBottomBar(
          selectedIndex: _currentIndex,
          onTabSelected: (index) => setState(() => _currentIndex = index),
          barHeight: 56,
          iconSize: 22,
          labelFontSize: 10,
          iconLabelSpacing: 2,
          horizontalPadding: 16,
          verticalPadding: 12,
          spacing: 0,
          selectedIconColor: iconColor,
          unselectedIconColor: iconColor.withValues(alpha: 0.5),
          indicatorColor: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
          maskingQuality: MaskingQuality.high,
          textStyle: TextStyle(
            fontSize: 10,
            color: iconColor,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            GlassBottomBarTab(
              icon: Icon(Icons.devices_rounded),
              activeIcon: Icon(Icons.devices_rounded),
              label: '设备',
            ),
            GlassBottomBarTab(
              icon: Icon(Icons.swap_horiz_rounded),
              activeIcon: Icon(Icons.swap_horiz_rounded),
              label: '传输',
            ),
            GlassBottomBarTab(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: '历史',
            ),
          ],
        ),
      ),
    );
  }
}
