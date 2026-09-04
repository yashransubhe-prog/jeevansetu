import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _navy = Color(0xFF073C4D);
const _bg = Color(0xFFF3F8FA);
const _red = Color(0xFFFF3B55);
const _green = Color(0xFF20C98A);
const _orange = Color(0xFFFFA42E);
const _blue = Color(0xFF4387F4);
const _purple = Color(0xFF7758DF);

class NetworkIncident {
  final String id;
  final String title;
  final String source;
  final String location;
  final int priority;
  final String status;
  final String assignedTo;
  final DateTime createdAt;

  const NetworkIncident({
    required this.id,
    required this.title,
    required this.source,
    required this.location,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.createdAt,
  });

  NetworkIncident copyWith({String? status, String? assignedTo}) => NetworkIncident(
        id: id,
        title: title,
        source: source,
        location: location,
        priority: priority,
        status: status ?? this.status,
        assignedTo: assignedTo ?? this.assignedTo,
        createdAt: createdAt,
      );
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
      ),
      ...incidents.value,
    ];
  }

  void update(String id, {String? status, String? assignedTo}) {
    incidents.value = [
      for (final item in incidents.value)
        if (item.id == id)
          item.copyWith(status: status, assignedTo: assignedTo)
        else
          item,
    ];
  }
}

String _age(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  return '${d.inHours} h';
}

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
  final MapController map = MapController();

  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : const Color(0xFF102027);
    final sub = widget.dark ? Colors.white60 : Colors.black54;
    return SafeArea(
      child: Material(
        color: widget.background,
        child: ValueListenableBuilder<List<NetworkIncident>>(
          valueListenable: JeevanNetwork.instance.incidents,
          builder: (_, incidents, __) {
            final active = incidents[selected.clamp(0, incidents.length - 1)];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_opsTitle(widget.roleName), style: TextStyle(color: fg, fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text('Shared JeevanSetu incident network', style: TextStyle(color: sub, fontSize: 10.5)),
                      ])),
                      _LiveChip(color: widget.accent),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 300,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 20, offset: const Offset(0, 8))]),
                    child: Stack(children: [
                      FlutterMap(
                        mapController: map,
                        options: const MapOptions(initialCenter: LatLng(27.85, 85.55), initialZoom: 9.2),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.jeevansetu'),
                          PolygonLayer(polygons: [Polygon(points: const [LatLng(27.90,85.45),LatLng(27.98,85.58),LatLng(27.88,85.69),LatLng(27.79,85.55)], color: _red.withOpacity(.17), borderColor: _red, borderStrokeWidth: 2)]),
                          PolylineLayer(polylines: [Polyline(points: const [LatLng(27.82,85.50),LatLng(27.86,85.55),LatLng(27.90,85.61)], strokeWidth: 5, color: _green)]),
                          MarkerLayer(markers: [
                            Marker(point: const LatLng(27.89,85.56), width: 46, height: 46, child: _MapPin(color: _red, icon: Icons.sos_rounded)),
                            Marker(point: const LatLng(27.82,85.50), width: 46, height: 46, child: _MapPin(color: widget.accent, icon: _roleIcon(widget.roleName))),
                            Marker(point: const LatLng(27.90,85.61), width: 46, height: 46, child: const _MapPin(color: _green, icon: Icons.home_work_rounded)),
                          ]),
                        ],
                      ),
                      Positioned(left: 12, top: 12, child: _GlassLabel('${active.id} · P${active.priority}', color: widget.accent)),
                      Positioned(left: 12, right: 12, bottom: 12, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xEE071B22), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(active.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text('${active.location} · ${active.status}', style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                      ]))),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Text('Incoming connected incidents', style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 16)))),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.builder(
                    itemCount: incidents.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IncidentCard(
                        incident: incidents[i],
                        accent: widget.accent,
                        selected: selected == i,
                        dark: widget.dark,
                        roleName: widget.roleName,
                        onTap: () => setState(() => selected = i),
                        onPrimary: () => _advanceIncident(widget.roleName, incidents[i]),
                        onCall: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NetworkCallPage(title: '${incidents[i].id} response room', color: widget.accent, video: true))),
                      ),
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

  void _advanceIncident(String role, NetworkIncident item) {
    final (status, assignee) = switch (role) {
      'Rescue Team' => ('Rescue dispatched · ETA 8 min', 'Rescue Unit 04'),
      'Authority' => ('Verified · public warning active', 'District EOC'),
      'Volunteer' => ('Volunteer mission accepted', 'Volunteer Alpha'),
      'Organization' => ('Shelter + supplies reserved', 'Relief Partner 03'),
      _ => ('Acknowledged', role),
    };
    JeevanNetwork.instance.update(item.id, status: status, assignedTo: assignee);
  }
}

