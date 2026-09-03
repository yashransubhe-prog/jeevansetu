import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const navy = Color(0xFF073C4D);
const deepNavy = Color(0xFF032833);
const cyan = Color(0xFF14BFD4);
const aqua = Color(0xFF57E1E8);
const blue = Color(0xFF4387F4);
const red = Color(0xFFFF3B55);
const green = Color(0xFF20C98A);
const orange = Color(0xFFFFA42E);
const purple = Color(0xFF7758DF);
const bg = Color(0xFFF3F8FA);
const ink = Color(0xFF102027);

class JeevanSetuApp extends StatelessWidget {
  const JeevanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JeevanSetu',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          primary: cyan,
          secondary: blue,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: bg,
          surfaceTintColor: bg,
          foregroundColor: ink,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDDF6F9),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? navy
                  : const Color(0xFF64757B),
            ),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

Route<T> jsRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 440),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: page,
    ),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(.04, .015),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}

class ReferenceAtlas {
  static Future<Uint8List>? _cache;
  static Future<Uint8List> get bytes {
    return _cache ??= rootBundle
        .loadString('assets/reference_atlas.b64')
        .then((text) => base64Decode(text.trim()));
  }
}

/// The image is the locally bundled atlas made from the exact visual references
/// supplied in the SIH UI board, so the intro does not depend on dead URLs.
class ReferencePhoto extends StatelessWidget {
  final int scene;
  final BoxFit fit;
  const ReferencePhoto(this.scene, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final y = (-1.0 + scene.clamp(0, 4) * .5).clamp(-1.0, 1.0);
    return FutureBuilder<Uint8List>(
      future: ReferenceAtlas.bytes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E82A0), deepNavy],
              ),
            ),
          );
        }
        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          height: double.infinity,
          fit: fit,
          alignment: Alignment(0, y),
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        );
      },
    );
  }
}

