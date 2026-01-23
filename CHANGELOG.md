## [Unreleased]

## [1.4.0] - 2026-01-23

### Changed
- Updated Ruby version requirement from `>= 3.0.0` to `>= 3.2.0` (required for Rails 8.1 compatibility)
- Maintained Rails compatibility: supports Rails `>= 6.1.4.1` including Rails 8.1
- Maintained ActiveSupport compatibility: supports ActiveSupport `>= 6.1.4.1` including Rails 8.1
- Maintained RSpec Rails compatibility: supports RSpec Rails `>= 5.0.2` (tested with Rails 8.1)
- Updated RuboCop to `~> 1.65` and updated TargetRubyVersion to 3.2
- Updated Rake to `~> 13.2`
- Updated Diffy to `~> 3.4`
- Updated all transitive dependencies to latest compatible versions
- Verified compatibility with Rails 8.1.2 while maintaining support for older Rails versions
- Added `rubygems_mfa_required` metadata for enhanced security

### Fixed
- Fixed RuboCop style violations (trailing commas, empty literals, symbol proc usage)
- Fixed module function style (changed `extend self` to `module_function`)

## [0.1.0] - 2021-08-24

- Initial release
