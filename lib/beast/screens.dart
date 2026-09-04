import 'package:flutter/material.dart';

import 'authority.dart';
import 'citizen.dart';
import 'model.dart';
import 'organization.dart';
import 'rescue.dart';
import 'shared_screens.dart';
import 'volunteer.dart';

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
    final items = _navItems(widget.role);
    final pages = _pages(widget.role);

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          setState(() => index = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

List<_NavItem> _navItems(UserRole role) {
  switch (role) {
    case UserRole.citizen:
      return const [
        _NavItem(Icons.home_rounded, 'Home'),
        _NavItem(Icons.add_alert_rounded, 'Report'),
        _NavItem(Icons.timeline_rounded, 'Incidents'),
        _NavItem(Icons.route_rounded, 'Safety'),
        _NavItem(Icons.grid_view_rounded, 'More'),
      ];
    case UserRole.rescue:
      return const [
        _NavItem(Icons.radar_rounded, 'Command'),
        _NavItem(Icons.assignment_rounded, 'Missions'),
        _NavItem(Icons.forum_rounded, 'Comms'),
        _NavItem(Icons.map_rounded, 'Map'),
        _NavItem(Icons.medical_services_rounded, 'Kit'),
      ];
    case UserRole.authority:
      return const [
        _NavItem(Icons.dashboard_rounded, 'Overview'),
        _NavItem(Icons.fact_check_rounded, 'Verify'),
        _NavItem(Icons.campaign_rounded, 'Broadcast'),
        _NavItem(Icons.map_rounded, 'Map'),
        _NavItem(Icons.admin_panel_settings_rounded, 'Admin'),
      ];
    case UserRole.volunteer:
      return const [
        _NavItem(Icons.explore_rounded, 'Field'),
        _NavItem(Icons.volunteer_activism_rounded, 'Tasks'),
        _NavItem(Icons.forum_rounded, 'Comms'),
        _NavItem(Icons.map_rounded, 'Map'),
        _NavItem(Icons.backpack_rounded, 'Toolkit'),
      ];
    case UserRole.organization:
      return const [
        _NavItem(Icons.hub_rounded, 'Hub'),
        _NavItem(Icons.inbox_rounded, 'Requests'),
        _NavItem(Icons.inventory_2_rounded, 'Inventory'),
        _NavItem(Icons.forum_rounded, 'Comms'),
        _NavItem(Icons.settings_rounded, 'Network'),
      ];
  }
}

List<Widget> _pages(UserRole role) {
  switch (role) {
    case UserRole.citizen:
      return const [
        CitizenHomeScreen(),
        CitizenReportScreen(),
        CitizenIncidentsScreen(),
        CitizenSafetyScreen(),
        CitizenMoreScreen(),
      ];
    case UserRole.rescue:
      return const [
        RescueCommandScreen(),
        RescueMissionsScreen(),
        SharedCommsScreen(role: UserRole.rescue),
        OperationalMapScreen(
          title: 'Rescue Operations Map',
          subtitle: 'Live incident markers, hazards, hospitals and responder route.',
          accent: kRed,
        ),
        RescueKitScreen(),
      ];
    case UserRole.authority:
      return const [
        AuthorityOverviewScreen(),
        AuthorityVerifyScreen(),
        AuthorityBroadcastScreen(),
        OperationalMapScreen(
          title: 'District Command Map',
          subtitle: 'Shared risk perimeter, incident status and safe corridor visibility.',
          accent: kBlue,
        ),
        AuthorityAdminScreen(),
      ];
    case UserRole.volunteer:
      return const [
        VolunteerFieldScreen(),
        VolunteerTasksScreen(),
        SharedCommsScreen(role: UserRole.volunteer),
        OperationalMapScreen(
          title: 'Field Support Map',
          subtitle: 'Verified support route, checkpoints and relief locations.',
          accent: kPurple,
        ),
        VolunteerToolkitScreen(),
      ];
    case UserRole.organization:
      return const [
        OrganizationHubScreen(),
        OrganizationRequestsScreen(),
        OrganizationInventoryScreen(),
        SharedCommsScreen(role: UserRole.organization),
        OrganizationNetworkScreen(),
      ];
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}
