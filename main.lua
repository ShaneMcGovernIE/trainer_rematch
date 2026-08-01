-- Trainer Rematch: talk to a trainer you have already beaten to get a
-- rematch.  Rematch battles award no money.  Each trainer class opens
-- with a line in its own voice, matched to the personality that class
-- shows in its regular dialogue.

-- One line per trainer class, written in the class's voice.  The line
-- leads straight into the YES/NO prompt, so every one reads as a
-- challenge.  Rows are the text box's lines (max 18 chars each).
local REMATCH_LINES = {
  OPP_YOUNGSTER    = "I like shorts!\nBut I'm not\nlosing twice!",
  OPP_BUG_CATCHER  = "My BUG POKéMON\nwant to battle\nyou again!",
  OPP_LASS         = "I've been training\nsince we last\nfought. Rematch?",
  OPP_SAILOR       = "You're back,\nlandlubber! One\nmore battle?",
  OPP_JR_TRAINER_M = "I'll try harder\nthis time. Let's\nbattle again!",
  OPP_JR_TRAINER_F = "I've practiced\na lot since\nlast time!",
  OPP_POKEMANIAC   = "I've caught even\nmore POKéMON\nsince you beat me!",
  OPP_SUPER_NERD   = "I've studied\nyour strategy.\nLet's try again!",
  OPP_HIKER        = "I've climbed many\nmountains since\nour last battle!",
  OPP_BIKER        = "You're back for\nmore? Let's go\nfor a ride!",
  OPP_BURGLAR      = "You beat me\nonce. I want to\nsettle this!",
  OPP_ENGINEER     = "I've built some\nnew machines.\nTest them!",
  OPP_UNUSED_JUGGLER = "I've been\npracticing my\njuggling. Watch!",
  OPP_FISHER       = "The fish here\naren't the only\nthing I'll catch!",
  OPP_SWIMMER      = "The water's fine.\nLet's battle\nagain!",
  OPP_CUE_BALL     = "I'm not done\nwith you yet.\nRematch!",
  OPP_GAMBLER      = "I'll bet my\nPOKéMON can beat\nyours this time!",
  OPP_BEAUTY       = "I won't lose\nthis time. Care\nfor a rematch?",
  OPP_PSYCHIC_TR   = "I knew you'd\ncome back. Let's\nbattle again!",
  OPP_ROCKER       = "The encore is\nover. Time for\nround two!",
  OPP_JUGGLER      = "I've been\npracticing my\njuggling. Watch!",
  OPP_TAMER        = "My POKéMON are\nhungry for a\nrematch!",
  OPP_BIRD_KEEPER  = "My flying\nPOKéMON want to\nbattle again!",
  OPP_BLACKBELT    = "I've trained hard\nsince our last\nbattle. Rematch?",
  OPP_RIVAL1       = "You again? Fine,\nbut this time\nI'm not losing!",
  OPP_RIVAL2       = "You again? Fine,\nbut this time\nI'm not losing!",
  OPP_RIVAL3       = "You again? Fine,\nbut this time\nI'm not losing!",
  OPP_PROF_OAK     = "Care to battle\nme again, my\nyoung friend?",
  OPP_CHIEF        = "I won't lose\ntwice. Rematch!",
  OPP_SCIENTIST    = "My research\nshows I can\nbeat you now!",
  OPP_GIOVANNI     = "You've got nerve\ncoming back.\nWe'll see!",
  OPP_ROCKET       = "Team Rocket\nalways comes\nback. Rematch!",
  OPP_COOLTRAINER_M = "I've gotten\nstronger since\nwe last fought!",
  OPP_COOLTRAINER_F = "You're strong,\nbut I've trained\nsince then. Again?",
  OPP_BRUNO        = "Hoo hah! My\nmuscles have\ngrown! Rematch!",
  OPP_BROCK        = "You've returned.\nMy rock-hard\nPOKéMON await you!",
  OPP_MISTY        = "You're back!\nMy WATER POKéMON\nare ready for you!",
  OPP_LT_SURGE     = "Shock me again\nif you can,\nkid!",
  OPP_ERIKA        = "How lovely to\nsee you again.\nShall we battle?",
  OPP_KOGA         = "You have grown.\nProve it once\nmore. Rematch.",
  OPP_BLAINE       = "Ha! Fire burns\nbrighter the\nsecond time!",
  OPP_SABRINA      = "I foresaw your\nreturn. I have\nbeen waiting.",
  OPP_GENTLEMAN    = "Care for a\ncivilized\nrematch?",
  OPP_LORELEI      = "The cold winds\ncall for another\nbattle. Come.",
  OPP_CHANNELER    = "The spirits\nwish to see\nanother battle.",
  OPP_AGATHA       = "Heh heh heh.\nBack for more,\nare you?",
  OPP_LANCE        = "My dragons have\nslept long\nenough. Prove\nyourself again!",
}

