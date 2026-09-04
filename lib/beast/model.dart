import 'package:flutter/material.dart';

enum UserRole { citizen, rescue, authority, volunteer, organization }
enum IncidentStage { submitted, verification, dispatched, onSite, rescued, relief, completed }
enum AppLanguage { english, hindi, nepali }

const kNavy = Color(0xFF063847);
const kDeep = Color(0xFF03232D);
const kCyan = Color(0xFF22C7D9);
const kGreen = Color(0xFF20C98A);
const kRed = Color(0xFFFF3B55);
const kOrange = Color(0xFFFFA42E);
const kBlue = Color(0xFF4387F4);
const kPurple = Color(0xFF7758DF);

extension UserRoleInfo on UserRole {
  Color get color {
    switch (this) {
      case UserRole.citizen:
        return kGreen;
      case UserRole.rescue:
        return kRed;
      case UserRole.authority:
        return kBlue;
      case UserRole.volunteer:
        return kPurple;
      case UserRole.organization:
        return kOrange;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.citizen:
        return Icons.person_rounded;
      case UserRole.rescue:
        return Icons.health_and_safety_rounded;
      case UserRole.authority:
        return Icons.account_balance_rounded;
      case UserRole.volunteer:
        return Icons.volunteer_activism_rounded;
      case UserRole.organization:
        return Icons.business_rounded;
    }
  }
}

class Incident {
  Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.createdAt,
    required this.people,
    required this.medical,
    this.stage = IncidentStage.submitted,
    this.verified = false,
    this.rescueTeam = 'Unassigned',
    this.volunteerTeam = 'Unassigned',
    this.reliefAllocation = 'Not allocated',
    this.evidencePath,
  });

  final String id;
  final String type;
  final String description;
  final String location;
  final DateTime createdAt;
  final int people;
  final bool medical;
  String? evidencePath;
  IncidentStage stage;
  bool verified;
  String rescueTeam;
  String volunteerTeam;
  String reliefAllocation;
}

class IncidentEvent {
  IncidentEvent({
    required this.incidentId,
    required this.actor,
    required this.text,
    required this.color,
    required this.time,
  });

  final String incidentId;
  final String actor;
  final String text;
  final Color color;
  final DateTime time;
}

class IncidentMessage {
  IncidentMessage({
    required this.incidentId,
    required this.sender,
    required this.text,
    required this.time,
  });

  final String incidentId;
  final String sender;
  final String text;
  final DateTime time;
}

class AppModel extends ChangeNotifier {
  bool darkMode = false;
  AppLanguage language = AppLanguage.english;
  int _serial = 1023;

  final List<Incident> incidents = <Incident>[
    Incident(
      id: 'JS1023',
      type: 'Landslide / trapped',
      description: 'Two people trapped near an unstable slope after heavy rainfall.',
      location: 'Sindhupalchok · Ward 8',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      people: 2,
      medical: true,
      stage: IncidentStage.verification,
    ),
  ];

  final List<IncidentEvent> events = <IncidentEvent>[];
  final List<IncidentMessage> messages = <IncidentMessage>[];

