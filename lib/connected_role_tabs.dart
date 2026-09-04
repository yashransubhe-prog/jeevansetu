import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _navy = Color(0xFF073C4D);
const _deep = Color(0xFF041E27);
const _red = Color(0xFFFF3B55);
const _green = Color(0xFF20C98A);
const _orange = Color(0xFFFFA42E);
const _blue = Color(0xFF4387F4);
const _purple = Color(0xFF7758DF);
const _ink = Color(0xFF102027);

class NetworkIncident {
  final String id;
  final String title;
  final String source;
  final String location;
  final int priority;
  final String status;
  final String assignedTo;
  final DateTime createdAt;
  final int progress;

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
  });

  NetworkIncident copyWith({
    String? status,
    String? assignedTo,
    int? progress,
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
    );
  }
}

class NetworkEvent {
  final String incidentId;
  final String role;
  final String text;
  final DateTime time;
  final Color color;

  const NetworkEvent({
    required this.incidentId,
    required this.role,
    required this.text,
    required this.time,
    required this.color,
  });
}

class NetworkMessage {
  final String incidentId;
  final String sender;
  final String text;
  final DateTime time;

  const NetworkMessage({
    required this.incidentId,
    required this.sender,
    required this.text,
    required this.time,
  });
}

class JeevanNetwork {
  JeevanNetwork._();
  static final instance = JeevanNetwork._();

  final ValueNotifier<List<NetworkIncident>> incidents = ValueNotifier([
    NetworkIncident(
      id: 'JS-2481',
      title: 'Family trapped near unstable slope',
      source: 'Citizen SOS',
      location: 'Sindhupalchok · Ward 8',
      priority: 5,
      status: 'Triage required',
      assignedTo: 'Unassigned',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      progress: 18,
    ),
    NetworkIncident(
      id: 'JS-2477',
      title: 'Road blocked by falling debris',
      source: 'Citizen report',
      location: 'Araniko Highway · KM 44',
      priority: 4,
      status: 'Verified by authority',
      assignedTo: 'Volunteer Alpha',
      createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
      progress: 48,
    ),
  ]);

  final ValueNotifier<List<NetworkEvent>> events = ValueNotifier([
    NetworkEvent(
      incidentId: 'JS-2481',
      role: 'Citizen',
      text: 'SOS submitted with live location',
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      color: _blue,
    ),
    NetworkEvent(
      incidentId: 'JS-2481',
      role: 'System',
      text: 'Risk engine matched red-zone overlap · 94%',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      color: _purple,
    ),
    NetworkEvent(
      incidentId: 'JS-2477',
      role: 'Authority',
      text: 'Road blockage verified from 3 evidence sources',
      time: DateTime.now().subtract(const Duration(minutes: 8)),
      color: _blue,
    ),
  ]);

