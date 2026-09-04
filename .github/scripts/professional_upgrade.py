from pathlib import Path

p = Path('lib/judge_experience.dart')
s = p.read_text(encoding='utf-8')

# Keep navigation history so Android back returns to role/login flow rather than exiting.
s = s.replace(
"""  void enter() {
    Navigator.pushAndRemoveUntil(
      context,
      premiumRoute(RoleExperienceShell(role: widget.role)),
      (_) => false,
    );
  }
""",
"""  void enter() {
    Navigator.pushReplacement(
      context,
      premiumRoute(RoleExperienceShell(role: widget.role)),
    );
  }
""",
)

# Route all role tabs to the richer professional implementations.
s = s.replace(
"""    final pages = <Widget>[
      DistinctRoleHome(role: widget.role, config: config),
      RoleOperations(role: widget.role, config: config),
      RoleCommunications(role: widget.role, config: config),
      RoleIntelligence(role: widget.role, config: config),
      RoleToolkit(role: widget.role, config: config),
    ];
""",
"""    final pages = <Widget>[
      ProfessionalRoleHome(role: widget.role, config: config),
      ProfessionalRoleOperations(role: widget.role, config: config),
      RoleCommunications(role: widget.role, config: config),
      ProfessionalRoleIntelligence(role: widget.role, config: config),
      ProfessionalRoleToolkit(role: widget.role, config: config),
    ];
""",
)

# Replace all citizen safe-route entry points with the real map route screen.
s = s.replace('const SafeRoutePage()', 'const ProfessionalSafeRoutePage()')

