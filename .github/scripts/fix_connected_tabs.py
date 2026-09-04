from pathlib import Path
import re

p = Path('lib/connected_role_tabs.dart')
s = p.read_text(encoding='utf-8')

replacement = r'''class ConnectedToolkitTab extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : const Color(0xFF102027);
    final sub = dark ? Colors.white60 : Colors.black54;
    final tools = _tools(roleName);

    return SafeArea(
      child: Material(
        color: background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _toolkitTitle(roleName),
              style: TextStyle(
                color: fg,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Operational tools connected to the same incident network',
              style: TextStyle(color: sub, fontSize: 10.5),
            ),
            const SizedBox(height: 14),
            Container(
              height: 150,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [accent, secondary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GlassLabel(
                    'READY FOR DEPLOYMENT',
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Text(
                    _toolkitHero(roleName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Actions are recorded in the shared response timeline',
                    style: TextStyle(color: Colors.white70, fontSize: 9.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, i) {
                final tool = tools[i];
                return Material(
                  color: dark ? const Color(0xFF102A33) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${tool.$2} action recorded in JeevanSetu network',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            tool.$1,
                            color: i.isEven ? accent : secondary,
                          ),
                          const Spacer(),
                          Text(
                            tool.$2,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            tool.$3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: sub, fontSize: 8.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<List<NetworkIncident>>(
              valueListenable: JeevanNetwork.instance.incidents,
              builder: (context, items, _) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF102A33) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hub_rounded, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${items.length} incidents synchronized',
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Citizen · Rescue · Authority · Volunteer · Organization',
                              style: TextStyle(color: sub, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkCallPage'''

s, count = re.subn(
    r'class ConnectedToolkitTab extends StatelessWidget \{.*?class NetworkCallPage',
    replacement,
    s,
    count=1,
    flags=re.S,
)
if count != 1:
    raise SystemExit('ConnectedToolkitTab block not found')

s = s.replace('widget.video?.28:.08', 'widget.video ? .28 : .08')

p.write_text(s, encoding='utf-8')
print('Connected tab syntax fixes applied')
