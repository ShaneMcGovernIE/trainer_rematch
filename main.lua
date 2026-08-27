-- Trainer Rematch: talk to a trainer you have already beaten to get a
-- rematch.  Rematch battles award a percentage of the usual money and
-- experience (MODS > Trainer Rematch: 0-100% in 10% steps; money
-- defaults to 0%, XP to 100%).  Each trainer class opens with a line in
-- its own voice, matched to the personality that class shows in its
-- regular dialogue.

-- One line per trainer class, written in the class's voice.  The line
-- leads straight into the YES/NO prompt, so every one reads as a
-- challenge.  Rows are the text box's lines (max 18 chars each, max 2 lines per box).
local REMATCH_LINES = {
  -- Gen 1 / Shared classes
  OPP_YOUNGSTER    = "I like shorts!\nRematch with me?",
  OPP_BUG_CATCHER  = "My BUG POKéMON\nwant a rematch!",
  OPP_LASS         = "I've trained since\nwe fought. Again?",
  OPP_SAILOR       = "Ahoy, landlubber!\nOne more battle?",
  OPP_JR_TRAINER_M = "I'll try harder\nnow. Let's battle!",
  OPP_JR_TRAINER_F = "I've practiced a\nlot! Rematch?",
  OPP_POKEMANIAC   = "Caught even more\nPOKéMON! Rematch?",
  OPP_SUPER_NERD   = "I studied your\nmoves. Try again?",
  OPP_HIKER        = "Climbed mountains\nsince then! Fight?",
  OPP_BIKER        = "Back for more?\nLet's ride again!",
  OPP_BURGLAR      = "You beat me once.\nTime to settle it!",
  OPP_ENGINEER     = "Built new machines\nfor this! Battle?",
  OPP_UNUSED_JUGGLER = "New juggling moves\nto show! Rematch?",
  OPP_FISHER       = "Caught more than\nfish! Care to try?",
  OPP_SWIMMER      = "The water is fine!\nLet's go again!",
  OPP_CUE_BALL     = "Not done with you\nyet. Rematch!",
  OPP_GAMBLER      = "Bet my POKéMON can\nwin this time!",
  OPP_BEAUTY       = "I won't lose this\ntime. Rematch?",
  OPP_PSYCHIC_TR   = "I saw your return!\nBattle again?",
  OPP_ROCKER       = "Encore is over!\nReady for round 2?",
  OPP_JUGGLER      = "New juggling moves\nto show! Rematch?",
  OPP_TAMER        = "My beasts hunger\nfor a rematch!",
  OPP_BIRD_KEEPER  = "My flock wants to\nbattle you again!",
  OPP_BLACKBELT    = "Trained hard since\nlast time! Fight?",
  OPP_RIVAL1       = "You again? I won't\nlose this time!",
  OPP_RIVAL2       = "You again? I won't\nlose this time!",
  OPP_RIVAL3       = "You again? I won't\nlose this time!",
  OPP_PROF_OAK     = "Care to battle me\nagain, my friend?",
  OPP_CHIEF        = "I won't lose\ntwice! Rematch!",
  OPP_SCIENTIST    = "Research says I'll\nwin now! Rematch?",
  OPP_GIOVANNI     = "Nerve to return?\nWe shall see!",
  OPP_ROCKET       = "Team Rocket always\nreturns! Battle?",
  OPP_COOLTRAINER_M = "I've grown much\nstronger! Rematch?",
  OPP_COOLTRAINER_F = "You're strong, but\nI've trained! Go?",
  OPP_BRUNO        = "Hoo hah! Muscles\ngrown! Rematch!",
  OPP_BROCK        = "My rock-hard team\nawaits you again!",
  OPP_MISTY        = "My WATER POKéMON\nare ready! Battle?",
  OPP_LT_SURGE     = "Shock me again if\nyou can, kid!",
  OPP_ERIKA        = "Lovely to see you.\nShall we battle?",
  OPP_KOGA         = "Prove your growth\nonce more! Fight!",
  OPP_BLAINE       = "Fire burns hotter\nthe second time!",
  OPP_SABRINA      = "I foresaw this.\nI have been ready.",
  OPP_GENTLEMAN    = "Care for another\ncivilized bout?",
  OPP_LORELEI      = "The cold winds\ncall us! Battle?",
  OPP_CHANNELER    = "Spirits wish for\nanother battle!",
  OPP_AGATHA       = "Heh heh! Back for\nmore, are you?",
  OPP_LANCE        = "My dragons hunger\nfor battle! Ready?",

  -- Gen 2 Leaders, Elite Four & Champions
  OPP_FALKNER      = "I've been training\nsince our battle.\fShall we battle in\nthe sky once more?",
  OPP_BUGSY        = "BUG research has\ndeepened! Rematch?",
  OPP_WHITNEY      = "I won't cry now!\nLet's fight again!",
  OPP_MORTY        = "Ghosts trained in\nsecret! Rematch?",
  OPP_CHUCK        = "HRAAGH! Waterfall\ntraining! Rematch?",
  OPP_JASMINE      = "My steel defense\nhas grown! Battle?",
  OPP_PRYCE        = "Winter tempered my\nresolve! Rematch?",
  OPP_CLAIR        = "I won't lose now!\nFace my dragons!",
  OPP_WILL         = "I foresaw our next\nclash! Prepared?",
  OPP_KAREN        = "Battle with your\nfavorites again!",
  OPP_JANINE       = "Ninja skills won't\nfail me! Prepare!",
  OPP_RED          = "... ... ...\n... ... Rematch?",
  OPP_BLUE         = "Smell ya later?\nNo way! Let's go!",
  OPP_CAL          = "Test our skills\nonce more! Ready?",

  -- Gen 2 Johto/Kanto Trainer Classes
  OPP_SCHOOLBOY    = "Studied all battle\ntheory! Test me!",
  OPP_SKIER        = "Snow is fresh and\nso is my team! Go!",
  OPP_TEACHER      = "Time for a pop\nquiz in battling!",
  OPP_FIREBREATHER = "My fire burns even\nhotter! Feel heat!",
  OPP_SAGE         = "Harmony of spirits\ntested once more.",
  OPP_MEDIUM       = "Spirits gather for\nour battle. Begin?",
  OPP_BOARDER      = "New moves on the\nsnow! Rematch?",
  OPP_POKEFANM     = "Darling POKéMON\nready to show off!",
  OPP_POKEFANF     = "My sweet POKéMON\ncare to battle?",
  OPP_KIMONO_GIRL  = "Dance with our\nPOKéMON once more?",
  OPP_TWINS        = "Twice as tough as\nbefore! Rematch?",
  OPP_OFFICER      = "Halt! Care for a\nfriendly spar?",
  OPP_EXECUTIVEM   = "Team Rocket will\nnot lose! Rematch!",
  OPP_EXECUTIVEF   = "Pay for meddling\nwith us! Rematch!",
  OPP_MYSTICALMAN  = "Passion for legend\nnever wanes! Go!",
}