  final ValueNotifier<List<NetworkMessage>> messages = ValueNotifier([
    NetworkMessage(
      incidentId: 'JS-2481',
      sender: 'Citizen',
      text: 'Two people are trapped. We can hear falling rocks.',
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    NetworkMessage(
      incidentId: 'JS-2481',
      sender: 'Rescue Team',
      text: 'SOS received. Keep away from the exposed slope.',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    NetworkMessage(
      incidentId: 'JS-2481',
      sender: 'Authority',
      text: 'Ward 8 corridor is being verified for evacuation.',
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ]);

  void reportCitizenIncident(String title) {
    final id = 'JS-${2500 + incidents.value.length + 1}';
    incidents.value = [
      NetworkIncident(
        id: id,
        title: title,
        source: 'Citizen report',
        location: 'Sindhupalchok · live location',
        priority: 5,
        status: 'New · needs verification',
        assignedTo: 'Unassigned',
        createdAt: DateTime.now(),
        progress: 8,
      ),
      ...incidents.value,
    ];
    addEvent(id, 'Citizen', 'New incident shared to every response role', _blue);
    addMessage(id, 'Citizen', 'Incident submitted from citizen app with live location.');
  }

  void update(
    String id, {
    String? status,
    String? assignedTo,
    int? progress,
  }) {
    incidents.value = [
      for (final item in incidents.value)
        if (item.id == id)
          item.copyWith(
            status: status,
            assignedTo: assignedTo,
            progress: progress,
          )
        else
          item,
    ];
  }

  void addEvent(String id, String role, String text, Color color) {
    events.value = [
      NetworkEvent(
        incidentId: id,
        role: role,
        text: text,
        time: DateTime.now(),
        color: color,
      ),
      ...events.value,
    ];
  }

  void addMessage(String id, String sender, String text) {
    messages.value = [
      NetworkMessage(
        incidentId: id,
        sender: sender,
        text: text,
        time: DateTime.now(),
      ),
      ...messages.value,
    ];
  }

  void act(String role, NetworkIncident incident) {
    switch (role) {
      case 'Rescue Team':
        update(
          incident.id,
          status: 'Rescue dispatched · ETA 8 min',
          assignedTo: 'Rescue Unit 04',
          progress: incident.progress < 42 ? 42 : incident.progress,
        );
        addEvent(incident.id, role, 'Unit 04 dispatched through safest corridor', _red);
        addMessage(incident.id, role, 'Unit 04 is en route. ETA 8 minutes.');
        break;
      case 'Authority':
        update(
          incident.id,
          status: 'Verified · public warning active',
          assignedTo: 'District EOC',
          progress: incident.progress < 32 ? 32 : incident.progress,
        );
        addEvent(incident.id, role, 'Incident verified and warning perimeter activated', _blue);
        addMessage(incident.id, role, 'Incident verified. Evacuation corridor is active.');
        break;
      case 'Volunteer':
        update(
          incident.id,
          status: 'Ground support assigned',
          assignedTo: 'Volunteer Alpha',
          progress: incident.progress < 60 ? 60 : incident.progress,
        );
        addEvent(incident.id, role, 'Volunteer Alpha assigned for family support', _purple);
        addMessage(incident.id, role, 'Volunteer team ready at the safe assembly point.');
        break;
      case 'Organization':
        update(
          incident.id,
          status: 'Shelter + medical capacity reserved',
          assignedTo: 'Melamchi Relief Hub',
          progress: incident.progress < 72 ? 72 : incident.progress,
        );
        addEvent(incident.id, role, '2 shelter spaces and medical desk reserved', _orange);
        addMessage(incident.id, role, 'Relief hub has reserved beds, food and medical support.');
        break;
    }
  }
}

String _age(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  return '${d.inHours} h';
}

String _roleVerb(String role) => switch (role) {
      'Rescue Team' => 'Dispatch',
      'Authority' => 'Verify',
      'Volunteer' => 'Accept task',
      'Organization' => 'Reserve resources',
      _ => 'Acknowledge',
    };

IconData _roleIcon(String role) => switch (role) {
      'Rescue Team' => Icons.health_and_safety_rounded,
      'Authority' => Icons.account_balance_rounded,
      'Volunteer' => Icons.volunteer_activism_rounded,
      'Organization' => Icons.apartment_rounded,
      _ => Icons.hub_rounded,
    };

String _roleOpsTitle(String role) => switch (role) {
      'Rescue Team' => 'Live Missions',
      'Authority' => 'District Command',
      'Volunteer' => 'Field Missions',
      'Organization' => 'Relief Logistics',
      _ => 'Operations',
    };

String _roleOpsSubtitle(String role) => switch (role) {
      'Rescue Team' => 'Triage · dispatch · route · rescue hand-off',
      'Authority' => 'Verify · warn · coordinate · audit',
      'Volunteer' => 'Accept · navigate · check-in · assist',
      'Organization' => 'Shelter · medical · food · transport',
      _ => 'Connected response network',
    };

List<(String, String)> _roleMetrics(String role) => switch (role) {
      'Rescue Team' => [('7', 'ACTIVE'), ('8 min', 'ETA'), ('3', 'UNITS')],
      'Authority' => [('3', 'CRITICAL'), ('94%', 'VERIFIED'), ('28', 'SENSORS')],
      'Volunteer' => [('12', 'TASKS'), ('31', 'READY'), ('4', 'ZONES')],
      'Organization' => [('18', 'HUBS'), ('84', 'BEDS'), ('92%', 'STOCK')],
      _ => [('3', 'ACTIVE'), ('94%', 'CONF.'), ('18', 'HUBS')],
    };

List<(IconData, String, String)> _roleQuickActions(String role) => switch (role) {
      'Rescue Team' => [
          (Icons.sos_rounded, 'Triage', 'Prioritise SOS'),
          (Icons.route_rounded, 'Safe corridor', 'Open responder route'),
          (Icons.air_rounded, 'Aerial scan', 'Request reconnaissance'),
          (Icons.local_hospital_rounded, 'Medical', 'Prepare transfer'),
        ],
      'Authority' => [
          (Icons.campaign_rounded, 'Broadcast', 'Send area warning'),
          (Icons.fact_check_rounded, 'Verify', 'Review citizen evidence'),
          (Icons.hexagon_outlined, 'Risk zone', 'Update perimeter'),
          (Icons.groups_rounded, 'Resources', 'Reallocate capacity'),
        ],
      'Volunteer' => [
          (Icons.assignment_turned_in_rounded, 'Accept task', 'Join field mission'),
          (Icons.family_restroom_rounded, 'Check-in', 'Assist households'),
          (Icons.inventory_2_rounded, 'Deliver', 'Move relief supplies'),
          (Icons.photo_camera_rounded, 'Evidence', 'Upload verified photo'),
        ],
      'Organization' => [
          (Icons.bed_rounded, 'Shelter', 'Allocate safe spaces'),
          (Icons.medical_services_rounded, 'Medical desk', 'Open treatment capacity'),
          (Icons.local_shipping_rounded, 'Dispatch', 'Send supplies'),
          (Icons.inventory_rounded, 'Inventory', 'Update live stock'),
        ],
      _ => [],
    };

class ConnectedOperationsTab extends StatefulWidget {
  final String roleName;
  final Color accent;
  final Color secondary;
  final Color background;
  final bool dark;

  const ConnectedOperationsTab({
    super.key,
    required this.roleName,
    required this.accent,
    required this.secondary,
    required this.background,
    required this.dark,
  });

  @override
  State<ConnectedOperationsTab> createState() => _ConnectedOperationsTabState();
}

class _ConnectedOperationsTabState extends State<ConnectedOperationsTab> {
  int selected = 0;
  int livePulse = 0;
  Timer? timer;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => livePulse++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : _ink;
    final sub = widget.dark ? Colors.white60 : Colors.black54;
    final metrics = _roleMetrics(widget.roleName);
    final actions = _roleQuickActions(widget.roleName);

    return SafeArea(
      child: Material(
        color: widget.background,
        child: ValueListenableBuilder<List<NetworkIncident>>(
          valueListenable: JeevanNetwork.instance.incidents,
          builder: (context, incidents, _) {
            final safeIndex = selected.clamp(0, incidents.length - 1);
            final active = incidents[safeIndex];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: _TopHeader(
                      title: _roleOpsTitle(widget.roleName),
                      subtitle: _roleOpsSubtitle(widget.roleName),
                      accent: widget.accent,
                      fg: fg,
                      pulse: livePulse,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (var i = 0; i < metrics.length; i++) ...[
                          Expanded(
                            child: _MetricTile(
                              value: metrics[i].$1,
                              label: metrics[i].$2,
                              accent: i == 0 ? widget.accent : (i == 1 ? widget.secondary : _green),
                              dark: widget.dark,
                            ),
                          ),
                          if (i != metrics.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    height: 330,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.13),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(27.86, 85.58),
                            initialZoom: 10.1,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.jeevansetu',
                            ),
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: const [
                                    LatLng(27.92, 85.50),
                                    LatLng(27.96, 85.60),
                                    LatLng(27.89, 85.69),
                                    LatLng(27.82, 85.61),
                                    LatLng(27.84, 85.52),
                                  ],
                                  color: _red.withOpacity(.18),
                                  borderColor: _red,
                                  borderStrokeWidth: 2.5,
                                ),
                              ],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: const [
                                    LatLng(27.80, 85.50),
                                    LatLng(27.83, 85.54),
                                    LatLng(27.86, 85.57),
                                    LatLng(27.90, 85.63),
                                  ],
                                  strokeWidth: 6,
                                  color: _green,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: const LatLng(27.89, 85.58),
                                  width: 50,
                                  height: 50,
                                  child: const _MapPin(color: _red, icon: Icons.sos_rounded),
                                ),
                                Marker(
                                  point: const LatLng(27.82, 85.52),
                                  width: 50,
                                  height: 50,
                                  child: _MapPin(color: widget.accent, icon: _roleIcon(widget.roleName)),
                                ),
                                const Marker(
                                  point: LatLng(27.90, 85.64),
                                  width: 50,
                                  height: 50,
                                  child: _MapPin(color: _green, icon: Icons.home_work_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: _GlassPill(
                            text: '${active.id} · P${active.priority} · LIVE',
                            color: widget.accent,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Column(
                            children: [
                              _MapButton(
                                icon: Icons.my_location_rounded,
                                onTap: () => mapController.move(const LatLng(27.86, 85.58), 10.1),
                              ),
                              const SizedBox(height: 8),
                              _MapButton(
                                icon: Icons.route_rounded,
                                onTap: () => _toast(context, 'Safest operational corridor selected'),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: _MapIncidentOverlay(
                            incident: active,
                            accent: widget.accent,
                            roleName: widget.roleName,
                            onAction: () => JeevanNetwork.instance.act(widget.roleName, active),
                            onCall: () => _openCall(context, active, widget.accent, true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    child: _SectionTitle(
                      title: '${widget.roleName} controls',
                      subtitle: 'Actions are written to the same incident timeline',
                      fg: fg,
                      sub: sub,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 126,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: actions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final a = actions[i];
                        return _ActionTile(
                          icon: a.$1,
                          title: a.$2,
                          subtitle: a.$3,
                          accent: i.isEven ? widget.accent : widget.secondary,
                          dark: widget.dark,
                          onTap: () {
                            if (a.$2 == _roleVerb(widget.roleName) || i == 0) {
                              JeevanNetwork.instance.act(widget.roleName, active);
                            }
                            _toast(context, '${a.$2} opened for ${active.id}');
                          },
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    child: _SectionTitle(
                      title: 'Shared response queue',
                      subtitle: 'Citizen report → verification → rescue → support → relief',
                      fg: fg,
                      sub: sub,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  sliver: SliverList.builder(
                    itemCount: incidents.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IncidentCard(
                        incident: incidents[i],
                        roleName: widget.roleName,
                        accent: widget.accent,
                        dark: widget.dark,
                        selected: i == safeIndex,
                        onTap: () => setState(() => selected = i),
                        onAction: () => JeevanNetwork.instance.act(widget.roleName, incidents[i]),
                        onCall: () => _openCall(context, incidents[i], widget.accent, true),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    child: _HandoffRail(
                      incident: active,
                      accent: widget.accent,
                      dark: widget.dark,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ConnectedCommunicationsTab extends StatefulWidget {
  final String roleName;
  final Color accent;
  final Color secondary;
  final Color background;
  final bool dark;

  const ConnectedCommunicationsTab({
    super.key,
    required this.roleName,
    required this.accent,
    required this.secondary,
    required this.background,
    required this.dark,
  });

  @override
  State<ConnectedCommunicationsTab> createState() => _ConnectedCommunicationsTabState();
}

class _ConnectedCommunicationsTabState extends State<ConnectedCommunicationsTab> {
  int pulse = 0;
  Timer? timer;
  final TextEditingController message = TextEditingController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => pulse++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    message.dispose();
    super.dispose();
  }

  List<String> get rooms => switch (widget.roleName) {
        'Rescue Team' => ['Field Command', 'Medical Desk', 'Citizen SOS'],
        'Authority' => ['District Command', 'Ward Officers', 'Public Information Cell'],
        'Volunteer' => ['Volunteer Alpha', 'Assembly Point', 'Relief Dispatch'],
        'Organization' => ['Relief Hub', 'Hospital Desk', 'Transport Partner'],
        _ => ['Response Network'],
      };

  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : _ink;
    final sub = widget.dark ? Colors.white60 : Colors.black54;
    return SafeArea(
      child: Material(
        color: widget.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TopHeader(
              title: 'Live Communications',
              subtitle: 'Voice · video · chat · incident rooms',
              accent: widget.accent,
              fg: fg,
              pulse: pulse,
            ),
            const SizedBox(height: 14),
            Container(
              height: 178,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.accent, widget.secondary],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -14,
                    top: -20,
                    child: Icon(Icons.wifi_tethering_rounded, size: 150, color: Colors.white.withOpacity(.10)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GlassPill(text: 'ENCRYPTED RESPONSE MESH', color: Colors.white),
                      const Spacer(),
                      Text(
                        '${12 + pulse % 4} responders connected',
                        style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Voice 42 ms · video stable · offline radio fallback ready',
                        style: TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: '${widget.roleName} channels', subtitle: 'Call any operational partner without leaving the incident', fg: fg, sub: sub),
            const SizedBox(height: 8),
            ...rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChannelCard(
                  title: room,
                  accent: widget.accent,
                  dark: widget.dark,
                  onVoice: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NetworkCallPage(title: room, color: widget.accent, video: false))),
                  onVideo: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NetworkCallPage(title: room, color: widget.accent, video: true))),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<NetworkIncident>>(
              valueListenable: JeevanNetwork.instance.incidents,
              builder: (context, incidents, _) {
                final active = incidents.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: '${active.id} response room', subtitle: active.title, fg: fg, sub: sub),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.dark ? const Color(0xFF102A33) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: widget.dark ? Colors.white10 : const Color(0xFFE0EAED)),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder<List<NetworkMessage>>(
                            valueListenable: JeevanNetwork.instance.messages,
                            builder: (context, messages, _) {
                              final relevant = messages.where((m) => m.incidentId == active.id).take(5).toList().reversed.toList();
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                                child: Column(
                                  children: [
                                    for (final item in relevant)
                                      _MessageBubble(message: item, accent: widget.accent, dark: widget.dark),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: message,
                                    style: TextStyle(color: fg, fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Send operational update...',
                                      hintStyle: TextStyle(color: sub),
                                      filled: true,
                                      fillColor: widget.dark ? Colors.white.withOpacity(.06) : const Color(0xFFF3F8FA),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  style: IconButton.styleFrom(backgroundColor: widget.accent),
                                  onPressed: () {
                                    final text = message.text.trim();
                                    if (text.isEmpty) return;
                                    JeevanNetwork.instance.addMessage(active.id, widget.roleName, text);
                                    JeevanNetwork.instance.addEvent(active.id, widget.roleName, 'Posted response-room update', widget.accent);
                                    message.clear();
                                  },
                                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class ConnectedIntelligenceTab extends StatefulWidget {
  final String roleName;
  final Color accent;
  final Color secondary;
  final Color background;
  final bool dark;

  const ConnectedIntelligenceTab({
    super.key,
    required this.roleName,
    required this.accent,
    required this.secondary,
    required this.background,
    required this.dark,
  });

  @override
  State<ConnectedIntelligenceTab> createState() => _ConnectedIntelligenceTabState();
}

class _ConnectedIntelligenceTabState extends State<ConnectedIntelligenceTab> {
  bool explain = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : _ink;
    final sub = widget.dark ? Colors.white60 : Colors.black54;
    return SafeArea(
      child: Material(
        color: widget.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TopHeader(title: 'Operational Intelligence', subtitle: 'AI + human evidence · explainable and role-aware', accent: widget.accent, fg: fg, pulse: 1),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(colors: [widget.accent, widget.secondary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('AI SLOPE SENTINEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const _RiskRing(value: 78),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('High landslide probability', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            const Text('Rainfall + soil saturation + slope movement are driving the score.', style: TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.35)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              style: TextButton.styleFrom(foregroundColor: Colors.white, padding: EdgeInsets.zero),
                              onPressed: () => setState(() => explain = !explain),
                              icon: const Icon(Icons.psychology_alt_rounded, size: 18),
                              label: Text(explain ? 'Hide explanation' : 'Why this score?'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: explain ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.14), borderRadius: BorderRadius.circular(16)),
                      child: const Text('42% rainfall intensity · 31% soil saturation · 17% slope movement · 10% historical susceptibility. Human evidence increases confidence by 4%.', style: TextStyle(color: Colors.white, fontSize: 10.5, height: 1.4)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SignalCard(icon: Icons.water_drop_rounded, value: '126 mm', label: '24H RAIN', color: _blue, dark: widget.dark)),
                const SizedBox(width: 8),
                Expanded(child: _SignalCard(icon: Icons.waves_rounded, value: '87%', label: 'SOIL SAT.', color: _red, dark: widget.dark)),
                const SizedBox(width: 8),
                Expanded(child: _SignalCard(icon: Icons.show_chart_rounded, value: '2.8 mm', label: 'MOVEMENT', color: _orange, dark: widget.dark)),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Evidence fusion', subtitle: 'Sensor, weather, citizen and response-team observations', fg: fg, sub: sub),
            const SizedBox(height: 8),
            _EvidenceCard(title: 'Citizen evidence verified', subtitle: '2 reports match sensor + rainfall pattern', confidence: 94, color: _green, dark: widget.dark),
            const SizedBox(height: 9),
            _EvidenceCard(title: 'Route intelligence changed', subtitle: 'Araniko corridor slower but outside active red zone', confidence: 81, color: _orange, dark: widget.dark),
            const SizedBox(height: 9),
            _EvidenceCard(title: 'Soil probe anomaly', subtitle: 'SM-12 crossed critical saturation threshold', confidence: 88, color: _red, dark: widget.dark),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Shared incident timeline', subtitle: 'Every role sees the same chain of action', fg: fg, sub: sub),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<NetworkEvent>>(
              valueListenable: JeevanNetwork.instance.events,
              builder: (context, events, _) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.dark ? const Color(0xFF102A33) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: widget.dark ? Colors.white10 : const Color(0xFFE0EAED)),
                  ),
                  child: Column(
                    children: [
                      for (final event in events.take(7)) _TimelineRow(event: event, dark: widget.dark),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class ConnectedToolkitTab extends StatelessWidget {
  final String roleName;
  final Color accent;
  final Color secondary;
  final Color background;
  final bool dark;

  const ConnectedToolkitTab({
    super.key,
    required this.roleName,
    required this.accent,
    required this.secondary,
    required this.background,
    required this.dark,
  });

  List<(IconData, String, String)> get tools => switch (roleName) {
        'Rescue Team' => [
            (Icons.medical_services_rounded, 'Triage protocol', 'Guided casualty priority'),
            (Icons.qr_code_scanner_rounded, 'Patient scan', 'Create rescue hand-off'),
            (Icons.offline_bolt_rounded, 'Offline responder pack', 'Maps + protocol cached'),
            (Icons.sensors_rounded, 'Field sensor link', 'Pair temporary sensor'),
            (Icons.air_rounded, 'Drone request', 'Queue aerial reconnaissance'),
            (Icons.route_rounded, 'Responder route', 'Safest live corridor'),
          ],
        'Authority' => [
            (Icons.campaign_rounded, 'Broadcast studio', 'Publish geo-targeted alert'),
            (Icons.fact_check_rounded, 'Evidence policy', 'Verification rules'),
            (Icons.history_rounded, 'Decision log', 'Auditable command history'),
            (Icons.admin_panel_settings_rounded, 'Access control', 'Role permissions'),
            (Icons.hexagon_outlined, 'Zone editor', 'Update risk perimeter'),
            (Icons.analytics_rounded, 'District analytics', 'Population + impact view'),
          ],
        'Volunteer' => [
            (Icons.badge_rounded, 'Volunteer ID', 'Verified responder profile'),
            (Icons.qr_code_scanner_rounded, 'Checkpoint scan', 'Proof of arrival'),
            (Icons.inventory_2_rounded, 'Supply manifest', 'Delivery checklist'),
            (Icons.family_restroom_rounded, 'Family check-in', 'Mark household safe'),
            (Icons.translate_rounded, 'Language assist', 'Local communication aid'),
            (Icons.offline_pin_rounded, 'Offline mission', 'Task + map cached'),
          ],
        'Organization' => [
            (Icons.bed_rounded, 'Shelter capacity', 'Beds and occupancy'),
            (Icons.inventory_rounded, 'Live inventory', 'Food, water, medicine'),
            (Icons.local_shipping_rounded, 'Fleet dispatch', 'Vehicles and drivers'),
            (Icons.medical_services_rounded, 'Medical desk', 'Beds + ambulance'),
            (Icons.qr_code_scanner_rounded, 'Relief voucher', 'Secure distribution'),
            (Icons.handshake_rounded, 'Partner network', 'Cross-org requests'),
          ],
        _ => [],
      };

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : _ink;
    final sub = dark ? Colors.white60 : Colors.black54;
    return SafeArea(
      child: Material(
        color: background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TopHeader(title: '$roleName Toolkit', subtitle: 'Field-ready tools connected to live incidents', accent: accent, fg: fg, pulse: 2),
            const SizedBox(height: 14),
            _ToolkitHero(roleName: roleName, accent: accent, secondary: secondary),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, i) {
                final tool = tools[i];
                return _ToolCard(
                  icon: tool.$1,
                  title: tool.$2,
                  subtitle: tool.$3,
                  accent: i.isEven ? accent : secondary,
                  dark: dark,
                  onTap: () {
                    if (tool.$2.contains('route') || tool.$2.contains('Route')) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SharedSafeRoutePage(accent: accent, dark: dark)));
                    } else if (tool.$2.contains('scan') || tool.$2.contains('Scan')) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FieldScannerPage(accent: accent, title: tool.$2)));
                    } else {
                      _toast(context, '${tool.$2} synchronized with JeevanSetu network');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Network readiness', subtitle: 'One incident · every role · one synchronized state', fg: fg, sub: sub),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<NetworkIncident>>(
              valueListenable: JeevanNetwork.instance.incidents,
              builder: (context, incidents, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF102A33) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE0EAED)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.hub_rounded, color: accent),
                          const SizedBox(width: 10),
                          Expanded(child: Text('${incidents.length} incidents synchronized', style: TextStyle(color: fg, fontWeight: FontWeight.w900))),
                          const _LivePill(color: _green),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(value: .96, minHeight: 7, borderRadius: BorderRadius.circular(20), color: _green, backgroundColor: _green.withOpacity(.12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Citizen · Rescue · Authority · Volunteer · Organization', style: TextStyle(color: sub, fontSize: 8.8)),
                          Text('96% mesh health', style: TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class NetworkCallPage extends StatefulWidget {
  final String title;
  final Color color;
  final bool video;

  const NetworkCallPage({
    super.key,
    required this.title,
    required this.color,
    required this.video,
  });

  @override
  State<NetworkCallPage> createState() => _NetworkCallPageState();
}

class _NetworkCallPageState extends State<NetworkCallPage> {
  bool muted = false;
  bool camera = true;
  bool speaker = true;
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: _deep,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.video && camera
                  ? Image.network(
                      'https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=900',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B4352)),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B5265), _deep],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(widget.video ? .35 : .10))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white)),
                      const Spacer(),
                      const _GlassPill(text: 'SECURE RESPONSE CHANNEL', color: _green),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: widget.color.withOpacity(.30),
                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 14),
                  Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('$m:$s · encrypted · low latency', style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallControl(icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded, label: 'Mute', active: muted, onTap: () => setState(() => muted = !muted)),
                      _CallControl(icon: speaker ? Icons.volume_up_rounded : Icons.volume_off_rounded, label: 'Speaker', active: !speaker, onTap: () => setState(() => speaker = !speaker)),
                      if (widget.video)
                        _CallControl(icon: camera ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: 'Camera', active: !camera, onTap: () => setState(() => camera = !camera)),
                      _CallControl(icon: Icons.call_end_rounded, label: 'End', active: true, color: _red, onTap: () => Navigator.pop(context)),
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

class SharedSafeRoutePage extends StatelessWidget {
  final Color accent;
  final bool dark;
  const SharedSafeRoutePage({super.key, required this.accent, required this.dark});

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : _ink;
    return Scaffold(
      backgroundColor: dark ? _deep : const Color(0xFFF3F8FA),
      appBar: AppBar(title: const Text('Live Safe Route'), backgroundColor: Colors.transparent, foregroundColor: fg),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: const MapOptions(initialCenter: LatLng(27.86, 85.58), initialZoom: 10.2),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.jeevansetu'),
                PolygonLayer(polygons: [Polygon(points: const [LatLng(27.88,85.55),LatLng(27.93,85.58),LatLng(27.90,85.64),LatLng(27.85,85.61)], color: _red.withOpacity(.2), borderColor: _red, borderStrokeWidth: 2)]),
                PolylineLayer(polylines: [Polyline(points: const [LatLng(27.80,85.50),LatLng(27.83,85.54),LatLng(27.86,85.57),LatLng(27.90,85.64)], strokeWidth: 7, color: _green)]),
                MarkerLayer(markers: const [
                  Marker(point: LatLng(27.80,85.50), width: 48, height: 48, child: _MapPin(color:_navy,icon:Icons.navigation_rounded)),
                  Marker(point: LatLng(27.90,85.64), width: 48, height: 48, child: _MapPin(color:_green,icon:Icons.home_work_rounded)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            color: dark ? const Color(0xFF102A33) : Colors.white,
            child: Column(
              children: [
                Row(children: [Expanded(child: _RouteChoice(title: 'Safest', meta: '6.3 km · 18 min', selected: true, accent: _green, dark: dark)), const SizedBox(width: 8), Expanded(child: _RouteChoice(title: 'Fastest', meta: '5.1 km · 14 min', selected: false, accent: accent, dark: dark))]),
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.shield_rounded, color: _green), const SizedBox(width: 8), Expanded(child: Text('Selected path avoids two active red zones and one blocked bridge.', style: TextStyle(color: fg, fontSize: 11)))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldScannerPage extends StatefulWidget {
  final Color accent;
  final String title;
  const FieldScannerPage({super.key, required this.accent, required this.title});
  @override
  State<FieldScannerPage> createState() => _FieldScannerPageState();
}

class _FieldScannerPageState extends State<FieldScannerPage> {
  bool scanned = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deep,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: scanned ? _green : widget.accent, width: 3),
                color: Colors.white.withOpacity(.04),
              ),
              child: Icon(scanned ? Icons.verified_rounded : Icons.qr_code_scanner_rounded, color: scanned ? _green : Colors.white, size: 120),
            ),
            const SizedBox(height: 24),
            Text(scanned ? 'Verified and synchronized' : 'Ready to scan', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(scanned ? 'Record linked to the shared incident timeline.' : 'Prototype field identity / asset verification flow', style: const TextStyle(color: Colors.white60)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: scanned ? _green : widget.accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () => setState(() => scanned = true),
                icon: Icon(scanned ? Icons.check_rounded : Icons.center_focus_strong_rounded),
                label: Text(scanned ? 'Scanned' : 'Simulate Scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final Color fg;
  final int pulse;
  const _TopHeader({required this.title, required this.subtitle, required this.accent, required this.fg, required this.pulse});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fg, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: fg.withOpacity(.55), fontSize: 10.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: _green.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)), const SizedBox(width: 6), Text('LIVE ${pulse % 3 == 0 ? '•' : ''}', style: const TextStyle(color: _green, fontWeight: FontWeight.w900, fontSize: 9))]),
          ),
        ],
      );
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final bool dark;
  const _MetricTile({required this.value, required this.label, required this.accent, required this.dark});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(color: dark ? const Color(0xFF102A33) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withOpacity(.18))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 8, fontWeight: FontWeight.w900))]),
      );
}

class _MapIncidentOverlay extends StatelessWidget {
  final NetworkIncident incident;
  final Color accent;
  final String roleName;
  final VoidCallback onAction;
  final VoidCallback onCall;
  const _MapIncidentOverlay({required this.incident, required this.accent, required this.roleName, required this.onAction, required this.onCall});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xEC061C24), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(incident.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5))), Text('${incident.progress}%', style: TextStyle(color: accent, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 3),
          Text('${incident.location} · ${incident.status}', style: const TextStyle(color: Colors.white60, fontSize: 9)),
          const SizedBox(height: 9),
          Row(children: [Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: accent, visualDensity: VisualDensity.compact), onPressed: onAction, icon: Icon(_roleIcon(roleName), size: 16), label: Text(_roleVerb(roleName)))), const SizedBox(width: 8), IconButton.filledTonal(onPressed: onCall, icon: const Icon(Icons.videocam_rounded))]),
        ]),
      );
}

class _IncidentCard extends StatelessWidget {
  final NetworkIncident incident;
  final String roleName;
  final Color accent;
  final bool dark;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final VoidCallback onCall;
  const _IncidentCard({required this.incident, required this.roleName, required this.accent, required this.dark, required this.selected, required this.onTap, required this.onAction, required this.onCall});
  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : _ink;
    final sub = dark ? Colors.white60 : Colors.black54;
    return Material(
      color: dark ? const Color(0xFF102A33) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? accent : (dark ? Colors.white10 : const Color(0xFFE0EAED)), width: selected ? 2 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: (incident.priority >= 5 ? _red : _orange).withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(incident.priority >= 5 ? Icons.sos_rounded : Icons.warning_amber_rounded, color: incident.priority >= 5 ? _red : _orange)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${incident.id} · ${incident.source}', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(incident.title, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w900))])),
              Text(_age(incident.createdAt), style: TextStyle(color: sub, fontSize: 9)),
            ]),
            const SizedBox(height: 10),
            Row(children: [Icon(Icons.location_on_rounded, size: 14, color: sub), const SizedBox(width: 4), Expanded(child: Text(incident.location, style: TextStyle(color: sub, fontSize: 9.5))), Text(incident.status, style: TextStyle(color: accent, fontSize: 8.5, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: incident.progress / 100, minHeight: 6, color: accent, backgroundColor: accent.withOpacity(.10))),
            const SizedBox(height: 9),
            Row(children: [Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: accent, visualDensity: VisualDensity.compact), onPressed: onAction, icon: Icon(_roleIcon(roleName), size: 16), label: Text(_roleVerb(roleName)))), const SizedBox(width: 8), IconButton.filledTonal(onPressed: onCall, icon: const Icon(Icons.call_rounded))]),
            Text('Assigned: ${incident.assignedTo}', style: TextStyle(color: sub, fontSize: 8.8)),
          ]),
        ),
      ),
    );
  }
}

class _HandoffRail extends StatelessWidget {
  final NetworkIncident incident;
  final Color accent;
  final bool dark;
  const _HandoffRail({required this.incident, required this.accent, required this.dark});
  @override
  Widget build(BuildContext context) {
    final roles = [
      (Icons.person_rounded, 'Citizen', _blue),
      (Icons.account_balance_rounded, 'Authority', _blue),
      (Icons.health_and_safety_rounded, 'Rescue', _red),
      (Icons.volunteer_activism_rounded, 'Volunteer', _purple),
      (Icons.apartment_rounded, 'Relief', _orange),
      (Icons.check_circle_rounded, 'Safe', _green),
    ];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: dark ? const Color(0xFF102A33) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE0EAED))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${incident.id} · connected lifecycle', style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(height: 13),
        Row(children: [
          for (var i = 0; i < roles.length; i++) ...[
            Expanded(child: Column(children: [CircleAvatar(radius: 17, backgroundColor: roles[i].$3.withOpacity(.13), child: Icon(roles[i].$1, color: roles[i].$3, size: 17)), const SizedBox(height: 5), Text(roles[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 7.2, fontWeight: FontWeight.w800))])),
            if (i != roles.length - 1) Icon(Icons.chevron_right_rounded, color: accent.withOpacity(.5), size: 16),
          ],
        ]),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool dark;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.accent, required this.dark, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 145,
        child: Material(
          color: dark ? const Color(0xFF102A33) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: accent, size: 20)), const Spacer(), Text(title, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 11)), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 8.5))]),
            ),
          ),
        ),
      );
}

