import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const navy = Color(0xFF073C4D);
const deepNavy = Color(0xFF032833);
const cyan = Color(0xFF16BED3);
const aqua = Color(0xFF52E0E7);
const blue = Color(0xFF4285F4);
const red = Color(0xFFFF3B55);
const green = Color(0xFF20C98A);
const orange = Color(0xFFFFA52F);
const purple = Color(0xFF7657DD);
const bg = Color(0xFFF2F8FA);
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
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          primary: cyan,
          secondary: blue,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: bg,
          surfaceTintColor: bg,
          foregroundColor: ink,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDDF6F9),
          labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
                fontSize: 11,
                fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
                color: s.contains(WidgetState.selected) ? navy : const Color(0xFF66757A),
              )),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

Route<T> jsRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 460),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: page,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween(begin: const Offset(.045, .015), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final scale = Tween(begin: .985, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return SlideTransition(position: slide, child: ScaleTransition(scale: scale, child: child));
      },
    );

class ReferenceAtlas {
  static Future<Uint8List>? _future;
  static Future<Uint8List> get bytes => _future ??= rootBundle
      .loadString('assets/reference_atlas.b64')
      .then((value) => base64Decode(value.trim()));
}

/// Uses the exact photo material extracted from the UI board supplied by the user.
/// The atlas contains: splash mountain, monitoring mountain, aerial risk map,
/// helicopter rescue scene and incident photo.
class ReferencePhoto extends StatelessWidget {
  final int index;
  final BoxFit fit;
  final Alignment? alignment;
  const ReferencePhoto(this.index, {super.key, this.fit = BoxFit.cover, this.alignment});

  @override
  Widget build(BuildContext context) {
    final y = -1.0 + (index.clamp(0, 4) * .5);
    return FutureBuilder<Uint8List>(
      future: ReferenceAtlas.bytes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2C7E99), Color(0xFF063B4C)],
              ),
            ),
          );
        }
        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          height: double.infinity,
          fit: fit,
          alignment: alignment ?? Alignment(0, y),
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
  const LogoMark({super.key, this.size = 78, this.color = Colors.white});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * .7,
        child: CustomPaint(painter: _LogoPainter(color)),
      );
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .12
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final path = Path()
      ..moveTo(s.width * .08, s.height * .86)
      ..lineTo(s.width * .43, s.height * .16)
      ..lineTo(s.width * .70, s.height * .64)
      ..lineTo(s.width * .92, s.height * .40);
    canvas.drawPath(path, p);
    canvas.drawLine(
      Offset(s.width * .38, s.height * .64),
      Offset(s.width * .69, s.height * .64),
      Paint()
        ..color = color.withOpacity(.75)
        ..strokeWidth = s.width * .065
        ..strokeCap = StrokeCap.round,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CinematicPhoto extends StatefulWidget {
  final int photo;
  final Widget child;
  final double darkness;
  const CinematicPhoto({super.key, required this.photo, required this.child, this.darkness = .35});

  @override
  State<CinematicPhoto> createState() => _CinematicPhotoState();
}

class _CinematicPhotoState extends State<CinematicPhoto> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 11))..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(scale: 1.03 + controller.value * .035, child: ReferencePhoto(widget.photo)),
            Container(color: Colors.black.withOpacity(widget.darkness)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    deepNavy.withOpacity(.10),
                    deepNavy.withOpacity(.92),
                  ],
                  stops: const [.1, .48, 1],
                ),
              ),
            ),
            Positioned(
              top: 100 + math.sin(controller.value * math.pi * 2) * 10,
              left: -70,
              right: -70,
              height: 130,
              child: IgnorePointer(child: CustomPaint(painter: _MistPainter(controller.value))),
            ),
            widget.child,
          ],
        ),
      );
}

class _MistPainter extends CustomPainter {
  final double t;
  _MistPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(.06);
    for (int i = 0; i < 7; i++) {
      final x = ((i * 121.0) + (t * size.width * .2)) % (size.width + 160) - 80;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 30 + (i % 3) * 32), width: 170, height: 36), p);
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

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController loading;
  @override
  void initState() {
    super.initState();
    loading = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..repeat();
    Timer(const Duration(milliseconds: 2350), () {
      if (mounted) Navigator.pushReplacement(context, jsRoute(const OnboardingPage()));
    });
  }

  @override
  void dispose() {
    loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: deepNavy,
        body: CinematicPhoto(
          photo: 0,
          darkness: .28,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  const LogoMark(size: 94),
                  const SizedBox(height: 14),
                  const Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                  const SizedBox(height: 5),
                  const Text('Disaster Monitoring & Response', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(color: cyan.withOpacity(.18), border: Border.all(color: cyan.withOpacity(.35)), borderRadius: BorderRadius.circular(99)),
                    child: const Text('SIH 2026 · PS26001', style: TextStyle(color: aqua, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  ),
                  const Spacer(flex: 5),
                  const Text('Initializing Nepal Risk Intelligence', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: loading,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: loading.value,
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

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int page = 0;
  final slides = const [
    ('Safer Communities\nwith Smarter Monitoring', 'AI-powered landslide and flood risk analysis for early warning and faster response.', 1),
    ('Real-Time Risk\nInsights', 'Live maps, explainable AI analysis, weather intelligence and verified community alerts.', 2),
    ('Report · Respond\n· Stay Safe', 'A unified platform for citizens, rescue teams, authorities, volunteers and organisations.', 3),
  ];

  void next() {
    if (page < 2) {
      controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    } else {
      Navigator.push(context, jsRoute(const RolePickerPage()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: deepNavy,
        body: PageView.builder(
          controller: controller,
          itemCount: slides.length,
          onPageChanged: (v) => setState(() => page = v),
          itemBuilder: (_, i) {
            final s = slides[i];
            return CinematicPhoto(
              photo: s.$3,
              darkness: .20,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(s.$1, style: const TextStyle(color: Colors.white, fontSize: 31, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.6)),
                      const SizedBox(height: 17),
                      Text(s.$2, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Text('${i + 1} / 3', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 14),
                          ...List.generate(3, (n) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(right: 5),
                                width: n == i ? 24 : 6,
                                height: 6,
                                decoration: BoxDecoration(color: n == i ? aqua : Colors.white30, borderRadius: BorderRadius.circular(9)),
                              )),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.push(context, jsRoute(const RolePickerPage())),
                            child: const Text('Skip', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          FloatingActionButton.small(
                            heroTag: 'intro_$i',
                            elevation: 0,
                            backgroundColor: aqua,
                            onPressed: next,
                            child: Icon(i == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded, color: navy),
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

enum UserRole { citizen, rescue, authority, volunteer, organization }

extension RoleInfo on UserRole {
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: deepNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ReferencePhoto(0),
            Container(color: deepNavy.withOpacity(.84)),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
                children: [
                  Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
                  const SizedBox(height: 5),
                  const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.4)),
                  const SizedBox(height: 3),
                  const Text('Select your role to open a purpose-built command experience.', style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.35)),
                  const SizedBox(height: 22),
                  ...UserRole.values.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.push(context, jsRoute(LoginPage(role: r))),
                            child: Ink(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [r.color.withOpacity(.98), r.color.withOpacity(.72)]),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(color: r.color.withOpacity(.2), blurRadius: 22, offset: const Offset(0, 10))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(15)),
                                    child: Icon(r.icon, color: r.color, size: 27),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                                        const SizedBox(height: 3),
                                        Text(r.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.25)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
}

class LoginPage extends StatelessWidget {
  final UserRole role;
  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: deepNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ReferencePhoto(0),
            Container(color: deepNavy.withOpacity(.88)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          LogoMark(size: 76, color: role.color == red ? aqua : Colors.white),
                          const SizedBox(height: 7),
                          const Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 31),
                    Row(
                      children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: role.color.withOpacity(.22), borderRadius: BorderRadius.circular(10)), child: Icon(role.icon, color: role.color, size: 20)),
                        const SizedBox(width: 10),
                        Text('${role.title} access', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.5)),
                    const Text('Sign in to continue', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 23),
                    const _GlassField(icon: Icons.person_outline_rounded, hint: 'Email or Phone'),
                    const SizedBox(height: 11),
                    const _GlassField(icon: Icons.lock_outline_rounded, hint: 'Password', obscure: true),
                    const SizedBox(height: 8),
                    const Align(alignment: Alignment.centerRight, child: Text('Forgot Password?', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: role.color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () => Navigator.pushAndRemoveUntil(context, jsRoute(AppShell(role: role)), (_) => false),
                        child: Text('Sign in as ${role.title}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 13)),
                        onPressed: () => Navigator.pushAndRemoveUntil(context, jsRoute(AppShell(role: role)), (_) => false),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                        label: const Text('Use SIH demo access', style: TextStyle(fontWeight: FontWeight.w700)),
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

class _GlassField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  const _GlassField({required this.icon, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white60),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(.09),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: aqua)),
        ),
      );
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
    final screens = [RoleHome(role: widget.role), const RiskMapPage(), const SosPage(), const AlertsPage(), MorePage(role: widget.role)];
    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.sos_outlined), selectedIcon: Icon(Icons.sos_rounded), label: 'SOS'),
          NavigationDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded), label: 'More'),
        ],
      ),
    );
  }
}

Widget surface(Widget child, {EdgeInsets padding = const EdgeInsets.all(14), Color color = Colors.white}) => Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9F1F3)),
        boxShadow: [BoxShadow(color: navy.withOpacity(.055), blurRadius: 22, offset: const Offset(0, 9))],
      ),
      child: child,
    );

class TapSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets padding;
  const TapSurface({super.key, required this.child, required this.onTap, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8F0F2))),
            child: child,
          ),
        ),
      );
}

class RoleHome extends StatelessWidget {
  final UserRole role;
  const RoleHome({super.key, required this.role});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Hero(role: role)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              sliver: SliverList.list(
                children: [
                  _CriticalBanner(onTap: () => Navigator.push(context, jsRoute(const EarlyWarningPage()))),
                  const SizedBox(height: 13),
                  const _NowCastStrip(),
                  const SizedBox(height: 19),
                  _sectionTitle('Safety tools', 'Live, actionable, one tap away'),
                  const SizedBox(height: 10),
                  _QuickGrid(role: role),
                  const SizedBox(height: 20),
                  _RoleMissionCard(role: role),
                  const SizedBox(height: 20),
                  _sectionTitle('AI Slope Sentinel', 'Explainable risk, not a black box'),
                  const SizedBox(height: 10),
                  TapSurface(
                    onTap: () => Navigator.push(context, jsRoute(const RiskAnalysisPage())),
                    child: const Row(
                      children: [
                        _MiniGauge(value: .78),
                        SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('High landslide probability', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          SizedBox(height: 5),
                          Text('Rainfall + soil saturation + slope geometry are driving the risk.', style: TextStyle(color: Colors.black54, height: 1.35, fontSize: 11)),
                          SizedBox(height: 9),
                          Text('WHY THIS SCORE  →', style: TextStyle(color: blue, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: .7)),
                        ])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Community pulse', 'Verified signals around you'),
                  const SizedBox(height: 10),
                  TapSurface(
                    onTap: () => Navigator.push(context, jsRoute(const CommunityReportsPage())),
                    child: const Column(
                      children: [
                        _PulseRow(icon: Icons.landscape_rounded, color: red, title: 'Slope movement reported', meta: 'Sindhupalchok · 2.4 km · AI verified', badge: '92% confidence'),
                        Divider(height: 25),
                        _PulseRow(icon: Icons.route_rounded, color: orange, title: 'Road partially blocked', meta: 'Araniko Highway · 4.1 km', badge: '3 reports'),
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

class _Hero extends StatelessWidget {
  final UserRole role;
  const _Hero({required this.role});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 285,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ReferencePhoto(0),
            DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [deepNavy.withOpacity(.28), deepNavy.withOpacity(.9)]))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(gradient: LinearGradient(colors: [role.color, role.color.withOpacity(.65)]), borderRadius: BorderRadius.circular(13)), child: Icon(role.icon, color: Colors.white)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Namaste,', style: TextStyle(color: Colors.white70, fontSize: 11)), Text(role.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))])),
                      Container(width: 41, height: 41, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white24)), child: const Icon(Icons.notifications_active_rounded, color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  const Text('NEPAL RISK INTELLIGENCE', style: TextStyle(color: aqua, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.25)),
                  const SizedBox(height: 5),
                  const Text('Know the slope\nbefore it moves.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.0, fontWeight: FontWeight.w900, letterSpacing: -.45)),
                  const SizedBox(height: 15),
                  const Row(children: [Expanded(child: _HeroStat(k: 'RISK', v: '78%', color: red)), SizedBox(width: 7), Expanded(child: _HeroStat(k: '24H RAIN', v: '126 mm', color: blue)), SizedBox(width: 7), Expanded(child: _HeroStat(k: 'SAFE HUBS', v: '18', color: green))]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HeroStat extends StatelessWidget {
  final String k, v;
  final Color color;
  const _HeroStat({required this.k, required this.v, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.11), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.14))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: .6)), const SizedBox(height: 2), Text(v, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900))]),
      );
}

class _CriticalBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _CriticalBanner({required this.onTap});
  @override
  State<_CriticalBanner> createState() => _CriticalBannerState();
}

class _CriticalBannerState extends State<_CriticalBanner> with SingleTickerProviderStateMixin {
  late final AnimationController c;
  @override
  void initState() { super.initState(); c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true); }
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFF05562)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: red.withOpacity(.23), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(animation: c, builder: (_, __) => Transform.scale(scale: .94 + c.value * .1, child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.16), shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 27)))),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)), SizedBox(height: 5), Text('Potential slope failure within the next 12 hours. Safer route is ready.', style: TextStyle(color: Colors.white, fontSize: 11.5, height: 1.35)), SizedBox(height: 9), Text('OPEN EARLY WARNING  →', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .45))])),
              ],
            ),
          ),
        ),
      );
}

class _NowCastStrip extends StatelessWidget {
  const _NowCastStrip();
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: surface(const Row(children: [Icon(Icons.cloudy_snowing, color: blue, size: 28), SizedBox(width: 9), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('12°C', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text('Heavy rain', style: TextStyle(fontSize: 10, color: Colors.black54))])]), padding: const EdgeInsets.all(12))),
        const SizedBox(width: 9),
        Expanded(child: surface(const Row(children: [Icon(Icons.water_drop_rounded, color: cyan, size: 27), SizedBox(width: 9), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('87%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text('Soil saturation', style: TextStyle(fontSize: 10, color: Colors.black54))])]), padding: const EdgeInsets.all(12))),
      ]);
}

Widget _sectionTitle(String title, String subtitle) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -.2)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 10.5))]))]);