local DEFAULT_LINE = "Looking for a\nrematch with me?"

-- One line per trainer class for when the player says NO.  Cocky and
-- rough classes mock the player; wise and polite ones are understanding.
local REMATCH_DECLINES = {
  -- Gen 1 / Shared classes
  OPP_YOUNGSTER    = "Ha! I knew it!\nToo scared for me!",
  OPP_BUG_CATCHER  = "Scared of a few\nlittle bugs? Haha!",
  OPP_LASS         = "Oh, I see. Too\nfrightened of me!",
  OPP_SAILOR       = "Avast! Scared of\nthe sea, are ya?",
  OPP_JR_TRAINER_M = "Coward! Scared of\na real battle!",
  OPP_JR_TRAINER_F = "You're scared, I\nknew it! Teehee!",
  OPP_POKEMANIAC   = "Ha! My collection\nscared you off!",
  OPP_SUPER_NERD   = "Fear is just poor\ncalculations.",
  OPP_HIKER        = "Hmph! Scared of a\nlittle climb, eh?",
  OPP_BIKER        = "Chicken! My wheels\nare too fast!",
  OPP_BURGLAR      = "Smart move. You'd\nlose to me anyway.",
  OPP_ENGINEER     = "Fear of machine\nfailure? Fitting!",
  OPP_UNUSED_JUGGLER = "Afraid I'll juggle\nyou dizzy? Heh.",
  OPP_FISHER       = "Got cold feet,\ndid ya? Ha!",
  OPP_SWIMMER      = "Scared to dip your\ntoes in, huh?",
  OPP_CUE_BALL     = "Hah! Scared of my\ntough moves!",
  OPP_GAMBLER      = "Chicken out? I'd\nhave bet on it!",
  OPP_BEAUTY       = "Afraid my POKéMON\nwill outshine you?",
  OPP_PSYCHIC_TR   = "I can see fear.\nIt's quite loud.",
  OPP_ROCKER       = "Too loud for you?\nHa! What a wimp!",
  OPP_JUGGLER      = "Afraid I'll juggle\nyou dizzy? Heh.",
  OPP_TAMER        = "Wise. My beasts\nwould crush you.",
  OPP_BIRD_KEEPER  = "Scared of a little\nflight? Ha!",
  OPP_BLACKBELT    = "Wise choice. My\nfists are strong.",
  OPP_RIVAL1       = "Ha! What a wimp.\nSee ya later!",
  OPP_RIVAL2       = "Ha! What a wimp.\nSee ya later!",
  OPP_RIVAL3       = "Ha! What a wimp.\nSee ya later!",
  OPP_PROF_OAK     = "Very well. Return\nwhen you're ready.",
  OPP_CHIEF        = "Chicken! I thought\nyou had nerve!",
  OPP_SCIENTIST    = "Fear is a variable\nI accounted for.",
  OPP_GIOVANNI     = "Coward. I expected\nbetter of you.",
  OPP_ROCKET       = "Scared of Team\nRocket's power?",
  OPP_COOLTRAINER_M = "Too cool for a\nrematch? Ha!",
  OPP_COOLTRAINER_F = "Chicken! I thought\nyou were strong.",
  OPP_BRUNO        = "Hoo hah! Fear is\nweakness! Train!",
  OPP_BROCK        = "Not ready yet?\nCome back later.",
  OPP_MISTY        = "Scared of getting\nsoaked? Heh!",
  OPP_LT_SURGE     = "Ha! Scared of a\nlittle shock, kid?",
  OPP_ERIKA        = "How shy. I will be\nhere when ready.",
  OPP_KOGA         = "Fear is poison.\nTrain your mind.",
  OPP_BLAINE       = "Ha! The heat is\ntoo much for you!",
  OPP_SABRINA      = "I foresaw this.\nFear is obvious.",
  OPP_GENTLEMAN    = "A true gentleman\nnever presses.",
  OPP_LORELEI      = "Cold feet in cold\nwinds? Fitting.",
  OPP_CHANNELER    = "Spirits can wait.\nFear is natural.",
  OPP_AGATHA       = "Heh heh! Scared of\nan old woman?",
  OPP_LANCE        = "I respect care.\nTrain and return.",

  -- Gen 2 Leaders, Elite Four & Champions
  OPP_FALKNER      = "I understand. The\nskies can wait.",
  OPP_BUGSY        = "Aw, don't bug out\non me now!",
  OPP_WHITNEY      = "Waaah! Why're you\nbeing so mean?",
  OPP_MORTY        = "Unseen paths are\nnot for everyone.",
  OPP_CHUCK        = "Wahaha! Need to\nbulk up first?",
  OPP_JASMINE      = "I understand...\nTake care, then.",
  OPP_PRYCE        = "A frozen heart\ncannot battle.",
  OPP_CLAIR        = "Hmph! Don't waste\nmy time, then!",
  OPP_WILL         = "You cannot escape\nyour destiny.",
  OPP_KAREN        = "Hmph. How very\ndisappointing.",
  OPP_JANINE       = "Hahaha! Fooled by\nmy illusions?",
  OPP_RED          = "... ...\n... ...",
  OPP_BLUE         = "Haha! Still scared\nof the CHAMPION?",
  OPP_CAL          = "Come back when you\nare ready.",

  -- Gen 2 Johto/Kanto Trainer Classes
  OPP_SCHOOLBOY    = "Aww, back to my\nstudies then...",
  OPP_SKIER        = "Brrr! Got cold\nfeet already?",
  OPP_TEACHER      = "You get an F for\neffort today!",
  OPP_FIREBREATHER = "Too hot to handle,\nhuh?",
  OPP_SAGE         = "Patience and peace\nbe with you.",
  OPP_MEDIUM       = "Spirits depart in\nsilence...",
  OPP_BOARDER      = "Wiped out before\nwe started?",
  OPP_POKEFANM     = "Oh, you're missing\nout on cuteness!",
  OPP_POKEFANF     = "My POKéMON are too\nsweet for you!",
  OPP_KIMONO_GIRL  = "A gentle bow to\nyour prudence.",
  OPP_TWINS        = "Aww! You're no fun\nat all!",
  OPP_OFFICER      = "Move along then,\ncitizen!",
  OPP_EXECUTIVEM   = "Coward! You know\nRocket's power!",
  OPP_EXECUTIVEF   = "Smart of you to\nrun away.",
  OPP_MYSTICALMAN  = "The wind guides\nyou elsewhere...",
}