class _ChannelCard extends StatelessWidget {
  final String title;
  final Color accent;
  final bool dark;
  final VoidCallback onVoice;
  final VoidCallback onVideo;
  const _ChannelCard({required this.title, required this.accent, required this.dark, required this.onVoice, required this.onVideo});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: dark ? const Color(0xFF102A33) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE0EAED))),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: accent.withOpacity(.12), child: Icon(Icons.wifi_tethering_rounded, color: accent)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 13)), Text('Available now · secure channel', style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 9))])),
          IconButton(onPressed: onVoice, icon: const Icon(Icons.call_rounded)),
          IconButton.filled(style: IconButton.styleFrom(backgroundColor: accent), onPressed: onVideo, icon: const Icon(Icons.videocam_rounded, color: Colors.white)),
        ]),
      );
}

class _MessageBubble extends StatelessWidget {
  final NetworkMessage message;
  final Color accent;
  final bool dark;
  const _MessageBubble({required this.message, required this.accent, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 16, backgroundColor: accent.withOpacity(.12), child: Text(message.sender.characters.first, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11))),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(message.sender, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 10))), Text(_age(message.time), style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 8))]), const SizedBox(height: 2), Text(message.text, style: TextStyle(color: dark ? Colors.white70 : Colors.black54, fontSize: 9.5, height: 1.35))])),
        ]),
      );
}

