import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'app.dart' show LogoMark;

const _navy = Color(0xFF073C4D);
const _deep = Color(0xFF032833);
const _cyan = Color(0xFF14BFD4);
const _aqua = Color(0xFF57E1E8);
const _blue = Color(0xFF4387F4);
const _red = Color(0xFFFF3B55);
const _green = Color(0xFF20C98A);
const _orange = Color(0xFFFFA42E);
const _purple = Color(0xFF7758DF);
const _bg = Color(0xFFF3F8FA);
const _ink = Color(0xFF102027);

const _mountain = 'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1400';
const _riskMountain = 'https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas.jpg?width=1400';
const _rescueMountain = 'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=1400';

class JudgeJeevanSetuApp extends StatefulWidget {
  const JudgeJeevanSetuApp({super.key});

  @override
  State<JudgeJeevanSetuApp> createState() => _JudgeJeevanSetuAppState();
}

class _JudgeJeevanSetuAppState extends State<JudgeJeevanSetuApp> {
  bool dark = false;
  AppLang language = AppLang.english;

  @override
  Widget build(BuildContext context) {
    return AppPrefs(
      dark: dark,
      language: language,
      setDark: (value) => setState(() => dark = value),
      setLanguage: (value) => setState(() => language = value),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JeevanSetu',
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _bg,
          colorScheme: ColorScheme.fromSeed(seedColor: _cyan, surface: Colors.white),
          navigationBarTheme: NavigationBarThemeData(
            height: 72,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDDF6F9),
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
              color: states.contains(WidgetState.selected) ? _navy : const Color(0xFF63757A),
            )),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF071D24),
          colorScheme: ColorScheme.fromSeed(seedColor: _cyan, brightness: Brightness.dark, surface: const Color(0xFF102A33)),
        ),
        home: const FoundationSplash(),
      ),
    );
  }
}

enum AppLang { english, hindi, nepali }

extension on AppLang {
  String get label => switch (this) {
    AppLang.english => 'English',
    AppLang.hindi => 'हिन्दी',
    AppLang.nepali => 'नेपाली',
  };
}

class AppPrefs extends InheritedWidget {
  final bool dark;
  final AppLang language;
  final ValueChanged<bool> setDark;
  final ValueChanged<AppLang> setLanguage;

  const AppPrefs({
    super.key,
    required this.dark,
    required this.language,
    required this.setDark,
    required this.setLanguage,
    required super.child,
  });

  static AppPrefs of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppPrefs>()!;

  @override
  bool updateShouldNotify(AppPrefs oldWidget) => dark != oldWidget.dark || language != oldWidget.language;
}

String _tr(BuildContext context, String en, String hi, String ne) {
  return switch (AppPrefs.of(context).language) {
    AppLang.english => en,
    AppLang.hindi => hi,
    AppLang.nepali => ne,
  };
}

Route<T> _route<T>(Widget child) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  pageBuilder: (_, animation, __) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    child: child,
  ),
  transitionsBuilder: (_, animation, __, child) {
    final slide = Tween<Offset>(begin: const Offset(.025, .01), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return SlideTransition(position: slide, child: child);
  },
);

class FoundationSplash extends StatefulWidget {
  const FoundationSplash({super.key});

  @override
  State<FoundationSplash> createState() => _FoundationSplashState();
}

class _FoundationSplashState extends State<FoundationSplash> with SingleTickerProviderStateMixin {
  late final AnimationController sequence;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sequence = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700))..forward();
    timer = Timer(const Duration(milliseconds: 3250), () {
      if (mounted) Navigator.pushReplacement(context, _route(const FoundationOnboarding()));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    sequence.dispose();
    super.dispose();
  }

  double v(double start, double end) => CurvedAnimation(parent: sequence, curve: Interval(start, end, curve: Curves.easeOutCubic)).value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deep,
      body: _PhotoBackdrop(
        url: _mountain,
        darkness: .44,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: sequence,
            builder: (_, __) {
              final logo = v(.03, .35);
              final name = v(.36, .64);
              final tag = v(.62, .82);
              return Column(
                children: [
                  const Spacer(flex: 4),
                  Opacity(
                    opacity: logo,
                    child: Transform.scale(
                      scale: .62 + .38 * Curves.easeOutBack.transform(logo.clamp(0, .999)),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _aqua.withValues(alpha: .25)),
                          color: Colors.white.withValues(alpha: .035),
                        ),
                        child: const LogoMark(size: 104),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: name,
                    child: const FittedBox(
                      child: Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: tag,
                    child: const Text('Disaster Monitoring & Response', style: TextStyle(color: Colors.white70, fontSize: 14.5)),
                  ),
                  const Spacer(flex: 5),
                  Opacity(
                    opacity: tag,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 0, 26, 22),
                      child: Column(
                        children: [
                          const Text('Preparing live risk intelligence', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(value: tag, minHeight: 5, color: Colors.white, backgroundColor: Colors.white24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PhotoBackdrop extends StatelessWidget {
  final String url;
  final double darkness;
  final Widget child;

  const _PhotoBackdrop({required this.url, required this.child, this.darkness = .28});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round().clamp(720, 1440);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: ResizeImage(NetworkImage(url), width: width),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            frameBuilder: (_, child, frame, sync) => frame != null || sync
                ? child
                : const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF176579), _deep], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            errorBuilder: (_, __, ___) => const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF176579), _deep], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          ),
          Container(color: Colors.black.withValues(alpha: darkness)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x08000000), Color(0x20032833), Color(0xF3032833)], stops: [.1, .52, 1]),
            ),
          ),
          child,
        ],
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
      controller.nextPage(duration: const Duration(milliseconds: 330), curve: Curves.easeOutCubic);
    } else {
      Navigator.push(context, _route(const PremiumRolePicker()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (_tr(context, 'Safer Communities\nwith Smarter Monitoring', 'स्मार्ट निगरानी से\nसुरक्षित समुदाय', 'स्मार्ट निगरानीसँग\nसुरक्षित समुदाय'), _tr(context, 'AI-powered landslide intelligence combines rainfall, soil saturation, terrain and community evidence for earlier warning.', 'AI आधारित भूस्खलन प्रणाली बारिश, मिट्टी की नमी, भू-ढलान और सामुदायिक संकेतों को जोड़कर जल्दी चेतावनी देती है।', 'AI आधारित पहिरो प्रणालीले वर्षा, माटोको चिस्यान, भू-ढलान र सामुदायिक संकेत मिलाएर छिटो चेतावनी दिन्छ।'), _mountain, 'PREDICT'),
      (_tr(context, 'Real-Time Risk\nIntelligence', 'रियल-टाइम जोखिम\nइंटेलिजेंस', 'रियल-टाइम जोखिम\nजानकारी'), _tr(context, 'Live Nepal maps, explainable AI scoring, safe-route intelligence, sensors and verified alerts in one operational view.', 'लाइव नेपाल मैप, समझने योग्य AI स्कोर, सुरक्षित मार्ग, सेंसर और सत्यापित अलर्ट एक ही जगह।', 'लाइभ नेपाल नक्सा, बुझिने AI स्कोर, सुरक्षित मार्ग, सेन्सर र प्रमाणित सूचना एउटै स्थानमा।'), _riskMountain, 'UNDERSTAND'),
      (_tr(context, 'Report · Respond\n· Stay Safe', 'रिपोर्ट · रिस्पॉन्ड\n· सुरक्षित रहें', 'रिपोर्ट · प्रतिक्रिया\n· सुरक्षित रहनुहोस्'), _tr(context, 'Citizens, rescuers, authorities, volunteers and organisations share one coordinated response network when minutes matter.', 'नागरिक, बचाव दल, अधिकारी, स्वयंसेवक और संगठन एक ही समन्वित प्रतिक्रिया नेटवर्क में जुड़े रहते हैं।', 'नागरिक, उद्धार टोली, अधिकारी, स्वयंसेवक र संस्था एउटै समन्वित प्रतिक्रिया सञ्जालमा जोडिन्छन्।'), _rescueMountain, 'RESPOND'),
    ];
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: _deep,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: (v) => setState(() => index = v),
            itemBuilder: (_, i) {
              final s = slides[i];
              return _PhotoBackdrop(
                url: s.$3,
                darkness: i == 2 ? .37 : .27,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 92, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        _pill(s.$4, _aqua, dark: true),
                        const SizedBox(height: 13),
                        Text(s.$1, maxLines: 3, overflow: TextOverflow.fade, style: const TextStyle(color: Colors.white, fontSize: 30, height: 1.03, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                        const SizedBox(height: 15),
                        Text(s.$2, maxLines: 5, overflow: TextOverflow.fade, style: const TextStyle(color: Colors.white70, fontSize: 13.8, height: 1.45)),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Text('${i + 1} / 3', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 12),
                            ...List.generate(3, (d) => AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.only(right: 5), width: d == i ? 24 : 7, height: 7, decoration: BoxDecoration(color: d == i ? _aqua : Colors.white30, borderRadius: BorderRadius.circular(10)))),
                            const Spacer(),
                            TextButton(onPressed: () => Navigator.push(context, _route(const PremiumRolePicker())), child: Text(_tr(context, 'Skip', 'स्किप', 'छोड्नुहोस्'), style: const TextStyle(color: Colors.white70))),
                            const SizedBox(width: 5),
                            SizedBox(width: 52, height: 52, child: FloatingActionButton.small(heroTag: 'intro-$i', elevation: 0, backgroundColor: _aqua, foregroundColor: _navy, onPressed: next, child: Icon(i == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 26))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(top: safeTop + 12, left: 16, right: 16, child: const _FoundationControls()),
        ],
      ),
    );
  }
}

class _FoundationControls extends StatelessWidget {
  const _FoundationControls();

  @override
  Widget build(BuildContext context) {
    final p = AppPrefs.of(context);
    Widget control({required Widget child, required VoidCallback onTap}) => Expanded(
      child: Material(
        color: _deep.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24)), child: child),
        ),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<AppLang>(
            color: const Color(0xFF0B3541),
            initialValue: p.language,
            onSelected: p.setLanguage,
            itemBuilder: (_) => AppLang.values.map((l) => PopupMenuItem(value: l, child: Text(l.label, style: const TextStyle(color: Colors.white)))).toList(),
            child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: _deep.withValues(alpha: .88), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24)), child: Row(children: [const Icon(Icons.translate_rounded, color: Colors.white, size: 20), const SizedBox(width: 8), Expanded(child: Text(p.language.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60)])),
          ),
        ),
        const SizedBox(width: 9),
        control(
          onTap: () => p.setDark(!p.dark),
          child: Row(children: [Icon(p.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(p.dark ? 'Dark' : 'Light', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const Icon(Icons.swap_horiz_rounded, color: Colors.white54)]),
        ),
      ],
    );
  }
}