class _QuickGrid extends StatelessWidget {
  final UserRole role;
  const _QuickGrid({required this.role});
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.map_rounded, 'Live Risk\nMap', green, const RiskMapPage()),
      (Icons.route_rounded, 'Safe\nRoute', cyan, const SafeRoutePage()),
      (Icons.psychology_alt_rounded, 'AI Risk\nAnalysis', blue, const RiskAnalysisPage()),
      (Icons.post_add_rounded, 'Report\nIncident', orange, const ReportIncidentPage()),
      (Icons.inventory_2_rounded, 'Relief &\nResources', green, const ResourcesPage()),
      (Icons.smart_toy_rounded, 'AI Safety\nAssistant', purple, const AssistantPage()),
    ];
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.05),
      itemBuilder: (_, i) {
        final a = actions[i];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(context, jsRoute(a.$4)),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8F0F2))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: a.$3.withOpacity(.11), borderRadius: BorderRadius.circular(12)), child: Icon(a.$1, color: a.$3, size: 22)), const SizedBox(height: 7), Text(a.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, height: 1.15, fontWeight: FontWeight.w800))]),
            ),
          ),
        );
      },
    );
  }
}

class _RoleMissionCard extends StatelessWidget {
  final UserRole role;
  const _RoleMissionCard({required this.role});
  @override
  Widget build(BuildContext context) {
    final data = switch (role) {
      UserRole.citizen => ('Personal Safety', '4 family members · 3 safe · 1 awaiting check-in', Icons.family_restroom_rounded, const PersonalSafetyPage()),
      UserRole.rescue => ('Rescue Command', '3 active missions · 11 responders deployed', Icons.emergency_rounded, const RescueCommandPage()),
      UserRole.authority => ('Authority Command Center', '4 high-risk wards · broadcast readiness 96%', Icons.radar_rounded, const AuthorityCenterPage()),
      UserRole.volunteer => ('Volunteer Operations', '2 relief tasks nearby · 18 volunteers online', Icons.volunteer_activism_rounded, const VolunteerOpsPage()),
      UserRole.organization => ('Resource Command', '4 facilities · 730 beds · 81% inventory ready', Icons.inventory_rounded, const OrganizationOpsPage()),
    };
    return TapSurface(
      onTap: () => Navigator.push(context, jsRoute(data.$4)),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [navy, Color.lerp(navy, role.color, .34)!]), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(15)), child: Icon(data.$3, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)), const SizedBox(height: 4), Text(data.$2, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.25))])), const Icon(Icons.arrow_forward_rounded, color: aqua)]),
      ),
    );
  }
}

class _MiniGauge extends StatelessWidget {
  final double value;
  const _MiniGauge({required this.value});
  @override
  Widget build(BuildContext context) => SizedBox(width: 76, height: 76, child: CustomPaint(painter: _GaugePainter(value), child: Center(child: Text('${(value * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))));
}

class _GaugePainter extends CustomPainter {
  final double value;
  _GaugePainter(this.value);
  @override
  void paint(Canvas c, Size s) {
    final rect = Rect.fromLTWH(8, 8, s.width - 16, s.height - 16);
    c.drawArc(rect, -math.pi / 2, math.pi * 2, false, Paint()..color = const Color(0xFFFFE1E6)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
    c.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, Paint()..color = red..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}

class _PulseRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, meta, badge;
  const _PulseRow({required this.icon, required this.color, required this.title, required this.meta, required this.badge});
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.11), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)), const SizedBox(height: 2), Text(meta, style: const TextStyle(color: Colors.black45, fontSize: 9.8))])), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(7)), child: Text(badge, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w800)))]);
}

class RiskMapPage extends StatefulWidget {
  const RiskMapPage({super.key});
  @override
  State<RiskMapPage> createState() => _RiskMapPageState();
}

class _RiskMapPageState extends State<RiskMapPage> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  bool forecast = false;
  @override
  void initState() { super.initState(); pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true); }
  @override
  void dispose() { pulse.dispose(); super.dispose(); }

  void details(String name, int risk) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: red, shape: BoxShape.circle)), const SizedBox(width: 8), Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const Spacer(), Text('$risk%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: red))]),
          const SizedBox(height: 10),
          const Text('AI detects sustained heavy rainfall, elevated soil saturation and steep terrain. Use the recommended evacuation corridor instead of the highlighted red road segment.', style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 12)),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { Navigator.pop(context); Navigator.push(context, jsRoute(const SafeRoutePage())); }, icon: const Icon(Icons.route_rounded), label: const Text('Open safest route'))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 11),
              child: Row(children: [const Text('Risk Map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: green.withOpacity(.1), borderRadius: BorderRadius.circular(99)), child: const Row(children: [CircleAvatar(radius: 3.5, backgroundColor: green), SizedBox(width: 6), Text('LIVE', style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w900))]))]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [Expanded(child: _toggle('Live', !forecast, () => setState(() => forecast = false))), const SizedBox(width: 8), Expanded(child: _toggle('Next 48 Hours', forecast, () => setState(() => forecast = true)))]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(initialCenter: const LatLng(27.70, 85.32), initialZoom: 7.4, minZoom: 5, maxZoom: 17),
                    children: [
                      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sih.jeevansetu'),
                      PolygonLayer(polygons: [
                        Polygon(points: const [LatLng(27.95,85.42),LatLng(27.86,85.78),LatLng(27.64,85.70),LatLng(27.60,85.37),LatLng(27.79,85.24)], color: red.withOpacity(forecast ? .18 : .24), borderColor: red.withOpacity(.8), borderStrokeWidth: 2),
                        Polygon(points: const [LatLng(28.38,83.72),LatLng(28.28,84.04),LatLng(28.04,83.96),LatLng(28.08,83.59)], color: orange.withOpacity(.2), borderColor: orange.withOpacity(.8), borderStrokeWidth: 2),
                      ]),
                      PolylineLayer(polylines: [Polyline(points: const [LatLng(27.7172,85.3240),LatLng(27.76,85.42),LatLng(27.83,85.55)], strokeWidth: 5, color: cyan, borderColor: Colors.white, borderStrokeWidth: 2)]),
                      MarkerLayer(markers: [
                        _riskMarker(const LatLng(27.83,85.55), 'Sindhupalchok', 86, red),
                        _riskMarker(const LatLng(27.7172,85.3240), 'Kathmandu', 64, orange),
                        _riskMarker(const LatLng(28.2096,83.9856), 'Pokhara', 71, orange),
                        _riskMarker(const LatLng(27.5291,84.3542), 'Chitwan', 42, green),
                      ]),
                    ],
                  ),
                  Positioned(left: 14, bottom: 16, child: _legend()),
                  Positioned(right: 14, bottom: 18, child: Column(children: [FloatingActionButton.small(heroTag: 'ai_map', backgroundColor: Colors.white, foregroundColor: navy, onPressed: () => Navigator.push(context, jsRoute(const RiskAnalysisPage())), child: const Icon(Icons.psychology_alt_rounded)), const SizedBox(height: 9), FloatingActionButton.small(heroTag: 'route_map', backgroundColor: Colors.white, foregroundColor: navy, onPressed: () => Navigator.push(context, jsRoute(const SafeRoutePage())), child: const Icon(Icons.route_rounded))])),
                  Positioned(top: 12, right: 12, child: Material(color: Colors.white, borderRadius: BorderRadius.circular(13), elevation: 3, child: InkWell(borderRadius: BorderRadius.circular(13), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location centred on Nepal demo area'))), child: const Padding(padding: EdgeInsets.all(11), child: Icon(Icons.my_location_rounded, color: navy, size: 21))))),
                ],
              ),
            ),
          ],
        ),
      );

  Marker _riskMarker(LatLng p, String name, int risk, Color color) => Marker(
        point: p,
        width: 62,
        height: 62,
        child: GestureDetector(
          onTap: () => details(name, risk),
          child: AnimatedBuilder(
            animation: pulse,
            builder: (_, __) => Stack(alignment: Alignment.center, children: [Container(width: 34 + pulse.value * 12, height: 34 + pulse.value * 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.13))), Icon(Icons.location_on_rounded, color: color, size: 38)]),
          ),
        ),
      );

  Widget _toggle(String text, bool active, VoidCallback tap) => Material(color: active ? navy : const Color(0xFFE5ECEF), borderRadius: BorderRadius.circular(11), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(11), child: SizedBox(height: 39, child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.w800, fontSize: 11))))));
  Widget _legend() => surface(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_LegendDot(red, 'Critical risk'), _LegendDot(orange, 'High risk'), _LegendDot(Color(0xFFFFD43B), 'Moderate'), _LegendDot(green, 'Low risk')]), padding: const EdgeInsets.all(11));
}