class _IncidentCard extends StatelessWidget {
  final NetworkIncident incident;
  final Color accent;
  final bool selected;
  final bool dark;
  final String roleName;
  final VoidCallback onTap;
  final VoidCallback onPrimary;
  final VoidCallback onCall;

  const _IncidentCard({required this.incident, required this.accent, required this.selected, required this.dark, required this.roleName, required this.onTap, required this.onPrimary, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final surface = dark ? const Color(0xFF102A33) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF102027);
    final sub = dark ? Colors.white60 : Colors.black54;
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? accent : (dark ? Colors.white12 : const Color(0xFFE6EEF0)), width: selected ? 2 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: (incident.priority >= 5 ? _red : _orange).withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(incident.priority >= 5 ? Icons.sos_rounded : Icons.warning_amber_rounded, color: incident.priority >= 5 ? _red : _orange)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${incident.id} · ${incident.source}', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(incident.title, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w900))])),
              Text(_age(incident.createdAt), style: TextStyle(color: sub, fontSize: 9)),
            ]),
            const SizedBox(height: 10),
            Row(children: [Icon(Icons.location_on_rounded, size: 15, color: sub), const SizedBox(width: 4), Expanded(child: Text(incident.location, style: TextStyle(color: sub, fontSize: 9.5))), _StatusChip(text: incident.status, color: accent)]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: onPrimary, icon: Icon(_primaryIcon(roleName), size: 17), label: Text(_primaryLabel(roleName), maxLines: 1, overflow: TextOverflow.ellipsis))),
              const SizedBox(width: 8),
              IconButton.filledTonal(onPressed: onCall, icon: const Icon(Icons.videocam_rounded)),
            ]),
            const SizedBox(height: 5),
            Text('Assigned: ${incident.assignedTo}', style: TextStyle(color: sub, fontSize: 9)),
          ]),
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
  const ConnectedCommunicationsTab({super.key, required this.roleName, required this.accent, required this.secondary, required this.background, required this.dark});
  @override State<ConnectedCommunicationsTab> createState() => _ConnectedCommunicationsTabState();
}

