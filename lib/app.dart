import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const navy = Color(0xFF073C4D);
const ink = Color(0xFF0D1B20);
const cyan = Color(0xFF20C5D8);
const blue = Color(0xFF4A8EF7);
const red = Color(0xFFFF4057);
const green = Color(0xFF28C98B);
const orange = Color(0xFFFFA638);
const purple = Color(0xFF7657E8);
const bg = Color(0xFFF3F8FA);

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
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: ink),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: ink),
          titleLarge: TextStyle(fontWeight: FontWeight.w900, color: ink),
          titleMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
          bodyMedium: TextStyle(color: Color(0xFF5D6B70)),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFDDF7FA),
          height: 70,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          surfaceTintColor: bg,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

Route<T> appRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: page,
      ),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween(begin: const Offset(.025, .015), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

class LogoMark extends StatelessWidget {
  final double size;
  final Color color;
  const LogoMark({super.key, this.size = 72, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .7,
      child: CustomPaint(painter: _LogoPainter(color)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .115
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final path = Path()
      ..moveTo(size.width * .08, size.height * .86)
      ..lineTo(size.width * .43, size.height * .17)
      ..lineTo(size.width * .70, size.height * .63)
      ..lineTo(size.width * .91, size.height * .39);
    canvas.drawPath(path, p);
    canvas.drawLine(
      Offset(size.width * .38, size.height * .64),
      Offset(size.width * .69, size.height * .64),
      Paint()
        ..color = color.withOpacity(.75)
        ..strokeWidth = size.width * .07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PhotoBackdrop extends StatelessWidget {
  final String asset;
  final Widget child;
  final double darkness;
  final Alignment alignment;
  const PhotoBackdrop({
    super.key,
    required this.asset,
    required this.child,
    this.darkness = .30,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'visual-$asset',
          child: Image.asset(asset, fit: BoxFit.cover, alignment: alignment),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(darkness * .35),
                navy.withOpacity(.12),
                navy.withOpacity(.90),
              ],
              stops: const [0, .45, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double radius;
  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: navy.withOpacity(.055)),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(.045),
              blurRadius: 22,
              offset: const Offset(0, 9),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacement(context, appRoute(const OnboardingScreen()));
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoBackdrop(
        asset: 'assets/images/hero_mountain.jpg',
        darkness: .34,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .8, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (_, value, child) => Transform.scale(scale: value, child: child),
                  child: const Column(
                    children: [
                      LogoMark(size: 92),
                      SizedBox(height: 13),
                      Text(
                        'JeevanSetu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Disaster Monitoring & Response',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => Column(
                    children: [
                      const Text(
                        'Loading live safety intelligence…',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 11),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: controller.value,
                          minHeight: 5,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OnboardData(
        'Safer Communities\nwith Smarter Monitoring',
        'AI-powered landslide and flood risk analysis for early warning and faster response.',
        'assets/images/monitoring_mountain.jpg',
      ),
      const _OnboardData(
        'Real-Time Risk\nInsights',
        'Live risk zones, AI explainability, community evidence and safe-route intelligence in one map.',
        'assets/images/hero_mountain.jpg',
      ),
      const _OnboardData(
        'Report · Respond\n· Stay Safe',
        'A unified platform for citizens, rescue teams, authorities, volunteers and relief organisations.',
        'assets/images/rescue_diver.jpg',
      ),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: controller,
        itemCount: pages.length,
        onPageChanged: (v) => setState(() => index = v),
        itemBuilder: (_, i) {
          final p = pages[i];
          return PhotoBackdrop(
            asset: p.asset,
            darkness: .24,
            alignment: i == 2 ? Alignment.topCenter : Alignment.center,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      p.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      p.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.45,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          '${i + 1} / 3',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            appRoute(const RolePicker()),
                          ),
                          child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 6),
                        FloatingActionButton.small(
                          heroTag: 'onboard-$i',
                          elevation: 0,
                          backgroundColor: const Color(0xFF5CE0E9),
                          onPressed: () {
                            if (i < 2) {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              Navigator.push(context, appRoute(const RolePicker()));
                            }
                          },
                          child: Icon(
                            i == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            color: navy,
                          ),
                        ),
                      ],
                    )
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

class _OnboardData {
  final String title;
  final String subtitle;
  final String asset;
  const _OnboardData(this.title, this.subtitle, this.asset);
}

enum UserRole { citizen, rescue, authority, volunteer, organization }

extension UserRoleX on UserRole {
  String get title => switch (this) {
        UserRole.citizen => 'Citizen',
        UserRole.rescue => 'Rescue Team',
        UserRole.authority => 'Authority',
        UserRole.volunteer => 'Volunteer',
        UserRole.organization => 'Organization',
      };
  String get subtitle => switch (this) {
        UserRole.citizen => 'Report, receive alerts and stay safe',
        UserRole.rescue => 'Dispatch, triage and respond to emergencies',
        UserRole.authority => 'Monitor, verify and coordinate response',
        UserRole.volunteer => 'Support communities and verified missions',
        UserRole.organization => 'Provide shelters, supplies and logistics',
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

class RolePicker extends StatelessWidget {
  const RolePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text('Select your role', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 22),
              ...UserRole.values.map(
                (role) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: () => Navigator.push(context, appRoute(LoginScreen(role: role))),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [role.color, role.color.withOpacity(.78)],
                          ),
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: role.color.withOpacity(.22),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.90),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      role.subtitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoBackdrop(
        asset: 'assets/images/hero_mountain.jpg',
        darkness: .45,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const SizedBox(height: 28),
                const Center(child: LogoMark(size: 78)),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'JeevanSetu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  '${role.title} Sign In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(role.subtitle, style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 22),
                const _DarkField(Icons.person_outline_rounded, 'Email or Phone'),
                const SizedBox(height: 11),
                const _DarkField(Icons.lock_outline_rounded, 'Password', obscure: true),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: role.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      appRoute(AppShell(role: role)),
                      (_) => false,
                    ),
                    child: Text(
                      'Continue as ${role.title}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      appRoute(AppShell(role: role)),
                      (_) => false,
                    ),
                    child: const Text('Use SIH demo access', style: TextStyle(color: Colors.white70)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  const _DarkField(this.icon, this.hint, {this.obscure = false});
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
        fillColor: const Color(0xFF0B5266).withOpacity(.82),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: cyan),
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
      HomeScreen(role: widget.role),
      const RiskMapScreen(),
      const SosScreen(),
      const AlertsScreen(),
      MoreScreen(role: widget.role),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.sos_outlined), selectedIcon: Icon(Icons.sos_rounded), label: 'SOS'),
          NavigationDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final UserRole role;
  const HomeScreen({super.key, required this.role});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }
  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 330,
            child: PhotoBackdrop(
              asset: 'assets/images/hero_mountain.jpg',
              darkness: .28,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: role.color,
                          child: Icon(role.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Good Morning,', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text(role.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                        )
                      ],
                    ),
                    const Spacer(),
                    const Text('NEPAL · LIVE RISK INTELLIGENCE', style: TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                    const SizedBox(height: 5),
                    const Text('Know the slope\nbefore it moves.', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.02, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _HeroMetric(label: 'RISK', value: '78%', color: red),
                        const SizedBox(width: 8),
                        _HeroMetric(label: 'RAIN', value: '126 mm', color: blue),
                        const SizedBox(width: 8),
                        _HeroMetric(label: 'SHELTERS', value: '18', color: green),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(context, appRoute(const EarlyWarningScreen())),
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFED5364)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: red.withOpacity(.23), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: pulse,
                            builder: (_, child) => Transform.scale(scale: .92 + pulse.value * .12, child: child),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 31),
                          ),
                          const SizedBox(width: 11),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                SizedBox(height: 4),
                                Text('Sindhupalchok corridor may be affected in the next 12 hours.', style: TextStyle(color: Colors.white70, height: 1.35)),
                                SizedBox(height: 10),
                                Text('VIEW EXPLAINABLE ALERT  ›', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .4)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: _WeatherCard(icon: Icons.cloudy_snowing, value: '126 mm', label: '24h Rainfall', color: blue)),
                    SizedBox(width: 10),
                    Expanded(child: _WeatherCard(icon: Icons.water_drop_rounded, value: '91%', label: 'Soil Saturation', color: cyan)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Safety Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ink)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  childAspectRatio: .82,
                  children: [
                    _ActionTile(Icons.map_rounded, 'Live Map', green, () => Navigator.push(context, appRoute(const RiskMapScreen()))),
                    _ActionTile(Icons.route_rounded, 'Safe Route', cyan, () => Navigator.push(context, appRoute(const SafeRouteScreen()))),
                    _ActionTile(Icons.psychology_alt_rounded, 'AI Risk', purple, () => Navigator.push(context, appRoute(const AiAnalysisScreen()))),
                    _ActionTile(Icons.sos_rounded, 'SOS', red, () => Navigator.push(context, appRoute(const SosScreen()))),
                    _ActionTile(Icons.add_a_photo_rounded, 'Report', orange, () => Navigator.push(context, appRoute(const ReportScreen()))),
                    _ActionTile(Icons.home_work_rounded, 'Resources', green, () => Navigator.push(context, appRoute(const ResourcesScreen()))),
                    _ActionTile(Icons.smart_toy_rounded, 'AI Guide', blue, () => Navigator.push(context, appRoute(const AssistantScreen()))),
                    _ActionTile(Icons.groups_rounded, 'Family', purple, () => Navigator.push(context, appRoute(const FamilyScreen()))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Text('AI Risk Pulse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ink))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: green.withOpacity(.12), borderRadius: BorderRadius.circular(9)),
                      child: const Text('LIVE', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w900)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 125,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _PulseCard('Rainfall anomaly', '+34%', '6h trend', blue, Icons.water_drop_rounded),
                      _PulseCard('Slope instability', 'High', 'AI confidence 92%', red, Icons.landscape_rounded),
                      _PulseCard('Community reports', '17', '12 verified', green, Icons.verified_rounded),
                      _PulseCard('Road disruptions', '3', '1 critical', orange, Icons.alt_route_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _RoleMissionCard(role: role),
                const SizedBox(height: 14),
                Glass(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: green.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.shield_rounded, color: green),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3 shelters within 5 km', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
                            Text('Open now · 730 combined capacity', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.black38)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroMetric({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.24),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [CircleAvatar(radius: 3, backgroundColor: color), const SizedBox(width: 5), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _WeatherCard({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Glass(
        child: Row(
          children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.11), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: ink, fontSize: 17)), Text(label, style: const TextStyle(fontSize: 10))])),
          ],
        ),
      );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  const _PulseCard(this.title, this.value, this.subtitle, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Container(
        width: 162,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: navy.withOpacity(.055))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 19)), const Spacer(), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900))]),
          const Spacer(),
          Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 12)),
          Text(subtitle, style: const TextStyle(fontSize: 9)),
        ]),
      );
}

