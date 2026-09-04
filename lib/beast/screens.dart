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
    final current = index == 0
        ? pages[0]
        : _RoleWorkspaceFrame(
            role: widget.role,
            tabLabel: items[index].label,
            child: pages[index],
          );

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          setState(() => index = 0);
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(key: ValueKey('${widget.role.name}-$index'), child: current),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon, color: widget.role.color),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleWorkspaceFrame extends StatelessWidget {
  const _RoleWorkspaceFrame({
    required this.role,
    required this.tabLabel,
    required this.child,
  });

  final UserRole role;
  final String tabLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final incident = model.incidents.isNotEmpty ? model.incidents.first : null;
    final background = dark ? const Color(0xFF04171E) : const Color(0xFFF2F7FA);

    return ColoredBox(
      color: background,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: role.color.withValues(alpha: dark ? .10 : .08),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _ConnectedHeader(
                    role: role,
                    tabLabel: tabLabel,
                    incident: incident,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectedHeader extends StatelessWidget {
  const _ConnectedHeader({
    required this.role,
    required this.tabLabel,
    required this.incident,
  });

  final UserRole role;
  final String tabLabel;
  final Incident? incident;

  @override
  Widget build(BuildContext context) {
    final model = AppScope.of(context);
    final stage = incident?.stage ?? IncidentStage.submitted;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF073B49),
            role.color.withValues(alpha: .92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: role.color.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -24,
            child: Icon(role.icon, size: 150, color: Colors.white.withValues(alpha: .08)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(role.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${model.roleName(role)} · $tabLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                            ),
                          ),
                          const Text(
                            'CONNECTED RESPONSE NETWORK',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14C987).withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: const Color(0xFF65F2BE).withValues(alpha: .42)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFF65F2BE)),
                          SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(color: Color(0xFFB8FFE5), fontWeight: FontWeight.w900, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (incident != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: .12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${incident!.id} · ${incident!.type}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              stageLabel(stage).toUpperCase(),
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: .7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(incident!.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        _StageRail(stage: stage),
                        const SizedBox(height: 12),
                        const _FiveRoleRail(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageRail extends StatelessWidget {
  const _StageRail({required this.stage});
  final IncidentStage stage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < IncidentStage.values.length; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: i <= stage.index ? Colors.white : Colors.white24,
              ),
            ),
          ),
          if (i != IncidentStage.values.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _FiveRoleRail extends StatelessWidget {
  const _FiveRoleRail();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final role in UserRole.values)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(role.icon, color: Colors.white, size: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _shortRole(role),
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _shortRole(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.rescue:
        return 'Rescue';
      case UserRole.authority:
        return 'Authority';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.organization:
        return 'Org';
    }
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