class _LegendDot extends StatelessWidget {
  final Color color; final String text; const _LegendDot(this.color, this.text);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [CircleAvatar(radius: 4.5, backgroundColor: color), const SizedBox(width: 7), Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))]));
}

class SosPage extends StatefulWidget {
  const SosPage({super.key});
  @override State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  String emergency = 'Landslide / trapped';
  int people = 2;
  bool medical = false;
  @override void initState() { super.initState(); pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1050))..repeat(reverse: true); }
  @override void dispose() { pulse.dispose(); super.dispose(); }

  void send() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: green, size: 45),
        title: const Text('Emergency request sent', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Your demo location and emergency details have been shared with the nearest response unit. Dispatch ETA: 11 min.', textAlign: TextAlign.center, style: TextStyle(height: 1.4)),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Track response'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 25),
          children: [
            const Center(child: Text('SOS Emergency', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
            const SizedBox(height: 25),
            Center(
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => GestureDetector(
                  onLongPress: send,
                  child: Container(
                    width: 188 + pulse.value * 14,
                    height: 188 + pulse.value * 14,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: red.withOpacity(.11), boxShadow: [BoxShadow(color: red.withOpacity(.18), blurRadius: 35, spreadRadius: 7)]),
                    alignment: Alignment.center,
                    child: Container(width: 140, height: 140, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF5266), red])), alignment: Alignment.center, child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('SOS', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)), Text('Press and Hold', style: TextStyle(color: Colors.white70, fontSize: 10))])),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(child: Text('Location, selected details and last known risk zone\nwill be shared with nearby rescue teams.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 10.5, height: 1.4))),
            const SizedBox(height: 19),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(children: [
                  ListTile(leading: const Icon(Icons.crisis_alert_rounded, color: navy), title: const Text('Type of Emergency', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text(emergency, style: const TextStyle(fontSize: 10)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => setState(() => emergency = emergency == 'Landslide / trapped' ? 'Flood / stranded' : 'Landslide / trapped')),
                  const Divider(height: 1, indent: 56),
                  ListTile(leading: const Icon(Icons.groups_rounded, color: navy), title: const Text('Number of People', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text('$people people', style: const TextStyle(fontSize: 10)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => setState(() => people = math.max(1, people - 1)), icon: const Icon(Icons.remove_circle_outline_rounded)), IconButton(onPressed: () => setState(() => people++), icon: const Icon(Icons.add_circle_outline_rounded))])),
                  const Divider(height: 1, indent: 56),
                  SwitchListTile(secondary: const Icon(Icons.medical_services_outlined, color: navy), title: const Text('Medical Assistance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: const Text('Flag for medical priority', style: TextStyle(fontSize: 10)), value: medical, onChanged: (v) => setState(() => medical = v)),
                  const Divider(height: 1, indent: 56),
                  ListTile(leading: const Icon(Icons.add_a_photo_outlined, color: navy), title: const Text('Photo / Video Evidence', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: const Text('Prototype camera attachment', style: TextStyle(fontSize: 10)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera attachment flow ready for device integration')))),
                ]),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: send, child: const Text('Send Emergency Request', style: TextStyle(fontWeight: FontWeight.w900)))),
          ],
        ),
      );
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const Row(children: [Text('Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Spacer(), Text('3 active', style: TextStyle(color: red, fontWeight: FontWeight.w800, fontSize: 11))]),
            const SizedBox(height: 15),
            _alert(context, Icons.warning_rounded, red, 'Critical', 'High Landslide Risk', 'Sindhupalchok · active now', const EarlyWarningPage()),
            const SizedBox(height: 10),
            _alert(context, Icons.cloudy_snowing, blue, 'Weather', 'Heavy Rainfall Expected', 'Next 6 hours · 126 mm / 24h', const RiskAnalysisPage()),
            const SizedBox(height: 10),
            _alert(context, Icons.route_rounded, orange, 'Mobility', 'Road Closure', 'Araniko Highway · partial blockage', const SafeRoutePage()),
            const SizedBox(height: 20),
            _sectionTitle('Alert intelligence', 'Prioritised by severity and proximity'),
            const SizedBox(height: 10),
            surface(const Column(children: [Row(children: [Icon(Icons.verified_user_rounded, color: green), SizedBox(width: 9), Expanded(child: Text('All active warnings are cross-checked with sensor, weather and community evidence.', style: TextStyle(fontSize: 11, height: 1.35)))]), SizedBox(height: 13), LinearProgressIndicator(value: .92, minHeight: 7, borderRadius: BorderRadius.all(Radius.circular(9)), color: green, backgroundColor: Color(0xFFE6F6F0)), SizedBox(height: 6), Align(alignment: Alignment.centerRight, child: Text('Verification confidence 92%', style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w800)))]),
          ],
        ),
      );

  Widget _alert(BuildContext context, IconData icon, Color color, String tag, String title, String subtitle, Widget page) => TapSurface(
        onTap: () => Navigator.push(context, jsRoute(page)),
        child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8.5, letterSpacing: .8)), const SizedBox(height: 2), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 10))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)]),
      );
}