class _RoleMissionCard extends StatelessWidget {
  final UserRole role;
  const _RoleMissionCard({required this.role});
  @override
  Widget build(BuildContext context) {
    final title = switch (role) {
      UserRole.citizen => 'Your safety status',
      UserRole.rescue => '3 missions need response',
      UserRole.authority => 'Command centre: 4 active zones',
      UserRole.volunteer => '2 verified volunteer missions',
      UserRole.organization => 'Resource demand: Medical kits high',
    };
    final subtitle = switch (role) {
      UserRole.citizen => 'Family safe · nearest shelter 2.1 km',
      UserRole.rescue => '1 critical · 2 high priority · 11 people',
      UserRole.authority => '12 reports pending verification · 3 roads blocked',
      UserRole.volunteer => 'Food distribution and elderly evacuation support',
      UserRole.organization => 'Sindhupalchok relief cluster requests 40 kits',
    };
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, appRoute(RoleOpsScreen(role: role))),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [role.color.withOpacity(.14), role.color.withOpacity(.04)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: role.color.withOpacity(.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: role.color, borderRadius: BorderRadius.circular(15)), child: Icon(role.icon, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 11))])),
                const Icon(Icons.arrow_forward_rounded, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});
  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  bool forecast = false;
  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  static const centre = LatLng(27.7172, 85.3240);
  final zones = const [
    (LatLng(27.95, 85.70), 'Sindhupalchok', '86%', red),
    (LatLng(27.72, 85.32), 'Kathmandu', '52%', orange),
    (LatLng(28.21, 83.99), 'Pokhara', '68%', orange),
    (LatLng(27.53, 84.35), 'Chitwan', '34%', green),
    (LatLng(27.67, 85.43), 'Bhaktapur', '44%', const Color(0xFFFFD23F)),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Expanded(child: Text('Risk Map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: green.withOpacity(.12), borderRadius: BorderRadius.circular(9)),
                  child: const Text('● LIVE', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w900)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _MapModeButton('Live', !forecast, () => setState(() => forecast = false))),
                const SizedBox(width: 8),
                Expanded(child: _MapModeButton('48h Forecast', forecast, () => setState(() => forecast = true))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    options: const MapOptions(initialCenter: centre, initialZoom: 7.1),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'org.sih.jeevansetu',
                      ),
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: const [LatLng(27.82, 85.53), LatLng(28.10, 85.75), LatLng(28.18, 85.48), LatLng(27.96, 85.35)],
                            color: red.withOpacity(forecast ? .36 : .25),
                            borderColor: red.withOpacity(.7),
                            borderStrokeWidth: 2,
                          ),
                          Polygon(
                            points: const [LatLng(28.08, 83.77), LatLng(28.38, 84.22), LatLng(28.06, 84.38), LatLng(27.92, 84.01)],
                            color: orange.withOpacity(.22),
                            borderColor: orange.withOpacity(.7),
                            borderStrokeWidth: 2,
                          )
                        ],
                      ),
                      MarkerLayer(
                        markers: zones
                            .map(
                              (z) => Marker(
                                point: z.$1,
                                width: 62,
                                height: 62,
                                child: GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    showDragHandle: true,
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(z.$2, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                                          const SizedBox(height: 5),
                                          Text('${z.$3} predicted landslide risk · 7 community signals'),
                                          const SizedBox(height: 15),
                                          SizedBox(width: double.infinity, child: FilledButton(onPressed: () { Navigator.pop(context); Navigator.push(context, appRoute(const AiAnalysisScreen())); }, child: const Text('Open AI analysis')))
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: pulse,
                                    builder: (_, child) => Transform.scale(scale: .88 + pulse.value * .18, child: child),
                                    child: Stack(alignment: Alignment.center, children: [
                                      Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: z.$4.withOpacity(.17))),
                                      Icon(Icons.location_on_rounded, color: z.$4, size: 37),
                                    ]),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    width: 172,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: navy.withOpacity(.92), borderRadius: BorderRadius.circular(15)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('AI RISK LAYER', style: TextStyle(color: cyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text('Rainfall + terrain + reports', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 16,
                  child: Glass(
                    padding: const EdgeInsets.all(11),
                    radius: 15,
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Legend(red, 'Critical'),
                      _Legend(orange, 'High'),
                      _Legend(Color(0xFFFFD23F), 'Moderate'),
                      _Legend(green, 'Low'),
                    ]),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 18,
                  child: Column(
                    children: [
                      FloatingActionButton.small(heroTag: 'ai-map', backgroundColor: Colors.white, onPressed: () => Navigator.push(context, appRoute(const AiAnalysisScreen())), child: const Icon(Icons.psychology_alt_rounded, color: navy)),
                      const SizedBox(height: 9),
                      FloatingActionButton.small(heroTag: 'route-map', backgroundColor: Colors.white, onPressed: () => Navigator.push(context, appRoute(const SafeRouteScreen())), child: const Icon(Icons.route_rounded, color: navy)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MapModeButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _MapModeButton(this.text, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
        color: active ? navy : const Color(0xFFE5ECEF),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: SizedBox(height: 40, child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 11, fontWeight: FontWeight.w800)))),
        ),
      );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend(this.color, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 5, backgroundColor: color), const SizedBox(width: 7), Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ink))]),
      );
}