class _RiskRing extends StatelessWidget {
  final int value;
  const _RiskRing({required this.value});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        height: 92,
        child: Stack(alignment: Alignment.center, children: [SizedBox(width: 92, height: 92, child: CircularProgressIndicator(value: value / 100, strokeWidth: 10, color: Colors.white, backgroundColor: Colors.white24)), Text('$value%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 23))]),
      );
}

class _SignalCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool dark;
  const _SignalCard({required this.icon, required this.value, required this.label, required this.color, required this.dark});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: dark ? const Color(0xFF102A33) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(.12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 20), const SizedBox(height: 9), Text(value, style: TextStyle(color: dark ? Colors.white : _ink, fontSize: 14, fontWeight: FontWeight.w900)), Text(label, style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 7.5, fontWeight: FontWeight.w900))]),
      );
}

class _EvidenceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int confidence;
  final Color color;
  final bool dark;
  const _EvidenceCard({required this.title, required this.subtitle, required this.confidence, required this.color, required this.dark});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: dark ? const Color(0xFF102A33) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE0EAED))),
        child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.bolt_rounded, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 11.5)), Text(subtitle, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 9))])), Text('$confidence%', style: TextStyle(color: color, fontWeight: FontWeight.w900))]),
      );
}

class _TimelineRow extends StatelessWidget {
  final NetworkEvent event;
  final bool dark;
  const _TimelineRow({required this.event, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.only(top: 3), width: 10, height: 10, decoration: BoxDecoration(color: event.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: event.color.withOpacity(.3), blurRadius: 8)])), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${event.role} · ${event.incidentId}', style: TextStyle(color: event.color, fontWeight: FontWeight.w900, fontSize: 9)), const SizedBox(height: 2), Text(event.text, style: TextStyle(color: dark ? Colors.white70 : Colors.black54, fontSize: 10))])), Text(_age(event.time), style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 8))]),
      );
}

