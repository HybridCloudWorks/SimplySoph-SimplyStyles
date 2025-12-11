# Contributing Guide

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make changes
5. Run tests
6. Submit pull request

## Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code refactoring

## Commit Messages

Format: `type: description`

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code restructure
- `test:` - Tests
- `chore:` - Maintenance

Example: `feat: add image upload functionality`

## Code Standards

- Follow Dart style guide
- Run `flutter analyze` before commit
- Write tests for new features
- Update documentation

## Pull Request Process

1. Update README if needed
2. Add tests
3. Ensure CI passes
4. Request review
5. Address feedback
6. Merge when approved

## Testing

```bash
flutter test                    # Run all tests
flutter test test/file_test.dart # Run specific test
flutter test --coverage         # Generate coverage
```

## Questions?

Open an issue or contact maintainers.
