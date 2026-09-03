# Roadmap

Deep review of `rspec-json_api` 1.5.0 (master at `87fddee`), done on 2026-09-03.

## How this was produced

- Read every file in the repository: library, generators, specs, gemspec, Gemfile and lockfile, appraisal gemfiles, CI workflow, RuboCop config, README and CHANGELOG.
- Ran the suite and linter on Ruby 4.0.1 with the committed `Gemfile.lock`: 63 examples, 0 failures; RuboCop 29 files, no offenses.
- Ran `bundle outdated` and `bundle-audit check --update` against `Gemfile.lock`.
- Ran a throwaway probe script that feeds edge-case schemas through `RSpec::JsonApi::Matchers::MatchJsonSchema`. Every "Confirmed" bug below quotes the exact input, so it can be reproduced in `bin/console`.

Each item is marked either **Confirmed** (reproduced or directly visible in the code) or **Suggestion** (a judgement call, an assumption, or a design proposal). Priorities follow the impact on a consumer's test suite: Critical means a valid test run crashes or a wrong response passes; High means correctness or supply-chain problems that are cheap to fix; Medium means real friction; Low means polish.

## Top ten by priority and impact

| # | Item | Priority | Effort | Status |
|---|------|----------|--------|--------|
| 1.1 | List schemas crash with `NoMethodError` when the actual value is not an array | Critical | S | Confirmed |
| 1.2 | Elements of exact arrays skip the key-structure guard (false positives) | High | S | Confirmed |
| 1.3 | `Types::URI` is unanchored, so a URI buried in prose passes | High | S | Confirmed |
| 1.4 | Matcher raises `TypeError` for `nil` or already-parsed input | High | S | Confirmed |
| 2.1 | Drop `railties` and `rspec-rails` from the runtime dependencies | High | M | Confirmed |
| 2.3 | Move the dev lockfile past 70+ open advisories | High | S | Confirmed |
| 3.1 | Report the failing key path instead of a one-line `inspect` diff | High | L | Suggestion |
| 5.1 | Close the spec gaps that let the crash paths ship | High | M | Confirmed |
| 4.1 | Optional keys and nullable values in the schema DSL | High | M | Suggestion |
| 5.2 | CI matrix exercises almost no Rails code | Medium | M | Confirmed |

## 1. Bugs to fix

### 1.1 List schemas crash when the actual value is not an array

Priority: Critical. Category: Correctness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/schema_match.rb:97-111`. `compare_typed_array` and `compare_interface_array` call `actual_value.all?` without checking the receiver. Reproduced against 1.5.0:

```ruby
match_json_schema({ notes: [String] }).matches?('{"notes":"x"}')          # NoMethodError: undefined method 'all?' for String
match_json_schema({ notes: [String] }).matches?('{"notes":null}')         # NoMethodError: undefined method 'all?' for nil
match_json_schema({ items: [{ id: Integer }] }).matches?('{"items":null}') # NoMethodError
match_json_schema({ items: [{ tags: [String] }] }).matches?('{"items":[{"tags":"b"}]}') # NoMethodError
```

**Problem and impact.** An API that returns `null` or a scalar where a list is expected is the everyday failure this gem exists to catch. Instead of a red example with a message, the consumer's suite errors out. Nested cases (probe 4) crash from inside `compare_interface_array`, so interface arrays are affected too. The 1.5.0 fix for `dig` raising `TypeError` on scalars (commit `c30eb5f`) covered objects but left the array branches with the same class of bug.

**Recommended solution.** Guard at the top of `compare_array`: `return false unless actual_value.is_a?(Array)`. Add one spec per crash input above. This also makes probe 4 fail cleanly instead of raising.

**Dependencies and risks.** None. Pure fix.

### 1.2 Elements of exact arrays skip the key-structure guard

Priority: High. Category: Correctness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/schema_match.rb:114-120`. `compare_exact_array` routes Hash elements through `compare`, not `match`, so `same_key_structure?` never runs for them. `compare` unions the key paths of both sides and compares value by value, and `nil == nil` is true. Reproduced:

```ruby
# extra null-valued key in an element: passes
match_json_schema({ c: [{ id: Integer }, { id: Integer }] })
  .matches?('{"c":[{"id":1,"x":null},{"id":2}]}')   # => true

# missing key whose schema allows blank: passes inside the array...
match_json_schema({ c: [{ id: Integer, n: -> { { type: String, allow_blank: true } } }, { id: Integer }] })
  .matches?('{"c":[{"id":1},{"id":2}]}')            # => true

# ...but the same shape is rejected at the top level
match_json_schema({ n: -> { { type: String, allow_blank: true } } }).matches?('{}')  # => false
```

**Problem and impact.** The README promises "match_json_schema always require full keys match". Inside an exact array that promise does not hold: a response with unexpected null fields, or with fields missing, passes. Commit `a79e487` fixed exactly this for interface arrays in 1.5.0 and left the exact-array branch untouched.

