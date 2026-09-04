import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const navy = Color(0xFF063847);
const deep = Color(0xFF03232D);
const cyan = Color(0xFF22C7D9);
const green = Color(0xFF20C98A);
const red = Color(0xFFFF3B55);
const orange = Color(0xFFFFA42E);
const blue = Color(0xFF4387F4);
const purple = Color(0xFF7758DF);

void runBeastApp() => runApp(const JeevanSetuBeastApp());

class JeevanSetuBeastApp extends StatefulWidget {
  const JeevanSetuBeastApp({super.key});

  @override
  State<JeevanSetuBeastApp> createState() => _JeevanSetuBeastAppState();
}

class _JeevanSetuBeastAppState extends State<JeevanSetuBeastApp> {
  final model = AppModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return AppScope(
          model: model,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'JeevanSetu',
            themeMode: model.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            home: const LaunchScreen(),
          ),
        );
      },
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final darkMode = brightness == Brightness.dark;
  final bg = darkMode ? const Color(0xFF061B23) : const Color(0xFFF2F7FA);
  final surface = darkMode ? const Color(0xFF102B35) : Colors.white;
  final ink = darkMode ? Colors.white : const Color(0xFF102027);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: brightness,
      surface: surface,
      primary: cyan,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: darkMode ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: ink),
      headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: ink),
      titleLarge: TextStyle(fontWeight: FontWeight.w900, color: ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
      bodyLarge: TextStyle(color: ink.withValues(alpha: .86)),
      bodyMedium: TextStyle(color: ink.withValues(alpha: .70)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: cyan.withValues(alpha: .18),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
            color: s.contains(WidgetState.selected) ? cyan : ink.withValues(alpha: .65),
          )),
    ),
  );
}

enum UserRole { citizen, rescue, authority, volunteer, organization }
enum IncidentStage { submitted, verification, dispatched, onSite, rescued, relief, completed }

enum AppLanguage { english, hindi, nepali }

extension RoleInfo on UserRole {
  String get title => switch (this) {
        UserRole.citizen => 'Citizen',
        UserRole.rescue => 'Rescue Team',
        UserRole.authority => 'Authority',
        UserRole.volunteer => 'Volunteer',
        UserRole.organization => 'Organization',
      };
  Color get color => switch (this) {
        UserRole.citizen => green,
        UserRole.rescue => red,
        UserRole.authority => blue,
        UserRole.volunteer => purple,
        UserRole.organization => orange,
      };
  IconData get icon => switch (this) {
        UserRole.citizen => Icons.person_rounded,
        UserRole.rescue => Icons.health_and_safety_rounded,
        UserRole.authority => Icons.account_balance_rounded,
        UserRole.volunteer => Icons.volunteer_activism_rounded,
        UserRole.organization => Icons.business_rounded,
      };
}

class Incident {
  Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.created,
    required this.people,
    this.medical = false,
    this.stage = IncidentStage.submitted,
    this.rescueTeam = 'Unassigned',
    this.shelter = 'Not reserved',
    this.volunteer = 'Unassigned',
    this.verified = false,
  });

  final String id;
  final String type;
  final String description;
  final String location;
  final DateTime created;
  final int people;
  bool medical;
  IncidentStage stage;
  String rescueTeam;
  String shelter;
  String volunteer;
  bool verified;
}

class TimelineEntry {
  TimelineEntry(this.incidentId, this.role, this.text, this.time, this.color);
  final String incidentId;
  final String role;
  final String text;
  final DateTime time;
  final Color color;
}

class ChatMessage {
  ChatMessage(this.incidentId, this.sender, this.text, this.time);
  final String incidentId;
  final String sender;
  final String text;
  final DateTime time;
}

class AppModel extends ChangeNotifier {
  bool darkMode = false;
  AppLanguage language = AppLanguage.english;
  UserRole? role;
  int serial = 1023;

  final List<Incident> incidents = [
    Incident(
      id: 'JS1023',
      type: 'Landslide / trapped',
      description: 'Two people trapped near an unstable slope after heavy rainfall.',
      location: 'Sindhupalchok · Ward 8',
      created: DateTime.now().subtract(const Duration(minutes: 8)),
      people: 2,
      medical: true,
      stage: IncidentStage.verification,
    ),
  ];

  final List<TimelineEntry> timeline = [];
  final List<ChatMessage> messages = [];

  AppModel() {
    timeline.addAll([
      TimelineEntry('JS1023', 'Citizen', 'Incident reported with live location', DateTime.now().subtract(const Duration(minutes: 8)), green),
      TimelineEntry('JS1023', 'AI Sentinel', 'Risk overlap detected · 94% confidence', DateTime.now().subtract(const Duration(minutes: 7)), purple),
    ]);
    messages.add(ChatMessage('JS1023', 'Citizen', 'We are near the road. Rocks are still falling.', DateTime.now().subtract(const Duration(minutes: 7))));
  }

  void setRole(UserRole value) { role = value; notifyListeners(); }
  void setDark(bool value) { darkMode = value; notifyListeners(); }
  void setLanguage(AppLanguage value) { language = value; notifyListeners(); }

  Incident report({required String type, required String description, required int people, required bool medical}) {
    serial++;
    final incident = Incident(
      id: 'JS$serial',
      type: type,
      description: description.isEmpty ? 'Citizen requested emergency support.' : description,
      location: 'Sindhupalchok · Live GPS',
      created: DateTime.now(),
      people: people,
      medical: medical,
    );
    incidents.insert(0, incident);
    _event(incident.id, 'Citizen', 'Report submitted with GPS and emergency details', green);
    _event(incident.id, 'System', 'Incident routed to Authority, Rescue, Volunteer and Organization', cyan);
    messages.add(ChatMessage(incident.id, 'System', 'Shared incident room opened for all response roles.', DateTime.now()));
    notifyListeners();
    return incident;
  }

  void verify(Incident i) {
    i.verified = true;
    i.stage = IncidentStage.verification;
    _event(i.id, 'Authority', 'Incident verified and response corridor approved', blue);
    messages.add(ChatMessage(i.id, 'Authority', 'Verified. Rescue dispatch authorized.', DateTime.now()));
    notifyListeners();
  }

  void dispatch(Incident i) {
    i.rescueTeam = 'Rescue Alpha 04';
    i.stage = IncidentStage.dispatched;
    _event(i.id, 'Rescue Team', 'Rescue Alpha 04 dispatched · ETA 8 min', red);
    messages.add(ChatMessage(i.id, 'Rescue Team', 'We are en route. ETA 8 minutes.', DateTime.now()));
    notifyListeners();
  }

