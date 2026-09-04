from pathlib import Path
import re

# This patch intentionally preserves the approved JeevanSetu foundation.
# It only deepens shared incident state, evidence hand-off and professional inner-tab connectivity.

judge = Path('lib/judge_experience.dart')
s = judge.read_text(encoding='utf-8')

# Keep light mode locked. The user explicitly asked to remove dark mode rather than partially support it.
s = s.replace('themeMode: mode,', 'themeMode: ThemeMode.light,')

# Pass real captured evidence into the shared incident object.
s = s.replace(
    'JeevanNetwork.instance.reportCitizenIncident(types[type]);',
    "JeevanNetwork.instance.reportCitizenIncident(\n                types[type],\n                source: 'Citizen evidence',\n                evidencePath: evidencePath,\n                people: 1,\n                medical: false,\n              );",
)

# Pass SOS context into the exact same incident network.
s = re.sub(
    r"JeevanNetwork\.instance\.reportCitizenIncident\('SOS · \$emergency · \$people people\$\{medical \? ' · medical priority' : ''\}'\);",
    "JeevanNetwork.instance.reportCitizenIncident(\n      'SOS · $emergency',\n      source: 'Citizen SOS',\n      people: people,\n      medical: medical,\n    );",
    s,
)

# Upgrade the SOS confirmation language so the user clearly understands the five-role handoff.
s = s.replace(
    "await tts.speak('Emergency request sent. JeevanSetu rescue network has been alerted.');",
    "await tts.speak('Emergency request sent. Authority, rescue, volunteer and relief teams have been alerted through JeevanSetu.');",
)

judge.write_text(s, encoding='utf-8')

p = Path('lib/connected_role_tabs.dart')
c = p.read_text(encoding='utf-8')

if "import 'dart:io';" not in c:
    c = c.replace("import 'dart:async';\n", "import 'dart:async';\nimport 'dart:io';\n")

network_incident = r'''class NetworkIncident {
  final String id;
  final String title;
  final String source;
  final String location;
  final int priority;
  final String status;
  final String assignedTo;
  final DateTime createdAt;
  final int progress;
  final String? evidencePath;
  final int people;
  final bool medical;
  final bool verified;
  final bool rescueDispatched;
  final bool volunteerAssigned;
  final bool reliefReserved;

  const NetworkIncident({
    required this.id,
    required this.title,
    required this.source,
    required this.location,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.createdAt,
    this.progress = 12,
    this.evidencePath,
    this.people = 1,
    this.medical = false,
    this.verified = false,
    this.rescueDispatched = false,
    this.volunteerAssigned = false,
    this.reliefReserved = false,
  });

  NetworkIncident copyWith({
    String? status,
    String? assignedTo,
    int? progress,
    String? evidencePath,
    int? people,
    bool? medical,
    bool? verified,
    bool? rescueDispatched,
    bool? volunteerAssigned,
    bool? reliefReserved,
  }) {
    return NetworkIncident(
      id: id,
      title: title,
      source: source,
      location: location,
      priority: priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      progress: progress ?? this.progress,
      evidencePath: evidencePath ?? this.evidencePath,
      people: people ?? this.people,
      medical: medical ?? this.medical,
      verified: verified ?? this.verified,
      rescueDispatched: rescueDispatched ?? this.rescueDispatched,
      volunteerAssigned: volunteerAssigned ?? this.volunteerAssigned,
      reliefReserved: reliefReserved ?? this.reliefReserved,
    );
  }
}

'''
c, n = re.subn(r'class NetworkIncident \{.*?\n\}\n\n(?=class NetworkEvent)', network_incident, c, flags=re.S)
assert n == 1, f'NetworkIncident patch count {n}'