class MorePage extends StatelessWidget {
  final UserRole role;
  const MorePage({super.key, required this.role});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            surface(Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: role.color.withOpacity(.12), shape: BoxShape.circle), child: Icon(role.icon, color: role.color, size: 27)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), const Text('JeevanSetu SIH demo profile', style: TextStyle(color: Colors.black45, fontSize: 10))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: green.withOpacity(.1), borderRadius: BorderRadius.circular(8)), child: const Text('ONLINE', style: TextStyle(color: green, fontSize: 8, fontWeight: FontWeight.w900)))])),
            const SizedBox(height: 12),
            _more(context, Icons.family_restroom_rounded, 'Personal Safety', 'Family live status & check-in', const PersonalSafetyPage()),
            _more(context, Icons.sensors_rounded, 'Sensor Network', 'Rain gauges, soil & slope telemetry', const SensorNetworkPage()),
            _more(context, Icons.inventory_2_outlined, 'Relief & Resources', 'Camps, hospitals and supplies', const ResourcesPage()),
            _more(context, Icons.smart_toy_outlined, 'AI Assistant', 'Ask safety and response questions', const AssistantPage()),
            _more(context, Icons.download_for_offline_outlined, 'Offline Readiness', 'Emergency pack cached for demo', const OfflinePage()),
            _more(context, Icons.shield_outlined, 'Safety Guidelines', 'Landslide survival checklist', const GuidelinesPage()),
            _more(context, Icons.contact_emergency_outlined, 'Emergency Contacts', 'Response numbers & command links', const ContactsPage()),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => Navigator.pushAndRemoveUntil(context, jsRoute(const RolePickerPage()), (_) => false), icon: const Icon(Icons.swap_horiz_rounded), label: const Text('Switch profession / role')),
          ],
        ),
      );

  Widget _more(BuildContext c, IconData icon, String title, String sub, Widget page) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TapSurface(onTap: () => Navigator.push(c, jsRoute(page)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEAF6F8), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: navy)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(sub, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])),
      );
}

PreferredSizeWidget jsAppBar(String title, {Widget? action}) => AppBar(title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), actions: action == null ? null : [action, const SizedBox(width: 8)]);

class RiskAnalysisPage extends StatefulWidget {
  const RiskAnalysisPage({super.key});
  @override State<RiskAnalysisPage> createState() => _RiskAnalysisPageState();
}
class _RiskAnalysisPageState extends State<RiskAnalysisPage> with SingleTickerProviderStateMixin {
  late final AnimationController c;
  @override void initState() { super.initState(); c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward(); }
  @override void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: jsAppBar('AI Risk Analysis'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), children: [
          const Row(children: [Expanded(child: _Segment(text: 'Current', active: true)), SizedBox(width: 8), Expanded(child: _Segment(text: 'Next 48 Hours', active: false))]),
          const SizedBox(height: 12),
          surface(const Row(children: [Icon(Icons.location_on_outlined, size: 19), SizedBox(width: 8), Text('Sindhupalchok, Nepal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))])),
          const SizedBox(height: 12),
          surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Text('Landslide Risk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Spacer(), Text('AI confidence 92%', style: TextStyle(color: green, fontWeight: FontWeight.w800, fontSize: 9.5))]),
            const SizedBox(height: 18),
            Center(child: AnimatedBuilder(animation: c, builder: (_, __) => SizedBox(width: 150, height: 150, child: CustomPaint(painter: _GaugePainter(.78 * Curves.easeOutCubic.transform(c.value)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${(78 * c.value).round()}%', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const Text('HIGH RISK', style: TextStyle(color: red, fontWeight: FontWeight.w900, fontSize: 11))]))))),
            const SizedBox(height: 20),
            const Text('Why the AI is concerned', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 10),
            const _Factor(icon: Icons.water_drop_outlined, color: blue, title: 'Rainfall (24h)', value: '126 mm', contribution: .92),
            const _Factor(icon: Icons.water_rounded, color: cyan, title: 'Soil saturation', value: '87%', contribution: .87),
            const _Factor(icon: Icons.change_history_rounded, color: purple, title: 'Terrain slope', value: '38° steep', contribution: .79),
            const _Factor(icon: Icons.history_rounded, color: orange, title: 'Historical activity', value: 'High', contribution: .68),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(13)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome_rounded, color: orange, size: 19), SizedBox(width: 8), Expanded(child: Text('AI explanation: prolonged rainfall has pushed soil moisture above the local failure threshold on steep slopes. Avoid red-zone roads until rainfall eases.', style: TextStyle(fontSize: 10.5, height: 1.4)))])),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => Navigator.push(context, jsRoute(const SafeRoutePage())), child: const Text('Generate safest evacuation route'))),
          ])),
          const SizedBox(height: 15),
          _sectionTitle('48-hour risk trend', 'Prototype nowcast simulation'),
          const SizedBox(height: 9),
          surface(const SizedBox(height: 120, child: CustomPaint(painter: _TrendPainter()))),
        ]),
      );
}

class _Segment extends StatelessWidget { final String text; final bool active; const _Segment({required this.text, required this.active}); @override Widget build(BuildContext context) => Container(height: 39, alignment: Alignment.center, decoration: BoxDecoration(color: active ? navy : const Color(0xFFE5ECEF), borderRadius: BorderRadius.circular(11)), child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 10.5, fontWeight: FontWeight.w800))); }
class _Factor extends StatelessWidget { final IconData icon; final Color color; final String title, value; final double contribution; const _Factor({required this.icon, required this.color, required this.title, required this.value, required this.contribution}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), SizedBox(width: 105, child: Text(title, style: const TextStyle(fontSize: 10.5))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: contribution, minHeight: 6, color: color, backgroundColor: color.withOpacity(.1)))), const SizedBox(width: 9), Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900))])); }
class _TrendPainter extends CustomPainter { const _TrendPainter(); @override void paint(Canvas c, Size s) { final grid = Paint()..color = const Color(0xFFE7EFF2)..strokeWidth = 1; for (int i=1;i<4;i++) c.drawLine(Offset(0,s.height*i/4),Offset(s.width,s.height*i/4),grid); final p = Paint()..color = red..style = PaintingStyle.stroke..strokeWidth=3..strokeCap=StrokeCap.round; final path=Path()..moveTo(0,s.height*.75)..cubicTo(s.width*.15,s.height*.65,s.width*.22,s.height*.45,s.width*.35,s.height*.5)..cubicTo(s.width*.48,s.height*.55,s.width*.58,s.height*.2,s.width*.72,s.height*.28)..cubicTo(s.width*.86,s.height*.36,s.width*.91,s.height*.18,s.width,s.height*.15); c.drawPath(path,p); } @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false; }

class EarlyWarningPage extends StatelessWidget {
  const EarlyWarningPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: jsAppBar('Early Warning'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), children: [
          Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFEC3C59)]), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28), SizedBox(width: 8), Text('High Risk Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))]), SizedBox(height: 10), Text('Landslide likely in your area\nwithin the next 12 hours.', style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4))])),
          const SizedBox(height: 8),
          const Text('Issued just now · AI confidence 92%', style: TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 19),
          const _WarningInfo(Icons.info_rounded, blue, 'Expected Impact', 'Possible road blockages, slope failure and local power disruption.'),
          const _WarningInfo(Icons.directions_walk_rounded, orange, 'Suggested Action', 'Avoid vulnerable slopes and follow the safe evacuation corridor.'),
          const _WarningInfo(Icons.location_on_rounded, green, 'Affected Zones', 'Sindhupalchok north-east corridor and nearby settlements.'),
          const _WarningInfo(Icons.timer_outlined, purple, 'Critical Window', 'Highest model risk between 21:00 and 03:00.'),
          const SizedBox(height: 16),
          SizedBox(height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: red), onPressed: () => Navigator.push(context, jsRoute(const RiskMapPage())), child: const Text('View affected zones on live map', style: TextStyle(fontWeight: FontWeight.w900)))),
          const SizedBox(height: 9),
          OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert share sheet simulated for prototype'))), icon: const Icon(Icons.share_rounded), label: const Text('Share verified alert')),
        ]),
      );
}
class _WarningInfo extends StatelessWidget { final IconData icon; final Color color; final String title, text; const _WarningInfo(this.icon,this.color,this.title,this.text); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:36,height:36,decoration:BoxDecoration(color:color.withOpacity(.1),borderRadius:BorderRadius.circular(11)),child:Icon(icon,color:color,size:20)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),const SizedBox(height:3),Text(text,style:const TextStyle(color:Colors.black54,fontSize:10.5,height:1.35))]))])); }

