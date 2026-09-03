import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'app.dart' show RolePickerPage, LogoMark, deepNavy, navy, cyan, aqua, bg, ink;

/// Upgrade layer that deliberately leaves the approved JeevanSetu application
/// foundation untouched. It replaces only the launch/onboarding experience and
/// adds global language/theme controls plus a judge-friendly explain overlay.
class EnhancedJeevanSetuApp extends StatefulWidget {
  const EnhancedJeevanSetuApp({super.key});

  @override
  State<EnhancedJeevanSetuApp> createState() => _EnhancedJeevanSetuAppState();
}

class _EnhancedJeevanSetuAppState extends State<EnhancedJeevanSetuApp> {
  ThemeMode mode = ThemeMode.light;
  AppLanguage language = AppLanguage.english;

  void setMode(ThemeMode value) => setState(() => mode = value);
  void setLanguage(AppLanguage value) => setState(() => language = value);

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyan,
        primary: cyan,
        secondary: const Color(0xFF4387F4),
        surface: Colors.white,
        brightness: Brightness.light,
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
    );

    final dark = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF071D24),
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyan,
        primary: aqua,
        secondary: const Color(0xFF6DA8FF),
        surface: const Color(0xFF102A33),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF071D24),
        surfaceTintColor: Color(0xFF071D24),
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: const Color(0xFF0B252E),
        indicatorColor: const Color(0xFF123E49),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? aqua
                : Colors.white60,
          ),
        ),
      ),
    );

    return _AppPreferences(
      language: language,
      mode: mode,
      setLanguage: setLanguage,
      setMode: setMode,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JeevanSetu',
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        builder: (context, child) => _ExplainOverlay(child: child ?? const SizedBox()),
        home: const PremiumSplashPage(),
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

  String get short => switch (this) {
        AppLanguage.english => 'EN',
        AppLanguage.hindi => 'हि',
        AppLanguage.nepali => 'ने',
      };
}

class _AppPreferences extends InheritedWidget {
  final AppLanguage language;
  final ThemeMode mode;
  final ValueChanged<AppLanguage> setLanguage;
  final ValueChanged<ThemeMode> setMode;

  const _AppPreferences({
    required this.language,
    required this.mode,
    required this.setLanguage,
    required this.setMode,
    required super.child,
  });

  static _AppPreferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppPreferences>()!;
  }

  @override
  bool updateShouldNotify(covariant _AppPreferences oldWidget) {
    return language != oldWidget.language || mode != oldWidget.mode;
  }
}

String tr(BuildContext context, String en, String hi, String ne) {
  return switch (_AppPreferences.of(context).language) {
    AppLanguage.english => en,
    AppLanguage.hindi => hi,
    AppLanguage.nepali => ne,
  };
}

const _mountainImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1800';
const _riskImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas.jpg?width=1800';
const _rescueImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=1800';

class _CinematicNetworkBackdrop extends StatefulWidget {
  final String url;
  final Widget child;
  final double darkness;
  const _CinematicNetworkBackdrop({
    required this.url,
    required this.child,
    this.darkness = .28,
  });

  @override
  State<_CinematicNetworkBackdrop> createState() => _CinematicNetworkBackdropState();
}

class _CinematicNetworkBackdropState extends State<_CinematicNetworkBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion;

  @override
  void initState() {
    super.initState();
    motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (_, __) => Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1.04 + motion.value * .035,
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const _PremiumImageFallback();
              },
              errorBuilder: (_, __, ___) => const _PremiumImageFallback(),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: widget.darkness)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x10000000),
                  Color(0x3D032833),
                  Color(0xF2032833),
                ],
                stops: [.08, .52, 1],
              ),
            ),
          ),
          Positioned(
            left: -80,
            right: -80,
            top: 90 + math.sin(motion.value * math.pi * 2) * 11,
            height: 140,
            child: IgnorePointer(child: CustomPaint(painter: _AtmospherePainter(motion.value))),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _PremiumImageFallback extends StatelessWidget {
  const _PremiumImageFallback();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E708A), Color(0xFF0B4D60), deepNavy],
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final double t;
  _AtmospherePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .07);
    for (var i = 0; i < 8; i++) {
      final x = ((i * 137.0) + t * size.width * .28) % (size.width + 220) - 110;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, 28 + (i % 3) * 38),
          width: 210,
          height: 44,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => oldDelegate.t != t;
}

class PremiumSplashPage extends StatefulWidget {
  const PremiumSplashPage({super.key});

  @override
  State<PremiumSplashPage> createState() => _PremiumSplashPageState();
}

