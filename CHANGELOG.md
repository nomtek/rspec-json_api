## [Unreleased]

## [1.5.0] - 2026-06-05

### Added
- CI compatibility matrix across Ruby 3.2–3.4 and Rails 6.1, 7.1, 7.2, 8.0 and 8.1 (`gemfiles/` + GitHub Actions matrix), so the advertised version support is actually tested.
- `RSpec::JsonApi::Constraints` module encapsulating the schema `Proc` options DSL.
- `RSpec::JsonApi::SchemaMatch` as the single comparison entry point, and `RSpec::JsonApi::Traversal` for the internal structural helpers.

### Changed
- Depend on `railties` instead of the full `rails` meta-gem; the gem only uses ActiveSupport core extensions and `Rails::Generators`. Drops the dependency graph from 87 to 65 gems. The `>= 6.1.4.1` floor is unchanged.
- Unified array and hash comparison behind `SchemaMatch`; removed the duplicate `CompareArray` and `CompareHash` modules.
- Stopped monkey-patching core `Hash`/`Array`; `deep_keys`, `deep_key_paths`, `deep_sort` and `sanitize!` moved into the internal `Traversal` module.
- The failure diff is now built lazily, only when a match fails.
- An unsupported schema `Proc` option now raises `ArgumentError` instead of being silently ignored.
- Generators emit `# frozen_string_literal: true` and freeze the generated interface hash.

### Fixed
- Require `uri` so the built-in types load on Ruby 4.0 (previously raised `NameError` on load).
- Anchor the `UUID` type with `\A...\z` so multiline strings no longer pass validation.
- Rescue invalid JSON in `match_json_schema` instead of raising `JSON::ParserError`.
- Avoid a `TypeError` when a schema expects a nested object but the actual value is a scalar.
- Enforce key structure for interface-array elements; an element with an extra null-valued key no longer matches.
- Reset the memoized diff at the start of `matches?` so a reused matcher reflects the current actual value.
- Use `Regexp#match?` for regex comparison so it returns a Boolean instead of a match index.

### Removed
- Dead/broken `interface.erb` generator template.

## [1.4.0] - 2026-01-23

### Changed
- Updated Ruby version requirement from `>= 3.0.0` to `>= 3.2.0` (required for Rails 8.1 compatibility)
- Maintained Rails compatibility: supports Rails `>= 6.1.4.1` including Rails 8.1
- Maintained ActiveSupport compatibility: supports ActiveSupport `>= 6.1.4.1` including Rails 8.1
- Maintained RSpec Rails compatibility: supports RSpec Rails `>= 5.0.2` (tested with Rails 8.1)
- Updated Bundler from 2.2.19 to 4.0.4 (latest version as of January 2026)
- Updated RuboCop to `~> 1.65` and updated TargetRubyVersion to 3.2
- Updated Rake to `~> 13.2`
- Updated Diffy to `~> 3.4`
- Updated all transitive dependencies to latest compatible versions
- Verified compatibility with Rails 8.1.2 while maintaining support for older Rails versions
- Added `rubygems_mfa_required` metadata for enhanced security
- Updated GitHub Actions CI workflow to use Ruby 3.2.2 and Bundler 4.0.4

### Fixed
- Fixed RuboCop style violations (trailing commas, empty literals, symbol proc usage)
- Fixed module function style (changed `extend self` to `module_function`)
- Fixed line endings in Gemfile (CRLF to LF)
- Fixed CI workflow bundler version mismatch
- Fixed README typos and improved code examples consistency

## [0.1.0] - 2021-08-24

- Initial release