enum ExperienceRole { citizen, rescue, authority, volunteer, organization }

extension RoleInfo on ExperienceRole {
  String get title => switch (this) {
    ExperienceRole.citizen => 'Citizen',
    ExperienceRole.rescue => 'Rescue Team',
    ExperienceRole.authority => 'Authority',
    ExperienceRole.volunteer => 'Volunteer',
    ExperienceRole.organization => 'Organization',
  };
  String get subtitle => switch (this) {
    ExperienceRole.citizen => 'Report, receive alerts, navigate to safety',
    ExperienceRole.rescue => 'Dispatch, triage and coordinate field missions',
    ExperienceRole.authority => 'Monitor, verify, broadcast and command',
    ExperienceRole.volunteer => 'Support camps, check-ins and supply missions',
    ExperienceRole.organization => 'Offer shelters, inventory and logistics',
  };
  Color get color => switch (this) {
    ExperienceRole.citizen => _green,
    ExperienceRole.rescue => _red,
    ExperienceRole.authority => _blue,
    ExperienceRole.volunteer => _purple,
    ExperienceRole.organization => _orange,
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
      backgroundColor: _deep,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
            const SizedBox(height: 7),
            const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Select your role to open a purpose-built response experience.', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
            const SizedBox(height: 22),
            ...ExperienceRole.values.map((role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(context, _route(RoleLogin(role: role))),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [role.color, role.color.withValues(alpha: .72)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: role.color.withValues(alpha: .18), blurRadius: 18, offset: const Offset(0, 8))]),
                    child: Row(children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .93), borderRadius: BorderRadius.circular(15)), child: Icon(role.icon, color: role.color)),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 3), Text(role.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10.5))])),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ]),
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

  void enter() => Navigator.pushAndRemoveUntil(context, _route(RoleExperienceShell(role: widget.role)), (_) => false);

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return Scaffold(
      backgroundColor: _deep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            const SizedBox(height: 18),
            Center(child: Column(children: [const LogoMark(size: 78), const SizedBox(height: 7), const Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 10), _pill('${role.title} access', role.color, dark: true)])),
            const SizedBox(height: 30),
            const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
            const Text('Sign in to continue', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            _loginField(email, Icons.person_outline_rounded, 'Email or Phone'),
            const SizedBox(height: 12),
            _loginField(password, Icons.lock_outline_rounded, 'Password', obscure: true),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 54, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: role.color), onPressed: enter, child: Text('Sign in as ${role.title}', style: const TextStyle(fontWeight: FontWeight.w900)))),
            const SizedBox(height: 11),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)), onPressed: enter, icon: const Icon(Icons.auto_awesome_rounded, size: 18), label: const Text('Use SIH demo access'))),
          ]),
        ),
      ),
    );
  }
}

Widget _loginField(TextEditingController controller, IconData icon, String hint, {bool obscure = false}) => TextField(
  controller: controller,
  obscureText: obscure,
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white54), prefixIcon: Icon(icon, color: Colors.white60), filled: true, fillColor: Colors.white.withValues(alpha: .09), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _aqua))),
);

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
      final pages = const [CitizenHome(), LiveRiskMap(), CitizenSos(), RichAlerts(), CitizenMore()];
      const labels = ['Home', 'Map', 'SOS', 'Alerts', 'More'];
      const icons = [Icons.home_rounded, Icons.map_rounded, Icons.sos_rounded, Icons.notifications_rounded, Icons.grid_view_rounded];
      return _RoleScaffold(index: index, onIndex: (v) => setState(() => index = v), pages: pages, labels: labels, icons: icons, color: _green);
    }

    final config = RoleVisualConfig.forRole(widget.role);
    final pages = [
      OpsDashboard(role: widget.role, config: config),
      OperationsBoard(role: widget.role, config: config),
      CommunicationHub(role: widget.role, config: config),
      IntelligenceFeed(role: widget.role, config: config),
      RoleToolkit(role: widget.role, config: config),
    ];
    return _RoleScaffold(index: index, onIndex: (v) => setState(() => index = v), pages: pages, labels: config.tabs, icons: config.icons, color: config.accent, dark: config.darkShell);
  }
}

class _RoleScaffold extends StatelessWidget {
  final int index;
  final ValueChanged<int> onIndex;
  final List<Widget> pages;
  final List<String> labels;
  final List<IconData> icons;
  final Color color;
  final bool dark;

  const _RoleScaffold({required this.index, required this.onIndex, required this.pages, required this.labels, required this.icons, required this.color, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF06151B) : _bg,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onIndex,
        backgroundColor: dark ? const Color(0xFF0A222B) : Colors.white,
        indicatorColor: color.withValues(alpha: dark ? .25 : .14),
        destinations: List.generate(labels.length, (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i])),
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
          const SliverToBoxAdapter(child: _CitizenHero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList.list(children: [
              _tapCard(context, child: const _WarningCard(), onTap: () => Navigator.push(context, _route(const RiskAnalysisScreen()))),
              const SizedBox(height: 12),
              const Row(children: [Expanded(child: _metric(Icons.cloudy_snowing, _blue, '12°C', 'Heavy rain')), SizedBox(width: 9), Expanded(child: _metric(Icons.water_drop_rounded, _cyan, '87%', 'Soil saturation'))]),
              const SizedBox(height: 20),
              _section('Safety tools', 'Live, actionable and one tap away'),
              const SizedBox(height: 10),
              const _CitizenTools(),
              const SizedBox(height: 20),
              _tapCard(context, onTap: () => Navigator.push(context, _route(const PersonalSafetyInteractive())), child: const _GradientFeature(icon: Icons.family_restroom_rounded, title: 'Personal Safety', subtitle: '4 family members · 3 safe · 1 awaiting check-in', colors: [_navy, Color(0xFF0A866D)])),
              const SizedBox(height: 20),
              _section('AI Slope Sentinel', 'Explainable risk, not a black box'),
              const SizedBox(height: 10),
              _tapCard(context, onTap: () => Navigator.push(context, _route(const RiskAnalysisScreen())), child: const Row(children: [MiniGauge(), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('High landslide probability', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), SizedBox(height: 4), Text('Rainfall + soil saturation + slope geometry are driving the score.', style: TextStyle(color: Colors.black54, fontSize: 10.5, height: 1.35)), SizedBox(height: 8), Text('WHY THIS SCORE  →', style: TextStyle(color: _blue, fontSize: 9.5, fontWeight: FontWeight.w900))]))])),
              const SizedBox(height: 20),
              _section('Community pulse', 'Verified signals around you'),
              const SizedBox(height: 10),
              _tapCard(context, onTap: () => _showInfo(context, 'Community evidence', '3 nearby reports are cross-checked against rainfall and sensor telemetry.'), child: const Column(children: [_Signal(icon: Icons.landscape_rounded, color: _red, title: 'Slope movement reported', subtitle: 'Sindhupalchok · 2.4 km · AI verified', badge: '92%'), Divider(height: 24), _Signal(icon: Icons.route_rounded, color: _orange, title: 'Road partially blocked', subtitle: 'Araniko Highway · 4.1 km', badge: '3 reports')]))
            ]),
          ),
        ],
      ),
    );
  }
}

class _CitizenHero extends StatelessWidget {
  const _CitizenHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(_mountain, fit: BoxFit.cover, filterQuality: FilterQuality.medium, errorBuilder: (_, __, ___) => Container(color: _navy)),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40102A33), Color(0xF2073C4D)]))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: LayoutBuilder(builder: (_, box) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.person_rounded, color: Colors.white)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Namaste,', style: TextStyle(color: Colors.white60, fontSize: 10)), Text('Citizen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))])), _iconGlass(Icons.notifications_active_rounded)]),
              const Spacer(),
              const Text('NEPAL RISK INTELLIGENCE', style: TextStyle(color: _aqua, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 5),
              const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Know the slope\nbefore it moves.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1, fontWeight: FontWeight.w900, letterSpacing: -.5))),
              const SizedBox(height: 14),
              const Row(children: [Expanded(child: _HeroStat('RISK', '78%', _red)), SizedBox(width: 7), Expanded(child: _HeroStat('24H RAIN', '126 mm', _blue)), SizedBox(width: 7), Expanded(child: _HeroStat('SAFE HUBS', '18', _green))]),
            ])),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String keyText;
  final String value;
  final Color color;
  const _HeroStat(this.keyText, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white.withValues(alpha: .14))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(keyText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .5)), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)))]));
}

Widget _iconGlass(IconData icon) => Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white24)), child: Icon(icon, color: Colors.white));

class _WarningCard extends StatelessWidget {
  const _WarningCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3150), Color(0xFFF05662)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _red.withValues(alpha: .18), blurRadius: 18, offset: const Offset(0, 7))]), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 22, backgroundColor: Color(0x22FFFFFF), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)), SizedBox(height: 5), Text('Potential slope failure within 12 hours. A safer evacuation corridor is ready.', style: TextStyle(color: Colors.white, fontSize: 11.2, height: 1.35)), SizedBox(height: 9), Text('OPEN EARLY WARNING  →', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900))]))]));
}

