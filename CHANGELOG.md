# Changelog

All notable changes to this project are documented in this file.

## [0.4.4] - 2026-08-05

### Fixed

- The Rocket Hideout B4F grunt that drops the LIFT KEY keeps his scripted
  drop. On engines older than v0.1.17 his after-battle talk is not a
  hand-ported script, so the rematch prompt replaced the key drop and the
  LIFT KEY never appeared. The manifest now gates those engines out
  (`game_version` requires v0.1.17+; the dev engine still loads), matching
  the engine's own fix (bryanthaboi/gen1recomp #90 / #105).

## [0.4.3] - 2026-08-05

### Fixed

- Rematch XP percentage now applies. The old wrap scaled the participant
  split, which the engine floors back to 1 for the normal single-participant
  rematch — so 0%-90% all paid full EXP. The finished EXP is now scaled
  after the battle, and the flag can't leak into the next battle.
- README and mod.card now state the rematch money default correctly (0%,
  not 25%).

### Changed

- Pure `scaleByPercent` / `resolvePartyIndex` / `resolveParty` helpers
  extracted from the money and party-selection paths and exported for
  tests; the full `battle.exp_award` -> `exp.gain` path is now covered.

## [0.4.1] - 2026-08-02

### Changed

- Rematch money now defaults to 0% (the original no-prize behaviour);
  the percentage sliders are unchanged.

## [0.4.0] - 2026-08-02

### Added

- Rematch earnings are now configurable in MODS > Trainer Rematch:
  - **REMATCH MONEY %** - a percentage of the usual trainer prize money,
    stepped in 10% intervals from 0% to 100% (default 25%).
  - **REMATCH XP %** - a percentage of the usual experience gained,
    stepped in 10% intervals from 0% to 100% (default 100%, unchanged
    behaviour).
- At 0% money the prize line is still suppressed (no "You got ¥0" box);
  Pay Day remains disabled on rematches.

## [0.3.0] - 2026-08-01

### Added

- Strength warning: when the rematch team averages more than 10 levels
  above the player's party, the trainer warns in its own voice ("My team
  is far stronger than yours...") and asks a second time before the battle
  starts.  Declining walks away with the class's usual decline line.

## [0.2.0] - 2026-08-01

### Added

- A trainer record may mark a dedicated rematch team via `rematchIndex`
  (Yellow Legacy Changes 1.6.0+ ships the hack's gym-leader, Elite Four
  and Champion rematch teams this way); the rematch battle then uses that
  team instead of the trainer's own.  Without a marker, behavior is
  unchanged.

## [0.1.0] - 2026-08-01

### Added

- Rematch prompt when talking to a defeated field trainer (YES/NO).
- Per-trainer-class rematch dialogue in the class's own voice.
- Per-trainer-class decline reaction: mocking for cocky classes, understanding for wise ones.
- No money rewards for rematch battles (trainer prize and Pay Day suppressed).
- The trainer's vanilla post-battle dialogue follows the decline reaction.
