import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/history_screen.dart';
import 'services/discovery_service.dart';
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
  static const double _minBottomBarWidth = 320;
  static const double _maxBottomBarWidth = 520;

  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ReceiveScreen(),
    HistoryScreen(),
  ];

  String get _title => switch (_currentIndex) {
        0 => 'LocalDrop',
        1 => '设备消息',
        _ => '传输历史',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final discoveryService = context.read<DiscoveryService>();

    return GlassPage(
      background: const AppBackground(child: SizedBox.expand()),
      statusBarStyle: GlassStatusBarStyle.auto,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(_title)),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _minBottomBarWidth,
              maxWidth: _maxBottomBarWidth,
            ),
            child: GlassBottomBar(
              selectedIndex: _currentIndex,
              onTabSelected: (index) => setState(() => _currentIndex = index),
              selectedIconColor: iconColor,
              unselectedIconColor: iconColor.withValues(alpha: 0.45),
              indicatorColor: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
              maskingQuality: MaskingQuality.high,
              extraButton: GlassBottomBarExtraButton(
                icon: const Icon(Icons.refresh_rounded),
                label: '刷新',
                onTap: discoveryService.refresh,
              ),
              tabs: const [
                GlassBottomBarTab(
                  icon: Icon(Icons.devices_rounded),
                  activeIcon: Icon(Icons.devices_rounded),
                  label: '设备',
                ),
                GlassBottomBarTab(
                  icon: Icon(Icons.forum_rounded),
                  activeIcon: Icon(Icons.forum_rounded),
                  label: '消息',
                ),
                GlassBottomBarTab(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: '历史',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