**Recommended solution.** In `compare_exact_array`, call `match(actual_value[index], elem)` for Hash elements (as `compare_interface_array` already does). Add the two inputs above as failing specs first.

**Dependencies and risks.** Behaviour change: suites that relied on the lax check will start failing, correctly. Note it under "Fixed" in the CHANGELOG. Pairs naturally with 3.2, which touches the same method.

### 1.3 `Types::URI` is unanchored

Priority: High. Category: Correctness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/types/uri.rb:6` uses `URI::DEFAULT_PARSER.make_regexp`, which has no `\A`/`\z` anchors. `compare_regexp` (`schema_match.rb:78-80`) uses `match?`, so any substring match wins:

```ruby
match_json_schema({ u: RSpec::JsonApi::Types::URI })
  .matches?('{"u":"not a uri but see http://example.com ok"}')  # => true
```

`Types::EMAIL` (`URI::MailTo::EMAIL_REGEXP`) is anchored and rejects the equivalent input, and `Types::UUID` was anchored in 1.5.0 (commit `ba59f62`) for the same reason. URI was missed.

**Problem and impact.** A field that should hold a URL accepts free text as long as a URL appears somewhere in it. For a type that ships as a built-in, that is a silent correctness hole.

**Recommended solution.** `URI = /\A#{URI::DEFAULT_PARSER.make_regexp}\z/`. Add a spec with a URI embedded in prose and one with leading whitespace. Consider a stricter `Types::URL` (http/https only) as a separate built-in, since `make_regexp` also accepts `mailto:` and `urn:` (see 4.4).

**Dependencies and risks.** Strings with surrounding whitespace start failing; that is the intended behaviour.

### 1.4 Matcher raises `TypeError` for `nil` or already-parsed input

Priority: High. Category: Robustness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/matchers/match_json_schema.rb:25-33` rescues only `JSON::ParserError`. `JSON.parse(nil)` and `JSON.parse({})` raise `TypeError`:

```ruby
match_json_schema({ id: String }).matches?(nil)          # TypeError: no implicit conversion of nil into String
match_json_schema({ id: String }).matches?({ id: "x" })  # TypeError: no implicit conversion of Hash into String
```

**Problem and impact.** `expect(nil).to match_json_schema(...)` is a plausible outcome of a helper that returns `nil`, and passing `JSON.parse(response.body)` or `response.parsed_body` is what request specs naturally hand over. Both crash instead of failing with a message.

**Recommended solution.** Short term: rescue `TypeError` alongside `JSON::ParserError` and set a `@parse_error` that `failure_message` prints ("expected a JSON String, got NilClass"). Longer term: accept Hash/Array input directly and objects that respond to `body` (see 4.3).

**Dependencies and risks.** None for the rescue. Accepting parsed input is a feature decision (4.3).

### 1.5 Regexp schema values ignore the value's type

Priority: Medium. Category: Correctness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/schema_match.rb:78-80` and `constraints.rb:43` call `to_s` on the actual value before matching:

```ruby
match_json_schema({ code: /\A\d+\z/ }).matches?('{"code":123}')  # => true (an Integer)
match_json_schema({ code: /.*/ }).matches?('{"code":null}')      # => true (nil.to_s == "")
```

**Problem and impact.** A regexp schema is the documented way to say "a string shaped like X". A number or `null` should not satisfy it. The `null` case is worse: a permissive regex accepts a missing value, which is what `allow_blank` exists to express explicitly.

**Recommended solution.** `actual_value.is_a?(String) && expected_value.match?(actual_value)` in both places. Document that regexp schemas imply String.

**Dependencies and risks.** Breaking for suites that regex-match numbers. Ship with 2.1 in a version that already carries a CHANGELOG "Changed" section; consider 2.0.0 for the combined set (see phasing).

### 1.6 Misused Proc schemas raise raw Ruby errors

