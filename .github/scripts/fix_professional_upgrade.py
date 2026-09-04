from pathlib import Path

p = Path('lib/judge_experience.dart')
s = p.read_text(encoding='utf-8')

bad = """                        Row(children:List.generate(3,(i)=>Expanded(child:Padding(padding:EdgeInsets.only(right:i<2?6:0),child:ChoiceChip(label:Text('${i+1}'),selected:selected==i,onSelected:(_)=>setState(()=>selected=i))))))),
"""
good = """                        Row(
                          children: List.generate(
                            3,
                            (i) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                                child: ChoiceChip(
                                  label: Text('${i + 1}'),
                                  selected: selected == i,
                                  onSelected: (_) => setState(() => selected = i),
                                ),
                              ),
                            ),
                          ),
                        ),
"""
if bad not in s:
    raise SystemExit('selector line not found')
s = s.replace(bad, good, 1)

old_title = """                Text(
                  config.tabs[2],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
"""
new_title = """                Text(
                  config.tabs[2],
                  style: TextStyle(
                    color: config.dark ? Colors.white : ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
"""
if old_title in s:
    s = s.replace(old_title, new_title, 1)

old_sub = """            const Text(
              'In-app voice, video and operational radio',
              style: TextStyle(color: Colors.black45, fontSize: 10.5),
            ),
"""
new_sub = """            Text(
              'In-app voice, video and operational radio',
              style: TextStyle(
                color: config.dark ? Colors.white60 : Colors.black54,
                fontSize: 10.5,
              ),
            ),
"""
if old_sub in s:
    s = s.replace(old_sub, new_sub, 1)

old_nav = """      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onChanged,
        backgroundColor: dark ? const Color(0xFF0A222B) : Colors.white,
        indicatorColor: accent.withValues(alpha: dark ? .24 : .14),
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i]),
            label: labels[i],
          ),
        ),
      ),
"""
new_nav = """      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: dark ? const Color(0xFF0A222B) : Colors.white,
          indicatorColor: accent.withValues(alpha: dark ? .26 : .14),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? (dark ? Colors.white : accent)
                  : (dark ? Colors.white60 : const Color(0xFF53676D)),
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected
                  ? (dark ? Colors.white : navy)
                  : (dark ? Colors.white60 : const Color(0xFF63757A)),
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onChanged,
          destinations: List.generate(
            labels.length,
            (i) => NavigationDestination(
              icon: Icon(icons[i]),
              label: labels[i],
            ),
          ),
        ),
      ),
"""
if old_nav in s:
    s = s.replace(old_nav, new_nav, 1)

p.write_text(s, encoding='utf-8')
print('fixed professional upgrade')
