import 'package:flutter/material.dart';

import 'model.dart';
import 'shared_screens.dart';
import 'widgets.dart';

class RescueCommandScreen extends StatelessWidget {
  const RescueCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final incident = model.incidents.first;
    final recentEvents = model.events.reversed.take(5).toList();

    return AppPage(
      children: [
        const ImageHero(
          image: 'assets/images/rescue_diver.jpg',
          eyebrow: 'RESCUE FIELD COMMAND',
          title: 'Rescue operations\nin motion.',
          subtitle: 'Triage, dispatch, live routing and responder coordination.',
          accent: kRed,
        ),
        const SectionTitle('Priority incident', 'Shared directly from the citizen response network'),
        IncidentCard(
          incident: incident,
          color: kRed,
          primaryLabel: 'Dispatch team',
          onPrimary: () => model.dispatch(incident),
          secondaryLabel: 'Open room',
          onSecondary: () {
            openPage(
              context,
              IncidentRoomScreen(incident: incident, role: UserRole.rescue),
            );
          },
        ),
        const SectionTitle('Operational picture', 'Live incident, hazard and safe-route awareness'),
        SizedBox(
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: const NepalOperationalMap(showRoute: true),
          ),
        ),
        const SectionTitle('Field controls', 'Fast actions for the active mission'),
        _RescueControls(incident: incident),
        const SectionTitle('Live operations stream', 'Changes requiring responder attention'),
        for (final event in recentEvents) TimelineTile(event: event),
      ],
    );
  }
}

class _RescueControls extends StatelessWidget {
  const _RescueControls({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final actions = [
      (Icons.local_shipping_rounded, 'Dispatch', kRed, () => model.dispatch(incident)),
      (Icons.location_on_rounded, 'On site', kOrange, () => model.markOnSite(incident)),
      (Icons.health_and_safety_rounded, 'Rescued', kGreen, () => model.markRescued(incident)),
      (Icons.videocam_rounded, 'Video link', kBlue, () {
        openPage(
          context,
          CallScreen(
            title: '${incident.id} Rescue Video',
            video: true,
            color: kRed,
          ),
        );
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: action.$4,
          borderRadius: BorderRadius.circular(22),
          child: Panel(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: action.$3.withValues(alpha: .12),
                  child: Icon(action.$1, color: action.$3),
                ),
                const SizedBox(width: 10),
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

class RescueMissionsScreen extends StatelessWidget {
  const RescueMissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader('Missions', 'Move every incident from dispatch to rescue completion.'),
        const StoryCard(
          image: 'assets/images/monitoring_mountain.jpg',
          title: 'Aerial reconnaissance corridor',
          subtitle: 'Slope visibility · route access · hospital handoff',
          badge: 'LIVE',
        ),
        const SizedBox(height: 14),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${incident.id} · ${incident.type}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(incident.location),
                  const SizedBox(height: 12),
                  IncidentProgress(stage: incident.stage),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: kRed),
                        onPressed: () => model.dispatch(incident),
                        child: const Text('Dispatch'),
                      ),
                      OutlinedButton(
                        onPressed: () => model.markOnSite(incident),
                        child: const Text('Reached'),
                      ),
                      OutlinedButton(
                        onPressed: () => model.markRescued(incident),
                        child: const Text('Rescued'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          openPage(
                            context,
                            IncidentRoomScreen(incident: incident, role: UserRole.rescue),
                          );
                        },
                        icon: const Icon(Icons.forum_rounded),
                        label: const Text('Room'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class RescueKitScreen extends StatelessWidget {
  const RescueKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader('Responder Kit', 'Field tools for low-connectivity emergency operations.'),
        SettingsTile(
          icon: Icons.medical_services_rounded,
          title: 'Triage Protocol',
          subtitle: 'START triage quick reference',
          color: kRed,
          onTap: () => showInfo(
            context,
            'Triage Protocol',
            'Airway → breathing → circulation → mobility → priority marking.',
          ),
        ),
        SettingsTile(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Patient / Asset Scan',
          subtitle: 'QR handoff workflow',
          color: kOrange,
          onTap: () => showInfo(
            context,
            'Patient / Asset Scan',
            'Prototype scan initialized. Use one incident ID across rescue and hospital handoff.',
          ),
        ),
        SettingsTile(
          icon: Icons.sensors_rounded,
          title: 'Field Sensor Link',
          subtitle: 'Pair portable rain and slope nodes',
          color: kCyan,
          onTap: () => showInfo(
            context,
            'Field Sensor Link',
            'Nearby portable telemetry node detected for pairing.',
          ),
        ),
        SettingsTile(
          icon: Icons.offline_bolt_rounded,
          title: 'Offline Responder Pack',
          subtitle: 'Maps, contacts and triage cached',
          color: kGreen,
          onTap: () => showInfo(
            context,
            'Offline Responder Pack',
            'Responder emergency pack is cached for weak-network operations.',
          ),
        ),
      ],
    );
  }
}