class _CitizenTools extends StatelessWidget {
  const _CitizenTools();
  @override
  Widget build(BuildContext context) {
    final data = [
      (Icons.map_rounded, 'Live Risk\nMap', _green, const LiveRiskMap()),
      (Icons.route_rounded, 'Safe\nRoute', _cyan, const SafeRouteInteractive()),
      (Icons.psychology_alt_rounded, 'AI Risk\nAnalysis', _blue, const RiskAnalysisScreen()),
      (Icons.post_add_rounded, 'Report\nIncident', _orange, const IncidentReporter()),
      (Icons.inventory_2_rounded, 'Relief &\nResources', _green, const ResourceFinder()),
      (Icons.smart_toy_rounded, 'AI Safety\nAssistant', _purple, const SafetyAssistant()),
    ];
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.04), itemBuilder: (_, i) {
      final x = data[i];
      return Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => Navigator.push(context, _route(x.$4)), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8F0F2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: x.$3.withValues(alpha: .11), borderRadius: BorderRadius.circular(12)), child: Icon(x.$1, color: x.$3, size: 22)), const SizedBox(height: 7), Text(x.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, height: 1.12, fontWeight: FontWeight.w900))]))));
    });
  }
}

class MiniGauge extends StatelessWidget {
  const MiniGauge({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(width: 70, height: 70, child: Stack(alignment: Alignment.center, children: [SizedBox(width: 64, height: 64, child: CircularProgressIndicator(value: .78, strokeWidth: 8, color: _red, backgroundColor: const Color(0xFFFFE3E8))), const Text('78%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]));
}

class _Signal extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  const _Signal({required this.icon, required this.color, required this.title, required this.subtitle, required this.badge});
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.2))])), _pill(badge, color)]);
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
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), child: Column(children: [Row(children: [const Text('Risk Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const Spacer(), _pill('●  LIVE MAP', _green)]), const SizedBox(height: 13), Row(children: [Expanded(child: _segButton('Live', !forecast, () => setState(() => forecast = false))), const SizedBox(width: 9), Expanded(child: _segButton('Next 48 Hours', forecast, () => setState(() => forecast = true)))])])),
      Expanded(child: FlutterMap(options: MapOptions(initialCenter: const LatLng(27.72, 85.4), initialZoom: 6.9), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.jeevansetu.app'), PolygonLayer(polygons: [Polygon(points: const [LatLng(27.72,85.25), LatLng(27.91,85.38), LatLng(27.82,85.65), LatLng(27.62,85.55)], color: _red.withValues(alpha: .2), borderColor: _red, borderStrokeWidth: 2)]), MarkerLayer(markers: [const LatLng(27.82,85.55), const LatLng(27.71,85.32), const LatLng(28.20,83.98), const LatLng(27.52,84.35)].asMap().entries.map((e) { final colors = [_red,_orange,_orange,_green]; return Marker(point: e.value, width: 50, height: 50, child: Icon(Icons.location_on_rounded, color: colors[e.key], size: 42)); }).toList())]))
    ]));
  }
}

Widget _segButton(String text, bool active, VoidCallback action) => Material(color: active ? _navy : const Color(0xFFE6EDF0), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: action, borderRadius: BorderRadius.circular(12), child: SizedBox(height: 44, child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.w900))))));

class CitizenSos extends StatefulWidget {
  const CitizenSos({super.key});
  @override
  State<CitizenSos> createState() => _CitizenSosState();
}

class _CitizenSosState extends State<CitizenSos> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  int people = 2;
  bool medical = false;
  bool locationLocked = true;
  bool evidenceAttached = false;
  String emergency = 'Landslide / trapped';

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1050))..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  void send() => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => const _SosTrackingSheet());

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 26), children: [
      Row(children: [const Expanded(child: Text('SOS Emergency', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))), _pill('GPS LOCKED', _green)]),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: _navy.withValues(alpha: .06), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.near_me_rounded, color: _navy, size: 18), SizedBox(width: 8), Expanded(child: Text('Sindhupalchok · 27.829°N, 85.548°E', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800))), Text('± 8 m', style: TextStyle(color: _green, fontSize: 9, fontWeight: FontWeight.w900))])),
      const SizedBox(height: 15),
      Center(child: AnimatedBuilder(animation: pulse, builder: (_, __) => GestureDetector(onLongPress: send, child: Container(width: 196 + pulse.value * 12, height: 196 + pulse.value * 12, decoration: BoxDecoration(shape: BoxShape.circle, color: _red.withValues(alpha: .08), boxShadow: [BoxShadow(color: _red.withValues(alpha: .15), blurRadius: 34, spreadRadius: 5)]), alignment: Alignment.center, child: Container(width: 146, height: 146, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF5267), _red])), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sos_rounded, color: Colors.white, size: 48), Text('PRESS & HOLD', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w900))]))))),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: _miniAction(Icons.call_rounded, 'Emergency call', _red, () => Navigator.push(context, _route(const CallScreen(title: 'District Rescue Desk', video: false))))), const SizedBox(width: 8), Expanded(child: _miniAction(Icons.videocam_rounded, 'Video assist', _blue, () => Navigator.push(context, _route(const CallScreen(title: 'Medical Response Team', video: true)))))]),
      const SizedBox(height: 16),
      _card(child: Column(children: [
        ListTile(leading: const Icon(Icons.crisis_alert_rounded, color: _navy), title: const Text('Type of Emergency', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(emergency), trailing: const Icon(Icons.swap_horiz_rounded), onTap: () => setState(() => emergency = emergency == 'Landslide / trapped' ? 'Flood / stranded' : 'Landslide / trapped')),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.groups_rounded, color: _navy), title: const Text('Number of People', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('$people people'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => setState(() => people = math.max(1, people - 1)), icon: const Icon(Icons.remove_circle_outline_rounded)), IconButton(onPressed: () => setState(() => people++), icon: const Icon(Icons.add_circle_outline_rounded))])),
        const Divider(height: 1),
        SwitchListTile(secondary: const Icon(Icons.medical_services_rounded, color: _navy), title: const Text('Medical Assistance', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Prioritises nearest medical unit'), value: medical, onChanged: (v) => setState(() => medical = v)),
        const Divider(height: 1),
        ListTile(leading: Icon(evidenceAttached ? Icons.verified_rounded : Icons.add_a_photo_rounded, color: evidenceAttached ? _green : _navy), title: Text(evidenceAttached ? 'Evidence attached' : 'Photo / Video Evidence', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(evidenceAttached ? '1 image · encrypted with SOS packet' : 'Tap to attach a quick scene snapshot'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => setState(() => evidenceAttached = !evidenceAttached)),
        const Divider(height: 1),
        SwitchListTile(secondary: const Icon(Icons.location_on_rounded, color: _navy), title: const Text('Share live location', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Updates responder map every 10 seconds'), value: locationLocked, onChanged: (v) => setState(() => locationLocked = v)),
      ])),
      const SizedBox(height: 15),
      SizedBox(height: 56, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: _red), onPressed: send, child: const Text('Send Emergency Request', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)))),
    ]));
  }
}

class _SosTrackingSheet extends StatefulWidget {
  const _SosTrackingSheet();
  @override
  State<_SosTrackingSheet> createState() => _SosTrackingSheetState();
}

class _SosTrackingSheetState extends State<_SosTrackingSheet> {
  int eta = 11;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (_) { if (mounted && eta > 7) setState(() => eta--); });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [CircleAvatar(backgroundColor: Color(0xFFE5F9F1), child: Icon(Icons.check_rounded, color: _green)), SizedBox(width: 10), Expanded(child: Text('SOS accepted by Rescue Unit 04', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)))]),
    const SizedBox(height: 16),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_deep, _navy]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.emergency_share_rounded, color: _aqua, size: 34), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Responder en route', style: TextStyle(color: Colors.white70, fontSize: 11)), Text('$eta min ETA', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))])), const _LiveDot()])),
    const SizedBox(height: 14),
    const _TimelineItem(done: true, title: 'SOS packet transmitted', subtitle: 'Location + risk context + medical priority'),
    const _TimelineItem(done: true, title: 'Dispatch acknowledged', subtitle: 'Unit 04 · 3 responders'),
    const _TimelineItem(done: false, title: 'Rescue team approaching', subtitle: 'Live location channel active'),
    const SizedBox(height: 13),
    Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, _route(const CallScreen(title: 'Rescue Unit 04', video: false))), icon: const Icon(Icons.call_rounded), label: const Text('Voice'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, _route(const CallScreen(title: 'Rescue Unit 04', video: true))), icon: const Icon(Icons.videocam_rounded), label: const Text('Video')))]),
  ]));
}

class _TimelineItem extends StatelessWidget {
  final bool done;
  final String title;
  final String subtitle;
  const _TimelineItem({required this.done, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 11, backgroundColor: done ? _green : const Color(0xFFE7EEF0), child: Icon(done ? Icons.check_rounded : Icons.more_horiz_rounded, size: 14, color: done ? Colors.white : _navy)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))]))]));
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
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 28), children: [
      Row(children: [const Text('Alerts', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const Spacer(), _pill('3 ACTIVE', _red)]),
      const SizedBox(height: 13),
      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(4, (i) { final text = ['All', 'Critical', 'Weather', 'Mobility'][i]; return Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(text), selected: filter == i, onSelected: (_) => setState(() => filter = i))); })),
      const SizedBox(height: 13),
      _tapCard(context, onTap: () => Navigator.push(context, _route(const RiskAnalysisScreen())), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 190, child: Stack(fit: StackFit.expand, children: [Image.network(_riskMountain, fit: BoxFit.cover, filterQuality: FilterQuality.medium, errorBuilder: (_, __, ___) => Container(color: _navy)), const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0xE0072631)]))), const Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_LiveDot(label: 'CRITICAL · NOW'), Spacer(), Text('High Landslide Risk', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Sindhupalchok · 2.4 km from you', style: TextStyle(color: Colors.white70, fontSize: 11)), SizedBox(height: 11), Row(children: [Icon(Icons.route_rounded, color: _aqua, size: 18), SizedBox(width: 6), Text('Safer corridor available', style: TextStyle(color: _aqua, fontWeight: FontWeight.w900, fontSize: 10))])]))]))),
      const SizedBox(height: 12),
      const _RichAlertRow(icon: Icons.cloudy_snowing, color: _blue, title: 'Heavy Rainfall Expected', subtitle: 'Next 6 hours · 126 mm / 24h', signal: 'Weather radar + 4 gauges'),
      const SizedBox(height: 10),
      const _RichAlertRow(icon: Icons.route_rounded, color: _orange, title: 'Araniko Highway restricted', subtitle: 'Partial blockage · 4.1 km away', signal: '3 citizen reports verified'),
      const SizedBox(height: 20),
      _section('Alert intelligence', 'Why these alerts reached you'),
      const SizedBox(height: 10),
      _card(child: Column(children: [const Row(children: [Icon(Icons.verified_user_rounded, color: _green), SizedBox(width: 9), Expanded(child: Text('Sensor + weather + community evidence agree on elevated slope instability.', style: TextStyle(fontSize: 11, height: 1.4)))]), const SizedBox(height: 14), const LinearProgressIndicator(value: .92, minHeight: 8, color: _green, backgroundColor: Color(0xFFE6F6F0), borderRadius: BorderRadius.all(Radius.circular(9))), const SizedBox(height: 7), Row(children: [const Text('Verification confidence', style: TextStyle(color: Colors.black45, fontSize: 9.5)), const Spacer(), Text('92%', style: TextStyle(color: _green, fontWeight: FontWeight.w900))])])),
    ]));
  }
}