class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Risk Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Glass(child: Row(children: const [Icon(Icons.location_on_outlined), SizedBox(width: 9), Expanded(child: Text('Sindhupalchok, Nepal', style: TextStyle(fontWeight: FontWeight.w900, color: ink)))])),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Expanded(child: Text('Landslide Risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ink))), Text('AI CONFIDENCE 92%', style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.w900))]),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: .78, strokeWidth: 13, backgroundColor: Color(0xFFFFE1E7), valueColor: AlwaysStoppedAnimation(red))),
                      Column(children: const [Text('78%', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: ink)), Text('HIGH RISK', style: TextStyle(color: red, fontSize: 11, fontWeight: FontWeight.w900))]),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Why the model is concerned', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
                const SizedBox(height: 9),
                const _Factor(Icons.water_drop_rounded, '24h rainfall', '126 mm', blue, .88),
                const _Factor(Icons.water_rounded, 'Soil saturation', '91%', cyan, .91),
                const _Factor(Icons.landscape_rounded, 'Terrain slope', '38°', purple, .78),
                const _Factor(Icons.history_rounded, 'Historical failures', 'High', orange, .70),
                const _Factor(Icons.groups_rounded, 'Verified community signals', '12', green, .65),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            color: const Color(0xFFFFF8E7),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI recommendation', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
              SizedBox(height: 6),
              Text('Avoid steep road sections after 21:00. Move vulnerable families toward the nearest verified shelter before rainfall peaks.'),
            ]),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => Navigator.push(context, appRoute(const EarlyWarningScreen())), child: const Text('Open Early Warning')),
        ],
      ),
    );
  }
}

