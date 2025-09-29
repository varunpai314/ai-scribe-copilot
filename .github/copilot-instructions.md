# MediNote AI Agent Instructions

This document provides essential guidance for AI agents working in the MediNote codebase - an AI-based medical transcription app built with Flutter.

## Project Overview

MediNote is a Flutter mobile application targeting both Android and iOS platforms, designed to provide AI-powered medical transcription capabilities. 

Key technologies:
- Flutter SDK 3.9.2+
- Kotlin for Android platform code
- Material Design for UI components
- Gradle (Kotlin DSL) for Android build configuration

## Project Structure

```
lib/               # Dart source code
  main.dart        # Application entry point
android/           # Android platform code
  app/             # Android app configuration
    build.gradle.kts   # Android build config (Kotlin DSL)
assets/            # Static assets
  medinote_logo.png
  medinote_logo_detailed.png
```

## Development Environment Setup

1. Required tools:
   - Flutter SDK ^3.35.4
   - Android SDK (for Android development)
   - VS Code with Flutter/Dart extensions

2. Initial setup:
   ```bash
   flutter pub get     # Install dependencies
   flutter run        # Run in debug mode
   ```

## Key Architectural Patterns

1. **Material Design Implementation**
   - The app follows Material Design principles using Flutter's Material components
   - Example in `main.dart` shows basic Material app structure

2. **Asset Management**
   - Static assets are declared in `pubspec.yaml` under the `flutter.assets` section
   - Access images and other assets from the `assets/` directory

3. **Platform Configuration**
   - Android configuration is managed through Kotlin DSL in `android/app/build.gradle.kts`
   - Application ID: `tech.varunpai.medinote`
   - Java/Kotlin target compatibility: Java 11

## Common Development Tasks

1. **Running the App**
   ```bash
   flutter run          # Debug mode
   flutter run --release # Release mode
   ```

2. **Adding Dependencies**
   - Add new dependencies to `pubspec.yaml`
   - Run `flutter pub get` to update dependencies

3. **Building for Release**
   - Android: Update signing configuration in `android/app/build.gradle.kts` before release builds
   - Current release config uses debug keys (needs updating for production)

## Best Practices

1. **Flutter Conventions**
   - Use `const` constructors where possible
   - Follow Material Design guidelines for consistent UI
   - Prefix private members with underscore

2. **Asset Management**
   - Add new assets under `assets/` directory
   - Register new asset directories in `pubspec.yaml`

3. **Platform Integration**
   - Android platform code goes in `android/app/src/main/`
   - Keep platform-specific code minimal and well-documented