local DEFAULT_DECLINE = "Ha! Scared of a\nrematch, are you?"

-- One line per trainer class for the "your team is far stronger" warning,
-- spoken when the rematch team averages more than 10 levels above the
-- player's party.  Same voice as the challenge lines: the class owns the
-- warning.  Rows are the text box's lines (max 18 chars each, max 2 lines per box).
local REMATCH_WARNINGS = {
  OPP_BROCK      = "My team is far\nstronger. Sure?",
  OPP_MISTY      = "My team is far\nbeyond yours! Go?",
  OPP_LT_SURGE   = "Warning: my team\nis high level! Go?",
  OPP_ERIKA      = "My flowers bloomed\npast you. Sure?",
  OPP_KOGA       = "My deadly poison\nis beyond you! Go?",
  OPP_BLAINE     = "The heat burns far\nbeyond you! Ready?",
  OPP_SABRINA    = "I see your team is\noutmatched. Sure?",
  OPP_LORELEI    = "My cold winds are\nfar stronger! Go?",
  OPP_BRUNO      = "Hoo hah! My power\nis far beyond you!",
  OPP_AGATHA     = "Heh! My ghosts are\nfar above you! Go?",
  OPP_LANCE      = "My dragons tower\nfar above you! Go?",
  OPP_RIVAL3     = "My team is far\nstronger! Sure?",

  -- Gen 2 Leaders & Bosses
  OPP_FALKNER    = "My birds soar far\nabove you. Sure?",
  OPP_BUGSY      = "My bugs swarm far\nbeyond you. Ready?",
  OPP_WHITNEY    = "Cute POKéMON are\nsuper tough! Sure?",
  OPP_MORTY      = "My ghost POKéMON\nlurk beyond! Sure?",
  OPP_CHUCK      = "HRAAGH! Crush you\nwith power! Sure?",
  OPP_JASMINE    = "My steel defense\nis far beyond you!",
  OPP_PRYCE      = "Biting cold will\nfreeze you. Ready?",
  OPP_CLAIR      = "Dragon wrath is\nbeyond you! Ready?",
  OPP_WILL       = "I saw your team is\noutmatched. Sure?",
  OPP_KAREN      = "Dark team is far\nstronger now. Go?",
  OPP_JANINE     = "Toxic tricks are\nbeyond you! Ready?",
  OPP_RED        = "... ... ...!\n(He is powerful!)",
  OPP_BLUE       = "My genius team is\nway out of league!",
  OPP_CAL        = "Training team is\nfar above! Sure?",
  OPP_EXECUTIVEM = "Executive power\nis far beyond you!",
  OPP_EXECUTIVEF = "I'll crush you\nwithout mercy! Go?",
}

