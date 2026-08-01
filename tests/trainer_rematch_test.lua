-- Trainer Rematch headless suite. Run from the engine checkout:
--   POKEPORT_DATA_DIR=tests/fixture_data luajit mods/trainer_rematch/tests/trainer_rematch_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path
local T = require("tests.modkit")
local Data = T.fixtures.load()

local run = T.sdk.loadMod("mods/trainer_rematch", { data = Data })
T.eq(#run.errors, 0, "loads clean")
local ex = run.loader.exports.trainer_rematch
T.neq(ex, nil, "exports reachable")

-- ------------------------------------------------ pure line resolution

T.eq(ex.resolveLine("OPP_YOUNGSTER"):find("shorts", 1, true) ~= nil, true,
  "YOUNGSTER line is in his voice")
T.eq(ex.resolveLine("OPP_LANCE"):find("dragons", 1, true) ~= nil, true,
  "LANCE line is in his voice")
T.eq(ex.resolveLine("OPP_UNUSED_JUGGLER"):find("juggling", 1, true) ~= nil, true,
  "UNUSED_JUGGLER gets a line too")
T.eq(ex.resolveLine("OPP_FIX_YOUNGSTER"), "You're looking\nfor a rematch?",
  "unknown class falls back to the default prompt")
T.eq(ex.resolveLine(nil), "You're looking\nfor a rematch?",
  "nil class falls back to the default prompt")

-- ------------------------------------------------ pure decline resolution

T.eq(ex.resolveDecline("OPP_YOUNGSTER"):find("scared", 1, true) ~= nil, true,
  "cocky classes mock the refusal")
T.eq(ex.resolveDecline("OPP_KOGA"):find("Fear", 1, true) ~= nil, true,
  "wise classes answer with understanding")
T.eq(ex.resolveDecline("OPP_GENTLEMAN"):find("gentleman", 1, true) ~= nil, true,
  "polite classes stay polite")
T.eq(ex.resolveDecline("OPP_FIX_YOUNGSTER"), "Ha! Scared of\na rematch, are\nyou?",
  "unknown class falls back to the default decline")
T.eq(ex.resolveDecline(nil), "Ha! Scared of\na rematch, are\nyou?",
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

run.release()
T.finish("trainer_rematch")
