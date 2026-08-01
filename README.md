# Trainer Rematch

Talk to any trainer you have already beaten and they challenge you to a rematch, with a YES/NO prompt.

## How it works

1. Beat a trainer, then walk up and talk to them again.
2. They greet you with a line written for their class (each class speaks in the voice it uses in its regular dialogue).
3. Answer the prompt:
   - **YES** - battle them again. The rematch pays **no money**: no trainer prize and no Pay Day pickup.
   - **NO** - they react in character: cocky classes mock you for being scared, wise ones are understanding. Their normal post-battle line still follows, so nothing from the base game is lost.

If the rematch team averages **more than 10 levels above your party**, they warn you first in their own voice and ask again — say YES to battle anyway, or NO to walk away.

Gym leaders, rivals and other scripted encounters keep their original conversations — except that a class which marks a dedicated rematch team (a `rematchIndex` in its trainer record) uses that team for the rematch instead of the trainer's own party.

## Yellow Legacy rematch teams

To rematch the gym leaders, the Elite Four and the Champion with their
far stronger rematch teams, install
**[Yellow Legacy Changes](https://github.com/ShaneMcGovernIE/yellow_legacy_changes)
alongside this mod** — it marks the hack's L64-77 teams with
`rematchIndex`, and this mod picks them up automatically (with the
strength warning when the gap is large).

## Try it

1. Install the mod into your game's `mods/` folder (or drop the zip in via the launcher).
2. Restart the game and enable the mod if it is not on.
3. Beat a field trainer (a Youngster, Bug Catcher, Lass...), then talk to them again.

## What changed

- `main.lua` - wraps the overworld talk flow to offer rematches, and the battle victory flow to suppress money in rematch battles. No save changes; your file works with or without the mod.