local DEFAULT_WARN = "My team is far\nstronger! Sure?"

-- Normalize trainer class names across Gen 1 (OPP_ prefix), Gen 2 (bare names),
-- and variant naming spellings.
local ALIAS_MAP = {
  OPP_COOLTRAINERM = "OPP_COOLTRAINER_M",
  COOLTRAINERM     = "OPP_COOLTRAINER_M",
  COOLTRAINER_M    = "OPP_COOLTRAINER_M",
  OPP_COOLTRAINERF = "OPP_COOLTRAINER_F",
  COOLTRAINERF     = "OPP_COOLTRAINER_F",
  COOLTRAINER_F    = "OPP_COOLTRAINER_F",
  OPP_BLACKBELT_T  = "OPP_BLACKBELT",
  BLACKBELT_T      = "OPP_BLACKBELT",
  BLACKBELT        = "OPP_BLACKBELT",
  OPP_PSYCHIC_T    = "OPP_PSYCHIC_TR",
  PSYCHIC_T        = "OPP_PSYCHIC_TR",
  PSYCHIC_TR       = "OPP_PSYCHIC_TR",
  OPP_SWIMMERM     = "OPP_SWIMMER",
  SWIMMERM         = "OPP_SWIMMER",
  OPP_SWIMMERF     = "OPP_SWIMMER",
  SWIMMERF         = "OPP_SWIMMER",
  SWIMMER          = "OPP_SWIMMER",
  OPP_CAMPER       = "OPP_JR_TRAINER_M",
  CAMPER           = "OPP_JR_TRAINER_M",
  JR_TRAINER_M     = "OPP_JR_TRAINER_M",
  OPP_PICNICKER    = "OPP_JR_TRAINER_F",
  PICNICKER        = "OPP_JR_TRAINER_F",
  JR_TRAINER_F     = "OPP_JR_TRAINER_F",
  OPP_GUITARIST    = "OPP_ROCKER",
  GUITARIST        = "OPP_ROCKER",
  ROCKER           = "OPP_ROCKER",
  OPP_GRUNTM       = "OPP_ROCKET",
  GRUNTM           = "OPP_ROCKET",
  OPP_GRUNTF       = "OPP_ROCKET",
  GRUNTF           = "OPP_ROCKET",
  ROCKET           = "OPP_ROCKET",
  OPP_CHAMPION     = "OPP_LANCE",
  CHAMPION         = "OPP_LANCE",
  LANCE            = "OPP_LANCE",
  OPP_POKEMON_PROF = "OPP_PROF_OAK",
  POKEMON_PROF     = "OPP_PROF_OAK",
  PROF_OAK         = "OPP_PROF_OAK",
}

local function normalizeClassId(classId)
  if not classId then return nil end
  if type(classId) ~= "string" then classId = tostring(classId) end
  if ALIAS_MAP[classId] then return ALIAS_MAP[classId] end
  if REMATCH_LINES[classId] then return classId end
  local opp = "OPP_" .. classId
  if REMATCH_LINES[opp] then return opp end
  if classId:sub(1, 4) == "OPP_" then
    local stripped = classId:sub(5)
    if REMATCH_LINES[stripped] then return stripped end
    if ALIAS_MAP[stripped] then return ALIAS_MAP[stripped] end
  end
  return classId
end

local function resolveWarning(classId)
  local key = normalizeClassId(classId)
  return (key and REMATCH_WARNINGS[key]) or REMATCH_WARNINGS[classId] or DEFAULT_WARN
end