  void onSite(Incident i) {
    i.stage = IncidentStage.onSite;
    _event(i.id, 'Rescue Team', 'Team reached incident location', red);
    notifyListeners();
  }

  void rescued(Incident i) {
    i.stage = IncidentStage.rescued;
    _event(i.id, 'Rescue Team', '${i.people} people marked safe and rescued', green);
    messages.add(ChatMessage(i.id, 'Rescue Team', 'People rescued. Requesting relief handoff.', DateTime.now()));
    notifyListeners();
  }

  void volunteerAccept(Incident i) {
    i.volunteer = 'Volunteer Unit V-12';
    _event(i.id, 'Volunteer', 'Ground support accepted by Unit V-12', purple);
    notifyListeners();
  }

  void allocateRelief(Incident i) {
    i.shelter = 'Melamchi Relief Hub · Beds reserved';
    if (i.stage.index < IncidentStage.relief.index) i.stage = IncidentStage.relief;
    _event(i.id, 'Organization', 'Shelter, food and medical support allocated', orange);
    messages.add(ChatMessage(i.id, 'Organization', '84-bed hub ready. Medical desk active.', DateTime.now()));
    notifyListeners();
  }

  void complete(Incident i) {
    i.stage = IncidentStage.completed;
    _event(i.id, 'Authority', 'Incident closed after rescue and relief confirmation', blue);
    notifyListeners();
  }

  void addMessage(Incident i, String sender, String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(i.id, sender, text.trim(), DateTime.now()));
    notifyListeners();
  }

  void _event(String id, String role, String text, Color color) {
    timeline.add(TimelineEntry(id, role, text, DateTime.now(), color));
  }
}

class AppScope extends InheritedNotifier<AppModel> {
  const AppScope({super.key, required AppModel model, required super.child}) : super(notifier: model);
  static AppModel of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});
  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RoleSelectScreen()));
    });
  }
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/hero_mountain.jpg', fit: BoxFit.cover),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x66335966), Color(0xE6032B36)]))),
        Center(child: FadeTransition(opacity: CurvedAnimation(parent: c, curve: Curves.easeIn), child: ScaleTransition(scale: Tween(begin: .72, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.elasticOut)), child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/app_icon.png', width: 118, height: 118)),
          const SizedBox(height: 22),
          const Text('JeevanSetu', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('From alert to action — together', style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 17)),
        ])))),
      ]),
    );
  }
}

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: Image.asset('assets/images/monitoring_mountain.jpg', fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: deep.withValues(alpha: .88))),
        SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 22, 30), children: [
          Row(children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset('assets/app_icon.png', width: 64, height: 64)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('JeevanSetu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)), Text('One incident. One connected response.', style: TextStyle(color: Colors.white70))]))]),
          const SizedBox(height: 34),
          const Text('Choose your role', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Each role gets a purpose-built operational experience, while every incident remains synchronized.', style: TextStyle(color: Colors.white70, height: 1.45)),
          const SizedBox(height: 24),
          for (final role in UserRole.values) Padding(padding: const EdgeInsets.only(bottom: 14), child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () { model.setRole(role); Navigator.push(context, MaterialPageRoute(builder: (_) => RoleShell(role: role))); }, child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [role.color, role.color.withValues(alpha: .72)]), boxShadow: [BoxShadow(color: role.color.withValues(alpha: .22), blurRadius: 20, offset: const Offset(0, 8))]), child: Row(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(18)), child: Icon(role.icon, color: role.color, size: 30)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role.title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), Text(_roleSubtitle(role), style: const TextStyle(color: Colors.white70))])), const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)]))))),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _selector(context, Icons.translate, model.language == AppLanguage.english ? 'English' : model.language == AppLanguage.hindi ? 'हिन्दी' : 'नेपाली', () => _languageSheet(context))), const SizedBox(width: 12), Expanded(child: _selector(context, model.darkMode ? Icons.dark_mode : Icons.light_mode, model.darkMode ? 'Dark' : 'Light', () => model.setDark(!model.darkMode)))]),
        ])),
      ]),
    );
  }

  String _roleSubtitle(UserRole role) => switch (role) {
    UserRole.citizen => 'Report, receive alerts, track help and reach safety',
    UserRole.rescue => 'Triage, dispatch, navigate, rescue and hand off',
    UserRole.authority => 'Verify evidence, command response and broadcast warnings',
    UserRole.volunteer => 'Accept field tasks, support evacuation and supply missions',
    UserRole.organization => 'Manage shelters, inventory, medical aid and logistics',
  };

  Widget _selector(BuildContext context, IconData icon, String text, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24), color: Colors.white.withValues(alpha: .08)), child: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 10), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])));

  void _languageSheet(BuildContext context) {
    final m = AppScope.of(context);
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: const Text('English'), onTap: () { m.setLanguage(AppLanguage.english); Navigator.pop(context); }),
      ListTile(title: const Text('हिन्दी'), onTap: () { m.setLanguage(AppLanguage.hindi); Navigator.pop(context); }),
      ListTile(title: const Text('नेपाली'), onTap: () { m.setLanguage(AppLanguage.nepali); Navigator.pop(context); }),
    ])));
  }
}

class RoleShell extends StatefulWidget {
  const RoleShell({super.key, required this.role});
  final UserRole role;
  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final spec = roleSpec(widget.role);
    final pages = rolePages(widget.role);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (index != 0) setState(() => index = 0); else Navigator.of(context).pop();
      },
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: [for (final n in spec) NavigationDestination(icon: Icon(n.$1), label: n.$2)]),
      ),
    );
  }
}

List<(IconData, String)> roleSpec(UserRole role) => switch (role) {
  UserRole.citizen => [(Icons.home_rounded, 'Home'), (Icons.add_alert_rounded, 'Report'), (Icons.timeline_rounded, 'Incidents'), (Icons.route_rounded, 'Safety'), (Icons.grid_view_rounded, 'More')],
  UserRole.rescue => [(Icons.radar_rounded, 'Command'), (Icons.assignment_rounded, 'Missions'), (Icons.forum_rounded, 'Comms'), (Icons.map_rounded, 'Map'), (Icons.medical_services_rounded, 'Kit')],
  UserRole.authority => [(Icons.dashboard_rounded, 'Overview'), (Icons.fact_check_rounded, 'Verify'), (Icons.campaign_rounded, 'Broadcast'), (Icons.map_rounded, 'Map'), (Icons.admin_panel_settings_rounded, 'Admin')],
  UserRole.volunteer => [(Icons.explore_rounded, 'Field'), (Icons.volunteer_activism_rounded, 'Tasks'), (Icons.forum_rounded, 'Comms'), (Icons.map_rounded, 'Map'), (Icons.backpack_rounded, 'More')],
  UserRole.organization => [(Icons.hub_rounded, 'Hub'), (Icons.inbox_rounded, 'Requests'), (Icons.inventory_2_rounded, 'Inventory'), (Icons.forum_rounded, 'Comms'), (Icons.settings_rounded, 'More')],
};