class _ConnectedCommunicationsTabState extends State<ConnectedCommunicationsTab> {
  int pulse = 0;
  Timer? timer;
  @override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:3),(_){if(mounted)setState(()=>pulse++);});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context){
    final fg=widget.dark?Colors.white:const Color(0xFF102027); final sub=widget.dark?Colors.white60:Colors.black54;
    final rooms=_rooms(widget.roleName);
    return SafeArea(child: Material(color:widget.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Response communications',style:TextStyle(color:fg,fontSize:24,fontWeight:FontWeight.w900)),Text('Encrypted voice · video · incident rooms',style:TextStyle(color:sub,fontSize:10.5))])),const _LiveChip(color:_green)]),
      const SizedBox(height:16),
      Container(height:170,padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:LinearGradient(colors:[widget.accent,widget.secondary])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const _GlassLabel('JEEVANSETU RESPONSE MESH',color:Colors.white),const Spacer(),Text('${9 + pulse%4} responders online',style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:4),const Text('Voice 42 ms · Video stable · Radio fallback ready',style:TextStyle(color:Colors.white70,fontSize:10))])),
      const SizedBox(height:16),
      ...rooms.map((room)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_CommsRoom(title:room,accent:widget.accent,dark:widget.dark,onVoice:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>NetworkCallPage(title:room,color:widget.accent,video:false))),onVideo:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>NetworkCallPage(title:room,color:widget.accent,video:true)))))),
      const SizedBox(height:6),
      ValueListenableBuilder<List<NetworkIncident>>(valueListenable:JeevanNetwork.instance.incidents,builder:(_,items,__)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Incident rooms',style:TextStyle(color:fg,fontWeight:FontWeight.w900,fontSize:16)),const SizedBox(height:8),...items.take(2).map((e)=>ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(backgroundColor:widget.accent.withOpacity(.12),child:Icon(Icons.forum_rounded,color:widget.accent)),title:Text('${e.id} · ${e.title}',style:TextStyle(color:fg,fontWeight:FontWeight.w800,fontSize:11)),subtitle:Text(e.status,style:TextStyle(color:sub,fontSize:9)),trailing:IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>NetworkCallPage(title:'${e.id} response room',color:widget.accent,video:true))),icon:Icon(Icons.video_call_rounded,color:widget.accent))))]))
    ])));
  }
}

class ConnectedIntelligenceTab extends StatelessWidget {
  final String roleName; final Color accent; final Color secondary; final Color background; final bool dark;
  const ConnectedIntelligenceTab({super.key,required this.roleName,required this.accent,required this.secondary,required this.background,required this.dark});
  @override Widget build(BuildContext context){final fg=dark?Colors.white:const Color(0xFF102027);final sub=dark?Colors.white60:Colors.black54;return SafeArea(child:Material(color:background,child:ValueListenableBuilder<List<NetworkIncident>>(valueListenable:JeevanNetwork.instance.incidents,builder:(_,items,__)=>ListView(padding:const EdgeInsets.all(16),children:[
    Text('Operational intelligence',style:TextStyle(color:fg,fontSize:24,fontWeight:FontWeight.w900)),Text('AI + citizen evidence + field confirmation',style:TextStyle(color:sub,fontSize:10.5)),const SizedBox(height:14),
    Container(height:220,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(24)),child:Stack(fit:StackFit.expand,children:[Image.network('https://commons.wikimedia.org/wiki/Special:Redirect/file/Himalayas,_Nepal.jpg?width=1000',fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:_navy)),Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Color(0xEE062F3C)]))),Positioned(left:16,right:16,bottom:16,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const _LiveChip(color:_green),const SizedBox(height:8),Text(_intelHeadline(roleName),style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const Text('Confidence 94% · updated from shared response network',style:TextStyle(color:Colors.white70,fontSize:9.5))]))])),
    const SizedBox(height:14),
    Row(children:[Expanded(child:_IntelMetric(label:'ACTIVE',value:'${items.length}',color:accent,dark:dark)),const SizedBox(width:8),Expanded(child:_IntelMetric(label:'VERIFIED',value:'94%',color:_green,dark:dark)),const SizedBox(width:8),Expanded(child:_IntelMetric(label:'CRITICAL',value:'${items.where((e)=>e.priority>=5).length}',color:_red,dark:dark))]),
    const SizedBox(height:14),
    ...items.map((e)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:dark?const Color(0xFF102A33):Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:dark?Colors.white12:const Color(0xFFE5ECEE))),child:Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:accent.withOpacity(.1),borderRadius:BorderRadius.circular(13)),child:Icon(Icons.analytics_rounded,color:accent)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.title,style:TextStyle(color:fg,fontWeight:FontWeight.w900,fontSize:11.5)),Text('${e.source} · ${e.status}',style:TextStyle(color:sub,fontSize:9))])),Text('P${e.priority}',style:TextStyle(color:e.priority>=5?_red:_orange,fontWeight:FontWeight.w900))])))),
  ]))));}
}

