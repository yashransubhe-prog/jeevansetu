import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'model.dart';
import 'shared_screens.dart';
import 'widgets.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final incident = model.incidents.first;
    return AppPage(
      children: [
        const ImageHero(
          image: 'assets/images/hero_mountain.jpg',
          eyebrow: 'NEPAL RISK INTELLIGENCE',
          title: 'Know the slope\nbefore it moves.',
          subtitle: 'AI-assisted warnings, verified incidents and coordinated response in one place.',
          accent: kCyan,
        ),
        const SizedBox(height: 18),
        AlertBanner(
          incident: incident,
          onTap: () => openPage(context, IncidentDetailScreen(incident: incident)),
        ),
        const SectionTitle('Live safety intelligence', 'Current conditions around you'),
        const Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.water_drop_rounded,
                value: '126 mm',
                label: '24h rainfall',
                color: kBlue,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.opacity_rounded,
                value: '87%',
                label: 'Soil saturation',
                color: kCyan,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.shield_rounded,
                value: '18',
                label: 'Safe hubs',
                color: kGreen,
              ),
            ),
          ],
        ),
        const SectionTitle('Quick response', 'Every action opens a working flow'),
        _CitizenActionGrid(incident: incident),
        const SectionTitle('Community pulse', 'Verified signals around your location'),
        const StoryCard(
          image: 'assets/images/monitoring_mountain.jpg',
          title: 'Slope movement reported',
          subtitle: 'Sindhupalchok · AI + community verified',
          badge: '94%',
        ),
      ],
    );
  }
}

class _CitizenActionGrid extends StatelessWidget {
  const _CitizenActionGrid({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_alert_rounded, 'Report incident', kRed, () => openPage(context, const CitizenReportScreen())),
      (Icons.route_rounded, 'Safe route', kGreen, () => openPage(context, const CitizenSafetyScreen())),
      (Icons.timeline_rounded, 'Track incident', kBlue, () => openPage(context, IncidentDetailScreen(incident: incident))),
      (Icons.forum_rounded, 'Response room', kPurple, () => openPage(context, IncidentRoomScreen(incident: incident, role: UserRole.citizen))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: action.$4,
          child: Panel(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: action.$3.withValues(alpha: .12),
                  child: Icon(action.$1, color: action.$3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(action.$2, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CitizenReportScreen extends StatefulWidget {
  const CitizenReportScreen({super.key});

  @override
  State<CitizenReportScreen> createState() => _CitizenReportScreenState();
}

class _CitizenReportScreenState extends State<CitizenReportScreen> {
  final TextEditingController description = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String type = 'Landslide';
  int people = 1;
  bool medical = false;
  XFile? evidence;

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Report Incident',
          'One report instantly becomes visible to every relevant response role.',
        ),
        SizedBox(
          height: 230,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: const NepalOperationalMap(showRoute: false, compact: true),
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Incident type', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in ['Landslide', 'Flood', 'Trapped', 'Medical', 'Road Block'])
                    ChoiceChip(
                      label: Text(value),
                      selected: type == value,
                      onSelected: (selected) {
                        if (selected) setState(() => type = value);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Describe what is happening'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('People needing help', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: people > 1 ? () => setState(() => people -= 1) : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text('$people', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  IconButton(
                    onPressed: () => setState(() => people += 1),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Medical assistance needed', style: TextStyle(fontWeight: FontWeight.w800)),
                value: medical,
                onChanged: (value) => setState(() => medical = value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: kCyan.withValues(alpha: .12),
                  child: const Icon(Icons.photo_camera_rounded, color: kCyan),
                ),
                title: Text(
                  evidence == null ? 'Add photo / video evidence' : 'Evidence attached',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(evidence?.name ?? 'Use camera or gallery'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _chooseEvidence,
              ),
              if (evidence != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(evidence!.path),
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: kRed,
            padding: const EdgeInsets.all(18),
          ),
          onPressed: _submit,
          icon: const Icon(Icons.sos_rounded),
          label: const Text(
            'Send Emergency Report',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseEvidence() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    final file = await picker.pickImage(source: source, imageQuality: 72);
    if (!mounted || file == null) return;
    setState(() => evidence = file);
  }

  void _submit() {
    final model = AppScope.of(context);
    final incident = model.createIncident(
      type: type,
      description: description.text,
      people: people,
      medical: medical,
      evidencePath: evidence?.path,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incident ${incident.id} shared across all five roles')),
    );
    openPage(context, IncidentDetailScreen(incident: incident));
  }
}

class CitizenIncidentsScreen extends StatelessWidget {
  const CitizenIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader('My Incidents', 'Transparent progress from report to recovery.'),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: kRed.withValues(alpha: .12),
                  child: const Icon(Icons.warning_rounded, color: kRed),
                ),
                title: Text(
                  '${incident.id} · ${incident.type}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('${incident.location}\n${stageLabel(incident.stage)}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => openPage(context, IncidentDetailScreen(incident: incident)),
              ),
            ),
          ),
      ],
    );
  }
}

class CitizenSafetyScreen extends StatelessWidget {
  const CitizenSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Safe Route',
          'Live map routing prioritises safety over shortest distance.',
        ),
        SizedBox(
          height: 430,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: const NepalOperationalMap(showRoute: true),
          ),
        ),
        const SizedBox(height: 14),
        const Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safest route selected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kGreen),
              ),
              SizedBox(height: 5),
              Text('6.3 km · 18 min · avoids two active hazard zones and one blocked bridge'),
              SizedBox(height: 14),
              LinearProgressIndicator(value: .72, color: kGreen),
            ],
          ),
        ),
      ],
    );
  }
}

class CitizenMoreScreen extends StatelessWidget {
  const CitizenMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader('More', 'Personal safety, offline readiness and app controls.'),
        SettingsTile(
          icon: Icons.family_restroom_rounded,
          title: 'Personal Safety',
          subtitle: 'Family check-in and live status',
          color: kCyan,
          onTap: () => openPage(context, const PersonalSafetyScreen()),
        ),
        SettingsTile(
          icon: Icons.sensors_rounded,
          title: 'Sensor Network',
          subtitle: 'Rain, soil and slope telemetry',
          color: kBlue,
          onTap: () => openPage(context, const SensorNetworkScreen()),
        ),
        SettingsTile(
          icon: Icons.download_for_offline_rounded,
          title: 'Offline Readiness',
          subtitle: 'Cached emergency pack',
          color: kGreen,
          onTap: () => openPage(context, const OfflineReadinessScreen()),
        ),
        SettingsTile(
          icon: Icons.shield_rounded,
          title: 'Safety Guidelines',
          subtitle: 'Landslide survival checklist',
          color: kOrange,
          onTap: () => openPage(context, const GuidelinesScreen()),
        ),
        Panel(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Applied across every screen and every role'),
            value: model.darkMode,
            onChanged: model.setDarkMode,
          ),
        ),
      ],
    );
  }
}