Priority: Medium. Category: Robustness. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/constraints.rb:31-36` assumes the Proc returned a Hash; `schema_match.rb:82-84` calls the Proc with no arguments:

```ruby
match_json_schema({ a: -> { true } }).matches?('{"a":1}')        # NoMethodError: undefined method 'keys' for true
match_json_schema({ a: ->(v) { v > 1 } }).matches?('{"a":2}')    # ArgumentError: wrong number of arguments (given 0, expected 1)
```

**Problem and impact.** Both shapes are what a first-time user reaches for. The README shows the correct form (`-> { { lambda: ... } }`) but the error a user gets does not point there. 1.5.0 added `ArgumentError` for unknown option keys; the non-Hash and arity cases were not covered.

**Recommended solution.** In `validate!`, raise `ArgumentError, "schema Proc must return an options Hash, got TrueClass"` when the result is not a Hash. In `compare_proc`, either raise a clear error for arity 1, or treat an arity-1 lambda as a predicate (`condition.call(value)`), which is the more useful behaviour and a small feature.

**Dependencies and risks.** If arity-1 lambdas become predicates, document it and add specs; it overlaps with 4.2.

### 1.7 `have_no_content_spec.rb` never tests the `"{}"` case

Priority: Low. Category: Test correctness. Effort: S. Status: Confirmed.

**Evidence.** `spec/rspec/json_api/matchers/have_no_content_spec.rb:12-20` calls `let(:actual)` twice inside one context from a `%w[{} []].each` loop. The second `let` overrides the first, so both examples run with `"[]"`. Verified by printing `actual` from a copy of the block: both print `"[]"`. The `describe` string "match_empty_body matcher" is also stale; the matcher is `have_no_content`.

**Problem and impact.** One of the two negative cases is untested and the documentation-format output shows two identically named examples.

**Recommended solution.** Wrap each value in its own `context "when #{value} is given"`, and rename the top-level describe.

### 1.8 `same_key_structure?` cannot tell which parent a nested hash belongs to

Priority: Low. Category: Correctness (latent). Effort: S. Status: Suggestion.

**Evidence.** `lib/rspec/json_api/traversal.rb:15-20` flattens nested keys into the parent's list (`{a: {c: 1}, b: 2}` becomes `[:a, [:c], :b]`) and `deep_sort` (`traversal.rb:42-46`) sorts by string, so parent association is lost:

```ruby
RSpec::JsonApi::SchemaMatch.same_key_structure?({ a: 1, b: { c: "x" } }, { a: { c: String }, b: Integer })  # => true
```

**Problem and impact.** I could not turn this into an end-to-end false positive, because `compare` re-derives full key paths and catches the mismatch. But the guard is weaker than its name and comment claim, and a future refactor of `compare` could expose it.

**Recommended solution.** Compare sorted `deep_key_paths` of both sides instead of `deep_sort(deep_keys(...))`. That removes `deep_keys` and `deep_sort` entirely. Folds into 3.6.

## 2. Package and dependency updates

### 2.1 Drop `railties` and `rspec-rails` from the runtime dependencies

Priority: High. Category: Dependencies / supply chain. Effort: M. Status: Confirmed.

**Evidence.** `rspec-json_api.gemspec:35-38` declares `activesupport`, `diffy`, `railties` and `rspec-rails` as runtime dependencies. `grep -rn "rspec\|Rails" lib` shows that nothing in `lib/rspec/` references `rspec-rails` or Rails; the only Rails references are the three generator classes under `lib/generators/`, and those are only ever loaded by Rails itself (it scans `lib/generators` of bundled gems). The matcher module (`lib/rspec/json_api/matchers.rb`) only needs `RSpec::Matchers` from `rspec-expectations`.

**Problem and impact.** Every consumer pulls `actionpack`, `actionview`, `rack`, `rack-session`, `nokogiri`, `loofah`, `rails-html-sanitizer`, `crass`, `irb`, `rackup` and friends into their bundle to get a JSON matcher. In the current dev lockfile those transitive gems account for every one of the 70+ advisories `bundle-audit` reports (see 2.3). It also means a non-Rails project (Sinatra, Hanami, plain Rack) cannot use the gem without taking on `railties`. 1.5.0 already went from `rails` to `railties` (87 to 65 gems); this is the second step.

**Recommended solution.**
- Runtime: `activesupport` (until 2.2 lands), `diffy`, `rspec-expectations ~> 3.0`.
- Development: `railties`, `rspec-rails`, `rake`, `rubocop`, plus `bundler-audit` and `simplecov` (5.1, 5.3).
- Keep `lib/generators/**` where it is. Rails finds it when both the gem and Rails are in the bundle; without Rails the files are never required. Add a comment in each generator saying so.
- README: state that the generators need Rails, the matchers do not.

**Dependencies and risks.** A consumer who never listed `rspec-rails` in their own Gemfile and relied on this gem pulling it in would lose it. That is unlikely (rspec-rails is what people install first) but call it out in the CHANGELOG and bump to 2.0.0 together with 1.5 and 2.2.

### 2.2 Replace the ActiveSupport `blank?`/`present?` extension with a local helper

Priority: Medium. Category: Dependencies. Effort: S. Status: Confirmed (usage), Suggestion (removal).

**Evidence.** `lib/rspec/json_api.rb:7` requires `active_support/core_ext/object/blank`. It is used in exactly two places: `constraints.rb:24` (`value.blank?`) and `schema_match.rb:36` (`actual.blank? && expected.present?`).

**Problem and impact.** Two call sites carry `activesupport` plus its own tail (`concurrent-ruby`, `i18n`, `tzinfo`, `minitest`, `drb`, `bigdecimal`, `logger`, `securerandom`, ...). After 2.1 this would be the last heavyweight dependency; removing it leaves `diffy` and `rspec-expectations`.

**Recommended solution.** A private `RSpec::JsonApi::Blank.blank?(value)` that reproduces the semantics that matter here: `nil`, `false`, empty String/Array/Hash, and whitespace-only strings. Write the specs first (the whitespace case is what `allow_blank` users depend on), then swap the two call sites. The `schema_match.rb:36` line also deserves a second look: with `same_key_structure?` already enforced by `match`, it only fires for the exact-array path, and after 1.2 it can probably go.

**Dependencies and risks.** Requires 2.1 to be worthwhile. `blank?` on unusual objects (e.g. `BigDecimal`) is not relevant because input always comes from `JSON.parse`.

### 2.3 Move the development lockfile past open security advisories

Priority: High. Category: Security / dependencies. Effort: S. Status: Confirmed.

**Evidence.** `bundle-audit check --update` on `Gemfile.lock` (2026-09-03). Grouped by gem, with the fix version the advisory database names:

| Gem | Locked | Advisories | Fix |
|-----|--------|------------|-----|
| rack | 3.2.4 | 14 (five rated High) | >= 3.2.6 |
| nokogiri | 1.19.0 | 13 (one High) | >= 1.19.4 |
| activesupport | 8.1.2 | 3 (ReDoS, XSS, DoS in helpers) | >= 8.1.2.1 |
| actionpack / actionview | 8.1.2 | 1 each (XSS) | >= 8.1.2.1 |
| concurrent-ruby | 1.3.6 | 3 (one High) | >= 1.3.7 |
| loofah | 2.25.0 | 4 | >= 2.25.2 |
| crass | 1.0.6 | 4 | >= 1.0.7 |
| erb | 6.0.1 | 1 (High, deserialization guard bypass) | >= 6.0.4 |
| json | 2.18.0 | 2 | >= 2.19.9 |
| rails-html-sanitizer | 1.6.2 | 1 (XSS) | >= 1.7.1 |
| rack-session | 2.1.1 | 1 (session forgery) | >= 2.1.2 |

`bundle outdated` shows `railties 8.1.3.1` is available, which drags the Rails 8.1.2.1+ fixes in.

**Problem and impact.** None of these gems are used by the matcher at runtime and the lockfile does not bind consumers, so the direct exposure is the CI runner and contributor machines. Two things still make it worth doing now: `Gemfile.lock` is packaged inside the `.gem` (5.5), so a scanner pointed at the published artifact flags it, and the list is the concrete argument for 2.1.

**Recommended solution.** `bundle update --conservative rack nokogiri railties concurrent-ruby loofah crass erb json rails-html-sanitizer rack-session`, run the suite, commit the lockfile. Then add `bundle-audit` to CI (5.3) so the list does not grow back quietly.

**Dependencies and risks.** Low. All are patch-level within the ranges the Gemfile allows.

### 2.4 Routine minor updates

Priority: Low. Category: Dependencies. Effort: S. Status: Confirmed.

**Evidence.** `bundle outdated`: rubocop 1.82.1 to 1.90.0 (allowed by `~> 1.65`), rake 13.3.1 to 13.4.2, rspec-rails 8.0.2 to 8.0.4, zeitwerk 2.7.4 to 2.8.3, i18n 1.14.8 to 1.15.2, rdoc 7.1.0 to 8.0.0. Two transitive majors are available and can wait: `parallel` 2.1.0 (via rubocop) and `diff-lcs` 2.0.0 (via rspec).

**Recommended solution.** Fold into the same PR as 2.3. Newer RuboCop versions add cops under `NewCops: enable` (`.rubocop.yml:10`), so expect a few new offences to address.

### 2.5 `Gemfile` duplicates gemspec dependencies with divergent constraints

Priority: Low. Category: Dependencies / hygiene. Effort: S. Status: Confirmed.

**Evidence.** `Gemfile:10-13` re-declares `activesupport`, `diffy` and `rspec-rails` that `gemspec` (line 8) already brings in, and `diffy` is `"~> 3.4"` in the Gemfile versus `">= 3.4.2"` in the gemspec.

**Problem and impact.** Two places to keep in sync; the gemspec is the one consumers see. The appraisal gemfiles inherit the root Gemfile (`gemfiles/*.gemfile:5`), so the duplication propagates to the CI matrix.

**Recommended solution.** Keep only `gemspec`, `rake`, `rubocop` (and the new dev tools) in the Gemfile; put the rest in `add_development_dependency` after 2.1.

## 3. Code quality and architecture improvements

### 3.1 Report the failing key path instead of a one-line `inspect` diff

Priority: High. Category: Architecture / developer experience. Effort: L. Status: Suggestion.

**Evidence.** `SchemaMatch.match` (`schema_match.rb:15-28`) returns a bare Boolean with no context. `MatchJsonSchema#failure_message` (`match_json_schema.rb:37-45`) prints `expected` and `actual` with `Hash#to_s` and hands the same two strings to Diffy (`match_json_schema.rb:58-60`). Actual output for a schema with one Proc and one type mismatch:

```
expected: {id: Integer, name: String, tags: [String], nested: {x: #<Proc:0x00000001250dd0d8 /Users/.../probe.rb:50 (lambda)>}}
     got: {id: "1", name: "n", tags: ["a"], nested: {x: 0}}

Diff:
-{id: Integer, name: String, tags: [String], nested: {x: #<Proc:0x00000001250dd0d8 ...>}}
\ No newline at end of file
+{id: "1", name: "n", tags: ["a"], nested: {x: 0}}
\ No newline at end of file
```

**Problem and impact.** For a 40-key response the user gets two very long lines, a Proc address with a local file path, and no indication of which key failed or why (wrong type, extra key, missing key, constraint). The diff is a full-line replace, so Diffy adds nothing over the two lines above it. Diffy also shells out to `diff(1)` per failure. This is the single biggest day-to-day cost of using the gem.

**Recommended solution.** Make `SchemaMatch` a single recursive walk that collects `Mismatch` records (path, reason, expected, actual) instead of returning `false` at the first miss. Render them as `at $.children[1].age: expected Integer, got String ("x")` and `at $.children[0]: unexpected key "x"`. Render schema values by name (`Integer`, `/\A\d+\z/`, `Proc(type: String, min: 1)`) and pretty-print the actual JSON. Diffy then becomes optional or goes away. This walk also replaces `same_key_structure?` plus `deep_key_paths` plus root-relative `dig_path` (see 5.7 and 3.6).

**Dependencies and risks.** Largest item in the roadmap. Do it after 1.1, 1.2 and 3.2 have specs, so the rewrite has a safety net. It changes the failure text; that is not a public API, but mention it.

### 3.2 `compare_exact_array` does not dispatch element schemas

Priority: Medium. Category: Correctness / consistency. Effort: S. Status: Confirmed.

**Evidence.** `schema_match.rb:118`: `elem.is_a?(Hash) ? compare(...) : compare_simple_value(...)`. Classes, Regexps, Procs and nested arrays as array elements are compared with `==`:

```ruby
match_json_schema({ pair: [Integer, Integer] }).matches?('{"pair":[1,2]}')     # => false
match_json_schema({ m: [[Integer]] }).matches?('{"m":[[1,2],[3]]}')            # => false
```

**Problem and impact.** Fixed-length tuples and lists of lists cannot be expressed at all, and the failure is silent: the schema looks valid and simply never matches.

**Recommended solution.** Dispatch every element through `compare_values` (and Hash elements through `match`, per 1.2). Document tuples and nested lists in the README once they work.

**Dependencies and risks.** Same method as 1.2; do both in one change.

### 3.3 Array schema dispatch is positional and ambiguous

Priority: Medium. Category: Design. Effort: M. Status: Suggestion.

**Evidence.** `schema_match.rb:86-94, 126-132`. `[X]` means "list of X" when `X` is a Class, "list of interface" when `X` is a Hash, and "exactly one element equal to X" otherwise. `[String, NilClass]` therefore means a two-element tuple, not a union. The README only documents the `[Class]` and `[INTERFACE]` forms.

**Problem and impact.** Users cannot say "a list of UUID-typed strings" (`[Types::UUID]` is a one-element exact array containing a Regexp) or "a list of procs". Every new feature in section 4 will make the positional rules harder to explain.

**Recommended solution.** Keep the two shorthand forms for compatibility and add explicit helpers on `RSpec::JsonApi` (or a `Schema` module users can include): `array_of(schema)`, `tuple(...)`, `one_of(...)`, `optional(schema)`, `nullable(schema)`. Internally represent them as small value objects that `compare_values` dispatches on. This is the natural place to hang 4.1, 4.2 and 4.8.

**Dependencies and risks.** Design decision; agree the DSL before 3.1 so the mismatch renderer knows about the new node types.

### 3.4 Top-level scalar, Regexp and Class schemas always fail

Priority: Medium. Category: Correctness. Effort: S. Status: Confirmed.

**Evidence.** `schema_match.rb:16`: `return false unless actual.instance_of?(expected.class)`. For `expected = String` the class is `Class`, so a String body never matches:

```ruby
match_json_schema(String).matches?('"hello"')        # => false
match_json_schema(/\Ahello\z/).matches?('"hello"')   # => false
```

**Problem and impact.** Endpoints that return a bare string, number or boolean cannot be matched at all, and the reason is not obvious.

**Recommended solution.** Route non-Hash, non-Array roots through `compare_values`; keep the `instance_of?` guard for Hash and Array roots only.

### 3.5 Strictness rules differ by nesting level

Priority: Low. Category: Consistency / documentation. Effort: S. Status: Confirmed.

**Evidence.** Probe outputs in 1.2: `allow_blank` accepts `null` but not a missing key at the top level, while inside an exact array a missing key passes. Interface arrays behave like the top level.

**Recommended solution.** After 1.2 the behaviour is uniform (strict everywhere). Write the rule down in the README: "every key in the schema must be present; `allow_blank` accepts `null` or empty, not absence; use `optional` (4.1) for absence."

### 3.6 `Traversal` can be a single recursive helper

Priority: Low. Category: Simplification. Effort: S. Status: Suggestion.

**Evidence.** `traversal.rb:15-46`. `deep_keys` recurses with `respond_to?(:keys)` while `deep_key_paths` uses an explicit stack with `is_a?(Hash)` and a final `reverse`; `deep_sort` exists only to normalise `deep_keys` output.

**Recommended solution.** One `each_path(hash) { |path, value| }` enumerator covers both uses (and fixes 1.8). If 3.1 lands, the module disappears altogether.

### 3.7 `example_interface.rb` ships in the gem but is a test fixture

Priority: Low. Category: Packaging / hygiene. Effort: S. Status: Confirmed.

**Evidence.** `lib/rspec/json_api/interfaces/example_interface.rb` is not required by `lib/rspec/json_api.rb`; the only consumer is `spec/rspec/json_api/matchers/match_json_schema_spec.rb:3`. It is included in the built gem (verified by listing `rspec-json_api-1.5.0.gem`).

**Recommended solution.** Move it to `spec/support/example_interface.rb`. The README example that mirrors it can stay as a code block.

### 3.8 Generator namespace and `class_path` handling

Priority: Low. Category: Maintainability. Effort: S. Status: Confirmed.

**Evidence.** Generators live in `Rspec::JsonApi::Generators` (`lib/generators/**/*_generator.rb:3-5`), while the library is `RSpec::JsonApi`. This is deliberate: Thor derives the CLI namespace by snake-casing the constant, and `RSpec` would become `r_spec:json_api:install`. Nothing in the code says so. Separately, `InterfaceGenerator` and `TypeGenerator` interpolate only `file_name` (`interface_generator.rb:10,16`, `type_generator.rb:10,16`), so `rails g rspec:json_api:interface admin/user` writes `interfaces/user.rb` and a constant `USER`, silently dropping the namespace.

**Recommended solution.** Add a two-line comment explaining the `Rspec` spelling. Either honour `class_path` in the output path and constant, or reject namespaced names with a clear message. Both need the generator specs from 5.1.

### 3.9 `MatchJsonSchema` lacks `description`

Priority: Low. Category: RSpec integration. Effort: S. Status: Confirmed.

**Evidence.** Probe: `matcher.respond_to?(:description)` is false. RSpec's one-liner syntax (`it { is_expected.to match_json_schema(SCHEMA) }`) and `--format documentation` then fall back to a generic phrase. `failure_message_when_negated` (`match_json_schema.rb:50-52`) also has a doc comment that describes `self` as the return value, which is wrong.

**Recommended solution.** Add `description` ("match JSON schema") and consider `RSpec::Matchers::Composable` so the matcher can be nested in `include` and `all`. Fix the comment.

## 4. Feature proposals

All items in this section are suggestions.

### 4.1 Optional keys and nullable values

Priority: High. Category: Schema DSL. Effort: M.

**Evidence.** Today the only relaxation is `allow_blank` (`constraints.rb:24`), which accepts `null` or `""` but still requires the key to exist at the top level (probe in 1.2). There is no way to say "this key may be absent".

**Problem and impact.** Paginated and conditional responses (`next_page` only on some pages, `deleted_at` only for deleted rows) force users to write two schemas or to loosen the whole response.

**Recommended solution.** `optional(schema)` and `nullable(schema)` helpers (3.3), plus `optional: true` as a Proc option for people who prefer the Hash style. `optional` keys are excluded from the key-structure check when absent.

**Dependencies and risks.** Needs 3.3 for the node types and 3.1 to report "missing required key" versus "unexpected key".

### 4.2 Union types, a Boolean type, and `is_a?` semantics

Priority: High. Category: Schema DSL. Effort: M.

**Evidence.** JSON booleans have no single Ruby class, so the only ways to check one today are `inclusion: [true, false]` or a lambda (probe: both work but are undocumented). `type:` uses `instance_of?` (`constraints.rb:40`), so `type: Numeric` rejects `1` and `type: Float` rejects `1` even though JSON does not distinguish `1` from `1.0`.

**Recommended solution.** `Types::BOOLEAN`, `one_of(Integer, Float)`, and `type:` accepting an Array of classes; switch the class check to `is_a?` so `Numeric` works (document it as a behaviour change). Also accept an arity-1 lambda directly as a predicate (1.6).

### 4.3 Accept parsed JSON and response objects

Priority: Medium. Category: Ergonomics. Effort: S.

**Evidence.** `matches?` (`match_json_schema.rb:27`) only accepts a JSON String; a Hash raises (1.4). Request specs commonly have `response.parsed_body` or `JSON.parse(response.body)` at hand, and `have_no_content` (`have_no_content.rb:17`) has the same limitation.

**Recommended solution.** If `actual` is a Hash or Array, deep-symbolise and use it; if it responds to `body`, call it; otherwise parse. Same for `have_no_content`.

### 4.4 More built-in types

Priority: Medium. Category: Types. Effort: S.

**Evidence.** `lib/rspec/json_api/types/` has EMAIL, URI and UUID. `Types::URI` accepts any scheme (`mailto:`, `urn:`).

**Recommended solution.** `Types::URL` (http/https), `Types::ISO8601_DATE`, `Types::ISO8601_DATETIME`, `Types::INTEGER_STRING`. Implement date types as lambdas around `Date.iso8601`/`Time.iso8601` rather than regexps so `2026-02-30` is rejected.

### 4.5 Load user-defined types and interfaces automatically

Priority: Medium. Category: Ergonomics. Effort: S.

**Evidence.** `README.md:27-31` asks every user to paste two `Dir[...]` `require` loops into `rails_helper.rb`; the install generator (`install_generator.rb:9-11`) creates the directories but not the loader.

**Recommended solution.** `RSpec::JsonApi.load_definitions(root = "spec/rspec/json_api")` that requires `types/*.rb` then `interfaces/*.rb` (interfaces reference types, so order matters), and have the install generator append the one-liner to `rails_helper.rb`.

### 4.6 String keys in schemas

Priority: Low. Category: Ergonomics. Effort: S.

**Evidence.** `matches?` parses with `symbolize_names: true` (`match_json_schema.rb:27`), so `{ "id" => String }` never matches (probe). The README does not say keys must be symbols.

**Recommended solution.** Deep-symbolise the schema keys once in `initialize`, or document the rule. Symbolising is friendlier and cheap.

### 4.7 `have_no_content` failure message should show the body

Priority: Low. Category: Developer experience. Effort: S.

**Evidence.** `have_no_content.rb:26-37`: both messages are fixed strings; the user has to add a `puts` to see what came back.

**Recommended solution.** Include a truncated `actual.inspect`, and accept response objects (4.3).

### 4.8 Size constraints for lists

Priority: Low. Category: Schema DSL. Effort: S.

**Evidence.** `[String]` accepts `[]` (probe) and there is no way to require at least one element without a lambda.

**Recommended solution.** `array_of(String, min: 1, max: 50)` on the 3.3 helpers.

## 5. Other findings

### 5.1 Testing gaps

Priority: High. Category: Test debt. Effort: M. Status: Confirmed.

**Evidence.**
- Every crash and false positive in section 1 lacks a spec; that is how they survived the 1.5.0 refactor.
- `Traversal` and `SchemaMatch` have no direct specs; they are exercised only through the matcher.
- `Constraints` has four examples (`constraints_spec.rb`); `inclusion`, `regex`, `lambda` and `max` are covered only via the matcher, and non-numeric `min`/`max` and Proc misuse are not covered at all.
- The three generators have zero tests.
- `match_json_schema_spec.rb` is 1,128 lines of nested `let` fixtures with 52 `include_examples` and 4 plain `it`s; adding a case means copying a 30-line block.
- `spec_helper.rb` does not enable `config.order = :random` or `config.warnings = true`.
- No coverage tooling.

**Recommended solution.** Add specs for each section 1 input as the first commit of each fix. Add unit specs for `Constraints` and `SchemaMatch` with a table-driven style (`[schema, json, expected_result]` rows). Add generator specs with `Rails::Generators::TestCase` or the `ammeter` gem under the Rails appraisal jobs. Add SimpleCov with a floor. Turn on random ordering.

### 5.2 The CI compatibility matrix exercises almost no Rails code

Priority: Medium. Category: CI. Effort: M. Status: Confirmed.

**Evidence.** `.github/workflows/main.yml:15-21` runs six Ruby/Rails pairs, but `spec/spec_helper.rb` requires only `rspec/json_api`, which in turn requires a single ActiveSupport file (`json_api.rb:7`). Nothing requires `rails` or `rspec-rails`, and the generators are never invoked. Each Rails job therefore tests `Object#blank?` against that Rails version. The 1.5.0 CHANGELOG describes the matrix as making "the advertised version support actually tested".

**Problem and impact.** Six jobs of CI time for one line of coverage, and a false sense that Rails 6.1 through 8.1 compatibility is verified. Ruby 4.0 is also absent even though 1.5.0 shipped a Ruby 4.0 load fix (commit `8f7318a`), and the local lockfile was resolved on Ruby 4.0.

**Recommended solution.** After 2.1, the runtime matrix only needs Ruby versions (3.2, 3.3, 3.4, 4.0) with the plain Gemfile. Keep one or two Rails appraisals that actually load `rspec-rails` and run the generator specs from 5.1 against a minimal dummy app. Add `permissions: contents: read` and a `concurrency` group while touching the file.

### 5.3 Supply-chain checks are not automated

Priority: Medium. Category: Security / DevOps. Effort: S. Status: Confirmed.

**Evidence.** No `.github/dependabot.yml`; no `bundler-audit` step in the workflow; the workflow has no `permissions:` block (`main.yml`); `actions/checkout@v4` where v5 is current.

**Recommended solution.** Dependabot for `bundler` and `github-actions` (weekly), a `bundle-audit check --update` job, least-privilege `permissions`, and the checkout bump. `rubygems_mfa_required` is already set in the gemspec (line 19), which is good.

### 5.4 Release process

Priority: Medium. Category: DevOps. Effort: M. Status: Confirmed.

**Evidence.** Tags exist for v1.0.0, v1.0.1, v1.0.2, v1.1.0, v1.1.1 and v1.5.0 only; 1.2.x, 1.3.x and 1.4.0 were released without tags. `CHANGELOG.md` has entries for 1.5.0, 1.4.0 and 0.1.0 and nothing in between. Releases are manual (`rake release` from `bundler/gem_tasks`); a built `rspec-json_api-1.5.0.gem` sits in the working tree (gitignored).

**Recommended solution.** A release workflow using RubyGems Trusted Publishing triggered by a `v*` tag, so publishing requires a tag and a green build. Backfill the missing tags from the version-bump commits and write short CHANGELOG entries from `git log` for 1.1 to 1.3.1.

### 5.5 The gem packages repository tooling

Priority: Low. Category: Packaging. Effort: S. Status: Confirmed.

**Evidence.** `rspec-json_api.gemspec:23-25` includes every tracked file except `test/`, `spec/` and `features/`. Listing the built gem shows `.github/workflows/main.yml`, `.rubocop.yml`, `.gitattributes`, `.gitignore`, `.rspec`, `.ruby-version`, `Gemfile`, `Gemfile.lock`, `Rakefile`, `bin/console`, `bin/setup` and `gemfiles/*.gemfile` inside it.

**Recommended solution.** `spec.files = Dir["lib/**/*"] + %w[LICENSE.txt README.md CHANGELOG.md]`. Drop `spec.bindir`/`spec.executables` (no `exe/` directory exists).