marker = '// PROFESSIONAL_UPGRADE_V3'
if marker not in s:
    s += r'''

// PROFESSIONAL_UPGRADE_V3 ---------------------------------------------------

class ProfessionalSafeRoutePage extends StatefulWidget {
  const ProfessionalSafeRoutePage({super.key});

  @override
  State<ProfessionalSafeRoutePage> createState() => _ProfessionalSafeRoutePageState();
}

class _ProfessionalSafeRoutePageState extends State<ProfessionalSafeRoutePage> {
  int route = 0;
  bool navigating = false;
  double progress = .18;
  Timer? timer;

  static const safest = <LatLng>[
    LatLng(27.742, 85.435),
    LatLng(27.751, 85.452),
    LatLng(27.763, 85.468),
    LatLng(27.774, 85.481),
    LatLng(27.789, 85.494),
    LatLng(27.802, 85.528),
  ];
  static const fastest = <LatLng>[
    LatLng(27.742, 85.435),
    LatLng(27.758, 85.466),
    LatLng(27.775, 85.502),
    LatLng(27.802, 85.528),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startNavigation() {
    setState(() => navigating = !navigating);
    timer?.cancel();
    if (navigating) {
      timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        setState(() => progress = math.min(.94, progress + .045));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = route == 0 ? safest : fastest;
    final activeColor = route == 0 ? green : orange;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Safe Route', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(27.775, 85.482),
                    initialZoom: 11.4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.jeevansetu.app',
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: const [
                            LatLng(27.761, 85.470),
                            LatLng(27.781, 85.485),
                            LatLng(27.777, 85.508),
                            LatLng(27.756, 85.500),
                          ],
                          color: red.withValues(alpha: .18),
                          borderColor: red,
                          borderStrokeWidth: 2,
                        ),
                        Polygon(
                          points: const [
                            LatLng(27.785, 85.505),
                            LatLng(27.796, 85.516),
                            LatLng(27.790, 85.530),
                            LatLng(27.778, 85.522),
                          ],
                          color: red.withValues(alpha: .13),
                          borderColor: red,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: active,
                          strokeWidth: 7,
                          color: activeColor,
                          borderColor: Colors.white,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        const Marker(
                          point: LatLng(27.742, 85.435),
                          width: 48,
                          height: 48,
                          child: CircleAvatar(
                            backgroundColor: navy,
                            child: Icon(Icons.my_location_rounded, color: Colors.white),
                          ),
                        ),
                        const Marker(
                          point: LatLng(27.802, 85.528),
                          width: 52,
                          height: 52,
                          child: CircleAvatar(
                            backgroundColor: green,
                            child: Icon(Icons.home_work_rounded, color: Colors.white),
                          ),
                        ),
                        const Marker(
                          point: LatLng(27.771, 85.491),
                          width: 42,
                          height: 42,
                          child: Icon(Icons.warning_rounded, color: red, size: 38),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: green),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route == 0 ? 'Safest corridor selected' : 'Fastest corridor selected',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                              Text(
                                route == 0
                                    ? 'Avoids 2 active red zones · 6.3 km · 18 min'
                                    : 'Shorter route · passes near 1 watch zone · 5.1 km · 14 min',
                                style: const TextStyle(color: Colors.black54, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                        const LiveBadge(label: 'LIVE'),
                      ],
                    ),
                  ),
                ),
                if (navigating)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: deepNavy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: aqua,
                                child: Icon(Icons.navigation_rounded, color: navy),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Continue on verified corridor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                    Text('${(6.3 * (1 - progress)).clamp(.3, 6.3).toStringAsFixed(1)} km remaining · live hazard rerouting on', style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                                  ],
                                ),
                              ),
                              Text('${(progress * 100).round()}%', style: const TextStyle(color: aqua, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 9),
                          LinearProgressIndicator(value: progress, minHeight: 6, color: aqua, backgroundColor: Colors.white12),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(14, 12, 14, MediaQuery.paddingOf(context).bottom + 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RouteChoice(
                        active: route == 0,
                        title: 'Safest',
                        subtitle: '6.3 km · 18 min',
                        color: green,
                        onTap: () => setState(() => route = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RouteChoice(
                        active: route == 1,
                        title: 'Fastest',
                        subtitle: '5.1 km · 14 min',
                        color: orange,
                        onTap: () => setState(() => route = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: navigating ? navy : activeColor, minimumSize: const Size.fromHeight(50)),
                    onPressed: startNavigation,
                    icon: Icon(navigating ? Icons.stop_circle_outlined : Icons.navigation_rounded),
                    label: Text(navigating ? 'Stop navigation' : 'Start live navigation', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalRoleHome extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleHome({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleHome> createState() => _ProfessionalRoleHomeState();
}

class _ProfessionalRoleHomeState extends State<ProfessionalRoleHome> {
  int tick = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => tick++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final role = widget.role;
    return SafeArea(
      child: Material(
        color: c.background,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ProfessionalRoleHero(role: role, config: c, tick: tick)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList.list(
                children: [
                  _RoleLiveMapPreview(role: role, config: c),
                  const SizedBox(height: 16),
                  SectionTitle(title: roleActionSection(role), subtitle: _professionalSubtitle(role)),
                  const SizedBox(height: 10),
                  _ProfessionalActionRail(role: role, config: c),
                  const SizedBox(height: 16),
                  RoleDynamicPanel(role: role, config: c),
                  const SizedBox(height: 16),
                  _RoleKpiTimeline(role: role, config: c, tick: tick),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _professionalSubtitle(ExperienceRole role) => switch (role) {
    ExperienceRole.rescue => 'Dispatch, triage, routing and field reconnaissance',
    ExperienceRole.authority => 'Broadcast, verification, zoning and resource allocation',
    ExperienceRole.volunteer => 'Nearby missions matched to skill, distance and urgency',
    ExperienceRole.organization => 'Shelter, stock, transport and partner coordination',
    ExperienceRole.citizen => 'Safety actions',
  };
}

class _ProfessionalRoleHero extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  final int tick;
  const _ProfessionalRoleHero({required this.role, required this.config, required this.tick});

  @override
  Widget build(BuildContext context) {
    final image = role == ExperienceRole.rescue ? rescueImage : mountainImage;
    return SizedBox(
      height: 310,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FastPhoto(image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: role == ExperienceRole.rescue
                    ? const [Color(0x7006151B), Color(0xF506151B)]
                    : [config.accent.withValues(alpha: .45), const Color(0xE9072631)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white.withValues(alpha: .16), child: Icon(role.icon, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(role.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                        Text(config.eyebrow, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .8)),
                      ]),
                    ),
                    const LiveBadge(label: 'LIVE'),
                  ],
                ),
                const Spacer(),
                Text(config.headline, style: const TextStyle(color: Colors.white, fontSize: 29, height: 1.02, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(config.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(3, (i) {
                    final baseText = config.metrics[i];
                    final dynamic = i == 1 && tick.isOdd ? '$baseText · LIVE' : baseText;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 7 : 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white24)),
                          child: FittedBox(child: Text(dynamic, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleLiveMapPreview extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const _RoleLiveMapPreview({required this.role, required this.config});

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(point: const LatLng(27.78, 85.49), width: 42, height: 42, child: CircleAvatar(backgroundColor: config.accent, child: Icon(role.icon, color: Colors.white, size: 20))),
      const Marker(point: LatLng(27.802, 85.528), width: 42, height: 42, child: CircleAvatar(backgroundColor: green, child: Icon(Icons.home_work_rounded, color: Colors.white, size: 20))),
      const Marker(point: LatLng(27.758, 85.462), width: 42, height: 42, child: CircleAvatar(backgroundColor: red, child: Icon(Icons.warning_rounded, color: Colors.white, size: 20))),
    ];
    return Container(
      height: 235,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: config.accent.withValues(alpha: .18))),
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(initialCenter: LatLng(27.78, 85.49), initialZoom: 11.2),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.jeevansetu.app'),
              PolygonLayer(polygons: [Polygon(points: const [LatLng(27.756,85.468),LatLng(27.779,85.485),LatLng(27.770,85.511),LatLng(27.748,85.497)], color: red.withValues(alpha:.16), borderColor: red, borderStrokeWidth: 2)]),
              PolylineLayer(polylines: [Polyline(points: const [LatLng(27.744,85.443),LatLng(27.763,85.470),LatLng(27.782,85.496),LatLng(27.802,85.528)], strokeWidth: 5, color: config.secondary)]),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                Icon(Icons.public_rounded, color: config.accent, size: 19),
                const SizedBox(width: 8),
                Expanded(child: Text(_mapTitle(role), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900))),
                const LiveBadge(label: 'MAP'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _mapTitle(ExperienceRole role) => switch(role) {
    ExperienceRole.rescue => 'Responder corridor · Unit 04 moving',
    ExperienceRole.authority => 'District risk perimeter · verified layers',
    ExperienceRole.volunteer => 'Mission cluster · 2 tasks within 1.8 km',
    ExperienceRole.organization => 'Facility network · capacity & logistics',
    ExperienceRole.citizen => 'Live safety map',
  };
}

class _ProfessionalActionRail extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const _ProfessionalActionRail({required this.role, required this.config});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: config.actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final a = config.actions[i];
          return SizedBox(
            width: 150,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => runRoleAction(context, role, a.title),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(backgroundColor: config.accent.withValues(alpha: .1), child: Icon(a.icon, color: config.accent)),
                    const Spacer(),
                    Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    Text(a.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 8.5)),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleKpiTimeline extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  final int tick;
  const _RoleKpiTimeline({required this.role, required this.config, required this.tick});

  @override
  Widget build(BuildContext context) {
    final items = switch(role) {
      ExperienceRole.rescue => [('Unit 04 GPS updated','${8 + tick % 5} sec ago'),('Medical team linked','secure channel active'),('Drone corridor','weather cleared')],
      ExperienceRole.authority => [('Ward 8 evidence','94% verified'),('Broadcast reach','18,420 devices'),('Sensor mesh','${27 + tick % 2}/28 online')],
      ExperienceRole.volunteer => [('Household check-in','3 of 4 complete'),('Supply handover','12 packs scanned'),('Team proximity','Riya · ${300 + tick*5 % 90} m')],
      ExperienceRole.organization => [('Shelter occupancy','53 / 84'),('Water inventory','${1260 - tick*3} units'),('Partner ETA','${18 - tick % 5} min')],
      ExperienceRole.citizen => <(String,String)>[],
    };
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.timeline_rounded, color: config.accent), const SizedBox(width: 8), const Text('Live operations timeline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const Spacer(), const LiveBadge(label:'SYNC')]),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) => Column(children: [if(e.key>0) const Divider(), Row(children:[CircleAvatar(radius:5,backgroundColor:e.key==0?config.accent:green),const SizedBox(width:9),Expanded(child:Text(e.value.$1,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:10.5))),Text(e.value.$2,style:const TextStyle(color:Colors.black45,fontSize:9))])])),
      ]),
    );
  }
}

class ProfessionalRoleOperations extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleOperations({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleOperations> createState() => _ProfessionalRoleOperationsState();
}

class _ProfessionalRoleOperationsState extends State<ProfessionalRoleOperations> {
  int selected = 0;
  bool layer = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final textColor = c.dark ? Colors.white : ink;
    return SafeArea(
      child: Material(
        color: c.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(children: [
                Expanded(child: Text(c.tabs[1], style: TextStyle(color:textColor,fontSize:24,fontWeight:FontWeight.w900))),
                Pill(label: 'LIVE', color: c.accent, dark: c.dark),
              ]),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(initialCenter: LatLng(27.78,85.49), initialZoom: 11.0),
                    children: [
                      TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.jeevansetu.app'),
                      if(layer) PolygonLayer(polygons:[Polygon(points:const[LatLng(27.75,85.46),LatLng(27.79,85.48),LatLng(27.78,85.53),LatLng(27.74,85.51)],color:red.withValues(alpha:.18),borderColor:red,borderStrokeWidth:2)]),
                      PolylineLayer(polylines:[Polyline(points:const[LatLng(27.742,85.435),LatLng(27.765,85.482),LatLng(27.802,85.528)],strokeWidth:6,color:c.secondary)]),
                      MarkerLayer(markers:[
                        Marker(point:const LatLng(27.78,85.49),width:46,height:46,child:CircleAvatar(backgroundColor:c.accent,child:Icon(widget.role.icon,color:Colors.white))),
                        const Marker(point:LatLng(27.802,85.528),width:46,height:46,child:CircleAvatar(backgroundColor:green,child:Icon(Icons.home_work_rounded,color:Colors.white))),
                        const Marker(point:LatLng(27.758,85.468),width:42,height:42,child:Icon(Icons.warning_rounded,color:red,size:38)),
                      ]),
                    ],
                  ),
                  Positioned(top:12,right:12,child:FloatingActionButton.small(heroTag:'layers-${widget.role.name}',backgroundColor:Colors.white,foregroundColor:c.accent,onPressed:()=>setState(()=>layer=!layer),child:Icon(layer?Icons.layers_rounded:Icons.layers_clear_rounded))),
                  Positioned(
                    left:12,right:12,bottom:12,
                    child: SurfaceCard(
                      child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Row(children:[Icon(widget.role.icon,color:c.accent),const SizedBox(width:8),Expanded(child:Text(boardTitle(widget.role,selected),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13))),const LiveBadge(label:'ACTIVE')]),
                        const SizedBox(height:4),
                        Text(boardSubtitle(widget.role,selected),style:const TextStyle(color:Colors.black54,fontSize:9.5)),
                        const SizedBox(height:10),
                        Row(children:List.generate(3,(i)=>Expanded(child:Padding(padding:EdgeInsets.only(right:i<2?6:0),child:ChoiceChip(label:Text('${i+1}'),selected:selected==i,onSelected:(_)=>setState(()=>selected=i))))))),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalRoleIntelligence extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleIntelligence({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleIntelligence> createState() => _ProfessionalRoleIntelligenceState();
}

class _ProfessionalRoleIntelligenceState extends State<ProfessionalRoleIntelligence> {
  int refresh = 14;
  Timer? timer;
  @override
  void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>refresh=refresh==1?14:refresh-1);});}
  @override
  void dispose(){timer?.cancel();super.dispose();}

  @override
  Widget build(BuildContext context){
    final c=widget.config; final tc=c.dark?Colors.white:ink; final sc=c.dark?Colors.white60:Colors.black54;
    return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:Text(c.tabs[3],style:TextStyle(color:tc,fontSize:24,fontWeight:FontWeight.w900))),Pill(label:'SYNC $refresh SEC',color:c.accent,dark:c.dark)]),
      const SizedBox(height:12),
      Container(height:180,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22)),child:Stack(fit:StackFit.expand,children:[
        FastPhoto(widget.role==ExperienceRole.rescue?rescueImage:riskImage),
        const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0x20000000),Color(0xDD071820)]))),
        Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Pill(label:'VERIFIED SIGNAL FUSION',color:c.accent,dark:true),const Spacer(),Text(_intelHeadline(widget.role),style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(_intelSub(widget.role),style:const TextStyle(color:Colors.white70,fontSize:10))]))
      ])),
      const SizedBox(height:12),
      SurfaceCard(child:Column(children:[_IntelMetric('Sensor confidence',.92,c.accent),const SizedBox(height:9),_IntelMetric('Community agreement',.81,green),const SizedBox(height:9),_IntelMetric('Route confidence',.88,orange)])),
      const SizedBox(height:12),
      ..._intelRows(widget.role).map((r)=>Padding(padding:const EdgeInsets.only(bottom:9),child:SurfaceCard(child:Row(children:[CircleAvatar(backgroundColor:r.$3.withValues(alpha:.1),child:Icon(r.$4,color:r.$3)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(r.$1,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12.5)),Text(r.$2,style:TextStyle(color:sc,fontSize:9.7,height:1.3))])),Icon(Icons.chevron_right_rounded,color:c.dark?Colors.white38:Colors.black38)]))))
    ])));
  }

  String _intelHeadline(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Terrain + victim intelligence',ExperienceRole.authority=>'District evidence picture',ExperienceRole.volunteer=>'Mission relevance engine',ExperienceRole.organization=>'Demand + capacity intelligence',ExperienceRole.citizen=>'Risk intelligence'};
  String _intelSub(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Thermal, terrain, route and SOS evidence fused for field decisions.',ExperienceRole.authority=>'Sensor, citizen and agency evidence prioritised before public action.',ExperienceRole.volunteer=>'Tasks ranked by proximity, skill, urgency and access.',ExperienceRole.organization=>'Shelter occupancy, demand, inventory and transport changes in one view.',ExperienceRole.citizen=>'Verified local risk context.'};
  List<(String,String,Color,IconData)> _intelRows(ExperienceRole r)=>switch(r){
    ExperienceRole.rescue=>[('Thermal signature confirmed','Possible 2-person cluster · drone pass 3',red,Icons.thermostat_rounded),('Approach corridor improved','North-east path now clear for 4×4 access',green,Icons.route_rounded),('Rain intensity falling','18.4 → 14.1 mm/hr over latest cycle',blue,Icons.water_drop_rounded)],
    ExperienceRole.authority=>[('Ward 8 evidence verified','3 independent sources · 94% confidence',red,Icons.fact_check_rounded),('Public warning reach','18,420 devices · 91% delivery',blue,Icons.campaign_rounded),('Resource pressure rising','Melamchi hub projected 82% full in 3h',orange,Icons.hub_rounded)],
    ExperienceRole.volunteer=>[('Mission match improved','Water delivery now 0.9 km from your route',purple,Icons.route_rounded),('Household check-in overdue','1 family has not checked in for 34 min',orange,Icons.family_restroom_rounded),('Camp B requests support','Registration queue increased by 12',green,Icons.home_work_rounded)],
    ExperienceRole.organization=>[('Water demand rising','Projected 18% increase at Melamchi hub',blue,Icons.water_drop_rounded),('Transport window opened','Araniko corridor clear for next 42 min',green,Icons.local_shipping_rounded),('Medical stock threshold','Trauma kits projected below 20% by 18:00',red,Icons.medical_services_rounded)],
    ExperienceRole.citizen=>[],
  };
}

class _IntelMetric extends StatelessWidget {final String label;final double value;final Color color;const _IntelMetric(this.label,this.value,this.color);@override Widget build(BuildContext context)=>Column(children:[Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800))),Text('${(value*100).round()}%',style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:10))]),const SizedBox(height:5),LinearProgressIndicator(value:value,minHeight:7,color:color,backgroundColor:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(10))]);}

class ProfessionalRoleToolkit extends StatelessWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleToolkit({super.key,required this.role,required this.config});

  @override
  Widget build(BuildContext context){
    final c=config; final tc=c.dark?Colors.white:ink; final sc=c.dark?Colors.white60:Colors.black54;
    final cards=switch(role){
      ExperienceRole.rescue=>[(Icons.medical_services_rounded,'Triage protocol','Offline protocol · 6 steps',red),(Icons.qr_code_scanner_rounded,'Patient / asset scan','QR + offline handover',blue),(Icons.sensors_rounded,'Field sensor link','26/28 nodes online',green),(Icons.inventory_2_rounded,'Equipment readiness','84% mission ready',orange)],
      ExperienceRole.authority=>[(Icons.campaign_rounded,'Broadcast templates','3 languages · geo-targeted',blue),(Icons.fact_check_rounded,'Evidence policy','3-source verification rules',green),(Icons.history_rounded,'Decision log','Signed operational history',purple),(Icons.security_rounded,'Access controls','12 authorised officers',orange)],
      ExperienceRole.volunteer=>[(Icons.badge_rounded,'Digital volunteer ID','Verified · responder mesh',purple),(Icons.school_rounded,'Micro training','4 modules cached offline',blue),(Icons.offline_bolt_rounded,'Offline mission pack','Routes + contacts synced',green),(Icons.workspace_premium_rounded,'Impact record','7 missions · 46 families',orange)],
      ExperienceRole.organization=>[(Icons.inventory_rounded,'Inventory ledger','1,260 water · 87 trauma kits',orange),(Icons.apartment_rounded,'Shelter profile','53 / 84 occupied',green),(Icons.qr_code_rounded,'Resource handover QR','Fast chain-of-custody',blue),(Icons.handshake_rounded,'Partner directory','4 partners online',purple)],
      ExperienceRole.citizen=><(IconData,String,String,Color)>[]};
    return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Text(c.tabs[4],style:TextStyle(color:tc,fontSize:24,fontWeight:FontWeight.w900)),
      Text('Operational tools ready for this role',style:TextStyle(color:sc,fontSize:10.5)),
      const SizedBox(height:14),
      Container(height:150,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22)),child:Stack(fit:StackFit.expand,children:[FastPhoto(role==ExperienceRole.rescue?rescueImage:mountainImage),Container(color:Colors.black.withValues(alpha:.45)),Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Pill(label:'OFFLINE + ONLINE',color:c.accent,dark:true),const Spacer(),Text(_kitTitle(role),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:18)),const Text('Critical tools stay usable even when connectivity degrades.',style:TextStyle(color:Colors.white70,fontSize:9.5))]))])),
      const SizedBox(height:12),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:1.18),itemBuilder:(_,i){final x=cards[i];return Material(color:Colors.white,borderRadius:BorderRadius.circular(19),child:InkWell(borderRadius:BorderRadius.circular(19),onTap:()=>showInfo(context,x.$2,x.$3),child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:x.$4.withValues(alpha:.1),child:Icon(x.$1,color:x.$4)),const Spacer(),Text(x.$2,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),Text(x.$3,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.black45,fontSize:8.7))]))));}),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:()=>Navigator.pushReplacement(context,premiumRoute(const PremiumRolePicker())),icon:const Icon(Icons.swap_horiz_rounded),label:const Text('Switch profession / role')),
    ])));
  }
  String _kitTitle(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Responder field kit',ExperienceRole.authority=>'Command governance suite',ExperienceRole.volunteer=>'Volunteer field pack',ExperienceRole.organization=>'Relief logistics toolkit',ExperienceRole.citizen=>'Safety toolkit'};
}
'''

p.write_text(s, encoding='utf-8')
print('professional upgrade applied', len(s))