class _RichAlertRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String signal;
  const _RichAlertRow({required this.icon, required this.color, required this.title, required this.subtitle, required this.signal});
  @override
  Widget build(BuildContext context) => _card(child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 27)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 10)), const SizedBox(height: 5), Text(signal, style: TextStyle(color: color, fontSize: 8.8, fontWeight: FontWeight.w900))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)]));
}

class CitizenMore extends StatelessWidget {
  const CitizenMore({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.family_restroom_rounded, 'Personal Safety', 'Family live status & check-in', _green, const PersonalSafetyInteractive()),
      (Icons.sensors_rounded, 'Sensor Network', 'Live rain, soil & slope telemetry', _blue, const SensorNetworkInteractive()),
      (Icons.inventory_2_outlined, 'Relief & Resources', 'Camps, hospitals and supplies', _orange, const ResourceFinder()),
      (Icons.smart_toy_outlined, 'AI Assistant', 'Interactive safety guidance', _purple, const SafetyAssistant()),
      (Icons.download_for_offline_outlined, 'Offline Readiness', 'Emergency pack synced locally', _cyan, const OfflineInteractive()),
      (Icons.shield_outlined, 'Safety Guidelines', 'Action cards for landslide survival', _red, const GuidelinesInteractive()),
      (Icons.contact_emergency_outlined, 'Emergency Contacts', 'Voice & video response channels', _blue, const ContactCenter()),
    ];
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 28), children: [
      const Text('More', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      Container(height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [_deep, _navy])), child: Stack(children: [Positioned(right: -10, top: -20, child: Icon(Icons.public_rounded, size: 150, color: Colors.white.withValues(alpha: .04))), Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: _green.withValues(alpha: .18), shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: _green, size: 34)), const SizedBox(width: 14), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Citizen', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Connected to JeevanSetu response mesh', style: TextStyle(color: Colors.white60, fontSize: 10)), SizedBox(height: 9), _LiveDot(label: 'ONLINE · GPS READY')]))]))])),
      const SizedBox(height: 12),
      ...items.map((x) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.push(context, _route(x.$5)), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8F0F2))), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: x.$4.withValues(alpha: .09), borderRadius: BorderRadius.circular(14)), child: Icon(x.$1, color: x.$4)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.$2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(x.$3, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)]))))),
      OutlinedButton.icon(onPressed: () => Navigator.pushAndRemoveUntil(context, _route(const PremiumRolePicker()), (_) => false), icon: const Icon(Icons.swap_horiz_rounded), label: const Text('Switch profession / role')),
    ]));
  }
}

class PersonalSafetyInteractive extends StatefulWidget {
  const PersonalSafetyInteractive({super.key});
  @override
  State<PersonalSafetyInteractive> createState() => _PersonalSafetyInteractiveState();
}

class _PersonalSafetyInteractiveState extends State<PersonalSafetyInteractive> {
  bool checked = false;
  bool sister = false;
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'Personal Safety', Column(children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, Color(0xFF08798A)]), borderRadius: BorderRadius.circular(22)), child: Row(children: [const Icon(Icons.verified_user_rounded, color: _aqua, size: 42), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(checked ? 'You checked in safely' : 'You are in a monitored zone', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), Text(checked ? 'Live status updated just now' : 'Last safety check-in 22 min ago', style: const TextStyle(color: Colors.white60, fontSize: 10))])), FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _navy), onPressed: () => setState(() => checked = true), child: Text(checked ? 'Safe ✓' : 'Check in'))])),
    const SizedBox(height: 14),
    _familyRow('You', checked ? 'Safe · just now' : 'Safe · live location', true), const SizedBox(height: 9),
    _familyRow('Mother', 'Safe · 2 min ago', true), const SizedBox(height: 9),
    _familyRow('Father', 'Safe · 18 min ago', true), const SizedBox(height: 9),
    Material(color: Colors.white, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => setState(() => sister = true), child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [CircleAvatar(backgroundColor: (sister ? _green : _orange).withValues(alpha: .12), child: Icon(Icons.person_rounded, color: sister ? _green : _orange)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sister', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(sister ? 'Safe · confirmed just now' : 'Awaiting check-in · tap to request', style: TextStyle(color: sister ? _green : _orange, fontSize: 10))])), Icon(sister ? Icons.verified_rounded : Icons.notifications_active_rounded, color: sister ? _green : _orange)]))))
  ]));
}

Widget _familyRow(String name, String status, bool safe) => _card(child: Row(children: [CircleAvatar(backgroundColor: (safe ? _green : _orange).withValues(alpha: .12), child: Icon(Icons.person_rounded, color: safe ? _green : _orange)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(status, style: TextStyle(color: safe ? _green : _orange, fontSize: 10))])), const Icon(Icons.chevron_right_rounded, color: Colors.black38)]));

class SensorNetworkInteractive extends StatefulWidget {
  const SensorNetworkInteractive({super.key});
  @override
  State<SensorNetworkInteractive> createState() => _SensorNetworkInteractiveState();
}

class _SensorNetworkInteractiveState extends State<SensorNetworkInteractive> {
  int sync = 14;
  Timer? timer;
  @override
  void initState() { super.initState(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => sync = sync == 1 ? 14 : sync - 1); }); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'Sensor Network', Column(children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, _blue]), borderRadius: BorderRadius.circular(22)), child: Row(children: [Expanded(child: _sensorTop('26/28', 'Sensors online')), Container(width: 1, height: 48, color: Colors.white24), Expanded(child: _sensorTop('$sync sec', 'Next sync')), Container(width: 1, height: 48, color: Colors.white24), Expanded(child: _sensorTop('96%', 'Mesh health'))])),
    const SizedBox(height: 14),
    const _SensorTile(Icons.water_drop_outlined, _blue, 'Rain Gauge SG-04', '18.4 mm/hr · Rising', .82), const SizedBox(height: 10),
    const _SensorTile(Icons.waves_rounded, _red, 'Soil Probe SM-12', '87% saturation · Critical', .87), const SizedBox(height: 10),
    const _SensorTile(Icons.straighten_rounded, _orange, 'Slope Node IN-07', '2.8 mm movement · Watch', .62), const SizedBox(height: 10),
    const _SensorTile(Icons.cloud_outlined, _green, 'Weather Station WX-03', 'Pressure falling · Active', .48),
  ]));
}

Widget _sensorTop(String value, String label) => Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 8.5))]);

class _SensorTile extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle; final double value;
  const _SensorTile(this.icon, this.color, this.title, this.subtitle, this.value);
  @override
  Widget build(BuildContext context) => _card(child: Column(children: [Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))]))]), const SizedBox(height: 10), LinearProgressIndicator(value: value, minHeight: 6, color: color, backgroundColor: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10))]));
}

class OfflineInteractive extends StatefulWidget {
  const OfflineInteractive({super.key});
  @override
  State<OfflineInteractive> createState() => _OfflineInteractiveState();
}

class _OfflineInteractiveState extends State<OfflineInteractive> {
  bool syncing = false;
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'Offline Readiness', Column(children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, Color(0xFF098496)]), borderRadius: BorderRadius.circular(22)), child: Column(children: [const CircleAvatar(radius: 30, backgroundColor: _aqua, child: Icon(Icons.bolt_rounded, color: _navy, size: 34)), const SizedBox(height: 14), Text(syncing ? 'Refreshing emergency pack…' : 'Emergency pack ready offline', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(height: 5), const Text('Risk snapshot, safety guides and verified contacts are stored on this device.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 10.5)), const SizedBox(height: 12), OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)), onPressed: () { setState(() => syncing = true); Future.delayed(const Duration(milliseconds: 900), () { if (mounted) setState(() => syncing = false); }); }, icon: const Icon(Icons.sync_rounded), label: Text(syncing ? 'Syncing' : 'Refresh pack'))])),
    const SizedBox(height: 14), const _OfflineRow(Icons.map_rounded, 'Risk snapshot', 'Updated 3 min ago'), const SizedBox(height: 9), const _OfflineRow(Icons.shield_outlined, 'Safety guidelines', 'Available offline'), const SizedBox(height: 9), const _OfflineRow(Icons.contact_emergency_outlined, 'Emergency contacts', 'Available offline'), const SizedBox(height: 9), const _OfflineRow(Icons.route_rounded, 'Last safe route', '6.3 km route cached'),
  ]));
}

class _OfflineRow extends StatelessWidget { final IconData icon; final String title; final String subtitle; const _OfflineRow(this.icon, this.title, this.subtitle); @override Widget build(BuildContext context) => _card(child: Row(children: [Icon(icon, color: _green, size: 28), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])), const Icon(Icons.check_circle_rounded, color: _green)])); }

class GuidelinesInteractive extends StatelessWidget {
  const GuidelinesInteractive({super.key});
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'Safety Guidelines', const Column(children: [
    _Guide(1, _red, 'Move away from steep slopes', 'Do not wait directly below a visibly unstable slope or drainage channel.'), SizedBox(height: 10),
    _Guide(2, _orange, 'Follow verified evacuation routes', 'Avoid shortcuts through red zones even when they appear faster.'), SizedBox(height: 10),
    _Guide(3, _blue, 'Keep an emergency go-bag', 'Carry water, medicines, light, power bank and identity documents.'), SizedBox(height: 10),
    _Guide(4, _green, 'Check in with family', 'Use Personal Safety so responders know who is safe and who needs help.'),
  ]));
}

