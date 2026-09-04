import 'package:flutter/material.dart';

import 'model.dart';
import 'screens.dart';

void runBeastApp() {
  runApp(const JeevanSetuApp());
}

class JeevanSetuApp extends StatefulWidget {
  const JeevanSetuApp({super.key});

  @override
  State<JeevanSetuApp> createState() => _JeevanSetuAppState();
}

class _JeevanSetuAppState extends State<JeevanSetuApp> {
  final AppModel model = AppModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, child) {
        return AppScope(
          model: model,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'JeevanSetu',
            themeMode: model.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? const Color(0xFF061B23) : const Color(0xFFF3F8FA);
  final surface = dark ? const Color(0xFF102A34) : Colors.white;
  final ink = dark ? Colors.white : const Color(0xFF102027);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kCyan,
      brightness: brightness,
      primary: kCyan,
      surface: surface,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: background,
      surfaceTintColor: background,
      foregroundColor: ink,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: ink.withValues(alpha: .14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: ink.withValues(alpha: .12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kCyan, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 74,
      backgroundColor: surface,
      indicatorColor: kCyan.withValues(alpha: .18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
          color: states.contains(WidgetState.selected) ? kCyan : ink.withValues(alpha: .65),
        );
      }),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: ink, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(color: ink, fontWeight: FontWeight.w900),
      titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w900),
      titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(color: ink.withValues(alpha: .86)),
      bodyMedium: TextStyle(color: ink.withValues(alpha: .68)),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> fade;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    scale = Tween<double>(begin: .70, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
    fade = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    Future<void>.delayed(const Duration(milliseconds: 1550), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/hero_mountain.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x553A6778), Color(0xF0032A35)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 126,
                          height: 126,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'JeevanSetu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'From alert to action — together',
                        style: TextStyle(color: Colors.white70, fontSize: 17),
                      ),
                    ],
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int index = 0;

  final List<_IntroData> pages = const [
    _IntroData(
      image: 'assets/images/hero_mountain.jpg',
      tag: 'PREDICT',
      title: 'Safer communities\nwith smarter monitoring',
      subtitle: 'AI-assisted landslide intelligence combines rainfall, soil saturation, terrain and community evidence for earlier warning.',
    ),
    _IntroData(
      image: 'assets/images/monitoring_mountain.jpg',
      tag: 'UNDERSTAND',
      title: 'Real-time risk\nintelligence',
      subtitle: 'Live Nepal maps, explainable risk scoring, sensors and verified incident evidence in one operational view.',
    ),
    _IntroData(
      image: 'assets/images/rescue_diver.jpg',
      tag: 'RESPOND',
      title: 'Report · Respond\n· Recover',
      subtitle: 'Citizens, rescuers, authorities, volunteers and organizations share one coordinated incident network.',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            onPageChanged: (value) => setState(() => index = value),
            itemBuilder: (context, pageIndex) {
              final data = pages[pageIndex];
              return _IntroPage(data: data);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _GlassButton(
                          icon: Icons.translate_rounded,
                          label: _languageLabel(model.language),
                          onTap: () => _showLanguage(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GlassButton(
                          icon: model.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          label: model.darkMode ? 'Dark' : 'Light',
                          onTap: () => model.setDarkMode(!model.darkMode),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '${index + 1} / ${pages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      for (int i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == index ? 34 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == index ? kCyan : Colors.white38,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          model.tr('skip'),
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kCyan,
                          foregroundColor: kDeep,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          minimumSize: const Size(58, 56),
                        ),
                        onPressed: () {
                          if (index == pages.length - 1) {
                            _finish();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 340),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        child: Icon(index == pages.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectScreen()),
    );
  }

  void _showLanguage(BuildContext context) {
    final model = AppScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  model.setLanguage(AppLanguage.english);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('हिन्दी'),
                onTap: () {
                  model.setLanguage(AppLanguage.hindi);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('नेपाली'),
                onTap: () {
                  model.setLanguage(AppLanguage.nepali);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IntroData {
  const _IntroData({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
  });
  final String image;
  final String tag;
  final String title;
  final String subtitle;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.data});
  final _IntroData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(data.image, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [.1, .55, 1],
              colors: [Color(0x33031E27), Color(0x65031E27), Color(0xF2032833)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 130, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(99),
                    color: kDeep.withValues(alpha: .34),
                  ),
                  child: Text(
                    data.tag,
                    style: const TextStyle(
                      color: kCyan,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 39,
                    fontWeight: FontWeight.w900,
                    height: .98,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
          color: kDeep.withValues(alpha: .65),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/monitoring_mountain.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: kDeep.withValues(alpha: .90)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset('assets/app_icon.png', width: 64, height: 64),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JeevanSetu',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                          ),
                          Text(
                            model.tr('connected'),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Text(
                  model.tr('chooseRole'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Every role has a different operational workspace, but the same incident ID and live status move across the whole network.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 24),
                for (final role in UserRole.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RoleCard(role: role),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.translate_rounded,
                        label: _languageLabel(model.language),
                        onTap: () => _roleLanguageSheet(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GlassButton(
                        icon: model.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        label: model.darkMode ? 'Dark' : 'Light',
                        onTap: () => model.setDarkMode(!model.darkMode),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _roleLanguageSheet(BuildContext context) {
    final model = AppScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                model.setLanguage(AppLanguage.english);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('हिन्दी'),
              onTap: () {
                model.setLanguage(AppLanguage.hindi);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('नेपाली'),
              onTap: () {
                model.setLanguage(AppLanguage.nepali);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RoleShell(role: role)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [role.color, role.color.withValues(alpha: .72)],
          ),
          boxShadow: [
            BoxShadow(
              color: role.color.withValues(alpha: .22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(role.icon, color: role.color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.roleName(role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _roleSubtitle(role),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  String _roleSubtitle(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'Report, receive alerts, track help and navigate to safety';
      case UserRole.rescue:
        return 'Triage, dispatch, navigate, rescue and hand off';
      case UserRole.authority:
        return 'Verify evidence, command response and broadcast warnings';
      case UserRole.volunteer:
        return 'Accept field tasks, support evacuation and supply missions';
      case UserRole.organization:
        return 'Manage shelters, medical aid, inventory and logistics';
    }
  }
}

String _languageLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.english:
      return 'English';
    case AppLanguage.hindi:
      return 'हिन्दी';
    case AppLanguage.nepali:
      return 'नेपाली';
  }
}