List<Widget> rolePages(UserRole role) => switch (role) {
  UserRole.citizen => const [CitizenHome(), ReportScreen(), CitizenIncidents(), SafetyScreen(), RoleMore()],
  UserRole.rescue => const [RescueCommand(), RescueMissions(), CommsScreen(role: UserRole.rescue), SharedMapScreen(title: 'Rescue Operations Map', accent: red), RescueKit()],
  UserRole.authority => const [AuthorityOverview(), AuthorityVerify(), BroadcastScreen(), SharedMapScreen(title: 'District Command Map', accent: blue), AuthorityAdmin()],
  UserRole.volunteer => const [VolunteerField(), VolunteerTasks(), CommsScreen(role: UserRole.volunteer), SharedMapScreen(title: 'Field Support Map', accent: purple), VolunteerMore()],
  UserRole.organization => const [OrganizationHub(), OrganizationRequests(), InventoryScreen(), CommsScreen(role: UserRole.organization), OrganizationMore()],
};

class CitizenHome extends StatelessWidget {
  const CitizenHome({super.key});
  @override
  Widget build(BuildContext context) {
    final m = AppScope.of(context);
    final incident = m.incidents.first;
    return AppPage(children: [
      const HeroBanner(image: 'assets/images/hero_mountain.jpg', eyebrow: 'NEPAL RISK INTELLIGENCE', title: 'Know the slope\nbefore it moves.', subtitle: 'AI-assisted warnings, verified incidents and coordinated response in one place.', accent: cyan),
      const SizedBox(height: 18),
      AlertCard(incident: incident),
      const SectionTitle('Live safety intelligence', 'Current conditions around you'),
      Row(children: const [Expanded(child: MetricCard(icon: Icons.water_drop_rounded, value: '126 mm', label: '24h rainfall', color: blue)), SizedBox(width: 12), Expanded(child: MetricCard(icon: Icons.opacity_rounded, value: '87%', label: 'Soil saturation', color: cyan)), SizedBox(width: 12), Expanded(child: MetricCard(icon: Icons.shield_rounded, value: '18', label: 'Safe hubs', color: green))]),
      const SectionTitle('Quick response', 'Every action opens a working flow'),
      ActionGrid(items: [
        ActionItem(Icons.add_alert_rounded, 'Report incident', red, () => _open(context, const ReportScreen())),
        ActionItem(Icons.route_rounded, 'Safe route', green, () => _open(context, const SafetyScreen())),
        ActionItem(Icons.timeline_rounded, 'Track incident', blue, () => _open(context, IncidentDetail(incident: incident))),
        ActionItem(Icons.chat_bubble_rounded, 'Response room', purple, () => _open(context, IncidentRoom(incident: incident, role: UserRole.citizen))),
      ]),
      const SectionTitle('Community pulse', 'Verified signals around your location'),
      const StoryCard(image: 'assets/images/monitoring_mountain.jpg', title: 'Slope movement reported', subtitle: 'Sindhupalchok · AI + community verified', badge: '94%'),
    ]);
  }
}

class ReportScreen extends StatefulWidget { const ReportScreen({super.key}); @override State<ReportScreen> createState() => _ReportScreenState(); }
class _ReportScreenState extends State<ReportScreen> {
  String type = 'Landslide'; int people = 1; bool medical = false; final desc = TextEditingController();
  @override void dispose() { desc.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AppPage(children: [
      const PageHeader('Report Incident', 'One report instantly becomes visible to every relevant response role.'),
      const SizedBox(height: 8),
      SizedBox(height: 230, child: ClipRRect(borderRadius: BorderRadius.circular(26), child: const NepalMap(compact: true))),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Incident type', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final v in ['Landslide','Flood','Trapped','Medical','Road Block']) ChoiceChip(label: Text(v), selected: type == v, onSelected: (_) => setState(() => type = v))]),
        const SizedBox(height: 18),
        TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Describe what is happening', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        Row(children: [const Text('People needing help', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), IconButton(onPressed: people > 1 ? () => setState(() => people--) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$people', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), IconButton(onPressed: () => setState(() => people++), icon: const Icon(Icons.add_circle_outline))]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Medical assistance needed', style: TextStyle(fontWeight: FontWeight.w800)), value: medical, onChanged: (v) => setState(() => medical = v)),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.photo_camera_rounded, color: cyan), title: const Text('Photo / video evidence', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Evidence slot ready for device capture in production build'), trailing: const Icon(Icons.chevron_right)),
      ]))),
      const SizedBox(height: 14),
      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: red, padding: const EdgeInsets.all(18)), onPressed: () {
        final i = AppScope.of(context).report(type: type, description: desc.text, people: people, medical: medical);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incident ${i.id} shared across all roles')));
        _open(context, IncidentDetail(incident: i));
      }, icon: const Icon(Icons.sos_rounded), label: const Text('Send Emergency Report', style: TextStyle(fontWeight: FontWeight.w900))),
    ]);
  }
}

class CitizenIncidents extends StatelessWidget { const CitizenIncidents({super.key}); @override Widget build(BuildContext context) { final m=AppScope.of(context); return AppPage(children:[const PageHeader('My Incidents','Transparent progress from report to recovery.'), for(final i in m.incidents) IncidentTile(incident:i,onTap:()=>_open(context,IncidentDetail(incident:i)))]); } }