### 5.6 Documentation

Priority: Medium. Category: Documentation. Effort: S. Status: Confirmed.

**Evidence.** `README.md`:
- Typos and grammar: "build-in" (lines 35, 114), "The gem allow users either to user build-in types or define owns" (line 113), "Proc match allows to customize schema according needs" (line 239), "The gem offers variety of possible matching methods" (line 146).
- Behaviours that are undocumented: invalid JSON yields a failed match (not an error); unknown Proc options raise `ArgumentError`; schema keys must be symbols; `type:` uses `instance_of?`; `[X]` semantics and the lack of tuples; top-level must be an object or array; how `allow_blank` interacts with missing keys.
- No supported Ruby/Rails matrix, even though the gemspec floor (Ruby 3.2, Rails 6.1.4.1) and the CI matrix define one.
- The name suggests the JSON:API specification (jsonapi.org); the gem is a general JSON-shape matcher. One sentence at the top would save readers a wrong assumption.
- No `CONTRIBUTING.md` or `SECURITY.md`; `bin/setup` and the toolchain (`.ruby-version` 3.2.2, Bundler 4.0.4 in the lockfile) are not mentioned anywhere.

**Recommended solution.** Fix the prose, add a "Behaviour reference" section that answers the bullets above, add a support matrix, and a short contributing section. Update again when 3.3 and section 4 land.