class ConnectedToolkitTab extends StatelessWidget {
  final String roleName; final Color accent; final Color secondary; final Color background; final bool dark;
  const ConnectedToolkitTab({super.key,required this.roleName,required this.accent,required this.secondary,required this.background,required this.dark});
  @override Widget build(BuildContext context){final fg=dark?Colors.white:const Color(0xFF102027);final sub=dark?Colors.white60:Colors.black54;final tools=_tools(roleName);return SafeArea(child:Material(color:background,child:ListView(padding:const EdgeInsets.all(16),children:[
    Text(_toolkitTitle(roleName),style:TextStyle(color:fg,fontSize:24,fontWeight:FontWeight.w900)),Text('Operational tools connected to the same incident network',style:TextStyle(color:sub,fontSize:10.5)),const SizedBox(height:14),
    Container(height:150,padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:LinearGradient(colors:[accent,secondary])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const _GlassLabel('READY FOR DEPLOYMENT',color:Colors.white),const Spacer(),Text(_toolkitHero(roleName),style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const Text('Actions are recorded in the shared response timeline',style:TextStyle(color:Colors.white70,fontSize:9.5))])),
    const SizedBox(height:14),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:tools.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.4),itemBuilder:(_,i){final t=tools[i];return Material(color:dark?const Color(0xFF102A33):Colors.white,borderRadius:BorderRadius.circular(18),child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${t.$2} action recorded in JeevanSetu network'))),child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(t.$1,color:i.isEven?accent:secondary),const Spacer(),Text(t.$2,style:TextStyle(color:fg,fontWeight:FontWeight.w900,fontSize:12)),Text(t.$3,style:TextStyle(color:sub,fontSize:8.7),maxLines:2,overflow:TextOverflow.ellipsis)])))) ;}),
    const SizedBox(height:16),
    ValueListenableBuilder<List<NetworkIncident>>(valueListenable:JeevanNetwork.instance.incidents,builder:(_,items,__)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:dark?const Color(0xFF102A33):Colors.white,borderRadius:BorderRadius.circular(18)),child:Row(children:[Icon(Icons.hub_rounded,color:accent),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${items.length} incidents synchronized',style:TextStyle(color:fg,fontWeight:FontWeight.w900)),Text('Citizen · Rescue · Authority · Volunteer · Organization',style:TextStyle(color:sub,fontSize:9))]))]))
  ]))));}
}

class NetworkCallPage extends StatefulWidget {
  final String title; final Color color; final bool video;
  const NetworkCallPage({super.key,required this.title,required this.color,required this.video});
  @override State<NetworkCallPage> createState()=>_NetworkCallPageState();
}
class _NetworkCallPageState extends State<NetworkCallPage>{bool muted=false;bool camera=true;int seconds=0;Timer? timer;@override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState(()=>seconds++);});}@override void dispose(){timer?.cancel();super.dispose();}@override Widget build(BuildContext context){final m=(seconds~/60).toString().padLeft(2,'0');final s=(seconds%60).toString().padLeft(2,'0');return Scaffold(backgroundColor:const Color(0xFF061820),body:SafeArea(child:Stack(children:[Positioned.fill(child:widget.video&&camera?Image.network('https://commons.wikimedia.org/wiki/Special:Redirect/file/A_helicopter_flying_over_Langtang_region.jpg?width=900',fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:const Color(0xFF0B4352))):Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF0B5265),Color(0xFF061820)],begin:Alignment.topCenter,end:Alignment.bottomCenter)))),Positioned.fill(child:Container(color:Colors.black.withOpacity(widget.video?.28:.08))),Padding(padding:const EdgeInsets.all(20),child:Column(children:[Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.keyboard_arrow_down_rounded,color:Colors.white)),const Spacer(),const _GlassLabel('SECURE RESPONSE CHANNEL',color:_green)]),const Spacer(),CircleAvatar(radius:42,backgroundColor:widget.color.withOpacity(.25),child:const Icon(Icons.groups_rounded,color:Colors.white,size:42)),const SizedBox(height:12),Text(widget.title,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),Text('$m:$s · connected',style:const TextStyle(color:Colors.white60)),const Spacer(),Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[_CallButton(icon:muted?Icons.mic_off_rounded:Icons.mic_rounded,label:'Mute',active:muted,onTap:()=>setState(()=>muted=!muted)),if(widget.video)_CallButton(icon:camera?Icons.videocam_rounded:Icons.videocam_off_rounded,label:'Camera',active:!camera,onTap:()=>setState(()=>camera=!camera)),_CallButton(icon:Icons.call_end_rounded,label:'End',active:true,color:_red,onTap:()=>Navigator.pop(context))]),const SizedBox(height:28)]))])));}}

