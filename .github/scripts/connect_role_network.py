from pathlib import Path

p = Path('lib/judge_experience.dart')
s = p.read_text(encoding='utf-8')

imp = "import 'connected_role_tabs.dart';\n"
anchor = "import 'app.dart' show LogoMark;\n"
if imp not in s:
    s = s.replace(anchor, anchor + imp)

old_pages = """    final config = RoleConfig.forRole(widget.role);\n    final pages = <Widget>[\n      ProfessionalRoleHome(role: widget.role, config: config),\n      ProfessionalRoleOperations(role: widget.role, config: config),\n      ProfessionalRoleCommunications(role: widget.role, config: config),\n      ProfessionalRoleIntelligence(role: widget.role, config: config),\n      ProfessionalRoleToolkit(role: widget.role, config: config),\n    ];"""
new_pages = """    final config = RoleConfig.forRole(widget.role);\n    final pages = <Widget>[\n      ProfessionalRoleHome(role: widget.role, config: config),\n      ConnectedOperationsTab(\n        roleName: widget.role.title,\n        accent: config.accent,\n        secondary: config.secondary,\n        background: config.background,\n        dark: config.dark,\n      ),\n      ConnectedCommunicationsTab(\n        roleName: widget.role.title,\n        accent: config.accent,\n        secondary: config.secondary,\n        background: config.background,\n        dark: config.dark,\n      ),\n      ConnectedIntelligenceTab(\n        roleName: widget.role.title,\n        accent: config.accent,\n        secondary: config.secondary,\n        background: config.background,\n        dark: config.dark,\n      ),\n      ConnectedToolkitTab(\n        roleName: widget.role.title,\n        accent: config.accent,\n        secondary: config.secondary,\n        background: config.background,\n        dark: config.dark,\n      ),\n    ];"""
if old_pages not in s:
    raise SystemExit('professional page block not found')
s = s.replace(old_pages, new_pages, 1)

old_report = "onPressed: () => setState(() => sent = true),"
new_report = """onPressed: () {\n                JeevanNetwork.instance.reportCitizenIncident(types[type]);\n                setState(() => sent = true);\n              },"""
if old_report not in s:
    raise SystemExit('citizen report action not found')
s = s.replace(old_report, new_report, 1)

old_status = "sent ? 'Report queued for verification' : 'Submit verified report',"
new_status = "sent ? 'Shared with rescue, authority & partners' : 'Submit verified report',"
s = s.replace(old_status, new_status, 1)

p.write_text(s, encoding='utf-8')
print('Connected role network patch applied')
