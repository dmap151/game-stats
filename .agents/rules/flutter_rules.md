# Flutter Architecture & UI Rules

## 1. Riverpod 2 State Management
- Use `ConsumerWidget` with `Widget build(BuildContext context, WidgetRef ref)` for stateless reactive widgets.
- Use `ConsumerStatefulWidget` / `ConsumerState` when local widget state (e.g. `TextEditingController`, form key) is required.
- Do not mix raw `StatefulWidget` with manual provider listeners when `ConsumerStatefulWidget` is cleaner.
- Always provide explicit types for navigation callbacks and dialogs: e.g. `showModalBottomSheet<void>(...)`, `MaterialPageRoute<void>(...)`.

## 2. Modern Material 3 & Dart Lints
- **Color Methods**: Always use `color.withValues(alpha: 0.5)` instead of `color.withOpacity(0.5)`.
- **ColorScheme Tokens**:
  - Use `theme.colorScheme.surfaceContainerHighest` instead of deprecated `surfaceVariant`.
  - Use `theme.colorScheme.surface` instead of deprecated `background`.
  - Use `theme.colorScheme.onSurface` instead of deprecated `onBackground`.
- **Const Constructors**: Use `const` wherever possible on widgets, borders, and EdgeInsets.
- **Final Locals**: Declare local variables as `final` (`prefer_final_locals`).

## 3. Visual Styling & Images
- **Round Avatars**: All profile pictures and game thumbnails must be circular (`CircleAvatar` + `ClipOval(child: Image.file(...))`).
- **No Hero Transitions**: Do not wrap thumbnails in `Hero` widgets.
- **High Performance Image Loading**: Always pass `cacheWidth: 100-200` and `gaplessPlayback: true` to prevent memory thrashing on large camera images.