class SafetyScreen extends StatelessWidget { const SafetyScreen({super.key}); @override Widget build(BuildContext context) => AppPage(children:[const PageHeader('Safe Route','Live map routing prioritises safety over shortest distance.'), const SizedBox(height:12), SizedBox(height:420,child:ClipRRect(borderRadius:BorderRadius.circular(28),child:const NepalMap(showRoute:true))), const SizedBox(height:14), const Card(child:Padding(padding:EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Safest route selected',style:TextStyle(fontWeight:FontWeight.w900,fontSize:20,color:green)),SizedBox(height:6),Text('6.3 km · 18 min · avoids 2 active hazard zones and a blocked bridge'),SizedBox(height:14),LinearProgressIndicator(value:.72)]))), const SizedBox(height:12), FilledButton.icon(onPressed:null,icon:Icon(Icons.navigation_rounded),label:Text('Navigation preview ready'))]); }

class RoleMore extends StatelessWidget { const RoleMore({super.key}); @override Widget build(BuildContext context) { final m=AppScope.of(context); return AppPage(children:[const PageHeader('More','Personal safety, accessibility and app controls.'), SettingsTile(Icons.family_restroom_rounded,'Personal Safety','Family check-in and live status',cyan,()=>_open(context,const PersonalSafetyScreen())), SettingsTile(Icons.sensors_rounded,'Sensor Network','Rain, soil and slope telemetry',blue,()=>_open(context,const SensorScreen())), SettingsTile(Icons.download_for_offline_rounded,'Offline Readiness','Cached emergency pack',green,()=>_open(context,const OfflineScreen())), SettingsTile(Icons.shield_rounded,'Safety Guidelines','Landslide survival checklist',orange,()=>_open(context,const GuidelinesScreen())), Card(child:SwitchListTile(title:const Text('Dark mode',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:const Text('Applied across every role and tab'),value:m.darkMode,onChanged:m.setDark)), SettingsTile(Icons.swap_horiz_rounded,'Switch role','Return to role selection',purple,()=>Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>const RoleSelectScreen()),(r)=>false))]); } }

class RescueCommand extends StatelessWidget { const RescueCommand({super.key}); @override Widget build(BuildContext context){ final m=AppScope.of(context); final i=m.incidents.first; return AppPage(children:[const HeroBanner(image:'assets/images/rescue_diver.jpg',eyebrow:'RESCUE FIELD COMMAND',title:'Rescue operations\nin motion.',subtitle:'Triage, dispatch and live responder coordination.',accent:red),const SectionTitle('Priority incident','Shared directly from the citizen network'),IncidentFocus(incident:i,color:red,primary:'Dispatch team',onPrimary:()=>m.dispatch(i),secondary:'Open room',onSecondary:()=>_open(context,IncidentRoom(incident:i,role:UserRole.rescue))),const SectionTitle('Operational picture','Live position and hazard awareness'),SizedBox(height:320,child:ClipRRect(borderRadius:BorderRadius.circular(26),child:const NepalMap(showRoute:true))),const SectionTitle('Live operations stream','Changes that require attention'),...m.timeline.reversed.take(4).map((e)=>TimelineTile(entry:e))]); } }

class RescueMissions extends StatelessWidget { const RescueMissions({super.key}); @override Widget build(BuildContext context){ final m=AppScope.of(context); return AppPage(children:[const PageHeader('Missions','Move incidents from dispatch to rescue completion.'),for(final i in m.incidents) Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${i.id} · ${i.type}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)),Text(i.location),const SizedBox(height:12),StageBar(stage:i.stage),const SizedBox(height:14),Wrap(spacing:8,children:[FilledButton(onPressed:()=>m.dispatch(i),child:const Text('Dispatch')),OutlinedButton(onPressed:()=>m.onSite(i),child:const Text('On site')),OutlinedButton(onPressed:()=>m.rescued(i),child:const Text('Rescued'))])])))]); } }

class RescueKit extends StatelessWidget { const RescueKit({super.key}); @override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Responder Kit','Field tools designed for low-connectivity operations.'),SettingsTile(Icons.medical_services_rounded,'Triage Protocol','START triage quick reference',red,()=>_showInfo(context,'Triage protocol','Airway → breathing → circulation → priority marking.')),SettingsTile(Icons.qr_code_scanner_rounded,'Patient / Asset Scan','Prototype QR handoff workflow',orange,()=>_showInfo(context,'Scanner','Patient handoff scan initialized.')),SettingsTile(Icons.sensors_rounded,'Field Sensor Link','Pair portable rain and slope nodes',cyan,()=>_showInfo(context,'Sensor link','Nearby field node detected.')),SettingsTile(Icons.offline_bolt_rounded,'Offline Responder Pack','Maps, contacts and triage cached',green,()=>_showInfo(context,'Offline pack','Responder pack is available offline.'))]); }

class AuthorityOverview extends StatelessWidget { const AuthorityOverview({super.key}); @override Widget build(BuildContext context){ final m=AppScope.of(context); return AppPage(children:[const GradientHeader(icon:Icons.account_balance_rounded,eyebrow:'DISTRICT COMMAND CENTER',title:'See the district.\nDecide with evidence.',subtitle:'Verified intelligence, escalation and public warning.',colors:[blue,cyan]),const SectionTitle('Command controls','Evidence-driven district response'),Row(children:[Expanded(child:MetricCard(icon:Icons.warning_rounded,value:'${m.incidents.length}',label:'Active incidents',color:red)),const SizedBox(width:12),const Expanded(child:MetricCard(icon:Icons.verified_rounded,value:'94%',label:'Verified confidence',color:green)),const SizedBox(width:12),const Expanded(child:MetricCard(icon:Icons.sensors_rounded,value:'28',label:'Sensors',color:blue))]),const SectionTitle('Verification queue','Citizen evidence awaiting decisions'),for(final i in m.incidents) IncidentFocus(incident:i,color:blue,primary:i.verified?'Verified':'Verify incident',onPrimary:()=>m.verify(i),secondary:'Open room',onSecondary:()=>_open(context,IncidentRoom(incident:i,role:UserRole.authority)))]); } }

class AuthorityVerify extends StatelessWidget { const AuthorityVerify({super.key}); @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[const PageHeader('Evidence Verification','Fuse citizen reports, weather and sensor evidence.'),for(final i in m.incidents) Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${i.id} · ${i.type}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)),const SizedBox(height:8),const Text('Evidence sources: Citizen GPS · rainfall radar · soil sensor · community match'),const SizedBox(height:12),const LinearProgressIndicator(value:.94),const SizedBox(height:6),const Text('AI + human verification confidence 94%',style:TextStyle(color:green,fontWeight:FontWeight.w800)),const SizedBox(height:12),FilledButton.icon(onPressed:()=>m.verify(i),icon:const Icon(Icons.verified_rounded),label:Text(i.verified?'Verified':'Verify & authorize response'))])))]); } }

class BroadcastScreen extends StatefulWidget { const BroadcastScreen({super.key}); @override State<BroadcastScreen> createState()=>_BroadcastScreenState(); }
class _BroadcastScreenState extends State<BroadcastScreen>{final c=TextEditingController(text:'High landslide risk in Ward 8. Avoid exposed slopes and follow verified evacuation routes.');@override void dispose(){c.dispose();super.dispose();}@override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Public Warning','Create a targeted, role-verified area broadcast.'),const StoryCard(image:'assets/images/monitoring_mountain.jpg',title:'Ward 8 warning perimeter',subtitle:'18,420 devices · 3 safe hubs · 2 blocked roads',badge:'LIVE'),const SizedBox(height:14),TextField(controller:c,maxLines:5,decoration:const InputDecoration(border:OutlineInputBorder(),labelText:'Warning message')),const SizedBox(height:14),FilledButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Broadcast queued to 18,420 devices'))),icon:const Icon(Icons.campaign_rounded),label:const Text('Broadcast warning'))]);}

