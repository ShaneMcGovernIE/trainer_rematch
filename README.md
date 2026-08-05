# Trainer Rematch

Talk to any trainer you have already beaten and they challenge you to a rematch, with a YES/NO prompt.

## How it works

1. Beat a trainer, then walk up and talk to them again.
2. They greet you with a line written for their class (each class speaks in the voice it uses in its regular dialogue).
3. Answer the prompt:
   - **YES** - battle them again. Rematch earnings are a **percentage of the usual amounts**, set in MODS > Trainer Rematch: **REMATCH MONEY %** (default 0%) and **REMATCH XP %** (default 100%), each a 0-100% slider in 10% steps. Pay Day stays disabled on rematches.
   - **NO** - they react in character: cocky classes mock you for being scared, wise ones are understanding. Their normal post-battle line still follows, so nothing from the base game is lost.

If the rematch team averages **more than 10 levels above your party**, they warn you first in their own voice and ask again — say YES to battle anyway, or NO to walk away.

Gym leaders, rivals and other scripted encounters keep their original conversations — except that a class which marks a dedicated rematch team (a `rematchIndex` in its trainer record, like the Yellow Legacy Changes mod ships for the gym leaders, Elite Four and Champion) uses that team for the rematch instead of the trainer's own party.

## Try it

1. Install the mod into your game's `mods/` folder (or drop the zip in via the launcher).
2. Restart the game and enable the mod if it is not on.
3. Beat a field trainer (a Youngster, Bug Catcher, Lass...), then talk to them again.

## What changed

- `main.lua` - wraps the overworld talk flow to offer rematches, scales money and experience in rematch battles from the MODS-menu percentages, and defines those two options. No save changes; your file works with or without the mod.
