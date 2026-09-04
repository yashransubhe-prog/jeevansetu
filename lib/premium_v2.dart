import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'app.dart' as base;

/// JeevanSetu V2 keeps the approved visual foundation and adds five genuinely
/// different role experiences. The heavy imagery is static/cached and the only
/// continuous animations are small, isolated indicators.
class JeevanSetuPremiumV2App extends StatefulWidget {
  const JeevanSetuPremiumV2App({super.key});

  @override
  State<JeevanSetuPremiumV2App> createState() => _JeevanSetuPremiumV2AppState();
}

class _JeevanSetuPremiumV2AppState extends State<JeevanSetuPremiumV2App> {
  ThemeMode mode = ThemeMode.light;
  _Language language = _Language.english;

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: base.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: base.cyan,
        primary: base.cyan,
        secondary: base.blue,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: base.bg,
        surfaceTintColor: base.bg,
        foregroundColor: base.ink,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF061D26),
      colorScheme: ColorScheme.fromSeed(
        seedColor: base.cyan,
        primary: base.aqua,
        secondary: base.blue,
        surface: const Color(0xFF102A33),
        brightness: Brightness.dark,
      ),
    );

    return _V2Prefs(
      language: language,
      mode: mode,
      onLanguage: (v) => setState(() => language = v),
      onMode: (v) => setState(() => mode = v),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JeevanSetu',
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        builder: (context, child) => _JudgeFab(child: child ?? const SizedBox.shrink()),
        home: const _V2SplashPage(),
      ),
    );
  }
}

enum _Language { english, hindi, nepali }

extension on _Language {
  String get label => switch (this) {
        _Language.english => 'English',
        _Language.hindi => 'हिन्दी',
        _Language.nepali => 'नेपाली',
      };
}

class _V2Prefs extends InheritedWidget {
  final _Language language;
  final ThemeMode mode;
  final ValueChanged<_Language> onLanguage;
  final ValueChanged<ThemeMode> onMode;

  const _V2Prefs({
    required this.language,
    required this.mode,
    required this.onLanguage,
    required this.onMode,
    required super.child,
  });

  static _V2Prefs of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_V2Prefs>()!;

  @override
  bool updateShouldNotify(covariant _V2Prefs oldWidget) =>
      language != oldWidget.language || mode != oldWidget.mode;
}

String _tr(BuildContext context, String en, String hi, String ne) {
  return switch (_V2Prefs.of(context).language) {
    _Language.english => en,
    _Language.hindi => hi,
    _Language.nepali => ne,
  };
}

const _mountain =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1200';
const _riskMountain =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas.jpg?width=1200';
const _helicopter =
    'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=1200';

class _FastPhoto extends StatelessWidget {
  final String url;
  final int fallbackScene;
  final BoxFit fit;
  const _FastPhoto(this.url, {required this.fallbackScene, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(720, 1280);
    return RepaintBoundary(
      child: Image(
        image: ResizeImage(NetworkImage(url), width: width),
        fit: fit,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        frameBuilder: (_, child, frame, sync) {
          if (sync || frame != null) return child;
          return base.ReferencePhoto(fallbackScene, fit: fit);
        },
        errorBuilder: (_, __, ___) => base.ReferencePhoto(fallbackScene, fit: fit),
      ),
    );
  }
}

class _V2SplashPage extends StatefulWidget {
  const _V2SplashPage();