class AuthorityAdmin extends StatelessWidget { const AuthorityAdmin({super.key}); @override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Admin','Governance controls for accountable emergency response.'),SettingsTile(Icons.history_rounded,'Decision Log','Immutable prototype audit trail',blue,()=>_showInfo(context,'Decision log','Every verify, dispatch and closure action is timestamped.')),SettingsTile(Icons.policy_rounded,'Evidence Policy','Human review thresholds',green,()=>_showInfo(context,'Evidence policy','Critical warnings require authority verification.')),SettingsTile(Icons.security_rounded,'Access Controls','Role-based operational access',purple,()=>_showInfo(context,'Access controls','Citizen, Rescue, Authority, Volunteer and Organization scopes enabled.'))]); }

class VolunteerField extends StatelessWidget { const VolunteerField({super.key}); @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[const GradientHeader(icon:Icons.volunteer_activism_rounded,eyebrow:'GROUND SUPPORT NETWORK',title:'Help where it\nmatters most.',subtitle:'Verified missions, safe routes and coordinated community support.',colors:[purple,Color(0xFF9B72F2)]),const SectionTitle('Nearby verified tasks','Only authority/rescue-linked assignments are shown'),for(final i in m.incidents) IncidentFocus(incident:i,color:purple,primary:'Accept support task',onPrimary:()=>m.volunteerAccept(i),secondary:'Open map',onSecondary:()=>_open(context,const SharedMapScreen(title:'Volunteer Field Map',accent:purple)))]); } }
class VolunteerTasks extends StatelessWidget { const VolunteerTasks({super.key}); @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[const PageHeader('Assigned Tasks','Evacuation, check-in and supply tasks linked to live incidents.'),for(final i in m.incidents) Card(child:ListTile(contentPadding:const EdgeInsets.all(18),leading:CircleAvatar(backgroundColor:purple.withValues(alpha:.12),child:const Icon(Icons.volunteer_activism_rounded,color:purple)),title:Text('${i.id} · ${i.location}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(i.volunteer=='Unassigned'?'Awaiting volunteer':'Assigned to ${i.volunteer}'),trailing:FilledButton(onPressed:()=>m.volunteerAccept(i),child:const Text('Accept'))))]); } }
class VolunteerMore extends StatelessWidget { const VolunteerMore({super.key}); @override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Volunteer Tools','Practical field support beyond incident response.'),SettingsTile(Icons.fact_check_rounded,'Household Check-in','Mark families safe at checkpoints',green,()=>_showInfo(context,'Check-in','Checkpoint status updated.')),SettingsTile(Icons.inventory_2_rounded,'Supply Delivery','Confirm food, water and medicine handoff',orange,()=>_showInfo(context,'Supply handoff','Delivery confirmation ready.')),SettingsTile(Icons.badge_rounded,'Skills & Availability','First aid · transport · local guide',purple,()=>_showInfo(context,'Volunteer profile','Skills are matched to incident requirements.'))]); }

class OrganizationHub extends StatelessWidget { const OrganizationHub({super.key}); @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[const GradientHeader(icon:Icons.business_rounded,eyebrow:'RELIEF & LOGISTICS HUB',title:'Turn capacity\ninto recovery.',subtitle:'Shelter, medical aid, food, water and transport coordinated in one flow.',colors:[orange,Color(0xFFFFC15A)]),const SectionTitle('Hub capacity','Live operational readiness'),Row(children:const[Expanded(child:MetricCard(icon:Icons.bed_rounded,value:'84',label:'Beds free',color:green)),SizedBox(width:12),Expanded(child:MetricCard(icon:Icons.medical_services_rounded,value:'12',label:'Medical slots',color:red)),SizedBox(width:12),Expanded(child:MetricCard(icon:Icons.local_shipping_rounded,value:'4',label:'Vehicles',color:orange))]),const SectionTitle('Incoming linked incidents','Allocate relief against the same incident ID'),for(final i in m.incidents) IncidentFocus(incident:i,color:orange,primary:'Allocate relief',onPrimary:()=>m.allocateRelief(i),secondary:'Response room',onSecondary:()=>_open(context,IncidentRoom(incident:i,role:UserRole.organization)))]); } }
class OrganizationRequests extends StatelessWidget { const OrganizationRequests({super.key}); @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[const PageHeader('Resource Requests','Requests appear here as rescue and authority actions progress.'),for(final i in m.incidents) Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${i.id} · ${i.people} people',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)),Text('${i.medical?'Medical priority · ':''}${i.location}'),const SizedBox(height:12),Text('Current allocation: ${i.shelter}'),const SizedBox(height:12),FilledButton.icon(onPressed:()=>m.allocateRelief(i),icon:const Icon(Icons.inventory_rounded),label:const Text('Reserve shelter + supplies'))]))]); } }
class InventoryScreen extends StatefulWidget { const InventoryScreen({super.key}); @override State<InventoryScreen> createState()=>_InventoryScreenState(); }
class _InventoryScreenState extends State<InventoryScreen>{int water=320,food=240,medical=78;@override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Inventory','Tap issue to simulate real stock movement during a response.'),InventoryCard('Water kits',water,500,blue,()=>setState(()=>water=(water-10).clamp(0,500))),InventoryCard('Food packs',food,400,orange,()=>setState(()=>food=(food-10).clamp(0,400))),InventoryCard('Medical kits',medical,120,red,()=>setState(()=>medical=(medical-5).clamp(0,120))),const StoryCard(image:'assets/images/hero_mountain.jpg',title:'Melamchi Relief Hub',subtitle:'2.7 km · medical desk active · 84 spaces',badge:'ONLINE')]);}}
class OrganizationMore extends StatelessWidget { const OrganizationMore({super.key}); @override Widget build(BuildContext context)=>AppPage(children:[const PageHeader('Organization Network','Partner, transport and shelter controls.'),SettingsTile(Icons.home_work_rounded,'Shelter Registry','Occupancy and accessibility',green,()=>_showInfo(context,'Shelter registry','3 hubs online. 146 spaces available.')),SettingsTile(Icons.local_shipping_rounded,'Transport Fleet','4 response vehicles available',orange,()=>_showInfo(context,'Fleet','Vehicle O-04 reserved for medical transfer.')),SettingsTile(Icons.handshake_rounded,'Partner Network','Hospital, NGO and community links',blue,()=>_showInfo(context,'Partners','District Hospital and 4 NGOs online.'))]); }

class CommsScreen extends StatelessWidget { const CommsScreen({super.key,required this.role}); final UserRole role; @override Widget build(BuildContext context){final m=AppScope.of(context);return AppPage(children:[PageHeader('${role.title} Communications','Shared incident rooms with voice, video and live updates.'),for(final i in m.incidents) Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${i.id} · ${i.type}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:19)),Text(i.location),const SizedBox(height:14),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>_open(context,CallScreen(title:'${i.id} Response Channel',video:false,color:role.color)),icon:const Icon(Icons.call_rounded),label:const Text('Voice'))),const SizedBox(width:10),Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:role.color),onPressed:()=>_open(context,CallScreen(title:'${i.id} Response Channel',video:true,color:role.color)),icon:const Icon(Icons.videocam_rounded),label:const Text('Video')))]),const SizedBox(height:8),TextButton.icon(onPressed:()=>_open(context,IncidentRoom(incident:i,role:role)),icon:const Icon(Icons.forum_rounded),label:const Text('Open shared incident room'))]))) ]); } }