report_fn = r'''  void reportCitizenIncident(
    String title, {
    String source = 'Citizen report',
    String? evidencePath,
    int people = 1,
    bool medical = false,
  }) {
    final id = 'JS-${2500 + incidents.value.length + 1}';
    incidents.value = [
      NetworkIncident(
        id: id,
        title: title,
        source: source,
        location: 'Sindhupalchok · live GPS',
        priority: medical ? 5 : 4,
        status: 'New · waiting for authority verification',
        assignedTo: 'Shared response network',
        createdAt: DateTime.now(),
        progress: 10,
        evidencePath: evidencePath,
        people: people,
        medical: medical,
      ),
      ...incidents.value,
    ];
    addEvent(id, 'Citizen', 'Incident created with live location${evidencePath != null ? ' + visual evidence' : ''}', _green);
    addEvent(id, 'System', 'Case broadcast to Authority, Rescue, Volunteer and Organization', _blue);
    addMessage(id, 'System', 'Shared response room opened for all five JeevanSetu roles.');
    addMessage(id, 'Citizen', medical
        ? 'Emergency submitted with medical priority for $people people.'
        : 'Incident submitted with live GPS${evidencePath != null ? ' and photo evidence' : ''}.');
  }

'''
c, n = re.subn(r'  void reportCitizenIncident\(String title\) \{.*?\n  \}\n\n(?=  void update)', report_fn, c, flags=re.S)
assert n == 1, f'reportCitizenIncident patch count {n}'

update_fn = r'''  void update(
    String id, {
    String? status,
    String? assignedTo,
    int? progress,
    bool? verified,
    bool? rescueDispatched,
    bool? volunteerAssigned,
    bool? reliefReserved,
  }) {
    incidents.value = [
      for (final item in incidents.value)
        if (item.id == id)
          item.copyWith(
            status: status,
            assignedTo: assignedTo,
            progress: progress,
            verified: verified,
            rescueDispatched: rescueDispatched,
            volunteerAssigned: volunteerAssigned,
            reliefReserved: reliefReserved,
          )
        else
          item,
    ];
  }

'''
c, n = re.subn(r'  void update\(.*?\n  \}\n\n(?=  void addEvent)', update_fn, c, flags=re.S)
assert n == 1, f'update patch count {n}'

act_fn = r'''  void act(String role, NetworkIncident incident) {
    switch (role) {
      case 'Authority':
        update(
          incident.id,
          status: 'Verified · response authorised',
          assignedTo: 'District EOC',
          progress: incident.progress < 30 ? 30 : incident.progress,
          verified: true,
        );
        addEvent(incident.id, role, 'Citizen evidence verified and response authorised', _blue);
        addMessage(incident.id, role, 'Verified. Rescue may dispatch and the safe corridor is active.');
        break;
      case 'Rescue Team':
        update(
          incident.id,
          status: 'Rescue Unit 04 dispatched · ETA 8 min',
          assignedTo: 'Rescue Unit 04',
          progress: incident.progress < 50 ? 50 : incident.progress,
          rescueDispatched: true,
        );
        addEvent(incident.id, role, 'Unit 04 dispatched through the safest mapped corridor', _red);
        addMessage(incident.id, role, 'Unit 04 is en route. ETA 8 minutes. Keep live location enabled.');
        break;
      case 'Volunteer':
        update(
          incident.id,
          status: 'Ground support accepted',
          assignedTo: 'Volunteer Alpha',
          progress: incident.progress < 68 ? 68 : incident.progress,
          volunteerAssigned: true,
        );
        addEvent(incident.id, role, 'Volunteer Alpha accepted family and checkpoint support', _purple);
        addMessage(incident.id, role, 'Volunteer Alpha will meet the citizen at the safe assembly point.');
        break;
      case 'Organization':
        update(
          incident.id,
          status: 'Shelter + medical + supplies reserved',
          assignedTo: 'Melamchi Relief Hub',
          progress: incident.progress < 84 ? 84 : incident.progress,
          reliefReserved: true,
        );
        addEvent(incident.id, role, 'Relief capacity reserved for this exact incident', _orange);
        addMessage(incident.id, role, 'Beds, food, water and medical desk are reserved at Melamchi Relief Hub.');
        break;
    }
  }
'''
c, n = re.subn(r'  void act\(String role, NetworkIncident incident\) \{.*?\n  \}\n(?=\})', act_fn, c, flags=re.S)
assert n == 1, f'act patch count {n}'