  @override
  State<_V2SplashPage> createState() => _V2SplashPageState();
}

class _V2SplashPageState extends State<_V2SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController sequence;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sequence = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2750),
    )..forward();
    timer = Timer(const Duration(milliseconds: 3250), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        _route(const _V2OnboardingPage()),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    sequence.dispose();
    super.dispose();
  }

  double interval(double a, double b) => CurvedAnimation(
        parent: sequence,
        curve: Interval(a, b, curve: Curves.easeOutCubic),
      ).value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: base.deepNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _FastPhoto(_mountain, fallbackScene: 0),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xA0053D4E), Color(0xF8032833)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: AnimatedBuilder(
                animation: sequence,
                builder: (_, __) {
                  final logo = interval(.03, .34);
                  final name = interval(.35, .60);
                  final tagline = interval(.60, .79);
                  return Column(
                    children: [
                      const Spacer(flex: 4),
                      Opacity(
                        opacity: logo,
                        child: Transform.scale(
                          scale: .62 + .38 * Curves.easeOutBack.transform(logo.clamp(0, .999)),
                          child: Container(
                            width: 132,
                            height: 132,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: base.aqua.withValues(alpha: .26)),
                              color: Colors.white.withValues(alpha: .035),
                            ),
                            child: const base.LogoMark(size: 105),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Opacity(
                        opacity: name,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - name)),
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
                      ),
                      const SizedBox(height: 5),
                      Opacity(
                        opacity: tagline,
                        child: const Text(
                          'Disaster Monitoring & Response',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14.5),
                        ),
                      ),
                      const Spacer(flex: 5),
                      Opacity(
                        opacity: interval(.78, 1),
                        child: Column(
                          children: [
                            Text(
                              _tr(
                                context,
                                'Preparing live risk intelligence',
                                'लाइव जोखिम जानकारी तैयार की जा रही है',
                                'प्रत्यक्ष जोखिम जानकारी तयार हुँदैछ',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: interval(.78, 1),
                                minHeight: 5,
                                backgroundColor: Colors.white24,
                                color: Colors.white,
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
        ],
      ),
    );
  }
}

class _V2OnboardingPage extends StatefulWidget {
  const _V2OnboardingPage();

  @override
  State<_V2OnboardingPage> createState() => _V2OnboardingPageState();
}

class _V2OnboardingPageState extends State<_V2OnboardingPage> {
  final controller = PageController();
  int page = 0;

  List<({String title, String body, String image, int scene, String eyebrow})>
      slides(BuildContext context) => [
        (
          title: _tr(context, 'Safer Communities\nwith Smarter Monitoring',
              'स्मार्ट निगरानी से\nसुरक्षित समुदाय', 'स्मार्ट निगरानीसँग\nसुरक्षित समुदाय'),
          body: _tr(
              context,
              'AI-powered landslide intelligence combines rainfall, soil saturation, terrain and community evidence for earlier warning.',
              'AI आधारित भूस्खलन प्रणाली बारिश, मिट्टी की नमी, भू-ढलान और सामुदायिक संकेतों को जोड़कर जल्दी चेतावनी देती है।',
              'AI आधारित पहिरो प्रणालीले वर्षा, माटोको चिस्यान, भू-ढलान र सामुदायिक संकेत मिलाएर छिटो चेतावनी दिन्छ।'),
          image: _mountain,
          scene: 1,
          eyebrow: 'PREDICT',
        ),
        (
          title: _tr(context, 'Real-Time Risk\nIntelligence', 'रियल-टाइम जोखिम\nइंटेलिजेंस', 'रियल-टाइम जोखिम\nजानकारी'),
          body: _tr(
              context,
              'Live Nepal maps, explainable AI scoring, safe-route intelligence, sensors and verified alerts in one operational view.',
              'लाइव नेपाल मैप, समझने योग्य AI स्कोर, सुरक्षित मार्ग, सेंसर और सत्यापित अलर्ट एक ही जगह।',
              'लाइभ नेपाल नक्सा, बुझिने AI स्कोर, सुरक्षित मार्ग, सेन्सर र प्रमाणित सूचना एउटै स्थानमा।'),
          image: _riskMountain,
          scene: 2,
          eyebrow: 'UNDERSTAND',
        ),
        (
          title: _tr(context, 'Report · Respond\n· Stay Safe', 'रिपोर्ट · रिस्पॉन्ड\n· सुरक्षित रहें', 'रिपोर्ट · प्रतिक्रिया\n· सुरक्षित रहनुहोस्'),
          body: _tr(
              context,
              'Citizens, rescuers, authorities, volunteers and organisations share one coordinated response network when minutes matter.',
              'नागरिक, बचाव दल, अधिकारी, स्वयंसेवक और संगठन एक ही समन्वित प्रतिक्रिया नेटवर्क में जुड़े रहते हैं।',
              'नागरिक, उद्धार टोली, अधिकारी, स्वयंसेवक र संस्था एउटै समन्वित प्रतिक्रिया सञ्जालमा जोडिन्छन्।'),
          image: _helicopter,
          scene: 3,
          eyebrow: 'RESPOND',
        ),
      ];

  void next() {
    if (page < 2) {
      controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      Navigator.push(context, _route(const _V2RolePickerPage()));
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
    return Scaffold(
      backgroundColor: base.deepNavy,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: 3,
            onPageChanged: (v) => setState(() => page = v),
            itemBuilder: (_, i) {
              final s = data[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  _FastPhoto(s.image, fallbackScene: s.scene),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x08000000), Color(0x25032833), Color(0xF8032833)],
                        stops: [.08, .49, 1],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 94, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          _Pill(s.eyebrow, base.aqua, dark: true),
                          const SizedBox(height: 12),
                          Text(
                            s.title,
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
                          const SizedBox(height: 14),
                          Text(
                            s.body,
                            maxLines: 5,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(color: Colors.white70, fontSize: 13.8, height: 1.43),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text('${i + 1} / 3', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 11),
                              ...List.generate(3, (d) => AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 5),
                                width: d == i ? 23 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: d == i ? base.aqua : Colors.white30,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.push(context, _route(const _V2RolePickerPage())),
                                child: Text(_tr(context, 'Skip', 'स्किप', 'छोड्नुहोस्'), style: const TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: FloatingActionButton.small(
                                  heroTag: 'v2_intro_$i',
                                  elevation: 0,
                                  backgroundColor: base.aqua,
                                  foregroundColor: base.navy,
                                  onPressed: next,
                                  child: Icon(i == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 26),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: const _IntroControls(),
          ),
        ],
      ),
    );
  }
}

class _IntroControls extends StatelessWidget {
  const _IntroControls();

  @override
  Widget build(BuildContext context) {
    final pref = _V2Prefs.of(context);
    final dark = pref.mode == ThemeMode.dark;
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<_Language>(
            color: const Color(0xFF0B3541),
            initialValue: pref.language,
            position: PopupMenuPosition.under,
            onSelected: pref.onLanguage,
            itemBuilder: (_) => _Language.values.map((l) => PopupMenuItem(
              value: l,
              child: Text(l.label, style: const TextStyle(color: Colors.white)),
            )).toList(),
            child: _GlassControl(
              icon: Icons.translate_rounded,
              label: pref.language.label,
              trailing: Icons.keyboard_arrow_down_rounded,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => pref.onMode(dark ? ThemeMode.light : ThemeMode.dark),
            child: _GlassControl(
              icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              label: dark ? _tr(context, 'Dark', 'डार्क', 'डार्क') : _tr(context, 'Light', 'लाइट', 'लाइट'),
              trailing: Icons.swap_horiz_rounded,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData trailing;
  const _GlassControl({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: base.deepNavy.withValues(alpha: .84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(width: 8),
          Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          Icon(trailing, color: Colors.white60, size: 18),
        ],
      ),
    );
  }
}

class _V2RolePickerPage extends StatelessWidget {
  const _V2RolePickerPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: base.deepNavy,
      body: SafeArea(
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
            const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            const Text('Select your role to open a purpose-built response experience.', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
            const SizedBox(height: 22),
            ...base.UserRole.values.map((role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.push(context, _route(_V2LoginPage(role: role))),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [role.color, role.color.withValues(alpha: .72)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: role.color.withValues(alpha: .22), blurRadius: 20, offset: const Offset(0, 9))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(14)),
                          child: Icon(role.icon, color: role.color),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(role.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 3),
                              Text(role.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
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
    );
  }
}

class _V2LoginPage extends StatelessWidget {
  final base.UserRole role;
  const _V2LoginPage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: base.deepNavy,
      body: SafeArea(
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
                    const base.LogoMark(size: 76),
                    const SizedBox(height: 7),
                    const Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    _Pill('${role.title} access', role.color, dark: true),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
              const Text('Sign in to continue', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 23),
              const _LoginField(Icons.person_outline_rounded, 'Email or Phone'),
              const SizedBox(height: 11),
              const _LoginField(Icons.lock_outline_rounded, 'Password', obscure: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: role.color, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, _route(_RoleShell(role: role)), (_) => false),
                  child: Text('Sign in as ${role.title}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, _route(_RoleShell(role: role)), (_) => false),
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

class _LoginField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  const _LoginField(this.icon, this.hint, {this.obscure = false});

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white60),
          filled: true,
          fillColor: Colors.white.withValues(alpha: .09),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: base.aqua)),
        ),
      );
}

Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: page,
      ),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween(begin: const Offset(.025, .008), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

class _RoleShell extends StatefulWidget {
  final base.UserRole role;
  const _RoleShell({required this.role});

  @override
  State<_RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<_RoleShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final experience = _experienceFor(widget.role);
    return Scaffold(
      backgroundColor: experience.background,
      body: IndexedStack(index: index, children: experience.pages),
      bottomNavigationBar: _RoleNav(
        role: widget.role,
        index: index,
        labels: experience.labels,
        icons: experience.icons,
        onChanged: (v) => setState(() => index = v),
      ),
    );
  }
}

class _Experience {
  final Color background;
  final List<Widget> pages;
  final List<String> labels;
  final List<IconData> icons;
  const _Experience(this.background, this.pages, this.labels, this.icons);
}

_Experience _experienceFor(base.UserRole role) {
  switch (role) {
    case base.UserRole.citizen:
      return const _Experience(
        base.bg,
        [_CitizenHome(), base.RiskMapPage(), _CitizenSosPage(), _CitizenAlertsPage(), _CitizenMorePage()],
        ['Home', 'Map', 'SOS', 'Alerts', 'More'],
        [Icons.home_rounded, Icons.map_rounded, Icons.sos_rounded, Icons.notifications_rounded, Icons.grid_view_rounded],
      );
    case base.UserRole.rescue:
      return const _Experience(
        Color(0xFF071017),
        [_RescueHome(), _RescueMap(), _RescueDispatchPage(), _RescueAlerts(), _RescueMore()],
        ['Ops', 'Tactical', 'Dispatch', 'Signals', 'More'],
        [Icons.radar_rounded, Icons.map_rounded, Icons.emergency_share_rounded, Icons.notifications_active_rounded, Icons.grid_view_rounded],
      );
    case base.UserRole.authority:
      return const _Experience(
        Color(0xFFF2F6FC),
        [_AuthorityHome(), _AuthorityMap(), _AuthorityBroadcast(), _AuthorityAlerts(), _AuthorityMore()],
        ['Command', 'GIS', 'Broadcast', 'Alerts', 'More'],
        [Icons.dashboard_customize_rounded, Icons.public_rounded, Icons.campaign_rounded, Icons.notifications_rounded, Icons.apps_rounded],
      );
    case base.UserRole.volunteer:
      return const _Experience(
        Color(0xFFF8F4FC),
        [_VolunteerHome(), _VolunteerMap(), _VolunteerCheckIn(), _VolunteerUpdates(), _VolunteerMore()],
        ['Hub', 'Tasks', 'Check-in', 'Updates', 'More'],
        [Icons.favorite_rounded, Icons.map_rounded, Icons.how_to_reg_rounded, Icons.dynamic_feed_rounded, Icons.grid_view_rounded],
      );
    case base.UserRole.organization:
      return const _Experience(
        Color(0xFFFFF8ED),
        [_OrganizationHome(), _OrganizationMap(), _OrganizationSupport(), _OrganizationAlerts(), _OrganizationMore()],
        ['Overview', 'Facilities', 'Support', 'Alerts', 'More'],
        [Icons.business_center_rounded, Icons.location_city_rounded, Icons.support_agent_rounded, Icons.inventory_rounded, Icons.grid_view_rounded],
      );
  }
}

class _RoleNav extends StatelessWidget {
  final base.UserRole role;
  final int index;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;
  const _RoleNav({required this.role, required this.index, required this.labels, required this.icons, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dark = role == base.UserRole.rescue;
    return Material(
      elevation: 14,
      color: dark ? const Color(0xFF0C1820) : Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(5, (i) {
              final active = index == i;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: active ? 48 : 38,
                        height: 32,
                        decoration: BoxDecoration(
                          color: active ? role.color.withValues(alpha: dark ? .24 : .13) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(icons[i], color: active ? role.color : (dark ? Colors.white54 : const Color(0xFF5F6D72)), size: 21),
                      ),
                      const SizedBox(height: 2),
                      Text(labels[i], maxLines: 1, style: TextStyle(fontSize: 8.5, fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: active ? role.color : (dark ? Colors.white54 : const Color(0xFF607078)))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Citizen – keeps the approved foundation but upgrades the weak screens.
// ---------------------------------------------------------------------------

class _CitizenHome extends StatelessWidget {
  const _CitizenHome();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF05677A), base.deepNavy], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(backgroundColor: base.green, child: Icon(Icons.person_rounded, color: Colors.white)),
                      SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Namaste,', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        Text('Citizen', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      ]),
                      Spacer(),
                      _LiveDot(text: 'MONITORED'),
                    ],
                  ),
                  const SizedBox(height: 42),
                  const Text('NEPAL RISK INTELLIGENCE', style: TextStyle(color: base.aqua, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.15)),
                  const SizedBox(height: 6),
                  const Text('Know the slope\nbefore it moves.', style: TextStyle(color: Colors.white, fontSize: 29, height: .98, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                  const SizedBox(height: 16),
                  const Row(children: [
                    Expanded(child: _HeroMetric('RISK', '78%', base.red)),
                    SizedBox(width: 8),
                    Expanded(child: _HeroMetric('24H RAIN', '126 mm', base.blue)),
                    SizedBox(width: 8),
                    Expanded(child: _HeroMetric('SAFE HUBS', '18', base.green)),
                  ]),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            sliver: SliverList.list(children: [
              _RiskActionBanner(onTap: () => Navigator.push(context, _route(const _CitizenRiskAnalysisPage()))),
              const SizedBox(height: 12),
              const Row(children: [
                Expanded(child: _MetricCard(Icons.cloudy_snowing, base.blue, '12°C', 'Heavy rain')),
                SizedBox(width: 9),
                Expanded(child: _MetricCard(Icons.water_drop_rounded, base.cyan, '87%', 'Soil saturation')),
              ]),
              const SizedBox(height: 18),
              _section('Safety tools', 'Live, actionable and one tap away'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: 1.02,
                children: [
                  _QuickTile(Icons.map_rounded, base.green, 'Live Risk\nMap', () => Navigator.push(context, _route(const base.RiskMapPage()))),
                  _QuickTile(Icons.route_rounded, base.cyan, 'Safe\nRoute', () => Navigator.push(context, _route(const base.SafeRoutePage()))),
                  _QuickTile(Icons.psychology_alt_rounded, base.blue, 'AI Risk\nAnalysis', () => Navigator.push(context, _route(const _CitizenRiskAnalysisPage()))),
                  _QuickTile(Icons.post_add_rounded, base.orange, 'Report\nIncident', () => Navigator.push(context, _route(const base.ReportIncidentPage()))),
                  _QuickTile(Icons.inventory_2_rounded, base.green, 'Relief &\nResources', () => Navigator.push(context, _route(const _VisualResourcesPage()))),
                  _QuickTile(Icons.smart_toy_rounded, base.purple, 'AI Safety\nAssistant', () => Navigator.push(context, _route(const base.AssistantPage()))),
                ],
              ),
              const SizedBox(height: 18),
              _GradientAction(
                icon: Icons.family_restroom_rounded,
                title: 'Personal Safety',
                subtitle: '4 family members · 3 safe · 1 awaiting check-in',
                colors: const [base.navy, Color(0xFF0D866F)],
                onTap: () => Navigator.push(context, _route(const _CitizenPersonalSafetyPage())),
              ),
              const SizedBox(height: 18),
              _section('AI Slope Sentinel', 'Explainable risk, not a black box'),
              const SizedBox(height: 10),
              _Surface(
                child: Row(children: [
                  const _AnimatedGauge(value: .78, color: base.red, size: 86),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('High landslide probability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Rainfall + soil saturation + slope geometry are driving the score.', style: TextStyle(color: Colors.black45, fontSize: 10.5, height: 1.3)),
                    const SizedBox(height: 7),
                    InkWell(onTap: () => Navigator.push(context, _route(const _CitizenRiskAnalysisPage())), child: const Text('WHY THIS SCORE  →', style: TextStyle(color: base.blue, fontSize: 9, fontWeight: FontWeight.w900))),
                  ])),
                ]),
              ),
              const SizedBox(height: 18),
              _section('Community pulse', 'Verified signals around you'),
              const SizedBox(height: 10),
              const _Surface(child: Column(children: [
                _Signal(Icons.landscape_rounded, base.red, 'Slope movement reported', 'Sindhupalchok · 2.4 km', '92% AI verified'),
                Divider(),
                _Signal(Icons.route_rounded, base.orange, 'Road partially blocked', 'Araniko Highway · 4.1 km', '3 reports'),
              ])),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CitizenRiskAnalysisPage extends StatefulWidget {
  const _CitizenRiskAnalysisPage();

  @override
  State<_CitizenRiskAnalysisPage> createState() => _CitizenRiskAnalysisPageState();
}

class _CitizenRiskAnalysisPageState extends State<_CitizenRiskAnalysisPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController entrance;
  bool forecast = false;

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 230,
              child: Stack(fit: StackFit.expand, children: [
                const _FastPhoto(_riskMountain, fallbackScene: 2),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30000000), Color(0xEB032833)]))),
                Positioned(top: 8, left: 8, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
                const Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Pill('EXPLAINABLE AI · LIVE', base.aqua, dark: true),
                  SizedBox(height: 9),
                  Text('AI Risk Analysis', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
                  Text('Sindhupalchok · evidence updated 14 sec ago', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                ])),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: _SegmentButton('Current', !forecast, () => setState(() => forecast = false))),
                  const SizedBox(width: 8),
                  Expanded(child: _SegmentButton('Next 48 Hours', forecast, () => setState(() => forecast = true))),
                ]),
                const SizedBox(height: 12),
                _Surface(
                  child: AnimatedBuilder(
                    animation: entrance,
                    builder: (_, __) => Column(children: [
                      Row(children: [
                        SizedBox(width: 118, height: 118, child: CustomPaint(painter: _RingPainter(.78 * Curves.easeOutCubic.transform(entrance.value), base.red), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('${(78 * entrance.value).round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                          const Text('HIGH RISK', style: TextStyle(color: base.red, fontSize: 9, fontWeight: FontWeight.w900)),
                        ])))),
                        const SizedBox(width: 14),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [Icon(Icons.verified_rounded, color: base.green, size: 18), SizedBox(width: 5), Text('Confidence 92%', style: TextStyle(color: base.green, fontSize: 10, fontWeight: FontWeight.w900))]),
                          SizedBox(height: 7),
                          Text('Slope failure probability is elevated in the next 12 hours.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, height: 1.2)),
                          SizedBox(height: 5),
                          Text('Model is using rain, soil, terrain, sensor movement and community evidence.', style: TextStyle(color: Colors.black45, fontSize: 10.2, height: 1.35)),
                        ])),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                _section('Why the AI is concerned', 'Every factor is visible and auditable'),
                const SizedBox(height: 9),
                const _Surface(child: Column(children: [
                  _FactorRow(Icons.water_drop_outlined, base.blue, 'Rainfall (24h)', '126 mm', .92),
                  _FactorRow(Icons.water_rounded, base.cyan, 'Soil saturation', '87%', .87),
                  _FactorRow(Icons.sensors_rounded, base.red, 'Slope movement', '2.8 mm', .81),
                  _FactorRow(Icons.change_history_rounded, base.purple, 'Terrain slope', '38°', .79),
                ])),
                const SizedBox(height: 14),
                const _AIExplanationCard(),
                const SizedBox(height: 14),
                _section('Risk trajectory', '48-hour nowcast · confidence band'),
                const SizedBox(height: 9),
                const _Surface(child: SizedBox(height: 150, child: CustomPaint(painter: _TrendGraphPainter()))),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(const base.RiskMapPage())), icon: const Icon(Icons.map_rounded), label: const Text('Affected zones'))),
                  const SizedBox(width: 8),
                  Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, _route(const base.SafeRoutePage())), icon: const Icon(Icons.route_rounded), label: const Text('Safe route'))),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitizenSosPage extends StatefulWidget {
  const _CitizenSosPage();

  @override
  State<_CitizenSosPage> createState() => _CitizenSosPageState();
}