class SafeRoutePage extends StatefulWidget { const SafeRoutePage({super.key}); @override State<SafeRoutePage> createState()=>_SafeRoutePageState(); }
class _SafeRoutePageState extends State<SafeRoutePage> { bool navigating=false; @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Safe Route'),body:Column(children:[Padding(padding:const EdgeInsets.fromLTRB(16,4,16,10),child:surface(const Column(children:[Row(children:[Icon(Icons.my_location_rounded,size:18,color:navy),SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Your location',style:TextStyle(fontSize:9,color:Colors.black45)),Text('Sindhupalchok risk corridor',style:TextStyle(fontWeight:FontWeight.w900,fontSize:12))]))]),Divider(),Row(children:[Icon(Icons.flag_outlined,size:18,color:navy),SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Destination',style:TextStyle(fontSize:9,color:Colors.black45)),Text('Nearest verified safe shelter',style:TextStyle(fontWeight:FontWeight.w900,fontSize:12))]))])]))),Expanded(child:Stack(children:[FlutterMap(options:MapOptions(initialCenter:const LatLng(27.78,85.48),initialZoom:11.2),children:[TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.sih.jeevansetu'),PolygonLayer(polygons:[Polygon(points:const[LatLng(27.76,85.42),LatLng(27.80,85.48),LatLng(27.78,85.54),LatLng(27.73,85.50)],color:red.withOpacity(.18),borderColor:red,borderStrokeWidth:2)]),PolylineLayer(polylines:[Polyline(points:const[LatLng(27.742,85.435),LatLng(27.755,85.455),LatLng(27.765,85.482),LatLng(27.785,85.505),LatLng(27.802,85.528)],strokeWidth:6,color:cyan,borderColor:Colors.white,borderStrokeWidth:2)]),MarkerLayer(markers:[const Marker(point:LatLng(27.742,85.435),width:45,height:45,child:Icon(Icons.location_on_rounded,color:red,size:40)),const Marker(point:LatLng(27.802,85.528),width:45,height:45,child:Icon(Icons.location_on_rounded,color:green,size:40))])]),Positioned(top:14,right:14,child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:green,borderRadius:BorderRadius.circular(13),boxShadow:[BoxShadow(color:green.withOpacity(.24),blurRadius:15)]),child:const Text('✓ SAFEST ROUTE\n6.8 km · 18 min',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w900)))),Positioned(left:16,right:16,bottom:18,child:SizedBox(height:53,child:FilledButton(style:FilledButton.styleFrom(backgroundColor:navigating?green:cyan),onPressed:()=>setState(()=>navigating=!navigating),child:Text(navigating?'Navigation active · ETA 18 min':'Start Navigation',style:const TextStyle(fontWeight:FontWeight.w900))))) ]))])); }