-- How many levels the trainer's team averages above the player's party;
-- nil when either side is empty, so callers can skip the warning.
local function levelGap(playerParty, team)
  if not team or #team == 0 then return nil end
  local playerLevels, playerCount = 0, 0
  if playerParty then
    for _, mon in ipairs(playerParty) do
      if mon and mon.level then
        playerLevels = playerLevels + mon.level
        playerCount = playerCount + 1
      end
    end
  end
  if playerCount == 0 then return nil end
  local teamLevels = 0
  for _, slot in ipairs(team) do
    teamLevels = teamLevels + (slot.level or 0)
  end
  return (teamLevels / #team) - (playerLevels / playerCount)
end

-- a percentage of a whole, rounded down; nil-safe for callers that have
-- no configured option yet
local function scaleByPercent(value, pct)
  return math.floor((value or 0) * (pct or 0) / 100)
end

-- a marked rematch team (rematchIndex) wins over the trainer's own party;
-- fallback is the npc's usual party index
local function resolvePartyIndex(record, fallback)
  local marked = record and record.rematchIndex
  if marked then
    if record.parties and record.parties[marked] then return marked end
    if record.trainers and record.trainers[marked] then return marked end
  end
  return fallback
end

local function resolveParty(record, index)
  if not record or not index then return nil end
  if record.parties and record.parties[index] then return record.parties[index] end
  if record.trainers and record.trainers[index] then
    return record.trainers[index].party or record.trainers[index].roster
  end
  return nil
end

local function resolveLine(classId)
  local key = normalizeClassId(classId)
  return (key and REMATCH_LINES[key]) or REMATCH_LINES[classId] or DEFAULT_LINE
end

local function resolveDecline(classId)
  local key = normalizeClassId(classId)
  return (key and REMATCH_DECLINES[key]) or REMATCH_DECLINES[classId] or DEFAULT_DECLINE
end

-- the prize line filtered out of rematch victory queues
local function isPrizeLine(text)
  return type(text) == "string" and text:find("got ", 1, true) ~= nil
    and text:find("for winning", 1, true) ~= nil
end

-- Leader flags and badge events for Gen 2 and Gen 1
local LEADER_PATTERNS = {
  FALKNER  = { class = "FALKNER", event = 1213, badge = "ZEPHYR", engineFlag = 26 },
  BUGSY    = { class = "BUGSY", event = 1214, badge = "HIVE", engineFlag = 27 },
  WHITNEY  = { class = "WHITNEY", event = 1215, badge = "PLAIN", engineFlag = 28 },
  MORTY    = { class = "MORTY", event = 1216, badge = "FOG", engineFlag = 29 },
  JASMINE  = { class = "JASMINE", event = 1217, badge = "MINERAL", engineFlag = 30 },
  CHUCK    = { class = "CHUCK", event = 1218, badge = "STORM", engineFlag = 31 },
  PRYCE    = { class = "PRYCE", event = 1219, badge = "GLACIER", engineFlag = 32 },
  CLAIR    = { class = "CLAIR", event = 1220, badge = "RISING", engineFlag = 33 },
  BROCK    = { class = "BROCK", event = 1221, badge = "BOULDER", engineFlag = 34 },
  MISTY    = { class = "MISTY", event = 1222, badge = "CASCADE", engineFlag = 35 },
  SURGE    = { class = "LT_SURGE", event = 1223, badge = "THUNDER", engineFlag = 36 },
  LT_SURGE = { class = "LT_SURGE", event = 1223, badge = "THUNDER", engineFlag = 36 },
  LTSURGE  = { class = "LT_SURGE", event = 1223, badge = "THUNDER", engineFlag = 36 },
  ERIKA    = { class = "ERIKA", event = 1224, badge = "RAINBOW", engineFlag = 37 },
  JANINE   = { class = "JANINE", event = 1225, badge = "SOUL", engineFlag = 38 },
  SABRINA  = { class = "SABRINA", event = 1226, badge = "MARSH", engineFlag = 39 },
  BLAINE   = { class = "BLAINE", event = 1227, badge = "VOLCANO", engineFlag = 40 },
  BLUE     = { class = "BLUE", event = 1228, badge = "EARTH", engineFlag = 41 },
  RED      = { class = "RED", event = 1890 },
  WILL     = { class = "WILL" },
  KOGA     = { class = "KOGA" },
  BRUNO    = { class = "BRUNO" },
  KAREN    = { class = "KAREN" },
  LANCE    = { class = "CHAMPION" },
  CHAMPION = { class = "CHAMPION" },
}

local function matchLeaderPattern(str)
  if not str or type(str) ~= "string" then return nil end
  local upper = str:upper()
  for name, leader in pairs(LEADER_PATTERNS) do
    if upper:find(name, 1, true) then
      return leader
    end
  end
  return nil
end

local function scanScriptForTrainer(scriptList, allScripts, visited)
  if not scriptList or type(scriptList) ~= "table" then return nil end
  visited = visited or {}
  local foundClass, foundMember, foundEvent
  for _, cmd in ipairs(scriptList) do
    if type(cmd) == "table" then
      local op = cmd.op
      if op == "loadtrainer" then
        foundClass = cmd.class or (cmd.args and cmd.args[1])
        foundMember = cmd.member or (cmd.args and cmd.args[2])
      elseif op == "checkevent" or op == "checkflag" then
        if not foundEvent then
          foundEvent = cmd.event or cmd.flag or (cmd.args and cmd.args[1])
        end
      elseif (op == "iftrue" or op == "iffalse" or op == "jump" or op == "farsjump") and cmd.script then
        if type(cmd.script) == "table" then
          local subClass, subMember, subEvent = scanScriptForTrainer(cmd.script, allScripts, visited)
          foundClass = foundClass or subClass
          foundMember = foundMember or subMember
          foundEvent = foundEvent or subEvent
        elseif type(cmd.script) == "string" and allScripts and not visited[cmd.script] then
          visited[cmd.script] = true
          local subClass, subMember, subEvent = scanScriptForTrainer(allScripts[cmd.script], allScripts, visited)
          foundClass = foundClass or subClass
          foundMember = foundMember or subMember
          foundEvent = foundEvent or subEvent
        end
      end
    end
  end
  return foundClass, foundMember, foundEvent
end

-- Helper to extract class, member index, and party records across Gen 1 and Gen 2 NPC structures
local function extractTrainerInfo(npc, game, overworld)
  local d = npc and npc.def
  if not d then return nil end

  local rawClass = d.trainerClass
  local partyIndex = d.trainerParty or 1
  local trainerEvent = nil

  if not rawClass and d.trainer then
    rawClass = d.trainer.class
    partyIndex = d.trainer.member or 1
    trainerEvent = d.trainer.event
  end

  -- If not on NPC definition, inspect script or match Gym Leader/Boss patterns
  if not rawClass then
    local allScripts = (overworld and overworld.scripts)
        or (overworld and overworld.vm and overworld.vm.scripts)
        or (game and game.data and (game.data.gen2Scripts or game.data.scripts))
    if d.scriptKey and allScripts and allScripts[d.scriptKey] then
      local scClass, scMember, scEvent = scanScriptForTrainer(allScripts[d.scriptKey], allScripts)
      if scClass then
        rawClass = scClass
        partyIndex = scMember or partyIndex
        trainerEvent = scEvent
      end
    end

    if not rawClass then
      local leader = matchLeaderPattern(d.sprite)
          or matchLeaderPattern(d.spriteName)
          or matchLeaderPattern(d.scriptKey)
          or matchLeaderPattern(d.text)
      if leader then
        rawClass = leader.class
        trainerEvent = leader.event
      end
    end
  end

  if not rawClass then return nil end

  local trainers = game and game.data and (game.data.trainers or game.data.gen2Trainers)
  local classRecord = nil
  if trainers then
    if trainers[rawClass] then
      classRecord = trainers[rawClass]
    elseif trainers.classes then
      if trainers.classes[rawClass] then
        classRecord = trainers.classes[rawClass]
      elseif type(rawClass) == "number" then
        for _, cls in pairs(trainers.classes) do
          if type(cls) == "table" and cls.index == rawClass then
            classRecord = cls
            break
          end
        end
      end
    end
  end

  local classId = (classRecord and (classRecord.id or classRecord.name)) or rawClass
  local team = resolveParty(classRecord, partyIndex)

  return {
    rawClass = rawClass,
    classId = classId,
    partyIndex = partyIndex,
    classRecord = classRecord,
    team = team,
    trainerEvent = trainerEvent,
    index = d.index,
    scriptKey = d.scriptKey or (d.trainer and d.trainer.scriptKey),
  }
end

-- Helper to determine if an NPC trainer is defeated across Gen 1 and Gen 2 world states
local function isTrainerDefeated(self, npc, info)
  if not npc or not npc.def then return false end
  local d = npc.def
  info = info or extractTrainerInfo(npc, (self and self.game), self)
  local classId = info and info.classId

  -- 1. Defeated check via Overworld methods (only accept true, fall through on false/nil)
  if self.trainerDefeated then
    local ok, defeated = pcall(self.trainerDefeated, self, npc)
    if ok and defeated == true then return true end
  end
  if self.trainerBeaten then
    local ok, beaten = pcall(self.trainerBeaten, self, d.trainer or d)
    if ok and beaten == true then return true end
  end

  local norm = classId and normalizeClassId(classId)
  if norm and norm:sub(1, 4) == "OPP_" then norm = norm:sub(5) end
  local leaderInfo = (norm and LEADER_PATTERNS[norm]) or (classId and LEADER_PATTERNS[classId])

  -- 2. Check badge via self:hasBadge
  if leaderInfo and leaderInfo.badge and self.hasBadge then
    local ok, has = pcall(self.hasBadge, self, leaderInfo.badge)
    if ok and has then return true end
  end

  -- 3. Event flags in self.events or self.game.save.events
  local events = self.events or (self.game and self.game.save and self.game.save.events)
  if events then
    local function checkFlag(flag)
      if not flag then return false end
      if events.get then
        local ok, v = pcall(events.get, events, flag)
        if ok and v then return true end
      end
      if type(events) == "table" and events[flag] then return true end
      return false
    end

    if info and info.trainerEvent and checkFlag(info.trainerEvent) then
      return true
    end
    if d.trainer and d.trainer.event and checkFlag(d.trainer.event) then
      return true
    end
    if leaderInfo and leaderInfo.event and checkFlag(leaderInfo.event) then
      return true
    end
  end

  -- 4. Check save.player.badges or save.badges table or save.engineFlags
  local save = (self.game and self.game.save) or self.save
  if save and leaderInfo then
    local badges = (save.player and save.player.badges) or save.badges
    if badges and leaderInfo.badge then
      if type(badges) == "table" and (badges[leaderInfo.badge] or badges[leaderInfo.badge:upper()]) then
        return true
      end
    end
    if save.engineFlags and leaderInfo.engineFlag then
      if save.engineFlags[leaderInfo.engineFlag] then return true end
    end
  end

  -- 5. Gen 1 numeric bitmask badges
  if save and norm then
    local GEN1_BADGE_BITS = {
      BROCK = 1, MISTY = 2, LT_SURGE = 4, LTSURGE = 4,
      ERIKA = 8, KOGA = 16, SABRINA = 32, BLAINE = 64, GIOVANNI = 128,
    }
    local bitMask = GEN1_BADGE_BITS[norm]
    if bitMask and type(badges) == "number" then
      if math.floor(badges / bitMask) % 2 == 1 then return true end
    end
  end

  return false
end

-- Active rematch flag for Gen 2 battle construction
local activeRematch = nil

return function(mod)
  mod.exports.resolveLine = resolveLine
  mod.exports.resolveDecline = resolveDecline
  mod.exports.resolveWarning = resolveWarning
  mod.exports.normalizeClassId = normalizeClassId
  mod.exports.levelGap = levelGap
  mod.exports.isPrizeLine = isPrizeLine
  mod.exports.scaleByPercent = scaleByPercent
  mod.exports.resolvePartyIndex = resolvePartyIndex
  mod.exports.resolveParty = resolveParty
  mod.exports.extractTrainerInfo = extractTrainerInfo
  mod.exports.isTrainerDefeated = isTrainerDefeated

  -- rematch earnings: a percentage of the usual battle money and
  -- experience, stepped in 10% intervals.  Money defaults to 0% (the
  -- original no-prize rematch behaviour); XP defaults to 100%, so
  -- behaviour is unchanged until the player moves the slider.
  mod.options:define({
    { key = "rematchMoneyPct", type = "number", label = "REMATCH MONEY %",
      min = 0, max = 100, step = 10, default = 0 },
    { key = "rematchXpPct", type = "number", label = "REMATCH XP %",
      min = 0, max = 100, step = 10, default = 100 },
  })

  local function offerRematch(self, npc, game, deps)
    deps = deps or {}
    local activeGame = (self and self.game) or game
    local d = npc.def
    local TextBox = deps.textBox or require("src.render.TextBox")
    local Runtime = deps.runtime or require("src.mods.Runtime")
    local BattleState = deps.battleState or (pcall(require, "src.battle.BattleState") and require("src.battle.BattleState"))
    npc.frozen = true
    if npc.facePlayer then npc:facePlayer(self.player) end
    local unfreeze = function() npc.frozen = false end

    local info = extractTrainerInfo(npc, activeGame, self)
    local classId = info and info.classId or (d and d.trainerClass)

    local function decline()
      -- the class reacts to the NO: mocking, or understanding for the
      -- wise classes.  The trainer's vanilla post-battle line follows as
      -- a second page, so the base-game text is never lost.
      local header = activeGame and activeGame.data and activeGame.data.trainerHeader
          and activeGame.data:trainerHeader(self.map and self.map.def and self.map.def.label, d.index)
      local after = header and header.after and activeGame.data.text and activeGame.data.text[header.after]
      local line = resolveDecline(classId)
      if after then line = line .. "\f" .. after end
      activeGame.stack:push(TextBox.new(activeGame, line, unfreeze))
    end

    local function accept()
      -- a mod may ship a dedicated rematch team for the class: the
      -- trainer record's rematchIndex points at it (Yellow Legacy Changes
      -- appends the hack's L64-77 rematch teams this way).  Fall back to
      -- the trainer's own party when none is marked.
      local partyIndex = resolvePartyIndex(info and info.classRecord, info and info.partyIndex or d.trainerParty)
      local team = resolveParty(info and info.classRecord, partyIndex) or (info and info.team)

      local function battle()
        Runtime.emit("world.trainer_engaged", {
          npc = npc,
          trainerClass = info and info.rawClass or d.trainerClass,
          partyIndex = partyIndex,
          trainerEvent = info and info.trainerEvent,
        })

        if self.startTrainerScript then
          -- Gen 2 engine overworld
          local REMATCH_SCRIPT = {
            { op = "loadtrainer", class = info and info.rawClass or d.trainerClass, member = partyIndex },
            { op = "startbattle" },
            { op = "reloadmapafterbattle" },
          }
          activeRematch = true
          self:startTrainerScript(npc, REMATCH_SCRIPT, nil)
        elseif self.pushBattle and BattleState and BattleState.newTrainer then
          -- Gen 1 engine overworld
          local header = activeGame and activeGame.data and activeGame.data.trainerHeader
              and activeGame.data:trainerHeader(self.map and self.map.def and self.map.def.label, d.index)
          local wonText = header and header.won and activeGame.data.text and activeGame.data.text[header.won]
          local b = BattleState.newTrainer(activeGame, info and info.rawClass or d.trainerClass, partyIndex)
          b.rematch = true
          b.endBattleText = wonText and TextBox.substitute and TextBox.substitute(activeGame, wonText) or nil
          b.onFinish = function(result)
            if self.afterBattle then self:afterBattle(result, b) end
            unfreeze()
          end
          self:pushBattle(b)
        else
          unfreeze()
        end
      end

      -- when the rematch team averages more than 10 levels above the
      -- player's party, the class warns in its own voice and asks again
      local playerParty = (activeGame and activeGame.save and activeGame.save.party)
          or (activeGame and activeGame.save and activeGame.save.player and activeGame.save.player.party)
      local gap = levelGap(playerParty, team)
      if gap and gap > 10 then
        activeGame.stack:push(TextBox.new(activeGame, resolveWarning(classId), nil, {
          choice = function(yes)
            if yes then battle() else decline() end
          end,
        }))
      else
        battle()
      end
    end

    activeGame.stack:push(TextBox.new(activeGame, resolveLine(classId), nil, {
      choice = function(yes)
        if yes then accept() else decline() end
      end,
    }))
    return true
  end

  -- deps injectable so the headless test can drive the wraps without the
  -- engine; in-game every one resolves to the real module
  local function install(game, deps)
    deps = deps or {}
    local Overworld = deps.overworld or require("src.world.OverworldController")
    local BattleState = deps.battleState or (pcall(require, "src.battle.BattleState") and require("src.battle.BattleState"))
    local mapScripts = deps.mapScripts or (pcall(require, "data.scripts.init") and require("data.scripts.init"))

    -- one wrap per boot; hot reload re-runs entry chunks without clearing
    -- the require cache, so the module table is the idempotence sentinel
    if Overworld and not Overworld._rematchTalkWrapped then
      Overworld._rematchTalkWrapped = true

      local vanillaTalkTo = Overworld.talkTo or function() return false end
      Overworld.talkTo = function(self, npc)
        local d = npc and npc.def
        if not d then return vanillaTalkTo(self, npc) end

        local activeGame = (self and self.game) or game
        local info = extractTrainerInfo(npc, activeGame, self)
        if info and isTrainerDefeated(self, npc, info) then
          local scripted = mapScripts and mapScripts.talkScript
              and mapScripts.talkScript(self.map and self.map.id, d.text)
          local hasDedicatedRematch = resolvePartyIndex(info.classRecord, nil) ~= nil
          if not scripted or hasDedicatedRematch or d.scriptKey or self.startTrainerScript then
            return offerRematch(self, npc, activeGame, deps)
          end
        end
        return vanillaTalkTo(self, npc)
      end
    end

    -- Gen 1 BattleState wraps: rematch money is a percentage of the usual prize
    -- (MODS > Trainer Rematch, 0-100% in 10s): scale the class base money for this battle
    -- only (never touch the shared data record), and at 0% drop the prize
    -- line entirely so no "You got ¥0" box appears
    if BattleState and not BattleState._rematchFaintedWrapped then
      BattleState._rematchFaintedWrapped = true

      local vanillaFainted = BattleState.enemyMonFainted
      if vanillaFainted then
        BattleState.enemyMonFainted = function(self, ...)
          if not self.rematch then return vanillaFainted(self, ...) end
          local realTrainer = self.trainer
          local pct = mod.options:get("rematchMoneyPct") or 0
          if realTrainer then
            self.trainer = setmetatable({
              baseMoney = scaleByPercent(realTrainer.baseMoney, pct),
            }, { __index = realTrainer })
          end
          local realSayNext = self.sayNext
          if pct <= 0 and realSayNext then
            self.sayNext = function(s, text)
              if isPrizeLine(text) then return end
              return realSayNext(s, text)
            end
          end
          local ok, err = pcall(vanillaFainted, self, ...)
          self.trainer = realTrainer
          self.sayNext = realSayNext
          if not ok then error(err, 2) end
        end
      end

      -- Pay Day is a reward too: nothing to collect on a rematch
      local vanillaFinish = BattleState.finish
      if vanillaFinish then
        BattleState.finish = function(self)
          if self.rematch then self.payDay = nil end
          return vanillaFinish(self)
        end
      end
    end

    -- Gen 2 Battle wraps: intercept prize money & battle construction on Gen 2
    local okGen2, Gen2Battle = pcall(require, "src.battle.gen2.Battle")
    if okGen2 and Gen2Battle and not Gen2Battle._rematchWrapped then
      Gen2Battle._rematchWrapped = true

      local vanillaBattleNew = Gen2Battle.new
      if vanillaBattleNew then
        Gen2Battle.new = function(opts)
          local b = vanillaBattleNew(opts)
          if b and (activeRematch or (opts and opts.rematch)) then
            b.rematch = true
            activeRematch = nil
          end
          return b
        end
      end

      local vanillaAwardPrize = Gen2Battle.awardPrizeMoney
      if vanillaAwardPrize then
        Gen2Battle.awardPrizeMoney = function(self)
          if not self.rematch then return vanillaAwardPrize(self) end
          local pct = mod.options:get("rematchMoneyPct") or 0
          if pct <= 0 then
            self.payDay = nil
            self.prize = { quarter = 0, total = 0, toMom = 0, mode = 0, wallet = 0, saved = 0 }
            return self.prize
          end
          local realTrainer = self.trainer
          if realTrainer then
            self.trainer = setmetatable({
              baseMoney = scaleByPercent(realTrainer.baseMoney, pct),
            }, { __index = realTrainer })
          end
          local ok, res = pcall(vanillaAwardPrize, self)
          self.trainer = realTrainer
          if not ok then error(res, 2) end
          return res
        end
      end
    end
  end
  mod.exports.install = install

  -- rematch experience scales the final gained EXP (default 100%).  The
  -- award ctx's applyShare takes a participant split, and the gain
  -- formula floors it through math.max(1, split): scaling that divisor
  -- by a percentage hits the floor for the usual single-participant
  -- battle (0% -> split 0 -> the max(1, .) guard restores full EXP).  The
  -- exp.gain hook sees the finished amount, so the award wrap only marks
  -- the battle as a rematch while vanilla runs and the exp.gain wrap does
  -- the scaling.
  local rematchXpPct
  mod.hooks:wrap("battle.exp_award", function(next, ctx)
    local saved = rematchXpPct
    rematchXpPct = ctx and ctx.battle and ctx.battle.rematch
        and (mod.options:get("rematchXpPct") or 100) or nil
    local ok, res = pcall(next, ctx)
    rematchXpPct = saved
    if not ok then error(res, 2) end
    return res
  end)
  mod.hooks:wrap("exp.gain", function(next, ctx)
    local pct = rematchXpPct
    if pct and pct ~= 100 then
      local gained = next(ctx)
      if gained == nil then return nil end
      return scaleByPercent(gained, pct)
    end
    return next(ctx)
  end)

  install()

  mod.events:on("game.ready", function(ev)
    install(ev.game)
  end)
end
