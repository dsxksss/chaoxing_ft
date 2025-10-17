# Chaoxing Flutter Implementation Documentation

## Project Overview
This project implements the core learning functionality for Chaoxing platform by replicating chaoxing_py implementation logic in Flutter.

## Architecture
- **Clean Architecture**: Data layer, Domain layer, Presentation layer
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences + Hive
- **Network**: Dio HTTP client
- **Testing**: Unit tests, Widget tests, Integration tests

## Getting Started
See [quickstart.md](quickstart.md) for setup instructions.

## API Reference
See [contracts/](../specs/002-chaoxing-core-logic/contracts/) for API specifications.

## Platform Support
- Android 8.0+
- iOS 12.0+
- Windows 10+

## Development Guidelines
- Follow TDD approach
- Maintain ≥80% test coverage
- Use clean architecture patterns
- Replicate chaoxing_py logic exactly
