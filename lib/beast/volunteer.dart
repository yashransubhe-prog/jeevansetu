import 'package:flutter/material.dart';

import 'model.dart';
import 'shared_screens.dart';
import 'widgets.dart';

class VolunteerFieldScreen extends StatelessWidget {
  const VolunteerFieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const GradientHero(
          icon: Icons.volunteer_activism_rounded,
          eyebrow: 'GROUND SUPPORT NETWORK',
          title: 'Help where it\nmatters most.',
          subtitle: 'Verified missions, safe routes and coordinated community support.',
          colors: [kPurple, Color(0xFF9B72F2)],
        ),
        const SectionTitle('Nearby verified tasks', 'Only linked authority / rescue missions are shown'),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IncidentCard(
              incident: incident,
              color: kPurple,
              primaryLabel: incident.volunteerTeam == 'Unassigned' ? 'Accept support task' : 'Accepted',
              onPrimary: () => model.acceptVolunteerTask(incident),
              secondaryLabel: 'Open room',
              onSecondary: () {
                openPage(
                  context,
                  IncidentRoomScreen(incident: incident, role: UserRole.volunteer),
                );
              },
            ),
          ),
        const SectionTitle('Field map', 'Hazards, incidents and verified support corridors'),
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

class VolunteerTasksScreen extends StatelessWidget {
  const VolunteerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    return AppPage(
      children: [
        const PageHeader(
          'Assigned Tasks',
          'Evacuation, household check-in and supply tasks linked to live incidents.',
        ),
        const StoryCard(
          image: 'assets/images/hero_mountain.jpg',
          title: 'Community support corridor',
          subtitle: 'Verified safe route · checkpoint · relief hub',
          badge: 'FIELD',
        ),
        const SizedBox(height: 14),
        for (final incident in model.incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: CircleAvatar(
                  backgroundColor: kPurple.withValues(alpha: .12),
                  child: const Icon(Icons.volunteer_activism_rounded, color: kPurple),
                ),
                title: Text(
                  '${incident.id} · ${incident.location}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  incident.volunteerTeam == 'Unassigned'
                      ? 'Support task available'
                      : 'Assigned to ${incident.volunteerTeam}',
                ),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kPurple),
                  onPressed: () => model.acceptVolunteerTask(incident),
                  child: const Text('Accept'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class VolunteerToolkitScreen extends StatelessWidget {
  const VolunteerToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          'Volunteer Toolkit',
          'Practical ground-support tools for check-in, supplies and coordination.',
        ),
        SettingsTile(
          icon: Icons.fact_check_rounded,
          title: 'Household Check-in',
          subtitle: 'Mark families safe at checkpoints',
          color: kGreen,
          onTap: () => showInfo(
            context,
            'Household Check-in',
            'Checkpoint status updated. The authority and citizen incident timeline can reflect the safe check-in.',
          ),
        ),
        SettingsTile(
          icon: Icons.inventory_2_rounded,
          title: 'Supply Delivery',
          subtitle: 'Confirm food, water and medicine handoff',
          color: kOrange,
          onTap: () => showInfo(
            context,
            'Supply Delivery',
            'Delivery confirmation is ready to be attached to the active incident.',
          ),
        ),
        SettingsTile(
          icon: Icons.badge_rounded,
          title: 'Skills & Availability',
          subtitle: 'First aid · transport · local guide',
          color: kPurple,
          onTap: () => showInfo(
            context,
            'Skills & Availability',
            'Volunteer skills are matched against active incident requirements.',
          ),
        ),
        SettingsTile(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Checkpoint Scan',
          subtitle: 'Prototype household / supply verification',
          color: kBlue,
          onTap: () => showInfo(
            context,
            'Checkpoint Scan',
            'Scan workflow initialized for verified field handoff.',
          ),
        ),
      ],
    );
  }
}
