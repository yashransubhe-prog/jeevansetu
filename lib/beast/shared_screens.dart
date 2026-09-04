import 'dart:async';

import 'package:flutter/material.dart';

import 'model.dart';
import 'widgets.dart';

void openPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
}

void showInfo(BuildContext context, String title, String text) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      );
    },
  );
}

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final incidentEvents = model.events.where((event) => event.incidentId == incident.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Incident #${incident.id}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AlertBanner(incident: incident),
          const SizedBox(height: 14),
          IncidentProgress(stage: incident.stage),
          const SizedBox(height: 18),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.type,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(incident.location),
                const SizedBox(height: 12),
                Text(incident.description),
                const SizedBox(height: 16),
                _detailRow('People', '${incident.people}'),
                _detailRow('Medical priority', incident.medical ? 'Yes' : 'No'),
                _detailRow('Rescue', incident.rescueTeam),
                _detailRow('Volunteer', incident.volunteerTeam),
                _detailRow('Relief', incident.reliefAllocation),
              ],
            ),
          ),
          const SectionTitle('Live incident timeline', 'Every role action appears against the same incident ID.'),
          for (final event in incidentEvents) TimelineTile(event: event),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              openPage(
                context,
                IncidentRoomScreen(incident: incident, role: UserRole.citizen),
              );
            },
            icon: const Icon(Icons.forum_rounded),
            label: const Text('Open shared response room'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class IncidentRoomScreen extends StatefulWidget {
  const IncidentRoomScreen({
    super.key,
    required this.incident,
    required this.role,
  });

  final Incident incident;
  final UserRole role;

  @override
  State<IncidentRoomScreen> createState() => _IncidentRoomScreenState();
}

class _IncidentRoomScreenState extends State<IncidentRoomScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final messages = model.messages.where((message) => message.incidentId == widget.incident.id).toList();
    final roleName = model.roleName(widget.role);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.incident.id} Response Room'),
            Text(
              stageLabel(widget.incident.stage),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: IncidentProgress(stage: widget.incident.stage),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final mine = message.sender == roleName || message.sender == widget.role.name;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mine
                          ? widget.role.color.withValues(alpha: .18)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: mine
                            ? widget.role.color.withValues(alpha: .24)
                            : Theme.of(context).dividerColor.withValues(alpha: .18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.sender,
                          style: TextStyle(
                            color: widget.role.color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(message.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      openPage(
                        context,
                        CallScreen(
                          title: '${widget.incident.id} Voice Channel',
                          video: false,
                          color: widget.role.color,
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_rounded),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: () {
                      openPage(
                        context,
                        CallScreen(
                          title: '${widget.incident.id} Video Channel',
                          video: true,
                          color: widget.role.color,
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Message all roles…'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: () {
                      model.addMessage(widget.incident, roleName, controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SharedCommsScreen extends StatelessWidget {
  const SharedCommsScreen({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        PageHeader(
          '${model.roleName(role)} Communications',
          'Shared incident rooms, voice calls, video calls and live updates.',
        ),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${incident.id} · ${incident.type}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  Text(incident.location),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            openPage(
                              context,
                              CallScreen(
                                title: '${incident.id} Response Channel',
                                video: false,
                                color: role.color,
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded),
                          label: const Text('Voice'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: role.color),
                          onPressed: () {
                            openPage(
                              context,
                              CallScreen(
                                title: '${incident.id} Response Channel',
                                video: true,
                                color: role.color,
                              ),
                            );
                          },
                          icon: const Icon(Icons.videocam_rounded),
                          label: const Text('Video'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      openPage(
                        context,
                        IncidentRoomScreen(incident: incident, role: role),
                      );
                    },
                    icon: const Icon(Icons.forum_rounded),
                    label: const Text('Open shared incident room'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.title,
    required this.video,
    required this.color,
  });

  final String title;
  final bool video;
  final Color color;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int seconds = 0;
  bool muted = false;
  bool speaker = true;
  bool camera = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => seconds += 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: kDeep,
      body: SafeArea(
        child: Stack(
          children: [
            if (widget.video)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/monitoring_mountain.jpg',
                  fit: BoxFit.cover,
                  color: Colors.black45,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, kDeep.withValues(alpha: .96)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: widget.color,
                    child: Icon(
                      widget.video ? Icons.videocam_rounded : Icons.call_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$minutes:$secs · encrypted in-app channel',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallButton(
                        icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        onTap: () => setState(() => muted = !muted),
                      ),
                      _CallButton(
                        icon: speaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        onTap: () => setState(() => speaker = !speaker),
                      ),
                      if (widget.video)
                        _CallButton(
                          icon: camera ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          onTap: () => setState(() => camera = !camera),
                        ),
                      _CallButton(
                        icon: Icons.call_end_rounded,
                        color: kRed,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF24434C),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: CircleAvatar(
        radius: 31,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class OperationalMapScreen extends StatelessWidget {
  const OperationalMapScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        PageHeader(title, subtitle),
        SizedBox(
          height: 560,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: const NepalOperationalMap(showRoute: true),
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: accent),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Incident marker · hazard perimeter · safe route · hospital / relief hub'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PersonalSafetyScreen extends StatelessWidget {
  const PersonalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Safety')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const GradientHero(
            icon: Icons.shield_rounded,
            eyebrow: 'FAMILY SAFETY',
            title: 'You are in a\nmonitored zone.',
            subtitle: 'Last safety check-in 12 minutes ago.',
            colors: [kNavy, kCyan],
          ),
          const SizedBox(height: 16),
          _person(context, 'You', 'Safe · live location', kGreen),
          _person(context, 'Mother', 'Safe · 2 min ago', kGreen),
          _person(context, 'Father', 'Safe · 18 min ago', kGreen),
          _person(context, 'Sister', 'Awaiting check-in', kOrange),
        ],
      ),
    );
  }

  Widget _person(BuildContext context, String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(Icons.person_rounded, color: color),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(status, style: TextStyle(color: color)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class SensorNetworkScreen extends StatelessWidget {
  const SensorNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Network')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          GradientHero(
            icon: Icons.sensors_rounded,
            eyebrow: 'LIVE TELEMETRY',
            title: '26 / 28 sensors\nonline.',
            subtitle: 'Last mesh sync 14 sec · network health 96%',
            colors: [kNavy, kBlue],
          ),
          SizedBox(height: 16),
          SensorRow('Rain Gauge SG-04', '18.4 mm/hr · Rising', .82, kBlue),
          SensorRow('Soil Probe SM-12', '87% saturation · Critical', .87, kRed),
          SensorRow('Slope Node IN-07', '2.8 mm movement · Watch', .62, kOrange),
          SensorRow('Weather Station WX-03', 'Pressure falling · Active', .48, kGreen),
        ],
      ),
    );
  }
}

class SensorRow extends StatelessWidget {
  const SensorRow(this.title, this.subtitle, this.value, this.color, {super.key});
  final String title;
  final String subtitle;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text(subtitle),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: value, color: color),
          ],
        ),
      ),
    );
  }
}

class OfflineReadinessScreen extends StatelessWidget {
  const OfflineReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Readiness')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const GradientHero(
            icon: Icons.offline_bolt_rounded,
            eyebrow: 'OFFLINE PACK',
            title: 'Emergency pack\nready offline.',
            subtitle: 'Risk snapshot, safety guides and emergency contacts cached for weak-network situations.',
            colors: [kNavy, kGreen],
          ),
          const SizedBox(height: 16),
          SettingsTile(
            icon: Icons.map_rounded,
            title: 'Risk snapshot',
            subtitle: 'Updated 3 min ago',
            color: kGreen,
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.shield_rounded,
            title: 'Safety guidelines',
            subtitle: 'Available offline',
            color: kGreen,
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.contact_phone_rounded,
            title: 'Emergency contacts',
            subtitle: 'Available offline',
            color: kGreen,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      (1, 'Move away from steep slopes', 'Do not wait below unstable slopes or drainage channels.', kRed),
      (2, 'Follow verified evacuation routes', 'Avoid shortcuts through active red zones.', kOrange),
      (3, 'Keep an emergency go-bag', 'Water, medicine, torch, power bank and identity documents.', kBlue),
      (4, 'Check in with family', 'Use Personal Safety so responders know who is safe.', kGreen),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Guidelines')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          for (final item in data)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: item.$4,
                      foregroundColor: Colors.white,
                      child: Text('${item.$1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(item.$3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
