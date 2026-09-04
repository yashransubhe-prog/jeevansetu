import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import 'app.dart' show LogoMark;

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

const mountainImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1200';
const riskImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas.jpg?width=1200';
const rescueImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=1200';

class JudgeJeevanSetuApp extends StatefulWidget {
  const JudgeJeevanSetuApp({super.key});

  @override
  State<JudgeJeevanSetuApp> createState() => _JudgeJeevanSetuAppState();
}

class _JudgeJeevanSetuAppState extends State<JudgeJeevanSetuApp> {
  ThemeMode mode = ThemeMode.light;
  AppLanguage language = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return AppPreferences(
      mode: mode,
      language: language,
      setMode: (value) => setState(() => mode = value),
      setLanguage: (value) => setState(() => language = value),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JeevanSetu',
        themeMode: mode,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: cyan,
            primary: cyan,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: bg,
            surfaceTintColor: bg,
            foregroundColor: ink,
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 72,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDDF6F9),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w900
                    : FontWeight.w700,
                color: states.contains(WidgetState.selected)
                    ? navy
                    : const Color(0xFF63757A),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF071D24),
          colorScheme: ColorScheme.fromSeed(
            seedColor: cyan,
            brightness: Brightness.dark,
            surface: const Color(0xFF102A33),
          ),
        ),
        home: const FoundationSplash(),
      ),
    );
  }
}

enum AppLanguage { english, hindi, nepali }

extension AppLanguageInfo on AppLanguage {
  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.hindi => 'हिन्दी',
        AppLanguage.nepali => 'नेपाली',
      };
}

class AppPreferences extends InheritedWidget {
  final ThemeMode mode;
  final AppLanguage language;
  final ValueChanged<ThemeMode> setMode;
  final ValueChanged<AppLanguage> setLanguage;

  const AppPreferences({
    super.key,
    required this.mode,
    required this.language,
    required this.setMode,
    required this.setLanguage,
    required super.child,
  });

  static AppPreferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppPreferences>()!;
  }

  @override
  bool updateShouldNotify(AppPreferences oldWidget) {
    return mode != oldWidget.mode || language != oldWidget.language;
  }
}

String tr(BuildContext context, String en, String hi, String ne) {
  return switch (AppPreferences.of(context).language) {
    AppLanguage.english => en,
    AppLanguage.hindi => hi,
    AppLanguage.nepali => ne,
  };
}

Route<T> premiumRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: page,
    ),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(.025, .01),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return SlideTransition(position: slide, child: child);
    },
  );
}

class FastPhoto extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const FastPhoto(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final physicalWidth =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(720, 1440);
    return Image(
      image: ResizeImage(NetworkImage(url), width: physicalWidth),
      fit: fit,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, synchronous) {
        if (synchronous || frame != null) return child;
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF176579), deepNavy],
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF176579), deepNavy],
          ),
        ),
      ),
    );
  }
}

class PhotoBackdrop extends StatelessWidget {
  final String url;
  final double darkness;
  final Widget child;

  const PhotoBackdrop({
    super.key,
    required this.url,
    required this.child,
    this.darkness = .28,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FastPhoto(url),
          Container(color: Colors.black.withValues(alpha: darkness)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x08000000),
                  Color(0x20032833),
                  Color(0xF3032833),
                ],
                stops: [.1, .52, 1],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class FoundationSplash extends StatefulWidget {
  const FoundationSplash({super.key});

  @override
  State<FoundationSplash> createState() => _FoundationSplashState();
}

class _FoundationSplashState extends State<FoundationSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController sequence;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sequence = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    )..forward();
    timer = Timer(const Duration(milliseconds: 3250), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          premiumRoute(const FoundationOnboarding()),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    sequence.dispose();
    super.dispose();
  }