### 5.7 Performance

Priority: Low. Category: Performance. Effort: folded into 3.1. Status: Suggestion.

**Evidence.** For each object, `match` walks the tree for `same_key_structure?` (`schema_match.rb:30-33`), then `compare` walks both sides again for `deep_key_paths` and calls `dig_path` from the root for every leaf path (`schema_match.rb:35-62`), and this repeats for every element of every array. Diffy shells out to `diff(1)` on each failure.

**Problem and impact.** Not measurable on typical API payloads; a few thousand keys would still finish in milliseconds. It is listed because 3.1 replaces all of it with a single walk, so no separate work is warranted.

### 5.8 Observability

Not applicable to a test-matcher gem in the usual sense. The equivalent concern is failure-message quality, which is 3.1 and 4.7.

### 5.9 Local development setup

Priority: Low. Category: Developer experience. Effort: S. Status: Confirmed.

**Evidence.** `.ruby-version` pins 3.2.2, `Gemfile.lock` says `BUNDLED WITH 4.0.4` and lists `arm64-darwin-25` plus a `nokogiri` build for it, so the lockfile was last resolved on a newer Ruby than the one the repo declares. `mise.toml` is gitignored (commit `87fddee`). `bin/setup` only runs `bundle install`.

**Recommended solution.** Decide on one declared development Ruby (3.4 or 4.0), regenerate the lockfile on it, and say in the README which Ruby and Bundler the lockfile expects.

## Phased plan

**Phase 1, patch release 1.5.1 (about a day).** 1.1, 1.3, 1.4, 1.6, 1.7, 2.3, 2.4, 5.3, 5.5. All additive or pure fixes, each with a spec.

**Phase 2, 2.0.0 (one to two weeks).** 1.2, 1.5, 3.2, 3.4, 3.9 (behaviour changes bundled in one CHANGELOG), 2.1 and 2.2 (dependency cut), 2.5, 3.7, 5.1 unit specs, 5.2 matrix rework, 5.6 documentation. Bump the major because 1.2, 1.5 and 2.1 can each break an existing suite.

**Phase 3, 2.x (ongoing).** 3.3 DSL helpers, then 4.1, 4.2, 4.8 on top of them; 3.1 mismatch reporting once the DSL is settled; 4.3, 4.4, 4.5, 4.6, 4.7; 5.4 release automation; 1.8 and 3.6 disappear as part of 3.1.