class _CallButton extends StatelessWidget{final IconData icon;final String label;final bool active;final VoidCallback onTap;final Color? color;const _CallButton({required this.icon,required this.label,required this.active,required this.onTap,this.color});@override Widget build(BuildContext context)=>Column(children:[InkWell(onTap:onTap,borderRadius:BorderRadius.circular(32),child:Container(width:58,height:58,decoration:BoxDecoration(shape:BoxShape.circle,color:color??(active?Colors.white24:Colors.white12)),child:Icon(icon,color:Colors.white))),const SizedBox(height:6),Text(label,style:const TextStyle(color:Colors.white70,fontSize:9))]);}
class _MapPin extends StatelessWidget{final Color color;final IconData icon;const _MapPin({required this.color,required this.icon});@override Widget build(BuildContext context)=>Container(decoration:BoxDecoration(color:color,shape:BoxShape.circle,border:Border.all(color:Colors.white,width:3),boxShadow:[BoxShadow(color:color.withOpacity(.3),blurRadius:12)]),child:Icon(icon,color:Colors.white,size:20));}
class _LiveChip extends StatelessWidget{final Color color;const _LiveChip({required this.color});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:color.withOpacity(.14),borderRadius:BorderRadius.circular(20)),child:Row(mainAxisSize:MainAxisSize.min,children:[Container(width:6,height:6,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:5),Text('LIVE',style:TextStyle(color:color,fontSize:8.5,fontWeight:FontWeight.w900))]));}
class _GlassLabel extends StatelessWidget{final String text;final Color color;const _GlassLabel(this.text,{required this.color});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:const Color(0xCC071B22),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white24)),child:Text(text,style:TextStyle(color:color,fontSize:8.5,fontWeight:FontWeight.w900)));}
class _StatusChip extends StatelessWidget{final String text;final Color color;const _StatusChip({required this.text,required this.color});@override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(maxWidth:150),padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:color.withOpacity(.1),borderRadius:BorderRadius.circular(8)),child:Text(text,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:color,fontSize:8,fontWeight:FontWeight.w800)));}
class _CommsRoom extends StatelessWidget{final String title;final Color accent;final bool dark;final VoidCallback onVoice;final VoidCallback onVideo;const _CommsRoom({required this.title,required this.accent,required this.dark,required this.onVoice,required this.onVideo});@override Widget build(BuildContext context){final fg=dark?Colors.white:const Color(0xFF102027);return Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:dark?const Color(0xFF102A33):Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:dark?Colors.white12:const Color(0xFFE5ECEE))),child:Row(children:[CircleAvatar(backgroundColor:accent.withOpacity(.1),child:Icon(Icons.podcasts_rounded,color:accent)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:fg,fontWeight:FontWeight.w900,fontSize:12)),const Text('Available now · secure',style:TextStyle(color:Colors.grey,fontSize:9))])),IconButton(onPressed:onVoice,icon:Icon(Icons.call_rounded,color:accent)),IconButton.filled(style:IconButton.styleFrom(backgroundColor:accent),onPressed:onVideo,icon:const Icon(Icons.videocam_rounded))]));}}
class _IntelMetric extends StatelessWidget{final String label;final String value;final Color color;final bool dark;const _IntelMetric({required this.label,required this.value,required this.color,required this.dark});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:dark?const Color(0xFF102A33):Colors.white,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(color:color,fontSize:8,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(value,style:TextStyle(color:dark?Colors.white:const Color(0xFF102027),fontSize:18,fontWeight:FontWeight.w900))]));}