local DEFAULT_LINE = "You're looking\nfor a rematch?"

-- One line per trainer class for when the player says NO.  Cocky and
-- rough classes mock the player; wise and polite ones are understanding.
local REMATCH_DECLINES = {
  OPP_YOUNGSTER    = "Ha! I knew\nit! Too scared\nto face me!",
  OPP_BUG_CATCHER  = "Chirp chirp!\nScared of a few\nlittle bugs?",
  OPP_LASS         = "Oh, I see.\nToo frightened\nof me, I bet!",
  OPP_SAILOR       = "Avast! Scared\nof the sea,\nare ya?",
  OPP_JR_TRAINER_M = "Coward! I bet\nyou're scared of\na real battle!",
  OPP_JR_TRAINER_F = "You're scared,\naren't you? I\nknew it!",
  OPP_POKEMANIAC   = "Ha! I guess my\ncollection scared\nyou off!",
  OPP_SUPER_NERD   = "Interesting.\nFear is just\npoor calculations.",
  OPP_HIKER        = "Hmph! Scared of\na little climb,\nare ya?",
  OPP_BIKER        = "Chicken! My\nwheels are too\nfast for you!",
  OPP_BURGLAR      = "Smart move.\nYou'd lose your\nPOKéMON to me.",
  OPP_ENGINEER     = "Fear of a\nmachine breakdown?\nHow fitting!",
  OPP_UNUSED_JUGGLER = "Afraid I'll\njuggle you dizzy?\nHeh.",
  OPP_FISHER       = "Got cold feet,\ndid ya? Ha!",
  OPP_SWIMMER      = "Scared to dip\nyour toes in,\nhuh?",
  OPP_CUE_BALL     = "Hah! You're\nscared of my\ntough moves!",
  OPP_GAMBLER      = "Chicken out? I\nwould've bet on\nit. Ha!",
  OPP_BEAUTY       = "Oh my. Afraid\nyour POKéMON\ncan't shine?",
  OPP_PSYCHIC_TR   = "I can see your\nfear. It's\nquite loud.",
  OPP_ROCKER       = "Too loud for\nyou? Ha! What\na pansy!",
  OPP_JUGGLER      = "Afraid I'll\njuggle you dizzy?\nHeh.",
  OPP_TAMER        = "Wise. My beasts\nwould've torn\nyou apart.",
  OPP_BIRD_KEEPER  = "Scared of a\nlittle flight?\nHa!",
  OPP_BLACKBELT    = "A wise choice.\nMy fists are\ntoo strong for\nyou.",
  OPP_RIVAL1       = "Ha! What a\nwimp. I've got\nbetter things\nto do.",
  OPP_RIVAL2       = "Ha! What a\nwimp. I've got\nbetter things\nto do.",
  OPP_RIVAL3       = "Ha! What a\nwimp. I've got\nbetter things\nto do.",
  OPP_PROF_OAK     = "Very well.\nWhen you're\nready, come\nback.",
  OPP_CHIEF        = "Chicken! I\nthought you had\nnerve!",
  OPP_SCIENTIST    = "Fear is a\nvariable I\naccounted for.",
  OPP_GIOVANNI     = "Coward. I\nexpected better\nof you.",
  OPP_ROCKET       = "Scared of Team\nRocket's power,\nhuh?",
  OPP_COOLTRAINER_M = "Too cool for a\nrematch? Ha!",
  OPP_COOLTRAINER_F = "Chicken! And\nhere I thought\nyou were strong.",
  OPP_BRUNO        = "Hoo hah! Fear\nis a weakness!\nTrain harder!",
  OPP_BROCK        = "Hm. You aren't\nready. Come\nback when you\nare.",
  OPP_MISTY        = "Heh, scared of\nsome WATER\nPOKéMON?",
  OPP_LT_SURGE     = "Ha! Scared of\na little shock?\nSome soldier\nyou are!",
  OPP_ERIKA        = "How shy. When\nyou're ready,\nI'll be here.",
  OPP_KOGA         = "Fear is poison.\nTrain your\nmind, then\nreturn.",
  OPP_BLAINE       = "Ha! The heat\ntoo much for\nyou?",
  OPP_SABRINA      = "I foresaw this\ntoo. Your fear\nis clear.",
  OPP_GENTLEMAN    = "Very well. A\ntrue gentleman\nnever presses.",
  OPP_LORELEI      = "Cold feet in\nthe cold winds?\nHow fitting.",
  OPP_CHANNELER    = "The spirits\ncan wait. Fear\nis natural.",
  OPP_AGATHA       = "Heh heh. Scared\nof an old\nwoman, are you?",
  OPP_LANCE        = "I respect a\ncareful trainer.\nTrain, then\nreturn.",
}

