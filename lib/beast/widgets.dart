import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'model.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: children,
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: .08) : const Color(0xFFE2EBEF),
        ),
        boxShadow: dark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader(this.title, this.subtitle, {super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, this.subtitle, {super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 24, 2, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class ImageHero extends StatelessWidget {
  const ImageHero({
    super.key,
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String image;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xED032A35)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: .98,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
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

class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 26),
          Text(
            eyebrow,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String image;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE0032A35)],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w900,
                    ),
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

class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.incident, this.onTap});
  final Incident incident;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(colors: [kRed, Color(0xFFFF6070)]),
          boxShadow: [
            BoxShadow(
              color: kRed.withValues(alpha: .20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.warning_amber_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${incident.id} · ${incident.type}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(incident.location, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class IncidentProgress extends StatelessWidget {
  const IncidentProgress({super.key, required this.stage});
  final IncidentStage stage;

  @override
  Widget build(BuildContext context) {
    final value = (stage.index + 1) / IncidentStage.values.length;
    final color = stage == IncidentStage.completed ? kGreen : kCyan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ),
        const SizedBox(height: 7),
        Text(stageLabel(stage), style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.color,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final Incident incident;
  final Color color;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                child: Icon(Icons.warning_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${incident.id} · ${incident.type}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(incident.location),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          IncidentProgress(stage: incident.stage),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: onPrimary,
                  child: Text(primaryLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  const TimelineTile({super.key, required this.event});
  final IncidentEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 13,
            height: 13,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.actor,
                  style: TextStyle(color: event.color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(event.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NepalOperationalMap extends StatelessWidget {
  const NepalOperationalMap({super.key, this.showRoute = true, this.compact = false});
  final bool showRoute;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(27.951, 85.684);
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: compact ? 10.0 : 9.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jeevansetu.sih2026',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: LatLng(27.96, 85.69),
              radius: 42,
              color: kRed.withValues(alpha: .16),
              borderColor: kRed,
              borderStrokeWidth: 2,
            ),
            CircleMarker(
              point: LatLng(27.91, 85.61),
              radius: 30,
              color: kOrange.withValues(alpha: .14),
              borderColor: kOrange,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        if (showRoute)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  LatLng(27.90, 85.58),
                  LatLng(27.925, 85.62),
                  LatLng(27.94, 85.66),
                  LatLng(27.965, 85.70),
                  LatLng(27.99, 85.73),
                ],
                strokeWidth: 6,
                color: kGreen,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(27.96, 85.69),
              width: 48,
              height: 48,
              child: const Icon(Icons.location_pin, color: kRed, size: 44),
            ),
            Marker(
              point: LatLng(27.90, 85.58),
              width: 44,
              height: 44,
              child: const Icon(Icons.home_rounded, color: kGreen, size: 38),
            ),
            Marker(
              point: LatLng(27.99, 85.73),
              width: 44,
              height: 44,
              child: const Icon(Icons.local_hospital_rounded, color: kBlue, size: 36),
            ),
          ],
        ),
      ],
    );
  }
}