class _CitizenSosPageState extends State<_CitizenSosPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  String emergency = 'Landslide / trapped';
  int people = 2;
  bool medical = false;
  bool evidence = false;
  bool locationLocked = true;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  void sendEmergency() {
    HapticFeedback.mediumImpact();
    Navigator.push(context, _route(_EmergencyTrackingPage(emergency: emergency, people: people, medical: medical)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Row(children: [
            Text('SOS Emergency', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            Spacer(),
            _LiveDot(text: 'GPS LOCKED'),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 156,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: Stack(fit: StackFit.expand, children: [
              const _FastPhoto(_helicopter, fallbackScene: 3),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xD9032833), Color(0x50300000)]))),
              const Positioned(left: 16, top: 16, child: _Pill('RESCUE NETWORK ONLINE', base.aqua, dark: true)),
              Positioned(left: 16, right: 16, bottom: 14, child: Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Nearest response unit', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                  Text('Team Alpha · 6.2 km', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                  Text('Estimated dispatch 11 min', style: TextStyle(color: base.aqua, fontSize: 10.5, fontWeight: FontWeight.w700)),
                ])),
                _RoundAction(Icons.call_rounded, base.green, () => Navigator.push(context, _route(const _InAppCallPage(name: 'Team Alpha', role: 'Rescue Team', video: false)))),
                const SizedBox(width: 8),
                _RoundAction(Icons.videocam_rounded, base.blue, () => Navigator.push(context, _route(const _InAppCallPage(name: 'Team Alpha', role: 'Rescue Team', video: true)))),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          Center(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => GestureDetector(
                onLongPress: sendEmergency,
                child: Container(
                  width: 184 + pulse.value * 9,
                  height: 184 + pulse.value * 9,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: base.red.withValues(alpha: .10), boxShadow: [BoxShadow(color: base.red.withValues(alpha: .16), blurRadius: 28, spreadRadius: 5)]),
                  alignment: Alignment.center,
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF5C71), base.red])),
                    alignment: Alignment.center,
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      Text('PRESS & HOLD', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          _Surface(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.crisis_alert_rounded, color: base.navy),
                title: const Text('Type of Emergency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                subtitle: Text(emergency, style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.unfold_more_rounded),
                onTap: () => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => _EmergencyPicker(current: emergency, onPick: (v) { setState(() => emergency = v); Navigator.pop(context); })),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.groups_rounded, color: base.navy),
                title: const Text('People needing help', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                subtitle: Text('$people people', style: const TextStyle(fontSize: 10)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(onPressed: () => setState(() => people = math.max(1, people - 1)), icon: const Icon(Icons.remove_circle_outline_rounded)),
                  IconButton(onPressed: () => setState(() => people++), icon: const Icon(Icons.add_circle_outline_rounded)),
                ]),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.medical_services_outlined, color: base.red),
                title: const Text('Medical priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                subtitle: const Text('Route request to medical responders first', style: TextStyle(fontSize: 9.5)),
                value: medical,
                onChanged: (v) => setState(() => medical = v),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.my_location_rounded, color: base.green),
                title: const Text('Live location beacon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                subtitle: Text(locationLocked ? 'Sharing location every 15 sec' : 'Location sharing paused', style: const TextStyle(fontSize: 9.5)),
                value: locationLocked,
                onChanged: (v) => setState(() => locationLocked = v),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(evidence ? Icons.check_circle_rounded : Icons.add_a_photo_outlined, color: evidence ? base.green : base.navy),
                title: const Text('Photo / Video Evidence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                subtitle: Text(evidence ? 'Evidence packet attached · compressed locally' : 'Attach a scene snapshot for responders', style: const TextStyle(fontSize: 9.5)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => setState(() => evidence = !evidence),
              ),
            ]),
          ),
          const SizedBox(height: 13),
          SizedBox(height: 54, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: base.red), onPressed: sendEmergency, icon: const Icon(Icons.emergency_share_rounded), label: const Text('Send Emergency Request', style: TextStyle(fontWeight: FontWeight.w900)))),
          const SizedBox(height: 9),
          const Text('Works with last cached risk zone and emergency contacts when data connectivity is degraded.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 9.2)),
        ],
      ),
    );
  }
}

class _EmergencyPicker extends StatelessWidget {
  final String current;
  final ValueChanged<String> onPick;
  const _EmergencyPicker({required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    const items = ['Landslide / trapped', 'Flood / stranded', 'Medical emergency', 'Road accident', 'Fire / infrastructure'];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: items.map((e) => ListTile(
          leading: Icon(e == current ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: e == current ? base.cyan : Colors.black38),
          title: Text(e, style: const TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => onPick(e),
        )).toList()),
      ),
    );
  }
}

class _EmergencyTrackingPage extends StatefulWidget {
  final String emergency;
  final int people;
  final bool medical;
  const _EmergencyTrackingPage({required this.emergency, required this.people, required this.medical});

  @override
  State<_EmergencyTrackingPage> createState() => _EmergencyTrackingPageState();
}

class _EmergencyTrackingPageState extends State<_EmergencyTrackingPage> {
  int eta = 11;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && eta > 4) setState(() => eta--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Tracking', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [base.red, Color(0xFFB51D42)]), borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 46),
              const SizedBox(height: 7),
              const Text('Request verified & dispatched', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('${widget.emergency} · ${widget.people} people${widget.medical ? ' · MEDICAL PRIORITY' : ''}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
            ]),
          ),
          const SizedBox(height: 12),
          _Surface(child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Color(0xFFFFE4E8), child: Icon(Icons.health_and_safety_rounded, color: base.red, size: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Team Alpha responding', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              Text('ETA $eta min · 6.2 km · GPS update live', style: const TextStyle(color: Colors.black45, fontSize: 10)),
              const SizedBox(height: 7),
              const LinearProgressIndicator(value: .64, minHeight: 7, borderRadius: BorderRadius.all(Radius.circular(8)), color: base.green, backgroundColor: Color(0xFFE4F7F0)),
            ])),
          ])),
          const SizedBox(height: 12),
          const _TimelineStep(Icons.check_rounded, base.green, 'Request received', 'Location and emergency packet verified', true),
          const _TimelineStep(Icons.local_shipping_rounded, base.blue, 'Responder dispatched', 'Team Alpha is en route', true),
          const _TimelineStep(Icons.route_rounded, base.orange, 'Approaching scene', 'Safe approach corridor calculated', false),
          const _TimelineStep(Icons.medical_services_rounded, base.red, 'On scene', 'Rescue handover and triage', false),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: base.green), onPressed: () => Navigator.push(context, _route(const _InAppCallPage(name: 'Team Alpha', role: 'Rescue Team', video: false))), icon: const Icon(Icons.call_rounded), label: const Text('Voice call'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: base.blue), onPressed: () => Navigator.push(context, _route(const _InAppCallPage(name: 'Team Alpha', role: 'Rescue Team', video: true))), icon: const Icon(Icons.videocam_rounded), label: const Text('Video call'))),
          ]),
        ],
      ),
    );
  }
}

class _CitizenAlertsPage extends StatelessWidget {
  const _CitizenAlertsPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Row(children: [
            Text('Alerts', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            Spacer(),
            _Pill('3 ACTIVE', base.red),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: Stack(fit: StackFit.expand, children: [
              const _FastPhoto(_riskMountain, fallbackScene: 2),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x20000000), Color(0xF5032833)]))),
              Positioned(left: 16, right: 16, bottom: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _Pill('CRITICAL · ACTIVE NOW', base.red, dark: true),
                const SizedBox(height: 8),
                const Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Sindhupalchok · 2.4 km · verified from 4 evidence sources', style: TextStyle(color: Colors.white70, fontSize: 10.3)),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: FilledButton.tonal(onPressed: () => Navigator.push(context, _route(const _CitizenRiskAnalysisPage())), child: const Text('Understand risk'))),
                  const SizedBox(width: 8),
                  Expanded(child: FilledButton(onPressed: () => Navigator.push(context, _route(const base.SafeRoutePage())), child: const Text('Safe route'))),
                ]),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          _VisualAlertCard(icon: Icons.cloudy_snowing, color: base.blue, tag: 'WEATHER', title: 'Heavy Rainfall Expected', subtitle: 'Next 6 hours · 126 mm / 24h', detail: 'Rain intensity rising', onTap: () => Navigator.push(context, _route(const _CitizenRiskAnalysisPage()))),
          const SizedBox(height: 10),
          _VisualAlertCard(icon: Icons.route_rounded, color: base.orange, tag: 'MOBILITY', title: 'Road Closure', subtitle: 'Araniko Highway · partial blockage', detail: 'Safe diversion ready', onTap: () => Navigator.push(context, _route(const base.SafeRoutePage()))),
          const SizedBox(height: 18),
          _section('Alert intelligence', 'Prioritised by severity, distance and confidence'),
          const SizedBox(height: 10),
          const _Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.verified_user_rounded, color: base.green), SizedBox(width: 9), Expanded(child: Text('Sensor + weather + community + authority evidence are fused before critical warnings.', style: TextStyle(fontSize: 10.5, height: 1.35)))]),
            SizedBox(height: 13),
            _ConfidenceBar('Verification confidence', .92, base.green),
            SizedBox(height: 10),
            _ConfidenceBar('Location relevance', .88, base.blue),
          ])),
          const SizedBox(height: 18),
          _section('What happens next', 'Live progression for the active warning'),
          const SizedBox(height: 10),
          const _Surface(child: Row(children: [
            Expanded(child: _MiniStage('NOW', 'Warning', base.red, true)),
            Expanded(child: _MiniStage('+2H', 'Evacuate', base.orange, true)),
            Expanded(child: _MiniStage('+6H', 'Peak rain', base.blue, false)),
          ])),
        ],
      ),
    );
  }
}

class _CitizenMorePage extends StatelessWidget {
  const _CitizenMorePage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('More', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Container(
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: Stack(fit: StackFit.expand, children: [
              const _FastPhoto(_mountain, fallbackScene: 1),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xEA032833), Color(0x80303030)]))),
              const Positioned(left: 16, right: 16, bottom: 16, child: Row(children: [
                CircleAvatar(radius: 28, backgroundColor: base.green, child: Icon(Icons.person_rounded, color: Colors.white, size: 30)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Citizen', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('JeevanSetu protected profile', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  SizedBox(height: 5),
                  _LiveDot(text: 'ONLINE · GPS SHARING'),
                ])),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          _MoreVisualTile(Icons.family_restroom_rounded, base.green, 'Personal Safety', 'Family live status, geofence & check-in', '4 members', () => Navigator.push(context, _route(const _CitizenPersonalSafetyPage()))),
          _MoreVisualTile(Icons.sensors_rounded, base.blue, 'Sensor Network', 'Rain, soil, slope and weather telemetry', '26 / 28', () => Navigator.push(context, _route(const _VisualSensorPage()))),
          _MoreVisualTile(Icons.inventory_2_rounded, base.orange, 'Relief & Resources', 'Camps, hospitals, inventory and live capacity', '18 hubs', () => Navigator.push(context, _route(const _VisualResourcesPage()))),
          _MoreVisualTile(Icons.smart_toy_rounded, base.purple, 'AI Safety Assistant', 'Context-aware safety and response guidance', 'Ready', () => Navigator.push(context, _route(const base.AssistantPage()))),
          _MoreVisualTile(Icons.offline_bolt_rounded, base.cyan, 'Offline Readiness', 'Cached safety pack, contacts and last risk map', '100%', () => Navigator.push(context, _route(const _VisualOfflinePage()))),
          _MoreVisualTile(Icons.shield_rounded, base.green, 'Safety Guidelines', 'Interactive landslide survival checklist', '4 steps', () => Navigator.push(context, _route(const _VisualGuidelinesPage()))),
          _MoreVisualTile(Icons.contact_emergency_rounded, base.red, 'Emergency Contacts', 'Voice and video communication center', '4 lines', () => Navigator.push(context, _route(const _VisualContactsPage()))),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(context, _route(const _V2RolePickerPage()), (_) => false),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Switch profession / role'),
          ),
        ],
      ),
    );
  }
}