local DEFAULT_DECLINE = "Ha! Scared of\na rematch, are\nyou?"

local function resolveLine(classId)
  return REMATCH_LINES[classId] or DEFAULT_LINE
end

local function resolveDecline(classId)
  return REMATCH_DECLINES[classId] or DEFAULT_DECLINE
end

-- the prize line filtered out of rematch victory queues
local function isPrizeLine(text)
  return type(text) == "string" and text:find("got ", 1, true) ~= nil
    and text:find("for winning", 1, true) ~= nil
end

return function(mod)
  mod.exports.resolveLine = resolveLine
  mod.exports.resolveDecline = resolveDecline
  mod.exports.isPrizeLine = isPrizeLine

  local function offerRematch(self, npc, game, deps)
    local d = npc.def
    local TextBox = deps.textBox or require("src.render.TextBox")
    local Runtime = deps.runtime or require("src.mods.Runtime")
    local BattleState = deps.battleState or require("src.battle.BattleState")
    npc.frozen = true
    npc:facePlayer(self.player)
    local unfreeze = function() npc.frozen = false end

    local function decline()
      -- the class reacts to the NO: mocking, or understanding for the
      -- wise classes.  The trainer's vanilla post-battle line follows as
      -- a second page, so the base-game text is never lost.
      local header = game.data:trainerHeader(self.map.def.label, d.index)
      local after = header and header.after and game.data.text[header.after]
      local line = resolveDecline(d.trainerClass)
      if after then line = line .. "\f" .. after end
      game.stack:push(TextBox.new(game, line, unfreeze))
    end

    local function accept()
      Runtime.emit("world.trainer_engaged", { npc = npc,
        trainerClass = d.trainerClass, partyIndex = d.trainerParty })
      local header = game.data:trainerHeader(self.map.def.label, d.index)
      local wonText = header and header.won and game.data.text[header.won]
      local battle = BattleState.newTrainer(game, d.trainerClass, d.trainerParty)
      battle.rematch = true
      battle.endBattleText = wonText and TextBox.substitute(game, wonText) or nil
      battle.onFinish = function(result)
        self:afterBattle(result, battle)
        unfreeze()
      end
      self:pushBattle(battle)
    end

    game.stack:push(TextBox.new(game, resolveLine(d.trainerClass), nil, {
      choice = function(yes)
        if yes then accept() else decline() end
      end,
    }))
  end

  -- deps injectable so the headless test can drive the wraps without the
  -- engine; in-game every one resolves to the real module
  local function install(game, deps)
    deps = deps or {}
    local Overworld = deps.overworld or require("src.world.OverworldController")
    local BattleState = deps.battleState or require("src.battle.BattleState")
    local TextBox = deps.textBox or require("src.render.TextBox")
    local Runtime = deps.runtime or require("src.mods.Runtime")
    local mapScripts = deps.mapScripts or require("data.scripts.init")

    -- one wrap per boot; hot reload re-runs entry chunks without clearing
    -- the require cache, so the module table is the idempotence sentinel
    if Overworld._rematchTalkWrapped then return end
    Overworld._rematchTalkWrapped = true

    local vanillaTalkTo = Overworld.talkTo
    Overworld.talkTo = function(self, npc)
      local d = npc.def
      -- only the generic-trainer branch: scripted encounters (gym leaders,
      -- rivals, story fights) keep their own flow, defeated or not
      local scripted = mapScripts and mapScripts.talkScript(self.map.id, d.text)
      if not scripted and d.trainerClass and self:trainerDefeated(npc) then
        return offerRematch(self, npc, game, deps)
      end
      return vanillaTalkTo(self, npc)
    end

    -- no money from a rematch: zero the class base money for this battle
    -- only (never touch the shared data record) and drop the prize line
    local vanillaFainted = BattleState.enemyMonFainted
    BattleState.enemyMonFainted = function(self, ...)
      if not self.rematch then return vanillaFainted(self, ...) end
      local realTrainer = self.trainer
      self.trainer = setmetatable({ baseMoney = 0 }, { __index = realTrainer })
      local realSayNext = self.sayNext
      self.sayNext = function(s, text)
        if isPrizeLine(text) then return end
        return realSayNext(s, text)
      end
      local ok, err = pcall(vanillaFainted, self, ...)
      self.trainer = realTrainer
      self.sayNext = realSayNext
      if not ok then error(err, 2) end
    end

    -- Pay Day is a reward too: nothing to collect on a rematch
    local vanillaFinish = BattleState.finish
    BattleState.finish = function(self)
      if self.rematch then self.payDay = nil end
      return vanillaFinish(self)
    end
  end
  mod.exports.install = install

  mod.events:on("game.ready", function(ev)
    install(ev.game)
  end)
end
