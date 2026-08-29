# Developer & AI Agent Workflow Guide

This guide details command line workflows, verification steps, and feature implementation patterns.

---

## 1. Useful Commands

### Dependencies & Setup
```bash
# Get all packages
flutter pub get

# Code generation (Isar models)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Verification & Quality
```bash
# Analyze code for static errors and lint violations
flutter analyze

# Run unit and widget tests
flutter test

# Build debug Android package
flutter build apk --debug
```

---

## 2. Common Implementation Patterns

### Adding a New Screen
1. Create screen in `lib/ui/screens/my_screen.dart` extending `ConsumerWidget`.
2. Access state using `ref.watch(myProvider)`.
3. Extract widgets longer than ~50 lines into `lib/ui/widgets/`.

### Adding a New Database Property
1. Add property to model in `lib/data/models/*.dart`.
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`.
3. Add unit test in `test/` verifying the new property behavior.
4. Run `flutter analyze` and `flutter test`.
