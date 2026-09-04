import 'package:flutter/material.dart';

import 'model.dart';
import 'shared_screens.dart';
import 'widgets.dart';

class AuthorityOverviewScreen extends StatelessWidget {
  const AuthorityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const GradientHero(
          icon: Icons.account_balance_rounded,
          eyebrow: 'DISTRICT COMMAND CENTER',
          title: 'See the district.\nDecide with evidence.',
          subtitle: 'Verified intelligence, escalation, resource command and public warning.',
          colors: [kBlue, kCyan],
        ),
        const SectionTitle('District picture', 'A live operational summary for command decisions'),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.warning_rounded,
                value: '${model.incidents.length}',
                label: 'Active incidents',
                color: kRed,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: MetricCard(
                icon: Icons.verified_rounded,
                value: '94%',
                label: 'Confidence',
                color: kGreen,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: MetricCard(
                icon: Icons.sensors_rounded,
                value: '28',
                label: 'Sensors',
                color: kBlue,
              ),
            ),
          ],
        ),
        const SectionTitle('Verification queue', 'Citizen evidence waiting for authority action'),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IncidentCard(
              incident: incident,
              color: kBlue,
              primaryLabel: incident.verified ? 'Verified' : 'Verify incident',
              onPrimary: () => model.verify(incident),
              secondaryLabel: 'Open room',
              onSecondary: () {
                openPage(
                  context,
                  IncidentRoomScreen(incident: incident, role: UserRole.authority),
                );
              },
            ),
          ),
        const SectionTitle('Command map', 'Hazard zones, incidents and safe corridors'),
        SizedBox(
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: const NepalOperationalMap(showRoute: true),
          ),
        ),
      ],
    );
  }
}

class AuthorityVerifyScreen extends StatelessWidget {
  const AuthorityVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader(
          'Evidence Verification',
          'Fuse citizen evidence with weather, sensors and community reports before escalation.',
        ),
        const StoryCard(
          image: 'assets/images/monitoring_mountain.jpg',
          title: 'Evidence fusion layer',
          subtitle: 'Citizen GPS · soil sensor · rainfall · community match',
          badge: 'AI + HUMAN',
        ),
        const SizedBox(height: 14),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: kBlue.withValues(alpha: .12),
                        child: const Icon(Icons.fact_check_rounded, color: kBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${incident.id} · ${incident.type}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(incident.location),
                  const SizedBox(height: 8),
                  Text(incident.description),
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(value: .94, color: kGreen),
                  const SizedBox(height: 6),
                  const Text(
                    'Verification confidence 94%',
                    style: TextStyle(color: kGreen, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kBlue),
                    onPressed: () => model.verify(incident),
                    icon: const Icon(Icons.verified_rounded),
                    label: Text(incident.verified ? 'Verified' : 'Verify & authorise response'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AuthorityBroadcastScreen extends StatefulWidget {
  const AuthorityBroadcastScreen({super.key});

  @override
  State<AuthorityBroadcastScreen> createState() => _AuthorityBroadcastScreenState();
}

class _AuthorityBroadcastScreenState extends State<AuthorityBroadcastScreen> {
  final TextEditingController controller = TextEditingController(
    text: 'High landslide risk in Ward 8. Avoid exposed slopes and follow verified evacuation routes.',
  );
  bool sent = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Public Warning',
          'Create a targeted, verified area broadcast with visible impact before sending.',
        ),
        const StoryCard(
          image: 'assets/images/hero_mountain.jpg',
          title: 'Ward 8 warning perimeter',
          subtitle: '18,420 devices · 3 safe hubs · 2 blocked roads',
          badge: 'LIVE',
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Broadcast composer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Warning message'),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(child: _ImpactChip(icon: Icons.phone_android_rounded, label: '18.4K devices')),
                  SizedBox(width: 8),
                  Expanded(child: _ImpactChip(icon: Icons.language_rounded, label: '3 languages')),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: kBlue),
                onPressed: () {
                  setState(() => sent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast queued to 18,420 devices')),
                  );
                },
                icon: Icon(sent ? Icons.check_circle_rounded : Icons.campaign_rounded),
                label: Text(sent ? 'Broadcast queued' : 'Broadcast warning'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImpactChip extends StatelessWidget {
  const _ImpactChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBlue.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: kBlue),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorityAdminScreen extends StatelessWidget {
  const AuthorityAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader(
          'Admin & Governance',
          'Auditability, evidence policy and role-based access for responsible response.',
        ),
        SettingsTile(
          icon: Icons.history_rounded,
          title: 'Decision Log',
          subtitle: '${model.events.length} timestamped network events',
          color: kBlue,
          onTap: () {
            showInfo(
              context,
              'Decision Log',
              'Verification, dispatch, rescue, relief and closure actions are timestamped in the shared incident timeline.',
            );
          },
        ),
        SettingsTile(
          icon: Icons.policy_rounded,
          title: 'Evidence Policy',
          subtitle: 'Human review thresholds for critical warnings',
          color: kGreen,
          onTap: () {
            showInfo(
              context,
              'Evidence Policy',
              'Critical alerts require authority verification before public broadcast.',
            );
          },
        ),
        SettingsTile(
          icon: Icons.security_rounded,
          title: 'Access Controls',
          subtitle: 'Citizen · Rescue · Authority · Volunteer · Organization',
          color: kPurple,
          onTap: () {
            showInfo(
              context,
              'Access Controls',
              'Each role can only perform role-appropriate actions while sharing the same incident state.',
            );
          },
        ),
        SettingsTile(
          icon: Icons.check_circle_rounded,
          title: 'Close Completed Incident',
          subtitle: 'Finalize after rescue and relief confirmation',
          color: kOrange,
          onTap: () {
            if (model.incidents.isNotEmpty) {
              model.closeIncident(model.incidents.first);
            }
          },
        ),
      ],
    );
  }
}