class _ToolkitHero extends StatelessWidget {
  final String roleName;
  final Color accent;
  final Color secondary;
  const _ToolkitHero({required this.roleName, required this.accent, required this.secondary});
  @override
  Widget build(BuildContext context) {
    final text = switch (roleName) {
      'Rescue Team' => 'Responder pack ready',
      'Authority' => 'Command systems online',
      'Volunteer' => 'Field mission ready',
      'Organization' => 'Relief network ready',
      _ => 'Operational toolkit ready',
    };
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: LinearGradient(colors: [accent, secondary])),
      child: Stack(children: [Positioned(right: -8, top: -15, child: Icon(_roleIcon(roleName), size: 120, color: Colors.white.withOpacity(.12))), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _GlassPill(text: 'READY FOR DEPLOYMENT', color: Colors.white), const Spacer(), Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Text('Tools stay linked to incident ID, map and response timeline.', style: TextStyle(color: Colors.white70, fontSize: 9.5))])]),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool dark;
  final VoidCallback onTap;
  const _ToolCard({required this.icon, required this.title, required this.subtitle, required this.accent, required this.dark, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: dark ? const Color(0xFF102A33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent)), const Spacer(), Text(title, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w900, fontSize: 11.5)), const SizedBox(height: 2), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 8.7))]),
          ),
        ),
      );
}