class _Factor extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double progress;
  const _Factor(this.icon, this.title, this.value, this.color, this.progress);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 12))), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: ink, fontSize: 12))]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: color.withOpacity(.10), valueColor: AlwaysStoppedAnimation(color))),
        ]),
      );
}

class EarlyWarningScreen extends StatelessWidget {
  const EarlyWarningScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Early Warning')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [red, Color(0xFFE8415C)]), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: red.withOpacity(.22), blurRadius: 22, offset: const Offset(0, 9))]),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28), SizedBox(width: 9), Text('High Risk Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))]),
                SizedBox(height: 10),
                Text('Landslide likely in vulnerable slopes within the next 12 hours.', style: TextStyle(color: Colors.white, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 14),
            const _WarningRow(Icons.info_rounded, blue, 'Expected Impact', 'Possible road blockages, slope failures and isolated communities.'),
            const _WarningRow(Icons.directions_walk_rounded, orange, 'Suggested Action', 'Avoid exposed roads, move to safe shelter and keep emergency contacts ready.'),
            const _WarningRow(Icons.location_on_rounded, green, 'Affected Zones', 'Sindhupalchok, Melamchi corridor and nearby steep settlements.'),
            const _WarningRow(Icons.verified_rounded, purple, 'Evidence', 'AI model + rainfall anomaly + 12 verified local reports.'),
            const SizedBox(height: 12),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: red, padding: const EdgeInsets.all(15)), onPressed: () => Navigator.push(context, appRoute(const RiskMapScreen())), child: const Text('View on Live Map')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert prepared for sharing'))), child: const Text('Share Alert')),
          ],
        ),
      );
}