class ReportIncidentPage extends StatefulWidget { const ReportIncidentPage({super.key}); @override State<ReportIncidentPage> createState()=>_ReportIncidentPageState(); }
class _ReportIncidentPageState extends State<ReportIncidentPage> { String type='Landslide'; bool submitted=false; @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Report Incident'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[const Row(children:[Expanded(child:_Segment(text:'Photo',active:true)),SizedBox(width:8),Expanded(child:_Segment(text:'Video',active:false))]),const SizedBox(height:11),ClipRRect(borderRadius:BorderRadius.circular(19),child:AspectRatio(aspectRatio:1.72,child:Stack(fit:StackFit.expand,children:[const ReferencePhoto(4),Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Colors.black45]))),const Positioned(left:12,bottom:10,child:Row(children:[Icon(Icons.auto_awesome_rounded,color:Colors.white,size:17),SizedBox(width:6),Text('AI visual check: possible slope debris',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w700))]))]))),const SizedBox(height:11),surface(const Row(children:[Icon(Icons.location_on_outlined,color:navy,size:19),SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Location · auto-detected',style:TextStyle(fontSize:9,color:Colors.black45)),Text('Sindhupalchok, Nepal',style:TextStyle(fontWeight:FontWeight.w900,fontSize:12))]))])),const SizedBox(height:15),const Text('Incident Type',style:TextStyle(fontWeight:FontWeight.w900,fontSize:14)),const SizedBox(height:8),Wrap(spacing:7,runSpacing:7,children:['Landslide','Flood','Road Block','Infrastructure'].map((e)=>ChoiceChip(label:Text(e),selected:type==e,onSelected:(_)=>setState(()=>type=e),selectedColor:const Color(0xFFDDF5F8),labelStyle:TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:type==e?navy:Colors.black54))).toList()),const SizedBox(height:12),TextField(maxLines:3,decoration:InputDecoration(hintText:'Describe what you see (optional)',filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),const SizedBox(height:13),SizedBox(height:52,child:FilledButton(onPressed:(){setState(()=>submitted=true);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$type report submitted for community verification')));},child:Text(submitted?'Report submitted ✓':'Submit Verified Report',style:const TextStyle(fontWeight:FontWeight.w900))))])); }

class CommunityReportsPage extends StatelessWidget { const CommunityReportsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Community Reports'),floatingActionButton:FloatingActionButton(backgroundColor:blue,foregroundColor:Colors.white,onPressed:()=>Navigator.push(context,jsRoute(const ReportIncidentPage())),child:const Icon(Icons.add_rounded)),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,30),children:[const Row(children:[Expanded(child:_Segment(text:'Nearby',active:true)),SizedBox(width:8),Expanded(child:_Segment(text:'All Nepal',active:false))]),const SizedBox(height:12),_community('Landslide','Sindhupalchok · 2.4 km','AI VERIFIED · 92%',red),_community('Road Block','Araniko Highway · 4.1 km','VERIFIED · 3 REPORTS',orange),_community('Flash Flood','Melamchi · 8.7 km','UNDER REVIEW',blue),_community('Bridge Damage','12.2 km away','AUTHORITY CHECK',purple)])); Widget _community(String t,String s,String b,Color c)=>Padding(padding:const EdgeInsets.only(bottom:9),child:surface(Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:c.withOpacity(.1),borderRadius:BorderRadius.circular(14)),child:Icon(t=='Landslide'?Icons.landscape_rounded:Icons.warning_rounded,color:c)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),Text(s,style:const TextStyle(fontSize:9.5,color:Colors.black45)),const SizedBox(height:4),Text(b,style:TextStyle(color:c,fontSize:8,fontWeight:FontWeight.w900))])),const Icon(Icons.chevron_right_rounded,color:Colors.black38)]))); }

class ResourcesPage extends StatelessWidget { const ResourcesPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Relief & Resources'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[const Row(children:[Expanded(child:_Segment(text:'Relief Camps',active:true)),SizedBox(width:8),Expanded(child:_Segment(text:'Essential Services',active:false))]),const SizedBox(height:12),_res(context,Icons.home_work_rounded,'Melamchi Community Hall','2.1 km · 250 capacity',['Food','Water','Medical']),_res(context,Icons.school_rounded,'Shree Secondary Shelter','4.8 km · 180 capacity',['Food','Medical']),_res(context,Icons.temple_buddhist_rounded,'Monastery Relief Camp','6.3 km · 300 capacity',['Food','Water','Power']),_res(context,Icons.local_hospital_rounded,'District Hospital','7.5 km · 24×7 emergency',['Medical','Ambulance'])])); Widget _res(BuildContext c,IconData i,String t,String s,List<String> tags)=>Padding(padding:const EdgeInsets.only(bottom:9),child:TapSurface(onTap:()=>showModalBottomSheet(context:c,showDragHandle:true,builder:(_)=>Padding(padding:const EdgeInsets.fromLTRB(20,0,20,28),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(height:6),Text(s),const SizedBox(height:14),const LinearProgressIndicator(value:.76,minHeight:8,borderRadius:BorderRadius.all(Radius.circular(9)),color:green,backgroundColor:Color(0xFFE3F5EE)),const SizedBox(height:6),const Text('76% capacity available · verified 8 min ago',style:TextStyle(color:green,fontSize:10,fontWeight:FontWeight.w800)),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(c),child:const Text('Navigate to this safe hub')))])),child:Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:green.withOpacity(.11),borderRadius:BorderRadius.circular(14)),child:Icon(i,color:green)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),Text(s,style:const TextStyle(color:Colors.black45,fontSize:9.5)),const SizedBox(height:5),Wrap(spacing:4,children:tags.map((x)=>Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:3),decoration:BoxDecoration(color:blue.withOpacity(.08),borderRadius:BorderRadius.circular(6)),child:Text(x,style:const TextStyle(color:blue,fontSize:8,fontWeight:FontWeight.w800)))).toList())])),const Icon(Icons.chevron_right_rounded,color:Colors.black38)]))); }

class AssistantPage extends StatefulWidget { const AssistantPage({super.key}); @override State<AssistantPage> createState()=>_AssistantPageState(); }
class _AssistantPageState extends State<AssistantPage> { final input=TextEditingController(); final List<(bool,String)> messages=[(false,'Namaste. I can explain risk, find safe routes, locate relief camps and guide emergency actions.')]; void send([String? preset]){final q=(preset??input.text).trim();if(q.isEmpty)return;setState((){messages.add((true,q));messages.add((false,_answer(q)));});input.clear();} String _answer(String q){final s=q.toLowerCase();if(s.contains('route'))return 'The safest demo corridor avoids the red-zone segment and reaches the verified shelter in about 18 minutes. Open Safe Route for the live map.';if(s.contains('risk'))return 'Current simulated risk is 78% High. The strongest drivers are 126 mm rainfall, 87% soil saturation and steep terrain.';if(s.contains('camp')||s.contains('shelter'))return 'Melamchi Community Hall is the closest verified hub in this demo: 2.1 km, 250 capacity, food, water and medical support.';return 'For this SIH prototype I can guide safety actions and link you to the relevant live screen. For a real deployment, responses would come from verified model/API data.';} @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('AI Safety Assistant'),body:Column(children:[Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[const Center(child:Column(children:[Icon(Icons.smart_toy_rounded,color:blue,size:58),SizedBox(height:6),Text('JeevanSetu Copilot',style:TextStyle(fontWeight:FontWeight.w900,fontSize:18)),Text('Context-aware disaster guidance',style:TextStyle(color:Colors.black45,fontSize:9.5))])),const SizedBox(height:16),Wrap(spacing:6,runSpacing:6,children:['Current risk?','Show safe route','Nearest shelter','What should I do?'].map((e)=>ActionChip(label:Text(e,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w700)),onPressed:()=>send(e))).toList()),const SizedBox(height:13),...messages.map((m)=>Align(alignment:m.$1?Alignment.centerRight:Alignment.centerLeft,child:Container(constraints:const BoxConstraints(maxWidth:310),margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:m.$1?navy:Colors.white,borderRadius:BorderRadius.circular(15),border:m.$1?null:Border.all(color:const Color(0xFFE7EFF2))),child:Text(m.$2,style:TextStyle(color:m.$1?Colors.white:ink,fontSize:10.5,height:1.4)))))])),SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(12),child:TextField(controller:input,onSubmitted:(_)=>send(),decoration:InputDecoration(hintText:'Ask a safety question…',filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide.none),suffixIcon:IconButton(onPressed:()=>send(),icon:const Icon(Icons.send_rounded,color:cyan))))))])); }

class PersonalSafetyPage extends StatefulWidget { const PersonalSafetyPage({super.key}); @override State<PersonalSafetyPage> createState()=>_PersonalSafetyPageState(); }
class _PersonalSafetyPageState extends State<PersonalSafetyPage>{ bool checked=false; @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Personal Safety'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,Color(0xFF0A6578)]),borderRadius:BorderRadius.circular(20)),child:Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:green.withOpacity(.2),shape:BoxShape.circle),child:const Icon(Icons.verified_user_rounded,color:aqua)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('You are in a monitored zone',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:14)),Text(checked?'Check-in sent just now':'Last safety check-in 22 min ago',style:const TextStyle(color:Colors.white60,fontSize:9.5))])),FilledButton.tonal(onPressed:()=>setState(()=>checked=true),child:Text(checked?'Sent ✓':'Check in'))])),const SizedBox(height:14),_family('You','Safe · live location',green),_family('Mother','Safe · 2 min ago',green),_family('Father','Safe · 18 min ago',green),_family('Sister','Awaiting check-in',orange),const SizedBox(height:12),SizedBox(height:50,child:FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Family invite flow opened in prototype'))),child:const Text('Add Family Member')))])); Widget _family(String t,String s,Color c)=>Padding(padding:const EdgeInsets.only(bottom:8),child:surface(Row(children:[CircleAvatar(backgroundColor:c.withOpacity(.12),child:Icon(Icons.person_rounded,color:c)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12.5)),Text(s,style:TextStyle(color:c,fontSize:9.5))])),const Icon(Icons.chevron_right_rounded,color:Colors.black38)]))); }