class _CitizenPersonalSafetyPage extends StatefulWidget {
  const _CitizenPersonalSafetyPage();

  @override
  State<_CitizenPersonalSafetyPage> createState() => _CitizenPersonalSafetyPageState();
}

class _CitizenPersonalSafetyPageState extends State<_CitizenPersonalSafetyPage> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Safety', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            height: 165,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: Stack(fit: StackFit.expand, children: [
              const _FastPhoto(_mountain, fallbackScene: 1),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xF005546A), Color(0xB0087B70)]))),
              Positioned(left: 16, right: 16, bottom: 16, child: Row(children: [
                const Icon(Icons.verified_user_rounded, color: base.aqua, size: 46),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('You are in a monitored zone', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text(checked ? 'Check-in sent just now' : 'Last safety check-in 22 min ago', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ])),
                FilledButton.tonal(onPressed: () { HapticFeedback.selectionClick(); setState(() => checked = true); }, child: Text(checked ? 'Sent ✓' : 'Check in')),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          const _Surface(child: Row(children: [
            Expanded(child: _SafetyMetric('3', 'Safe now', base.green)),
            Expanded(child: _SafetyMetric('1', 'Awaiting', base.orange)),
            Expanded(child: _SafetyMetric('2.4 km', 'Risk radius', base.red)),
          ])),
          const SizedBox(height: 12),
          _FamilyVisualTile('You', 'Safe · live location', base.green, true),
          _FamilyVisualTile('Mother', 'Safe · 2 min ago', base.green, false),
          _FamilyVisualTile('Father', 'Safe · 18 min ago', base.green, false),
          _FamilyVisualTile('Sister', 'Awaiting check-in', base.orange, false),
          const SizedBox(height: 12),
          const _Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Family geofence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('Alerts when a family member enters a critical risk polygon.', style: TextStyle(color: Colors.black45, fontSize: 10.5)),
            SizedBox(height: 10),
            _ConfidenceBar('Geofence coverage', .94, base.green),
          ])),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rescue – tactical dark UI.
// ---------------------------------------------------------------------------

class _RescueHome extends StatelessWidget {
  const _RescueHome();

  @override
  Widget build(BuildContext context) {
    return _DarkRoleScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _DarkHeader(icon: Icons.health_and_safety_rounded, title: 'RESCUE // ALPHA', subtitle: 'Field command · Sindhupalchok', color: base.red),
          const SizedBox(height: 14),
          Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
            child: Stack(fit: StackFit.expand, children: [
              const _FastPhoto(_helicopter, fallbackScene: 3),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x20000000), Color(0xF2071017)]))),
              const Positioned(top: 14, left: 14, child: _Pill('MISSION JS-104 · CRITICAL', base.red, dark: true)),
              Positioned(left: 14, right: 14, bottom: 14, child: Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('4 persons trapped', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  Text('Landslide corridor · ETA 11 min', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                ])),
                _RoundAction(Icons.navigation_rounded, base.red, () {}),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _DarkMetric('11', 'RESPONDERS', base.red)),
            SizedBox(width: 8),
            Expanded(child: _DarkMetric('03', 'MISSIONS', base.orange)),
            SizedBox(width: 8),
            Expanded(child: _DarkMetric('96%', 'COMMS', base.green)),
          ]),
          const SizedBox(height: 16),
          const Text('LIVE FIELD STATUS', style: TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const _DarkPanel(child: Column(children: [
            _ResponderRow('Team Alpha', '6 responders · moving', base.green, .86),
            Divider(color: Colors.white12),
            _ResponderRow('Medical-2', '2 medics · staged', base.blue, .62),
            Divider(color: Colors.white12),
            _ResponderRow('Drone-7', 'Thermal scan · active', base.orange, .74),
          ])),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _TacticalButton(Icons.call_rounded, 'Voice Net', base.green, _openRescueCall)),
            const SizedBox(width: 8),
            Expanded(child: _TacticalButton(Icons.videocam_rounded, 'Video Link', base.blue, _openRescueVideo)),
          ]),
          const SizedBox(height: 14),
          const _DarkPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MISSION TIMELINE', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900)),
            SizedBox(height: 10),
            _DarkTimeline('09:14', 'SOS verified', base.green),
            _DarkTimeline('09:15', 'Alpha dispatched', base.blue),
            _DarkTimeline('09:18', 'Safe approach updated', base.orange),
          ])),
        ],
      ),
    );
  }

  static void _openRescueCall(BuildContext context) => Navigator.push(context, _route(const _InAppCallPage(name: 'Rescue Command', role: 'Operations Net', video: false)));
  static void _openRescueVideo(BuildContext context) => Navigator.push(context, _route(const _InAppCallPage(name: 'Rescue Command', role: 'Operations Net', video: true)));
}

class _RescueMap extends StatelessWidget {
  const _RescueMap();

  @override
  Widget build(BuildContext context) {
    return _DarkRoleScaffold(
      child: Column(children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 14, 16, 10), child: _DarkHeader(icon: Icons.radar_rounded, title: 'TACTICAL MAP', subtitle: 'Teams · victims · hazards', color: base.red)),
        Expanded(
          child: Stack(children: [
            FlutterMap(
              options: const MapOptions(initialCenter: LatLng(27.78, 85.48), initialZoom: 11.0),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sih.jeevansetu'),
                PolygonLayer(polygons: [Polygon(points: const [LatLng(27.76, 85.42), LatLng(27.81, 85.48), LatLng(27.78, 85.55), LatLng(27.73, 85.51)], color: base.red.withValues(alpha: .20), borderColor: base.red, borderStrokeWidth: 3)]),
                PolylineLayer(polylines: [Polyline(points: const [LatLng(27.742, 85.435), LatLng(27.765, 85.482), LatLng(27.802, 85.528)], strokeWidth: 6, color: base.green)]),
                const MarkerLayer(markers: [
                  Marker(point: LatLng(27.742, 85.435), width: 42, height: 42, child: _MapBadge(Icons.health_and_safety_rounded, base.green)),
                  Marker(point: LatLng(27.78, 85.49), width: 42, height: 42, child: _MapBadge(Icons.sos_rounded, base.red)),
                  Marker(point: LatLng(27.802, 85.528), width: 42, height: 42, child: _MapBadge(Icons.local_hospital_rounded, base.blue)),
                ]),
              ],
            ),
            const Positioned(top: 12, left: 12, right: 12, child: _DarkPanel(child: Row(children: [
              Expanded(child: _TinyStatus('ALPHA', 'MOVING', base.green)),
              Expanded(child: _TinyStatus('VICTIMS', '4 LOCATED', base.red)),
              Expanded(child: _TinyStatus('ETA', '11 MIN', base.orange)),
            ]))),
          ]),
        ),
      ]),
    );
  }
}

class _RescueDispatchPage extends StatefulWidget {
  const _RescueDispatchPage();

  @override
  State<_RescueDispatchPage> createState() => _RescueDispatchPageState();
}

class _RescueDispatchPageState extends State<_RescueDispatchPage> {
  int selected = 0;
  final missions = ['JS-104', 'JS-103', 'JS-101'];

  @override
  Widget build(BuildContext context) {
    return _DarkRoleScaffold(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        const _DarkHeader(icon: Icons.emergency_share_rounded, title: 'DISPATCH BOARD', subtitle: 'Prioritised by life risk', color: base.red),
        const SizedBox(height: 14),
        ...List.generate(missions.length, (i) {
          final active = selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              onTap: () => setState(() => selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: active ? base.red.withValues(alpha: .14) : const Color(0xFF0E1C24), borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? base.red : Colors.white12)),
                child: Row(children: [
                  CircleAvatar(backgroundColor: (i == 0 ? base.red : base.orange).withValues(alpha: .16), child: Icon(i == 0 ? Icons.sos_rounded : Icons.warning_amber_rounded, color: i == 0 ? base.red : base.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('MISSION ${missions[i]}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    Text(i == 0 ? '4 trapped · landslide' : i == 1 ? 'Elderly evacuation · road block' : 'Shelter transfer · 12 persons', style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                    const SizedBox(height: 5),
                    Text(i == 0 ? 'CRITICAL · ETA 11 MIN' : 'HIGH · QUEUED', style: TextStyle(color: i == 0 ? base.red : base.orange, fontSize: 8.5, fontWeight: FontWeight.w900)),
                  ])),
                  Icon(active ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: active ? base.red : Colors.white24),
                ]),
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        _TacticalButton(Icons.send_rounded, 'Assign Team Alpha', base.red, (context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team Alpha assignment updated')))),
        const SizedBox(height: 12),
        const _DarkPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TRIAGE', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Row(children: [Expanded(child: _DarkMetric('01', 'RED', base.red)), SizedBox(width: 8), Expanded(child: _DarkMetric('02', 'YELLOW', base.orange)), SizedBox(width: 8), Expanded(child: _DarkMetric('03', 'GREEN', base.green))]),
        ])),
      ]),
    );
  }
}

class _RescueAlerts extends StatelessWidget {
  const _RescueAlerts();
  @override
  Widget build(BuildContext context) => _DarkRoleScaffold(
    child: ListView(padding: const EdgeInsets.all(16), children: const [
      _DarkHeader(icon: Icons.notifications_active_rounded, title: 'FIELD SIGNALS', subtitle: 'Operational alerts only', color: base.red),
      SizedBox(height: 14),
      _DarkSignalCard('NEW SOS', 'JS-104 · 4 persons trapped', '00:42 ago', base.red, Icons.sos_rounded),
      _DarkSignalCard('ROUTE CHANGE', 'Bridge approach now unsafe', '2 min ago', base.orange, Icons.route_rounded),
      _DarkSignalCard('MEDICAL', 'Trauma kit ETA 7 min', '4 min ago', base.blue, Icons.medical_services_rounded),
      _DarkSignalCard('DRONE', 'Thermal signature confirmed', '6 min ago', base.green, Icons.flight_rounded),
    ]),
  );
}

class _RescueMore extends StatelessWidget {
  const _RescueMore();
  @override
  Widget build(BuildContext context) => _DarkRoleScaffold(
    child: ListView(padding: const EdgeInsets.all(16), children: [
      const _DarkHeader(icon: Icons.grid_view_rounded, title: 'RESCUE SYSTEMS', subtitle: 'Field-ready tools', color: base.red),
      const SizedBox(height: 14),
      _DarkActionTile(Icons.groups_rounded, 'Team roster', '11 responders · vitals linked', base.green, () {}),
      _DarkActionTile(Icons.sensors_rounded, 'Sensor feed', 'Hazards streaming every 14 sec', base.blue, () => Navigator.push(context, _route(const _VisualSensorPage()))),
      _DarkActionTile(Icons.inventory_2_rounded, 'Equipment cache', '84% mission ready', base.orange, () {}),
      _DarkActionTile(Icons.call_rounded, 'Command voice', 'Encrypted in-app operations call', base.green, () => Navigator.push(context, _route(const _InAppCallPage(name: 'District Command', role: 'Rescue Operations', video: false)))),
      _DarkActionTile(Icons.videocam_rounded, 'Command video', 'Live visual coordination link', base.blue, () => Navigator.push(context, _route(const _InAppCallPage(name: 'District Command', role: 'Rescue Operations', video: true)))),
    ]),
  );
}

