# Quality checks

Before merging changes, run the standard Flutter checks from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
```

`flutter analyze` catches static-analysis issues configured by the project, while `flutter test` runs the automated test suite. Keep generated files and local secrets out of commits, and fix analyzer warnings introduced by a change before merging it.