class _WarningRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const _WarningRow(this.icon, this.color, this.title, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), const SizedBox(height: 3), Text(text, style: const TextStyle(fontSize: 12, height: 1.35))]))]),
      );
}

class SafeRouteScreen extends StatelessWidget {
  const SafeRouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const start = LatLng(27.7172, 85.3240);
    const shelter = LatLng(27.742, 85.345);
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Route')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Glass(
              child: Column(children: const [
                Row(children: [Icon(Icons.my_location_rounded, size: 18), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Location', style: TextStyle(fontSize: 10)), Text('Kathmandu Valley', style: TextStyle(fontWeight: FontWeight.w900, color: ink))]))]),
                Divider(height: 20),
                Row(children: [Icon(Icons.flag_outlined, size: 18), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Destination', style: TextStyle(fontSize: 10)), Text('Nearest Verified Shelter', style: TextStyle(fontWeight: FontWeight.w900, color: ink))]))]),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(initialCenter: LatLng(27.73, 85.335), initialZoom: 12.2),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.sih.jeevansetu'),
                    PolygonLayer(polygons: [Polygon(points: const [LatLng(27.725,85.33), LatLng(27.733,85.342), LatLng(27.72,85.352)], color: red.withOpacity(.18), borderColor: red.withOpacity(.7), borderStrokeWidth: 2)]),
                    PolylineLayer(polylines: [Polyline(points: const [start, LatLng(27.722,85.329), LatLng(27.728,85.332), LatLng(27.734,85.339), shelter], strokeWidth: 6, color: cyan)]),
                    MarkerLayer(markers: const [
                      Marker(point: start, width: 45, height: 45, child: Icon(Icons.location_on_rounded, color: red, size: 39)),
                      Marker(point: shelter, width: 45, height: 45, child: Icon(Icons.location_on_rounded, color: green, size: 39)),
                    ]),
                  ],
                ),
                Positioned(right: 14, top: 15, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(13)), child: const Text('✓ SAFE ROUTE\n3.8 km · 11 min', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)))),
                Positioned(left: 16, right: 16, bottom: 16, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: cyan, foregroundColor: navy, padding: const EdgeInsets.all(15)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigation started — route avoids active risk polygon'))), child: const Text('Start Navigation', style: TextStyle(fontWeight: FontWeight.w900))))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  bool sent = false;
  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Text('SOS Emergency', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink))),
          const SizedBox(height: 26),
          Center(
            child: GestureDetector(
              onLongPress: () {
                setState(() => sent = true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS broadcast sent with current location and safety profile')));
              },
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, child) => Container(
                  width: 178 + pulse.value * 12,
                  height: 178 + pulse.value * 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: red.withOpacity(.12), boxShadow: [BoxShadow(color: red.withOpacity(.18), blurRadius: 35, spreadRadius: 9)]),
                  alignment: Alignment.center,
                  child: child,
                ),
                child: Container(
                  width: 134,
                  height: 134,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: red),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(sent ? 'SENT' : 'SOS', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)), Text(sent ? 'Help is being notified' : 'Press and Hold', style: const TextStyle(color: Colors.white70, fontSize: 10))]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Your location, emergency type and medical needs\nwill be shared with verified responders.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11))),
          const SizedBox(height: 18),
          Glass(
            child: Column(children: [
              _SosOption(Icons.crisis_alert_rounded, 'Type of Emergency', () => _pick(context, 'Emergency type', ['Landslide','Flood','Road accident','Medical emergency'])),
              _SosOption(Icons.groups_rounded, 'Number of People', () => _pick(context, 'People affected', ['1','2–5','6–20','20+'])),
              _SosOption(Icons.medical_services_outlined, 'Medical Assistance Needed', () => _pick(context, 'Medical need', ['No','First aid','Urgent','Ambulance'])),
              _SosOption(Icons.add_a_photo_outlined, 'Add Photo / Video', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media attachment flow opened in prototype')))),
            ]),
          ),
          const SizedBox(height: 14),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: red, padding: const EdgeInsets.all(15)), onPressed: () { setState(() => sent = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency request sent successfully'))); }, child: const Text('Send Emergency Request', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  static void _pick(BuildContext context, String title, List<String> options) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 8), ...options.map((e) => ListTile(title: Text(e), onTap: () => Navigator.pop(context)))]))),
    );
  }
}