class SensorNetworkPage extends StatelessWidget { const SensorNetworkPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Sensor Network'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[deepNavy,navy]),borderRadius:BorderRadius.circular(20)),child:const Row(children:[Icon(Icons.sensors_rounded,color:aqua,size:37),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('26 / 28 sensors online',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:15)),Text('Last sync 14 sec ago · mesh health 96%',style:TextStyle(color:Colors.white60,fontSize:9.5))])),Text('96%',style:TextStyle(color:aqua,fontSize:22,fontWeight:FontWeight.w900))])),const SizedBox(height:13),_sensor(Icons.water_drop_outlined,'Rain Gauge SG-04','18.4 mm / hr','Rising',blue,.82),_sensor(Icons.water_rounded,'Soil Probe SM-12','87% saturation','Critical',red,.87),_sensor(Icons.straighten_rounded,'Slope Node IN-07','2.8 mm movement','Watch',orange,.62),_sensor(Icons.cloud_outlined,'Weather Station WX-03','Pressure falling','Active',green,.48),const SizedBox(height:10),surface(const SizedBox(height:130,child:CustomPaint(painter:_TrendPainter()))) ])); Widget _sensor(IconData i,String t,String v,String state,Color c,double val)=>Padding(padding:const EdgeInsets.only(bottom:9),child:surface(Column(children:[Row(children:[Container(width:40,height:40,decoration:BoxDecoration(color:c.withOpacity(.1),borderRadius:BorderRadius.circular(12)),child:Icon(i,color:c)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text(v,style:const TextStyle(color:Colors.black45,fontSize:9.5))])),Text(state,style:TextStyle(color:c,fontSize:9,fontWeight:FontWeight.w900))]),const SizedBox(height:9),LinearProgressIndicator(value:val,minHeight:6,borderRadius:BorderRadius.circular(8),color:c,backgroundColor:c.withOpacity(.1))]))); }

class RescueCommandPage extends StatelessWidget { const RescueCommandPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Rescue Command'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[_opsHero(red,'11','Responders','3','Active missions','2','Medical teams'),const SizedBox(height:13),_mission('MISSION JS-104','Landslide · 4 persons trapped','ETA 11 min','Team Alpha',red),_mission('MISSION JS-103','Road blockage · elderly evac','ETA 18 min','Team Bravo',orange),_mission('MISSION JS-101','Shelter transfer · 12 persons','On scene','Medical-2',green)])); }
class AuthorityCenterPage extends StatelessWidget { const AuthorityCenterPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Authority Command Center'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[_opsHero(blue,'4','High-risk wards','18','Safe hubs','92%','Alert confidence'),const SizedBox(height:13),surface(const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Broadcast readiness',style:TextStyle(fontWeight:FontWeight.w900,fontSize:14)),SizedBox(height:10),LinearProgressIndicator(value:.96,minHeight:8,borderRadius:BorderRadius.all(Radius.circular(8)),color:blue,backgroundColor:Color(0xFFE1ECFF)),SizedBox(height:7),Text('SMS · push · siren network · responder radio',style:TextStyle(color:Colors.black45,fontSize:9.5))])),const SizedBox(height:10),_mission('ALERT #NW-27','Sindhupalchok high-risk corridor','Ready to broadcast','92% verified',red),_mission('ROAD #A12','Araniko Highway partial closure','Authority verified','Traffic diversion active',orange)])); }
class VolunteerOpsPage extends StatelessWidget { const VolunteerOpsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Volunteer Operations'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[_opsHero(purple,'18','Online','2','Nearby tasks','46','Families checked'),const SizedBox(height:13),_mission('TASK V-21','Pack water + first aid','1.2 km','8 volunteers needed',purple),_mission('TASK V-19','Shelter registration support','2.0 km','4 volunteers needed',green)])); }
class OrganizationOpsPage extends StatelessWidget { const OrganizationOpsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Resource Command'),body:ListView(padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[_opsHero(orange,'4','Facilities','730','Beds','81%','Stock ready'),const SizedBox(height:13),_mission('INVENTORY','Water packs','1,260 units','81% ready',blue),_mission('MEDICAL','Trauma kits','87 kits','92% ready',red),_mission('POWER','Portable generators','12 units','9 available',green)])); }
Widget _opsHero(Color c,String a,String at,String b,String bt,String d,String dt)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:LinearGradient(colors:[navy,Color.lerp(navy,c,.5)!]),borderRadius:BorderRadius.circular(20)),child:Row(children:[Expanded(child:_opStat(a,at)),Container(width:1,height:45,color:Colors.white24),Expanded(child:_opStat(b,bt)),Container(width:1,height:45,color:Colors.white24),Expanded(child:_opStat(d,dt))]));
Widget _opStat(String a,String b)=>Column(children:[Text(a,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(b,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60,fontSize:8.5))]);
Widget _mission(String id,String title,String status,String team,Color c)=>Padding(padding:const EdgeInsets.only(bottom:9),child:surface(Row(children:[Container(width:45,height:45,decoration:BoxDecoration(color:c.withOpacity(.1),borderRadius:BorderRadius.circular(13)),child:Icon(Icons.my_location_rounded,color:c)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(id,style:TextStyle(color:c,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.6)),Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text('$status · $team',style:const TextStyle(color:Colors.black45,fontSize:9.5))])),const Icon(Icons.chevron_right_rounded,color:Colors.black38)])));

class OfflinePage extends StatelessWidget { const OfflinePage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Offline Readiness'),body:ListView(padding:const EdgeInsets.all(16),children:[Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,Color(0xFF0A6578)]),borderRadius:BorderRadius.circular(20)),child:const Column(children:[Icon(Icons.offline_bolt_rounded,color:aqua,size:45),SizedBox(height:9),Text('Emergency pack ready offline',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:16)),SizedBox(height:4),Text('Safety guides, emergency contacts and the last known risk snapshot are cached for the prototype.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white60,fontSize:10.5,height:1.4))])),const SizedBox(height:12),_offline(Icons.map_outlined,'Risk snapshot','Updated 3 min ago'),_offline(Icons.shield_outlined,'Safety guidelines','Available offline'),_offline(Icons.contact_emergency_outlined,'Emergency contacts','Available offline') ])); }
Widget _offline(IconData i,String t,String s)=>Padding(padding:const EdgeInsets.only(bottom:8),child:surface(Row(children:[Icon(i,color:green),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text(s,style:const TextStyle(color:Colors.black45,fontSize:9.5))])),const Icon(Icons.check_circle_rounded,color:green)])));

class GuidelinesPage extends StatelessWidget { const GuidelinesPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Safety Guidelines'),body:ListView(padding:const EdgeInsets.all(16),children:[_guide('1','Move away from steep slopes','Do not wait directly below a visibly unstable slope or drainage channel.',red),_guide('2','Follow verified evacuation routes','Avoid shortcuts through red zones even if they appear faster.',orange),_guide('3','Keep an emergency go-bag','Carry water, medicines, light, power bank and identity documents.',blue),_guide('4','Check in with family','Use Personal Safety so responders know who is safe and who needs help.',green)])); }
Widget _guide(String n,String t,String s,Color c)=>Padding(padding:const EdgeInsets.only(bottom:9),child:surface(Row(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:c,foregroundColor:Colors.white,child:Text(n,style:const TextStyle(fontWeight:FontWeight.w900))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),const SizedBox(height:3),Text(s,style:const TextStyle(color:Colors.black54,fontSize:10.5,height:1.35))]))])));

class ContactsPage extends StatelessWidget { const ContactsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:jsAppBar('Emergency Contacts'),body:ListView(padding:const EdgeInsets.all(16),children:[_contact(context,'National Emergency Demo','112',red),_contact(context,'District Response Desk','1077',blue),_contact(context,'Nearest Medical Team','Available',green),_contact(context,'JeevanSetu Command','In-app radio',purple)])); Widget _contact(BuildContext c,String t,String s,Color color)=>Padding(padding:const EdgeInsets.only(bottom:9),child:TapSurface(onTap:()=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('Contact action: $t'))),child:Row(children:[CircleAvatar(backgroundColor:color.withOpacity(.1),child:Icon(Icons.phone_in_talk_rounded,color:color)),const SizedBox(width:11),Expanded(child:Text(t,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12.5))),Text(s,style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:11)),const SizedBox(width:4),const Icon(Icons.chevron_right_rounded,color:Colors.black38)]))); }
