# JeevanSetu

SIH 2026 prototype for PS26001 — AI-assisted landslide risk monitoring, early warning, safe routing, and coordinated disaster response for Nepal.

## What it demonstrates

JeevanSetu is a Flutter prototype focused on presenting a connected disaster-response workflow. The current app includes map-based experiences, role-oriented interfaces, and supporting assets for a landslide monitoring and response concept.

## Tech stack

- Flutter / Dart
- `flutter_map` with `latlong2` for map experiences
- `image_picker` for image selection flows
- `flutter_tts` for text-to-speech support
- Flutter lints for static-analysis guidance

## Run locally

Prerequisites: a recent Flutter SDK compatible with Dart `>=3.4.0 <4.0.0` and an Android emulator/device or another Flutter target.

```bash
flutter pub get
flutter run
```

For a quick quality check before committing changes:

```bash
flutter analyze
```

## Project structure

- `lib/` — application source and role-based experiences
- `assets/` — app icon, images, and reference assets
- `android/` — Android platform configuration
- `docs/` — supporting project documentation
- `tools/` — project utilities

## Project status

This repository contains the SIH 2026 prototype source. Features should be treated as prototype demonstrations unless they are backed by a documented production data source or service.
