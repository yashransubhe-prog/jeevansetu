# Contributing to JeevanSetu

Thanks for contributing to JeevanSetu. This repository is an SIH 2026 Flutter prototype for landslide-risk monitoring and coordinated disaster response, so changes should stay easy to demonstrate, clearly scoped, and honest about which capabilities are prototype simulations versus production-backed data.

## Local setup

Use a recent Flutter SDK compatible with the project's Dart constraint.

```bash
flutter pub get
flutter run
```

Before submitting a change, run:

```bash
flutter analyze
```

Resolve new analyzer warnings introduced by your change.

## Contribution workflow

1. Create a short-lived branch from `main`.
2. Keep each change focused on one feature, fix, or documentation improvement.
3. Use descriptive commit messages.
4. Run the application on an appropriate Flutter target when the change affects UI or navigation.
5. Open a pull request that explains what changed and how you verified it.

Example branch names:

```text
feature/landslide-alert-card
fix/safe-route-state
docs/contribution-guide
```

## Pull-request checklist

- [ ] The change has a clear purpose.
- [ ] `flutter analyze` does not report new issues caused by the change.
- [ ] Updated screens or flows were manually exercised when applicable.
- [ ] New assets are referenced correctly from `pubspec.yaml` when required.
- [ ] No API keys, tokens, private credentials, or personal data are committed.
- [ ] Prototype or simulated data is not presented as verified live disaster data.
- [ ] Visible UI changes include a short explanation or screenshot when useful.

## Project principles

### Be explicit about prototype data

JeevanSetu demonstrates a disaster-response workflow. Do not label simulated risk scores, routes, alerts, sensor readings, or AI output as live operational data unless a documented production source actually provides them.

### Keep emergency UX clear

For alert, routing, and response screens, prioritize readability, unambiguous actions, and predictable navigation over decorative complexity.

### Protect sensitive information

Do not commit credentials, personal information, exact private locations, or other sensitive disaster-response data.

### Keep changes reviewable

Avoid mixing large formatting changes, dependency upgrades, and feature work in one pull request unless they are inseparable.

## Repository areas

- `lib/` — Flutter application source and role-based experiences
- `assets/` — app icon, images, and reference assets
- `android/` — Android platform configuration
- `docs/` — supporting project documentation
- `tools/` — project utilities

A contribution is successful when it improves the prototype while keeping the project's behavior and limitations easy to understand.