class _Guide extends StatelessWidget { final int n; final Color color; final String title; final String body; const _Guide(this.n, this.color, this.title, this.body); @override Widget build(BuildContext context) => _card(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 24, backgroundColor: color, child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 3), Text(body, style: const TextStyle(color: Colors.black54, fontSize: 10.5, height: 1.35))]))])); }

class ContactCenter extends StatelessWidget {
  const ContactCenter({super.key});
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'Emergency Contacts', Column(children: [
    _contact(context, 'National Emergency', '112', _red), const SizedBox(height: 9), _contact(context, 'District Response Desk', '1077', _blue), const SizedBox(height: 9), _contact(context, 'Nearest Medical Team', 'Available', _green, video: true), const SizedBox(height: 9), _contact(context, 'JeevanSetu Command', 'In-app radio', _purple, video: true),
  ]));
}

Widget _contact(BuildContext context, String title, String status, Color color, {bool video = false}) => _card(child: Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: .1), child: Icon(Icons.call_rounded, color: color)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))), Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)), IconButton(onPressed: () => Navigator.push(context, _route(CallScreen(title: title, video: false))), icon: const Icon(Icons.call_outlined)), if (video) IconButton(onPressed: () => Navigator.push(context, _route(CallScreen(title: title, video: true))), icon: const Icon(Icons.videocam_outlined))]));

class RiskAnalysisScreen extends StatelessWidget {
  const RiskAnalysisScreen({super.key});
  @override
  Widget build(BuildContext context) => _detailScaffold(context, 'AI Risk Analysis', Column(children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_deep, _navy]), borderRadius: BorderRadius.circular(22)), child: const Row(children: [MiniGauge(), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('78% · High probability', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)), SizedBox(height: 4), Text('Model confidence 92% · next 12 hours', style: TextStyle(color: Colors.white60, fontSize: 10)), SizedBox(height: 9), _LiveDot(label: 'UPDATED 14 SEC AGO')]))])),
    const SizedBox(height: 14),
    _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Risk drivers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), const SizedBox(height: 12), _driver('24h rainfall', '126 mm', .86, _blue), _driver('Soil saturation', '87%', .87, _red), _driver('Slope movement', '2.8 mm', .64, _orange), _driver('Community evidence', '5 reports', .72, _purple)])),
    const SizedBox(height: 12),
    _card(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('What the AI is seeing', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), SizedBox(height: 8), Text('Rainfall has exceeded the 7-day baseline while soil probes are above the local saturation threshold. The slope node shows small but increasing movement. Nearby verified reports agree with the sensor pattern.', style: TextStyle(color: Colors.black54, height: 1.45, fontSize: 11)), SizedBox(height: 12), Row(children: [Icon(Icons.verified_rounded, color: _green), SizedBox(width: 7), Expanded(child: Text('Explainable score · no single sensor decides the alert', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10))])])),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.push(context, _route(const SafeRouteInteractive())), icon: const Icon(Icons.route_rounded), label: const Text('Open safest evacuation route'))),
  ]));
}

Widget _driver(String label, String value, double p, Color color) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Column(children: [Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)), const Spacer(), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10.5))]), const SizedBox(height: 5), LinearProgressIndicator(value: p, minHeight: 7, color: color, backgroundColor: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10))]));

class SafeRouteInteractive extends StatefulWidget { const SafeRouteInteractive({super.key}); @override State<SafeRouteInteractive> createState() => _SafeRouteInteractiveState(); }
class _SafeRouteInteractiveState extends State<SafeRouteInteractive> {
  int route = 0;
  @override Widget build(BuildContext context) => _detailScaffold(context, 'Safe Route', Column(children: [
    Container(height: 230, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFFD9F2EC), Color(0xFFE3EEFA)])), child: CustomPaint(painter: _RoutePainter(route), child: const Center(child: Icon(Icons.near_me_rounded, color: _navy, size: 34)))),
    const SizedBox(height: 12),
    _card(child: Column(children: [Row(children: [Expanded(child: _routeChoice(0, 'Safest', '6.3 km · 18 min', _green)), const SizedBox(width: 8), Expanded(child: _routeChoice(1, 'Fastest', '5.1 km · 14 min', _orange))]), const SizedBox(height: 12), const Row(children: [Icon(Icons.shield_rounded, color: _green), SizedBox(width: 7), Expanded(child: Text('Selected path avoids two active red zones and one blocked bridge.', style: TextStyle(fontSize: 10.5, height: 1.35)))])])),
  ]));
  Widget _routeChoice(int i, String title, String sub, Color color) => InkWell(onTap: () => setState(() => route = i), child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: route == i ? color.withValues(alpha: .1) : _bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: route == i ? color : const Color(0xFFE2EAEC))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: route == i ? color : _ink, fontWeight: FontWeight.w900)), Text(sub, style: const TextStyle(color: Colors.black45, fontSize: 9.5))])));
}

class _RoutePainter extends CustomPainter { final int route; _RoutePainter(this.route); @override void paint(Canvas c, Size s) { final p = Paint()..color = route == 0 ? _green : _orange..strokeWidth = 7..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final path = Path()..moveTo(s.width*.12,s.height*.82)..cubicTo(s.width*.25,s.height*.55,s.width*.52,s.height*.78,s.width*.62,s.height*.44)..cubicTo(s.width*.70,s.height*.17,s.width*.84,s.height*.27,s.width*.9,s.height*.13); c.drawPath(path,p); for (final point in [Offset(s.width*.12,s.height*.82),Offset(s.width*.9,s.height*.13)]) { c.drawCircle(point,9,Paint()..color=_navy); } } @override bool shouldRepaint(_RoutePainter old) => old.route != route; }

class IncidentReporter extends StatefulWidget { const IncidentReporter({super.key}); @override State<IncidentReporter> createState()=>_IncidentReporterState(); }
class _IncidentReporterState extends State<IncidentReporter> { int type=0; bool photo=false; bool sent=false; @override Widget build(BuildContext context)=>_detailScaffold(context,'Report Incident',Column(children:[
  _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[const Text('What do you see?',style:TextStyle(fontWeight:FontWeight.w900,fontSize:15)),const SizedBox(height:10),Wrap(spacing:7,runSpacing:7,children:['Slope crack','Falling rocks','Blocked road','Flood water'].asMap().entries.map((e)=>ChoiceChip(label:Text(e.value),selected:type==e.key,onSelected:(_)=>setState(()=>type=e.key))).toList()),const SizedBox(height:12),ListTile(contentPadding:EdgeInsets.zero,leading:Icon(photo?Icons.verified_rounded:Icons.add_a_photo_rounded,color:photo?_green:_orange),title:Text(photo?'Photo evidence ready':'Add photo evidence',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:const Text('Adds timestamp and approximate location'),onTap:()=>setState(()=>photo=!photo))])),
  const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:(){setState(()=>sent=true);},icon:Icon(sent?Icons.check_rounded:Icons.send_rounded),label:Text(sent?'Report queued for verification':'Submit verified report'))),if(sent)...[const SizedBox(height:12),_card(child:const Row(children:[Icon(Icons.auto_awesome_rounded,color:_purple),SizedBox(width:9),Expanded(child:Text('AI cross-check started against nearby sensors and duplicate reports.',style:TextStyle(fontSize:10.5,height:1.4))) ]))]
])); }

class ResourceFinder extends StatelessWidget { const ResourceFinder({super.key}); @override Widget build(BuildContext context)=>_detailScaffold(context,'Relief & Resources',Column(children:[
  Container(height:150,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[_navy,Color(0xFF0B8A75)])),child:const Padding(padding:EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_LiveDot(label:'18 SAFE HUBS ONLINE'),Spacer(),Text('Nearest: Melamchi Relief Hub',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:18)),Text('2.7 km · 84 spaces · medical desk active',style:TextStyle(color:Colors.white60,fontSize:10))]))),
  const SizedBox(height:12),const _ResourceRow(Icons.local_hospital_rounded,_red,'District Hospital','12 beds · 3.9 km'),const SizedBox(height:9),const _ResourceRow(Icons.water_drop_rounded,_blue,'Water & food point','1.8 km · stocked 38 min ago'),const SizedBox(height:9),const _ResourceRow(Icons.charging_station_rounded,_orange,'Power & charging','2.1 km · 14 ports free')
])); }
class _ResourceRow extends StatelessWidget{final IconData icon;final Color color;final String title;final String sub;const _ResourceRow(this.icon,this.color,this.title,this.sub);@override Widget build(BuildContext context)=>_card(child:Row(children:[CircleAvatar(backgroundColor:color.withValues(alpha:.1),child:Icon(icon,color:color)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),Text(sub,style:const TextStyle(color:Colors.black45,fontSize:9.5))])),const Icon(Icons.directions_rounded,color:_navy)]));}

class SafetyAssistant extends StatefulWidget { const SafetyAssistant({super.key}); @override State<SafetyAssistant> createState()=>_SafetyAssistantState(); }
class _SafetyAssistantState extends State<SafetyAssistant>{final messages=<String>['I can explain your current risk, safest route, SOS steps, or what to pack.']; final field=TextEditingController(); @override void dispose(){field.dispose();super.dispose();} @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('AI Safety Assistant',style:TextStyle(fontWeight:FontWeight.w900))),body:Column(children:[Expanded(child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:messages.length,itemBuilder:(_,i)=>Align(alignment:i.isEven?Alignment.centerLeft:Alignment.centerRight,child:Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(12),constraints:BoxConstraints(maxWidth:MediaQuery.sizeOf(context).width*.78),decoration:BoxDecoration(color:i.isEven?_navy:const Color(0xFFDFF7F8),borderRadius:BorderRadius.circular(16)),child:Text(messages[i],style:TextStyle(color:i.isEven?Colors.white:_ink,fontSize:11,height:1.4)))))),Padding(padding:EdgeInsets.fromLTRB(12,8,12,MediaQuery.paddingOf(context).bottom+8),child:Row(children:[Expanded(child:TextField(controller:field,decoration:const InputDecoration(hintText:'Ask a safety question',border:OutlineInputBorder()))),const SizedBox(width:7),IconButton.filled(onPressed:(){final q=field.text.trim();if(q.isEmpty)return;setState((){messages.add(q);messages.add('Based on your current 78% slope-risk context: move toward the verified safe corridor, avoid steep drainage cuts, and keep live location sharing enabled.');field.clear();});},icon:const Icon(Icons.send_rounded))]))]));}