class IncidentRoom extends StatefulWidget { const IncidentRoom({super.key,required this.incident,required this.role}); final Incident incident; final UserRole role; @override State<IncidentRoom> createState()=>_IncidentRoomState(); }
class _IncidentRoomState extends State<IncidentRoom>{final c=TextEditingController();@override void dispose(){c.dispose();super.dispose();}@override Widget build(BuildContext context){final m=AppScope.of(context);final msgs=m.messages.where((x)=>x.incidentId==widget.incident.id).toList();return Scaffold(appBar:AppBar(title:Text('${widget.incident.id} Response Room')),body:Column(children:[Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[StageBar(stage:widget.incident.stage),const SizedBox(height:16),for(final msg in msgs) Align(alignment:msg.sender==widget.role.title?Alignment.centerRight:Alignment.centerLeft,child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(12),constraints:const BoxConstraints(maxWidth:320),decoration:BoxDecoration(color:msg.sender==widget.role.title?widget.role.color.withValues(alpha:.18):Theme.of(context).cardColor,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(msg.sender,style:TextStyle(fontWeight:FontWeight.w900,color:widget.role.color)),const SizedBox(height:4),Text(msg.text)]))) ])),SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[IconButton(onPressed:()=>_open(context,CallScreen(title:'${widget.incident.id} Voice',video:false,color:widget.role.color)),icon:const Icon(Icons.call_rounded)),IconButton(onPressed:()=>_open(context,CallScreen(title:'${widget.incident.id} Video',video:true,color:widget.role.color)),icon:const Icon(Icons.videocam_rounded)),Expanded(child:TextField(controller:c,decoration:const InputDecoration(hintText:'Message all roles…',border:OutlineInputBorder()))),IconButton(onPressed:(){m.addMessage(widget.incident,widget.role.title,c.text);c.clear();},icon:const Icon(Icons.send_rounded))])))]));}}

class IncidentDetail extends StatelessWidget { const IncidentDetail({super.key,required this.incident}); final Incident incident; @override Widget build(BuildContext context){final m=AppScope.of(context);final events=m.timeline.where((e)=>e.incidentId==incident.id).toList();return Scaffold(appBar:AppBar(title:Text('Incident #${incident.id}')),body:ListView(padding:const EdgeInsets.all(18),children:[AlertCard(incident:incident),const SizedBox(height:14),StageBar(stage:incident.stage),const SizedBox(height:18),Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(incident.type,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:23)),Text(incident.location),const SizedBox(height:10),Text(incident.description),const SizedBox(height:12),Text('Rescue: ${incident.rescueTeam}'),Text('Volunteer: ${incident.volunteer}'),Text('Relief: ${incident.shelter}')]))),const SectionTitle('Live timeline','Every role action appears here'),for(final e in events) TimelineTile(entry:e),const SizedBox(height:12),FilledButton.icon(onPressed:()=>_open(context,IncidentRoom(incident:incident,role:UserRole.citizen)),icon:const Icon(Icons.forum_rounded),label:const Text('Open live response room'))])); } }

class SharedMapScreen extends StatelessWidget { const SharedMapScreen({super.key,required this.title,required this.accent}); final String title; final Color accent; @override Widget build(BuildContext context)=>AppPage(children:[PageHeader(title,'Live OSM map with shared incidents, hazard zones and response routing.'),SizedBox(height:590,child:ClipRRect(borderRadius:BorderRadius.circular(28),child:const NepalMap(showRoute:true))),const SizedBox(height:14),Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Icon(Icons.circle,color:accent,size:14),const SizedBox(width:8),const Expanded(child:Text('Incident marker · safe route · operational map layer'))])))]); }

class NepalMap extends StatelessWidget { const NepalMap({super.key,this.compact=false,this.showRoute=false}); final bool compact; final bool showRoute; @override Widget build(BuildContext context){final center=LatLng(27.951,85.684);return FlutterMap(options:MapOptions(initialCenter:center,initialZoom:compact?10.0:9.5),children:[TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.jeevansetu.sih2026'),CircleLayer(circles:[CircleMarker(point:LatLng(27.96,85.69),radius:42,color:red.withValues(alpha:.18),borderColor:red,borderStrokeWidth:2),CircleMarker(point:LatLng(27.91,85.61),radius:30,color:orange.withValues(alpha:.15),borderColor:orange,borderStrokeWidth:2)]),if(showRoute)PolylineLayer(polylines:[Polyline(points:[LatLng(27.90,85.58),LatLng(27.925,85.62),LatLng(27.94,85.66),LatLng(27.965,85.70),LatLng(27.99,85.73)],strokeWidth:6,color:green)]),MarkerLayer(markers:[Marker(point:LatLng(27.96,85.69),width:48,height:48,child:const Icon(Icons.location_pin,color:red,size:44)),Marker(point:LatLng(27.90,85.58),width:44,height:44,child:const Icon(Icons.home_rounded,color:green,size:38)),Marker(point:LatLng(27.99,85.73),width:44,height:44,child:const Icon(Icons.local_hospital_rounded,color:blue,size:36))])]); } }

class CallScreen extends StatefulWidget { const CallScreen({super.key,required this.title,required this.video,required this.color}); final String title; final bool video; final Color color; @override State<CallScreen> createState()=>_CallScreenState(); }
class _CallScreenState extends State<CallScreen>{int seconds=0;bool muted=false,speaker=true,camera=true;Timer? timer;@override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>seconds++);});}@override void dispose(){timer?.cancel();super.dispose();}@override Widget build(BuildContext context){final min=(seconds~/60).toString().padLeft(2,'0'),sec=(seconds%60).toString().padLeft(2,'0');return Scaffold(backgroundColor:deep,body:SafeArea(child:Stack(children:[if(widget.video)Positioned.fill(child:Image.asset('assets/images/monitoring_mountain.jpg',fit:BoxFit.cover,color:Colors.black45,colorBlendMode:BlendMode.darken)),Positioned.fill(child:Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,deep.withValues(alpha:.95)])))),Padding(padding:const EdgeInsets.all(24),child:Column(children:[const Spacer(),CircleAvatar(radius:46,backgroundColor:widget.color,child:Icon(widget.video?Icons.videocam_rounded:Icons.call_rounded,color:Colors.white,size:42)),const SizedBox(height:18),Text(widget.title,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text('$min:$sec · encrypted in-app channel',style:const TextStyle(color:Colors.white70)),const Spacer(),Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[_callButton(muted?Icons.mic_off:Icons.mic,()=>setState(()=>muted=!muted)),_callButton(speaker?Icons.volume_up:Icons.volume_off,()=>setState(()=>speaker=!speaker)),if(widget.video)_callButton(camera?Icons.videocam:Icons.videocam_off,()=>setState(()=>camera=!camera)),_callButton(Icons.call_end,()=>Navigator.pop(context),color:red)]),const SizedBox(height:28)])])]))); } Widget _callButton(IconData icon,VoidCallback onTap,{Color color=const Color(0xFF24434C)})=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(36),child:CircleAvatar(radius:30,backgroundColor:color,child:Icon(icon,color:Colors.white,size:28))); }