// ---------------------------------------------------------------------------
// Authority – clean command-center / GIS UI.
// ---------------------------------------------------------------------------

class _AuthorityHome extends StatelessWidget {
  const _AuthorityHome();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const _AuthorityHeader(),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF123E8F), Color(0xFF4387F4)]), borderRadius: BorderRadius.circular(24)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Regional Risk\nCommand', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.0, fontWeight: FontWeight.w900))),
            Icon(Icons.radar_rounded, color: Colors.white, size: 56),
          ]),
          SizedBox(height: 16),
          Row(children: [Expanded(child: _LightOnBlueMetric('4', 'High-risk zones')), Expanded(child: _LightOnBlueMetric('18', 'Safe hubs')), Expanded(child: _LightOnBlueMetric('92%', 'Confidence'))]),
        ]),
      ),
      const SizedBox(height: 14),
      _section('Decision intelligence', 'Verified evidence before public action'),
      const SizedBox(height: 9),
      const _Surface(child: Column(children: [
        _DecisionRow('NW-27', 'Sindhupalchok', 'Broadcast ready', base.red, .92),
        Divider(),
        _DecisionRow('A12', 'Araniko Highway', 'Diversion active', base.orange, .84),
      ])),
      const SizedBox(height: 14),
      _section('Operational readiness', 'Cross-agency capability'),
      const SizedBox(height: 9),
      const Row(children: [
        Expanded(child: _AuthorityStat(Icons.cell_tower_rounded, '96%', 'Broadcast')), SizedBox(width: 8),
        Expanded(child: _AuthorityStat(Icons.local_hospital_rounded, '12', 'Medical units')), SizedBox(width: 8),
        Expanded(child: _AuthorityStat(Icons.groups_rounded, '47', 'Responders')),
      ]),
      const SizedBox(height: 14),
      _GradientAction(icon: Icons.campaign_rounded, title: 'Issue verified warning', subtitle: 'Target zones, channels and languages', colors: [Color(0xFF123E8F), base.blue], onTap: _openBroadcast),
    ]),
  );

  static void _openBroadcast(BuildContext context) => Navigator.push(context, _route(const _AuthorityBroadcast()));
}

class _AuthorityMap extends StatelessWidget {
  const _AuthorityMap();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: _AuthorityHeader(title: 'GIS Command', subtitle: 'Risk polygons · infrastructure · shelters')),
      Expanded(child: Stack(children: [
        FlutterMap(
          options: const MapOptions(initialCenter: LatLng(27.75, 85.45), initialZoom: 9.7),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sih.jeevansetu'),
            PolygonLayer(polygons: [
              Polygon(points: const [LatLng(27.70,85.35),LatLng(27.85,85.40),LatLng(27.88,85.57),LatLng(27.72,85.62)], color: base.red.withValues(alpha: .18), borderColor: base.red, borderStrokeWidth: 2),
              Polygon(points: const [LatLng(27.62,85.25),LatLng(27.70,85.28),LatLng(27.73,85.36),LatLng(27.65,85.40)], color: base.orange.withValues(alpha: .16), borderColor: base.orange, borderStrokeWidth: 2),
            ]),
          ],
        ),
        Positioned(top: 12, left: 12, right: 12, child: _Surface(child: Row(children: const [
          Icon(Icons.layers_rounded, color: base.blue), SizedBox(width: 8), Expanded(child: Text('Layers: Risk · Roads · Shelters · Sensors', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800))), _Pill('LIVE', base.green),
        ]))),
      ])),
    ]),
  );
}

class _AuthorityBroadcast extends StatefulWidget {
  const _AuthorityBroadcast();
  @override
  State<_AuthorityBroadcast> createState() => _AuthorityBroadcastState();
}

class _AuthorityBroadcastState extends State<_AuthorityBroadcast> {
  bool sms = true;
  bool app = true;
  bool siren = false;
  bool sent = false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const _AuthorityHeader(title: 'Verified Broadcast', subtitle: 'Multi-channel public warning composer'),
      const SizedBox(height: 14),
      const _Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.verified_rounded, color: base.green), SizedBox(width: 8), Text('Evidence package NW-27', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))]),
        SizedBox(height: 7),
        Text('High landslide probability in the Sindhupalchok north-east corridor. Move away from steep slopes and follow verified evacuation routes.', style: TextStyle(color: Colors.black54, fontSize: 10.5, height: 1.45)),
        SizedBox(height: 9),
        _ConfidenceBar('Evidence confidence', .92, base.green),
      ])),
      const SizedBox(height: 12),
      _Surface(child: Column(children: [
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('App push notification', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Estimated reach 18,420 devices'), value: app, onChanged: (v) => setState(() => app = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('SMS cell broadcast', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Fallback for low-data connectivity'), value: sms, onChanged: (v) => setState(() => sms = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Local siren network', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('6 municipal sirens available'), value: siren, onChanged: (v) => setState(() => siren = v)),
      ])),
      const SizedBox(height: 12),
      SizedBox(height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: base.blue), onPressed: () => setState(() => sent = true), icon: Icon(sent ? Icons.check_circle_rounded : Icons.campaign_rounded), label: Text(sent ? 'Broadcast queued ✓' : 'Authorize & broadcast', style: const TextStyle(fontWeight: FontWeight.w900)))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(const _InAppCallPage(name: 'Municipal Command', role: 'Authority Coordination', video: false))), icon: const Icon(Icons.call_rounded), label: const Text('Voice bridge'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(const _InAppCallPage(name: 'Municipal Command', role: 'Authority Coordination', video: true))), icon: const Icon(Icons.videocam_rounded), label: const Text('Video bridge'))),
      ]),
    ]),
  );
}

class _AuthorityAlerts extends StatelessWidget {
  const _AuthorityAlerts();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
    _AuthorityHeader(title: 'Decision Queue', subtitle: 'Warnings requiring authority attention'),
    SizedBox(height: 14),
    _AuthorityAlert('CRITICAL', 'NW-27 · Landslide warning', '92% verified · 18,420 people in target zone', base.red, Icons.warning_rounded),
    _AuthorityAlert('MOBILITY', 'A12 · Road diversion', 'Police verification received 3 min ago', base.orange, Icons.route_rounded),
    _AuthorityAlert('WEATHER', 'Rain threshold exceeded', '3 gauges above critical threshold', base.blue, Icons.cloudy_snowing),
  ]));
}

class _AuthorityMore extends StatelessWidget {
  const _AuthorityMore();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const _AuthorityHeader(title: 'Command Systems', subtitle: 'Governance, audit and cross-agency tools'),
    const SizedBox(height: 14),
    _MoreVisualTile(Icons.fact_check_rounded, base.blue, 'Verification desk', 'Review evidence and provenance', '12 queued', () {}),
    _MoreVisualTile(Icons.sensors_rounded, base.green, 'Sensor integrity', 'Telemetry health and stale-node audit', '96%', () => Navigator.push(context, _route(const _VisualSensorPage()))),
    _MoreVisualTile(Icons.policy_rounded, base.purple, 'Audit trail', 'Signed warning and action history', 'Live', () {}),
    _MoreVisualTile(Icons.groups_rounded, base.orange, 'Agency bridge', 'Rescue, police, medical and municipality', '4 online', () => Navigator.push(context, _route(const _InAppCallPage(name: 'Inter-agency Bridge', role: 'Authority Coordination', video: true)))),
  ]));
}

// ---------------------------------------------------------------------------
// Volunteer – warm community / task UI.
// ---------------------------------------------------------------------------

class _VolunteerHome extends StatefulWidget {
  const _VolunteerHome();
  @override
  State<_VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<_VolunteerHome> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const Row(children: [
        CircleAvatar(radius: 24, backgroundColor: Color(0xFFEDE5FB), child: Icon(Icons.volunteer_activism_rounded, color: base.purple)),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Community Volunteer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text('Sindhupalchok hub · Level 2', style: TextStyle(color: Colors.black45, fontSize: 10))])),
        _Pill('AVAILABLE', base.green),
      ]),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [base.purple, Color(0xFFB26BE0)]), borderRadius: BorderRadius.circular(26)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nearby mission', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Prepare water + first aid', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const Text('1.2 km · 8 volunteers needed · starts in 18 min', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(child: Row(children: [Icon(Icons.people_rounded, color: Colors.white), SizedBox(width: 5), Text('5 / 8 joined', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])),
            FilledButton.tonal(onPressed: () => setState(() => accepted = !accepted), child: Text(accepted ? 'Joined ✓' : 'Join mission')),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      const Row(children: [
        Expanded(child: _WarmStat(Icons.task_alt_rounded, '2', 'Nearby tasks', base.purple)), SizedBox(width: 8),
        Expanded(child: _WarmStat(Icons.groups_rounded, '18', 'Online', base.green)), SizedBox(width: 8),
        Expanded(child: _WarmStat(Icons.family_restroom_rounded, '46', 'Check-ins', base.orange)),
      ]),
      const SizedBox(height: 16),
      _section('Community needs', 'Matched to your location and skills'),
      const SizedBox(height: 9),
      const _Surface(child: Column(children: [
        _NeedRow(Icons.water_drop_rounded, 'Water distribution', 'Melamchi Hall · 12 packs', base.blue),
        Divider(),
        _NeedRow(Icons.medical_services_rounded, 'First-aid support', 'Camp B · 2 volunteers', base.red),
        Divider(),
        _NeedRow(Icons.translate_rounded, 'Translation desk', 'Nepali ↔ Hindi support', base.purple),
      ])),
      const SizedBox(height: 14),
      _GradientAction(icon: Icons.qr_code_scanner_rounded, title: 'Rapid camp check-in', subtitle: 'Verify arrival and assignment in one tap', colors: const [base.purple, Color(0xFF9F72D9)], onTap: _openVolunteerCheckIn),
    ]),
  );

  static void _openVolunteerCheckIn(BuildContext context) => Navigator.push(context, _route(const _VolunteerCheckIn()));
}

class _VolunteerMap extends StatelessWidget {
  const _VolunteerMap();
  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
    const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [Text('Task Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Spacer(), _Pill('2 NEARBY', base.purple)])),
    Expanded(child: Stack(children: [
      FlutterMap(options: const MapOptions(initialCenter: LatLng(27.78,85.48), initialZoom: 11.1), children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sih.jeevansetu'),
        const MarkerLayer(markers: [
          Marker(point: LatLng(27.77,85.47), width: 48, height: 48, child: _MapBadge(Icons.water_drop_rounded, base.blue)),
          Marker(point: LatLng(27.80,85.50), width: 48, height: 48, child: _MapBadge(Icons.medical_services_rounded, base.red)),
          Marker(point: LatLng(27.75,85.52), width: 48, height: 48, child: _MapBadge(Icons.home_work_rounded, base.purple)),
        ]),
      ]),
      const Positioned(left: 12, right: 12, bottom: 12, child: _Surface(child: Row(children: [Icon(Icons.favorite_rounded, color: base.purple), SizedBox(width: 8), Expanded(child: Text('Best match: Water distribution · 1.2 km', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))), Icon(Icons.arrow_forward_rounded)]))),
    ])),
  ]));
}

class _VolunteerCheckIn extends StatefulWidget {
  const _VolunteerCheckIn();
  @override
  State<_VolunteerCheckIn> createState() => _VolunteerCheckInState();
}