# Insert a premium shared-handoff strip in PROFESSIONAL INNER TABS only.
marker = """                SliverToBoxAdapter(\n                  child: Container(\n                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),\n                    height: 330,"""
if 'ConnectedHandoffStrip(' not in c:
    replacement = """                SliverToBoxAdapter(\n                  child: Padding(\n                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),\n                    child: ConnectedHandoffStrip(\n                      incident: active,\n                      roleName: widget.roleName,\n                      accent: widget.accent,\n                      dark: widget.dark,\n                    ),\n                  ),\n                ),\n""" + marker
    assert marker in c, 'Operations map marker not found'
    c = c.replace(marker, replacement, 1)

if 'class ConnectedHandoffStrip extends StatelessWidget' not in c:
    c += r'''

class ConnectedHandoffStrip extends StatelessWidget {
  const ConnectedHandoffStrip({
    super.key,
    required this.incident,
    required this.roleName,
    required this.accent,
    required this.dark,
  });

  final NetworkIncident incident;
  final String roleName;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : _ink;
    final sub = dark ? Colors.white60 : Colors.black54;
    final nodes = <(String, Color, bool)>[
      ('Citizen', _green, true),
      ('Authority', _blue, incident.verified),
      ('Rescue', _red, incident.rescueDispatched),
      ('Volunteer', _purple, incident.volunteerAssigned),
      ('Relief', _orange, incident.reliefReserved),
    ];

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: incident.progress / 100),
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF102A33) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE1EAED)),
            boxShadow: dark ? const [] : [
              BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(13)),
                child: Icon(Icons.hub_rounded, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${incident.id} · Shared response', style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 2),
                Text(incident.status, style: TextStyle(color: sub, fontSize: 10)),
              ])),
              Text('${incident.progress}%', style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                color: accent,
                backgroundColor: accent.withOpacity(.10),
              ),
            ),
            const SizedBox(height: 13),
            Row(children: [
              for (var i = 0; i < nodes.length; i++) ...[
                Expanded(child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nodes[i].$3 ? nodes[i].$2 : (dark ? Colors.white10 : const Color(0xFFE9EFF1)),
                      boxShadow: nodes[i].$3 ? [BoxShadow(color: nodes[i].$2.withOpacity(.22), blurRadius: 10)] : const [],
                    ),
                    child: Icon(nodes[i].$3 ? Icons.check_rounded : Icons.more_horiz_rounded, size: 17, color: nodes[i].$3 ? Colors.white : sub),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(child: Text(nodes[i].$1, style: TextStyle(color: nodes[i].$3 ? fg : sub, fontSize: 8.5, fontWeight: FontWeight.w800))),
                ])),
                if (i != nodes.length - 1)
                  Container(width: 10, height: 2, color: nodes[i + 1].$3 ? nodes[i + 1].$2.withOpacity(.45) : (dark ? Colors.white10 : const Color(0xFFE5ECEE))),
              ],
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 7, runSpacing: 7, children: [
              _CaseChip(Icons.people_alt_rounded, '${incident.people} people', accent),
              if (incident.medical) const _CaseChip(Icons.medical_services_rounded, 'Medical priority', _red),
              if (incident.evidencePath != null) const _CaseChip(Icons.photo_camera_rounded, 'Citizen evidence', _green),
              _CaseChip(Icons.person_pin_circle_rounded, incident.assignedTo, accent),
            ]),
            if (incident.evidencePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(children: [
                  Image.file(File(incident.evidencePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    left: 9, bottom: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(color: _deep.withOpacity(.88), borderRadius: BorderRadius.circular(10)),
                      child: const Text('CITIZEN EVIDENCE · GPS + TIME', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ]),
              ),
            ],
          ]),
        );
      },
    );
  }
}

class _CaseChip extends StatelessWidget {
  const _CaseChip(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}
'''

p.write_text(c, encoding='utf-8')
print('Applied deep connected-role enhancement without changing approved dashboards.')
