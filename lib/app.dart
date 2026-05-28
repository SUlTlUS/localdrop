import 'dart:math' as math;

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
      // Keep the page background and bottom bar in the same backdrop scope so
      // the bottom navigation glass can sample the real content behind it.
      background: const AppBackground(child: SizedBox.expand()),
      statusBarStyle: GlassStatusBarStyle.auto,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _PersistentGlassBottomBar(
          selectedIndex: _currentIndex,
          selectedColor: iconColor,
          unselectedColor: iconColor.withValues(alpha: 0.5),
          isDark: isDark,
          onTabSelected: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _PersistentGlassBottomBar extends StatelessWidget {
  const _PersistentGlassBottomBar({
    required this.selectedIndex,
    required this.selectedColor,
    required this.unselectedColor,
    required this.isDark,
    required this.onTabSelected,
  });

  static const _tabs = [
    _BottomNavItem(Icons.devices_rounded, '设备'),
    _BottomNavItem(Icons.swap_horiz_rounded, '传输'),
    _BottomNavItem(Icons.history_rounded, '历史'),
  ];

  static const _barHeight = 56.0;
  static const _horizontalMargin = 16.0;
  static const _verticalMargin = 12.0;
  static const _innerPadding = 4.0;

  final int selectedIndex;
  final Color selectedColor;
  final Color unselectedColor;
  final bool isDark;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        _horizontalMargin,
        0,
        _horizontalMargin,
        _verticalMargin,
      ),
      child: SizedBox(
        height: _barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _tabs.length;
            final indicatorWidth = itemWidth - _innerPadding * 2;

            return Stack(
              children: [
                GlassContainer(
                  width: double.infinity,
                  height: _barHeight,
                  useOwnLayer: true,
                  quality: GlassQuality.premium,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 28),
                  settings: LiquidGlassSettings(
                    thickness: 42,
                    blur: 5,
                    refractiveIndex: 1.72,
                    chromaticAberration: 0.55,
                    lightIntensity: 0.85,
                    saturation: 0.85,
                    ambientStrength: 1,
                    lightAngle: 0.75 * math.pi,
                    glassColor: Color(isDark ? 0x33FFFFFF : 0x44FFFFFF),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * itemWidth + _innerPadding,
                  top: _innerPadding,
                  width: indicatorWidth,
                  height: _barHeight - _innerPadding * 2,
                  child: GlassContainer(
                    useOwnLayer: true,
                    quality: GlassQuality.premium,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                    settings: LiquidGlassSettings(
                      thickness: 68,
                      blur: 1.5,
                      refractiveIndex: 1.92,
                      chromaticAberration: 0.9,
                      lightIntensity: 1,
                      saturation: 1.08,
                      ambientStrength: 1,
                      lightAngle: 0.75 * math.pi,
                      glassColor: Color(isDark ? 0x55FFFFFF : 0x66FFFFFF),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: _BottomTabButton(
                          item: _tabs[i],
                          selected: i == selectedIndex,
                          selectedColor: selectedColor,
                          unselectedColor: unselectedColor,
                          onTap: () => onTabSelected(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      containedInkWell: false,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
