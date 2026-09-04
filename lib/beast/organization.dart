import 'package:flutter/material.dart';

import 'model.dart';
import 'shared_screens.dart';
import 'widgets.dart';

class OrganizationHubScreen extends StatelessWidget {
  const OrganizationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const GradientHero(
          icon: Icons.business_rounded,
          eyebrow: 'RELIEF & LOGISTICS HUB',
          title: 'Turn capacity\ninto recovery.',
          subtitle: 'Shelter, medical aid, food, water and transport coordinated in one flow.',
          colors: [kOrange, Color(0xFFFFC15A)],
        ),
        const SectionTitle('Hub capacity', 'Live operational readiness'),
        const Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.bed_rounded,
                value: '84',
                label: 'Beds free',
                color: kGreen,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.medical_services_rounded,
                value: '12',
                label: 'Medical slots',
                color: kRed,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.local_shipping_rounded,
                value: '4',
                label: 'Vehicles',
                color: kOrange,
              ),
            ),
          ],
        ),
        const SectionTitle('Incoming linked incidents', 'Allocate relief against the same incident ID'),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IncidentCard(
              incident: incident,
              color: kOrange,
              primaryLabel: 'Allocate relief',
              onPrimary: () => model.allocateRelief(incident),
              secondaryLabel: 'Response room',
              onSecondary: () {
                openPage(
                  context,
                  IncidentRoomScreen(incident: incident, role: UserRole.organization),
                );
              },
            ),
          ),
        const SectionTitle('Relief network', 'Shelter and medical support closest to the incident'),
        const StoryCard(
          image: 'assets/images/hero_mountain.jpg',
          title: 'Melamchi Relief Hub',
          subtitle: '2.7 km · medical desk active · 84 spaces',
          badge: 'ONLINE',
        ),
      ],
    );
  }
}

class OrganizationRequestsScreen extends StatelessWidget {
  const OrganizationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader(
          'Resource Requests',
          'Requests appear here as rescue and authority actions progress.',
        ),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${incident.id} · ${incident.people} people',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text('${incident.medical ? 'Medical priority · ' : ''}${incident.location}'),
                  const SizedBox(height: 12),
                  Text('Current allocation: ${incident.reliefAllocation}'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kOrange),
                    onPressed: () => model.allocateRelief(incident),
                    icon: const Icon(Icons.inventory_rounded),
                    label: const Text('Reserve shelter + supplies'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class OrganizationInventoryScreen extends StatefulWidget {
  const OrganizationInventoryScreen({super.key});

  @override
  State<OrganizationInventoryScreen> createState() => _OrganizationInventoryScreenState();
}

class _OrganizationInventoryScreenState extends State<OrganizationInventoryScreen> {
  int water = 320;
  int food = 240;
  int medical = 78;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Inventory',
          'Issue stock to simulate real resource movement during a response.',
        ),
        _InventoryPanel(
          title: 'Water kits',
          icon: Icons.water_drop_rounded,
          value: water,
          max: 500,
          color: kBlue,
          onIssue: () => setState(() => water = (water - 10).clamp(0, 500)),
        ),
        _InventoryPanel(
          title: 'Food packs',
          icon: Icons.restaurant_rounded,
          value: food,
          max: 400,
          color: kOrange,
          onIssue: () => setState(() => food = (food - 10).clamp(0, 400)),
        ),
        _InventoryPanel(
          title: 'Medical kits',
          icon: Icons.medical_services_rounded,
          value: medical,
          max: 120,
          color: kRed,
          onIssue: () => setState(() => medical = (medical - 5).clamp(0, 120)),
        ),
        const StoryCard(
          image: 'assets/images/monitoring_mountain.jpg',
          title: 'District supply corridor',
          subtitle: '4 vehicles · 3 hubs · hospital handoff active',
          badge: 'SYNCED',
        ),
      ],
    );
  }
}

class _InventoryPanel extends StatelessWidget {
  const _InventoryPanel({
    required this.title,
    required this.icon,
    required this.value,
    required this.max,
    required this.color,
    required this.onIssue,
  });

  final String title;
  final IconData icon;
  final int value;
  final int max;
  final Color color;
  final VoidCallback onIssue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: .12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '$value / $max',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: value / max, color: color),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onIssue,
              icon: const Icon(Icons.remove_circle_outline_rounded),
              label: const Text('Issue stock'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizationNetworkScreen extends StatelessWidget {
  const OrganizationNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Organization Network',
          'Partner, transport and shelter controls for recovery operations.',
        ),
        SettingsTile(
          icon: Icons.home_work_rounded,
          title: 'Shelter Registry',
          subtitle: '3 hubs online · 146 spaces available',
          color: kGreen,
          onTap: () => showInfo(
            context,
            'Shelter Registry',
            'Melamchi Relief Hub, District School Shelter and Community Hall are online.',
          ),
        ),
        SettingsTile(
          icon: Icons.local_shipping_rounded,
          title: 'Transport Fleet',
          subtitle: '4 response vehicles available',
          color: kOrange,
          onTap: () => showInfo(
            context,
            'Transport Fleet',
            'Vehicle O-04 reserved for medical transfer. Three vehicles remain available.',
          ),
        ),
        SettingsTile(
          icon: Icons.handshake_rounded,
          title: 'Partner Network',
          subtitle: 'District Hospital + 4 NGOs online',
          color: kBlue,
          onTap: () => showInfo(
            context,
            'Partner Network',
            'Hospital, local NGO and community partners are connected to the same incident network.',
          ),
        ),
        SettingsTile(
          icon: Icons.phone_in_talk_rounded,
          title: 'Call District Hospital',
          subtitle: 'Open in-app voice channel',
          color: kRed,
          onTap: () {
            openPage(
              context,
              const CallScreen(
                title: 'District Hospital Medical Desk',
                video: false,
                color: kOrange,
              ),
            );
          },
        ),
        SettingsTile(
          icon: Icons.video_call_rounded,
          title: 'Video Relief Coordination',
          subtitle: 'Open in-app video channel',
          color: kPurple,
          onTap: () {
            openPage(
              context,
              const CallScreen(
                title: 'Relief Coordination Video',
                video: true,
                color: kOrange,
              ),
            );
          },
        ),
      ],
    );
  }
}