class LogoMark extends StatelessWidget {
  final double size;
  final Color color;
  const LogoMark({super.key, this.size = 80, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .72,
      child: CustomPaint(painter: _LogoPainter(color)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .115
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final path = ui.Path()
      ..moveTo(s.width * .08, s.height * .86)
      ..lineTo(s.width * .43, s.height * .16)
      ..lineTo(s.width * .70, s.height * .64)
      ..lineTo(s.width * .92, s.height * .40);
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(s.width * .38, s.height * .64),
      Offset(s.width * .69, s.height * .64),
      Paint()
        ..color = color.withValues(alpha: .75)
        ..strokeWidth = s.width * .065
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => oldDelegate.color != color;
}

class CinematicReference extends StatefulWidget {
  final int scene;
  final Widget child;
  final double darkness;
  const CinematicReference({
    super.key,
    required this.scene,
    required this.child,
    this.darkness = .28,
  });

  @override
  State<CinematicReference> createState() => _CinematicReferenceState();
}

class _CinematicReferenceState extends State<CinematicReference>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: 1.025 + controller.value * .035,
              child: ReferencePhoto(widget.scene),
            ),
            Container(color: Colors.black.withValues(alpha: widget.darkness)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    deepNavy.withValues(alpha: .10),
                    deepNavy.withValues(alpha: .94),
                  ],
                  stops: const [.08, .48, 1],
                ),
              ),
            ),
            Positioned(
              top: 110 + math.sin(controller.value * math.pi * 2) * 8,
              left: -60,
              right: -60,
              height: 120,
              child: IgnorePointer(
                child: CustomPaint(painter: _MistPainter(controller.value)),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _MistPainter extends CustomPainter {
  final double t;
  _MistPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: .055);
    for (var i = 0; i < 7; i++) {
      final x = ((i * 126.0) + t * size.width * .18) % (size.width + 180) - 90;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, 28 + (i % 3) * 34),
          width: 175,
          height: 38,
        ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MistPainter oldDelegate) => oldDelegate.t != t;
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController loading;

  @override
  void initState() {
    super.initState();
    loading = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    Timer(const Duration(milliseconds: 2350), () {
      if (mounted) {
        Navigator.pushReplacement(context, jsRoute(const OnboardingPage()));
      }
    });
  }

  @override
  void dispose() {
    loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: CinematicReference(
        scene: 0,
        darkness: .24,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              children: [
                const Spacer(flex: 4),
                const LogoMark(size: 96),
                const SizedBox(height: 14),
                const Text(
                  'JeevanSetu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Disaster Monitoring & Response',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: cyan.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: aqua.withValues(alpha: .35)),
                  ),
                  child: const Text(
                    'SIH 2026 · PS26001',
                    style: TextStyle(
                      color: aqua,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Spacer(flex: 5),
                const Text(
                  'Initializing Nepal Risk Intelligence',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: loading,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: loading.value,
                      minHeight: 5,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int page = 0;

  final slides = const [
    (
      'Safer Communities\nwith Smarter Monitoring',
      'AI-powered landslide and flood risk analysis for early warning and faster response.',
      1,
    ),
    (
      'Real-Time Risk\nInsights',
      'Live maps, explainable AI analysis, weather intelligence and verified community alerts.',
      2,
    ),
    (
      'Report · Respond\n· Stay Safe',
      'A unified platform for citizens, rescue teams, authorities, volunteers and organisations.',
      3,
    ),
  ];

  void advance() {
    if (page < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.push(context, jsRoute(const RolePickerPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: PageView.builder(
        controller: controller,
        itemCount: slides.length,
        onPageChanged: (value) => setState(() => page = value),
        itemBuilder: (_, index) {
          final slide = slides[index];
          return CinematicReference(
            scene: slide.$3,
            darkness: .18,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      slide.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      slide.$2,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        Text(
                          '${index + 1} / 3',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 13),
                        ...List.generate(
                          3,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.only(right: 5),
                            width: i == index ? 24 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == index ? aqua : Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            jsRoute(const RolePickerPage()),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        FloatingActionButton.small(
                          heroTag: 'intro_$index',
                          elevation: 0,
                          backgroundColor: aqua,
                          foregroundColor: navy,
                          onPressed: advance,
                          child: Icon(
                            index == 2
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum UserRole { citizen, rescue, authority, volunteer, organization }

extension UserRoleInfo on UserRole {
  String get title => switch (this) {
        UserRole.citizen => 'Citizen',
        UserRole.rescue => 'Rescue Team',
        UserRole.authority => 'Authority',
        UserRole.volunteer => 'Volunteer',
        UserRole.organization => 'Organization',
      };

  String get subtitle => switch (this) {
        UserRole.citizen => 'Report, receive alerts, navigate to safety',
        UserRole.rescue => 'Dispatch, triage and coordinate field missions',
        UserRole.authority => 'Monitor, verify, broadcast and command',
        UserRole.volunteer => 'Support camps, check-ins and supply missions',
        UserRole.organization => 'Offer shelters, inventory and logistics',
      };

  IconData get icon => switch (this) {
        UserRole.citizen => Icons.person_rounded,
        UserRole.rescue => Icons.health_and_safety_rounded,
        UserRole.authority => Icons.account_balance_rounded,
        UserRole.volunteer => Icons.volunteer_activism_rounded,
        UserRole.organization => Icons.business_center_rounded,
      };

  Color get color => switch (this) {
        UserRole.citizen => green,
        UserRole.rescue => red,
        UserRole.authority => blue,
        UserRole.volunteer => purple,
        UserRole.organization => orange,
      };
}

class RolePickerPage extends StatelessWidget {
  const RolePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ReferencePhoto(0),
          Container(color: deepNavy.withValues(alpha: .84)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Select your role to open a purpose-built response experience.',
                  style: TextStyle(color: Colors.white60, fontSize: 12.5),
                ),
                const SizedBox(height: 22),
                ...UserRole.values.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.push(
                          context,
                          jsRoute(LoginPage(role: role)),
                        ),
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                role.color,
                                role.color.withValues(alpha: .72),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: role.color.withValues(alpha: .22),
                                blurRadius: 20,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .92),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(role.icon, color: role.color),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      role.subtitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final UserRole role;
  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ReferencePhoto(0),
          Container(color: deepNavy.withValues(alpha: .88)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        const LogoMark(size: 76),
                        const SizedBox(height: 7),
                        const Text(
                          'JeevanSetu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: role.color.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: role.color.withValues(alpha: .45)),
                          ),
                          child: Text(
                            '${role.title} access',
                            style: TextStyle(
                              color: role.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 23),
                  const _GlassField(Icons.person_outline_rounded, 'Email or Phone'),
                  const SizedBox(height: 11),
                  const _GlassField(Icons.lock_outline_rounded, 'Password', obscure: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: role.color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        jsRoute(AppShell(role: role)),
                        (_) => false,
                      ),
                      child: Text(
                        'Sign in as ${role.title}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        jsRoute(AppShell(role: role)),
                        (_) => false,
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Use SIH demo access'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  const _GlassField(this.icon, this.hint, {this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .09),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: aqua),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final UserRole role;
  const AppShell({super.key, required this.role});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RoleHome(role: widget.role),
      const RiskMapPage(),
      const SosPage(),
      const AlertsPage(),
      MorePage(role: widget.role),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.sos_outlined),
            selectedIcon: Icon(Icons.sos_rounded),
            label: 'SOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

Widget surface(
  Widget child, {
  EdgeInsets padding = const EdgeInsets.all(14),
  Color color = Colors.white,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8F0F2)),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: .055),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

class TapSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets padding;
  const TapSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8F0F2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

PreferredSizeWidget jsAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
    ),
  );
}

class RoleHome extends StatelessWidget {
  final UserRole role;
  const RoleHome({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HomeHero(role: role)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList.list(
              children: [
                _RiskBanner(
                  onTap: () => Navigator.push(
                    context,
                    jsRoute(const EarlyWarningPage()),
                  ),
                ),
                const SizedBox(height: 12),
                const _WeatherStrip(),
                const SizedBox(height: 18),
                sectionTitle('Safety tools', 'Live, actionable and one tap away'),
                const SizedBox(height: 10),
                _QuickActions(role: role),
                const SizedBox(height: 19),
                _RoleCommandCard(role: role),
                const SizedBox(height: 19),
                sectionTitle('AI Slope Sentinel', 'Explainable risk, not a black box'),
                const SizedBox(height: 10),
                TapSurface(
                  onTap: () => Navigator.push(
                    context,
                    jsRoute(const RiskAnalysisPage()),
                  ),
                  child: const Row(
                    children: [
                      MiniGauge(.78),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'High landslide probability',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rainfall + soil saturation + slope geometry are driving the score.',
                              style: TextStyle(color: Colors.black54, fontSize: 10.5, height: 1.35),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'WHY THIS SCORE  →',
                              style: TextStyle(color: blue, fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                sectionTitle('Community pulse', 'Verified signals around you'),
                const SizedBox(height: 10),
                TapSurface(
                  onTap: () => Navigator.push(
                    context,
                    jsRoute(const CommunityReportsPage()),
                  ),
                  child: const Column(
                    children: [
                      SignalRow(
                        Icons.landscape_rounded,
                        red,
                        'Slope movement reported',
                        'Sindhupalchok · 2.4 km · AI verified',
                        '92%',
                      ),
                      Divider(height: 24),
                      SignalRow(
                        Icons.route_rounded,
                        orange,
                        'Road partially blocked',
                        'Araniko Highway · 4.1 km',
                        '3 reports',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final UserRole role;
  const _HomeHero({required this.role});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReferencePhoto(0),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  deepNavy.withValues(alpha: .24),
                  deepNavy.withValues(alpha: .92),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: role.color,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(role.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Namaste,', style: TextStyle(color: Colors.white60, fontSize: 10)),
                          Text(
                            role.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'NEPAL RISK INTELLIGENCE',
                  style: TextStyle(
                    color: aqua,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Know the slope\nbefore it moves.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(child: HeroStat('RISK', '78%', red)),
                    SizedBox(width: 7),
                    Expanded(child: HeroStat('24H RAIN', '126 mm', blue)),
                    SizedBox(width: 7),
                    Expanded(child: HeroStat('SAFE HUBS', '18', green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroStat extends StatelessWidget {
  final String keyText;
  final String value;
  final Color color;
  const HeroStat(this.keyText, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            keyText,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RiskBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _RiskBanner({required this.onTap});

  @override
  State<_RiskBanner> createState() => _RiskBannerState();
}

class _RiskBannerState extends State<_RiskBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF3150), Color(0xFFF05662)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: red.withValues(alpha: .22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => Transform.scale(
                  scale: .94 + pulse.value * .1,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 27),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Landslide Risk',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Potential slope failure within 12 hours. A safer evacuation corridor is ready.',
                      style: TextStyle(color: Colors.white, fontSize: 11.2, height: 1.35),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'OPEN EARLY WARNING  →',
                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherStrip extends StatelessWidget {
  const _WeatherStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: surface(
            const Row(
              children: [
                Icon(Icons.cloudy_snowing, color: blue, size: 28),
                SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('12°C', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Text('Heavy rain', style: TextStyle(fontSize: 9.5, color: Colors.black45)),
                  ],
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: surface(
            const Row(
              children: [
                Icon(Icons.water_drop_rounded, color: cyan, size: 27),
                SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('87%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Text('Soil saturation', style: TextStyle(fontSize: 9.5, color: Colors.black45)),
                  ],
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

Widget sectionTitle(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45)),
    ],
  );
}

class _QuickActions extends StatelessWidget {
  final UserRole role;
  const _QuickActions({required this.role});

  @override
  Widget build(BuildContext context) {
    final data = <(IconData, String, Color, Widget)>[
      (Icons.map_rounded, 'Live Risk\nMap', green, const RiskMapPage()),
      (Icons.route_rounded, 'Safe\nRoute', cyan, const SafeRoutePage()),
      (Icons.psychology_alt_rounded, 'AI Risk\nAnalysis', blue, const RiskAnalysisPage()),
      (Icons.post_add_rounded, 'Report\nIncident', orange, const ReportIncidentPage()),
      (Icons.inventory_2_rounded, 'Relief &\nResources', green, const ResourcesPage()),
      (Icons.smart_toy_rounded, 'AI Safety\nAssistant', purple, const AssistantPage()),
    ];
    return GridView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, index) {
        final item = data[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(context, jsRoute(item.$4)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8F0F2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: item.$3.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$1, color: item.$3, size: 22),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, height: 1.12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleCommandCard extends StatelessWidget {
  final UserRole role;
  const _RoleCommandCard({required this.role});

  @override
  Widget build(BuildContext context) {
    late String title;
    late String subtitle;
    late IconData icon;
    late Widget page;
    switch (role) {
      case UserRole.citizen:
        title = 'Personal Safety';
        subtitle = '4 family members · 3 safe · 1 awaiting check-in';
        icon = Icons.family_restroom_rounded;
        page = const PersonalSafetyPage();
      case UserRole.rescue:
        title = 'Rescue Command';
        subtitle = '3 active missions · 11 responders deployed';
        icon = Icons.emergency_rounded;
        page = const RescueCommandPage();
      case UserRole.authority:
        title = 'Authority Command Center';
        subtitle = '4 high-risk zones · broadcast readiness 96%';
        icon = Icons.radar_rounded;
        page = const AuthorityCenterPage();
      case UserRole.volunteer:
        title = 'Volunteer Operations';
        subtitle = '2 nearby relief tasks · 18 volunteers online';
        icon = Icons.volunteer_activism_rounded;
        page = const VolunteerOpsPage();
      case UserRole.organization:
        title = 'Resource Command';
        subtitle = '4 facilities · 730 beds · 81% inventory ready';
        icon = Icons.inventory_rounded;
        page = const OrganizationOpsPage();
    }
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, jsRoute(page)),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [navy, Color.lerp(navy, role.color, .38)!],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: aqua),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniGauge extends StatelessWidget {
  final double value;
  const MiniGauge(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: CustomPaint(
        painter: GaugePainter(value),
        child: Center(
          child: Text(
            '${(value * 100).round()}%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFFFE1E6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) => oldDelegate.value != value;
}

class SignalRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  const SignalRow(
    this.icon,
    this.color,
    this.title,
    this.subtitle,
    this.badge, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            badge,
            style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class RiskMapPage extends StatefulWidget {
  const RiskMapPage({super.key});

  @override
  State<RiskMapPage> createState() => _RiskMapPageState();
}

class _RiskMapPageState extends State<RiskMapPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  bool forecast = false;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  void openHotspot(String name, int risk) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 5, backgroundColor: red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  ),
                  Text('$risk%', style: const TextStyle(fontSize: 20, color: red, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Heavy rainfall, saturated soil and steep terrain are increasing the simulated failure probability. Use the cyan evacuation corridor instead of the red-zone road.',
                style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(context, jsRoute(const SafeRoutePage()));
                  },
                  icon: const Icon(Icons.route_rounded),
                  label: const Text('Open safest route'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Marker hotspot(LatLng point, String name, int risk, Color color) {
    return Marker(
      point: point,
      width: 64,
      height: 64,
      child: GestureDetector(
        onTap: () => openHotspot(name, risk),
        child: AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 35 + pulse.value * 13,
                height: 35 + pulse.value * 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: .14),
                ),
              ),
              Icon(Icons.location_on_rounded, color: color, size: 39),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                const Text('Risk Map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 3.5, backgroundColor: green),
                      SizedBox(width: 6),
                      Text('LIVE MAP', style: TextStyle(color: green, fontSize: 8.5, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: mapToggle('Live', !forecast, () => setState(() => forecast = false)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: mapToggle('Next 48 Hours', forecast, () => setState(() => forecast = true)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(27.70, 85.32),
                    initialZoom: 7.35,
                    minZoom: 5,
                    maxZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sih.jeevansetu',
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: const [
                            LatLng(27.95, 85.42),
                            LatLng(27.86, 85.78),
                            LatLng(27.64, 85.70),
                            LatLng(27.60, 85.37),
                            LatLng(27.79, 85.24),
                          ],
                          color: red.withValues(alpha: forecast ? .16 : .24),
                          borderColor: red.withValues(alpha: .8),
                          borderStrokeWidth: 2,
                        ),
                        Polygon(
                          points: const [
                            LatLng(28.38, 83.72),
                            LatLng(28.28, 84.04),
                            LatLng(28.04, 83.96),
                            LatLng(28.08, 83.59),
                          ],
                          color: orange.withValues(alpha: .18),
                          borderColor: orange.withValues(alpha: .8),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: const [
                            LatLng(27.7172, 85.3240),
                            LatLng(27.76, 85.42),
                            LatLng(27.83, 85.55),
                          ],
                          strokeWidth: 5,
                          color: cyan,
                          borderColor: Colors.white,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        hotspot(const LatLng(27.83, 85.55), 'Sindhupalchok', 86, red),
                        hotspot(const LatLng(27.7172, 85.3240), 'Kathmandu', 64, orange),
                        hotspot(const LatLng(28.2096, 83.9856), 'Pokhara', 71, orange),
                        hotspot(const LatLng(27.5291, 84.3542), 'Chitwan', 42, green),
                      ],
                    ),
                  ],
                ),
                Positioned(left: 14, bottom: 16, child: riskLegend()),
                Positioned(
                  right: 14,
                  bottom: 18,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'map_ai',
                        backgroundColor: Colors.white,
                        foregroundColor: navy,
                        onPressed: () => Navigator.push(context, jsRoute(const RiskAnalysisPage())),
                        child: const Icon(Icons.psychology_alt_rounded),
                      ),
                      const SizedBox(height: 9),
                      FloatingActionButton.small(
                        heroTag: 'map_route',
                        backgroundColor: Colors.white,
                        foregroundColor: navy,
                        onPressed: () => Navigator.push(context, jsRoute(const SafeRoutePage())),
                        child: const Icon(Icons.route_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapToggle(String text, bool active, VoidCallback action) {
    return Material(
      color: active ? navy : const Color(0xFFE6EDF0),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: action,
        child: SizedBox(
          height: 39,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget riskLegend() {
    return surface(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LegendLine(red, 'Critical risk'),
          LegendLine(orange, 'High risk'),
          LegendLine(Color(0xFFFFD33A), 'Moderate'),
          LegendLine(green, 'Low risk'),
        ],
      ),
      padding: const EdgeInsets.all(11),
    );
  }
}

class LegendLine extends StatelessWidget {
  final Color color;
  final String text;
  const LegendLine(this.color, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          CircleAvatar(radius: 4.5, backgroundColor: color),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  String emergency = 'Landslide / trapped';
  int people = 2;
  bool medical = false;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  void sendEmergency() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: green, size: 46),
        title: const Text(
          'Emergency request sent',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Your demo location and emergency details were shared with the nearest response unit. Dispatch ETA: 11 min.',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.4),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Track response'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 25),
        children: [
          const Center(
            child: Text('SOS Emergency', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          Center(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => GestureDetector(
                onLongPress: sendEmergency,
                child: Container(
                  width: 188 + pulse.value * 14,
                  height: 188 + pulse.value * 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: red.withValues(alpha: .11),
                    boxShadow: [
                      BoxShadow(
                        color: red.withValues(alpha: .18),
                        blurRadius: 34,
                        spreadRadius: 7,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFFFF5267), red]),
                    ),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SOS', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
                        Text('Press and Hold', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          const Center(
            child: Text(
              'Your location, selected details and last known risk zone\nwill be shared with nearby rescue teams.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 10.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.crisis_alert_rounded, color: navy),
                  title: const Text('Type of Emergency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  subtitle: Text(emergency, style: const TextStyle(fontSize: 9.5)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => setState(() {
                    emergency = emergency == 'Landslide / trapped'
                        ? 'Flood / stranded'
                        : 'Landslide / trapped';
                  }),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.groups_rounded, color: navy),
                  title: const Text('Number of People', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  subtitle: Text('$people people', style: const TextStyle(fontSize: 9.5)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => setState(() => people = math.max(1, people - 1)),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      IconButton(
                        onPressed: () => setState(() => people++),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.medical_services_outlined, color: navy),
                  title: const Text('Medical Assistance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  subtitle: const Text('Mark as medical priority', style: TextStyle(fontSize: 9.5)),
                  value: medical,
                  onChanged: (value) => setState(() => medical = value),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.add_a_photo_outlined, color: navy),
                  title: const Text('Photo / Video Evidence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  subtitle: const Text('Prototype device attachment flow', style: TextStyle(fontSize: 9.5)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera attachment flow opened for prototype')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: red),
              onPressed: sendEmergency,
              child: const Text('Send Emergency Request', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: bg,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const Row(
              children: [
                Text('Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                Spacer(),
                Text('3 active', style: TextStyle(color: red, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 15),
            alertCard(context, Icons.warning_rounded, red, 'CRITICAL', 'High Landslide Risk', 'Sindhupalchok · active now', const EarlyWarningPage()),
            const SizedBox(height: 10),
            alertCard(context, Icons.cloudy_snowing, blue, 'WEATHER', 'Heavy Rainfall Expected', 'Next 6 hours · 126 mm / 24h', const RiskAnalysisPage()),
            const SizedBox(height: 10),
            alertCard(context, Icons.route_rounded, orange, 'MOBILITY', 'Road Closure', 'Araniko Highway · partial blockage', const SafeRoutePage()),
            const SizedBox(height: 19),
            sectionTitle('Alert intelligence', 'Prioritised by severity and proximity'),
            const SizedBox(height: 10),
            surface(
              const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: green),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Active warnings combine sensor, weather and community evidence.',
                          style: TextStyle(fontSize: 10.5, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  LinearProgressIndicator(
                    value: .92,
                    minHeight: 7,
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    color: green,
                    backgroundColor: Color(0xFFE6F6F0),
                  ),
                  SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Verification confidence 92%',
                      style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget alertCard(
    BuildContext context,
    IconData icon,
    Color color,
    String tag,
    String title,
    String subtitle,
    Widget page,
  ) {
    return TapSurface(
      onTap: () => Navigator.push(context, jsRoute(page)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tag, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final UserRole role;
  const MorePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: bg,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            surface(
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: role.color.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(role.icon, color: role.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        const Text('JeevanSetu SIH demo profile', style: TextStyle(color: Colors.black45, fontSize: 9.5)),
                      ],
                    ),
                  ),
                  const Text('ONLINE', style: TextStyle(color: green, fontSize: 8.5, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 11),
            moreItem(context, Icons.family_restroom_rounded, 'Personal Safety', 'Family live status & check-in', const PersonalSafetyPage()),
            moreItem(context, Icons.sensors_rounded, 'Sensor Network', 'Rain gauges, soil & slope telemetry', const SensorNetworkPage()),
            moreItem(context, Icons.inventory_2_outlined, 'Relief & Resources', 'Camps, hospitals and supplies', const ResourcesPage()),
            moreItem(context, Icons.smart_toy_outlined, 'AI Assistant', 'Ask safety and response questions', const AssistantPage()),
            moreItem(context, Icons.download_for_offline_outlined, 'Offline Readiness', 'Emergency pack cached for demo', const OfflinePage()),
            moreItem(context, Icons.shield_outlined, 'Safety Guidelines', 'Landslide survival checklist', const GuidelinesPage()),
            moreItem(context, Icons.contact_emergency_outlined, 'Emergency Contacts', 'Response numbers & command links', const ContactsPage()),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                jsRoute(const RolePickerPage()),
                (_) => false,
              ),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Switch profession / role'),
            ),
          ],
        ),
      ),
    );
  }

  Widget moreItem(BuildContext context, IconData icon, String title, String subtitle, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TapSurface(
        onTap: () => Navigator.push(context, jsRoute(page)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Text(subtitle, style: const TextStyle(fontSize: 9.3, color: Colors.black45)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class RiskAnalysisPage extends StatefulWidget {
  const RiskAnalysisPage({super.key});

  @override
  State<RiskAnalysisPage> createState() => _RiskAnalysisPageState();
}

class _RiskAnalysisPageState extends State<RiskAnalysisPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('AI Risk Analysis'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          const Row(
            children: [
              Expanded(child: Segment('Current', true)),
              SizedBox(width: 8),
              Expanded(child: Segment('Next 48 Hours', false)),
            ],
          ),
          const SizedBox(height: 12),
          surface(
            const Row(
              children: [
                Icon(Icons.location_on_outlined, size: 19),
                SizedBox(width: 8),
                Text('Sindhupalchok, Nepal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          surface(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Landslide Risk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Spacer(),
                    Text('AI confidence 92%', style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      final value = .78 * Curves.easeOutCubic.transform(controller.value);
                      return SizedBox(
                        width: 150,
                        height: 150,
                        child: CustomPaint(
                          painter: GaugePainter(value),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(78 * controller.value).round()}%',
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                                ),
                                const Text('HIGH RISK', style: TextStyle(color: red, fontSize: 10.5, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Why the AI is concerned', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                const Factor(Icons.water_drop_outlined, blue, 'Rainfall (24h)', '126 mm', .92),
                const Factor(Icons.water_rounded, cyan, 'Soil saturation', '87%', .87),
                const Factor(Icons.change_history_rounded, purple, 'Terrain slope', '38° steep', .79),
                const Factor(Icons.history_rounded, orange, 'Historical activity', 'High', .68),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: orange, size: 19),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI explanation: prolonged rainfall has pushed soil moisture above the local failure threshold on steep slopes.',
                          style: TextStyle(fontSize: 10.3, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.push(context, jsRoute(const SafeRoutePage())),
                    child: const Text('Generate safest evacuation route'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          sectionTitle('48-hour risk trend', 'Prototype nowcast simulation'),
          const SizedBox(height: 9),
          surface(const SizedBox(height: 120, child: CustomPaint(painter: TrendPainter()))),
        ],
      ),
    );
  }
}

class Segment extends StatelessWidget {
  final String text;
  final bool active;
  const Segment(this.text, this.active, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? navy : const Color(0xFFE5ECEF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class Factor extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double contribution;
  const Factor(this.icon, this.color, this.title, this.value, this.contribution, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          SizedBox(width: 105, child: Text(title, style: const TextStyle(fontSize: 10.5))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: contribution,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: .1),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class TrendPainter extends CustomPainter {
  const TrendPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE7EFF2)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        grid,
      );
    }
    final path = ui.Path()
      ..moveTo(0, size.height * .75)
      ..cubicTo(
        size.width * .15,
        size.height * .65,
        size.width * .22,
        size.height * .45,
        size.width * .35,
        size.height * .50,
      )
      ..cubicTo(
        size.width * .48,
        size.height * .55,
        size.width * .58,
        size.height * .20,
        size.width * .72,
        size.height * .28,
      )
      ..cubicTo(
        size.width * .86,
        size.height * .36,
        size.width * .91,
        size.height * .18,
        size.width,
        size.height * .15,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EarlyWarningPage extends StatelessWidget {
  const EarlyWarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Early Warning'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFEC3C59)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('High Risk Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Landslide likely in your area\nwithin the next 12 hours.',
                  style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Issued just now · AI confidence 92%', style: TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 18),
          const WarningInfo(Icons.info_rounded, blue, 'Expected Impact', 'Possible road blockages, slope failure and local power disruption.'),
          const WarningInfo(Icons.directions_walk_rounded, orange, 'Suggested Action', 'Avoid vulnerable slopes and follow the safe evacuation corridor.'),
          const WarningInfo(Icons.location_on_rounded, green, 'Affected Zones', 'Sindhupalchok north-east corridor and nearby settlements.'),
          const WarningInfo(Icons.timer_outlined, purple, 'Critical Window', 'Highest model risk between 21:00 and 03:00.'),
          const SizedBox(height: 15),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: red),
              onPressed: () => Navigator.push(context, jsRoute(const RiskMapPage())),
              child: const Text('View affected zones on live map', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verified alert share action opened')),
            ),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share verified alert'),
          ),
        ],
      ),
    );
  }
}

class WarningInfo extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const WarningInfo(this.icon, this.color, this.title, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(text, style: const TextStyle(fontSize: 10.5, height: 1.35, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SafeRoutePage extends StatefulWidget {
  const SafeRoutePage({super.key});

  @override
  State<SafeRoutePage> createState() => _SafeRoutePageState();
}

class _SafeRoutePageState extends State<SafeRoutePage> {
  bool navigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Safe Route'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: surface(
              const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location_rounded, size: 18, color: navy),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your location', style: TextStyle(fontSize: 9, color: Colors.black45)),
                            Text('Sindhupalchok risk corridor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 18, color: navy),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destination', style: TextStyle(fontSize: 9, color: Colors.black45)),
                            Text('Nearest verified safe shelter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(27.78, 85.48),
                    initialZoom: 11.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sih.jeevansetu',
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: const [
                            LatLng(27.76, 85.42),
                            LatLng(27.80, 85.48),
                            LatLng(27.78, 85.54),
                            LatLng(27.73, 85.50),
                          ],
                          color: red.withValues(alpha: .18),
                          borderColor: red,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: const [
                            LatLng(27.742, 85.435),
                            LatLng(27.755, 85.455),
                            LatLng(27.765, 85.482),
                            LatLng(27.785, 85.505),
                            LatLng(27.802, 85.528),
                          ],
                          strokeWidth: 6,
                          color: cyan,
                          borderColor: Colors.white,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(27.742, 85.435),
                          width: 45,
                          height: 45,
                          child: Icon(Icons.location_on_rounded, color: red, size: 40),
                        ),
                        Marker(
                          point: LatLng(27.802, 85.528),
                          width: 45,
                          height: 45,
                          child: Icon(Icons.location_on_rounded, color: green, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Text(
                      '✓ SAFEST ROUTE\n6.8 km · 18 min',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: SizedBox(
                    height: 53,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: navigating ? green : cyan),
                      onPressed: () => setState(() => navigating = !navigating),
                      child: Text(
                        navigating ? 'Navigation active · ETA 18 min' : 'Start Navigation',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  String type = 'Landslide';
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Report Incident'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          const Row(
            children: [
              Expanded(child: Segment('Photo', true)),
              SizedBox(width: 8),
              Expanded(child: Segment('Video', false)),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: AspectRatio(
              aspectRatio: 1.72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ReferencePhoto(4),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 17),
                        SizedBox(width: 6),
                        Text(
                          'AI visual check: possible slope debris',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
          surface(
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: navy, size: 19),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location · auto-detected', style: TextStyle(fontSize: 9, color: Colors.black45)),
                      Text('Sindhupalchok, Nepal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Incident Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: ['Landslide', 'Flood', 'Road Block', 'Infrastructure']
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: type == item,
                    onSelected: (_) => setState(() => type = item),
                    selectedColor: const Color(0xFFDDF5F8),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe what you see (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () {
                setState(() => submitted = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$type report submitted for verification')),
                );
              },
              child: Text(
                submitted ? 'Report submitted ✓' : 'Submit Verified Report',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityReportsPage extends StatelessWidget {
  const CommunityReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Community Reports'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context, jsRoute(const ReportIncidentPage())),
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: const [
          Row(
            children: [
              Expanded(child: Segment('Nearby', true)),
              SizedBox(width: 8),
              Expanded(child: Segment('All Nepal', false)),
            ],
          ),
          SizedBox(height: 12),
          ReportTile('Landslide', 'Sindhupalchok · 2.4 km', 'AI VERIFIED · 92%', red),
          ReportTile('Road Block', 'Araniko Highway · 4.1 km', 'VERIFIED · 3 REPORTS', orange),
          ReportTile('Flash Flood', 'Melamchi · 8.7 km', 'UNDER REVIEW', blue),
          ReportTile('Bridge Damage', '12.2 km away', 'AUTHORITY CHECK', purple),
        ],
      ),
    );
  }
}

class ReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  const ReportTile(this.title, this.subtitle, this.badge, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: surface(
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.landscape_rounded, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
                  const SizedBox(height: 4),
                  Text(badge, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Relief & Resources'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          const Row(
            children: [
              Expanded(child: Segment('Relief Camps', true)),
              SizedBox(width: 8),
              Expanded(child: Segment('Essential Services', false)),
            ],
          ),
          const SizedBox(height: 12),
          resource(context, Icons.home_work_rounded, 'Melamchi Community Hall', '2.1 km · 250 capacity', ['Food', 'Water', 'Medical']),
          resource(context, Icons.school_rounded, 'Shree Secondary Shelter', '4.8 km · 180 capacity', ['Food', 'Medical']),
          resource(context, Icons.temple_buddhist_rounded, 'Monastery Relief Camp', '6.3 km · 300 capacity', ['Food', 'Water', 'Power']),
          resource(context, Icons.local_hospital_rounded, 'District Hospital', '7.5 km · 24×7 emergency', ['Medical', 'Ambulance']),
        ],
      ),
    );
  }

  Widget resource(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<String> tags,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: TapSurface(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (sheetContext) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(subtitle),
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(
                      value: .76,
                      minHeight: 8,
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      color: green,
                      backgroundColor: Color(0xFFE3F5EE),
                    ),
                    const SizedBox(height: 6),
                    const Text('76% capacity available · verified 8 min ago', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(context, jsRoute(const SafeRoutePage()));
                        },
                        child: const Text('Navigate to this safe hub'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: green.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: green),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: blue.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(tag, style: const TextStyle(color: blue, fontSize: 8, fontWeight: FontWeight.w800)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final input = TextEditingController();
  final List<(bool, String)> messages = [
    (false, 'Namaste. I can explain risk, find safe routes, locate relief camps and guide emergency actions.'),
  ];

  String answer(String question) {
    final q = question.toLowerCase();
    if (q.contains('route')) {
      return 'The safest demo corridor avoids the red zone and reaches the verified shelter in about 18 minutes.';
    }
    if (q.contains('risk')) {
      return 'Current simulated risk is 78% High. Strongest drivers: 126 mm rainfall, 87% soil saturation and steep terrain.';
    }
    if (q.contains('camp') || q.contains('shelter')) {
      return 'Melamchi Community Hall is the nearest verified demo hub: 2.1 km, with food, water and medical support.';
    }
    return 'I can guide the prototype workflow and direct you to the relevant safety screen. Real deployment answers would be backed by verified model/API data.';
  }

  void send([String? preset]) {
    final question = (preset ?? input.text).trim();
    if (question.isEmpty) return;
    setState(() {
      messages.add((true, question));
      messages.add((false, answer(question)));
    });
    input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('AI Safety Assistant'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: blue, size: 58),
                      SizedBox(height: 6),
                      Text('JeevanSetu Copilot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('Context-aware disaster guidance', style: TextStyle(fontSize: 9.5, color: Colors.black45)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['Current risk?', 'Show safe route', 'Nearest shelter', 'What should I do?']
                      .map(
                        (text) => ActionChip(
                          label: Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                          onPressed: () => send(text),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 13),
                ...messages.map(
                  (message) => Align(
                    alignment: message.$1 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 310),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: message.$1 ? navy : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: message.$1 ? null : Border.all(color: const Color(0xFFE7EFF2)),
                      ),
                      child: Text(
                        message.$2,
                        style: TextStyle(
                          color: message.$1 ? Colors.white : ink,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: input,
                onSubmitted: (_) => send(),
                decoration: InputDecoration(
                  hintText: 'Ask a safety question…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => send(),
                    icon: const Icon(Icons.send_rounded, color: cyan),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalSafetyPage extends StatefulWidget {
  const PersonalSafetyPage({super.key});

  @override
  State<PersonalSafetyPage> createState() => _PersonalSafetyPageState();
}

class _PersonalSafetyPageState extends State<PersonalSafetyPage> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Personal Safety'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [navy, Color(0xFF0A6578)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: aqua, size: 38),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('You are in a monitored zone', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                      Text(
                        checked ? 'Check-in sent just now' : 'Last safety check-in 22 min ago',
                        style: const TextStyle(color: Colors.white60, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => setState(() => checked = true),
                  child: Text(checked ? 'Sent ✓' : 'Check in'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const FamilyTile('You', 'Safe · live location', green),
          const FamilyTile('Mother', 'Safe · 2 min ago', green),
          const FamilyTile('Father', 'Safe · 18 min ago', green),
          const FamilyTile('Sister', 'Awaiting check-in', orange),
        ],
      ),
    );
  }
}

class FamilyTile extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  const FamilyTile(this.name, this.status, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: surface(
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(Icons.person_rounded, color: color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                  Text(status, style: TextStyle(color: color, fontSize: 9.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class SensorNetworkPage extends StatelessWidget {
  const SensorNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Sensor Network'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: const [
          OpsHero(blue, '26/28', 'Sensors online', '14 sec', 'Last sync', '96%', 'Mesh health'),
          SizedBox(height: 12),
          SensorTile(Icons.water_drop_outlined, 'Rain Gauge SG-04', '18.4 mm/hr · Rising', blue, .82),
          SensorTile(Icons.water_rounded, 'Soil Probe SM-12', '87% saturation · Critical', red, .87),
          SensorTile(Icons.straighten_rounded, 'Slope Node IN-07', '2.8 mm movement · Watch', orange, .62),
          SensorTile(Icons.cloud_outlined, 'Weather Station WX-03', 'Pressure falling · Active', green, .48),
        ],
      ),
    );
  }
}

class SensorTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final double value;
  const SensorTile(this.icon, this.title, this.subtitle, this.color, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: surface(
        Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: color.withValues(alpha: .1),
            ),
          ],
        ),
      ),
    );
  }
}

class RescueCommandPage extends StatelessWidget {
  const RescueCommandPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const OperationsPage(
      title: 'Rescue Command',
      color: red,
      stats: [('11', 'Responders'), ('3', 'Active missions'), ('2', 'Medical teams')],
      missions: [
        ('MISSION JS-104', 'Landslide · 4 persons trapped', 'ETA 11 min · Team Alpha', red),
        ('MISSION JS-103', 'Road blockage · elderly evac', 'ETA 18 min · Team Bravo', orange),
        ('MISSION JS-101', 'Shelter transfer · 12 persons', 'On scene · Medical-2', green),
      ],
    );
  }
}

class AuthorityCenterPage extends StatelessWidget {
  const AuthorityCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const OperationsPage(
      title: 'Authority Command Center',
      color: blue,
      stats: [('4', 'High-risk zones'), ('18', 'Safe hubs'), ('92%', 'Alert confidence')],
      missions: [
        ('ALERT #NW-27', 'Sindhupalchok high-risk corridor', 'Ready to broadcast · 92% verified', red),
        ('ROAD #A12', 'Araniko Highway partial closure', 'Diversion active · authority verified', orange),
      ],
    );
  }
}

class VolunteerOpsPage extends StatelessWidget {
  const VolunteerOpsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const OperationsPage(
      title: 'Volunteer Operations',
      color: purple,
      stats: [('18', 'Online'), ('2', 'Nearby tasks'), ('46', 'Families checked')],
      missions: [
        ('TASK V-21', 'Pack water + first aid', '1.2 km · 8 volunteers needed', purple),
        ('TASK V-19', 'Shelter registration support', '2.0 km · 4 volunteers needed', green),
      ],
    );
  }
}

class OrganizationOpsPage extends StatelessWidget {
  const OrganizationOpsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const OperationsPage(
      title: 'Resource Command',
      color: orange,
      stats: [('4', 'Facilities'), ('730', 'Beds'), ('81%', 'Stock ready')],
      missions: [
        ('INVENTORY', 'Water packs', '1,260 units · 81% ready', blue),
        ('MEDICAL', 'Trauma kits', '87 kits · 92% ready', red),
        ('POWER', 'Portable generators', '12 units · 9 available', green),
      ],
    );
  }
}

class OperationsPage extends StatelessWidget {
  final String title;
  final Color color;
  final List<(String, String)> stats;
  final List<(String, String, String, Color)> missions;
  const OperationsPage({
    super.key,
    required this.title,
    required this.color,
    required this.stats,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar(title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          OpsHero(
            color,
            stats[0].$1,
            stats[0].$2,
            stats[1].$1,
            stats[1].$2,
            stats[2].$1,
            stats[2].$2,
          ),
          const SizedBox(height: 12),
          ...missions.map(
            (m) => MissionTile(m.$1, m.$2, m.$3, m.$4),
          ),
        ],
      ),
    );
  }
}

class OpsHero extends StatelessWidget {
  final Color color;
  final String a;
  final String at;
  final String b;
  final String bt;
  final String c;
  final String ct;
  const OpsHero(this.color, this.a, this.at, this.b, this.bt, this.c, this.ct, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [navy, Color.lerp(navy, color, .48)!]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: stat(a, at)),
          Container(width: 1, height: 44, color: Colors.white24),
          Expanded(child: stat(b, bt)),
          Container(width: 1, height: 44, color: Colors.white24),
          Expanded(child: stat(c, ct)),
        ],
      ),
    );
  }

  Widget stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 8.5)),
      ],
    );
  }
}

class MissionTile extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final Color color;
  const MissionTile(this.id, this.title, this.status, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: TapSurface(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$id opened in command workflow')),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.my_location_rounded, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  Text(status, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Offline Readiness'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          OfflineHero(),
          SizedBox(height: 12),
          OfflineTile(Icons.map_outlined, 'Risk snapshot', 'Updated 3 min ago'),
          OfflineTile(Icons.shield_outlined, 'Safety guidelines', 'Available offline'),
          OfflineTile(Icons.contact_emergency_outlined, 'Emergency contacts', 'Available offline'),
        ],
      ),
    );
  }
}

class OfflineHero extends StatelessWidget {
  const OfflineHero({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [navy, Color(0xFF0A6578)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.offline_bolt_rounded, color: aqua, size: 45),
          SizedBox(height: 9),
          Text('Emergency pack ready offline', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text(
            'Safety guides, contacts and the last known risk snapshot are cached for the prototype.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 10.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class OfflineTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const OfflineTile(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: surface(
        Row(
          children: [
            Icon(icon, color: green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45)),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded, color: green),
          ],
        ),
      ),
    );
  }
}

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Safety Guidelines'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          GuideTile('1', 'Move away from steep slopes', 'Do not wait directly below a visibly unstable slope or drainage channel.', red),
          GuideTile('2', 'Follow verified evacuation routes', 'Avoid shortcuts through red zones even when they appear faster.', orange),
          GuideTile('3', 'Keep an emergency go-bag', 'Carry water, medicines, light, power bank and identity documents.', blue),
          GuideTile('4', 'Check in with family', 'Use Personal Safety so responders know who is safe and who needs help.', green),
        ],
      ),
    );
  }
}

class GuideTile extends StatelessWidget {
  final String number;
  final String title;
  final String text;
  final Color color;
  const GuideTile(this.number, this.title, this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: surface(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Text(number, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(text, style: const TextStyle(fontSize: 10.5, height: 1.35, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: jsAppBar('Emergency Contacts'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ContactTile('National Emergency Demo', '112', red),
          ContactTile('District Response Desk', '1077', blue),
          ContactTile('Nearest Medical Team', 'Available', green),
          ContactTile('JeevanSetu Command', 'In-app radio', purple),
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const ContactTile(this.title, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: TapSurface(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact action opened: $title')),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .1),
              child: Icon(Icons.phone_in_talk_rounded, color: color),
            ),
            const SizedBox(width: 11),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900))),
            Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