class RoleVisualConfig {
  final Color accent;
  final Color secondary;
  final Color background;
  final bool darkShell;
  final List<String> tabs;
  final List<IconData> icons;
  final String eyebrow;
  final String headline;
  final String subhead;
  final String metric1;
  final String metric2;
  final String metric3;
  final List<(String,String,IconData)> actions;

  const RoleVisualConfig({required this.accent,required this.secondary,required this.background,required this.darkShell,required this.tabs,required this.icons,required this.eyebrow,required this.headline,required this.subhead,required this.metric1,required this.metric2,required this.metric3,required this.actions});

  static RoleVisualConfig forRole(ExperienceRole role) => switch(role){
    ExperienceRole.rescue => const RoleVisualConfig(accent:_red,secondary:_orange,background:Color(0xFF071820),darkShell:true,tabs:['Command','Missions','Comms','Intel','Kit'],icons:[Icons.radar_rounded,Icons.assignment_turned_in_rounded,Icons.podcasts_rounded,Icons.satellite_alt_rounded,Icons.inventory_2_rounded],eyebrow:'FIELD COMMAND',headline:'Rescue operations\nin motion.',subhead:'Triage, dispatch and live responder coordination',metric1:'7 ACTIVE',metric2:'11 MIN ETA',metric3:'3 TEAMS',actions:[('Dispatch','Assign nearest team',Icons.emergency_share_rounded),('Triage','Prioritise incoming SOS',Icons.medical_services_rounded),('Route','Open responder corridor',Icons.route_rounded),('Drone','Request aerial scan',Icons.flight_takeoff_rounded)]),
    ExperienceRole.authority => const RoleVisualConfig(accent:_blue,secondary:_cyan,background:Color(0xFFF1F5FA),darkShell:false,tabs:['Overview','Command','Channels','Evidence','Admin'],icons:[Icons.dashboard_rounded,Icons.account_tree_rounded,Icons.campaign_rounded,Icons.fact_check_rounded,Icons.admin_panel_settings_rounded],eyebrow:'DISTRICT COMMAND CENTER',headline:'See the district.\nDecide with evidence.',subhead:'Verified intelligence, escalation and public warning',metric1:'3 CRITICAL',metric2:'92% VERIFIED',metric3:'28 SENSORS',actions:[('Broadcast','Send area warning',Icons.campaign_rounded),('Verify','Review citizen evidence',Icons.fact_check_rounded),('Zones','Update risk perimeter',Icons.polyline_rounded),('Resources','Reallocate capacity',Icons.hub_rounded)]),
    ExperienceRole.volunteer => const RoleVisualConfig(accent:_purple,secondary:_green,background:Color(0xFFF8F5FF),darkShell:false,tabs:['Today','Missions','Team','Updates','Profile'],icons:[Icons.wb_sunny_rounded,Icons.task_alt_rounded,Icons.groups_rounded,Icons.notifications_active_rounded,Icons.badge_rounded],eyebrow:'COMMUNITY RESPONSE',headline:'Your next helpful\naction is ready.',subhead:'Micro-missions matched to location and skill',metric1:'2 MISSIONS',metric2:'1.8 KM',metric3:'6 TEAMMATES',actions:[('Check-ins','Visit 3 households',Icons.how_to_reg_rounded),('Supplies','Deliver water packs',Icons.local_shipping_rounded),('Shelter','Support registration',Icons.home_work_rounded),('Report','Verify road access',Icons.add_location_alt_rounded)]),
    ExperienceRole.organization => const RoleVisualConfig(accent:_orange,secondary:_purple,background:Color(0xFFFFF8ED),darkShell:false,tabs:['Operations','Capacity','Comms','Requests','More'],icons:[Icons.business_center_rounded,Icons.inventory_rounded,Icons.video_call_rounded,Icons.move_to_inbox_rounded,Icons.grid_view_rounded],eyebrow:'RELIEF OPERATIONS',headline:'Capacity that moves\nwhere it matters.',subhead:'Shelters, inventory, logistics and partner coordination',metric1:'84 SPACES',metric2:'71% STOCK',metric3:'4 PARTNERS',actions:[('Shelters','Manage live occupancy',Icons.apartment_rounded),('Inventory','Update supplies',Icons.inventory_2_rounded),('Transport','Assign logistics',Icons.local_shipping_rounded),('Partners','Open coordination room',Icons.groups_2_rounded)]),
    ExperienceRole.citizen => throw StateError('Citizen uses foundation UI'),
  };
}

class OpsDashboard extends StatefulWidget {
  final ExperienceRole role;
  final RoleVisualConfig config;
  const OpsDashboard({super.key,required this.role,required this.config});
  @override State<OpsDashboard> createState()=>_OpsDashboardState();
}
class _OpsDashboardState extends State<OpsDashboard> with SingleTickerProviderStateMixin{
  late final AnimationController reveal;
  @override void initState(){super.initState();reveal=AnimationController(vsync:this,duration:const Duration(milliseconds:650))..forward();}
  @override void dispose(){reveal.dispose();super.dispose();}
  @override Widget build(BuildContext context){final c=widget.config;return SafeArea(child:Material(color:c.background,child:ListView(padding:EdgeInsets.zero,children:[
    Container(height:widget.role==ExperienceRole.rescue?300:275,decoration:BoxDecoration(gradient:LinearGradient(colors:widget.role==ExperienceRole.rescue?[const Color(0xFF071820),const Color(0xFF102F3A)]:[c.accent.withValues(alpha:.9),c.secondary.withValues(alpha:.78)])),child:Stack(children:[Positioned(right:-25,top:35,child:Icon(_roleHeroIcon(widget.role),size:210,color:Colors.white.withValues(alpha:.06))),Padding(padding:const EdgeInsets.all(20),child:AnimatedBuilder(animation:reveal,builder:(_,__){final v=Curves.easeOutCubic.transform(reveal.value);return Opacity(opacity:v,child:Transform.translate(offset:Offset(0,18*(1-v)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:Colors.white.withValues(alpha:.14),borderRadius:BorderRadius.circular(14)),child:Icon(widget.role.icon,color:Colors.white)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.role.title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:16)),Text(c.eyebrow,style:const TextStyle(color:Colors.white60,fontSize:8.5,fontWeight:FontWeight.w900,letterSpacing:1))])),const _LiveDot()]),const Spacer(),Text(c.headline,style:const TextStyle(color:Colors.white,fontSize:27,height:1.02,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(c.subhead,style:const TextStyle(color:Colors.white60,fontSize:10.5)),const SizedBox(height:14),Row(children:[Expanded(child:_OpsMetric(c.metric1,c.accent)),const SizedBox(width:7),Expanded(child:_OpsMetric(c.metric2,c.secondary)),const SizedBox(width:7),Expanded(child:_OpsMetric(c.metric3,_green))])])));}))]))]),
    Padding(padding:const EdgeInsets.fromLTRB(16,16,16,30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_section(_roleSection(widget.role),'Role-specific actions'),const SizedBox(height:10),GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:c.actions.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.55),itemBuilder:(_,i){final a=c.actions[i];return _RoleActionCard(accent:i.isEven?c.accent:c.secondary,icon:a.$3,title:a.$1,subtitle:a.$2,onTap:()=>_roleAction(context,widget.role,a.$1));}),const SizedBox(height:20),_roleDynamicPanel(context,widget.role,c),const SizedBox(height:20),_section('Live operations stream','Changes that need attention'),const SizedBox(height:10),_opsFeed(widget.role,c)]))
  ])));}
}
IconData _roleHeroIcon(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>Icons.helicopter_rounded,ExperienceRole.authority=>Icons.account_balance_rounded,ExperienceRole.volunteer=>Icons.volunteer_activism_rounded,ExperienceRole.organization=>Icons.warehouse_rounded,ExperienceRole.citizen=>Icons.person_rounded};
String _roleSection(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Field controls',ExperienceRole.authority=>'Command controls',ExperienceRole.volunteer=>'Today’s missions',ExperienceRole.organization=>'Operations controls',ExperienceRole.citizen=>'Safety tools'};

class _OpsMetric extends StatelessWidget{final String text;final Color color;const _OpsMetric(this.text,this.color);@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:9),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.11),borderRadius:BorderRadius.circular(13),border:Border.all(color:Colors.white12)),child:FittedBox(fit:BoxFit.scaleDown,child:Text(text,style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:12))));}
class _RoleActionCard extends StatelessWidget{final Color accent;final IconData icon;final String title;final String subtitle;final VoidCallback onTap;const _RoleActionCard({required this.accent,required this.icon,required this.title,required this.subtitle,required this.onTap});@override Widget build(BuildContext context)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(18),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),border:Border.all(color:accent.withValues(alpha:.16))),child:Row(children:[Container(width:43,height:43,decoration:BoxDecoration(color:accent.withValues(alpha:.1),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:accent)),const SizedBox(width:10),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text(subtitle,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.black45,fontSize:8.8))]))]))));}

void _roleAction(BuildContext context,ExperienceRole role,String action){
  if(action=='Partners'||action=='Dispatch'||action=='Broadcast') { Navigator.push(context,_route(CallScreen(title:role==ExperienceRole.organization?'Partner Coordination Room':role==ExperienceRole.rescue?'Rescue Command':'District Broadcast Desk',video:true))); return; }
  showModalBottomSheet(context:context,showDragHandle:true,builder:(_)=>Padding(padding:EdgeInsets.fromLTRB(20,0,20,MediaQuery.paddingOf(context).bottom+20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(role.icon,color:role.color,size:34),const SizedBox(height:10),Text('$action ready',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:19)),const SizedBox(height:5),Text('This control updates the ${role.title.toLowerCase()} operational workflow and records the action in the live activity feed.',style:const TextStyle(color:Colors.black54,height:1.4)),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('Confirm action')))])));
}