class _SosOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _SosOption(this.icon, this.text, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: navy), title: Text(text, style: const TextStyle(fontSize: 13)), trailing: const Icon(Icons.chevron_right_rounded), onTap: onTap);
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 13),
            _AlertCard(red, Icons.warning_rounded, 'High Landslide Risk', 'Sindhupalchok · active now', () => Navigator.push(context, appRoute(const EarlyWarningScreen()))),
            _AlertCard(blue, Icons.cloudy_snowing, 'Heavy Rainfall Expected', 'Next 6 hours · 126 mm', () => Navigator.push(context, appRoute(const AiAnalysisScreen()))),
            _AlertCard(orange, Icons.alt_route_rounded, 'Road Closure', 'Araniko Highway · verified 8 min ago', () => Navigator.push(context, appRoute(const SafeRouteScreen()))),
            _AlertCard(green, Icons.home_work_rounded, 'Shelter Capacity Updated', '2 shelters have space nearby', () => Navigator.push(context, appRoute(const ResourcesScreen()))),
          ],
        ),
      );
}

class _AlertCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AlertCard(this.color, this.icon, this.title, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), Text(subtitle, style: const TextStyle(fontSize: 11))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)]),
            ),
          ),
        ),
      );
}

class MoreScreen extends StatelessWidget {
  final UserRole role;
  const MoreScreen({super.key, required this.role});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('More', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 13),
            Glass(child: Row(children: [CircleAvatar(radius: 25, backgroundColor: role.color.withOpacity(.15), child: Icon(role.icon, color: role.color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role.title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), const Text('SIH 2026 demo profile', style: TextStyle(fontSize: 11))]))])),
            const SizedBox(height: 12),
            _MoreItem(Icons.notifications_none_rounded, 'Notifications', 'Critical alerts and preferences', () => Navigator.push(context, appRoute(const AlertsScreen()))),
            _MoreItem(Icons.download_for_offline_outlined, 'Offline Safety Pack', 'Map, shelters and emergency guide', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline safety pack queued')))),
            _MoreItem(Icons.shield_outlined, 'Safety Guidelines', 'Landslide, flood and evacuation steps', () => Navigator.push(context, appRoute(const FamilyScreen()))),
            _MoreItem(Icons.contact_emergency_outlined, 'Emergency Contacts', 'Family and responder contacts', () => Navigator.push(context, appRoute(const FamilyScreen()))),
            _MoreItem(Icons.smart_toy_outlined, 'AI Safety Assistant', 'Ask what to do right now', () => Navigator.push(context, appRoute(const AssistantScreen()))),
            _MoreItem(Icons.swap_horiz_rounded, 'Switch Role', 'Citizen, rescue, authority and more', () => Navigator.pushAndRemoveUntil(context, appRoute(const RolePicker()), (_) => false)),
          ],
        ),
      );
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MoreItem(this.icon, this.title, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            leading: Icon(icon, color: navy),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink, fontSize: 13)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTap,
          ),
        ),
      );
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String type = 'Landslide';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Report Incident')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [Image.asset('assets/images/monitoring_mountain.jpg', height: 190, width: double.infinity, fit: BoxFit.cover), Positioned.fill(child: Container(color: navy.withOpacity(.14))), const Positioned(left: 14, bottom: 12, child: Text('Add incident photo or video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))) ])),
            const SizedBox(height: 12),
            Glass(child: const Row(children: [Icon(Icons.location_on_outlined), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Location (Auto-detected)', style: TextStyle(fontSize: 10)), Text('Sindhupalchok, Nepal', style: TextStyle(fontWeight: FontWeight.w900, color: ink))]))])),
            const SizedBox(height: 14),
            const Text('Incident Type', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: ['Landslide','Flood','Road Block','Other'].map((e) => ChoiceChip(label: Text(e), selected: type == e, onSelected: (_) => setState(() => type = e))).toList()),
            const SizedBox(height: 12),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: 'Add description and visible warning signs', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 13),
            FilledButton(style: FilledButton.styleFrom(padding: const EdgeInsets.all(15)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted for AI + community verification'))), child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w900))),
          ],
        ),
      );
}

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Relief & Resources')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _ResourceCard(Icons.home_work_rounded, 'Melamchi Community Shelter', '2.1 km · 250 capacity', ['Food','Water','Medical']),
            _ResourceCard(Icons.school_rounded, 'Govt. School Shelter', '4.8 km · 180 capacity', ['Food','Medical']),
            _ResourceCard(Icons.temple_buddhist_rounded, 'Monastery Relief Camp', '6.3 km · 300 capacity', ['Food','Water','Power']),
            _ResourceCard(Icons.local_hospital_rounded, 'District Hospital', '7.5 km · 24×7 Emergency', ['Medical','Ambulance']),
          ],
        ),
      );
}

