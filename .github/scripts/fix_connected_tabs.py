from pathlib import Path

p = Path('lib/connected_role_tabs.dart')
s = p.read_text(encoding='utf-8')

s = s.replace("]))\n  ]))));}\n}\n\nclass NetworkCallPage", "])))\n  ]))));}\n}\n\nclass NetworkCallPage", 1)
s = s.replace("widget.video?.28:.08", "widget.video ? .28 : .08")

p.write_text(s, encoding='utf-8')
print('Connected tab syntax fixes applied')