Widget _roleDynamicPanel(BuildContext context,ExperienceRole role,RoleVisualConfig c){
  switch(role){
    case ExperienceRole.rescue:return Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF0B2731),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[_LiveDot(label:'UNIT 04 EN ROUTE'),Spacer(),Text('ETA 11 min',style:TextStyle(color:_aqua,fontWeight:FontWeight.w900))]),const SizedBox(height:12),const Text('SOS #JS-2481 · Landslide / trapped',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:15)),const SizedBox(height:4),const Text('2 people · medical priority · location streaming',style:TextStyle(color:Colors.white60,fontSize:9.5)),const SizedBox(height:13),Row(children:[Expanded(child:OutlinedButton.icon(style:OutlinedButton.styleFrom(foregroundColor:Colors.white,side:const BorderSide(color:Colors.white24)),onPressed:()=>Navigator.push(context,_route(const CallScreen(title:'Citizen SOS #JS-2481',video:false))),icon:const Icon(Icons.call_rounded),label:const Text('Voice'))),const SizedBox(width:8),Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_red),onPressed:()=>Navigator.push(context,_route(const CallScreen(title:'Citizen SOS #JS-2481',video:true))),icon:const Icon(Icons.videocam_rounded),label:const Text('Video')))] )]));
    case ExperienceRole.authority:return _card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.fact_check_rounded,color:_blue),SizedBox(width:9),Text('Verification queue',style:TextStyle(fontWeight:FontWeight.w900,fontSize:15)),Spacer(),_LiveDot(label:'6 ITEMS')]),const SizedBox(height:12),const _EvidenceBar('Slope movement · Ward 8',.94,_red),const _EvidenceBar('Bridge blockage · Araniko Hwy',.81,_orange),const _EvidenceBar('Rain gauge anomaly · SG-04',.76,_blue)]));
    case ExperienceRole.volunteer:return _card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.route_rounded,color:_purple),SizedBox(width:9),Expanded(child:Text('Mission route · 3 stops',style:TextStyle(fontWeight:FontWeight.w900,fontSize:15))),_pillInline('42 min',_green)]),const SizedBox(height:10),const Text('1. Community check-in  ·  0.6 km',style:TextStyle(fontSize:10.5)),const Divider(),const Text('2. Water delivery  ·  1.1 km',style:TextStyle(fontSize:10.5)),const Divider(),const Text('3. Road access verification  ·  1.8 km',style:TextStyle(fontSize:10.5))]));
    case ExperienceRole.organization:return _card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.apartment_rounded,color:_orange),SizedBox(width:9),Text('Melamchi Relief Hub',style:TextStyle(fontWeight:FontWeight.w900,fontSize:15)),Spacer(),_LiveDot(label:'OPEN')]),const SizedBox(height:11),const LinearProgressIndicator(value:.64,minHeight:10,color:_orange,backgroundColor:Color(0xFFFFEFD5),borderRadius:BorderRadius.all(Radius.circular(10))),const SizedBox(height:7),const Row(children:[Text('53 / 84 spaces occupied',style:TextStyle(fontSize:10)),Spacer(),Text('31 available',style:TextStyle(color:_green,fontWeight:FontWeight.w900,fontSize:10))]),const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>Navigator.push(context,_route(const CallScreen(title:'Camp Operations',video:false))),icon:const Icon(Icons.call_rounded),label:const Text('Call camp'))),const SizedBox(width:8),Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_orange),onPressed:()=>Navigator.push(context,_route(const CallScreen(title:'Camp Operations',video:true))),icon:const Icon(Icons.videocam_rounded),label:const Text('Video')))])]));
    case ExperienceRole.citizen:return const SizedBox();
  }
}

class _EvidenceBar extends StatelessWidget{final String text;final double value;final Color color;const _EvidenceBar(this.text,this.value,this.color);@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Column(children:[Row(children:[Expanded(child:Text(text,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800))),Text('${(value*100).round()}%',style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:10))]),const SizedBox(height:5),LinearProgressIndicator(value:value,minHeight:6,color:color,backgroundColor:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(10))]));}
class _pillInline extends StatelessWidget{final String text;final Color color;const _pillInline(this.text,this.color);@override Widget build(BuildContext context)=>_pill(text,color);}

Widget _opsFeed(ExperienceRole r,RoleVisualConfig c){
  final rows=switch(r){
    ExperienceRole.rescue=>[('SOS #2481 acknowledged','Unit 04 · just now'),('Road access changed','Araniko corridor · 2 min'),('Medical team joined channel','District Hospital · 4 min')],
    ExperienceRole.authority=>[('Ward 8 report verified','Evidence confidence 94%'),('Public warning delivered','18,420 devices reached'),('Red-zone boundary updated','2.4 km² affected')],
    ExperienceRole.volunteer=>[('Mission #V-113 accepted','Check-in route · 3 stops'),('Supply pickup confirmed','Water packs × 12'),('Team member nearby','Riya · 350 m away')],
    ExperienceRole.organization=>[('Shelter capacity updated','31 spaces available'),('Medical supplies received','12 kits · logged'),('Partner request received','Water tanker · priority')],
    ExperienceRole.citizen=>[],
  };
  return _card(child:Column(children:rows.asMap().entries.map((e)=>Column(children:[if(e.key>0)const Divider(height:20),Row(children:[CircleAvatar(radius:5,backgroundColor:e.key==0?c.accent:_green),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.value.$1,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:10.5)),Text(e.value.$2,style:const TextStyle(color:Colors.black45,fontSize:8.8))]))])])).toList()));
}

class OperationsBoard extends StatefulWidget{final ExperienceRole role;final RoleVisualConfig config;const OperationsBoard({super.key,required this.role,required this.config});@override State<OperationsBoard> createState()=>_OperationsBoardState();}
class _OperationsBoardState extends State<OperationsBoard>{int selected=0;@override Widget build(BuildContext context){final r=widget.role;final c=widget.config;return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Text(c.tabs[1],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const Spacer(),_pill('LIVE',c.accent)]),const SizedBox(height:14),Container(height:205,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:LinearGradient(colors:[c.accent.withValues(alpha:.9),c.secondary.withValues(alpha:.75)])),child:CustomPaint(painter:_OpsGraphicPainter(c.accent,c.secondary),child:Center(child:Icon(_roleHeroIcon(r),color:Colors.white.withValues(alpha:.9),size:56)))),const SizedBox(height:14),...List.generate(3,(i)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Material(color:Colors.white,borderRadius:BorderRadius.circular(18),child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>setState(()=>selected=i),child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),border:Border.all(color:selected==i?c.accent:const Color(0xFFE5ECEE),width:selected==i?2:1)),child:Row(children:[CircleAvatar(backgroundColor:c.accent.withValues(alpha:.1),child:Text('${i+1}',style:TextStyle(color:c.accent,fontWeight:FontWeight.w900))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_boardTitle(r,i),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),Text(_boardSub(r,i),style:const TextStyle(color:Colors.black45,fontSize:9.5))])),if(selected==i)Icon(Icons.check_circle_rounded,color:c.accent)])))))])));}}
String _boardTitle(ExperienceRole r,int i)=>switch(r){ExperienceRole.rescue=>['SOS #2481 · trapped','Slope reconnaissance','Medical transfer'][i],ExperienceRole.authority=>['Critical zone review','Warning broadcast','Resource deployment'][i],ExperienceRole.volunteer=>['Household check-ins','Water delivery','Road verification'][i],ExperienceRole.organization=>['Shelter occupancy','Inventory transfer','Partner request'][i],ExperienceRole.citizen=>''};
String _boardSub(ExperienceRole r,int i)=>switch(r){ExperienceRole.rescue=>['Unit 04 assigned · ETA 11 min','Drone request queued','Hospital desk ready'][i],ExperienceRole.authority=>['3 evidence sources · 94% confidence','18,420 devices targeted','4 assets available'][i],ExperienceRole.volunteer=>['3 homes · 1.4 km loop','12 packs · 2 stops','Araniko access point'][i],ExperienceRole.organization=>['53 / 84 occupied','12 medical kits incoming','Water tanker requested'][i],ExperienceRole.citizen=>''};

class CommunicationHub extends StatelessWidget{final ExperienceRole role;final RoleVisualConfig config;const CommunicationHub({super.key,required this.role,required this.config});@override Widget build(BuildContext context){final rooms=switch(role){ExperienceRole.rescue=>['Field Command','Medical Desk','Citizen SOS #2481'],ExperienceRole.authority=>['District Command','Ward Officers','Public Information Cell'],ExperienceRole.volunteer=>['Volunteer Team Alpha','Camp Coordinator','Field Mentor'],ExperienceRole.organization=>['Camp Operations','Partner Coordination','Logistics Driver'],ExperienceRole.citizen=>['Response Desk']};return SafeArea(child:Material(color:config.background,child:ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Text(config.tabs[2],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const Spacer(),_pill('ENCRYPTED',_green)]),const SizedBox(height:10),Text('In-app voice, video and operational radio',style:TextStyle(color:Theme.of(context).colorScheme.onSurface.withValues(alpha:.55),fontSize:10.5)),const SizedBox(height:16),...rooms.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_card(child:Row(children:[CircleAvatar(radius:24,backgroundColor:config.accent.withValues(alpha:.1),child:Icon(e.key==0?Icons.podcasts_rounded:Icons.groups_rounded,color:config.accent)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.value,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),Text(e.key==0?'6 participants · live channel':'Available now',style:const TextStyle(color:Colors.black45,fontSize:9.2))])),IconButton(onPressed:()=>Navigator.push(context,_route(CallScreen(title:e.value,video:false))),icon:const Icon(Icons.call_rounded)),IconButton.filled(style:IconButton.styleFrom(backgroundColor:config.accent),onPressed:()=>Navigator.push(context,_route(CallScreen(title:e.value,video:true))),icon:const Icon(Icons.videocam_rounded))]))))] )));}}

