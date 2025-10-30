fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### lint

```sh
[bundle exec] fastlane lint
```

Does a static analysis of the project. Configure the options in .swiftlint.yml

### changelog

```sh
[bundle exec] fastlane changelog
```

Create a file with the Changelog output between a specific TAG and HEAD

----


## iOS

### ios test_sdk

```sh
[bundle exec] fastlane ios test_sdk
```

Run tests for TelnyxVoiceAIWidget SDK

### ios test_sample_app

```sh
[bundle exec] fastlane ios test_sample_app
```

Run tests for SampleApp

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run all tests (SDK + SampleApp)

### ios build_sdk

```sh
[bundle exec] fastlane ios build_sdk
```

Build TelnyxVoiceAIWidget framework only

### ios build_sample_app

```sh
[bundle exec] fastlane ios build_sample_app
```

Build SampleApp only

### ios ci

```sh
[bundle exec] fastlane ios ci
```

Run SwiftLint and all tests

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build framework for release

### ios prepare_release

```sh
[bundle exec] fastlane ios prepare_release
```

Prepare release - lint, test, and build

### ios generate_docs

```sh
[bundle exec] fastlane ios generate_docs
```

Generate documentation using Jazzy - HTML docs

### ios generate_docs_markdown

```sh
[bundle exec] fastlane ios generate_docs_markdown
```

Generate documentation using SourceDocs - Markdown docs

### ios generate_full_docs

```sh
[bundle exec] fastlane ios generate_full_docs
```

Generate HTML and Markdown documentation

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