class _VolunteerCheckInState extends State<_VolunteerCheckIn> {
  bool checked = false;
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Rapid Check-in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const Text('Confirm location, skills and assignment', style: TextStyle(color: Colors.black45, fontSize: 10.5)),
    const SizedBox(height: 14),
    Container(
      height: 240,
      decoration: BoxDecoration(color: const Color(0xFF251B38), borderRadius: BorderRadius.circular(26)),
      child: Stack(children: [
        const Center(child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 150)),
        Positioned(top: 14, left: 14, child: _Pill(checked ? 'VERIFIED' : 'READY TO SCAN', checked ? base.green : base.aqua, dark: true)),
        Positioned(left: 18, right: 18, bottom: 16, child: FilledButton.icon(onPressed: () => setState(() => checked = true), icon: Icon(checked ? Icons.check_rounded : Icons.qr_code_scanner_rounded), label: Text(checked ? 'Camp B check-in verified' : 'Simulate secure check-in'))),
      ]),
    ),
    const SizedBox(height: 14),
    const _Surface(child: Column(children: [
      _NeedRow(Icons.location_on_rounded, 'Camp B', '2.0 km · operational', base.purple),
      Divider(),
      _NeedRow(Icons.badge_rounded, 'Your assignment', 'Registration support', base.green),
      Divider(),
      _NeedRow(Icons.schedule_rounded, 'Shift', '09:30 – 13:30', base.orange),
    ])),
  ]));
}

class _VolunteerUpdates extends StatelessWidget {
  const _VolunteerUpdates();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
    Text('Community Updates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    SizedBox(height: 14),
    _CommunityUpdate('Camp B', 'Medical desk needs two volunteers', '2 min ago', base.red, Icons.medical_services_rounded),
    _CommunityUpdate('Melamchi Hall', 'Water stock replenished', '6 min ago', base.blue, Icons.water_drop_rounded),
    _CommunityUpdate('Family desk', '12 new safe check-ins', '9 min ago', base.green, Icons.family_restroom_rounded),
  ]));
}

class _VolunteerMore extends StatelessWidget {
  const _VolunteerMore();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Volunteer Toolkit', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 14),
    _MoreVisualTile(Icons.badge_rounded, base.purple, 'Skills profile', 'First aid · logistics · translation', 'Level 2', () {}),
    _MoreVisualTile(Icons.school_rounded, base.blue, 'Micro-training', '3-minute disaster response refreshers', '4 ready', () {}),
    _MoreVisualTile(Icons.call_rounded, base.green, 'Camp coordinator', 'In-app voice channel', 'Online', () => Navigator.push(context, _route(const _InAppCallPage(name: 'Camp B Coordinator', role: 'Volunteer Operations', video: false)))),
    _MoreVisualTile(Icons.videocam_rounded, base.purple, 'Visual support', 'Show field conditions to coordinator', 'Ready', () => Navigator.push(context, _route(const _InAppCallPage(name: 'Camp B Coordinator', role: 'Volunteer Operations', video: true)))),
  ]));
}

// ---------------------------------------------------------------------------
// Organization – logistics / facilities / inventory UI.
// ---------------------------------------------------------------------------

class _OrganizationHome extends StatefulWidget {
  const _OrganizationHome();
  @override
  State<_OrganizationHome> createState() => _OrganizationHomeState();
}

class _OrganizationHomeState extends State<_OrganizationHome> {
  int reserved = 120;

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
    const Row(children: [
      CircleAvatar(radius: 24, backgroundColor: Color(0xFFFFE8C0), child: Icon(Icons.business_center_rounded, color: base.orange)),
      SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Resource Command', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('Organization operations · live inventory', style: TextStyle(color: Colors.black45, fontSize: 10))])),
      _Pill('ONLINE', base.green),
    ]),
    const SizedBox(height: 14),
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59B23), Color(0xFFB76A00)]), borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Emergency capacity', style: TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 3),
        const Text('730 beds across 4 facilities', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        const LinearProgressIndicator(value: .81, minHeight: 9, borderRadius: BorderRadius.all(Radius.circular(9)), color: Colors.white, backgroundColor: Colors.white24),
        const SizedBox(height: 6),
        const Text('81% operational stock ready', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
      ]),
    ),
    const SizedBox(height: 14),
    const Row(children: [
      Expanded(child: _OrgStat('1,260', 'Water packs', base.blue)), SizedBox(width: 8),
      Expanded(child: _OrgStat('87', 'Trauma kits', base.red)), SizedBox(width: 8),
      Expanded(child: _OrgStat('9', 'Generators', base.green)),
    ]),
    const SizedBox(height: 16),
    _section('Priority request', 'Authority verified · response needed'),
    const SizedBox(height: 9),
    _Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.inventory_rounded, color: base.orange), SizedBox(width: 8), Expanded(child: Text('Reserve water packs for Camp B', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))), _Pill('HIGH', base.red)]),
      const SizedBox(height: 5),
      const Text('Requested: 120 packs · delivery window 45 min', style: TextStyle(color: Colors.black45, fontSize: 10)),
      const SizedBox(height: 10),
      Row(children: [
        IconButton(onPressed: () => setState(() => reserved = math.max(20, reserved - 20)), icon: const Icon(Icons.remove_circle_outline_rounded)),
        Expanded(child: Text('$reserved packs reserved', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))),
        IconButton(onPressed: () => setState(() => reserved += 20), icon: const Icon(Icons.add_circle_outline_rounded)),
      ]),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: base.orange), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$reserved water packs committed to Camp B'))), icon: const Icon(Icons.local_shipping_rounded), label: const Text('Commit delivery'))),
    ])),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(child: _WarmAction(Icons.call_rounded, 'Call command', base.green, () => Navigator.push(context, _route(const _InAppCallPage(name: 'District Logistics Desk', role: 'Organization Support', video: false))))),
      const SizedBox(width: 8),
      Expanded(child: _WarmAction(Icons.videocam_rounded, 'Video command', base.blue, () => Navigator.push(context, _route(const _InAppCallPage(name: 'District Logistics Desk', role: 'Organization Support', video: true))))),
    ]),
  ]));
}

class _OrganizationMap extends StatelessWidget {
  const _OrganizationMap();
  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
    const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [Text('Facilities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Spacer(), _Pill('4 ACTIVE', base.orange)])),
    Expanded(child: Stack(children: [
      FlutterMap(options: const MapOptions(initialCenter: LatLng(27.77,85.47), initialZoom: 10.8), children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sih.jeevansetu'),
        const MarkerLayer(markers: [
          Marker(point: LatLng(27.78,85.46), width: 46, height: 46, child: _MapBadge(Icons.home_work_rounded, base.orange)),
          Marker(point: LatLng(27.74,85.50), width: 46, height: 46, child: _MapBadge(Icons.local_hospital_rounded, base.red)),
          Marker(point: LatLng(27.82,85.53), width: 46, height: 46, child: _MapBadge(Icons.warehouse_rounded, base.blue)),
        ]),
      ]),
      Positioned(left: 12, right: 12, bottom: 12, child: _Surface(child: Row(children: [
        const Icon(Icons.home_work_rounded, color: base.orange),
        const SizedBox(width: 9),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Melamchi Community Hall', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), Text('250 capacity · 76% available', style: TextStyle(color: Colors.black45, fontSize: 9.5))])),
        _RoundAction(Icons.call_rounded, base.green, () => Navigator.push(context, _route(const _InAppCallPage(name: 'Melamchi Hall', role: 'Facility Coordinator', video: false)))),
        const SizedBox(width: 6),
        _RoundAction(Icons.videocam_rounded, base.blue, () => Navigator.push(context, _route(const _InAppCallPage(name: 'Melamchi Hall', role: 'Facility Coordinator', video: true)))),
      ])),
    ])),
  ]));
}

class _OrganizationSupport extends StatelessWidget {
  const _OrganizationSupport();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Support Network', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const Text('Voice, video and facility coordination in one place', style: TextStyle(color: Colors.black45, fontSize: 10.5)),
    const SizedBox(height: 14),
    _ContactCommandCard('District Logistics Desk', 'Authority logistics coordination', base.blue),
    _ContactCommandCard('Melamchi Community Hall', 'Shelter coordinator · 250 capacity', base.orange),
    _ContactCommandCard('District Hospital', 'Medical logistics · 24×7', base.red),
    _ContactCommandCard('Warehouse WX-3', 'Inventory & transport desk', base.green),
    const SizedBox(height: 14),
    const _Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Communication health', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      SizedBox(height: 8),
      _ConfidenceBar('Voice bridge', .98, base.green),
      SizedBox(height: 8),
      _ConfidenceBar('Video link', .91, base.blue),
      SizedBox(height: 8),
      _ConfidenceBar('Data sync', .96, base.orange),
    ])),
  ]));
}

class _OrganizationAlerts extends StatelessWidget {
  const _OrganizationAlerts();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
    Row(children: [Text('Logistics Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Spacer(), _Pill('4', base.orange)]),
    SizedBox(height: 14),
    _OrgAlert('STOCK', 'Water packs below target', 'Camp B · 120 packs requested', base.orange, Icons.inventory_rounded),
    _OrgAlert('MEDICAL', 'Trauma kits requested', 'District Hospital · 16 kits', base.red, Icons.medical_services_rounded),
    _OrgAlert('SHELTER', 'Capacity crossed 70%', 'Melamchi Hall · 61 beds open', base.blue, Icons.home_work_rounded),
    _OrgAlert('POWER', 'Generator reserved', 'Warehouse WX-3 · delivery 35 min', base.green, Icons.electrical_services_rounded),
  ]));
}

class _OrganizationMore extends StatelessWidget {
  const _OrganizationMore();
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Operations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 14),
    _MoreVisualTile(Icons.inventory_2_rounded, base.orange, 'Inventory ledger', 'Live stock, reservations and expiry', '81% ready', () {}),
    _MoreVisualTile(Icons.local_shipping_rounded, base.blue, 'Fleet dispatch', 'Vehicles, drivers and delivery ETA', '7 active', () {}),
    _MoreVisualTile(Icons.home_work_rounded, base.green, 'Shelter capacity', 'Beds, food, water and medical status', '730 beds', () => Navigator.push(context, _route(const _VisualResourcesPage()))),
    _MoreVisualTile(Icons.call_rounded, base.green, 'Facility call center', 'Direct in-app voice communication', '4 online', () => Navigator.push(context, _route(const _OrganizationSupport()))),
    _MoreVisualTile(Icons.videocam_rounded, base.blue, 'Visual command bridge', 'Live facility verification by video', 'Ready', () => Navigator.push(context, _route(const _InAppCallPage(name: 'District Logistics Desk', role: 'Organization Support', video: true)))),
  ]));
}

// ---------------------------------------------------------------------------
// Rich shared operational pages.
// ---------------------------------------------------------------------------

class _VisualSensorPage extends StatelessWidget {
  const _VisualSensorPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sensor Network', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Container(
        height: 165,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(fit: StackFit.expand, children: [
          const _FastPhoto(_riskMountain, fallbackScene: 2),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xE5054E68), Color(0xA94387F4)]))),
          const Positioned(left: 16, right: 16, bottom: 16, child: Row(children: [
            Expanded(child: _LightOnBlueMetric('26/28', 'Sensors online')),
            Expanded(child: _LightOnBlueMetric('14 sec', 'Last sync')),
            Expanded(child: _LightOnBlueMetric('96%', 'Mesh health')),
          ])),
        ]),
      ),
      const SizedBox(height: 12),
      const _SensorVisual(Icons.water_drop_outlined, 'Rain Gauge SG-04', '18.4 mm/hr · Rising', base.blue, .82, 'LIVE'),
      const _SensorVisual(Icons.water_rounded, 'Soil Probe SM-12', '87% saturation · Critical', base.red, .87, 'CRITICAL'),
      const _SensorVisual(Icons.straighten_rounded, 'Slope Node IN-07', '2.8 mm movement · Watch', base.orange, .62, 'WATCH'),
      const _SensorVisual(Icons.cloud_outlined, 'Weather Station WX-03', 'Pressure falling · Active', base.green, .48, 'ACTIVE'),
    ]),
  );
}

class _VisualResourcesPage extends StatelessWidget {
  const _VisualResourcesPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Relief & Resources', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Container(
        height: 185,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(fit: StackFit.expand, children: [
          const _FastPhoto(_mountain, fallbackScene: 1),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x20000000), Color(0xE5032833)]))),
          const Positioned(left: 16, right: 16, bottom: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Pill('18 VERIFIED SAFE HUBS', base.green, dark: true),
            SizedBox(height: 7),
            Text('Help near you', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
            Text('Live capacity · medical · water · power', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
          ])),
        ]),
      ),
      const SizedBox(height: 12),
      _ResourceVisualCard(context, Icons.home_work_rounded, 'Melamchi Community Hall', '2.1 km · 250 capacity', .76, base.green),
      _ResourceVisualCard(context, Icons.school_rounded, 'Shree Secondary Shelter', '4.8 km · 180 capacity', .64, base.blue),
      _ResourceVisualCard(context, Icons.local_hospital_rounded, 'District Hospital', '7.5 km · 24×7 emergency', .88, base.red),
    ]),
  );
}