class CallScreen extends StatefulWidget{final String title;final bool video;const CallScreen({super.key,required this.title,required this.video});@override State<CallScreen> createState()=>_CallScreenState();}
class _CallScreenState extends State<CallScreen>{bool muted=false;bool speaker=true;bool camera=true;int seconds=0;Timer?timer;@override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>seconds++);});}@override void dispose(){timer?.cancel();super.dispose();}String get time=>'${(seconds~/60).toString().padLeft(2,'0')}:${(seconds%60).toString().padLeft(2,'0')}';@override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF061820),body:SafeArea(child:Stack(children:[if(widget.video&&camera)Positioned.fill(child:Image.network(_rescueMountain,fit:BoxFit.cover,filterQuality:FilterQuality.medium,errorBuilder:(_,__,___)=>Container(color:const Color(0xFF0B2832)))),if(!widget.video||!camera)Positioned.fill(child:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF0A5265),Color(0xFF061820)],begin:Alignment.topCenter,end:Alignment.bottomCenter)))),Positioned.fill(child:Container(color:Colors.black.withValues(alpha:widget.video?.28:.08))),Padding(padding:const EdgeInsets.all(20),child:Column(children:[Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.keyboard_arrow_down_rounded,color:Colors.white)),const Spacer(),const _LiveDot(label:'SECURE CHANNEL')]),const Spacer(),CircleAvatar(radius:42,backgroundColor:_aqua.withValues(alpha:.18),child:const Icon(Icons.groups_rounded,color:_aqua,size:42)),const SizedBox(height:14),Text(widget.title,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(time,style:const TextStyle(color:Colors.white60,fontSize:13)),const Spacer(),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.32),borderRadius:BorderRadius.circular(28),border:Border.all(color:Colors.white12)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_callButton(muted?Icons.mic_off_rounded:Icons.mic_rounded,muted,()=>setState(()=>muted=!muted)),_callButton(speaker?Icons.volume_up_rounded:Icons.volume_off_rounded,speaker,()=>setState(()=>speaker=!speaker)),if(widget.video)_callButton(camera?Icons.videocam_rounded:Icons.videocam_off_rounded,camera,()=>setState(()=>camera=!camera)),_callButton(Icons.call_end_rounded,true,()=>Navigator.pop(context),danger:true)])),const SizedBox(height:18)]))])));}
Widget _callButton(IconData icon,bool active,VoidCallback tap,{bool danger=false})=>Material(color:danger?_red:Colors.white.withValues(alpha:active?.18:.08),shape:const CircleBorder(),child:InkWell(customBorder:const CircleBorder(),onTap:tap,child:SizedBox(width:54,height:54,child:Icon(icon,color:Colors.white))));

class IntelligenceFeed extends StatelessWidget{final ExperienceRole role;final RoleVisualConfig config;const IntelligenceFeed({super.key,required this.role,required this.config});@override Widget build(BuildContext context)=>SafeArea(child:Material(color:config.background,child:ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Text(config.tabs[3],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const Spacer(),_pill('AI + HUMAN',config.accent)]),const SizedBox(height:14),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:LinearGradient(colors:[config.accent.withValues(alpha:.9),config.secondary.withValues(alpha:.75)]),borderRadius:BorderRadius.circular(22)),child:const Row(children:[Icon(Icons.auto_awesome_rounded,color:Colors.white,size:34),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Operational intelligence',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:16)),Text('Prioritised by urgency, confidence and role relevance',style:TextStyle(color:Colors.white70,fontSize:9.5))]))])),const SizedBox(height:13),_intelCard('Risk model updated','Slope probability increased 6% after the latest soil sync.',_red),const SizedBox(height:9),_intelCard('Community evidence verified','Two reports match sensor and weather patterns.',_green),const SizedBox(height:9),_intelCard('Route intelligence changed','One corridor is slower but remains outside red zones.',_orange)])));
Widget _intelCard(String title,String body,Color color)=>_card(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:color.withValues(alpha:.1),child:Icon(Icons.bolt_rounded,color:color)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12.5)),const SizedBox(height:3),Text(body,style:const TextStyle(color:Colors.black54,fontSize:10,height:1.35))]))]));

class RoleToolkit extends StatelessWidget{final ExperienceRole role;final RoleVisualConfig config;const RoleToolkit({super.key,required this.role,required this.config});@override Widget build(BuildContext context){final tools=switch(role){ExperienceRole.rescue=>[(Icons.medical_services_rounded,'Triage protocol'),(Icons.offline_bolt_rounded,'Offline responder pack'),(Icons.qr_code_scanner_rounded,'Patient / asset scan'),(Icons.sensors_rounded,'Field sensor link')],ExperienceRole.authority=>[(Icons.campaign_rounded,'Broadcast templates'),(Icons.fact_check_rounded,'Evidence policy'),(Icons.history_rounded,'Decision log'),(Icons.security_rounded,'Access controls')],ExperienceRole.volunteer=>[(Icons.badge_rounded,'Digital volunteer ID'),(Icons.school_rounded,'Micro training'),(Icons.offline_bolt_rounded,'Offline mission pack'),(Icons.workspace_premium_rounded,'Impact record')],ExperienceRole.organization=>[(Icons.inventory_rounded,'Inventory ledger'),(Icons.apartment_rounded,'Shelter profile'),(Icons.qr_code_rounded,'Resource handover QR'),(Icons.handshake_rounded,'Partner directory')],ExperienceRole.citizen=>[]};return SafeArea(child:Material(color:config.background,child:ListView(padding:const EdgeInsets.all(16),children:[Text(config.tabs[4],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:14),...tools.map((t)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Material(color:Colors.white,borderRadius:BorderRadius.circular(19),child:InkWell(borderRadius:BorderRadius.circular(19),onTap:()=>_showInfo(context,t.$2,'This module is available locally and records changes in the role activity log.'),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(borderRadius:BorderRadius.circular(19),border:Border.all(color:const Color(0xFFE4EBED))),child:Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:config.accent.withValues(alpha:.1),borderRadius:BorderRadius.circular(14)),child:Icon(t.$1,color:config.accent)),const SizedBox(width:12),Expanded(child:Text(t.$2,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13))),const Icon(Icons.chevron_right_rounded,color:Colors.black38)]))))),const SizedBox(height:6),OutlinedButton.icon(onPressed:()=>Navigator.pushAndRemoveUntil(context,_route(const PremiumRolePicker()),(_)=>false),icon:const Icon(Icons.swap_horiz_rounded),label:const Text('Switch profession / role'))])));}}

class _OpsGraphicPainter extends CustomPainter{final Color a;final Color b;_OpsGraphicPainter(this.a,this.b);@override void paint(Canvas c,Size s){final grid=Paint()..color=Colors.white.withValues(alpha:.12)..strokeWidth=1;for(double x=20;x<s.width;x+=32)c.drawLine(Offset(x,0),Offset(x,s.height),grid);for(double y=18;y<s.height;y+=28)c.drawLine(Offset(0,y),Offset(s.width,y),grid);final p=Paint()..color=Colors.white.withValues(alpha:.42)..style=PaintingStyle.stroke..strokeWidth=3;final path=Path()..moveTo(15,s.height*.68)..cubicTo(s.width*.25,s.height*.72,s.width*.31,s.height*.31,s.width*.49,s.height*.48)..cubicTo(s.width*.7,s.height*.7,s.width*.75,s.height*.2,s.width*.95,s.height*.32);c.drawPath(path,p);}@override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;}

class _LiveDot extends StatelessWidget{final String label;const _LiveDot({this.label='LIVE'});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(color:_green.withValues(alpha:.16),borderRadius:BorderRadius.circular(99)),child:Row(mainAxisSize:MainAxisSize.min,children:[const CircleAvatar(radius:3.5,backgroundColor:_green),const SizedBox(width:5),Text(label,style:const TextStyle(color:_green,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.5))]));}

class _GradientFeature extends StatelessWidget{final IconData icon;final String title;final String subtitle;final List<Color> colors;const _GradientFeature({required this.icon,required this.title,required this.subtitle,required this.colors});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:LinearGradient(colors:colors),borderRadius:BorderRadius.circular(20)),child:Row(children:[Container(width:50,height:50,decoration:BoxDecoration(color:Colors.white.withValues(alpha:.12),borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:Colors.white)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:15)),Text(subtitle,style:const TextStyle(color:Colors.white60,fontSize:9.5))])),const Icon(Icons.arrow_forward_rounded,color:_aqua)]));}

class _ResourceMini extends StatelessWidget{const _ResourceMini();@override Widget build(BuildContext context)=>const SizedBox();}

Widget _metric(IconData icon,Color color,String value,String label)=>_card(child:Row(children:[Icon(icon,color:color,size:28),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),Text(label,style:const TextStyle(fontSize:9.5,color:Colors.black45))]))]),padding:const EdgeInsets.all(12));
Widget _miniAction(IconData icon,String text,Color color,VoidCallback tap)=>Material(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(16),child:InkWell(onTap:tap,borderRadius:BorderRadius.circular(16),child:Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:12),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:color,size:19),const SizedBox(width:7),Flexible(child:Text(text,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:10)))]))));
Widget _section(String title,String subtitle)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(subtitle,style:const TextStyle(fontSize:10,color:Colors.black45))]);
Widget _pill(String text,Color color,{bool dark=false})=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:dark?Colors.white.withValues(alpha:.08):color.withValues(alpha:.1),borderRadius:BorderRadius.circular(99),border:Border.all(color:dark?Colors.white24:color.withValues(alpha:.25))),child:Text(text,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:dark?Colors.white:color,fontSize:8.5,fontWeight:FontWeight.w900,letterSpacing:.5)));
Widget _card({required Widget child,EdgeInsets padding=const EdgeInsets.all(14)})=>Container(padding:padding,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFFE6EEF0)),boxShadow:[BoxShadow(color:_navy.withValues(alpha:.045),blurRadius:18,offset:const Offset(0,7))]),child:child);
Widget _tapCard(BuildContext context,{required Widget child,required VoidCallback onTap})=>Material(color:Colors.transparent,borderRadius:BorderRadius.circular(20),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(20),child:child));
void _showInfo(BuildContext context,String title,String body)=>showModalBottomSheet(context:context,showDragHandle:true,builder:(_)=>Padding(padding:EdgeInsets.fromLTRB(20,0,20,MediaQuery.paddingOf(context).bottom+22),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:7),Text(body,style:const TextStyle(color:Colors.black54,height:1.45)),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('Done')))])));

Widget _detailScaffold(BuildContext context,String title,Widget child)=>Scaffold(backgroundColor:_bg,appBar:AppBar(backgroundColor:_bg,surfaceTintColor:_bg,title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:[child])));