class PersonalSafetyScreen extends StatelessWidget { const PersonalSafetyScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Personal Safety')),body:ListView(padding:const EdgeInsets.all(18),children:[const GradientHeader(icon:Icons.shield_rounded,eyebrow:'FAMILY SAFETY',title:'You are in a\nmonitored zone.',subtitle:'Last safety check-in 12 minutes ago.',colors:[navy,cyan]),for(final x in [('You','Safe · live location',green),('Mother','Safe · 2 min ago',green),('Father','Safe · 18 min ago',green),('Sister','Awaiting check-in',orange)])Card(child:ListTile(contentPadding:const EdgeInsets.all(18),leading:CircleAvatar(backgroundColor:x.$3.withValues(alpha:.12),child:Icon(Icons.person,color:x.$3)),title:Text(x.$1,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(x.$2,style:TextStyle(color:x.$3))))])); }
class SensorScreen extends StatelessWidget { const SensorScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Sensor Network')),body:ListView(padding:const EdgeInsets.all(18),children:[const GradientHeader(icon:Icons.sensors_rounded,eyebrow:'LIVE TELEMETRY',title:'26 / 28 sensors\nonline.',subtitle:'Last mesh sync 14 sec · health 96%',colors:[navy,blue]),SensorTile('Rain Gauge SG-04','18.4 mm/hr · Rising',.82,blue),SensorTile('Soil Probe SM-12','87% saturation · Critical',.87,red),SensorTile('Slope Node IN-07','2.8 mm movement · Watch',.62,orange),SensorTile('Weather Station WX-03','Pressure falling · Active',.48,green)])); }
class OfflineScreen extends StatelessWidget { const OfflineScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Offline Readiness')),body:ListView(padding:const EdgeInsets.all(18),children:[const GradientHeader(icon:Icons.offline_bolt_rounded,eyebrow:'OFFLINE PACK',title:'Emergency pack\nready offline.',subtitle:'Risk snapshot, safety guides and contacts cached.',colors:[navy,green]),SettingsTile(Icons.map_rounded,'Risk snapshot','Updated 3 min ago',green,(){}),SettingsTile(Icons.shield_rounded,'Safety guidelines','Available offline',green,(){}),SettingsTile(Icons.contact_phone_rounded,'Emergency contacts','Available offline',green,(){})])); }
class GuidelinesScreen extends StatelessWidget { const GuidelinesScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Safety Guidelines')),body:ListView(padding:const EdgeInsets.all(18),children:[Guideline(1,'Move away from steep slopes','Do not wait below unstable slopes or drainage channels.',red),Guideline(2,'Follow verified evacuation routes','Avoid shortcuts through active red zones.',orange),Guideline(3,'Keep an emergency go-bag','Water, medicines, torch, power bank and identity documents.',blue),Guideline(4,'Check in with family','Use Personal Safety so responders know who is safe.',green)])); }

class AppPage extends StatelessWidget { const AppPage({super.key,required this.children}); final List<Widget> children; @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(18,18,18,28),children:children)); }
class PageHeader extends StatelessWidget { const PageHeader(this.title,this.subtitle,{super.key}); final String title,subtitle; @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:5),Text(subtitle,style:Theme.of(context).textTheme.bodyLarge)])); }
class SectionTitle extends StatelessWidget { const SectionTitle(this.title,this.subtitle,{super.key}); final String title,subtitle; @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.fromLTRB(2,24,2,12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:2),Text(subtitle)])); }
class HeroBanner extends StatelessWidget { const HeroBanner({super.key,required this.image,required this.eyebrow,required this.title,required this.subtitle,required this.accent}); final String image,eyebrow,title,subtitle; final Color accent; @override Widget build(BuildContext context)=>Container(height:360,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(30)),child:Stack(fit:StackFit.expand,children:[Image.asset(image,fit:BoxFit.cover),const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Color(0xE7032A35)]))),Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Spacer(),Text(eyebrow,style:TextStyle(color:accent,fontWeight:FontWeight.w900,letterSpacing:1.4)),const SizedBox(height:10),Text(title,style:const TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.w900,height:.98)),const SizedBox(height:12),Text(subtitle,style:const TextStyle(color:Colors.white70,fontSize:15,height:1.4))]))])); }
class GradientHeader extends StatelessWidget { const GradientHeader({super.key,required this.icon,required this.eyebrow,required this.title,required this.subtitle,required this.colors}); final IconData icon; final String eyebrow,title,subtitle; final List<Color> colors; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:LinearGradient(colors:colors)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:Colors.white,size:38),const SizedBox(height:26),Text(eyebrow,style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Text(title,style:const TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900,height:1)),const SizedBox(height:10),Text(subtitle,style:const TextStyle(color:Colors.white70))])); }
class MetricCard extends StatelessWidget { const MetricCard({super.key,required this.icon,required this.value,required this.label,required this.color}); final IconData icon; final String value,label; final Color color; @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:color),const SizedBox(height:10),Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text(label,style:Theme.of(context).textTheme.bodySmall)]))); }
class AlertCard extends StatelessWidget { const AlertCard({super.key,required this.incident}); final Incident incident; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(26),gradient:const LinearGradient(colors:[red,Color(0xFFFF5F6D)])),child:Row(children:[const CircleAvatar(backgroundColor:Colors.white24,child:Icon(Icons.warning_amber_rounded,color:Colors.white)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${incident.id} · ${incident.type}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:19)),const SizedBox(height:4),Text(incident.location,style:const TextStyle(color:Colors.white70))])),const Icon(Icons.chevron_right,color:Colors.white)])); }
class ActionItem { ActionItem(this.icon,this.label,this.color,this.onTap); final IconData icon; final String label; final Color color; final VoidCallback onTap; }
class ActionGrid extends StatelessWidget { const ActionGrid({super.key,required this.items}); final List<ActionItem> items; @override Widget build(BuildContext context)=>GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:12,crossAxisSpacing:12,childAspectRatio:1.4,children:[for(final i in items)InkWell(onTap:i.onTap,borderRadius:BorderRadius.circular(22),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[CircleAvatar(backgroundColor:i.color.withValues(alpha:.12),child:Icon(i.icon,color:i.color)),const SizedBox(width:12),Expanded(child:Text(i.label,style:const TextStyle(fontWeight:FontWeight.w900)))]))))])); }
class StoryCard extends StatelessWidget { const StoryCard({super.key,required this.image,required this.title,required this.subtitle,required this.badge}); final String image,title,subtitle,badge; @override Widget build(BuildContext context)=>Container(height:185,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(26)),child:Stack(fit:StackFit.expand,children:[Image.asset(image,fit:BoxFit.cover),const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Color(0xDD032A35)]))),Positioned(left:18,right:18,bottom:16,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:20)),Text(subtitle,style:const TextStyle(color:Colors.white70))])),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(99)),child:Text(badge,style:const TextStyle(color:navy,fontWeight:FontWeight.w900))) ]))])); }
class IncidentTile extends StatelessWidget { const IncidentTile({super.key,required this.incident,required this.onTap}); final Incident incident; final VoidCallback onTap; @override Widget build(BuildContext context)=>Card(child:ListTile(onTap:onTap,contentPadding:const EdgeInsets.all(16),leading:CircleAvatar(backgroundColor:red.withValues(alpha:.12),child:const Icon(Icons.warning_rounded,color:red)),title:Text('${incident.id} · ${incident.type}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${incident.location}\n${stageName(incident.stage)}'),isThreeLine:true,trailing:const Icon(Icons.chevron_right))); }
class IncidentFocus extends StatelessWidget { const IncidentFocus({super.key,required this.incident,required this.color,required this.primary,required this.onPrimary,required this.secondary,required this.onSecondary}); final Incident incident; final Color color; final String primary,secondary; final VoidCallback onPrimary,onSecondary; @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(backgroundColor:color.withValues(alpha:.12),child:Icon(Icons.warning_rounded,color:color)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${incident.id} · ${incident.type}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:19)),Text(incident.location)]))]),const SizedBox(height:14),StageBar(stage:incident.stage),const SizedBox(height:14),Row(children:[Expanded(child:FilledButton(style:FilledButton.styleFrom(backgroundColor:color),onPressed:onPrimary,child:Text(primary))),const SizedBox(width:8),Expanded(child:OutlinedButton(onPressed:onSecondary,child:Text(secondary)))])]))); }
class StageBar extends StatelessWidget { const StageBar({super.key,required this.stage}); final IncidentStage stage; @override Widget build(BuildContext context){final vals=IncidentStage.values;return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LinearProgressIndicator(value:(stage.index+1)/vals.length,minHeight:8,borderRadius:BorderRadius.circular(9),color:stage==IncidentStage.completed?green:cyan),const SizedBox(height:6),Text(stageName(stage),style:const TextStyle(fontWeight:FontWeight.w800))]);} }
String stageName(IncidentStage s)=>switch(s){IncidentStage.submitted=>'Report submitted',IncidentStage.verification=>'Under verification',IncidentStage.dispatched=>'Rescue dispatched',IncidentStage.onSite=>'Team on site',IncidentStage.rescued=>'People rescued',IncidentStage.relief=>'Relief & recovery',IncidentStage.completed=>'Completed'};
class TimelineTile extends StatelessWidget { const TimelineTile({super.key,required this.entry}); final TimelineEntry entry; @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(margin:const EdgeInsets.only(top:5),width:12,height:12,decoration:BoxDecoration(color:entry.color,shape:BoxShape.circle)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(entry.role,style:TextStyle(color:entry.color,fontWeight:FontWeight.w900)),Text(entry.text)]))])); }
class SettingsTile extends StatelessWidget { const SettingsTile(this.icon,this.title,this.subtitle,this.color,this.onTap,{super.key}); final IconData icon;final String title,subtitle;final Color color;final VoidCallback onTap;@override Widget build(BuildContext context)=>Card(child:ListTile(onTap:onTap,contentPadding:const EdgeInsets.all(16),leading:CircleAvatar(backgroundColor:color.withValues(alpha:.12),child:Icon(icon,color:color)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(subtitle),trailing:const Icon(Icons.chevron_right))); }
class InventoryCard extends StatelessWidget { const InventoryCard(this.title,this.value,this.max,this.color,this.onIssue,{super.key}); final String title;final int value,max;final Color color;final VoidCallback onIssue;@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18))),Text('$value / $max',style:TextStyle(color:color,fontWeight:FontWeight.w900))]),const SizedBox(height:10),LinearProgressIndicator(value:value/max,color:color),const SizedBox(height:12),OutlinedButton.icon(onPressed:onIssue,icon:const Icon(Icons.remove_circle_outline),label:const Text('Issue stock'))]))); }
class SensorTile extends StatelessWidget { const SensorTile(this.title,this.subtitle,this.value,this.color,{super.key}); final String title,subtitle;final double value;final Color color;@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),Text(subtitle),const SizedBox(height:12),LinearProgressIndicator(value:value,color:color)]))); }
class Guideline extends StatelessWidget { const Guideline(this.number,this.title,this.text,this.color,{super.key}); final int number;final String title,text;final Color color;@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:color,foregroundColor:Colors.white,child:Text('$number',style:const TextStyle(fontWeight:FontWeight.w900))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(height:4),Text(text)]))]))); }

void _open(BuildContext context,Widget page)=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>page));
void _showInfo(BuildContext context,String title,String text)=>showModalBottomSheet(context:context,showDragHandle:true,builder:(_)=>Padding(padding:const EdgeInsets.fromLTRB(22,8,22,32),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:22)),const SizedBox(height:8),Text(text)])));