Widget _ResourceVisualCard(BuildContext context, IconData icon, String title, String subtitle, double available, Color color) => Padding(
  padding: const EdgeInsets.only(bottom: 9),
  child: _Surface(child: Column(children: [
    Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])),
      _Pill('${(available * 100).round()}% OPEN', color),
    ]),
    const SizedBox(height: 10),
    LinearProgressIndicator(value: available, minHeight: 7, borderRadius: BorderRadius.circular(8), color: color, backgroundColor: color.withValues(alpha: .1)),
    const SizedBox(height: 10),
    Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(_InAppCallPage(name: title, role: 'Safe Hub Coordinator', video: false))), icon: const Icon(Icons.call_rounded), label: const Text('Call'))),
      const SizedBox(width: 8),
      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(_InAppCallPage(name: title, role: 'Safe Hub Coordinator', video: true))), icon: const Icon(Icons.videocam_rounded), label: const Text('Video'))),
    ]),
  ])),
);

class _VisualOfflinePage extends StatefulWidget {
  const _VisualOfflinePage();
  @override
  State<_VisualOfflinePage> createState() => _VisualOfflinePageState();
}

class _VisualOfflinePageState extends State<_VisualOfflinePage> {
  bool refreshed = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Offline Readiness', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [base.navy, Color(0xFF0A7886)]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Icon(Icons.offline_bolt_rounded, color: base.aqua, size: 52),
          const SizedBox(height: 8),
          const Text('Emergency pack ready offline', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(refreshed ? 'Offline package refreshed just now.' : 'Last safe route, contacts, guidelines and risk snapshot are cached on-device.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.4)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(onPressed: () => setState(() => refreshed = true), icon: const Icon(Icons.sync_rounded), label: const Text('Refresh emergency pack')),
        ]),
      ),
      const SizedBox(height: 12),
      const _OfflineVisual(Icons.map_rounded, 'Risk snapshot', 'Updated 3 min ago', base.green),
      const _OfflineVisual(Icons.route_rounded, 'Last safe corridor', '6.8 km · locally cached', base.cyan),
      const _OfflineVisual(Icons.shield_rounded, 'Safety guidelines', '4 essential steps', base.blue),
      const _OfflineVisual(Icons.contact_emergency_rounded, 'Emergency contacts', '4 communication channels', base.red),
    ]),
  );
}

class _VisualGuidelinesPage extends StatelessWidget {
  const _VisualGuidelinesPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Safety Guidelines', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: const [
      _GuideVisual('1', 'Move away from steep slopes', 'Do not wait directly below unstable slopes or drainage channels.', base.red, Icons.landscape_rounded),
      _GuideVisual('2', 'Follow verified evacuation routes', 'Avoid shortcuts through red zones even when they look faster.', base.orange, Icons.route_rounded),
      _GuideVisual('3', 'Keep an emergency go-bag', 'Water, medicines, light, power bank and identity documents.', base.blue, Icons.backpack_rounded),
      _GuideVisual('4', 'Check in with family', 'Let responders know who is safe and who still needs help.', base.green, Icons.family_restroom_rounded),
    ]),
  );
}

class _VisualContactsPage extends StatelessWidget {
  const _VisualContactsPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      const _Surface(child: Row(children: [Icon(Icons.cell_tower_rounded, color: base.green), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Communication network', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), Text('4 channels online · fallback ready', style: TextStyle(color: Colors.black45, fontSize: 9.5))])), _Pill('ONLINE', base.green)])),
      const SizedBox(height: 12),
      _ContactCommandCard('National Emergency Desk', '112 · national response', base.red),
      _ContactCommandCard('District Response Desk', '1077 · local command', base.blue),
      _ContactCommandCard('Nearest Medical Team', 'Available · 6.8 km', base.green),
      _ContactCommandCard('JeevanSetu Command', 'In-app operations radio', base.purple),
    ]),
  );
}

class _InAppCallPage extends StatefulWidget {
  final String name;
  final String role;
  final bool video;
  const _InAppCallPage({required this.name, required this.role, required this.video});

  @override
  State<_InAppCallPage> createState() => _InAppCallPageState();
}

class _InAppCallPageState extends State<_InAppCallPage> {
  bool connected = false;
  bool muted = false;
  bool speaker = true;
  bool camera = true;
  int seconds = 0;
  Timer? connectTimer;
  Timer? clock;

  @override
  void initState() {
    super.initState();
    connectTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => connected = true);
      clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => seconds++);
      });
    });
  }

  @override
  void dispose() {
    connectTimer?.cancel();
    clock?.cancel();
    super.dispose();
  }

  String get clockText => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A23),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.video && camera)
              const Opacity(opacity: .42, child: _FastPhoto(_helicopter, fallbackScene: 3)),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40000000), Color(0xF5041A23)]))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(children: [
                const Align(alignment: Alignment.centerLeft, child: _LiveDot(text: 'JEEVANSETU SECURE LINK')),
                const Spacer(),
                CircleAvatar(radius: 56, backgroundColor: Colors.white12, child: Icon(widget.video ? Icons.videocam_rounded : Icons.person_rounded, color: Colors.white, size: 58)),
                const SizedBox(height: 16),
                Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(widget.role, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 10),
                Text(connected ? clockText : 'Connecting…', style: TextStyle(color: connected ? base.green : base.aqua, fontSize: 12, fontWeight: FontWeight.w900)),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _CallControl(icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded, label: muted ? 'Unmute' : 'Mute', active: muted, onTap: () => setState(() => muted = !muted)),
                  _CallControl(icon: speaker ? Icons.volume_up_rounded : Icons.volume_off_rounded, label: 'Speaker', active: speaker, onTap: () => setState(() => speaker = !speaker)),
                  if (widget.video) _CallControl(icon: camera ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: 'Camera', active: camera, onTap: () => setState(() => camera = !camera)),
                ]),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(radius: 32, backgroundColor: base.red, child: Icon(Icons.call_end_rounded, color: Colors.white, size: 30)),
                ),
                const SizedBox(height: 10),
                const Text('End call', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared widgets / painters.
// ---------------------------------------------------------------------------

class _JudgeFab extends StatefulWidget {
  final Widget child;
  const _JudgeFab({required this.child});
  @override
  State<_JudgeFab> createState() => _JudgeFabState();
}

class _JudgeFabState extends State<_JudgeFab> {
  bool open = false;
  @override
  Widget build(BuildContext context) => Stack(children: [
    widget.child,
    if (!open)
      Positioned(right: 14, top: MediaQuery.paddingOf(context).top + 66, child: Material(
        color: base.navy.withValues(alpha: .94), elevation: 7, borderRadius: BorderRadius.circular(99),
        child: InkWell(borderRadius: BorderRadius.circular(99), onTap: () => setState(() => open = true), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.auto_awesome_rounded, color: base.aqua, size: 20))),
      )),
    if (open)
      Positioned.fill(child: Material(color: Colors.black54, child: SafeArea(child: Align(alignment: Alignment.bottomCenter, child: Container(
        margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.auto_awesome_rounded, color: base.cyan), const SizedBox(width: 8), const Expanded(child: Text('Explain JeevanSetu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), IconButton(onPressed: () => setState(() => open = false), icon: const Icon(Icons.close_rounded))]),
          const Text('Five role-specific operational experiences share one disaster intelligence layer: risk prediction, live maps, safe routing, SOS, sensors, verified alerts, resources, offline readiness and in-app coordination.', style: TextStyle(fontSize: 11, height: 1.45)),
          const SizedBox(height: 10),
          const Wrap(spacing: 6, runSpacing: 6, children: [_Pill('5 ROLE UIs', base.purple), _Pill('LIVE MAPS', base.blue), _Pill('SOS', base.red), _Pill('VOICE + VIDEO', base.green), _Pill('OFFLINE', base.orange)]),
        ]),
      ))))),
  ]);
}

class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Surface({required this.child, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7EEF1)), boxShadow: [BoxShadow(color: base.navy.withValues(alpha: .055), blurRadius: 18, offset: const Offset(0, 8))]),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool dark;
  const _Pill(this.text, this.color, {this.dark = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: dark ? Colors.black.withValues(alpha: .22) : color.withValues(alpha: .10), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: .42))),
    child: Text(text, maxLines: 1, style: TextStyle(color: color, fontSize: 8.2, fontWeight: FontWeight.w900, letterSpacing: .45)),
  );
}

class _LiveDot extends StatelessWidget {
  final String text;
  const _LiveDot({required this.text});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [const CircleAvatar(radius: 3.5, backgroundColor: base.green), const SizedBox(width: 5), Text(text, style: const TextStyle(color: base.green, fontSize: 8.5, fontWeight: FontWeight.w900))]);
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroMetric(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))]),
  );
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _MetricCard(this.icon, this.color, this.value, this.label);
  @override
  Widget build(BuildContext context) => _Surface(child: Row(children: [Icon(icon, color: color, size: 28), const SizedBox(width: 9), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.black45))])]), padding: const EdgeInsets.all(12));
}

Widget _section(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45))]);

class _RiskActionBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RiskActionBanner({required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Ink(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFEB3F59)]), borderRadius: BorderRadius.circular(22)),
      child: const Row(children: [
        CircleAvatar(radius: 27, backgroundColor: Color(0x33FFFFFF), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30)), SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Potential slope failure within 12 hours. A safer evacuation corridor is ready.', style: TextStyle(color: Colors.white, fontSize: 10.5, height: 1.35)), SizedBox(height: 7), Text('OPEN RISK INTELLIGENCE  →', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))]))
      ]),
    )),
  );
}

class _QuickTile extends StatelessWidget {
  final IconData icon; final Color color; final String label; final VoidCallback onTap;
  const _QuickTile(this.icon, this.color, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8F0F2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, height: 1.12, fontWeight: FontWeight.w800))]))));
}

class _GradientAction extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final List<Color> colors; final void Function(BuildContext) onTap;
  const _GradientAction({required this.icon, required this.title, required this.subtitle, required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: () => onTap(context), borderRadius: BorderRadius.circular(20), child: Ink(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.white)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5))])), const Icon(Icons.arrow_forward_rounded, color: base.aqua)]))));
}

class _AnimatedGauge extends StatelessWidget {
  final double value; final Color color; final double size;
  const _AnimatedGauge({required this.value, required this.color, required this.size});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: value), duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic, builder: (_, v, __) => SizedBox(width: size, height: size, child: CustomPaint(painter: _RingPainter(v, color), child: Center(child: Text('${(v * 100).round()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))))));
}

class _RingPainter extends CustomPainter {
  final double value; final Color color;
  _RingPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, Paint()..color = color.withValues(alpha: .12)..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.value != value || oldDelegate.color != color;
}

class _Signal extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle; final String badge;
  const _Signal(this.icon, this.color, this.title, this.subtitle, this.badge);
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(fontSize: 9.2, color: Colors.black45))])), _Pill(badge, color)]);
}

class _SegmentButton extends StatelessWidget {
  final String text; final bool active; final VoidCallback onTap;
  const _SegmentButton(this.text, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(11), child: AnimatedContainer(duration: const Duration(milliseconds: 180), height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: active ? base.navy : const Color(0xFFE5ECEF), borderRadius: BorderRadius.circular(11)), child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 10.5, fontWeight: FontWeight.w800))));
}

