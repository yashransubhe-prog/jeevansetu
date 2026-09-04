from pathlib import Path

p=Path('lib/judge_experience.dart')
s=p.read_text(encoding='utf-8')
s=s.replace('      RoleCommunications(role: widget.role, config: config),','      ProfessionalRoleCommunications(role: widget.role, config: config),',1)
marker='// PROFESSIONAL_COMMS_V1'
if marker not in s:
    s += r'''

// PROFESSIONAL_COMMS_V1 -----------------------------------------------------
class ProfessionalRoleCommunications extends StatefulWidget {
  final ExperienceRole role;
  final RoleConfig config;
  const ProfessionalRoleCommunications({super.key, required this.role, required this.config});

  @override
  State<ProfessionalRoleCommunications> createState()=>_ProfessionalRoleCommunicationsState();
}

class _ProfessionalRoleCommunicationsState extends State<ProfessionalRoleCommunications>{
  int latency=42;
  int participants=6;
  Timer? timer;
  @override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:3),(_){if(mounted)setState((){latency=34+(latency+7)%24;participants=5+(participants+1)%4;});});}
  @override void dispose(){timer?.cancel();super.dispose();}

  @override Widget build(BuildContext context){
    final c=widget.config; final role=widget.role; final tc=c.dark?Colors.white:ink; final sc=c.dark?Colors.white60:Colors.black54;
    final rooms=switch(role){
      ExperienceRole.rescue=>[('Field Command','Unit leaders + dispatch',Icons.podcasts_rounded),('Medical Desk','Hospital + field medic',Icons.medical_services_rounded),('Citizen SOS #2481','Live rescue subject',Icons.sos_rounded)],
      ExperienceRole.authority=>[('District Command','District operations room',Icons.account_balance_rounded),('Ward Officers','Local authority network',Icons.groups_rounded),('Public Information Cell','Broadcast coordination',Icons.campaign_rounded)],
      ExperienceRole.volunteer=>[('Volunteer Team Alpha','6 nearby teammates',Icons.groups_rounded),('Camp Coordinator','Melamchi relief hub',Icons.home_work_rounded),('Field Mentor','Safety supervision',Icons.shield_rounded)],
      ExperienceRole.organization=>[('Camp Operations','Shelter desk + medical',Icons.apartment_rounded),('Partner Coordination','4 partner organisations',Icons.handshake_rounded),('Logistics Driver','Vehicle JS-L12',Icons.local_shipping_rounded)],
      ExperienceRole.citizen=>[('Response Desk','District response',Icons.support_agent_rounded)]};
    return SafeArea(child:Material(color:c.background,child:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:Text(c.tabs[2],style:TextStyle(color:tc,fontSize:24,fontWeight:FontWeight.w900))),const Pill(label:'ENCRYPTED',color:green)]),
      Text('Voice, video and operational radio with live channel health',style:TextStyle(color:sc,fontSize:10.5)),
      const SizedBox(height:14),
      Container(height:190,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22)),child:Stack(fit:StackFit.expand,children:[
        FastPhoto(role==ExperienceRole.rescue?rescueImage:mountainImage),
        DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.black.withValues(alpha:.12),const Color(0xE8061B24)]))),
        Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Pill(label:'SECURE RESPONSE MESH',color:c.accent,dark:true),
          const Spacer(),
          Text(_commsHeadline(role),style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),
          const SizedBox(height:4),
          Text('$participants participants · $latency ms latency · voice + video ready',style:const TextStyle(color:Colors.white70,fontSize:10)),
          const SizedBox(height:10),
          LinearProgressIndicator(value:.92,minHeight:6,color:green,backgroundColor:Colors.white12,borderRadius:BorderRadius.circular(9)),
        ]))
      ])),
      const SizedBox(height:13),
      ...rooms.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:SurfaceCard(child:Row(children:[
        CircleAvatar(radius:24,backgroundColor:c.accent.withValues(alpha:.1),child:Icon(e.value.$3,color:c.accent)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.value.$1,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),Text(e.value.$2,style:const TextStyle(color:Colors.black45,fontSize:9.3)),const SizedBox(height:4),Row(children:[const CircleAvatar(radius:3,backgroundColor:green),const SizedBox(width:5),Text(e.key==0?'LIVE CHANNEL':'AVAILABLE NOW',style:const TextStyle(color:green,fontSize:8,fontWeight:FontWeight.w900))])])),
        IconButton(onPressed:()=>Navigator.push(context,premiumRoute(InAppCallPage(title:e.value.$1,video:false))),icon:const Icon(Icons.call_rounded)),
        IconButton.filled(style:IconButton.styleFrom(backgroundColor:c.accent),onPressed:()=>Navigator.push(context,premiumRoute(InAppCallPage(title:e.value.$1,video:true))),icon:const Icon(Icons.videocam_rounded)),
      ])))),
      const SizedBox(height:4),
      SurfaceCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Channel health',style:TextStyle(fontWeight:FontWeight.w900,fontSize:14)),const SizedBox(height:10),
        _CommsHealth('Voice bridge',.98,green),const SizedBox(height:8),_CommsHealth('Video uplink',.91,blue),const SizedBox(height:8),_CommsHealth('Offline radio fallback',.87,orange),
      ])),
    ])));
  }
  String _commsHeadline(ExperienceRole r)=>switch(r){ExperienceRole.rescue=>'Field command stays connected',ExperienceRole.authority=>'One district, one command channel',ExperienceRole.volunteer=>'Stay linked to your team',ExperienceRole.organization=>'Partners and facilities in one room',ExperienceRole.citizen=>'Response channel'};
}

class _CommsHealth extends StatelessWidget{final String label;final double value;final Color color;const _CommsHealth(this.label,this.value,this.color);@override Widget build(BuildContext context)=>Row(children:[SizedBox(width:125,child:Text(label,style:const TextStyle(fontSize:9.7,fontWeight:FontWeight.w800))),Expanded(child:LinearProgressIndicator(value:value,minHeight:6,color:color,backgroundColor:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(8))),const SizedBox(width:8),Text('${(value*100).round()}%',style:TextStyle(color:color,fontSize:9,fontWeight:FontWeight.w900))]);}
'''
p.write_text(s,encoding='utf-8')
print('professional comms applied')