  AppModel() {
    events.addAll(<IncidentEvent>[
      IncidentEvent(
        incidentId: 'JS1023',
        actor: 'Citizen',
        text: 'Incident reported with live location',
        color: kGreen,
        time: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      IncidentEvent(
        incidentId: 'JS1023',
        actor: 'AI Sentinel',
        text: 'Slope-risk overlap detected · confidence 94%',
        color: kPurple,
        time: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ]);

    messages.addAll(<IncidentMessage>[
      IncidentMessage(
        incidentId: 'JS1023',
        sender: 'Citizen',
        text: 'We are beside the road. Rocks are still falling.',
        time: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
      IncidentMessage(
        incidentId: 'JS1023',
        sender: 'System',
        text: 'Shared response room opened for all five roles.',
        time: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
    ]);
  }

  String tr(String key) {
    final table = <String, List<String>>{
      'chooseRole': <String>['Choose your role', 'अपनी भूमिका चुनें', 'आफ्नो भूमिका छान्नुहोस्'],
      'connected': <String>['One incident. One connected response.', 'एक घटना। एक जुड़ी हुई प्रतिक्रिया।', 'एउटै घटना। एउटै जोडिएको प्रतिक्रिया।'],
      'continue': <String>['Continue', 'आगे बढ़ें', 'अगाडि बढ्नुहोस्'],
      'skip': <String>['Skip', 'छोड़ें', 'छोड्नुहोस्'],
      'citizen': <String>['Citizen', 'नागरिक', 'नागरिक'],
      'rescue': <String>['Rescue Team', 'बचाव दल', 'उद्धार टोली'],
      'authority': <String>['Authority', 'प्राधिकरण', 'प्राधिकरण'],
      'volunteer': <String>['Volunteer', 'स्वयंसेवक', 'स्वयंसेवक'],
      'organization': <String>['Organization', 'संगठन', 'संस्था'],
    };
    final index = language.index;
    return table[key]?[index] ?? key;
  }

  String roleName(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return tr('citizen');
      case UserRole.rescue:
        return tr('rescue');
      case UserRole.authority:
        return tr('authority');
      case UserRole.volunteer:
        return tr('volunteer');
      case UserRole.organization:
        return tr('organization');
    }
  }

  void setDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void setLanguage(AppLanguage value) {
    language = value;
    notifyListeners();
  }

  Incident createIncident({
    required String type,
    required String description,
    required int people,
    required bool medical,
    String? evidencePath,
  }) {
    _serial += 1;
    final incident = Incident(
      id: 'JS$_serial',
      type: type,
      description: description.trim().isEmpty ? 'Citizen requested emergency support.' : description.trim(),
      location: 'Sindhupalchok · Live GPS',
      createdAt: DateTime.now(),
      people: people,
      medical: medical,
      evidencePath: evidencePath,
    );
    incidents.insert(0, incident);
    addEvent(incident, 'Citizen', 'Report submitted with GPS and emergency details', kGreen);
    addEvent(incident, 'System', 'Automatically shared with Authority, Rescue, Volunteer and Organization', kCyan);
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: 'System',
      text: 'Shared incident room opened.',
      time: DateTime.now(),
    ));
    notifyListeners();
    return incident;
  }

  void verify(Incident incident) {
    incident.verified = true;
    incident.stage = IncidentStage.verification;
    addEvent(incident, 'Authority', 'Incident verified · rescue dispatch authorised', kBlue);
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: 'Authority',
      text: 'Incident verified. Rescue dispatch authorised.',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void dispatch(Incident incident) {
    incident.rescueTeam = 'Rescue Alpha 04';
    incident.stage = IncidentStage.dispatched;
    addEvent(incident, 'Rescue Team', 'Rescue Alpha 04 dispatched · ETA 8 min', kRed);
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: 'Rescue Team',
      text: 'We are en route. ETA 8 minutes.',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void markOnSite(Incident incident) {
    incident.stage = IncidentStage.onSite;
    addEvent(incident, 'Rescue Team', 'Response unit reached the incident location', kRed);
    notifyListeners();
  }

  void markRescued(Incident incident) {
    incident.stage = IncidentStage.rescued;
    addEvent(incident, 'Rescue Team', '${incident.people} people marked rescued', kGreen);
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: 'Rescue Team',
      text: 'Rescue complete. Requesting relief handoff.',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void acceptVolunteerTask(Incident incident) {
    incident.volunteerTeam = 'Volunteer Unit V-12';
    addEvent(incident, 'Volunteer', 'Ground support accepted by Unit V-12', kPurple);
    notifyListeners();
  }

  void allocateRelief(Incident incident) {
    incident.reliefAllocation = 'Melamchi Relief Hub · beds + medical desk';
    if (incident.stage.index < IncidentStage.relief.index) {
      incident.stage = IncidentStage.relief;
    }
    addEvent(incident, 'Organization', 'Shelter, food and medical support allocated', kOrange);
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: 'Organization',
      text: 'Relief hub ready. Beds and medical desk reserved.',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void closeIncident(Incident incident) {
    incident.stage = IncidentStage.completed;
    addEvent(incident, 'Authority', 'Incident closed after rescue and relief confirmation', kBlue);
    notifyListeners();
  }

  void addMessage(Incident incident, String sender, String text) {
    if (text.trim().isEmpty) return;
    messages.add(IncidentMessage(
      incidentId: incident.id,
      sender: sender,
      text: text.trim(),
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void addEvent(Incident incident, String actor, String text, Color color) {
    events.add(IncidentEvent(
      incidentId: incident.id,
      actor: actor,
      text: text,
      color: color,
      time: DateTime.now(),
    ));
  }
}

class AppScope extends InheritedNotifier<AppModel> {
  const AppScope({
    super.key,
    required AppModel model,
    required super.child,
  }) : super(notifier: model);

  static AppModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}

String stageLabel(IncidentStage stage) {
  switch (stage) {
    case IncidentStage.submitted:
      return 'Report submitted';
    case IncidentStage.verification:
      return 'Under verification';
    case IncidentStage.dispatched:
      return 'Rescue dispatched';
    case IncidentStage.onSite:
      return 'Team on site';
    case IncidentStage.rescued:
      return 'People rescued';
    case IncidentStage.relief:
      return 'Relief & recovery';
    case IncidentStage.completed:
      return 'Completed';
  }
}
