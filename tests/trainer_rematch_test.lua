-- Trainer Rematch headless suite. Run from the engine checkout:
--   POKEPORT_DATA_DIR=tests/fixture_data luajit mods/trainer_rematch/tests/trainer_rematch_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path
local T = require("tests.modkit")
local Data = T.fixtures.load()

local run = T.sdk.loadMod("mods/trainer_rematch", { data = Data })
T.eq(#run.errors, 0, "loads clean")
local ex = run.loader.exports.trainer_rematch
T.neq(ex, nil, "exports reachable")

-- --------------------------------------- engine gate (Lift Key drop)

-- The Celadon Hideout Rocket grunt (ROCKET_HIDEOUT_B4F_obj_4) drops the
-- LIFT KEY from a hand-ported talk handler the engine added in v0.1.17
-- (commit 8278b20).  Before that, his text constant is not scripted, so
-- the mod's talk wrap would offer a rematch to the defeated grunt instead
-- of letting the key drop -- a progression-blocking bug (bryanthaboi/
-- gen1recomp #90 / #105).  The manifest must gate those engines out.
local Semver = require("src.mods.Semver")
local gate = run.loader.mods.trainer_rematch.manifest.game_version
T.eq(type(gate), "string", "manifest declares a game_version gate")
T.eq(Semver.satisfies("0.1.16", gate), false,
  "engine before the LIFT KEY talk handler is rejected")
T.eq(Semver.satisfies("0.1.17", gate), true,
  "first engine with the LIFT KEY talk handler is accepted")
T.eq(Semver.satisfies("0.0.0-dev", gate), true,
  "dev engine is accepted so the mod keeps loading in the dev checkout")

-- ------------------------------------------------ pure line resolution

T.eq(ex.resolveLine("OPP_YOUNGSTER"):find("shorts", 1, true) ~= nil, true,
  "YOUNGSTER line is in his voice")
T.eq(ex.resolveLine("OPP_LANCE"):find("dragons", 1, true) ~= nil, true,
  "LANCE line is in his voice")
T.eq(ex.resolveLine("OPP_UNUSED_JUGGLER"):find("juggling", 1, true) ~= nil, true,
  "UNUSED_JUGGLER gets a line too")
T.eq(ex.resolveLine("OPP_FIX_YOUNGSTER"), "Looking for a\nrematch with me?",
  "unknown class falls back to the default prompt")
T.eq(ex.resolveLine(nil), "Looking for a\nrematch with me?",
  "nil class falls back to the default prompt")

-- ------------------------------------------------ pure decline resolution

T.eq(ex.resolveDecline("OPP_YOUNGSTER"):find("scared", 1, true) ~= nil, true,
  "cocky classes mock the refusal")
T.eq(ex.resolveDecline("OPP_KOGA"):find("Fear", 1, true) ~= nil, true,
  "wise classes answer with understanding")
T.eq(ex.resolveDecline("OPP_GENTLEMAN"):find("gentleman", 1, true) ~= nil, true,
  "polite classes stay polite")
T.eq(ex.resolveDecline("OPP_FIX_YOUNGSTER"), "Ha! Scared of a\nrematch, are you?",
  "unknown class falls back to the default decline")
T.eq(ex.resolveDecline(nil), "Ha! Scared of a\nrematch, are you?",
  "nil class falls back to the default decline")

-- ------------------------------------------------ prize-line filter

T.eq(ex.isPrizeLine("RED got ¥1500\nfor winning!"), true,
  "prize line is filtered out")
T.eq(ex.isPrizeLine("RED defeated\nYOUNGSTER!"), false,
  "defeated line passes")
T.eq(ex.isPrizeLine("You got here\nfor winning\nnothing!"), true,
  "any line mentioning got/for winning is treated as prize text")
T.eq(ex.isPrizeLine(123), false, "non-string texts pass")

-- ------------------------------------------------ install (stubbed deps)

local pushed = {}
local calls = { vanillaTalk = 0, engaged = 0, battles = {}, after = 0 }
local game = {
  data = Data,
  save = { money = 3000, defeatedTrainers = {}, player = { name = "RED" },
           party = { { level = 5 }, { level = 6 }, { level = 7 } } },
  stack = { push = function(_, s) table.insert(pushed, s) end },
}
local textBoxStub = {
  new = function(g, text, onDone, opts)
    return { text = text, onDone = onDone, opts = opts or {} }
  end,
  substitute = function(g, text) return "sub:" .. text end,
}
local battleStateStub = {
  newTrainer = function(g, cls, party)
    local b = { game = g, trainer = g.data.trainers[cls],
                enemy = { mon = { level = 10 } }, queue = {} }
    calls.battles[#calls.battles + 1] = { cls = cls, party = party, battle = b }
    return b
  end,
  -- vanilla-shaped victory: award money, queue the prize line + a flavor line
  enemyMonFainted = function(self)
    local prize = (self.trainer.baseMoney or 0) * self.enemy.mon.level
    self.game.save.money = self.game.save.money + prize
    self:sayNext(("RED got ¥%d\nfor winning!"):format(prize))
    self:sayNext("RED defeated\nYOUNGSTER!")
  end,
  finish = function(self)
    if self.payDay and self.result == "win" then
      self.game.save.money = self.game.save.money + self.payDay
      self.paid = self.payDay
    end
  end,
}
local runtimeStub = { emit = function(_, name, payload)
  calls.engaged = calls.engaged + 1 end }
local scriptedFlag = { value = false }
local mapScriptsStub = { talkScript = function()
  return scriptedFlag.value end }
local vanillaTalkTo = function() calls.vanillaTalk = calls.vanillaTalk + 1 end
local overworldStub = { talkTo = vanillaTalkTo }

ex.install(game, { overworld = overworldStub, battleState = battleStateStub,
                   textBox = textBoxStub, runtime = runtimeStub,
                   mapScripts = mapScriptsStub })

local function freshNpc()
  return {
    def = { trainerClass = "OPP_FIX_YOUNGSTER", trainerParty = 1,
            text = "X", index = 1 },
    frozen = false,
    facePlayer = function() end,
  }
end
local ow = {
  map = { id = "FIX_ROUTE", def = { label = "FixRoute" } },
  player = {},
  trainerDefeated = function() return true end,
  afterBattle = function() calls.after = calls.after + 1 end,
  pushBattle = function(self, battle) calls.pushedBattle = battle end,
}

-- A: beaten generic trainer -> rematch prompt with the class line
local npc = freshNpc()
overworldStub.talkTo(ow, npc)
T.eq(#pushed, 1, "rematch prompt pushed")
T.eq(pushed[1].text, ex.resolveLine("OPP_FIX_YOUNGSTER"),
  "prompt shows the class line")
T.eq(type(pushed[1].opts.choice), "function", "prompt carries a YES/NO choice")
T.eq(npc.frozen, true, "npc frozen while the prompt is up")

-- B: YES -> battle starts, flagged as rematch, no victory rewards
pushed[1].opts.choice(true)
T.eq(calls.engaged, 1, "trainer_engaged emitted")
T.eq(#calls.battles, 1, "one battle created")
T.eq(calls.battles[1].cls, "OPP_FIX_YOUNGSTER", "battle uses the npc class")
T.eq(calls.battles[1].party, 1, "battle uses the npc party")
local b = calls.battles[1].battle
T.eq(b.rematch, true, "battle flagged as rematch")
T.eq(b.endBattleText, "sub:Well fixed!", "loss line still shown")
T.neq(b.onFinish, nil, "onFinish wired")
local afterCount = calls.after
b.onFinish("win")
T.eq(calls.after, afterCount + 1, "afterBattle ran")
T.eq(npc.frozen, false, "npc unfrozen after the battle")

-- C: NO -> the class reacts, then the vanilla post-battle line as a page
pushed = {}
local npc2 = freshNpc()
overworldStub.talkTo(ow, npc2)
pushed[1].opts.choice(false)
T.eq(#pushed, 2, "decline pushes the reaction box")
T.eq(pushed[2].text:lower():find("scared", 1, true) ~= nil, true,
  "decline shows the class reaction")
T.eq(pushed[2].text:find("Nice fixture.", 1, true) ~= nil, true,
  "vanilla after text kept as a second page")
T.eq(pushed[2].text:find("\f", 1, true) ~= nil, true, "pages joined by \\f")
T.eq(calls.vanillaTalk, 0, "no vanilla fallback on decline with after text")
pushed[2].onDone()
T.eq(npc2.frozen, false, "npc unfrozen after the reaction box")

-- D: decline with no post-battle header -> just the default reaction
pushed = {}
local owNoHeader = {
  map = { id = "SOMEWHERE", def = { label = "Nowhere" } },
  player = {},
  trainerDefeated = function() return true end,
  afterBattle = function() end,
  pushBattle = function() end,
}
local npc3 = freshNpc()
overworldStub.talkTo(owNoHeader, npc3)
pushed[1].opts.choice(false)
T.eq(#pushed, 2, "reaction box pushed without a header")
T.eq(pushed[2].text, ex.resolveDecline("OPP_FIX_YOUNGSTER"),
  "default reaction used when the class has no header")
T.eq(pushed[2].text:find("\f", 1, true) == nil, true,
  "no \\f page when there is no after text")
T.eq(calls.vanillaTalk, 0, "no vanilla fallback on decline without a header")
pushed[2].onDone()
T.eq(npc3.frozen, false, "npc unfrozen after the reaction box")

-- E: unbeaten trainers keep the vanilla flow
calls.vanillaTalk = 0
local owUnbeaten = {
  map = { id = "FIX_ROUTE", def = { label = "FixRoute" } },
  player = {},
  trainerDefeated = function() return false end,
  afterBattle = function() end,
  pushBattle = function() end,
}
overworldStub.talkTo(owUnbeaten, freshNpc())
T.eq(calls.vanillaTalk, 1, "unbeaten trainer uses the vanilla talk")

-- F: scripted trainers (gym leaders, rivals) keep their flow
calls.vanillaTalk = 0
pushed = {}
scriptedFlag.value = true
overworldStub.talkTo(ow, freshNpc())
T.eq(calls.vanillaTalk, 1, "scripted trainer skips the rematch prompt")
T.eq(#pushed, 0, "no rematch prompt for scripted trainers")
scriptedFlag.value = false

-- G: rematch win awards no money and drops the prize line
local moneyBefore = game.save.money
local rematch = { game = game, rematch = true,
  trainer = { baseMoney = 150, name = "FIX YOUNGSTER" },
  enemy = { mon = { level = 10 } }, queue = {},
  sayNext = function(self, text) table.insert(self.queue, text) end }
battleStateStub.enemyMonFainted(rematch)
T.eq(game.save.money, moneyBefore, "rematch awards no money")
T.eq(#rematch.queue, 1, "prize line dropped")
T.eq(rematch.queue[1], "RED defeated\nYOUNGSTER!", "flavor line kept")
T.eq(rematch.trainer.baseMoney, 150, "shared trainer record untouched")

-- H: the first (non-rematch) fight still pays
moneyBefore = game.save.money
local normal = { game = game, rematch = false,
  trainer = { baseMoney = 150, name = "FIX YOUNGSTER" },
  enemy = { mon = { level = 10 } }, queue = {},
  sayNext = function(self, text) table.insert(self.queue, text) end }
battleStateStub.enemyMonFainted(normal)
T.eq(game.save.money, moneyBefore + 1500, "normal win still pays")
T.eq(#normal.queue, 2, "prize line kept on normal wins")

-- I: Pay Day pays nothing on a rematch
moneyBefore = game.save.money
local pay = { game = game, rematch = true, payDay = 500, result = "win" }
battleStateStub.finish(pay)
T.eq(pay.paid, nil, "pay day suppressed on rematch")
T.eq(game.save.money, moneyBefore, "no money from pay day on rematch")

-- J: Pay Day still pays in normal battles
moneyBefore = game.save.money
local pay2 = { game = game, rematch = false, payDay = 500, result = "win" }
battleStateStub.finish(pay2)
T.eq(pay2.paid, 500, "pay day pays normally")
T.eq(game.save.money, moneyBefore + 500, "money credited normally")

-- K: a class with a marked rematch team (the Yellow Legacy pattern) uses
-- that party for the rematch instead of the trainer's own -- and since
-- the marked team averages far above the player's party, the class warns
-- first and only battles after a second confirmation
Data.trainers["OPP_FIX_MISTY"] = {
  id = "OPP_FIX_MISTY", name = "MISTY", index = 35, baseMoney = 40,
  parties = {
    { { level = 18, species = "STARYU" }, { level = 21, species = "STARMIE" } },
    { { level = 64, species = "SEADRA" }, { level = 65, species = "STARMIE" } },
  },
  rematchIndex = 2,
}
local mistyBattles = #calls.battles
local pushedBefore = #pushed
local mistyNpc = freshNpc()
mistyNpc.def.trainerClass = "OPP_FIX_MISTY"
scriptedFlag.value = true
overworldStub.talkTo(ow, mistyNpc)
T.eq(#pushed, pushedBefore + 1, "the rematch prompt is pushed")
pushed[#pushed].opts.choice(true)
T.eq(#calls.battles, mistyBattles, "no battle yet: the warning comes first")
T.eq(#pushed, pushedBefore + 2, "the strength warning is pushed")
T.eq(pushed[#pushed].text, ex.resolveWarning("OPP_FIX_MISTY"),
  "the warning speaks in the class's default voice")
pushed[#pushed].opts.choice(true)
T.eq(#calls.battles, mistyBattles + 1, "confirming the warning starts the battle")
T.eq(calls.battles[#calls.battles].party, 2,
  "the marked rematch team is used")
T.eq(calls.battles[#calls.battles].battle.rematch, true,
  "the marked-rematch battle is still a rematch")

-- L: declining the warning walks away without a battle
local lBefore = #calls.battles
local pushedL = #pushed
mistyNpc.frozen = false
overworldStub.talkTo(ow, mistyNpc)
pushed[#pushed].opts.choice(true)
pushed[#pushed].opts.choice(false)
T.eq(#calls.battles, lBefore, "declining the warning starts no battle")
T.eq(#pushed, pushedL + 3, "the decline line follows")
scriptedFlag.value = false

-- M: a small level gap skips the warning and battles directly
local lvlBattles = #calls.battles
local pushedM = #pushed
local lvlNpc = freshNpc()
overworldStub.talkTo(ow, lvlNpc)
T.eq(#pushed, pushedM + 1, "the rematch prompt is pushed")
pushed[#pushed].opts.choice(true)
T.eq(#calls.battles, lvlBattles + 1, "a close team battles straight away")
T.eq(calls.battles[#calls.battles].party, 1, "it uses the trainer's own party")

-- N: the level-gap math behind the warning
T.eq(ex.levelGap({ { level = 5 }, { level = 7 } },
  { { level = 64 }, { level = 65 } }), 58.5, "the gap is team average minus party average")
T.eq(ex.levelGap({ { level = 60 }, { level = 60 } },
  { { level = 55 }, { level = 55 } }), -5, "an easier team is a negative gap")
T.eq(ex.levelGap(nil, { { level = 64 } }), nil, "an empty party yields no gap")
T.eq(ex.levelGap({ { level = 5 } }, nil), nil, "an empty team yields no gap")

-- ------------------------------------------------ percentage scaling

T.eq(ex.scaleByPercent(1500, 25), 375, "25% of a prize")
T.eq(ex.scaleByPercent(150, 0), 0, "0% scales to zero")
T.eq(ex.scaleByPercent(37, 50), 18, "the percent is floored")
T.eq(ex.scaleByPercent(1000, 10), 100, "10% of a gain")
T.eq(ex.scaleByPercent(nil, 50), 0, "nil values scale to zero")

-- ------------------------------------------------ rematch party resolution

local markedRec = { rematchIndex = 2, parties = { "p1", "p2" } }
T.eq(ex.resolvePartyIndex(markedRec, 1), 2, "a marked rematch team wins")
T.eq(ex.resolvePartyIndex({ rematchIndex = 9, parties = { "p1" } }, 1), 1,
  "a marked index with no party falls back")
T.eq(ex.resolvePartyIndex(nil, 3), 3, "no record falls back")
T.eq(ex.resolvePartyIndex({ parties = {} }, 2), 2, "no marker falls back")
T.eq(ex.resolveParty(markedRec, 2), "p2", "the marked party resolves")
T.eq(ex.resolveParty(markedRec, 9), nil, "a bad index yields no party")

-- ------------------------------------------------ rematch XP scaling (hooks)

-- the mod's battle.exp_award wrap marks a rematch while vanilla runs; the
-- exp.gain wrap it registers scales the finished gained amount.  Drive the
-- real hook bus the way Runtime.call does: award with an inline vanilla fn
-- that asks for a gain through the exp.gain hook.
local function gainThroughAward(battle, participants)
  local seen
  run.loader.hooks:call("battle.exp_award", function(ctx)
    seen = run.loader.hooks:call("exp.gain", function()
      return 1000
    end, { defeatedDef = {}, level = 10, isTrainer = true,
           participants = participants, traded = false, mon = {} })
  end, { battle = battle })
  return seen
end
run.loader.modOptions["trainer_rematch"] = { rematchXpPct = 10 }
T.eq(gainThroughAward({ rematch = true }, 1), 100,
  "10% rematch XP scales the gained amount")
T.eq(gainThroughAward({}, 1), 1000, "non-rematch battles gain full XP")
run.loader.modOptions["trainer_rematch"].rematchXpPct = 0
T.eq(gainThroughAward({ rematch = true }, 1), 0, "0% rematch XP gains nothing")
run.loader.modOptions["trainer_rematch"].rematchXpPct = 100
T.eq(gainThroughAward({ rematch = true }, 1), 1000, "100% rematch XP is unchanged")
run.loader.modOptions["trainer_rematch"] = nil

-- ------------------------------------------------ Gen 2 Target & Loading

local manifest = run.loader.mods.trainer_rematch.manifest
T.neq(manifest.games, nil, "manifest has games list")
T.eq(type(manifest.games), "table", "manifest games is a table")
local gamesStr = table.concat(manifest.games, ",")
T.eq(gamesStr:find("gen1", 1, true) ~= nil or gamesStr:find("red", 1, true) ~= nil, true,
  "manifest covers Gen 1")
T.eq(gamesStr:find("gen2", 1, true) ~= nil or gamesStr:find("gold", 1, true) ~= nil, true,
  "manifest covers Gen 2")

local runGen2 = T.sdk.loadMod("mods/trainer_rematch", { data = T.fixtures.fresh(), generation = 2 })
T.eq(#runGen2.errors, 0, "loads clean on Gen 2")
T.eq(runGen2.mod and runGen2.mod.state, "loaded", "runs on Gen 2 with loaded state")
runGen2.release()

-- ------------------------------------------------ Gen 2 Trainer Lines & Aliases

T.eq(ex.resolveLine("FALKNER"):find("training", 1, true) ~= nil, true,
  "FALKNER line resolves (bare name)")
T.eq(ex.resolveLine("OPP_FALKNER"):find("training", 1, true) ~= nil, true,
  "OPP_FALKNER line resolves (OPP prefix)")
T.eq(ex.resolveLine("WHITNEY"):find("cry", 1, true) ~= nil, true,
  "WHITNEY line resolves")
T.eq(ex.resolveLine("BUGSY"):find("BUG", 1, true) ~= nil, true,
  "BUGSY line resolves")
T.eq(ex.resolveLine("MORTY"):find("Ghosts", 1, true) ~= nil, true,
  "MORTY line resolves")
T.eq(ex.resolveLine("CHUCK"):find("HRAAGH", 1, true) ~= nil, true,
  "CHUCK line resolves")
T.eq(ex.resolveLine("JASMINE"):find("steel", 1, true) ~= nil, true,
  "JASMINE line resolves")
T.eq(ex.resolveLine("PRYCE"):find("Winter", 1, true) ~= nil, true,
  "PRYCE line resolves")
T.eq(ex.resolveLine("CLAIR"):find("dragons", 1, true) ~= nil, true,
  "CLAIR line resolves")
T.eq(ex.resolveLine("WILL"):find("foresaw", 1, true) ~= nil, true,
  "WILL line resolves")
T.eq(ex.resolveLine("KAREN"):find("favorites", 1, true) ~= nil, true,
  "KAREN line resolves")
T.eq(ex.resolveLine("JANINE"):find("Ninja", 1, true) ~= nil, true,
  "JANINE line resolves")
T.eq(ex.resolveLine("RED"):find("%.%.%.", 1, false) ~= nil, true,
  "RED line resolves")
T.eq(ex.resolveLine("BLUE"):find("Smell ya later", 1, true) ~= nil, true,
  "BLUE line resolves")
T.eq(ex.resolveLine("CAL"):find("skills", 1, true) ~= nil, true,
  "CAL line resolves")
T.eq(ex.resolveLine("SCHOOLBOY"):find("theory", 1, true) ~= nil, true,
  "SCHOOLBOY line resolves")
T.eq(ex.resolveLine("SKIER"):find("Snow", 1, true) ~= nil, true,
  "SKIER line resolves")
T.eq(ex.resolveLine("TEACHER"):find("quiz", 1, true) ~= nil, true,
  "TEACHER line resolves")
T.eq(ex.resolveLine("FIREBREATHER"):find("fire", 1, true) ~= nil, true,
  "FIREBREATHER line resolves")
T.eq(ex.resolveLine("SAGE"):find("spirits", 1, true) ~= nil, true,
  "SAGE line resolves")
T.eq(ex.resolveLine("MEDIUM"):find("Spirits", 1, true) ~= nil, true,
  "MEDIUM line resolves")
T.eq(ex.resolveLine("BOARDER"):find("moves", 1, true) ~= nil, true,
  "BOARDER line resolves")
T.eq(ex.resolveLine("POKEFANM"):find("Darling", 1, true) ~= nil, true,
  "POKEFANM line resolves")
T.eq(ex.resolveLine("POKEFANF"):find("sweet", 1, true) ~= nil, true,
  "POKEFANF line resolves")
T.eq(ex.resolveLine("KIMONO_GIRL"):find("Dance", 1, true) ~= nil, true,
  "KIMONO_GIRL line resolves")
T.eq(ex.resolveLine("TWINS"):find("Twice", 1, true) ~= nil, true,
  "TWINS line resolves")
T.eq(ex.resolveLine("OFFICER"):find("Halt", 1, true) ~= nil, true,
  "OFFICER line resolves")
T.eq(ex.resolveLine("EXECUTIVEM"):find("Rocket", 1, true) ~= nil, true,
  "EXECUTIVEM line resolves")
T.eq(ex.resolveLine("EXECUTIVEF"):find("meddling", 1, true) ~= nil, true,
  "EXECUTIVEF line resolves")
T.eq(ex.resolveLine("MYSTICALMAN"):find("Passion", 1, true) ~= nil, true,
  "MYSTICALMAN line resolves")

-- Aliases
T.eq(ex.resolveLine("COOLTRAINERM"):find("stronger", 1, true) ~= nil, true,
  "COOLTRAINERM aliases to COOLTRAINER_M")
T.eq(ex.resolveLine("COOLTRAINERF"):find("trained", 1, true) ~= nil, true,
  "COOLTRAINERF aliases to COOLTRAINER_F")
T.eq(ex.resolveLine("BLACKBELT_T"):find("Trained", 1, true) ~= nil, true,
  "BLACKBELT_T aliases to BLACKBELT")
T.eq(ex.resolveLine("PSYCHIC_T"):find("return", 1, true) ~= nil, true,
  "PSYCHIC_T aliases to PSYCHIC_TR")
T.eq(ex.resolveLine("SWIMMERM"):find("water", 1, true) ~= nil, true,
  "SWIMMERM aliases to SWIMMER")
T.eq(ex.resolveLine("SWIMMERF"):find("water", 1, true) ~= nil, true,
  "SWIMMERF aliases to SWIMMER")
T.eq(ex.resolveLine("CAMPER"):find("harder", 1, true) ~= nil, true,
  "CAMPER aliases to JR_TRAINER_M")
T.eq(ex.resolveLine("PICNICKER"):find("practiced", 1, true) ~= nil, true,
  "PICNICKER aliases to JR_TRAINER_F")
T.eq(ex.resolveLine("GUITARIST"):find("Encore", 1, true) ~= nil, true,
  "GUITARIST aliases to ROCKER")
T.eq(ex.resolveLine("GRUNTM"):find("Rocket", 1, true) ~= nil, true,
  "GRUNTM aliases to ROCKET")
T.eq(ex.resolveLine("GRUNTF"):find("Rocket", 1, true) ~= nil, true,
  "GRUNTF aliases to ROCKET")
T.eq(ex.resolveLine("CHAMPION"):find("dragons", 1, true) ~= nil, true,
  "CHAMPION aliases to LANCE")
T.eq(ex.resolveLine("POKEMON_PROF"):find("friend", 1, true) ~= nil, true,
  "POKEMON_PROF aliases to PROF_OAK")

-- Gen 2 Declines & Warnings
T.eq(ex.resolveDecline("WHITNEY"):find("mean", 1, true) ~= nil, true,
  "WHITNEY decline line resolves")
T.eq(ex.resolveDecline("FALKNER"):find("skies", 1, true) ~= nil, true,
  "FALKNER decline line resolves")
T.eq(ex.resolveWarning("CLAIR"):find("Dragon", 1, true) ~= nil, true,
  "CLAIR warning resolves")
T.eq(ex.resolveWarning("RED"):find("%.%.%.", 1, false) ~= nil, true,
  "RED warning resolves")

-- ------------------------------------------------ Gen 2 NPC Structure & Overworld

local gen2Game = {
  data = {
    trainers = {
      classes = {
        YOUNGSTER = { id = "YOUNGSTER", name = "YOUNGSTER", index = 24,
          trainers = { { id = "JOEY1", name = "JOEY", party = { { level = 4, species = "RATTATA" } } } } },
        FALKNER = { id = "FALKNER", name = "FALKNER", index = 1,
          trainers = { { id = "FALKNER1", name = "FALKNER", party = { { level = 7, species = "PIDGEY" }, { level = 9, species = "PIDGEOTTO" } } } } },
      }
    }
  },
  save = {
    party = { { level = 12 } },
    events = { [100] = true },
  },
  stack = { push = function(_, s) table.insert(pushed, s) end },
}

local gen2Npc = {
  def = {
    trainer = { class = 24, member = 1, event = 100 },
    index = 2,
  },
  frozen = false,
  facePlayer = function() end,
}

local gen2StartedScript = nil
local gen2Ow = {
  game = gen2Game,
  player = {},
  events = { get = function(_, ev) return ev == 100 end },
  trainerBeaten = function(self, record)
    return record and record.event == 100
  end,
  startTrainerScript = function(self, npc, script, sight)
    gen2StartedScript = script
    return true
  end,
}

T.eq(ex.isTrainerDefeated(gen2Ow, gen2Npc), true, "isTrainerDefeated detects beaten Gen 2 trainer")

local info = ex.extractTrainerInfo(gen2Npc, gen2Game)
T.neq(info, nil, "extractTrainerInfo extracts Gen 2 trainer struct")
T.eq(info.classId, "YOUNGSTER", "classId resolved from classes index")
T.eq(info.partyIndex, 1, "member index extracted")
T.eq(#info.team, 1, "team roster extracted")

-- Offer rematch on Gen 2 overworld
pushed = {}
local gen2TalkTo = overworldStub.talkTo
overworldStub.talkTo(gen2Ow, gen2Npc)
T.eq(#pushed, 1, "rematch prompt pushed on Gen 2")
T.eq(pushed[1].text:find("shorts", 1, true) ~= nil, true, "shows YOUNGSTER challenge line")

-- Accept on Gen 2 starts trainer script
pushed[1].opts.choice(true)
T.neq(gen2StartedScript, nil, "trainer script started on accept")
T.eq(gen2StartedScript[1].op, "loadtrainer", "script loads trainer")
T.eq(gen2StartedScript[1].member, 1, "script loads member 1")
T.eq(gen2StartedScript[2].op, "startbattle", "script starts battle")

-- ------------------------------------------------ Gen 2 Battle Prize & Pay Day

local gen2BattleClass = {
  awardPrizeMoney = function(self)
    local prize = (self.trainer.baseMoney or 0) * (self.enemyParty and self.enemyParty[1].level or 1)
    self.save.player.money = self.save.player.money + prize
    self.prize = { total = prize }
    return self.prize
  end,
  new = function(opts)
    return {
      trainer = opts.trainer,
      save = opts.save,
      enemyParty = opts.party,
    }
  end
}

-- Re-install with Gen 2 battle stub
package.loaded["src.battle.gen2.Battle"] = gen2BattleClass
ex.install(gen2Game, { overworld = overworldStub, textBox = textBoxStub, runtime = runtimeStub })

local gen2Save = { player = { money = 5000 } }
local gen2RematchBattle = {
  rematch = true,
  trainer = { baseMoney = 200 },
  enemyParty = { { level = 10 } },
  save = gen2Save,
  payDay = 400,
}
setmetatable(gen2RematchBattle, { __index = gen2BattleClass })

-- 0% money: prize is zeroed and payDay cleared
gen2BattleClass.awardPrizeMoney(gen2RematchBattle)
T.eq(gen2Save.player.money, 5000, "0% rematch money awards no money in Gen 2")
T.eq(gen2RematchBattle.payDay, nil, "payDay suppressed on Gen 2 rematch")

-- 50% money: prize is scaled by 50%
run.loader.modOptions["trainer_rematch"] = { rematchMoneyPct = 50 }
local gen2RematchBattle50 = {
  rematch = true,
  trainer = { baseMoney = 200 },
  enemyParty = { { level = 10 } },
  save = gen2Save,
}
setmetatable(gen2RematchBattle50, { __index = gen2BattleClass })
gen2BattleClass.awardPrizeMoney(gen2RematchBattle50)
T.eq(gen2Save.player.money, 5000 + 1000, "50% rematch money awards scaled money (50%) in Gen 2")
run.loader.modOptions["trainer_rematch"] = nil

-- Non-rematch battle awards full money
local gen2NormalBattle = {
  rematch = false,
  trainer = { baseMoney = 200 },
  enemyParty = { { level = 10 } },
  save = gen2Save,
}
setmetatable(gen2NormalBattle, { __index = gen2BattleClass })
gen2BattleClass.awardPrizeMoney(gen2NormalBattle)
T.eq(gen2Save.player.money, 6000 + 2000, "normal battle awards full money in Gen 2")

-- ------------------------------------------------ Gen 2 Gym Leader Rematches

local falknerNpc = {
  def = {
    scriptKey = "VioletGym_FalknerScript",
    index = 1,
  },
  frozen = false,
  facePlayer = function() end,
}

local falknerOwBeaten = {
  game = gen2Game,
  player = {},
  events = { get = function(_, ev) return ev == 1213 end },
  trainerBeaten = function(self, record)
    -- Matches real engine behavior: returns false for Gym Leader objects without record.event
    if not (record and record.event) then return false end
    return false
  end,
  scripts = {
    VioletGym_FalknerScript = {
      { op = "checkevent", event = 1213 },
      { op = "loadtrainer", class = "FALKNER", member = 1 },
      { op = "startbattle" },
    }
  },
  startTrainerScript = function(self, npc, script)
    gen2StartedScript = script
    return true
  end,
}

local falknerInfo = ex.extractTrainerInfo(falknerNpc, gen2Game, falknerOwBeaten)
T.neq(falknerInfo, nil, "extractTrainerInfo detects Falkner from scriptKey")
T.eq(falknerInfo.classId, "FALKNER", "Falkner classId resolved")
T.eq(ex.isTrainerDefeated(falknerOwBeaten, falknerNpc, falknerInfo), true,
  "Falkner detected as defeated when EVENT_BEAT_FALKNER is set")

-- Talk to beaten Falkner -> rematch offered
pushed = {}
overworldStub.talkTo(falknerOwBeaten, falknerNpc)
T.eq(#pushed, 1, "rematch prompt offered for beaten Falkner")
T.eq(pushed[1].text:find("training", 1, true) ~= nil, true, "shows Falkner challenge line")

-- Accept -> starts Falkner battle
gen2StartedScript = nil
pushed[1].opts.choice(true)
T.neq(gen2StartedScript, nil, "starts battle script for Falkner")
T.eq(gen2StartedScript[1].class, "FALKNER", "loads Falkner class")
T.eq(gen2StartedScript[1].member, 1, "loads member 1")

-- Undefeated Falkner falls through to vanilla even when early-game events (like event 64) are set
local falknerOwUndefeated = {
  game = gen2Game,
  player = {},
  events = { get = function(_, ev) return ev == 64 end },
  trainerBeaten = function(self, record) return false end,
  scripts = falknerOwBeaten.scripts,
}
pushed = {}
T.eq(ex.isTrainerDefeated(falknerOwUndefeated, falknerNpc, falknerInfo), false,
  "Falkner correctly detected as undefeated when only early-game event 64 is set")
local talkReturned = overworldStub.talkTo(falknerOwUndefeated, falknerNpc)
T.eq(#pushed, 0, "no rematch prompt for undefeated Falkner")
T.neq(talkReturned, true, "falls through to vanilla script for undefeated Falkner")

run.release()
T.finish("trainer_rematch")

