# <part>/CLAUDE.md — Android (Kotlin) rules

Applies to everything under this folder. Root `CLAUDE.md` still applies. UI work must follow `docs/DESIGN.md`.

## Stack
- Kotlin, Jetpack Compose, Coroutines + Flow, Hilt (DI), Room, WorkManager, kotlinx-serialization.
- Networking: Retrofit + OkHttp + kotlinx-serialization (or Ktor — decide in an ADR, never mix).
- Screenshot tests: Roborazzi (JVM, Robolectric). Unit: JUnit + Turbine; fakes over mocks.
- Lint: ktlint + detekt. Versions in `gradle/libs.versions.toml` only.

## Version lessons (check, don't assume)
- Hilt/Dagger usually sets the **Kotlin ceiling** — read its POM's kotlin-bom before choosing Kotlin.
- AGP 9+ has built-in Kotlin (no `org.jetbrains.kotlin.android` plugin) and needs a recent Gradle.
- Newest androidx artifacts may declare a `minCompileSdk` above the latest stable platform — hold them back.
- Robolectric may need a newer JDK to emulate the newest SDK — align JDK, CI and Robolectric SDK.
- Record the final matrix in ADR 0003.

## Modules
```
:app                      entry, DI graph, product flavors / build types
:core:common              Result, AppError, dispatchers, logger, Clock  (pure JVM)
:core:<platform-adapters> permissions, sensors, OS services behind interfaces
:core:database            Room DB, entities, DAOs, migrations
:data:<domain>            provider/ (internal) · gateway/ (public) · mapper/ · di/
:domain                   model/ · usecase/   (pure JVM — Android imports = compile error)
:ui:designsystem          tokens, theme, base components (DESIGN.md)
:ui:screen:<feature>      Screen + ViewModel + UiState + UiEvent
```
- Convention plugins in `build-logic/`. `explicitApi()` in libraries. Providers/DTOs/mappers `internal`.
- Flavor-specific code in `src/<flavor>/`; store builds must not compile restricted code.

## UI & State
- `UiEvent → ViewModel → StateFlow<UiState> → Composable`; `collectAsStateWithLifecycle()`.
- ViewModels call use cases only. No business logic in Composables.
- Disable default ripple; use the design system's indication. Shared elements via `SharedTransitionLayout`.
- Previews: light, dark, 200% font. Every screen: loading/empty/error/success.

## Platform
- Request permissions just-in-time with an explanation screen; expose permission state as a typed enum.
- Background work via WorkManager; foreground services only when unavoidable; no polling.
- Long-running platform callbacks (accessibility, receivers) do no I/O on the callback thread.

## Testing
- Room migrations with `MigrationTestHelper`. Screenshot tests for every design-system component.
- `failOnNoDiscoveredTests` off for empty modules (Gradle 9).

## Commands
`./gradlew ktlintCheck detekt` · `./gradlew test` · `./gradlew verifyRoborazziDebug` · `./gradlew :app:assemble<Flavor>Debug`
