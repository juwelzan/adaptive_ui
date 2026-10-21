# Contributing to Adaptive UI

Thank you for your interest in contributing to `adaptive_ui`! We welcome contributions that improve responsiveness, accessibility, stability, and developer ergonomics.

## Code of Conduct
Please be polite, collaborative, and considerate of others.

## Development Workflow
1. Fork and clone the repository.
2. Install dependencies: `flutter pub get`.
3. Create a feature branch: `git checkout -b feature/my-feature`.
4. Run tests: `flutter test`.
5. Run static analysis: `flutter analyze`.
6. Format code: `dart format lib test example`.
7. Submit a pull request with clear description and accompanying tests.

## Architecture Guidelines
- **Parent Constraints First**: Component decisions must derive from parent constraints (`LayoutBuilder`), not raw window dimensions.
- **Accessibility**: Never disable accessibility text scaling. Never shrink text beneath minimum legibility bounds.
- **Minimal Dependencies**: Rely strictly on the Flutter SDK and native Dart.
- **Documentation**: Provide clear dartdoc comments for all public classes and members.