class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> tags;
  const _ResourceCard(this.icon, this.title, this.subtitle, this.tags);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Glass(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: green.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: green)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), Text(subtitle, style: const TextStyle(fontSize: 11)), const SizedBox(height: 6), Wrap(spacing: 5, children: tags.map((e) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: blue.withOpacity(.10), borderRadius: BorderRadius.circular(7)), child: Text(e, style: const TextStyle(color: blue, fontSize: 9, fontWeight: FontWeight.w800)))).toList())])),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ]),
        ),
      );
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final input = TextEditingController();
  final messages = <String>[];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AI Safety Assistant')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(Icons.smart_toy_rounded, color: blue, size: 66),
                  const Center(child: Text('How can I help you?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: ink))),
                  const SizedBox(height: 16),
                  ...['What is the current risk near me?','Show the safest route','Nearest open shelter','What signs of slope failure should I watch?'].map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.auto_awesome_rounded, color: blue, size: 19), title: Text(e, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => setState(() => messages.add(e))))),
                  ...messages.map((m) => Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFDDF7FA), borderRadius: BorderRadius.circular(13)), child: Text(m, style: const TextStyle(fontSize: 12)))),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: input,
                  decoration: InputDecoration(
                    hintText: 'Ask JeevanSetu…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    suffixIcon: IconButton(icon: const Icon(Icons.send_rounded, color: cyan), onPressed: () { if (input.text.trim().isNotEmpty) { setState(() => messages.add(input.text.trim())); input.clear(); } }),
                  ),
                ),
              ),
            )
          ],
        ),
      );
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Personal Safety')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _FamilyCard('You', 'Safe · live location', green),
            _FamilyCard('Mother', 'Safe · checked in 2 min ago', green),
            _FamilyCard('Father', 'Last seen 1 hour ago', orange),
            _FamilyCard('Sister', 'Location unavailable', red),
          ],
        ),
      );
}

