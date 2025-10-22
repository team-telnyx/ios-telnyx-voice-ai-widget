# Development Guidelines for Claude Code

This document provides guidelines for AI assistants (like Claude) when working on this codebase.

## Code Quality Standards

### SwiftLint Configuration

This project uses **SwiftLint** to enforce code quality and style consistency. All code must adhere to the rules defined in `.swiftlint.yml`.

#### Before Writing Code

1. **Review** the `.swiftlint.yml` file to understand the project's coding standards
2. **Follow** the enabled rules when writing new code
3. **Avoid** patterns that violate the disabled rules
4. **Run** SwiftLint to verify compliance: `swiftlint lint`

#### Key Rules to Follow

**Enabled Rules:**
- **Sorted imports**: All imports must be alphabetically sorted
- **No force unwrapping**: Avoid using `!` operator; use safe optional handling
- **Multiline parameters**: Each parameter should be on a separate line
- **Proper spacing**: Consistent operator spacing and formatting
- **Code documentation**: Public APIs must have documentation comments
- **No redundant type annotations**: Don't specify type when it can be inferred (e.g., `let x: Int = Int()` → `let x = Int()`)

**Disabled Rules (avoid these patterns):**
- **explicit_type_interface**: Don't add type annotations when values are assigned (they make code verbose)
- **implicitly_unwrapped_optional**: Acceptable in XCTest setup methods
- **type_body_length**: Large test files are acceptable
- **multiple_closures_with_trailing_closure**: SwiftUI patterns often require this

#### Code Examples

**✅ Good Code:**
```swift
import AVFoundation
import Combine
import Foundation

class MyClass {
    /// Documentation for public API
    public func process(
        name: String,
        age: Int,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard let user = createUser(name: name, age: age) else {
            completion(.failure(UserError.invalidData))
            return
        }
        completion(.success(user))
    }
}
```

**❌ Bad Code:**
```swift
import Foundation
import Combine  // Not sorted
import AVFoundation

class MyClass {
    public func process(name: String, age: Int, completion: @escaping (Result<User, Error>) -> Void) {  // Not multiline
        let user = createUser(name: name, age: age)!  // Force unwrap
        completion(.success(user))
    }
}
```

#### Running SwiftLint

```bash
# Lint all files
swiftlint lint

# Auto-fix violations where possible
swiftlint --fix

# Run via Fastlane
fastlane lint
```

### Project Structure

```
TelnyxVoiceAIWidget/
├── TelnyxVoiceAIWidget/          # SDK source code
├── Tests/                        # Unit tests
├── SampleApp/                    # Sample application
├── .swiftlint.yml                # SwiftLint configuration (READ THIS FIRST)
└── fastlane/                     # CI/CD configuration
```

## Best Practices

1. **Always check SwiftLint** before committing code
2. **Read the `.swiftlint.yml`** file before making changes
3. **Follow Swift best practices** for naming, structure, and patterns
4. **Document public APIs** with clear, concise comments
5. **Write tests** for new functionality
6. **Maintain consistency** with existing code style

## Workflow

When making changes:
1. Read `.swiftlint.yml` to understand rules
2. Write code following the rules
3. Run `swiftlint lint` to verify
4. Fix any violations
5. Commit changes

---

*This document helps ensure consistent code quality when AI assistants work on this codebase.*