class _FactorRow extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String value; final double contribution;
  const _FactorRow(this.icon, this.color, this.title, this.value, this.contribution);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), SizedBox(width: 100, child: Text(title, style: const TextStyle(fontSize: 10))), Expanded(child: LinearProgressIndicator(value: contribution, minHeight: 6, borderRadius: BorderRadius.circular(8), color: color, backgroundColor: color.withValues(alpha: .1))), const SizedBox(width: 8), SizedBox(width: 49, child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)))]));
}

class _AIExplanationCard extends StatelessWidget {
  const _AIExplanationCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF5E9), Color(0xFFFFEEDC)]), borderRadius: BorderRadius.circular(16)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome_rounded, color: base.orange), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI explanation', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Prolonged rainfall has pushed soil moisture above the local failure threshold while slope movement sensors are also trending upward. This combination is why the score is high.', style: TextStyle(fontSize: 10.3, height: 1.4))]))]));
}

class _TrendGraphPainter extends CustomPainter {
  const _TrendGraphPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE7EFF2)..strokeWidth = 1;
    for (var i = 1; i < 4; i++) canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), grid);
    final area = Path()..moveTo(0, size.height * .78)..cubicTo(size.width * .18, size.height * .7, size.width * .28, size.height * .48, size.width * .40, size.height * .50)..cubicTo(size.width * .56, size.height * .55, size.width * .65, size.height * .20, size.width * .78, size.height * .27)..cubicTo(size.width * .90, size.height * .34, size.width * .94, size.height * .15, size.width, size.height * .18);
    final fill = Path.from(area)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fill, Paint()..color = base.red.withValues(alpha: .08));
    canvas.drawPath(area, Paint()..color = base.red..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineStep extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle; final bool done;
  const _TimelineStep(this.icon, this.color, this.title, this.subtitle, this.done);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: done ? .15 : .07), child: Icon(icon, color: done ? color : Colors.black26, size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: done ? base.ink : Colors.black45)), Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black45))])), if (done) const Icon(Icons.check_circle_rounded, color: base.green, size: 18)]));
}

class _VisualAlertCard extends StatelessWidget {
  final IconData icon; final Color color; final String tag; final String title; final String subtitle; final String detail; final VoidCallback onTap;
  const _VisualAlertCard({required this.icon, required this.color, required this.tag, required this.title, required this.subtitle, required this.detail, required this.onTap});
  @override
  Widget build(BuildContext context) => _Surface(child: InkWell(onTap: onTap, child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 28)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5)), const SizedBox(height: 4), Text(detail, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])));
}

class _ConfidenceBar extends StatelessWidget {
  final String label; final double value; final Color color;
  const _ConfidenceBar(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))), Text('${(value * 100).round()}%', style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900))]), const SizedBox(height: 5), LinearProgressIndicator(value: value, minHeight: 7, borderRadius: BorderRadius.circular(9), color: color, backgroundColor: color.withValues(alpha: .1))]);
}

class _MiniStage extends StatelessWidget {
  final String time; final String title; final Color color; final bool active;
  const _MiniStage(this.time, this.title, this.color, this.active);
  @override
  Widget build(BuildContext context) => Column(children: [CircleAvatar(radius: 13, backgroundColor: color.withValues(alpha: active ? 1 : .12), child: Icon(active ? Icons.check_rounded : Icons.schedule_rounded, color: active ? Colors.white : color, size: 14)), const SizedBox(height: 5), Text(time, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900)), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800))]);
}

class _MoreVisualTile extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle; final String badge; final VoidCallback onTap;
  const _MoreVisualTile(this.icon, this.color, this.title, this.subtitle, this.badge, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7EEF1))), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: .17), color.withValues(alpha: .06)]), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])), _Pill(badge, color), const SizedBox(width: 4), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])))));
}

class _SafetyMetric extends StatelessWidget {
  final String value; final String label; final Color color;
  const _SafetyMetric(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.black45))]);
}

class _FamilyVisualTile extends StatelessWidget {
  final String name; final String status; final Color color; final bool live;
  const _FamilyVisualTile(this.name, this.status, this.color, this.live);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Row(children: [CircleAvatar(radius: 24, backgroundColor: color.withValues(alpha: .12), child: Icon(Icons.person_rounded, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), Text(status, style: TextStyle(color: color, fontSize: 9.5))])), if (live) const _Pill('LIVE', base.green), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])));
}

class _DarkRoleScaffold extends StatelessWidget {
  final Widget child; const _DarkRoleScaffold({required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(child: ColoredBox(color: const Color(0xFF071017), child: child));
}

class _DarkHeader extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color;
  const _DarkHeader({required this.icon, required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: .4))), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: .4)), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9.5))])), const _LiveDot(text: 'LIVE')]);
}

class _DarkMetric extends StatelessWidget {
  final String value; final String label; final Color color;
  const _DarkMetric(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF0E1C24), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Column(children: [Text(value, style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: Colors.white38, fontSize: 7.5, fontWeight: FontWeight.w800))]));
}

class _DarkPanel extends StatelessWidget {
  final Widget child; const _DarkPanel({required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF0E1C24), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: child);
}

class _ResponderRow extends StatelessWidget {
  final String name; final String status; final Color color; final double value;
  const _ResponderRow(this.name, this.status, this.color, this.value);
  @override
  Widget build(BuildContext context) => Row(children: [CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: .15), child: Icon(Icons.person_rounded, color: color, size: 19)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900)), Text(status, style: const TextStyle(color: Colors.white38, fontSize: 8.5)), const SizedBox(height: 4), LinearProgressIndicator(value: value, minHeight: 4, borderRadius: BorderRadius.all(Radius.circular(6)), color: color, backgroundColor: Colors.white10)]))]);
}

class _TacticalButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final void Function(BuildContext) action;
  const _TacticalButton(this.icon, this.label, this.color, this.action);
  @override
  Widget build(BuildContext context) => FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: color.withValues(alpha: .16), foregroundColor: color, side: BorderSide(color: color.withValues(alpha: .45)), padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () => action(context), icon: Icon(icon), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)));
}

class _DarkTimeline extends StatelessWidget {
  final String time; final String text; final Color color;
  const _DarkTimeline(this.time, this.text, this.color);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [SizedBox(width: 42, child: Text(time, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900))), CircleAvatar(radius: 4, backgroundColor: color), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10.5))]));
}

class _TinyStatus extends StatelessWidget {
  final String a; final String b; final Color color; const _TinyStatus(this.a, this.b, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [Text(a, style: const TextStyle(color: Colors.white38, fontSize: 7.5, fontWeight: FontWeight.w900)), Text(b, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900))]);
}

class _DarkSignalCard extends StatelessWidget {
  final String tag; final String title; final String time; final Color color; final IconData icon;
  const _DarkSignalCard(this.tag, this.title, this.time, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _DarkPanel(child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900)), Text(time, style: const TextStyle(color: Colors.white38, fontSize: 8.5))])), const Icon(Icons.chevron_right_rounded, color: Colors.white30)])));
}

class _DarkActionTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback action;
  const _DarkActionTile(this.icon, this.title, this.subtitle, this.color, this.action);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(onTap: action, borderRadius: BorderRadius.circular(18), child: _DarkPanel(child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9))])), const Icon(Icons.chevron_right_rounded, color: Colors.white30)]))));
}

class _MapBadge extends StatelessWidget {
  final IconData icon; final Color color; const _MapBadge(this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: .3), blurRadius: 12)]), child: Icon(icon, color: Colors.white, size: 22));
}

class _AuthorityHeader extends StatelessWidget {
  final String title; final String subtitle;
  const _AuthorityHeader({this.title = 'Authority Command', this.subtitle = 'District operations · verified intelligence'});
  @override
  Widget build(BuildContext context) => Row(children: [const CircleAvatar(radius: 23, backgroundColor: Color(0xFFE5EEFF), child: Icon(Icons.account_balance_rounded, color: base.blue)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])), const _Pill('VERIFIED', base.green)]);
}

class _LightOnBlueMetric extends StatelessWidget {
  final String value; final String label; const _LightOnBlueMetric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 8.5))]);
}

class _DecisionRow extends StatelessWidget {
  final String id; final String place; final String status; final Color color; final double confidence;
  const _DecisionRow(this.id, this.place, this.status, this.color, this.confidence);
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.fact_check_rounded, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$id · $place', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), Text(status, style: const TextStyle(color: Colors.black45, fontSize: 9))])), _Pill('${(confidence * 100).round()}%', color)]);
}

class _AuthorityStat extends StatelessWidget {
  final IconData icon; final String value; final String label; const _AuthorityStat(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => _Surface(child: Column(children: [Icon(icon, color: base.blue), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 8.5))]), padding: const EdgeInsets.all(10));
}

class _AuthorityAlert extends StatelessWidget {
  final String tag; final String title; final String subtitle; final Color color; final IconData icon;
  const _AuthorityAlert(this.tag, this.title, this.subtitle, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])));
}

class _WarmStat extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color; const _WarmStat(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => _Surface(child: Column(children: [Icon(icon, color: color), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 8.5))]), padding: const EdgeInsets.all(10));
}

class _NeedRow extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; const _NeedRow(this.icon, this.title, this.subtitle, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 21)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9))])), const Icon(Icons.chevron_right_rounded, color: Colors.black26)]);
}

class _CommunityUpdate extends StatelessWidget {
  final String source; final String title; final String time; final Color color; final IconData icon; const _CommunityUpdate(this.source, this.title, this.time, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(source, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), Text(time, style: const TextStyle(color: Colors.black45, fontSize: 8.5))]))])));
}

class _OrgStat extends StatelessWidget {
  final String value; final String label; final Color color; const _OrgStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => _Surface(child: Column(children: [Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 8.5))]), padding: const EdgeInsets.all(10));
}

class _WarmAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback action; const _WarmAction(this.icon, this.label, this.color, this.action);
  @override
  Widget build(BuildContext context) => FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: color.withValues(alpha: .12), foregroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: action, icon: Icon(icon), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)));
}

class _ContactCommandCard extends StatelessWidget {
  final String name; final String subtitle; final Color color; const _ContactCommandCard(this.name, this.subtitle, this.color);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Column(children: [
    Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(Icons.support_agent_rounded, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), const _Pill('ONLINE', base.green)]),
    const SizedBox(height: 10),
    Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(_InAppCallPage(name: name, role: subtitle, video: false))), icon: const Icon(Icons.call_rounded), label: const Text('Voice'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: color), onPressed: () => Navigator.push(context, _route(_InAppCallPage(name: name, role: subtitle, video: true))), icon: const Icon(Icons.videocam_rounded), label: const Text('Video')))]),
  ])));
}

class _OrgAlert extends StatelessWidget {
  final String tag; final String title; final String subtitle; final Color color; final IconData icon; const _OrgAlert(this.tag, this.title, this.subtitle, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)])));
}

class _SensorVisual extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final double value; final String badge; const _SensorVisual(this.icon, this.title, this.subtitle, this.color, this.value, this.badge);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Column(children: [Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), _Pill(badge, color)]), const SizedBox(height: 9), LinearProgressIndicator(value: value, minHeight: 7, borderRadius: BorderRadius.circular(8), color: color, backgroundColor: color.withValues(alpha: .1))])));
}

class _OfflineVisual extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; const _OfflineVisual(this.icon, this.title, this.subtitle, this.color);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _Surface(child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), const Icon(Icons.check_circle_rounded, color: base.green)])));
}

class _GuideVisual extends StatelessWidget {
  final String number; final String title; final String text; final Color color; final IconData icon; const _GuideVisual(this.number, this.title, this.text, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _Surface(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 26, backgroundColor: color, child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 5), Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)))]), const SizedBox(height: 4), Text(text, style: const TextStyle(color: Colors.black45, fontSize: 10.2, height: 1.35))]))])));
}

class _CallControl extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap; const _CallControl({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Column(children: [CircleAvatar(radius: 26, backgroundColor: active ? Colors.white : Colors.white12, child: Icon(icon, color: active ? base.deepNavy : Colors.white)), const SizedBox(height: 6), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9))]));
}

class _RoundAction extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap; const _RoundAction(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(99), child: CircleAvatar(radius: 20, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)));
}
