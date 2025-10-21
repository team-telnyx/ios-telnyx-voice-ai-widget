# TelnyxVoiceAIWidget Fastlane Documentation

This directory contains Fastlane configuration for the TelnyxVoiceAIWidget iOS SDK.

## Installation

Make sure you have the latest version of the Xcode command line tools installed:

```bash
xcode-select --install
```

Install dependencies:

```bash
bundle install
```

For SwiftLint functionality, install SwiftLint:

```bash
brew install swiftlint
```

## Available Actions

### Development & Testing

#### `fastlane lint`
Runs SwiftLint static analysis on the codebase. Configuration is in `.swiftlint.yml`.

#### `fastlane test_sdk`
Builds and tests the TelnyxVoiceAIWidget framework.

#### `fastlane test_sample_app`
Builds and tests the SampleApp.

#### `fastlane tests`
Runs all tests (SDK + SampleApp).

#### `fastlane ci`
Runs the complete CI pipeline: SwiftLint + all tests.

### Building

#### `fastlane build_sdk`
Builds the TelnyxVoiceAIWidget framework only (Debug configuration).

#### `fastlane build_sample_app`
Builds the SampleApp only (Debug configuration).

#### `fastlane build_release`
Builds the framework for release (Release configuration, creates archive).

### Release Management

#### `fastlane prepare_release`
Prepares a release by running: lint → tests → release build.

#### `fastlane changelog tag:TAG_NAME`
Generates a changelog between the specified tag and HEAD.

## GitHub Actions Integration

The repository includes several GitHub Actions workflows:

- **`ios_fastlane_tests.yml`**: Runs SwiftLint and tests on every PR
- **`release-01-create-pull-request.yml`**: Creates release PRs with version updates
- **`release-02-create-gh-release.yml`**: Creates GitHub releases when podspec is updated
- **`release-03-deploy-cocoapods.yml`**: Deploys to CocoaPods when releases are published

## SwiftLint Configuration

SwiftLint rules are configured in `.swiftlint.yml`. The configuration includes:

- Source paths for the SDK, tests, and sample app
- Excluded paths (build artifacts, documentation)
- Custom rule thresholds for line length, file length, etc.

## Release Process

1. Run `fastlane prepare_release` locally to ensure everything builds
2. Use the "Release 01" GitHub Action to create a release PR
3. Review and merge the release PR
4. The "Release 02" action will automatically create a GitHub release
5. The "Release 03" action will deploy to CocoaPods

----

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).