class _RouteChoice extends StatelessWidget {
  final String title;
  final String meta;
  final bool selected;
  final Color accent;
  final bool dark;
  const _RouteChoice({required this.title, required this.meta, required this.selected, required this.accent, required this.dark});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: selected ? accent.withOpacity(.10) : (dark ? Colors.white.withOpacity(.05) : const Color(0xFFF2F7F9)), borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? accent : Colors.transparent)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: selected ? accent : (dark ? Colors.white : _ink), fontWeight: FontWeight.w900, fontSize: 14)), Text(meta, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 9))]),
      );
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;
  const _CallControl({required this.icon, required this.label, required this.active, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => Column(children: [InkWell(onTap: onTap, borderRadius: BorderRadius.circular(36), child: Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? (active ? Colors.white24 : Colors.white12)), child: Icon(icon, color: Colors.white))), const SizedBox(height: 6), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8.5))]);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color fg;
  final Color sub;
  const _SectionTitle({required this.title, required this.subtitle, required this.fg, required this.sub});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: sub, fontSize: 9.5))]);
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _MapPin({required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 14)]), child: Icon(icon, color: Colors.white, size: 20));
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, elevation: 5, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: SizedBox(width: 42, height: 42, child: Icon(icon, color: _navy))));
}

class _GlassPill extends StatelessWidget {
  final String text;
  final Color color;
  const _GlassPill({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color == Colors.white ? Colors.white.withOpacity(.16) : color.withOpacity(.16), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(.45))), child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8.5, letterSpacing: .5)));
}

class _LivePill extends StatelessWidget {
  final Color color;
  const _LivePill({required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5), Text('LIVE', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8))]));
}

void _openCall(BuildContext context, NetworkIncident incident, Color accent, bool video) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => NetworkCallPage(title: '${incident.id} response room', color: accent, video: video)));
}

void _toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}