  double interval(double start, double end) {
    return CurvedAnimation(
      parent: sequence,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ).value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: PhotoBackdrop(
        url: mountainImage,
        darkness: .46,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: sequence,
            builder: (_, __) {
              final logo = interval(.03, .35);
              final name = interval(.36, .64);
              final tag = interval(.62, .82);
              return Padding(
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    Opacity(
                      opacity: logo,
                      child: Transform.scale(
                        scale: .62 +
                            .38 *
                                Curves.easeOutBack.transform(
                                  logo.clamp(0, .999),
                                ),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .04),
                            border: Border.all(
                              color: aqua.withValues(alpha: .25),
                            ),
                          ),
                          child: const LogoMark(size: 104),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: name,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'JeevanSetu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Opacity(
                      opacity: tag,
                      child: const Text(
                        'Disaster Monitoring & Response',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    Opacity(
                      opacity: tag,
                      child: Column(
                        children: [
                          const Text(
                            'Preparing live risk intelligence',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: tag,
                              minHeight: 5,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FoundationOnboarding extends StatefulWidget {
  const FoundationOnboarding({super.key});

  @override
  State<FoundationOnboarding> createState() => _FoundationOnboardingState();
}

class _FoundationOnboardingState extends State<FoundationOnboarding> {
  final controller = PageController();
  int index = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (index < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 330),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.push(context, premiumRoute(const PremiumRolePicker()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (
        tr(
          context,
          'Safer Communities\nwith Smarter Monitoring',
          'स्मार्ट निगरानी से\nसुरक्षित समुदाय',
          'स्मार्ट निगरानीसँग\nसुरक्षित समुदाय',
        ),
        tr(
          context,
          'AI-powered landslide intelligence combines rainfall, soil saturation, terrain and community evidence for earlier warning.',
          'AI आधारित भूस्खलन प्रणाली बारिश, मिट्टी की नमी, भू-ढलान और सामुदायिक संकेतों को जोड़कर जल्दी चेतावनी देती है।',
          'AI आधारित पहिरो प्रणालीले वर्षा, माटोको चिस्यान, भू-ढलान र सामुदायिक संकेत मिलाएर छिटो चेतावनी दिन्छ।',
        ),
        mountainImage,
        'PREDICT',
      ),
      (
        tr(
          context,
          'Real-Time Risk\nIntelligence',
          'रियल-टाइम जोखिम\nइंटेलिजेंस',
          'रियल-टाइम जोखिम\nजानकारी',
        ),
        tr(
          context,
          'Live Nepal maps, explainable AI scoring, safe-route intelligence, sensors and verified alerts in one operational view.',
          'लाइव नेपाल मैप, समझने योग्य AI स्कोर, सुरक्षित मार्ग, सेंसर और सत्यापित अलर्ट एक ही जगह।',
          'लाइभ नेपाल नक्सा, बुझिने AI स्कोर, सुरक्षित मार्ग, सेन्सर र प्रमाणित सूचना एउटै स्थानमा।',
        ),
        riskImage,
        'UNDERSTAND',
      ),
      (
        tr(
          context,
          'Report · Respond\n· Stay Safe',
          'रिपोर्ट · रिस्पॉन्ड\n· सुरक्षित रहें',
          'रिपोर्ट · प्रतिक्रिया\n· सुरक्षित रहनुहोस्',
        ),
        tr(
          context,
          'Citizens, rescuers, authorities, volunteers and organisations share one coordinated response network when minutes matter.',
          'नागरिक, बचाव दल, अधिकारी, स्वयंसेवक और संगठन एक ही समन्वित प्रतिक्रिया नेटवर्क में जुड़े रहते हैं।',
          'नागरिक, उद्धार टोली, अधिकारी, स्वयंसेवक र संस्था एउटै समन्वित प्रतिक्रिया सञ्जालमा जोडिन्छन्।',
        ),
        rescueImage,
        'RESPOND',
      ),
    ];
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: (value) => setState(() => index = value),
            itemBuilder: (_, i) {
              final slide = slides[i];
              return PhotoBackdrop(
                url: slide.$3,
                darkness: i == 2 ? .37 : .27,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 92, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Pill(label: slide.$4, color: aqua, dark: true),
                        const SizedBox(height: 13),
                        Text(
                          slide.$1,
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1.03,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.8,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          slide.$2,
                          maxLines: 5,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13.8,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Text(
                              '${i + 1} / 3',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ...List.generate(
                              3,
                              (dot) => AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 5),
                                width: dot == i ? 24 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: dot == i ? aqua : Colors.white30,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                premiumRoute(const PremiumRolePicker()),
                              ),
                              child: Text(
                                tr(context, 'Skip', 'स्किप', 'छोड्नुहोस्'),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: FloatingActionButton.small(
                                heroTag: 'intro-$i',
                                elevation: 0,
                                backgroundColor: aqua,
                                foregroundColor: navy,
                                onPressed: next,
                                child: Icon(
                                  i == 2
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 26,
                                ),
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
          Positioned(
            top: safeTop + 12,
            left: 16,
            right: 16,
            child: const FoundationControls(),
          ),
        ],
      ),
    );
  }
}

class FoundationControls extends StatelessWidget {
  const FoundationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = AppPreferences.of(context);
    final dark = pref.mode == ThemeMode.dark;
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<AppLanguage>(
            color: const Color(0xFF0B3541),
            initialValue: pref.language,
            onSelected: pref.setLanguage,
            itemBuilder: (_) => AppLanguage.values
                .map(
                  (language) => PopupMenuItem<AppLanguage>(
                    value: language,
                    child: Text(
                      language.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            child: GlassControl(
              child: Row(
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pref.language.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: GestureDetector(
            onTap: () => pref.setMode(
              dark ? ThemeMode.light : ThemeMode.dark,
            ),
            child: GlassControl(
              child: Row(
                children: [
                  Icon(
                    dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dark ? 'Dark' : 'Light',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GlassControl extends StatelessWidget {
  final Widget child;
  const GlassControl({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: deepNavy.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}

enum ExperienceRole { citizen, rescue, authority, volunteer, organization }

extension ExperienceRoleInfo on ExperienceRole {
  String get title => switch (this) {
        ExperienceRole.citizen => 'Citizen',
        ExperienceRole.rescue => 'Rescue Team',
        ExperienceRole.authority => 'Authority',
        ExperienceRole.volunteer => 'Volunteer',
        ExperienceRole.organization => 'Organization',
      };

  String get subtitle => switch (this) {
        ExperienceRole.citizen =>
          'Report, receive alerts, navigate to safety',
        ExperienceRole.rescue =>
          'Dispatch, triage and coordinate field missions',
        ExperienceRole.authority =>
          'Monitor, verify, broadcast and command',
        ExperienceRole.volunteer =>
          'Support camps, check-ins and supply missions',
        ExperienceRole.organization =>
          'Offer shelters, inventory and logistics',
      };

  Color get color => switch (this) {
        ExperienceRole.citizen => green,
        ExperienceRole.rescue => red,
        ExperienceRole.authority => blue,
        ExperienceRole.volunteer => purple,
        ExperienceRole.organization => orange,
      };

  IconData get icon => switch (this) {
        ExperienceRole.citizen => Icons.person_rounded,
        ExperienceRole.rescue => Icons.health_and_safety_rounded,
        ExperienceRole.authority => Icons.account_balance_rounded,
        ExperienceRole.volunteer => Icons.volunteer_activism_rounded,
        ExperienceRole.organization => Icons.business_center_rounded,
      };
}

class PremiumRolePicker extends StatelessWidget {
  const PremiumRolePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select your role to open a purpose-built response experience.',
              style: TextStyle(color: Colors.white60, fontSize: 12.5),
            ),
            const SizedBox(height: 22),
            ...ExperienceRole.values.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      premiumRoute(RoleLogin(role: role)),
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
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: role.color.withValues(alpha: .18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .93),
                              borderRadius: BorderRadius.circular(15),
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
                                    fontSize: 17,
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
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                          ),
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
    );
  }
}

class RoleLogin extends StatefulWidget {
  final ExperienceRole role;
  const RoleLogin({super.key, required this.role});

  @override
  State<RoleLogin> createState() => _RoleLoginState();
}

class _RoleLoginState extends State<RoleLogin> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void enter() {
    Navigator.pushReplacement(
      context,
      premiumRoute(RoleExperienceShell(role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return Scaffold(
      backgroundColor: deepNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  children: [
                    const LogoMark(size: 78),
                    const SizedBox(height: 7),
                    const Text(
                      'JeevanSetu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Pill(
                      label: '${role.title} access',
                      color: role.color,
                      dark: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 24),
              LoginField(
                controller: email,
                icon: Icons.person_outline_rounded,
                hint: 'Email or Phone',
              ),
              const SizedBox(height: 12),
              LoginField(
                controller: password,
                icon: Icons.lock_outline_rounded,
                hint: 'Password',
                obscure: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: role.color,
                  ),
                  onPressed: enter,
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
                  onPressed: enter,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Use SIH demo access'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;

  const LoginField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .09),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: aqua),
        ),
      ),
    );
  }
}

class RoleExperienceShell extends StatefulWidget {
  final ExperienceRole role;
  const RoleExperienceShell({super.key, required this.role});

  @override
  State<RoleExperienceShell> createState() => _RoleExperienceShellState();
}

class _RoleExperienceShellState extends State<RoleExperienceShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.role == ExperienceRole.citizen) {
      final pages = <Widget>[
        const CitizenHome(),
        const LiveRiskMap(),
        const CitizenSos(),
        const RichAlerts(),
        const CitizenMore(),
      ];
      return RoleNavigation(
        index: index,
        onChanged: (value) => setState(() => index = value),
        pages: pages,
        labels: const ['Home', 'Map', 'SOS', 'Alerts', 'More'],
        icons: const [
          Icons.home_rounded,
          Icons.map_rounded,
          Icons.sos_rounded,
          Icons.notifications_rounded,
          Icons.grid_view_rounded,
        ],
        accent: green,
      );
    }

    final config = RoleConfig.forRole(widget.role);
    final pages = <Widget>[
      ProfessionalRoleHome(role: widget.role, config: config),
      ProfessionalRoleOperations(role: widget.role, config: config),
      RoleCommunications(role: widget.role, config: config),
      ProfessionalRoleIntelligence(role: widget.role, config: config),
      ProfessionalRoleToolkit(role: widget.role, config: config),
    ];
    return RoleNavigation(
      index: index,
      onChanged: (value) => setState(() => index = value),
      pages: pages,
      labels: config.tabs,
      icons: config.icons,
      accent: config.accent,
      dark: config.dark,
    );
  }
}

class RoleNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<Widget> pages;
  final List<String> labels;
  final List<IconData> icons;
  final Color accent;
  final bool dark;

  const RoleNavigation({
    super.key,
    required this.index,
    required this.onChanged,
    required this.pages,
    required this.labels,
    required this.icons,
    required this.accent,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF06151B) : bg,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onChanged,
        backgroundColor: dark ? const Color(0xFF0A222B) : Colors.white,
        indicatorColor: accent.withValues(alpha: dark ? .24 : .14),
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i]),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}

class CitizenHome extends StatelessWidget {
  const CitizenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: CitizenHero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList.list(
              children: [
                TapCard(
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(const RiskAnalysisScreen()),
                  ),
                  child: const WarningCard(),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.cloudy_snowing,
                        color: blue,
                        value: '12°C',
                        label: 'Heavy rain',
                      ),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.water_drop_rounded,
                        color: cyan,
                        value: '87%',
                        label: 'Soil saturation',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'Safety tools',
                  subtitle: 'Live, actionable and one tap away',
                ),
                const SizedBox(height: 10),
                const CitizenTools(),
                const SizedBox(height: 20),
                TapCard(
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(const PersonalSafetyPage()),
                  ),
                  child: const GradientFeature(
                    icon: Icons.family_restroom_rounded,
                    title: 'Personal Safety',
                    subtitle:
                        '4 family members · 3 safe · 1 awaiting check-in',
                    colors: [navy, Color(0xFF0A866D)],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'AI Slope Sentinel',
                  subtitle: 'Explainable risk, not a black box',
                ),
                const SizedBox(height: 10),
                TapCard(
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(const RiskAnalysisScreen()),
                  ),
                  child: const SurfaceCard(
                    child: Row(
                      children: [
                        MiniGauge(),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'High landslide probability',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rainfall + soil saturation + slope geometry are driving the score.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10.5,
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'WHY THIS SCORE  →',
                                style: TextStyle(
                                  color: blue,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'Community pulse',
                  subtitle: 'Verified signals around you',
                ),
                const SizedBox(height: 10),
                const SurfaceCard(
                  child: Column(
                    children: [
                      SignalRow(
                        icon: Icons.landscape_rounded,
                        color: red,
                        title: 'Slope movement reported',
                        subtitle: 'Sindhupalchok · 2.4 km · AI verified',
                        badge: '92%',
                      ),
                      Divider(height: 24),
                      SignalRow(
                        icon: Icons.route_rounded,
                        color: orange,
                        title: 'Road partially blocked',
                        subtitle: 'Araniko Highway · 4.1 km',
                        badge: '3 reports',
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

class CitizenHero extends StatelessWidget {
  const CitizenHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FastPhoto(mountainImage),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x40102A33), Color(0xF2073C4D)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste,',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Citizen',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const GlassIcon(icon: Icons.notifications_active_rounded),
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
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Know the slope\nbefore it moves.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
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

class GlassIcon extends StatelessWidget {
  final IconData icon;
  const GlassIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const HeroStat(this.label, this.value, this.color, {super.key});

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
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WarningCard extends StatelessWidget {
  const WarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF3150), Color(0xFFF05662)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: red.withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0x22FFFFFF),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Landslide Risk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Potential slope failure within 12 hours. A safer evacuation corridor is ready.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.2,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'OPEN EARLY WARNING  →',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
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

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const MetricCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.black45,
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

class CitizenTools extends StatelessWidget {
  const CitizenTools({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <ToolItem>[
      const ToolItem(
        Icons.map_rounded,
        'Live Risk\nMap',
        green,
        LiveRiskMap(),
      ),
      const ToolItem(
        Icons.route_rounded,
        'Safe\nRoute',
        cyan,
        SafeRoutePage(),
      ),
      const ToolItem(
        Icons.psychology_alt_rounded,
        'AI Risk\nAnalysis',
        blue,
        RiskAnalysisScreen(),
      ),
      const ToolItem(
        Icons.post_add_rounded,
        'Report\nIncident',
        orange,
        IncidentReportPage(),
      ),
      const ToolItem(
        Icons.inventory_2_rounded,
        'Relief &\nResources',
        green,
        ResourcesPage(),
      ),
      const ToolItem(
        Icons.smart_toy_rounded,
        'AI Safety\nAssistant',
        purple,
        SafetyAssistantPage(),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 1.04,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(context, premiumRoute(item.page)),
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
                      color: item.color.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
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

class ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;
  const ToolItem(this.icon, this.label, this.color, this.page);
}

class GradientFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;

  const GradientFeature({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: aqua),
        ],
      ),
    );
  }
}

class MiniGauge extends StatelessWidget {
  const MiniGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: .78,
              strokeWidth: 8,
              color: red,
              backgroundColor: Color(0xFFFFE3E8),
            ),
          ),
          const Text(
            '78%',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class SignalRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;

  const SignalRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
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
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 9.2,
                ),
              ),
            ],
          ),
        ),
        Pill(label: badge, color: color),
      ],
    );
  }
}

class LiveRiskMap extends StatefulWidget {
  const LiveRiskMap({super.key});

  @override
  State<LiveRiskMap> createState() => _LiveRiskMapState();
}

class _LiveRiskMapState extends State<LiveRiskMap> {
  bool forecast = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Risk Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Pill(label: '●  LIVE MAP', color: green),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: SegmentButton(
                        label: 'Live',
                        active: !forecast,
                        onTap: () => setState(() => forecast = false),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: SegmentButton(
                        label: 'Next 48 Hours',
                        active: forecast,
                        onTap: () => setState(() => forecast = true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(27.72, 85.4),
                initialZoom: 6.9,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.jeevansetu.app',
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: const [
                        LatLng(27.72, 85.25),
                        LatLng(27.91, 85.38),
                        LatLng(27.82, 85.65),
                        LatLng(27.62, 85.55),
                      ],
                      color: red.withValues(alpha: .2),
                      borderColor: red,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: const [
                    RiskMarker(LatLng(27.82, 85.55), red),
                    RiskMarker(LatLng(27.71, 85.32), orange),
                    RiskMarker(LatLng(28.20, 83.98), orange),
                    RiskMarker(LatLng(27.52, 84.35), green),
                  ].map((item) => item.marker).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiskMarker {
  final LatLng point;
  final Color color;
  const RiskMarker(this.point, this.color);

  Marker get marker => Marker(
        point: point,
        width: 50,
        height: 50,
        child: Icon(Icons.location_on_rounded, color: color, size: 42),
      );
}

class SegmentButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const SegmentButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? navy : const Color(0xFFE6EDF0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CitizenSos extends StatefulWidget {
  const CitizenSos({super.key});

  @override
  State<CitizenSos> createState() => _CitizenSosState();
}

class _CitizenSosState extends State<CitizenSos>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  int people = 2;
  bool medical = false;
  bool liveLocation = true;
  bool evidence = false;
  String emergency = 'Landslide / trapped';

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

  void send() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SosTrackingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'SOS Emergency',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Pill(label: 'GPS LOCKED', color: green),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: navy.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.near_me_rounded, color: navy, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sindhupalchok · 27.829°N, 85.548°E',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '± 8 m',
                  style: TextStyle(
                    color: green,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, __) {
                return GestureDetector(
                  onLongPress: send,
                  child: Container(
                    width: 196 + pulse.value * 12,
                    height: 196 + pulse.value * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: red.withValues(alpha: .08),
                      boxShadow: [
                        BoxShadow(
                          color: red.withValues(alpha: .15),
                          blurRadius: 34,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 146,
                      height: 146,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF5267), red],
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sos_rounded, color: Colors.white, size: 48),
                          Text(
                            'PRESS & HOLD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MiniAction(
                  icon: Icons.call_rounded,
                  label: 'Emergency call',
                  color: red,
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'District Rescue Desk',
                        video: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniAction(
                  icon: Icons.videocam_rounded,
                  label: 'Video assist',
                  color: blue,
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Medical Response Team',
                        video: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.crisis_alert_rounded, color: navy),
                  title: const Text(
                    'Type of Emergency',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(emergency),
                  trailing: const Icon(Icons.swap_horiz_rounded),
                  onTap: () => setState(() {
                    emergency = emergency == 'Landslide / trapped'
                        ? 'Flood / stranded'
                        : 'Landslide / trapped';
                  }),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.groups_rounded, color: navy),
                  title: const Text(
                    'Number of People',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text('$people people'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => setState(
                          () => people = math.max(1, people - 1),
                        ),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      IconButton(
                        onPressed: () => setState(() => people++),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.medical_services_rounded,
                    color: navy,
                  ),
                  title: const Text(
                    'Medical Assistance',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('Prioritises nearest medical unit'),
                  value: medical,
                  onChanged: (value) => setState(() => medical = value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    evidence ? Icons.verified_rounded : Icons.add_a_photo_rounded,
                    color: evidence ? green : navy,
                  ),
                  title: Text(
                    evidence ? 'Evidence attached' : 'Photo / Video Evidence',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    evidence
                        ? '1 image · encrypted with SOS packet'
                        : 'Tap to attach a scene snapshot',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => setState(() => evidence = !evidence),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.location_on_rounded, color: navy),
                  title: const Text(
                    'Share live location',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text('Updates responder map every 10 seconds'),
                  value: liveLocation,
                  onChanged: (value) => setState(() => liveLocation = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: red),
              onPressed: send,
              child: const Text(
                'Send Emergency Request',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SosTrackingSheet extends StatefulWidget {
  const SosTrackingSheet({super.key});

  @override
  State<SosTrackingSheet> createState() => _SosTrackingSheetState();
}

class _SosTrackingSheetState extends State<SosTrackingSheet> {
  int eta = 11;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && eta > 7) setState(() => eta--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE5F9F1),
                child: Icon(Icons.check_rounded, color: green),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOS accepted by Rescue Unit 04',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [deepNavy, navy]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emergency_share_rounded,
                  color: aqua,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Responder en route',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '$eta min ETA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const LiveBadge(label: 'LIVE'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const TimelineItem(
            done: true,
            title: 'SOS packet transmitted',
            subtitle: 'Location + risk context + medical priority',
          ),
          const TimelineItem(
            done: true,
            title: 'Dispatch acknowledged',
            subtitle: 'Unit 04 · 3 responders',
          ),
          const TimelineItem(
            done: false,
            title: 'Rescue team approaching',
            subtitle: 'Live location channel active',
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Rescue Unit 04',
                        video: false,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Voice'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Rescue Unit 04',
                        video: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final bool done;
  final String title;
  final String subtitle;

  const TimelineItem({
    super.key,
    required this.done,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: done ? green : const Color(0xFFE7EEF0),
            child: Icon(
              done ? Icons.check_rounded : Icons.more_horiz_rounded,
              size: 14,
              color: done ? Colors.white : navy,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 9.5,
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

class RichAlerts extends StatefulWidget {
  const RichAlerts({super.key});

  @override
  State<RichAlerts> createState() => _RichAlertsState();
}

class _RichAlertsState extends State<RichAlerts> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          const Row(
            children: [
              Text(
                'Alerts',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              Pill(label: '3 ACTIVE', color: red),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(4, (i) {
                final text = ['All', 'Critical', 'Weather', 'Mobility'][i];
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    label: Text(text),
                    selected: filter == i,
                    onSelected: (_) => setState(() => filter = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 13),
          TapCard(
            onTap: () => Navigator.push(
              context,
              premiumRoute(const RiskAnalysisScreen()),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 190,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const FastPhoto(riskImage),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xE0072631)],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiveBadge(label: 'CRITICAL · NOW'),
                          Spacer(),
                          Text(
                            'High Landslide Risk',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sindhupalchok · 2.4 km from you',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 11),
                          Row(
                            children: [
                              Icon(Icons.route_rounded, color: aqua, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Safer corridor available',
                                style: TextStyle(
                                  color: aqua,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const RichAlertRow(
            icon: Icons.cloudy_snowing,
            color: blue,
            title: 'Heavy Rainfall Expected',
            subtitle: 'Next 6 hours · 126 mm / 24h',
            signal: 'Weather radar + 4 gauges',
          ),
          const SizedBox(height: 10),
          const RichAlertRow(
            icon: Icons.route_rounded,
            color: orange,
            title: 'Araniko Highway restricted',
            subtitle: 'Partial blockage · 4.1 km away',
            signal: '3 citizen reports verified',
          ),
          const SizedBox(height: 20),
          const SectionTitle(
            title: 'Alert intelligence',
            subtitle: 'Why these alerts reached you',
          ),
          const SizedBox(height: 10),
          const SurfaceCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: green),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Sensor + weather + community evidence agree on elevated slope instability.',
                        style: TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                LinearProgressIndicator(
                  value: .92,
                  minHeight: 8,
                  color: green,
                  backgroundColor: Color(0xFFE6F6F0),
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      'Verification confidence',
                      style: TextStyle(color: Colors.black45, fontSize: 9.5),
                    ),
                    Spacer(),
                    Text(
                      '92%',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w900,
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
}

class RichAlertRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String signal;

  const RichAlertRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  signal,
                  style: TextStyle(
                    color: color,
                    fontSize: 8.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
    );
  }
}

class CitizenMore extends StatelessWidget {
  const CitizenMore({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <MoreItem>[
      const MoreItem(
        Icons.family_restroom_rounded,
        'Personal Safety',
        'Family live status & check-in',
        green,
        PersonalSafetyPage(),
      ),
      const MoreItem(
        Icons.sensors_rounded,
        'Sensor Network',
        'Live rain, soil & slope telemetry',
        blue,
        SensorNetworkPage(),
      ),
      const MoreItem(
        Icons.inventory_2_outlined,
        'Relief & Resources',
        'Camps, hospitals and supplies',
        orange,
        ResourcesPage(),
      ),
      const MoreItem(
        Icons.smart_toy_outlined,
        'AI Assistant',
        'Interactive safety guidance',
        purple,
        SafetyAssistantPage(),
      ),
      const MoreItem(
        Icons.download_for_offline_outlined,
        'Offline Readiness',
        'Emergency pack synced locally',
        cyan,
        OfflineReadinessPage(),
      ),
      const MoreItem(
        Icons.shield_outlined,
        'Safety Guidelines',
        'Action cards for landslide survival',
        red,
        GuidelinesPage(),
      ),
      const MoreItem(
        Icons.contact_emergency_outlined,
        'Emergency Contacts',
        'Voice & video response channels',
        blue,
        ContactCenterPage(),
      ),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          const Text(
            'More',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [deepNavy, navy]),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -20,
                  child: Icon(
                    Icons.public_rounded,
                    size: 150,
                    color: Colors.white.withValues(alpha: .04),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0x3320C98A),
                        child: Icon(
                          Icons.person_rounded,
                          color: green,
                          size: 34,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Citizen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Connected to JeevanSetu response mesh',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(height: 9),
                            LiveBadge(label: 'ONLINE · GPS READY'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    premiumRoute(item.page),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8F0F2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: .09),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              premiumRoute(const PremiumRolePicker()),
              (_) => false,
            ),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Switch profession / role'),
          ),
        ],
      ),
    );
  }
}

class MoreItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;
  const MoreItem(this.icon, this.title, this.subtitle, this.color, this.page);
}

class PersonalSafetyPage extends StatefulWidget {
  const PersonalSafetyPage({super.key});

  @override
  State<PersonalSafetyPage> createState() => _PersonalSafetyPageState();
}

class _PersonalSafetyPageState extends State<PersonalSafetyPage> {
  bool checkedIn = false;
  bool sisterSafe = false;

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Personal Safety',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [navy, Color(0xFF08798A)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: aqua,
                  size: 42,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkedIn
                            ? 'You checked in safely'
                            : 'You are in a monitored zone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        checkedIn
                            ? 'Live status updated just now'
                            : 'Last safety check-in 22 min ago',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: navy,
                  ),
                  onPressed: () => setState(() => checkedIn = true),
                  child: Text(checkedIn ? 'Safe ✓' : 'Check in'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FamilyRow(
            name: 'You',
            status: checkedIn ? 'Safe · just now' : 'Safe · live location',
          ),
          const SizedBox(height: 9),
          const FamilyRow(name: 'Mother', status: 'Safe · 2 min ago'),
          const SizedBox(height: 9),
          const FamilyRow(name: 'Father', status: 'Safe · 18 min ago'),
          const SizedBox(height: 9),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => sisterSafe = true),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (sisterSafe ? green : orange)
                          .withValues(alpha: .12),
                      child: Icon(
                        Icons.person_rounded,
                        color: sisterSafe ? green : orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sister',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            sisterSafe
                                ? 'Safe · confirmed just now'
                                : 'Awaiting check-in · tap to request',
                            style: TextStyle(
                              color: sisterSafe ? green : orange,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      sisterSafe
                          ? Icons.verified_rounded
                          : Icons.notifications_active_rounded,
                      color: sisterSafe ? green : orange,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyRow extends StatelessWidget {
  final String name;
  final String status;

  const FamilyRow({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x2220C98A),
            child: Icon(Icons.person_rounded, color: green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(status, style: const TextStyle(color: green, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
    );
  }
}

class SensorNetworkPage extends StatefulWidget {
  const SensorNetworkPage({super.key});

  @override
  State<SensorNetworkPage> createState() => _SensorNetworkPageState();
}

class _SensorNetworkPageState extends State<SensorNetworkPage> {
  int sync = 14;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => sync = sync == 1 ? 14 : sync - 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Sensor Network',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [navy, blue]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: SensorTop(value: '26/28', label: 'Sensors online'),
                ),
                Container(width: 1, height: 48, color: Colors.white24),
                Expanded(
                  child: SensorTop(value: '$sync sec', label: 'Next sync'),
                ),
                Container(width: 1, height: 48, color: Colors.white24),
                const Expanded(
                  child: SensorTop(value: '96%', label: 'Mesh health'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SensorTile(
            Icons.water_drop_outlined,
            blue,
            'Rain Gauge SG-04',
            '18.4 mm/hr · Rising',
            .82,
          ),
          const SizedBox(height: 10),
          const SensorTile(
            Icons.waves_rounded,
            red,
            'Soil Probe SM-12',
            '87% saturation · Critical',
            .87,
          ),
          const SizedBox(height: 10),
          const SensorTile(
            Icons.straighten_rounded,
            orange,
            'Slope Node IN-07',
            '2.8 mm movement · Watch',
            .62,
          ),
          const SizedBox(height: 10),
          const SensorTile(
            Icons.cloud_outlined,
            green,
            'Weather Station WX-03',
            'Pressure falling · Active',
            .48,
          ),
        ],
      ),
    );
  }
}

class SensorTop extends StatelessWidget {
  final String value;
  final String label;
  const SensorTop({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 8.5),
        ),
      ],
    );
  }
}

class SensorTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double value;

  const SensorTile(
    this.icon,
    this.color,
    this.title,
    this.subtitle,
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}

class OfflineReadinessPage extends StatefulWidget {
  const OfflineReadinessPage({super.key});

  @override
  State<OfflineReadinessPage> createState() => _OfflineReadinessPageState();
}

class _OfflineReadinessPageState extends State<OfflineReadinessPage> {
  bool syncing = false;

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Offline Readiness',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [navy, Color(0xFF098496)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: aqua,
                  child: Icon(Icons.bolt_rounded, color: navy, size: 34),
                ),
                const SizedBox(height: 14),
                Text(
                  syncing
                      ? 'Refreshing emergency pack…'
                      : 'Emergency pack ready offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Risk snapshot, safety guides and verified contacts are stored on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 10.5),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: () {
                    setState(() => syncing = true);
                    Future.delayed(const Duration(milliseconds: 900), () {
                      if (mounted) setState(() => syncing = false);
                    });
                  },
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(syncing ? 'Syncing' : 'Refresh pack'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const OfflineRow(
            Icons.map_rounded,
            'Risk snapshot',
            'Updated 3 min ago',
          ),
          const SizedBox(height: 9),
          const OfflineRow(
            Icons.shield_outlined,
            'Safety guidelines',
            'Available offline',
          ),
          const SizedBox(height: 9),
          const OfflineRow(
            Icons.contact_emergency_outlined,
            'Emergency contacts',
            'Available offline',
          ),
          const SizedBox(height: 9),
          const OfflineRow(
            Icons.route_rounded,
            'Last safe route',
            '6.3 km route cached',
          ),
        ],
      ),
    );
  }
}

class OfflineRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const OfflineRow(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Icon(icon, color: green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: green),
        ],
      ),
    );
  }
}

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Safety Guidelines',
      child: Column(
        children: [
          GuideCard(
            1,
            red,
            'Move away from steep slopes',
            'Do not wait directly below a visibly unstable slope or drainage channel.',
          ),
          SizedBox(height: 10),
          GuideCard(
            2,
            orange,
            'Follow verified evacuation routes',
            'Avoid shortcuts through red zones even when they appear faster.',
          ),
          SizedBox(height: 10),
          GuideCard(
            3,
            blue,
            'Keep an emergency go-bag',
            'Carry water, medicines, light, power bank and identity documents.',
          ),
          SizedBox(height: 10),
          GuideCard(
            4,
            green,
            'Check in with family',
            'Use Personal Safety so responders know who is safe and who needs help.',
          ),
        ],
      ),
    );
  }
}

class GuideCard extends StatelessWidget {
  final int number;
  final Color color;
  final String title;
  final String body;

  const GuideCard(
    this.number,
    this.color,
    this.title,
    this.body, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10.5,
                    height: 1.35,
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

class ContactCenterPage extends StatelessWidget {
  const ContactCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Emergency Contacts',
      child: Column(
        children: [
          ContactRow(
            title: 'National Emergency',
            status: '112',
            color: red,
            onCall: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'National Emergency',
                  video: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          ContactRow(
            title: 'District Response Desk',
            status: '1077',
            color: blue,
            onCall: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'District Response Desk',
                  video: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          ContactRow(
            title: 'Nearest Medical Team',
            status: 'Available',
            color: green,
            video: true,
            onCall: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'Nearest Medical Team',
                  video: false,
                ),
              ),
            ),
            onVideo: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'Nearest Medical Team',
                  video: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          ContactRow(
            title: 'JeevanSetu Command',
            status: 'In-app radio',
            color: purple,
            video: true,
            onCall: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'JeevanSetu Command',
                  video: false,
                ),
              ),
            ),
            onVideo: () => Navigator.push(
              context,
              premiumRoute(
                const InAppCallPage(
                  title: 'JeevanSetu Command',
                  video: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final bool video;
  final VoidCallback onCall;
  final VoidCallback? onVideo;

  const ContactRow({
    super.key,
    required this.title,
    required this.status,
    required this.color,
    required this.onCall,
    this.video = false,
    this.onVideo,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(Icons.call_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          IconButton(
            onPressed: onCall,
            icon: const Icon(Icons.call_outlined),
          ),
          if (video)
            IconButton(
              onPressed: onVideo,
              icon: const Icon(Icons.videocam_outlined),
            ),
        ],
      ),
    );
  }
}

class RiskAnalysisScreen extends StatelessWidget {
  const RiskAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'AI Risk Analysis',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [deepNavy, navy]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                MiniGauge(),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '78% · High probability',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Model confidence 92% · next 12 hours',
                        style: TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                      SizedBox(height: 9),
                      LiveBadge(label: 'UPDATED 14 SEC AGO'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk drivers',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                SizedBox(height: 12),
                RiskDriver('24h rainfall', '126 mm', .86, blue),
                RiskDriver('Soil saturation', '87%', .87, red),
                RiskDriver('Slope movement', '2.8 mm', .64, orange),
                RiskDriver('Community evidence', '5 reports', .72, purple),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What the AI is seeing',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                SizedBox(height: 8),
                Text(
                  'Rainfall has exceeded the 7-day baseline while soil probes are above the local saturation threshold. The slope node shows small but increasing movement. Nearby verified reports agree with the sensor pattern.',
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.45,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.verified_rounded, color: green),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Explainable score · no single sensor decides the alert',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                premiumRoute(const ProfessionalSafeRoutePage()),
              ),
              icon: const Icon(Icons.route_rounded),
              label: const Text('Open safest evacuation route'),
            ),
          ),
        ],
      ),
    );
  }
}

class RiskDriver extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const RiskDriver(this.label, this.value, this.progress, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: color,
            backgroundColor: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
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
  int route = 0;

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Safe Route',
      child: Column(
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFFD9F2EC), Color(0xFFE3EEFA)],
              ),
            ),
            child: CustomPaint(
              painter: RoutePainter(route),
              child: const Center(
                child: Icon(Icons.near_me_rounded, color: navy, size: 34),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RouteChoice(
                        active: route == 0,
                        title: 'Safest',
                        subtitle: '6.3 km · 18 min',
                        color: green,
                        onTap: () => setState(() => route = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RouteChoice(
                        active: route == 1,
                        title: 'Fastest',
                        subtitle: '5.1 km · 14 min',
                        color: orange,
                        onTap: () => setState(() => route = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: green),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Selected path avoids two active red zones and one blocked bridge.',
                        style: TextStyle(fontSize: 10.5, height: 1.35),
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
}

class RouteChoice extends StatelessWidget {
  final bool active;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const RouteChoice({
    super.key,
    required this.active,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: .1) : bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : const Color(0xFFE2EAEC),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: active ? color : ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black45, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final int route;
  RoutePainter(this.route);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = route == 0 ? green : orange
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = ui.Path()
      ..moveTo(size.width * .12, size.height * .82)
      ..cubicTo(
        size.width * .25,
        size.height * .55,
        size.width * .52,
        size.height * .78,
        size.width * .62,
        size.height * .44,
      )
      ..cubicTo(
        size.width * .70,
        size.height * .17,
        size.width * .84,
        size.height * .27,
        size.width * .90,
        size.height * .13,
      );
    canvas.drawPath(path, paint);
    for (final point in [
      Offset(size.width * .12, size.height * .82),
      Offset(size.width * .90, size.height * .13),
    ]) {
      canvas.drawCircle(point, 9, Paint()..color = navy);
    }
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) => oldDelegate.route != route;
}

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  int type = 0;
  bool evidence = false;
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    final types = ['Slope crack', 'Falling rocks', 'Blocked road', 'Flood water'];
    return DetailPage(
      title: 'Report Incident',
      child: Column(
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What do you see?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: List.generate(
                    types.length,
                    (i) => ChoiceChip(
                      label: Text(types[i]),
                      selected: type == i,
                      onSelected: (_) => setState(() => type = i),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    evidence ? Icons.verified_rounded : Icons.add_a_photo_rounded,
                    color: evidence ? green : orange,
                  ),
                  title: Text(
                    evidence ? 'Photo evidence ready' : 'Add photo evidence',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Adds timestamp and approximate location',
                  ),
                  onTap: () => setState(() => evidence = !evidence),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => sent = true),
              icon: Icon(sent ? Icons.check_rounded : Icons.send_rounded),
              label: Text(
                sent ? 'Report queued for verification' : 'Submit verified report',
              ),
            ),
          ),
          if (sent) ...[
            const SizedBox(height: 12),
            const SurfaceCard(
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: purple),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'AI cross-check started against nearby sensors and duplicate reports.',
                      style: TextStyle(fontSize: 10.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Relief & Resources',
      child: Column(
        children: [
          GradientResourceHero(),
          SizedBox(height: 12),
          ResourceRow(
            Icons.local_hospital_rounded,
            red,
            'District Hospital',
            '12 beds · 3.9 km',
          ),
          SizedBox(height: 9),
          ResourceRow(
            Icons.water_drop_rounded,
            blue,
            'Water & food point',
            '1.8 km · stocked 38 min ago',
          ),
          SizedBox(height: 9),
          ResourceRow(
            Icons.charging_station_rounded,
            orange,
            'Power & charging',
            '2.1 km · 14 ports free',
          ),
        ],
      ),
    );
  }
}

class GradientResourceHero extends StatelessWidget {
  const GradientResourceHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [navy, Color(0xFF0B8A75)]),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LiveBadge(label: '18 SAFE HUBS ONLINE'),
          Spacer(),
          Text(
            'Nearest: Melamchi Relief Hub',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            '2.7 km · 84 spaces · medical desk active',
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class ResourceRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const ResourceRow(this.icon, this.color, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.directions_rounded, color: navy),
        ],
      ),
    );
  }
}

class SafetyAssistantPage extends StatefulWidget {
  const SafetyAssistantPage({super.key});

  @override
  State<SafetyAssistantPage> createState() => _SafetyAssistantPageState();
}

class _SafetyAssistantPageState extends State<SafetyAssistantPage> {
  final field = TextEditingController();
  final messages = <ChatMessage>[
    const ChatMessage(
      'I can explain your current risk, safest route, SOS steps, or what to pack.',
      false,
    ),
  ];

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  void send() {
    final text = field.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(ChatMessage(text, true));
      messages.add(
        const ChatMessage(
          'Based on your current 78% slope-risk context: move toward the verified safe corridor, avoid steep drainage cuts, and keep live location sharing enabled.',
          false,
        ),
      );
      field.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Safety Assistant',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final message = messages[i];
                return Align(
                  alignment: message.user
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .78,
                    ),
                    decoration: BoxDecoration(
                      color: message.user ? const Color(0xFFDFF7F8) : navy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.user ? ink : Colors.white,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.paddingOf(context).bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: field,
                    decoration: const InputDecoration(
                      hintText: 'Ask a safety question',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 7),
                IconButton.filled(
                  onPressed: send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool user;
  const ChatMessage(this.text, this.user);
}

class RoleConfig {
  final Color accent;
  final Color secondary;
  final Color background;
  final bool dark;
  final List<String> tabs;
  final List<IconData> icons;
  final String eyebrow;
  final String headline;
  final String subtitle;
  final List<String> metrics;
  final List<RoleAction> actions;

  const RoleConfig({
    required this.accent,
    required this.secondary,
    required this.background,
    required this.dark,
    required this.tabs,
    required this.icons,
    required this.eyebrow,
    required this.headline,
    required this.subtitle,
    required this.metrics,
    required this.actions,
  });

  static RoleConfig forRole(ExperienceRole role) {
    return switch (role) {
      ExperienceRole.rescue => const RoleConfig(
          accent: red,
          secondary: orange,
          background: Color(0xFF071820),
          dark: true,
          tabs: ['Command', 'Missions', 'Comms', 'Intel', 'Kit'],
          icons: [
            Icons.radar_rounded,
            Icons.assignment_turned_in_rounded,
            Icons.podcasts_rounded,
            Icons.satellite_alt_rounded,
            Icons.inventory_2_rounded,
          ],
          eyebrow: 'FIELD COMMAND',
          headline: 'Rescue operations\nin motion.',
          subtitle: 'Triage, dispatch and live responder coordination',
          metrics: ['7 ACTIVE', '11 MIN ETA', '3 TEAMS'],
          actions: [
            RoleAction(Icons.emergency_share_rounded, 'Dispatch', 'Assign nearest team'),
            RoleAction(Icons.medical_services_rounded, 'Triage', 'Prioritise incoming SOS'),
            RoleAction(Icons.route_rounded, 'Route', 'Open responder corridor'),
            RoleAction(Icons.flight_rounded, 'Aerial scan', 'Request reconnaissance'),
          ],
        ),
      ExperienceRole.authority => const RoleConfig(
          accent: blue,
          secondary: cyan,
          background: Color(0xFFF1F5FA),
          dark: false,
          tabs: ['Overview', 'Command', 'Channels', 'Evidence', 'Admin'],
          icons: [
            Icons.dashboard_rounded,
            Icons.account_tree_rounded,
            Icons.campaign_rounded,
            Icons.fact_check_rounded,
            Icons.admin_panel_settings_rounded,
          ],
          eyebrow: 'DISTRICT COMMAND CENTER',
          headline: 'See the district.\nDecide with evidence.',
          subtitle: 'Verified intelligence, escalation and public warning',
          metrics: ['3 CRITICAL', '92% VERIFIED', '28 SENSORS'],
          actions: [
            RoleAction(Icons.campaign_rounded, 'Broadcast', 'Send area warning'),
            RoleAction(Icons.fact_check_rounded, 'Verify', 'Review citizen evidence'),
            RoleAction(Icons.polyline_rounded, 'Zones', 'Update risk perimeter'),
            RoleAction(Icons.hub_rounded, 'Resources', 'Reallocate capacity'),
          ],
        ),
      ExperienceRole.volunteer => const RoleConfig(
          accent: purple,
          secondary: green,
          background: Color(0xFFF8F5FF),
          dark: false,
          tabs: ['Today', 'Missions', 'Team', 'Updates', 'Profile'],
          icons: [
            Icons.wb_sunny_rounded,
            Icons.task_alt_rounded,
            Icons.groups_rounded,
            Icons.notifications_active_rounded,
            Icons.badge_rounded,
          ],
          eyebrow: 'COMMUNITY RESPONSE',
          headline: 'Your next helpful\naction is ready.',
          subtitle: 'Micro-missions matched to location and skill',
          metrics: ['2 MISSIONS', '1.8 KM', '6 TEAMMATES'],
          actions: [
            RoleAction(Icons.how_to_reg_rounded, 'Check-ins', 'Visit 3 households'),
            RoleAction(Icons.local_shipping_rounded, 'Supplies', 'Deliver water packs'),
            RoleAction(Icons.home_work_rounded, 'Shelter', 'Support registration'),
            RoleAction(Icons.add_location_alt_rounded, 'Report', 'Verify road access'),
          ],
        ),
      ExperienceRole.organization => const RoleConfig(
          accent: orange,
          secondary: purple,
          background: Color(0xFFFFF8ED),
          dark: false,
          tabs: ['Operations', 'Capacity', 'Comms', 'Requests', 'More'],
          icons: [
            Icons.business_center_rounded,
            Icons.inventory_rounded,
            Icons.video_call_rounded,
            Icons.move_to_inbox_rounded,
            Icons.grid_view_rounded,
          ],
          eyebrow: 'RELIEF OPERATIONS',
          headline: 'Capacity that moves\nwhere it matters.',
          subtitle: 'Shelters, inventory, logistics and partner coordination',
          metrics: ['84 SPACES', '71% STOCK', '4 PARTNERS'],
          actions: [
            RoleAction(Icons.apartment_rounded, 'Shelters', 'Manage live occupancy'),
            RoleAction(Icons.inventory_2_rounded, 'Inventory', 'Update supplies'),
            RoleAction(Icons.local_shipping_rounded, 'Transport', 'Assign logistics'),
            RoleAction(Icons.groups_2_rounded, 'Partners', 'Open coordination room'),
          ],
        ),
      ExperienceRole.citizen => throw StateError('Citizen uses foundation UI'),
    };
  }
}

class RoleAction {
  final IconData icon;
  final String title;
  final String subtitle;
  const RoleAction(this.icon, this.title, this.subtitle);
}

class DistinctRoleHome extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const DistinctRoleHome({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  State<DistinctRoleHome> createState() => _DistinctRoleHomeState();
}

class _DistinctRoleHomeState extends State<DistinctRoleHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController reveal;

  @override
  void initState() {
    super.initState();
    reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return SafeArea(
      child: Material(
        color: config.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            RoleHero(role: widget.role, config: config, reveal: reveal),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: roleActionSection(widget.role),
                    subtitle: 'Role-specific actions',
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: config.actions.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                    itemBuilder: (_, i) {
                      final action = config.actions[i];
                      return RoleActionCard(
                        accent: i.isEven ? config.accent : config.secondary,
                        action: action,
                        onTap: () => runRoleAction(
                          context,
                          widget.role,
                          action.title,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RoleDynamicPanel(role: widget.role, config: config),
                  const SizedBox(height: 20),
                  const SectionTitle(
                    title: 'Live operations stream',
                    subtitle: 'Changes that need attention',
                  ),
                  const SizedBox(height: 10),
                  OperationsFeed(role: widget.role, config: config),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleHero extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  final Animation<double> reveal;

  const RoleHero({
    super.key,
    required this.role,
    required this.config,
    required this.reveal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: role == ExperienceRole.rescue ? 300 : 275,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: role == ExperienceRole.rescue
              ? const [Color(0xFF071820), Color(0xFF102F3A)]
              : [
                  config.accent.withValues(alpha: .92),
                  config.secondary.withValues(alpha: .78),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: 35,
            child: Icon(
              roleHeroIcon(role),
              size: 210,
              color: Colors.white.withValues(alpha: .06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedBuilder(
              animation: reveal,
              builder: (_, __) {
                final value = Curves.easeOutCubic.transform(reveal.value);
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(role.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
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
                                  Text(
                                    config.eyebrow,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const LiveBadge(label: 'LIVE'),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          config.headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.02,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          config.subtitle,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: List.generate(3, (i) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: i < 2 ? 7 : 0),
                                child: OpsMetric(
                                  text: config.metrics[i],
                                  color: i == 0
                                      ? config.accent
                                      : i == 1
                                          ? config.secondary
                                          : green,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

IconData roleHeroIcon(ExperienceRole role) {
  return switch (role) {
    ExperienceRole.rescue => Icons.flight_rounded,
    ExperienceRole.authority => Icons.account_balance_rounded,
    ExperienceRole.volunteer => Icons.volunteer_activism_rounded,
    ExperienceRole.organization => Icons.warehouse_rounded,
    ExperienceRole.citizen => Icons.person_rounded,
  };
}

String roleActionSection(ExperienceRole role) {
  return switch (role) {
    ExperienceRole.rescue => 'Field controls',
    ExperienceRole.authority => 'Command controls',
    ExperienceRole.volunteer => 'Today’s missions',
    ExperienceRole.organization => 'Operations controls',
    ExperienceRole.citizen => 'Safety tools',
  };
}

class OpsMetric extends StatelessWidget {
  final String text;
  final Color color;
  const OpsMetric({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class RoleActionCard extends StatelessWidget {
  final Color accent;
  final RoleAction action;
  final VoidCallback onTap;

  const RoleActionCard({
    super.key,
    required this.accent,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: .16)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(action.icon, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 8.8,
                      ),
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

void runRoleAction(BuildContext context, ExperienceRole role, String action) {
  if (action == 'Partners' || action == 'Dispatch' || action == 'Broadcast') {
    final title = role == ExperienceRole.organization
        ? 'Partner Coordination Room'
        : role == ExperienceRole.rescue
            ? 'Rescue Command'
            : 'District Broadcast Desk';
    Navigator.push(
      context,
      premiumRoute(InAppCallPage(title: title, video: true)),
    );
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(role.icon, color: role.color, size: 34),
          const SizedBox(height: 10),
          Text(
            '$action ready',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
          ),
          const SizedBox(height: 5),
          Text(
            'This control updates the ${role.title.toLowerCase()} operational workflow and records the action in the activity stream.',
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Confirm action'),
            ),
          ),
        ],
      ),
    ),
  );
}

class RoleDynamicPanel extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const RoleDynamicPanel({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case ExperienceRole.rescue:
        return RescueLivePanel();
      case ExperienceRole.authority:
        return const AuthorityEvidencePanel();
      case ExperienceRole.volunteer:
        return const VolunteerMissionPanel();
      case ExperienceRole.organization:
        return OrganizationCapacityPanel();
      case ExperienceRole.citizen:
        return const SizedBox.shrink();
    }
  }
}

class RescueLivePanel extends StatelessWidget {
  const RescueLivePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2731),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              LiveBadge(label: 'UNIT 04 EN ROUTE'),
              Spacer(),
              Text(
                'ETA 11 min',
                style: TextStyle(
                  color: aqua,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'SOS #JS-2481 · Landslide / trapped',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '2 people · medical priority · location streaming',
            style: TextStyle(color: Colors.white60, fontSize: 9.5),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Citizen SOS #JS-2481',
                        video: false,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Voice'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: red),
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Citizen SOS #JS-2481',
                        video: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthorityEvidencePanel extends StatelessWidget {
  const AuthorityEvidencePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_rounded, color: blue),
              SizedBox(width: 9),
              Text(
                'Verification queue',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              Spacer(),
              LiveBadge(label: '6 ITEMS'),
            ],
          ),
          SizedBox(height: 12),
          EvidenceBar('Slope movement · Ward 8', .94, red),
          EvidenceBar('Bridge blockage · Araniko Hwy', .81, orange),
          EvidenceBar('Rain gauge anomaly · SG-04', .76, blue),
        ],
      ),
    );
  }
}

class EvidenceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const EvidenceBar(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}

class VolunteerMissionPanel extends StatelessWidget {
  const VolunteerMissionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: purple),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Mission route · 3 stops',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              Pill(label: '42 min', color: green),
            ],
          ),
          SizedBox(height: 10),
          Text('1. Community check-in  ·  0.6 km', style: TextStyle(fontSize: 10.5)),
          Divider(),
          Text('2. Water delivery  ·  1.1 km', style: TextStyle(fontSize: 10.5)),
          Divider(),
          Text('3. Road access verification  ·  1.8 km', style: TextStyle(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class OrganizationCapacityPanel extends StatelessWidget {
  const OrganizationCapacityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.apartment_rounded, color: orange),
              SizedBox(width: 9),
              Text(
                'Melamchi Relief Hub',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              Spacer(),
              LiveBadge(label: 'OPEN'),
            ],
          ),
          const SizedBox(height: 11),
          const LinearProgressIndicator(
            value: .64,
            minHeight: 10,
            color: orange,
            backgroundColor: Color(0xFFFFEFD5),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Text('53 / 84 spaces occupied', style: TextStyle(fontSize: 10)),
              Spacer(),
              Text(
                '31 available',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Camp Operations',
                        video: false,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call camp'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: orange),
                  onPressed: () => Navigator.push(
                    context,
                    premiumRoute(
                      const InAppCallPage(
                        title: 'Camp Operations',
                        video: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OperationsFeed extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const OperationsFeed({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final rows = switch (role) {
      ExperienceRole.rescue => const [
          ('SOS #2481 acknowledged', 'Unit 04 · just now'),
          ('Road access changed', 'Araniko corridor · 2 min'),
          ('Medical team joined channel', 'District Hospital · 4 min'),
        ],
      ExperienceRole.authority => const [
          ('Ward 8 report verified', 'Evidence confidence 94%'),
          ('Public warning delivered', '18,420 devices reached'),
          ('Red-zone boundary updated', '2.4 km² affected'),
        ],
      ExperienceRole.volunteer => const [
          ('Mission #V-113 accepted', 'Check-in route · 3 stops'),
          ('Supply pickup confirmed', 'Water packs × 12'),
          ('Team member nearby', 'Riya · 350 m away'),
        ],
      ExperienceRole.organization => const [
          ('Shelter capacity updated', '31 spaces available'),
          ('Medical supplies received', '12 kits · logged'),
          ('Partner request received', 'Water tanker · priority'),
        ],
      ExperienceRole.citizen => const <(String, String)>[],
    };
    return SurfaceCard(
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              if (i > 0) const Divider(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: i == 0 ? config.accent : green,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                          ),
                        ),
                        Text(
                          row.$2,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 8.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class RoleOperations extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const RoleOperations({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  State<RoleOperations> createState() => _RoleOperationsState();
}

class _RoleOperationsState extends State<RoleOperations> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return SafeArea(
      child: Material(
        color: config.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  config.tabs[1],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Pill(label: 'LIVE', color: config.accent),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 205,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    config.accent.withValues(alpha: .9),
                    config.secondary.withValues(alpha: .75),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: OpsGraphicPainter(),
                child: Center(
                  child: Icon(
                    roleHeroIcon(widget.role),
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => setState(() => selected = i),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected == i
                              ? config.accent
                              : const Color(0xFFE5ECEE),
                          width: selected == i ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                config.accent.withValues(alpha: .1),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: config.accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  boardTitle(widget.role, i),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  boardSubtitle(widget.role, i),
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected == i)
                            Icon(
                              Icons.check_circle_rounded,
                              color: config.accent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

String boardTitle(ExperienceRole role, int index) {
  return switch (role) {
    ExperienceRole.rescue =>
      ['SOS #2481 · trapped', 'Slope reconnaissance', 'Medical transfer'][index],
    ExperienceRole.authority =>
      ['Critical zone review', 'Warning broadcast', 'Resource deployment'][index],
    ExperienceRole.volunteer =>
      ['Household check-ins', 'Water delivery', 'Road verification'][index],
    ExperienceRole.organization =>
      ['Shelter occupancy', 'Inventory transfer', 'Partner request'][index],
    ExperienceRole.citizen => '',
  };
}

String boardSubtitle(ExperienceRole role, int index) {
  return switch (role) {
    ExperienceRole.rescue =>
      ['Unit 04 assigned · ETA 11 min', 'Aerial scan queued', 'Hospital desk ready'][index],
    ExperienceRole.authority =>
      ['3 evidence sources · 94% confidence', '18,420 devices targeted', '4 assets available'][index],
    ExperienceRole.volunteer =>
      ['3 homes · 1.4 km loop', '12 packs · 2 stops', 'Araniko access point'][index],
    ExperienceRole.organization =>
      ['53 / 84 occupied', '12 medical kits incoming', 'Water tanker requested'][index],
    ExperienceRole.citizen => '',
  };
}

class OpsGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (double x = 20; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 18; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = ui.Path()
      ..moveTo(15, size.height * .68)
      ..cubicTo(
        size.width * .25,
        size.height * .72,
        size.width * .31,
        size.height * .31,
        size.width * .49,
        size.height * .48,
      )
      ..cubicTo(
        size.width * .70,
        size.height * .70,
        size.width * .75,
        size.height * .20,
        size.width * .95,
        size.height * .32,
      );
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoleCommunications extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const RoleCommunications({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = switch (role) {
      ExperienceRole.rescue =>
        ['Field Command', 'Medical Desk', 'Citizen SOS #2481'],
      ExperienceRole.authority =>
        ['District Command', 'Ward Officers', 'Public Information Cell'],
      ExperienceRole.volunteer =>
        ['Volunteer Team Alpha', 'Camp Coordinator', 'Field Mentor'],
      ExperienceRole.organization =>
        ['Camp Operations', 'Partner Coordination', 'Logistics Driver'],
      ExperienceRole.citizen => ['Response Desk'],
    };
    return SafeArea(
      child: Material(
        color: config.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  config.tabs[2],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                const Pill(label: 'ENCRYPTED', color: green),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'In-app voice, video and operational radio',
              style: TextStyle(color: Colors.black45, fontSize: 10.5),
            ),
            const SizedBox(height: 16),
            ...rooms.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            config.accent.withValues(alpha: .1),
                        child: Icon(
                          entry.key == 0
                              ? Icons.podcasts_rounded
                              : Icons.groups_rounded,
                          color: config.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              entry.key == 0
                                  ? '6 participants · live channel'
                                  : 'Available now',
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 9.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          premiumRoute(
                            InAppCallPage(
                              title: entry.value,
                              video: false,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.call_rounded),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: config.accent,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          premiumRoute(
                            InAppCallPage(
                              title: entry.value,
                              video: true,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.videocam_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InAppCallPage extends StatefulWidget {
  final String title;
  final bool video;

  const InAppCallPage({
    super.key,
    required this.title,
    required this.video,
  });

  @override
  State<InAppCallPage> createState() => _InAppCallPageState();
}

class _InAppCallPageState extends State<InAppCallPage> {
  bool muted = false;
  bool speaker = true;
  bool camera = true;
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get elapsed {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061820),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.video && camera
                  ? const FastPhoto(rescueImage)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0A5265), Color(0xFF061820)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: widget.video ? .28 : .08,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const LiveBadge(label: 'SECURE CHANNEL'),
                    ],
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0x3357E1E8),
                    child: Icon(
                      Icons.groups_rounded,
                      color: aqua,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    elapsed,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .32),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CallControl(
                          icon: muted
                              ? Icons.mic_off_rounded
                              : Icons.mic_rounded,
                          active: !muted,
                          onTap: () => setState(() => muted = !muted),
                        ),
                        CallControl(
                          icon: speaker
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          active: speaker,
                          onTap: () => setState(() => speaker = !speaker),
                        ),
                        if (widget.video)
                          CallControl(
                            icon: camera
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                            active: camera,
                            onTap: () => setState(() => camera = !camera),
                          ),
                        CallControl(
                          icon: Icons.call_end_rounded,
                          active: true,
                          danger: true,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CallControl extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool danger;
  final VoidCallback onTap;

  const CallControl({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger
          ? red
          : Colors.white.withValues(alpha: active ? .18 : .08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class RoleIntelligence extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const RoleIntelligence({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: config.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  config.tabs[3],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Pill(label: 'AI + HUMAN', color: config.accent),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    config.accent.withValues(alpha: .9),
                    config.secondary.withValues(alpha: .75),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operational intelligence',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Prioritised by urgency, confidence and role relevance',
                          style: TextStyle(color: Colors.white70, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            const IntelCard(
              title: 'Risk model updated',
              body:
                  'Slope probability increased 6% after the latest soil sync.',
              color: red,
            ),
            const SizedBox(height: 9),
            const IntelCard(
              title: 'Community evidence verified',
              body: 'Two reports match sensor and weather patterns.',
              color: green,
            ),
            const SizedBox(height: 9),
            const IntelCard(
              title: 'Route intelligence changed',
              body: 'One corridor is slower but remains outside red zones.',
              color: orange,
            ),
          ],
        ),
      ),
    );
  }
}

class IntelCard extends StatelessWidget {
  final String title;
  final String body;
  final Color color;

  const IntelCard({
    super.key,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(Icons.bolt_rounded, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    height: 1.35,
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

class RoleToolkit extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;

  const RoleToolkit({
    super.key,
    required this.role,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final tools = switch (role) {
      ExperienceRole.rescue => const [
          (Icons.medical_services_rounded, 'Triage protocol'),
          (Icons.offline_bolt_rounded, 'Offline responder pack'),
          (Icons.qr_code_scanner_rounded, 'Patient / asset scan'),
          (Icons.sensors_rounded, 'Field sensor link'),
        ],
      ExperienceRole.authority => const [
          (Icons.campaign_rounded, 'Broadcast templates'),
          (Icons.fact_check_rounded, 'Evidence policy'),
          (Icons.history_rounded, 'Decision log'),
          (Icons.security_rounded, 'Access controls'),
        ],
      ExperienceRole.volunteer => const [
          (Icons.badge_rounded, 'Digital volunteer ID'),
          (Icons.school_rounded, 'Micro training'),
          (Icons.offline_bolt_rounded, 'Offline mission pack'),
          (Icons.workspace_premium_rounded, 'Impact record'),
        ],
      ExperienceRole.organization => const [
          (Icons.inventory_rounded, 'Inventory ledger'),
          (Icons.apartment_rounded, 'Shelter profile'),
          (Icons.qr_code_rounded, 'Resource handover QR'),
          (Icons.handshake_rounded, 'Partner directory'),
        ],
      ExperienceRole.citizen => const <(IconData, String)>[],
    };
    return SafeArea(
      child: Material(
        color: config.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              config.tabs[4],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            ...tools.map(
              (tool) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: () => showInfo(
                      context,
                      tool.$2,
                      'This module is available locally and records changes in the ${role.title.toLowerCase()} activity log.',
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: const Color(0xFFE4EBED)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: config.accent.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(tool.$1, color: config.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tool.$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                premiumRoute(const PremiumRolePicker()),
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
}

class LiveBadge extends StatelessWidget {
  final String label;
  const LiveBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: green.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3.5, backgroundColor: green),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: green,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MiniAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool dark;

  const Pill({
    super.key,
    required this.label,
    required this.color,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .08)
            : color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: dark ? Colors.white24 : color.withValues(alpha: .25),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: dark ? Colors.white : color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EEF0)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: .045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TapCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const TapCard({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final Widget child;

  const DetailPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: bg,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [child],
        ),
      ),
    );
  }
}

void showInfo(BuildContext context, String title, String body) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    ),
  );
}


// PROFESSIONAL_UPGRADE_V3 ---------------------------------------------------

class ProfessionalSafeRoutePage extends StatefulWidget {
  const ProfessionalSafeRoutePage({super.key});

  @override
  State<ProfessionalSafeRoutePage> createState() => _ProfessionalSafeRoutePageState();
}

class _ProfessionalSafeRoutePageState extends State<ProfessionalSafeRoutePage> {
  int route = 0;
  bool navigating = false;
  double progress = .18;
  Timer? timer;

  static const safest = <LatLng>[
    LatLng(27.742, 85.435),
    LatLng(27.751, 85.452),
    LatLng(27.763, 85.468),
    LatLng(27.774, 85.481),
    LatLng(27.789, 85.494),
    LatLng(27.802, 85.528),
  ];
  static const fastest = <LatLng>[
    LatLng(27.742, 85.435),
    LatLng(27.758, 85.466),
    LatLng(27.775, 85.502),
    LatLng(27.802, 85.528),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startNavigation() {
    setState(() => navigating = !navigating);
    timer?.cancel();
    if (navigating) {
      timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        setState(() => progress = math.min(.94, progress + .045));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = route == 0 ? safest : fastest;
    final activeColor = route == 0 ? green : orange;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Safe Route', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(27.775, 85.482),
                    initialZoom: 11.4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.jeevansetu.app',
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: const [
                            LatLng(27.761, 85.470),
                            LatLng(27.781, 85.485),
                            LatLng(27.777, 85.508),
                            LatLng(27.756, 85.500),
                          ],
                          color: red.withValues(alpha: .18),
                          borderColor: red,
                          borderStrokeWidth: 2,
                        ),
                        Polygon(
                          points: const [
                            LatLng(27.785, 85.505),
                            LatLng(27.796, 85.516),
                            LatLng(27.790, 85.530),
                            LatLng(27.778, 85.522),
                          ],
                          color: red.withValues(alpha: .13),
                          borderColor: red,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: active,
                          strokeWidth: 7,
                          color: activeColor,
                          borderColor: Colors.white,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        const Marker(
                          point: LatLng(27.742, 85.435),
                          width: 48,
                          height: 48,
                          child: CircleAvatar(
                            backgroundColor: navy,
                            child: Icon(Icons.my_location_rounded, color: Colors.white),
                          ),
                        ),
                        const Marker(
                          point: LatLng(27.802, 85.528),
                          width: 52,
                          height: 52,
                          child: CircleAvatar(
                            backgroundColor: green,
                            child: Icon(Icons.home_work_rounded, color: Colors.white),
                          ),
                        ),
                        const Marker(
                          point: LatLng(27.771, 85.491),
                          width: 42,
                          height: 42,
                          child: Icon(Icons.warning_rounded, color: red, size: 38),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: green),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route == 0 ? 'Safest corridor selected' : 'Fastest corridor selected',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                              Text(
                                route == 0
                                    ? 'Avoids 2 active red zones · 6.3 km · 18 min'
                                    : 'Shorter route · passes near 1 watch zone · 5.1 km · 14 min',
                                style: const TextStyle(color: Colors.black54, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                        const LiveBadge(label: 'LIVE'),
                      ],
                    ),
                  ),
                ),
                if (navigating)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: deepNavy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: aqua,
                                child: Icon(Icons.navigation_rounded, color: navy),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Continue on verified corridor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                    Text('${(6.3 * (1 - progress)).clamp(.3, 6.3).toStringAsFixed(1)} km remaining · live hazard rerouting on', style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                                  ],
                                ),
                              ),
                              Text('${(progress * 100).round()}%', style: const TextStyle(color: aqua, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 9),
                          LinearProgressIndicator(value: progress, minHeight: 6, color: aqua, backgroundColor: Colors.white12),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(14, 12, 14, MediaQuery.paddingOf(context).bottom + 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RouteChoice(
                        active: route == 0,
                        title: 'Safest',
                        subtitle: '6.3 km · 18 min',
                        color: green,
                        onTap: () => setState(() => route = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RouteChoice(
                        active: route == 1,
                        title: 'Fastest',
                        subtitle: '5.1 km · 14 min',
                        color: orange,
                        onTap: () => setState(() => route = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: navigating ? navy : activeColor, minimumSize: const Size.fromHeight(50)),
                    onPressed: startNavigation,
                    icon: Icon(navigating ? Icons.stop_circle_outlined : Icons.navigation_rounded),
                    label: Text(navigating ? 'Stop navigation' : 'Start live navigation', style: const TextStyle(fontWeight: FontWeight.w900)),
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

class ProfessionalRoleHome extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleHome({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleHome> createState() => _ProfessionalRoleHomeState();
}

class _ProfessionalRoleHomeState extends State<ProfessionalRoleHome> {
  int tick = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => tick++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final role = widget.role;
    return SafeArea(
      child: Material(
        color: c.background,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ProfessionalRoleHero(role: role, config: c, tick: tick)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList.list(
                children: [
                  _RoleLiveMapPreview(role: role, config: c),
                  const SizedBox(height: 16),
                  SectionTitle(title: roleActionSection(role), subtitle: _professionalSubtitle(role)),
                  const SizedBox(height: 10),
                  _ProfessionalActionRail(role: role, config: c),
                  const SizedBox(height: 16),
                  RoleDynamicPanel(role: role, config: c),
                  const SizedBox(height: 16),
                  _RoleKpiTimeline(role: role, config: c, tick: tick),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _professionalSubtitle(ExperienceRole role) => switch (role) {
    ExperienceRole.rescue => 'Dispatch, triage, routing and field reconnaissance',
    ExperienceRole.authority => 'Broadcast, verification, zoning and resource allocation',
    ExperienceRole.volunteer => 'Nearby missions matched to skill, distance and urgency',
    ExperienceRole.organization => 'Shelter, stock, transport and partner coordination',
    ExperienceRole.citizen => 'Safety actions',
  };
}

class _ProfessionalRoleHero extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  final int tick;
  const _ProfessionalRoleHero({required this.role, required this.config, required this.tick});

  @override
  Widget build(BuildContext context) {
    final image = role == ExperienceRole.rescue ? rescueImage : mountainImage;
    return SizedBox(
      height: 310,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FastPhoto(image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: role == ExperienceRole.rescue
                    ? const [Color(0x7006151B), Color(0xF506151B)]
                    : [config.accent.withValues(alpha: .45), const Color(0xE9072631)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white.withValues(alpha: .16), child: Icon(role.icon, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(role.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                        Text(config.eyebrow, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .8)),
                      ]),
                    ),
                    const LiveBadge(label: 'LIVE'),
                  ],
                ),
                const Spacer(),
                Text(config.headline, style: const TextStyle(color: Colors.white, fontSize: 29, height: 1.02, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(config.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(3, (i) {
                    final baseText = config.metrics[i];
                    final dynamic = i == 1 && tick.isOdd ? '$baseText · LIVE' : baseText;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 7 : 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white24)),
                          child: FittedBox(child: Text(dynamic, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleLiveMapPreview extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const _RoleLiveMapPreview({required this.role, required this.config});

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(point: const LatLng(27.78, 85.49), width: 42, height: 42, child: CircleAvatar(backgroundColor: config.accent, child: Icon(role.icon, color: Colors.white, size: 20))),
      const Marker(point: LatLng(27.802, 85.528), width: 42, height: 42, child: CircleAvatar(backgroundColor: green, child: Icon(Icons.home_work_rounded, color: Colors.white, size: 20))),
      const Marker(point: LatLng(27.758, 85.462), width: 42, height: 42, child: CircleAvatar(backgroundColor: red, child: Icon(Icons.warning_rounded, color: Colors.white, size: 20))),
    ];
    return Container(
      height: 235,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: config.accent.withValues(alpha: .18))),
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(initialCenter: LatLng(27.78, 85.49), initialZoom: 11.2),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.jeevansetu.app'),
              PolygonLayer(polygons: [Polygon(points: const [LatLng(27.756,85.468),LatLng(27.779,85.485),LatLng(27.770,85.511),LatLng(27.748,85.497)], color: red.withValues(alpha:.16), borderColor: red, borderStrokeWidth: 2)]),
              PolylineLayer(polylines: [Polyline(points: const [LatLng(27.744,85.443),LatLng(27.763,85.470),LatLng(27.782,85.496),LatLng(27.802,85.528)], strokeWidth: 5, color: config.secondary)]),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                Icon(Icons.public_rounded, color: config.accent, size: 19),
                const SizedBox(width: 8),
                Expanded(child: Text(_mapTitle(role), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900))),
                const LiveBadge(label: 'MAP'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _mapTitle(ExperienceRole role) => switch(role) {
    ExperienceRole.rescue => 'Responder corridor · Unit 04 moving',
    ExperienceRole.authority => 'District risk perimeter · verified layers',
    ExperienceRole.volunteer => 'Mission cluster · 2 tasks within 1.8 km',
    ExperienceRole.organization => 'Facility network · capacity & logistics',
    ExperienceRole.citizen => 'Live safety map',
  };
}

class _ProfessionalActionRail extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const _ProfessionalActionRail({required this.role, required this.config});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: config.actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final a = config.actions[i];
          return SizedBox(
            width: 150,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => runRoleAction(context, role, a.title),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(backgroundColor: config.accent.withValues(alpha: .1), child: Icon(a.icon, color: config.accent)),
                    const Spacer(),
                    Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    Text(a.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 8.5)),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleKpiTimeline extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  final int tick;
  const _RoleKpiTimeline({required this.role, required this.config, required this.tick});

  @override
  Widget build(BuildContext context) {
    final items = switch(role) {
      ExperienceRole.rescue => [('Unit 04 GPS updated','${8 + tick % 5} sec ago'),('Medical team linked','secure channel active'),('Drone corridor','weather cleared')],
      ExperienceRole.authority => [('Ward 8 evidence','94% verified'),('Broadcast reach','18,420 devices'),('Sensor mesh','${27 + tick % 2}/28 online')],
      ExperienceRole.volunteer => [('Household check-in','3 of 4 complete'),('Supply handover','12 packs scanned'),('Team proximity','Riya · ${300 + tick*5 % 90} m')],
      ExperienceRole.organization => [('Shelter occupancy','53 / 84'),('Water inventory','${1260 - tick*3} units'),('Partner ETA','${18 - tick % 5} min')],
      ExperienceRole.citizen => <(String,String)>[],
    };
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.timeline_rounded, color: config.accent), const SizedBox(width: 8), const Text('Live operations timeline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const Spacer(), const LiveBadge(label:'SYNC')]),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) => Column(children: [if(e.key>0) const Divider(), Row(children:[CircleAvatar(radius:5,backgroundColor:e.key==0?config.accent:green),const SizedBox(width:9),Expanded(child:Text(e.value.$1,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:10.5))),Text(e.value.$2,style:const TextStyle(color:Colors.black45,fontSize:9))])])),
      ]),
    );
  }
}

class ProfessionalRoleOperations extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleOperations({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleOperations> createState() => _ProfessionalRoleOperationsState();
}

class _ProfessionalRoleOperationsState extends State<ProfessionalRoleOperations> {
  int selected = 0;
  bool layer = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final textColor = c.dark ? Colors.white : ink;
    return SafeArea(
      child: Material(
        color: c.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(children: [
                Expanded(child: Text(c.tabs[1], style: TextStyle(color:textColor,fontSize:24,fontWeight:FontWeight.w900))),
                Pill(label: 'LIVE', color: c.accent, dark: c.dark),
              ]),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(initialCenter: LatLng(27.78,85.49), initialZoom: 11.0),
                    children: [
                      TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.jeevansetu.app'),
                      if(layer) PolygonLayer(polygons:[Polygon(points:const[LatLng(27.75,85.46),LatLng(27.79,85.48),LatLng(27.78,85.53),LatLng(27.74,85.51)],color:red.withValues(alpha:.18),borderColor:red,borderStrokeWidth:2)]),
                      PolylineLayer(polylines:[Polyline(points:const[LatLng(27.742,85.435),LatLng(27.765,85.482),LatLng(27.802,85.528)],strokeWidth:6,color:c.secondary)]),
                      MarkerLayer(markers:[
                        Marker(point:const LatLng(27.78,85.49),width:46,height:46,child:CircleAvatar(backgroundColor:c.accent,child:Icon(widget.role.icon,color:Colors.white))),
                        const Marker(point:LatLng(27.802,85.528),width:46,height:46,child:CircleAvatar(backgroundColor:green,child:Icon(Icons.home_work_rounded,color:Colors.white))),
                        const Marker(point:LatLng(27.758,85.468),width:42,height:42,child:Icon(Icons.warning_rounded,color:red,size:38)),
                      ]),
                    ],
                  ),
                  Positioned(top:12,right:12,child:FloatingActionButton.small(heroTag:'layers-${widget.role.name}',backgroundColor:Colors.white,foregroundColor:c.accent,onPressed:()=>setState(()=>layer=!layer),child:Icon(layer?Icons.layers_rounded:Icons.layers_clear_rounded))),
                  Positioned(
                    left:12,right:12,bottom:12,
                    child: SurfaceCard(
                      child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Row(children:[Icon(widget.role.icon,color:c.accent),const SizedBox(width:8),Expanded(child:Text(boardTitle(widget.role,selected),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13))),const LiveBadge(label:'ACTIVE')]),
                        const SizedBox(height:4),
                        Text(boardSubtitle(widget.role,selected),style:const TextStyle(color:Colors.black54,fontSize:9.5)),
                        const SizedBox(height:10),
                        Row(children:List.generate(3,(i)=>Expanded(child:Padding(padding:EdgeInsets.only(right:i<2?6:0),child:ChoiceChip(label:Text('${i+1}'),selected:selected==i,onSelected:(_)=>setState(()=>selected=i))))))),
                      ]),
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
}

class ProfessionalRoleIntelligence extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleIntelligence({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleIntelligence> createState() => _ProfessionalRoleIntelligenceState();
}

class _ProfessionalRoleIntelligenceState extends State<ProfessionalRoleIntelligence> {
  int refresh = 14;
  Timer? timer;
  @override
  void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>refresh=refresh==1?14:refresh-1);});}
  @override
  void dispose(){timer?.cancel();super.dispose();}

  @override
  Widget build(BuildContext context){
    final c=widget.config; final tc=c.dark?Colors.white:ink; final sc=c.dark?Colors.white60:Colors.black54;
    return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:Text(c.tabs[3],style:TextStyle(color:tc,fontSize:24,fontWeight:FontWeight.w900))),Pill(label:'SYNC $refresh SEC',color:c.accent,dark:c.dark)]),
      const SizedBox(height:12),
      Container(height:180,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22)),child:Stack(fit:StackFit.expand,children:[
        FastPhoto(widget.role==ExperienceRole.rescue?rescueImage:riskImage),
        const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0x20000000),Color(0xDD071820)]))),
        Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Pill(label:'VERIFIED SIGNAL FUSION',color:c.accent,dark:true),const Spacer(),Text(_intelHeadline(widget.role),style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(_intelSub(widget.role),style:const TextStyle(color:Colors.white70,fontSize:10))]))
      ])),
      const SizedBox(height:12),
      SurfaceCard(child:Column(children:[_IntelMetric('Sensor confidence',.92,c.accent),const SizedBox(height:9),_IntelMetric('Community agreement',.81,green),const SizedBox(height:9),_IntelMetric('Route confidence',.88,orange)])),
      const SizedBox(height:12),
      ..._intelRows(widget.role).map((r)=>Padding(padding:const EdgeInsets.only(bottom:9),child:SurfaceCard(child:Row(children:[CircleAvatar(backgroundColor:r.$3.withValues(alpha:.1),child:Icon(r.$4,color:r.$3)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(r.$1,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12.5)),Text(r.$2,style:TextStyle(color:sc,fontSize:9.7,height:1.3))])),Icon(Icons.chevron_right_rounded,color:c.dark?Colors.white38:Colors.black38)]))))
    ])));
  }

  String _intelHeadline(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Terrain + victim intelligence',ExperienceRole.authority=>'District evidence picture',ExperienceRole.volunteer=>'Mission relevance engine',ExperienceRole.organization=>'Demand + capacity intelligence',ExperienceRole.citizen=>'Risk intelligence'};
  String _intelSub(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Thermal, terrain, route and SOS evidence fused for field decisions.',ExperienceRole.authority=>'Sensor, citizen and agency evidence prioritised before public action.',ExperienceRole.volunteer=>'Tasks ranked by proximity, skill, urgency and access.',ExperienceRole.organization=>'Shelter occupancy, demand, inventory and transport changes in one view.',ExperienceRole.citizen=>'Verified local risk context.'};
  List<(String,String,Color,IconData)> _intelRows(ExperienceRole r)=>switch(r){
    ExperienceRole.rescue=>[('Thermal signature confirmed','Possible 2-person cluster · drone pass 3',red,Icons.thermostat_rounded),('Approach corridor improved','North-east path now clear for 4×4 access',green,Icons.route_rounded),('Rain intensity falling','18.4 → 14.1 mm/hr over latest cycle',blue,Icons.water_drop_rounded)],
    ExperienceRole.authority=>[('Ward 8 evidence verified','3 independent sources · 94% confidence',red,Icons.fact_check_rounded),('Public warning reach','18,420 devices · 91% delivery',blue,Icons.campaign_rounded),('Resource pressure rising','Melamchi hub projected 82% full in 3h',orange,Icons.hub_rounded)],
    ExperienceRole.volunteer=>[('Mission match improved','Water delivery now 0.9 km from your route',purple,Icons.route_rounded),('Household check-in overdue','1 family has not checked in for 34 min',orange,Icons.family_restroom_rounded),('Camp B requests support','Registration queue increased by 12',green,Icons.home_work_rounded)],
    ExperienceRole.organization=>[('Water demand rising','Projected 18% increase at Melamchi hub',blue,Icons.water_drop_rounded),('Transport window opened','Araniko corridor clear for next 42 min',green,Icons.local_shipping_rounded),('Medical stock threshold','Trauma kits projected below 20% by 18:00',red,Icons.medical_services_rounded)],
    ExperienceRole.citizen=>[],
  };
}

class _IntelMetric extends StatelessWidget {final String label;final double value;final Color color;const _IntelMetric(this.label,this.value,this.color);@override Widget build(BuildContext context)=>Column(children:[Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800))),Text('${(value*100).round()}%',style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:10))]),const SizedBox(height:5),LinearProgressIndicator(value:value,minHeight:7,color:color,backgroundColor:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(10))]);}

class ProfessionalRoleToolkit extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleToolkit({super.key,required this.role,required this.config});

  @override
  Widget build(BuildContext context){
    final c=config; final tc=c.dark?Colors.white:ink; final sc=c.dark?Colors.white60:Colors.black54;
    final cards=switch(role){
      ExperienceRole.rescue=>[(Icons.medical_services_rounded,'Triage protocol','Offline protocol · 6 steps',red),(Icons.qr_code_scanner_rounded,'Patient / asset scan','QR + offline handover',blue),(Icons.sensors_rounded,'Field sensor link','26/28 nodes online',green),(Icons.inventory_2_rounded,'Equipment readiness','84% mission ready',orange)],
      ExperienceRole.authority=>[(Icons.campaign_rounded,'Broadcast templates','3 languages · geo-targeted',blue),(Icons.fact_check_rounded,'Evidence policy','3-source verification rules',green),(Icons.history_rounded,'Decision log','Signed operational history',purple),(Icons.security_rounded,'Access controls','12 authorised officers',orange)],
      ExperienceRole.volunteer=>[(Icons.badge_rounded,'Digital volunteer ID','Verified · responder mesh',purple),(Icons.school_rounded,'Micro training','4 modules cached offline',blue),(Icons.offline_bolt_rounded,'Offline mission pack','Routes + contacts synced',green),(Icons.workspace_premium_rounded,'Impact record','7 missions · 46 families',orange)],
      ExperienceRole.organization=>[(Icons.inventory_rounded,'Inventory ledger','1,260 water · 87 trauma kits',orange),(Icons.apartment_rounded,'Shelter profile','53 / 84 occupied',green),(Icons.qr_code_rounded,'Resource handover QR','Fast chain-of-custody',blue),(Icons.handshake_rounded,'Partner directory','4 partners online',purple)],
      ExperienceRole.citizen=><(IconData,String,String,Color)>[]};
    return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Text(c.tabs[4],style:TextStyle(color:tc,fontSize:24,fontWeight:FontWeight.w900)),
      Text('Operational tools ready for this role',style:TextStyle(color:sc,fontSize:10.5)),
      const SizedBox(height:14),
      Container(height:150,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22)),child:Stack(fit:StackFit.expand,children:[FastPhoto(role==ExperienceRole.rescue?rescueImage:mountainImage),Container(color:Colors.black.withValues(alpha:.45)),Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Pill(label:'OFFLINE + ONLINE',color:c.accent,dark:true),const Spacer(),Text(_kitTitle(role),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:18)),const Text('Critical tools stay usable even when connectivity degrades.',style:TextStyle(color:Colors.white70,fontSize:9.5))]))])),
      const SizedBox(height:12),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:1.18),itemBuilder:(_,i){final x=cards[i];return Material(color:Colors.white,borderRadius:BorderRadius.circular(19),child:InkWell(borderRadius:BorderRadius.circular(19),onTap:()=>showInfo(context,x.$2,x.$3),child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:x.$4.withValues(alpha:.1),child:Icon(x.$1,color:x.$4)),const Spacer(),Text(x.$2,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text(x.$3,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.black45,fontSize:8.7))]))));}),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:()=>Navigator.pushReplacement(context,premiumRoute(const PremiumRolePicker())),icon:const Icon(Icons.swap_horiz_rounded),label:const Text('Switch profession / role')),
    ])));
  }
  String _kitTitle(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Responder field kit',ExperienceRole.authority=>'Command governance suite',ExperienceRole.volunteer=>'Volunteer field pack',ExperienceRole.organization=>'Relief logistics toolkit',ExperienceRole.citizen=>'Safety toolkit'};
}