class _PremiumSplashPageState extends State<PremiumSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController logo;
  late final AnimationController progress;

  @override
  void initState() {
    super.initState();
    logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1450))
      ..forward();
    progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..forward();
    Timer(const Duration(milliseconds: 2900), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 650),
            pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const PremiumOnboardingPage()),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    logo.dispose();
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: _CinematicNetworkBackdrop(
        url: _mountainImage,
        darkness: .30,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
            child: Column(
              children: [
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: logo,
                  builder: (_, __) {
                    final curve = Curves.easeOutBack.transform(logo.value);
                    return Transform.scale(
                      scale: .55 + curve * .45,
                      child: Opacity(
                        opacity: logo.value.clamp(0, 1),
                        child: const LogoMark(size: 105),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                AnimatedBuilder(
                  animation: logo,
                  builder: (_, __) {
                    final value = Curves.easeOutCubic.transform(((logo.value - .30) / .70).clamp(0, 1));
                    return Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: const Column(
                          children: [
                            Text(
                              'JeevanSetu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Disaster Monitoring & Response',
                              style: TextStyle(color: Colors.white70, fontSize: 14.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 5),
                Text(
                  tr(
                    context,
                    'Preparing live risk intelligence',
                    'लाइव जोखिम जानकारी तैयार की जा रही है',
                    'प्रत्यक्ष जोखिम जानकारी तयार हुँदैछ',
                  ),
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
                const SizedBox(height: 11),
                AnimatedBuilder(
                  animation: progress,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: Curves.easeInOutCubic.transform(progress.value),
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

class PremiumOnboardingPage extends StatefulWidget {
  const PremiumOnboardingPage({super.key});

  @override
  State<PremiumOnboardingPage> createState() => _PremiumOnboardingPageState();
}

class _PremiumOnboardingPageState extends State<PremiumOnboardingPage> {
  final PageController controller = PageController();
  int index = 0;

  List<({String title, String body, String image})> slides(BuildContext context) => [
        (
          title: tr(
            context,
            'Safer Communities\nwith Smarter Monitoring',
            'स्मार्ट निगरानी से\nसुरक्षित समुदाय',
            'स्मार्ट निगरानीसँग\nसुरक्षित समुदाय',
          ),
          body: tr(
            context,
            'AI-powered landslide intelligence combines rainfall, soil saturation, terrain and community evidence for earlier warning.',
            'AI आधारित भूस्खलन प्रणाली बारिश, मिट्टी की नमी, भू-ढलान और सामुदायिक संकेतों को जोड़कर जल्दी चेतावनी देती है।',
            'AI आधारित पहिरो प्रणालीले वर्षा, माटोको चिस्यान, भू-ढलान र सामुदायिक संकेत मिलाएर छिटो चेतावनी दिन्छ।',
          ),
          image: _mountainImage,
        ),
        (
          title: tr(context, 'Real-Time Risk\nIntelligence', 'रियल-टाइम जोखिम\nइंटेलिजेंस', 'रियल-टाइम जोखिम\nजानकारी'),
          body: tr(
            context,
            'Live Nepal maps, explainable AI scoring, safe-route intelligence, sensors and verified alerts in one operational view.',
            'लाइव नेपाल मैप, समझने योग्य AI स्कोर, सुरक्षित मार्ग, सेंसर और सत्यापित अलर्ट एक ही जगह।',
            'लाइभ नेपाल नक्सा, बुझिने AI स्कोर, सुरक्षित मार्ग, सेन्सर र प्रमाणित सूचना एउटै स्थानमा।',
          ),
          image: _riskImage,
        ),
        (
          title: tr(context, 'Report · Respond\n· Stay Safe', 'रिपोर्ट · रिस्पॉन्ड\n· सुरक्षित रहें', 'रिपोर्ट · प्रतिक्रिया\n· सुरक्षित रहनुहोस्'),
          body: tr(
            context,
            'Citizens, rescuers, authorities, volunteers and organisations share one coordinated response network when minutes matter.',
            'नागरिक, बचाव दल, अधिकारी, स्वयंसेवक और संगठन एक ही समन्वित प्रतिक्रिया नेटवर्क में जुड़े रहते हैं।',
            'नागरिक, उद्धार टोली, अधिकारी, स्वयंसेवक र संस्था एउटै समन्वित प्रतिक्रिया सञ्जालमा जोडिन्छन्।',
          ),
          image: _rescueImage,
        ),
      ];

  void next() {
    if (index < 2) {
      controller.nextPage(duration: const Duration(milliseconds: 480), curve: Curves.easeOutCubic);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RolePickerPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = slides(context);
    return Scaffold(
      backgroundColor: deepNavy,
      body: PageView.builder(
        controller: controller,
        itemCount: data.length,
        onPageChanged: (value) => setState(() => index = value),
        itemBuilder: (_, i) {
          final slide = data[i];
          return _CinematicNetworkBackdrop(
            url: slide.image,
            darkness: i == 2 ? .34 : .25,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntroControlBar(onSkip: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RolePickerPage()))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        i == 0 ? 'PREDICT' : i == 1 ? 'UNDERSTAND' : 'RESPOND',
                        style: const TextStyle(color: aqua, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        height: 1.03,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      slide.body,
                      style: const TextStyle(color: Colors.white70, fontSize: 14.2, height: 1.45),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text('${i + 1} / 3', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 12),
                        ...List.generate(
                          3,
                          (dot) => AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.only(right: 5),
                            width: dot == i ? 25 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: dot == i ? aqua : Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RolePickerPage())),
                          child: Text(tr(context, 'Skip', 'स्किप', 'छोड्नुहोस्'), style: const TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 5),
                        FloatingActionButton.small(
                          heroTag: 'premium_intro_$i',
                          elevation: 0,
                          backgroundColor: aqua,
                          foregroundColor: navy,
                          onPressed: next,
                          child: Icon(i == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded),
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

class _IntroControlBar extends StatelessWidget {
  final VoidCallback onSkip;
  const _IntroControlBar({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final pref = _AppPreferences.of(context);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .22),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white24),
          ),
          child: PopupMenuButton<AppLanguage>(
            color: const Color(0xFF0C3440),
            tooltip: 'Language',
            initialValue: pref.language,
            onSelected: pref.setLanguage,
            itemBuilder: (_) => AppLanguage.values
                .map((lang) => PopupMenuItem(
                      value: lang,
                      child: Text(lang.label, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.translate_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(pref.language.short, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60, size: 17),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.black.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () => pref.setMode(pref.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(pref.mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white, size: 19),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .20), borderRadius: BorderRadius.circular(99)),
          child: const Row(
            children: [
              CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF20C98A)),
              SizedBox(width: 6),
              Text('READY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5, letterSpacing: .8)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small persistent assistant affordance. It does not change existing screens;
/// it gives judges/users an explanation of what the current product is doing.
class _ExplainOverlay extends StatefulWidget {
  final Widget child;
  const _ExplainOverlay({required this.child});

  @override
  State<_ExplainOverlay> createState() => _ExplainOverlayState();
}

class _ExplainOverlayState extends State<_ExplainOverlay> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (open)
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 28, offset: Offset(0, 12))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 42, height: 42, decoration: BoxDecoration(color: cyan.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.auto_awesome_rounded, color: cyan)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr(context, 'Explain JeevanSetu', 'JeevanSetu समझाएँ', 'JeevanSetu बुझाउनुहोस्'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                  Text(tr(context, 'Judge / user walkthrough assistant', 'जज / यूज़र वॉकथ्रू असिस्टेंट', 'जज / प्रयोगकर्ता वाकथ्रु सहायक'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55), fontSize: 10)),
                                ],
                              ),
                            ),
                            IconButton(onPressed: () => setState(() => open = false), icon: const Icon(Icons.close_rounded)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr(
                            context,
                            'JeevanSetu predicts and explains landslide risk, visualises affected zones, recommends safer evacuation routes, connects SOS requests to responders, verifies community reports and coordinates relief resources across five professional roles.',
                            'JeevanSetu भूस्खलन जोखिम का अनुमान और कारण बताता है, प्रभावित क्षेत्र दिखाता है, सुरक्षित निकासी मार्ग सुझाता है, SOS को बचाव दल से जोड़ता है, सामुदायिक रिपोर्ट सत्यापित करता है और पाँच भूमिकाओं में राहत समन्वय करता है।',
                            'JeevanSetu ले पहिरो जोखिम अनुमान र कारण बताउँछ, प्रभावित क्षेत्र देखाउँछ, सुरक्षित निकासी मार्ग सुझाउँछ, SOS लाई उद्धार टोलीसँग जोड्छ, सामुदायिक रिपोर्ट प्रमाणित गर्छ र पाँच भूमिकामा राहत समन्वय गर्छ।',
                          ),
                          style: const TextStyle(fontSize: 12, height: 1.45),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: const [
                            _ExplainChip(Icons.psychology_alt_rounded, 'Explainable AI'),
                            _ExplainChip(Icons.map_rounded, 'Live risk map'),
                            _ExplainChip(Icons.route_rounded, 'Safe routing'),
                            _ExplainChip(Icons.sos_rounded, 'SOS response'),
                            _ExplainChip(Icons.sensors_rounded, 'Sensor fusion'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!open)
          Positioned(
            right: 14,
            top: MediaQuery.of(context).padding.top + 66,
            child: SafeArea(
              child: Material(
                color: navy.withValues(alpha: .93),
                elevation: 6,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => setState(() => open = true),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.auto_awesome_rounded, color: aqua, size: 19),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExplainChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ExplainChip(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: cyan.withValues(alpha: .09), borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: cyan), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800))]),
    );
  }
}
