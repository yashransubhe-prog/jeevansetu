import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart'
    show RolePickerPage, LogoMark, deepNavy, navy, cyan, aqua, bg, ink;

/// Launch/onboarding upgrade layer only.
/// The approved JeevanSetu dashboard, map, SOS, alerts and role flows remain in
/// app.dart unchanged.
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
        builder: (context, child) => _ExplainOverlay(
          child: child ?? const SizedBox.shrink(),
        ),
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

  String get compact => switch (this) {
        AppLanguage.english => 'EN',
        AppLanguage.hindi => 'हिं',
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
    final result =
        context.dependOnInheritedWidgetOfExactType<_AppPreferences>();
    assert(result != null, 'JeevanSetu app preferences are missing.');
    return result!;
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
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1400';
const _riskImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas.jpg?width=1400';
const _rescueImage =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=1400';

/// Performance-oriented full-screen background.
/// The old version continuously scaled the full-resolution image and repainted
/// mist every frame. This version performs a short one-time entrance motion and
/// lets Flutter's image cache handle the rest.
class _FastCinematicBackdrop extends StatelessWidget {
  final String url;
  final Widget child;
  final double darkness;

  const _FastCinematicBackdrop({
    required this.url,
    required this.child,
    this.darkness = .28,
  });

  @override
  Widget build(BuildContext context) {
    final logicalWidth = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final targetWidth = (logicalWidth * dpr).round().clamp(720, 1440);
    final provider = ResizeImage(
      NetworkImage(url),
      width: targetWidth,
      policy: ResizeImagePolicy.fit,
    );

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.025, end: 1.0),
            duration: const Duration(milliseconds: 780),
            curve: Curves.easeOutCubic,
            builder: (_, scale, image) => Transform.scale(
              scale: scale,
              child: image,
            ),
            child: Image(
              image: provider,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, sync) {
                if (sync || frame != null) return child;
                return const _PremiumImageFallback();
              },
              errorBuilder: (_, __, ___) => const _PremiumImageFallback(),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: darkness)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x08000000),
                  Color(0x26032833),
                  Color(0xF5032833),
                ],
                stops: [.08, .50, 1],
              ),
            ),
          ),
          child,
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
          colors: [Color(0xFF267A95), Color(0xFF0B5265), deepNavy],
        ),
      ),
    );
  }
}

class PremiumSplashPage extends StatefulWidget {
  const PremiumSplashPage({super.key});

  @override
  State<PremiumSplashPage> createState() => _PremiumSplashPageState();
}