String _opsTitle(String r)=>switch(r){'Rescue Team'=>'Live missions map','Authority'=>'District incident command','Volunteer'=>'Field mission network','Organization'=>'Relief request network',_=>'Operations'};
IconData _roleIcon(String r)=>switch(r){'Rescue Team'=>Icons.health_and_safety_rounded,'Authority'=>Icons.account_balance_rounded,'Volunteer'=>Icons.volunteer_activism_rounded,'Organization'=>Icons.warehouse_rounded,_=>Icons.person_rounded};
String _primaryLabel(String r)=>switch(r){'Rescue Team'=>'Dispatch','Authority'=>'Verify','Volunteer'=>'Accept task','Organization'=>'Reserve',_=>'Acknowledge'};
IconData _primaryIcon(String r)=>switch(r){'Rescue Team'=>Icons.emergency_share_rounded,'Authority'=>Icons.verified_rounded,'Volunteer'=>Icons.task_alt_rounded,'Organization'=>Icons.inventory_2_rounded,_=>Icons.check_rounded};
List<String> _rooms(String r)=>switch(r){'Rescue Team'=>['Field Command','Medical Desk','District EOC'],'Authority'=>['District Command','Rescue Commander','Public Information Cell'],'Volunteer'=>['Volunteer Alpha','Camp Coordinator','Rescue Liaison'],'Organization'=>['Camp Operations','District Logistics','Partner Coordination'],_=>['Response Desk']};
String _intelHeadline(String r)=>switch(r){'Rescue Team'=>'Victim + terrain intelligence','Authority'=>'District evidence picture','Volunteer'=>'Mission relevance intelligence','Organization'=>'Demand + capacity intelligence',_=>'Risk intelligence'};
String _toolkitTitle(String r)=>switch(r){'Rescue Team'=>'Field kit','Authority'=>'Command tools','Volunteer'=>'Mission kit','Organization'=>'Logistics toolkit',_=>'Toolkit'};
String _toolkitHero(String r)=>switch(r){'Rescue Team'=>'Responder tools ready','Authority'=>'District controls synchronized','Volunteer'=>'Field tools ready for mission','Organization'=>'Resources ready to allocate',_=>'Operational tools ready'};
List<(IconData,String,String)> _tools(String r)=>switch(r){'Rescue Team'=>[(Icons.medical_services_rounded,'Triage board','Prioritise victims'),(Icons.route_rounded,'Responder route','Avoid red zones'),(Icons.flight_rounded,'Aerial request','Request reconnaissance'),(Icons.offline_bolt_rounded,'Offline mesh','Keep team connected')],'Authority'=>[(Icons.campaign_rounded,'Broadcast','Send verified warning'),(Icons.polyline_rounded,'Risk zones','Edit affected perimeter'),(Icons.hub_rounded,'Resources','Reallocate capacity'),(Icons.history_rounded,'Audit trail','Review incident decisions')],'Volunteer'=>[(Icons.qr_code_scanner_rounded,'Check-in','Verify field arrival'),(Icons.local_shipping_rounded,'Delivery','Track supply handoff'),(Icons.add_a_photo_rounded,'Evidence','Upload field proof'),(Icons.groups_rounded,'Team','View nearby volunteers')],'Organization'=>[(Icons.apartment_rounded,'Shelters','Update occupancy'),(Icons.inventory_2_rounded,'Inventory','Commit supplies'),(Icons.local_shipping_rounded,'Transport','Assign vehicle'),(Icons.handshake_rounded,'Partners','Coordinate fulfillment')],_=>[]};
