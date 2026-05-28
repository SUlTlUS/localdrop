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
  final _backgroundKey = GlobalKey();
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ReceiveScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPage(
      // Same structure as the package demos: GlassPage owns the background,
      // Scaffold extends behind the bar, and GlassBottomBar lives directly in
      // Scaffold.bottomNavigationBar. The RepaintBoundary key is passed to the
      // bar so the Skia/Web refraction shader has a concrete source to sample.
      background: RepaintBoundary(
        key: _backgroundKey,
        child: const AppBackground(child: SizedBox.expand()),
      ),
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
          quality: GlassQuality.standard,
          backgroundKey: _backgroundKey,
          barHeight: 56,
          iconSize: 22,
          labelFontSize: 10,
          iconLabelSpacing: 2,
          horizontalPadding: 16,
          verticalPadding: 12,
          spacing: 0,

          // Match the official demo pattern: keep selected and unselected
          // colors visibly different, and do not override textStyle. The
          // bottom bar renders a second selected tab layer inside the indicator;
          // a fixed textStyle makes that foreground layer look identical.
          selectedIconColor: Colors.white,
          unselectedIconColor:
              (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.45),
          indicatorColor: Colors.blue.withValues(alpha: 0.2),
          indicatorSettings: const LiquidGlassSettings(
            thickness: 30,
            blur: 3,
            chromaticAberration: 0.3,
            refractiveIndex: 1.59,
          ),
          maskingQuality: MaskingQuality.high,
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