class _PremiumSplashPageState extends State<PremiumSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController sequence;
  Timer? navigationTimer;
  bool imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    sequence = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    )..forward();

    navigationTimer = Timer(const Duration(milliseconds: 3300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: const PremiumOnboardingPage(),
          ),
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (imagesPrecached) return;
    imagesPrecached = true;
    // Prime all three intro images while the logo sequence plays. Errors are
    // intentionally ignored because each screen has a local premium fallback.
    for (final url in const [_mountainImage, _riskImage, _rescueImage]) {
      precacheImage(ResizeImage(NetworkImage(url), width: 1080), context)
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    navigationTimer?.cancel();
    sequence.dispose();
    super.dispose();
  }

  double _interval(double start, double end) {
    return CurvedAnimation(
      parent: sequence,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ).value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepNavy,
      body: _FastCinematicBackdrop(
        url: _mountainImage,
        darkness: .31,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: AnimatedBuilder(
              animation: sequence,
              builder: (_, __) {
                final logoValue = _interval(.02, .34);
                final nameValue = _interval(.36, .63);
                final taglineValue = _interval(.62, .82);
                final progressValue = _interval(.78, 1.0);

                return Column(
                  children: [
                    const Spacer(flex: 4),
                    Opacity(
                      opacity: logoValue,
                      child: Transform.scale(
                        scale: .58 + (.42 * Curves.easeOutBack.transform(
                          logoValue.clamp(0, .999),
                        )),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .055),
                            border: Border.all(
                              color: aqua.withValues(alpha: .22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: aqua.withValues(alpha: .12 * logoValue),
                                blurRadius: 34,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const LogoMark(size: 104),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: nameValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - nameValue)),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'JeevanSetu',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Opacity(
                      opacity: taglineValue,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - taglineValue)),
                        child: const Text(
                          'Disaster Monitoring & Response',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    Opacity(
                      opacity: progressValue,
                      child: Column(
                        children: [
                          Text(
                            tr(
                              context,
                              'Preparing live risk intelligence',
                              'लाइव जोखिम जानकारी तैयार की जा रही है',
                              'प्रत्यक्ष जोखिम जानकारी तयार हुँदैछ',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 11),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 5,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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

  List<({String title, String body, String image, String eyebrow})> slides(
    BuildContext context,
  ) {
    return [
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
        eyebrow: tr(context, 'PREDICT', 'पूर्वानुमान', 'पूर्वानुमान'),
      ),
      (
        title: tr(
          context,
          'Real-Time Risk\nIntelligence',
          'रियल-टाइम जोखिम\nइंटेलिजेंस',
          'रियल-टाइम जोखिम\nजानकारी',
        ),
        body: tr(
          context,
          'Live Nepal maps, explainable AI scoring, safe-route intelligence, sensors and verified alerts in one operational view.',
          'लाइव नेपाल मैप, समझने योग्य AI स्कोर, सुरक्षित मार्ग, सेंसर और सत्यापित अलर्ट एक ही जगह।',
          'लाइभ नेपाल नक्सा, बुझिने AI स्कोर, सुरक्षित मार्ग, सेन्सर र प्रमाणित सूचना एउटै स्थानमा।',
        ),
        image: _riskImage,
        eyebrow: tr(context, 'UNDERSTAND', 'समझें', 'बुझ्नुहोस्'),
      ),
      (
        title: tr(
          context,
          'Report · Respond\n· Stay Safe',
          'रिपोर्ट · रिस्पॉन्ड\n· सुरक्षित रहें',
          'रिपोर्ट · प्रतिक्रिया\n· सुरक्षित रहनुहोस्',
        ),
        body: tr(
          context,
          'Citizens, rescuers, authorities, volunteers and organisations share one coordinated response network when minutes matter.',
          'नागरिक, बचाव दल, अधिकारी, स्वयंसेवक और संगठन एक ही समन्वित प्रतिक्रिया नेटवर्क में जुड़े रहते हैं।',
          'नागरिक, उद्धार टोली, अधिकारी, स्वयंसेवक र संस्था एउटै समन्वित प्रतिक्रिया सञ्जालमा जोडिन्छन्।',
        ),
        image: _rescueImage,
        eyebrow: tr(context, 'RESPOND', 'प्रतिक्रिया', 'प्रतिक्रिया'),
      ),
    ];
  }

  void goToRoles() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: const RolePickerPage(),
        ),
      ),
    );
  }

  void next() {
    if (index < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 330),
        curve: Curves.easeOutCubic,
      );
    } else {
      goToRoles();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = slides(context);
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: deepNavy,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: data.length,
            onPageChanged: (value) => setState(() => index = value),
            itemBuilder: (_, i) {
              final slide = data[i];
              return _FastCinematicBackdrop(
                url: slide.image,
                darkness: i == 2 ? .34 : .25,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 92, 24, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                slide.eyebrow,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: aqua,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              child: Text(
                                slide.title,
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  height: 1.04,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.body,
                              maxLines: 5,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.8,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _IntroFooter(
                              index: i,
                              onSkip: goToRoles,
                              onNext: next,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Fixed overlay: controls are no longer part of the scrolling page,
          // so they stay visible on every intro screen and every phone size.
          Positioned(
            top: safeTop + 12,
            left: 16,
            right: 16,
            child: const _AlwaysVisibleIntroControls(),
          ),
        ],
      ),
    );
  }
}

class _IntroFooter extends StatelessWidget {
  final int index;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _IntroFooter({
    required this.index,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${index + 1} / 3',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 11),
        ...List.generate(
          3,
          (dot) => AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 5),
            width: dot == index ? 23 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot == index ? aqua : Colors.white30,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSkip,
          child: Text(
            tr(context, 'Skip', 'स्किप', 'छोड्नुहोस्'),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton.small(
            heroTag: 'intro_next_$index',
            elevation: 0,
            backgroundColor: aqua,
            foregroundColor: navy,
            onPressed: onNext,
            child: Icon(
              index == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlwaysVisibleIntroControls extends StatelessWidget {
  const _AlwaysVisibleIntroControls();

  @override
  Widget build(BuildContext context) {
    final pref = _AppPreferences.of(context);
    final dark = pref.mode == ThemeMode.dark;

    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: PopupMenuButton<AppLanguage>(
              color: const Color(0xFF0B3541),
              initialValue: pref.language,
              onSelected: pref.setLanguage,
              position: PopupMenuPosition.under,
              itemBuilder: (_) => AppLanguage.values
                  .map(
                    (lang) => PopupMenuItem<AppLanguage>(
                      value: lang,
                      child: Row(
                        children: [
                          Icon(
                            pref.language == lang
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: pref.language == lang ? aqua : Colors.white54,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            lang.label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: _ControlPill(
                icon: Icons.translate_rounded,
                label: pref.language.label,
                trailing: Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => pref.setMode(
                dark ? ThemeMode.light : ThemeMode.dark,
              ),
              child: _ControlPill(
                icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                label: dark
                    ? tr(context, 'Dark', 'डार्क', 'डार्क')
                    : tr(context, 'Light', 'लाइट', 'लाइट'),
                trailing: Icons.swap_horiz_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData trailing;

  const _ControlPill({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xCC062E39),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(trailing, color: Colors.white60, size: 17),
        ],
      ),
    );
  }
}

/// Judge/user self-explanation affordance retained from the approved upgrade.
/// It is intentionally lightweight and only builds the larger panel when open.
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: cyan.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: cyan,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr(
                                        context,
                                        'Explain JeevanSetu',
                                        'JeevanSetu समझाएँ',
                                        'JeevanSetu बुझाउनुहोस्',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      tr(
                                        context,
                                        'Judge / user walkthrough assistant',
                                        'जज / यूज़र वॉकथ्रू असिस्टेंट',
                                        'जज / प्रयोगकर्ता वाकथ्रु सहायक',
                                      ),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: .55),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => open = false),
                                icon: const Icon(Icons.close_rounded),
                              ),
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
                          const Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _ExplainChip(
                                Icons.psychology_alt_rounded,
                                'Explainable AI',
                              ),
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
          ),
        if (!open)
          Positioned(
            right: 14,
            top: MediaQuery.paddingOf(context).top + 66,
            child: Material(
              color: navy.withValues(alpha: .93),
              elevation: 5,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () => setState(() => open = true),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: aqua,
                    size: 19,
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
      decoration: BoxDecoration(
        color: cyan.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cyan),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
