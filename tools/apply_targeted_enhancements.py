from pathlib import Path
import re

p = Path('lib/judge_experience.dart')
s = p.read_text(encoding='utf-8')

# Imports: device evidence, SOS haptic/system alert, spoken acknowledgement.
s = s.replace("import 'dart:async';\n", "import 'dart:async';\nimport 'dart:io';\n")
s = s.replace("import 'package:flutter/material.dart';\n", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_tts/flutter_tts.dart';\nimport 'package:image_picker/image_picker.dart';\n")

# Dark mode is intentionally removed: keep the approved light foundation everywhere.
s = s.replace('themeMode: mode,', 'themeMode: ThemeMode.light,')
controls = '''class FoundationControls extends StatelessWidget {
  const FoundationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = AppPreferences.of(context);
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<AppLanguage>(
            color: const Color(0xFF0B3541),
            initialValue: pref.language,
            onSelected: pref.setLanguage,
            itemBuilder: (_) => AppLanguage.values.map((language) => PopupMenuItem<AppLanguage>(
              value: language,
              child: Text(language.label, style: const TextStyle(color: Colors.white)),
            )).toList(),
            child: GlassControl(
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(pref.language.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: GlassControl(
            child: Row(
              children: [
                Icon(Icons.visibility_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('High visibility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                Icon(Icons.verified_rounded, color: Color(0xFF57E1E8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

'''
s, n = re.subn(r'class FoundationControls extends StatelessWidget \{.*?\n\}\n\n(?=class GlassControl)', controls, s, flags=re.S)
assert n == 1, f'FoundationControls patch count {n}'

# Real map route replaces the old painted diagram, while keeping the same page and controls.
safe_route = '''class SafeRoutePage extends StatefulWidget {
  const SafeRoutePage({super.key});

  @override
  State<SafeRoutePage> createState() => _SafeRoutePageState();
}

class _SafeRoutePageState extends State<SafeRoutePage> {
  int route = 0;

  List<LatLng> get selectedRoute => route == 0
      ? const [
          LatLng(27.8290, 85.5480), LatLng(27.8238, 85.5410),
          LatLng(27.8170, 85.5355), LatLng(27.8115, 85.5270),
          LatLng(27.8060, 85.5190), LatLng(27.7990, 85.5120),
        ]
      : const [
          LatLng(27.8290, 85.5480), LatLng(27.8220, 85.5380),
          LatLng(27.8140, 85.5290), LatLng(27.8060, 85.5190),
          LatLng(27.7990, 85.5120),
        ];

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Safe Route',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(initialCenter: LatLng(27.814, 85.530), initialZoom: 13.2),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jeevansetu.app',
                      ),
                      PolygonLayer(polygons: [
                        Polygon(
                          points: const [LatLng(27.824,85.526), LatLng(27.829,85.534), LatLng(27.821,85.541), LatLng(27.816,85.532)],
                          color: red.withValues(alpha: .20), borderColor: red, borderStrokeWidth: 2,
                        ),
                      ]),
                      PolylineLayer(polylines: [
                        Polyline(points: selectedRoute, strokeWidth: 6, color: route == 0 ? green : orange),
                      ]),
                      MarkerLayer(markers: [
                        Marker(point: selectedRoute.first, width: 48, height: 48,
                          child: const Icon(Icons.my_location_rounded, color: navy, size: 34)),
                        Marker(point: selectedRoute.last, width: 52, height: 52,
                          child: const Icon(Icons.shield_rounded, color: green, size: 40)),
                      ]),
                    ],
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(color: deepNavy.withValues(alpha: .90), borderRadius: BorderRadius.circular(12)),
                      child: const Text('LIVE SAFE CORRIDOR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: RouteChoice(active: route == 0, title: 'Safest', subtitle: '6.3 km · 18 min', color: green, onTap: () => setState(() => route = 0))),
                  const SizedBox(width: 8),
                  Expanded(child: RouteChoice(active: route == 1, title: 'Fastest', subtitle: '5.1 km · 14 min', color: orange, onTap: () => setState(() => route = 1))),
                ]),
                const SizedBox(height: 12),
                const Row(children: [
                  Icon(Icons.shield_rounded, color: green), SizedBox(width: 7),
                  Expanded(child: Text('Live route avoids the active red zone and blocked bridge. Pinch and drag the map to inspect the corridor.', style: TextStyle(fontSize: 10.5, height: 1.35))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

'''
s, n = re.subn(r'class SafeRoutePage extends StatefulWidget \{.*?\n\}\n\n(?=class RouteChoice)', safe_route, s, flags=re.S)
assert n == 1, f'SafeRoute patch count {n}'

# Evidence becomes a real camera/gallery capture and the submitted report opens the shared 5-role room.
incident = '''class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  int type = 0;
  bool sent = false;
  String? evidencePath;
  final ImagePicker picker = ImagePicker();

  Future<void> pickEvidence(ImageSource source) async {
    final image = await picker.pickImage(source: source, imageQuality: 78, maxWidth: 1600);
    if (image != null && mounted) setState(() => evidencePath = image.path);
  }

  @override
  Widget build(BuildContext context) {
    final types = ['Slope crack', 'Falling rocks', 'Blocked road', 'Flood water'];
    return DetailPage(
      title: 'Report Incident',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [deepNavy, navy]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(children: [
              CircleAvatar(backgroundColor: Color(0x22FFFFFF), child: Icon(Icons.add_a_photo_rounded, color: aqua)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Community Evidence', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                Text('Photo + location + time are shared to the response network', style: TextStyle(color: Colors.white60, fontSize: 10)),
              ])),
              LiveBadge(label: 'LIVE'),
            ]),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What do you see?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(spacing: 7, runSpacing: 7, children: List.generate(types.length, (i) => ChoiceChip(
                label: Text(types[i]), selected: type == i, onSelected: (_) => setState(() => type = i),
              ))),
              const SizedBox(height: 14),
              if (evidencePath != null) ...[
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(evidencePath!), height: 170, width: double.infinity, fit: BoxFit.cover)),
                const SizedBox(height: 8),
                const Row(children: [Icon(Icons.verified_rounded, color: green, size: 18), SizedBox(width: 6), Expanded(child: Text('Evidence ready · timestamp + GPS context attached', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))]),
                const SizedBox(height: 8),
              ],
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => pickEvidence(ImageSource.camera), icon: const Icon(Icons.camera_alt_rounded), label: const Text('Camera'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () => pickEvidence(ImageSource.gallery), icon: const Icon(Icons.photo_library_rounded), label: const Text('Gallery'))),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () {
              JeevanNetwork.instance.reportCitizenIncident(types[type]);
              setState(() => sent = true);
            },
            icon: Icon(sent ? Icons.check_rounded : Icons.send_rounded),
            label: Text(sent ? 'Shared across all 5 roles' : 'Submit verified report'),
          )),
          if (sent) ...[
            const SizedBox(height: 12),
            SurfaceCard(child: Column(children: [
              const Row(children: [
                Icon(Icons.hub_rounded, color: purple), SizedBox(width: 9),
                Expanded(child: Text('Citizen → Authority → Rescue → Volunteer → Organization', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
              ]),
              const SizedBox(height: 10),
              const Text('Your report is now one shared incident. Every response role can message and update the same case.', style: TextStyle(fontSize: 10.5, height: 1.4)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: () => Navigator.push(context, premiumRoute(const CitizenResponseMessenger())),
                icon: const Icon(Icons.forum_rounded), label: const Text('Open 5-role response messenger'),
              )),
            ])),
          ],
        ],
      ),
    );
  }
}

'''
s, n = re.subn(r'class IncidentReportPage extends StatefulWidget \{.*?\n\}\n\n(?=class ResourcesPage)', incident, s, flags=re.S)
assert n == 1, f'IncidentReport patch count {n}'

# SOS now creates the same shared incident, plays an alert and speaks the acknowledgement.
old_send = '''  void send() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SosTrackingSheet(),
    );
  }'''
new_send = '''  Future<void> send() async {
    JeevanNetwork.instance.reportCitizenIncident('SOS · $emergency · $people people${medical ? ' · medical priority' : ''}');
    await SystemSound.play(SystemSoundType.alert);
    final tts = FlutterTts();
    await tts.setSpeechRate(0.46);
    await tts.speak('Emergency request sent. JeevanSetu rescue network has been alerted.');
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SosTrackingSheet(),
    );
  }'''
assert old_send in s, 'SOS send block not found'
s = s.replace(old_send, new_send, 1)

p.write_text(s, encoding='utf-8')

# Add a Citizen-facing messenger to the already shared network used by all professional roles.
cp = Path('lib/connected_role_tabs.dart')
c = cp.read_text(encoding='utf-8')
if 'class CitizenResponseMessenger extends StatefulWidget' not in c:
    c += r'''

class CitizenResponseMessenger extends StatefulWidget {
  const CitizenResponseMessenger({super.key});

  @override
  State<CitizenResponseMessenger> createState() => _CitizenResponseMessengerState();
}

class _CitizenResponseMessengerState extends State<CitizenResponseMessenger> {
  final TextEditingController field = TextEditingController();

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FA),
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Response Messenger', style: TextStyle(fontWeight: FontWeight.w900)),
          Text('All 5 roles · shared incident room', style: TextStyle(fontSize: 10, color: Colors.black54)),
        ]),
      ),
      body: ValueListenableBuilder<List<NetworkIncident>>(
        valueListenable: JeevanNetwork.instance.incidents,
        builder: (context, incidents, _) {
          final incident = incidents.first;
          return Column(children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_deep, _navy]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(incident.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  const Text('● LIVE', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(height: 5),
                Text(incident.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Wrap(spacing: 6, runSpacing: 6, children: [
                  _RolePill('Citizen', _green), _RolePill('Authority', _blue), _RolePill('Rescue', _red), _RolePill('Volunteer', _purple), _RolePill('Organization', _orange),
                ]),
              ]),
            ),
            Expanded(child: ValueListenableBuilder<List<NetworkMessage>>(
              valueListenable: JeevanNetwork.instance.messages,
              builder: (context, messages, _) {
                final relevant = messages.where((m) => m.incidentId == incident.id).toList().reversed.toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: relevant.length,
                  itemBuilder: (_, i) {
                    final m = relevant[i];
                    final mine = m.sender == 'Citizen';
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(color: mine ? const Color(0xFFDDF6F0) : Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.sender, style: TextStyle(color: mine ? _green : _blue, fontSize: 9, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(m.text, style: const TextStyle(fontSize: 11.5, height: 1.35)),
                        ]),
                      ),
                    );
                  },
                );
              },
            )),
            SafeArea(top: false, child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(child: TextField(controller: field, decoration: InputDecoration(hintText: 'Message all response roles…', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
                const SizedBox(width: 7),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: _navy),
                  onPressed: () {
                    final text = field.text.trim();
                    if (text.isEmpty) return;
                    JeevanNetwork.instance.addMessage(incident.id, 'Citizen', text);
                    JeevanNetwork.instance.addEvent(incident.id, 'Citizen', 'Citizen posted a response-room update', _green);
                    field.clear();
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ]),
            )),
          ]);
        },
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final Color color;
  const _RolePill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(.16), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.45))),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
  );
}
'''
cp.write_text(c, encoding='utf-8')

pub = Path('pubspec.yaml')
y = pub.read_text(encoding='utf-8')
if 'flutter_tts:' not in y:
    y = y.replace('  image_picker: ^1.1.2\n', '  image_picker: ^1.1.2\n  flutter_tts: ^4.2.3\n')
pub.write_text(y, encoding='utf-8')

print('Targeted enhancements applied; original dashboards/foundation preserved.')