class _FamilyCard extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  const _FamilyCard(this.name, this.status, this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Glass(child: Row(children: [CircleAvatar(backgroundColor: color.withOpacity(.14), child: Icon(Icons.person_rounded, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: ink)), Text(status, style: TextStyle(color: color, fontSize: 11))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])),
      );
}

class RoleOpsScreen extends StatelessWidget {
  final UserRole role;
  const RoleOpsScreen({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    final items = switch (role) {
      UserRole.citizen => [('Family check-in','4 people',Icons.groups_rounded,green),('Safe shelters','18 live',Icons.home_work_rounded,blue),('My reports','3 verified',Icons.verified_rounded,purple)],
      UserRole.rescue => [('Critical missions','1',Icons.emergency_rounded,red),('People awaiting rescue','11',Icons.groups_rounded,orange),('Units available','7',Icons.health_and_safety_rounded,green)],
      UserRole.authority => [('Active risk zones','4',Icons.radar_rounded,red),('Reports awaiting verification','12',Icons.fact_check_rounded,orange),('Road closures','3',Icons.alt_route_rounded,blue)],
      UserRole.volunteer => [('Verified missions','2',Icons.volunteer_activism_rounded,purple),('People supported','34',Icons.groups_rounded,green),('Supply runs','4',Icons.inventory_2_rounded,orange)],
      UserRole.organization => [('Shelter occupancy','73%',Icons.home_work_rounded,blue),('Medical kits required','40',Icons.medical_services_rounded,red),('Supply vehicles','6',Icons.local_shipping_rounded,green)],
    };
    return Scaffold(
      appBar: AppBar(title: Text('${role.title} Operations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [role.color, role.color.withOpacity(.72)]), borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(role.icon, color: Colors.white, size: 34), const SizedBox(height: 13), Text(role.title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)), Text(role.subtitle, style: const TextStyle(color: Colors.white70))]),
          ),
          const SizedBox(height: 14),
          ...items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Glass(child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: i.$4.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(i.$3, color: i.$4)), const SizedBox(width: 11), Expanded(child: Text(i.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: ink))), Text(i.$2, style: TextStyle(color: i.$4, fontWeight: FontWeight.w900))])))),
          const SizedBox(height: 5),
          FilledButton(onPressed: () => Navigator.push(context, appRoute(const RiskMapScreen())), child: const Text('Open Live Command Map')),
        ],
      ),
    );
  }
}
