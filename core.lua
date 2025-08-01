local addonName, bepgp = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(bepgp, addonName, "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ADBO = LibStub("AceDBOptions-3.0")
local LDBO = LibStub("LibDataBroker-1.1"):NewDataObject(addonName)
local LDI = LibStub("LibDBIcon-1.0")
local LDD = LibStub("LibDropdown-1.0")
local LD = LibStub("LibDialog-1.0_Roadblock")
local C = LibStub("LibCrayon-3.0")
local DF = LibStub("LibDeformat-3.0")
local G = LibStub("LibGratuity-3.0")
local T = LibStub("LibQTip-1.0")

local wowver, wowbuild, wowbuildate, wowtocver = GetBuildInfo()
bepgp._DEBUG = false
bepgp._SUSPEND = false
bepgp._mists = _G.WOW_PROJECT_ID and (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MISTS_CLASSIC) or false
bepgp._cata = _G.WOW_PROJECT_ID and (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC) or false
bepgp._wrath = _G.WOW_PROJECT_ID and (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC) or false
bepgp._bcc = _G.WOW_PROJECT_ID and (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC) or false
bepgp._classic = _G.WOW_PROJECT_ID and (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC) or false

local RAID_CLASS_COLORS = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)
bepgp._network = {}

-- Upvalue some API
local C_TimerAfter = C_Timer.After
local CanLootUnit = _G.CanLootUnit -- local hasLoot, canLoot = CanLootUnit(guid)
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CombatLog_Object_IsA = _G.CombatLog_Object_IsA
local UnitInBattleground = _G.UnitInBattleground
local IsInActiveWorldPVP = _G.IsInActiveWorldPVP
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]
local strlen = string.utf8len or string.len
local strsub = string.utf8sub or string.sub

bepgp.VARS = {
  basegp = 100,
  minep = 0,
  baseaward_ep = 100,
  minilvl = 0,
  maxilvl = 572,
  prveto = false,
  decay = 0.8,
  max = 1000,
  timeout = 60,
  rosterthrottle = 10,
  minlevel = 90,
  maxloglines = 500,
  priorank = 100,
  standinrank = 100,
  maxreserves = 1,
  prefix = "BASTIONLOOT_PFX",
  pricesystem = "BastionEPGP_MOPC-1.0",
  progress = "T14",
  bop = C:Red(L["BoP"]),
  boe = C:Yellow(L["BoE"]),
  nobind = C:White(L["NoBind"]),
  msgp = L["Mainspec GP"],
  osgp = L["Offspec GP"],
  bankde = L["Bank-D/E"],
  unassigned = C:Red(L["Unassigned"]),
  autoloot = {
    [89112] = "MoteHarmony",
    [80433] = "BloodSpirit",
    [94289] = "HauntingSpirit",
    [102218] = "SpiritOfWar",
    [40752] = "BadgeHero",
    [101] = "currency",
    [40753] = "BadgeValor",
    [102] = "currency",
    [45624] = "BadgeConquest",
    [221] = "currency",
    [47241] = "BadgeTriumph",
    [301] = "currency",
    [49426] = "BadgeFrost",
    [341] = "currency",
    [241] = "currency",
    [2589] = "currency", -- sidereal essence
    [2711] = "currency", -- defiler's scourgestone
    [22484] = "Necrotic",
    [43494] = "Watcher",
    [43670] = "Tiki",
    [43697] = "Nathrezim",
    [43726] = "Crown",
    [43693] = "Mojo",
    [43668] = "Tuner",
    [43665] = "Heart",
    [43669] = "Locket",
    [43823] = "Cyanigosa",
    [43724] = "CelestialRuby",
    [43699] = "FleshDisc",
    [43821] = "Withered",
    [43662] = "PlundererAxe",
    [48418] = "SoulFragment",
    [202269] = "BountyAlpha",
    [208157] = "BountyBeta",
    [211206] = "DefilerMedallion",
    [211207] = "MysteriousArtifact",
    --[0] = "BountyGamma", -- unknown yet
    [45788] = "FreyaSigil",
    [45786] = "HodirSigil",
    [45787] = "MimironSigil",
    [45784] = "ThorimSigil",
    [45814] = "FreyaSigilH",
    [45815] = "HodirSigilH",
    [45816] = "MimironSigilH",
    [45817] = "ThorimSigilH",
    [51026] = "Sindragosa1",
    [51027] = "Sindragosa2",
    [52006] = "FrostySack",
    [52676] = "LeyCache",
    -- bcc
    [29434] = "Badge",
    [42] = "currency",
    [28558] = "SpiritShard",
    [29425] = "MarkKJ",
    [30809] = "MarkSG",
    [29426] = "SignetFW",
    [30810] = "SignetSF",
    [24368] = "Coilfang",
    [25433] = "Warbead",
    [29209] = "Zaxxis",
    [25463] = "IvoryTusk",
    [26042] = "OshuPowder",
    [32569] = "ApexisShard",
    [32572] = "ApexisCrystal",
    [32388] = "ShadowDust",
    [32620] = "TimeLostScroll",
    [30436] = "MechBlue",
    [30437] = "MechRed",
    [24514] = "Karafrag1",
    [24487] = "Karafrag2",
    [24488] = "Karafrag3",
    [31239] = "Shhkeymold",
    [31750] = "Gruulsignet",
    [23933] = "Medivjournal",
    [25461] = "Sythbook",
    [25462] = "KurseTome",
    [31751] = "NightBsignet",
    [31716] = "ShhAxe",
    [31721] = "SVtrident",
    [31722] = "SLessence",
    [29906] = "VashVial",
    [29905] = "KaelVial",
    [31307] = "HeartFury",
    [32459] = "Timephylactery",
    -- classic
    [21229] = "Insignia",
    [21230] = "Artifact",
    [23055] = "Thawing",
    [22708] = "Ramaladni",    
  },
}
if bepgp._cata then
  bepgp.VARS.maxilvl = 416
  bepgp.VARS.minlevel = 85
  bepgp.VARS.pricesystem = "BastionEPGP_CC-1.0"
  bepgp.VARS.progress = "T11"
  bepgp.VARS.crystalfirestone = 71617
  autoloot = {
    [40752] = "BadgeHero",
    [101] = "currency",
    [40753] = "BadgeValor",
    [102] = "currency",
    [45624] = "BadgeConquest",
    [221] = "currency",
    [47241] = "BadgeTriumph",
    [301] = "currency",
    [49426] = "BadgeFrost",
    [341] = "currency",
    [241] = "currency",
    [2589] = "currency", -- sidereal essence
    [2711] = "currency", -- defiler's scourgestone
    [22484] = "Necrotic",
    [43494] = "Watcher",
    [43670] = "Tiki",
    [43697] = "Nathrezim",
    [43726] = "Crown",
    [43693] = "Mojo",
    [43668] = "Tuner",
    [43665] = "Heart",
    [43669] = "Locket",
    [43823] = "Cyanigosa",
    [43724] = "CelestialRuby",
    [43699] = "FleshDisc",
    [43821] = "Withered",
    [43662] = "PlundererAxe",
    [48418] = "SoulFragment",
    [202269] = "BountyAlpha",
    [208157] = "BountyBeta",
    [211206] = "DefilerMedallion",
    [211207] = "MysteriousArtifact",
    --[0] = "BountyGamma", -- unknown yet
    [45788] = "FreyaSigil",
    [45786] = "HodirSigil",
    [45787] = "MimironSigil",
    [45784] = "ThorimSigil",
    [45814] = "FreyaSigilH",
    [45815] = "HodirSigilH",
    [45816] = "MimironSigilH",
    [45817] = "ThorimSigilH",
    [51026] = "Sindragosa1",
    [51027] = "Sindragosa2",
    [52006] = "FrostySack",
    [52676] = "LeyCache",
    -- bcc
    [29434] = "Badge",
    [42] = "currency",
    [28558] = "SpiritShard",
    [29425] = "MarkKJ",
    [30809] = "MarkSG",
    [29426] = "SignetFW",
    [30810] = "SignetSF",
    [24368] = "Coilfang",
    [25433] = "Warbead",
    [29209] = "Zaxxis",
    [25463] = "IvoryTusk",
    [26042] = "OshuPowder",
    [32569] = "ApexisShard",
    [32572] = "ApexisCrystal",
    [32388] = "ShadowDust",
    [32620] = "TimeLostScroll",
    [30436] = "MechBlue",
    [30437] = "MechRed",
    [24514] = "Karafrag1",
    [24487] = "Karafrag2",
    [24488] = "Karafrag3",
    [31239] = "Shhkeymold",
    [31750] = "Gruulsignet",
    [23933] = "Medivjournal",
    [25461] = "Sythbook",
    [25462] = "KurseTome",
    [31751] = "NightBsignet",
    [31716] = "ShhAxe",
    [31721] = "SVtrident",
    [31722] = "SLessence",
    [29906] = "VashVial",
    [29905] = "KaelVial",
    [31307] = "HeartFury",
    [32459] = "Timephylactery",
    -- classic
    [21229] = "Insignia",
    [21230] = "Artifact",
    [23055] = "Thawing",
    [22708] = "Ramaladni",
  }
end
if bepgp._wrath then
  bepgp.VARS.maxilvl = 284
  bepgp.VARS.minlevel = 80
  bepgp.VARS.pricesystem = "BastionEPGP_LK-1.0"
  bepgp.VARS.progress = "T7"
  bepgp.VARS.autoloot = {
    [40752] = "BadgeHero",
    [101] = "currency",
    [40753] = "BadgeValor",
    [102] = "currency",
    [45624] = "BadgeConquest",
    [221] = "currency",
    [47241] = "BadgeTriumph",
    [301] = "currency",
    [49426] = "BadgeFrost",
    [341] = "currency",
    [241] = "currency",
    [2589] = "currency", -- sidereal essence
    [2711] = "currency", -- defiler's scourgestone
    [22484] = "Necrotic",
    [43494] = "Watcher",
    [43670] = "Tiki",
    [43697] = "Nathrezim",
    [43726] = "Crown",
    [43693] = "Mojo",
    [43668] = "Tuner",
    [43665] = "Heart",
    [43669] = "Locket",
    [43823] = "Cyanigosa",
    [43724] = "CelestialRuby",
    [43699] = "FleshDisc",
    [43821] = "Withered",
    [43662] = "PlundererAxe",
    [48418] = "SoulFragment",
    [202269] = "BountyAlpha",
    [208157] = "BountyBeta",
    [211206] = "DefilerMedallion",
    [211207] = "MysteriousArtifact",
    --[0] = "BountyGamma", -- unknown yet
    [45788] = "FreyaSigil",
    [45786] = "HodirSigil",
    [45787] = "MimironSigil",
    [45784] = "ThorimSigil",
    [45814] = "FreyaSigilH",
    [45815] = "HodirSigilH",
    [45816] = "MimironSigilH",
    [45817] = "ThorimSigilH",
    [51026] = "Sindragosa1",
    [51027] = "Sindragosa2",
    [52006] = "FrostySack",
    [52676] = "LeyCache",
    -- bcc
    [29434] = "Badge",
    [42] = "currency",
    [28558] = "SpiritShard",
    [29425] = "MarkKJ",
    [30809] = "MarkSG",
    [29426] = "SignetFW",
    [30810] = "SignetSF",
    [24368] = "Coilfang",
    [25433] = "Warbead",
    [29209] = "Zaxxis",
    [25463] = "IvoryTusk",
    [26042] = "OshuPowder",
    [32569] = "ApexisShard",
    [32572] = "ApexisCrystal",
    [32388] = "ShadowDust",
    [32620] = "TimeLostScroll",
    [30436] = "MechBlue",
    [30437] = "MechRed",
    [24514] = "Karafrag1",
    [24487] = "Karafrag2",
    [24488] = "Karafrag3",
    [31239] = "Shhkeymold",
    [31750] = "Gruulsignet",
    [23933] = "Medivjournal",
    [25461] = "Sythbook",
    [25462] = "KurseTome",
    [31751] = "NightBsignet",
    [31716] = "ShhAxe",
    [31721] = "SVtrident",
    [31722] = "SLessence",
    [29906] = "VashVial",
    [29905] = "KaelVial",
    [31307] = "HeartFury",
    [32459] = "Timephylactery",
    -- classic
    [21229] = "Insignia",
    [21230] = "Artifact",
    [23055] = "Thawing",
    [22708] = "Ramaladni",
  }
end
if bepgp._bcc then
  bepgp.VARS.minlevel = 68
  bepgp.VARS.progress = "T4"
  bepgp.VARS.pricesystem = "BastionEPGPFixed_bc-1.0"
  bepgp.VARS.autoloot = {
    [29434] = "Badge",
    [28558] = "SpiritShard",
    [29425] = "MarkKJ",
    [30809] = "MarkSG",
    [29426] = "SignetFW",
    [30810] = "SignetSF",
    [24368] = "Coilfang",
    [25433] = "Warbead",
    [29209] = "Zaxxis",
    [25463] = "IvoryTusk",
    [26042] = "OshuPowder",
    [32569] = "ApexisShard",
    [32572] = "ApexisCrystal",
    [32388] = "ShadowDust",
    [32620] = "TimeLostScroll",
    [30436] = "MechBlue",
    [30437] = "MechRed",
    [24514] = "Karafrag1",
    [24487] = "Karafrag2",
    [24488] = "Karafrag3",
    [31239] = "Shhkeymold",
    [31750] = "Gruulsignet",
    [23933] = "Medivjournal",
    [25461] = "Sythbook",
    [25462] = "KurseTome",
    [31751] = "NightBsignet",
    [31716] = "ShhAxe",
    [31721] = "SVtrident",
    [31722] = "SLessence",
    [29906] = "VashVial",
    [29905] = "KaelVial",
    [31307] = "HeartFury",
    [32459] = "Timephylactery",
    -- classic
    [21229] = "Insignia",
    [21230] = "Artifact",
    [23055] = "Thawing",
    [22708] = "Ramaladni",
  }
end
if bepgp._classic then
  bepgp.VARS.minlevel = 55
  bepgp.VARS.prefix = "BEPGP_PREFIX"
  bepgp.VARS.pricesystem = "BastionEPGPFixed-1.1"
  bepgp.VARS.progress = "T1"
  bepgp.VARS.autoloot = {
    [21229] = "Insignia",
    [21230] = "Artifact",
    [23055] = "Thawing",
    [22708] = "Ramaladni",
  }
end
bepgp._playerName = UnitNameUnmodified("player")--GetUnitName("player")
bepgp._playerFullName = bepgp._playerName

local raidStatus,lastRaidStatus
local lastUpdate = 0
local running_check
local partyUnit,raidUnit = {},{}
local hexClassColor, classToEnClass, classToClassID, classidToClass = {}, {}, {}, {}
local hexColorQuality = {}
local price_systems = {}
local special_frames = {}
local pendingLoot, pendingLooters = {}, {}
local label = string.format("|cff33ff99%s|r",addonName)
local out_chat = string.format("%s: %%s",addonName)
local icons = {
  epgp = "Interface\\PetitionFrame\\GuildCharter-Icon",
  plusroll = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
  suspend = "Interface\\Buttons\\UI-GroupLoot-Pass-Down",
}
local modes = {
  epgp = L["EPGP"],
  plusroll = L["PlusRoll"],
  suspend = C:Red(L["Suspend"])
}
local item_swaps = {}
local whitelist = {}
local switch_icon = "|TInterface\\Buttons\\UI-OptionsButton:16|t"..L["Switch Mode"]
local stop_icon = "|TInterface\\Buttons\\UI-GroupLoot-Pass-Down:16|t"..L["Suspend"]
local resume_icon = "|TInterface\\Buttons\\UI-CheckBox-Check:16|t"..L["Resume"]
local lootareq_icon = "|TInterface\\GROUPFRAME\\UI-Group-MasterLooter:16|t"..L["Get Loot Admin"]
local sizereq_icon = "|TInterface\\Buttons\\UI-RefreshButton:16|t"..L["Change Raid Size"]
local diffreq_icon = "|TInterface\\PVPFrame\\Icon-Combat:16|t"..L["Change Raid Difficulty"]
local exportrost_icon = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:16|t"..L["Export Raid Roster"]
local prveto_icon =  "|TInterface\\ICONS\\Spell_ChargePositive:16|t"..L["|cffFFF0A7Use PR|r"]
local msbid_icon =  "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:16|t"..L["|cff4DA6FFMainspec|r"]
local osbid_icon =  "|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:16|t"..L["|cffB6FFA7Offspec|r"]
local xbid_icon = "|TInterface\\GossipFrame\\transmogrifyGossipIcon:16|t"..L["|cffD2B48CTransmog|r"] -- CURSOR\\Transmogrify
do
  for i=1,MAX_RAID_MEMBERS do
    raidUnit[i] = "raid"..i
  end
  for i=1,MAX_PARTY_MEMBERS do
    partyUnit[i] = "party"..i
  end
end
do
  for i=0,5 do
    hexColorQuality[ITEM_QUALITY_COLORS[i].hex] = i
  end
end
do
  for eClass, class in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    hexClassColor[class] = RAID_CLASS_COLORS[eClass].colorStr:gsub("^(ff)","")
    classToEnClass[class] = eClass
  end
  for eClass, class in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    hexClassColor[class] = RAID_CLASS_COLORS[eClass].colorStr:gsub("^(ff)","")
  end
end
do
  for id = 1, GetNumClasses() do
    local lClass, eClass, classId = GetClassInfo(id)
    if classId then
      classToClassID[eClass] = classId
      classidToClass[classId] = eClass
    end
  end
end
do
  local star,star_off = CreateAtlasMarkup("tradeskills-star"),CreateAtlasMarkup("tradeskills-star-off")
  bepgp._favmap = {
    [-1]=string.format("%s",CreateAtlasMarkup("bags-newitem")),
    [-2]=string.format("%s",CreateAtlasMarkup("bags-icon-equipment")),
    [1]=string.format("%s%s%s%s%s",star,star_off,star_off,star_off,star_off),
    [2]=string.format("%s%s%s%s%s",star,star,star_off,star_off,star_off),
    [3]=string.format("%s%s%s%s%s",star,star,star,star_off,star_off),
    [4]=string.format("%s%s%s%s%s",star,star,star,star,star_off),
    [5]=string.format("%s%s%s%s%s",star,star,star,star,star),
  }
end
do
  bepgp._specmap = {
    DEATHKNIGHT = {
      --Icon = CreateAtlasMarkup("classicon-deathknight"),
      Icon = CreateAtlasMarkup("GarrMission_ClassIcon-DeathKnight"),
      Blood = CreateAtlasMarkup("GarrMission_ClassIcon-DeathKnight-Blood"),
      Frost = CreateAtlasMarkup("GarrMission_ClassIcon-DeathKnight-Frost"),
      Unholy = CreateAtlasMarkup("GarrMission_ClassIcon-DeathKnight-Unholy"),
    },
    DRUID = {
      Icon = CreateAtlasMarkup("classicon-druid"),
      Balance = CreateAtlasMarkup("GarrMission_ClassIcon-Druid-Balance"),
      FeralCombat = CreateAtlasMarkup("GarrMission_ClassIcon-Druid-Feral"),
      FeralTank = CreateAtlasMarkup("GarrMission_ClassIcon-Druid-Guardian"),
      Restoration = CreateAtlasMarkup("GarrMission_ClassIcon-Druid-Restoration")
    },
    HUNTER = {
      Icon = CreateAtlasMarkup("classicon-hunter"),
      BeastMastery = CreateAtlasMarkup("GarrMission_ClassIcon-Hunter-BeastMastery"),
      Marksmanship = CreateAtlasMarkup("GarrMission_ClassIcon-Hunter-Marksmanship"),
      Survival = CreateAtlasMarkup("GarrMission_ClassIcon-Hunter-Survival")
    },
    MAGE = {
      Icon = CreateAtlasMarkup("classicon-mage"),
      Arcane = CreateAtlasMarkup("GarrMission_ClassIcon-Mage-Arcane"),
      Fire = CreateAtlasMarkup("GarrMission_ClassIcon-Mage-Fire"),
      Frost = CreateAtlasMarkup("GarrMission_ClassIcon-Mage-Frost")
    },
    MONK = {
      Icon = CreateAtlasMarkup("classicon-monk"),
      Brewmaster = CreateAtlasMarkup("GarrMission_ClassIcon-Monk-Brewmaster"),
      Mistweaver = CreateAtlasMarkup("GarrMission_ClassIcon-Monk-Mistweaver"),
      Windwalker = CreateAtlasMarkup("GarrMission_ClassIcon-Monk-Windwalker"),
    },
    PALADIN = {
      Icon = CreateAtlasMarkup("classicon-paladin"),
      Holy = CreateAtlasMarkup("GarrMission_ClassIcon-Paladin-Holy"),
      Protection = CreateAtlasMarkup("GarrMission_ClassIcon-Paladin-Protection"),
      Retribution = CreateAtlasMarkup("GarrMission_ClassIcon-Paladin-Retribution")
    },
    PRIEST = {
      Icon = CreateAtlasMarkup("classicon-priest"),
      Discipline = CreateAtlasMarkup("GarrMission_ClassIcon-Priest-Discipline"),
      Holy = CreateAtlasMarkup("GarrMission_ClassIcon-Priest-Holy"),
      Shadow = CreateAtlasMarkup("GarrMission_ClassIcon-Priest-Shadow")
    },
    ROGUE = {
      Icon = CreateAtlasMarkup("classicon-rogue"),
      Assasination = CreateAtlasMarkup("GarrMission_ClassIcon-Rogue-Assassination"),
      Combat = CreateAtlasMarkup("GarrMission_ClassIcon-Rogue-Outlaw"),
      Subtlety = CreateAtlasMarkup("GarrMission_ClassIcon-Rogue-Subtlety")
    },
    SHAMAN = {
      Icon = CreateAtlasMarkup("classicon-shaman"),
      Elemental = CreateAtlasMarkup("GarrMission_ClassIcon-Shaman-Elemental"),
      Enhancement = CreateAtlasMarkup("GarrMission_ClassIcon-Shaman-Enhancement"),
      Restoration = CreateAtlasMarkup("GarrMission_ClassIcon-Shaman-Restoration")
    },
    WARLOCK = {
      Icon = CreateAtlasMarkup("classicon-warlock"),
      Affliction = CreateAtlasMarkup("GarrMission_ClassIcon-Warlock-Affliction"),
      Demonology = CreateAtlasMarkup("GarrMission_ClassIcon-Warlock-Demonology"),
      Destruction = CreateAtlasMarkup("GarrMission_ClassIcon-Warlock-Destruction")
    },
    WARRIOR = {
      Icon = CreateAtlasMarkup("classicon-warrior"),
      Arms = CreateAtlasMarkup("GarrMission_ClassIcon-Warrior-Arms"),
      Fury = CreateAtlasMarkup("GarrMission_ClassIcon-Warrior-Fury"),
      Protection = CreateAtlasMarkup("GarrMission_ClassIcon-Warrior-Protection")
    }
  }
end
do
  bepgp._progsets = {
    _mists = {
      progress_values = {
        ["T16"]  = L["3.Siege of Org"],
        ["T15"]  = L["2.Throne of Thunder"],
        ["T14"]  = L["1.MV, ToES, HoF"],
      },
      progress_sorting = {"T16", "T15", "T14"},
      progressmap = {
        ["T16.5"] = {"T16.5","T16","T15.5"},
        ["T16"]   = {"T16.5","T16"},
        ["T15.5"] = {"T15.5","T15","T14.5"},
        ["T15"]   = {"T15.5", "T15"},
        ["T14.5"] = {"T14.5","T14"},
        ["T14"]   = {"T14.5","T14"},
      },
      tierlist = {["T16.5"]="560+",["T16"]="540-559",["T15.5"]="529-539",["T15"]="510-528",["T14.5"]="497-509",["T14"]="476-496"},
      tiersort = {"T16.5","T16","T15.5","T15","T14.5","T14"},
      modlist = {["T16"]="T16",["T15"]="T15",["T14"]="T14"},
      modsort = {"T16","T15","T14"},
      bench_values = {["T16"]=L["3.Siege of Org"], ["T15"]=L["2.Throne of Thunder"], ["T14"]=L["1.MV, ToES, HoF"]},
      bench_sorting = {"T14", "T15", "T16"},
      raidLimits = {
        ["T14"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 6,},
        ["T15"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 6,},
        ["T16"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 6,},
      },
    },
    _cata = {
      progress_values = {
        ["T13"]  = L["3.Deathwing"],
        ["T12"]  = L["2.Firelands"],
        ["T11"]  = L["1.BD, BoT, TfW"],
      },
      progress_sorting = {"T13", "T12", "T11"},
      progressmap = {
        ["T13.5"] = {"T13.5","T13","T12.5"},
        ["T13"]   = {"T13.5","T13"},
        ["T12.5"] = {"T12.5","T12","T11.5"},
        ["T12"]   = {"T12.5", "T12"},
        ["T11.5"] = {"T11.5","T11"},
        ["T11"]   = {"T11.5","T11"},
      },
      tierlist = {["T13.5"]="410+",["T13"]="397-403",["T12.5"]="391",["T12"]="378-390",["T11.5"]="372-379",["T11"]="359-371"},
      tiersort = {"T13.5","T13","T12.5","T12","T11.5","T11"},
      modlist = {["T13"]="T13",["T12"]="T12",["T11"]="T11"},
      modsort = {"T13","T12","T11"},
      bench_values = {["T13"]=L["3.Deathwing"], ["T12"]=L["2.Firelands"], ["T11"]=L["1.BD, BoT, TfW"]},
      bench_sorting = {"T11", "T12", "T13"},
      raidLimits = {
        ["T11"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 5,},
        ["T12"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 5,},
        ["T13"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 6,},
      },
    },
    _wrath = {
      progress_values = {
        ["T10.5"]=L["5.RS"],
        ["T10"]  =L["4.ICC, VoA-T"],
        ["T9"]   =L["3.ToCR/Ony, VoA-K"],
        ["T8"]   =L["2.Ulduar, VoA-E"],
        ["T7"]   =L["1.Naxx/OS/EoE, VoA-A"]
      },
      progress_sorting = {"T10.5", "T10", "T9", "T8", "T7"},
      progressmap = {
        ["T10.5"] = {"T10.5", "T10","T9.5"},
        ["T10"]   = {"T10.5", "T10","T9.5"},
        ["T9.5"]  = {"T10", "T9.5", "T9"},
        ["T9"]    = {"T10", "T9.5", "T9"},
        ["T8.5"]  = {"T9", "T8.5", "T8"},
        ["T8"]    = {"T9", "T8.5", "T8"},
        ["T7.5"]  = {"T8", "T7.5", "T7"},
        ["T7"]    = {"T8", "T7.5", "T7"},
      },
      tierlist = {["T10.5"]="270+",["T10"]="260-269",["T9.5"]="250-259",["T9"]="240-249",["T8.5"]="230-239",["T8"]="220-229",["T7.5"]="210-219",["T7"]="200-209"},
      tiersort = {"T10.5","T10","T9.5","T9","T8.5","T8","T7.5","T7"},
      modlist = {["T10.5"]="T10.5",["T10"]="T10",["T9"]="T9",["T8"]="T8",["T7"]="T7"},
      modsort = {"T10.5","T10","T9","T8","T7"},
      bench_values = {["T10.5"]=L["5.RS"], ["T10"]=L["4.ICC, VoA-T"], ["T9"]=L["3.ToCR/Ony, VoA-K"], ["T8"]=L["2.Ulduar, VoA-E"], ["T7"]=L["1.Naxx/OS/EoE, VoA-A"]},
      bench_sorting = {"T7", "T8", "T9", "T10", "T10.5"},
      raidLimits = {
        ["T7"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 5,},
        ["T8"] = {total = 25,[_G.TANK] = 2,[_G.HEALER] = 5,},
        ["T9"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 5,},
        ["T10"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 5,},
        ["T10.5"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 6,},
      },
    },
    _bcc = {
      progress_values = {
        ["T6.5"]=L["4.Sunwell Plateau"],
        ["T6"]=L["3.Black Temple, Hyjal"],
        ["T5"]=L["2.Serpentshrine Cavern, The Eye"],
        ["T4"]=L["1.Karazhan, Magtheridon, Gruul, World Bosses"]
      },
      progress_sorting = {"T6.5", "T6", "T5", "T4"},
      progressmap = {
        ["T6.5"] = {"T6.5","T6","T5","T4"},
        ["T6"] = {"T6", "T5", "T4"},
        ["T5"] = {"T5", "T4"},
        ["T4"] = {"T4"}
      },
      tierlist = {["T6.5"]="T6.5",["T6"]="T6",["T5"]="T5",["T4"]="T4"},
      tiersort = {"T6.5","T6","T5","T4"},
      modlist = {["T6.5"]="T6.5",["T6"]="T6",["T5"]="T5",["T4"]="T4"},
      modsort = {"T6.5","T6","T5","T4"},
      bench_values = { ["T6.5"]=L["4.Sunwell Plateau"], ["T6"]=L["3.Black Temple, Hyjal"], ["T5"]=L["2.Serpentshrine Cavern, The Eye"], ["T4"]=L["1.Karazhan, Magtheridon, Gruul, World Bosses"]},
      bench_sorting = {"T4", "T5", "T6", "T6.5"},
      raidLimits = {
        ["T4"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 6,},
        ["T5"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 7,},
        ["T6"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 7,},
        ["T6.5"] = {total = 25,[_G.TANK] = 3,[_G.HEALER] = 8,},
      },
    },
    _classic = {
      progress_values = {
        ["T3"]=L["4.Naxxramas"],
        ["T2.5"]=L["3.Temple of Ahn\'Qiraj"],
        ["T2"]=L["2.Blackwing Lair"],
        ["T1"]=L["1.Molten Core"]
      },
      progress_sorting = {"T3", "T2.5", "T2", "T1"},
      progressmap = {
        ["T3"] = {"T3","T2.5","T2","T1.5","T1"},
        ["T2.5"] = {"T2.5","T2","T1.5","T1"},
        ["T2"] = {"T2","T1.5","T1"},
        ["T1"] = {"T1.5","T1"},
      },
      tierlist = {["T3"]="T3",["T2.5"]="T2.5",["T2"]="T2",["T1.5"]="T1.5",["T1"]="T1"}, 
      tiersort = {"T3","T2.5","T2","T1.5","T1"},
      modlist = {["T3"]="T3",["T2.5"]="T2.5",["T2"]="T2",["T1"]="T1"}, 
      modsort = {"T3","T2.5","T2","T1"},
      bench_values = { ["T3"]=L["4.Naxxramas"], ["T2.5"]=L["3.Temple of Ahn\'Qiraj"], ["T2"]=L["2.Blackwing Lair"], ["T1"]=L["1.Molten Core"]},
      bench_sorting = {"T1", "T2", "T2.5", "T3"},
      raidLimits = {
        ["T1"] = {total = 40,[_G.TANK] = 3,[_G.HEALER] = 10,},
        ["T2"] = {total = 40,[_G.TANK] = 4,[_G.HEALER] = 12,},
        ["T2.5"] = {total = 40,[_G.TANK] = 5,[_G.HEALER] = 14,},
        ["T3"] = {total = 40,[_G.TANK] = 6,[_G.HEALER] = 15,},
      },
    },
  }
end  
local item_bind_patterns = {
  CRAFT = "("..USE_COLON..")",
  BOP = "("..ITEM_BIND_ON_PICKUP..")",
  QUEST = "("..ITEM_BIND_QUEST..")",
  BOU = "("..ITEM_BIND_ON_EQUIP..")",
  BOE = "("..ITEM_BIND_ON_USE..")",
  BOUND = "("..ITEM_SOULBOUND..")"
}
local object_names = {
  [181366] = L["Four Horsemen Chest"],
  [193426] = L["Four Horsemen Chest"],
  [193905] = L["Alexstrasza's Gift"],
  [193967] = L["Alexstrasza's Gift"],
  [194158] = L["Heart of Magic"],
  [194159] = L["Heart of Magic"],
  [194324] = L["Freya's Gift"],
  [194325] = L["Freya's Gift"],
  [194326] = L["Freya's Gift"],
  [194327] = L["Freya's Gift"],
  [194328] = L["Freya's Gift"],
  [194329] = L["Freya's Gift"],
  [194330] = L["Freya's Gift"],
  [194331] = L["Freya's Gift"],
  [279654] = L["Freya's Gift"],
  [281376] = L["Freya's Gift"],
  [281377] = L["Freya's Gift"],
  [194789] = L["Cache of Innovation"],
  [194956] = L["Cache of Innovation"],
  [194957] = L["Cache of Innovation"],
  [194958] = L["Cache of Innovation"],
  [279655] = L["Cache of Innovation"],
  [281370] = L["Cache of Innovation"],
  [194312] = L["Cache of Storms"],
  [194313] = L["Cache of Storms"],
  [194314] = L["Cache of Storms"],
  [194315] = L["Cache of Storms"],
  [218997] = L["Cache of Storms"],
  [218998] = L["Cache of Storms"],
  [279656] = L["Cache of Storms"],
  [281368] = L["Cache of Storms"],
  [281369] = L["Cache of Storms"],
  [194307] = L["Cache of Winter"],
  [194308] = L["Cache of Winter"],
  [281374] = L["Cache of Winter"],
  [194200] = L["Rare Cache of Winter"],
  [194201] = L["Rare Cache of Winter"],
  [281373] = L["Rare Cache of Winter"],
  [195046] = L["Cache of Living Stone"],
  [195047] = L["Cache of Living Stone"],
  [281372] = L["Cache of Living Stone"],
  [194821] = L["Gift of the Observer"],
  [194822] = L["Gift of the Observer"],
  [195631] = L["Champions' Cache"],
  [195632] = L["Champions' Cache"],
  [195633] = L["Champions' Cache"],
  [195635] = L["Champions' Cache"],
  [195665] = L["Argent Crusade Tribute Chest"],
  [195666] = L["Argent Crusade Tribute Chest"],
  [195667] = L["Argent Crusade Tribute Chest"],
  [195668] = L["Argent Crusade Tribute Chest"],
  [195669] = L["Argent Crusade Tribute Chest"],
  [195670] = L["Argent Crusade Tribute Chest"],
  [195671] = L["Argent Crusade Tribute Chest"],
  [195672] = L["Argent Crusade Tribute Chest"],
  [201872] = L["Gunship Armory"],
  [201873] = L["Gunship Armory"],
  [201874] = L["Gunship Armory"],
  [201875] = L["Gunship Armory"],
  [202177] = L["Gunship Armory"],
  [202178] = L["Gunship Armory"],
  [202179] = L["Gunship Armory"],
  [202180] = L["Gunship Armory"],
  [202238] = L["Deathbringer's Cache"],
  [202239] = L["Deathbringer's Cache"],
  [202240] = L["Deathbringer's Cache"],
  [202241] = L["Deathbringer's Cache"],
  [201959] = L["Cache of the Dreamwalker"],
  [202338] = L["Cache of the Dreamwalker"],
  [202339] = L["Cache of the Dreamwalker"],
  [202340] = L["Cache of the Dreamwalker"],
  [179703] = L["Cache of the Firelord"],
  [180691] = L["Scarab Coffer"],
  [180690] = L["Large Scarab Coffer"],
  [180228] = L["Jinxed Hoodoo Pile"],
  [180229] = L["Jinxed Hoodoo Pile"],
  [185119] = L["Dust Covered Chest"],
  [187021] = L["Harkor's Satchel"],
  [186648] = L["Tanzar's Trunk"],
  [186667] = L["Kraz's Package"],
  [186672] = L["Ashli's Bag"],
  [208044] = L["Cache of the Broodmother"],
  [208045] = L["Cache of the Broodmother"],
  [207891] = L["Heart of Wind"],
  [207892] = L["Heart of Wind"],
  [207893] = L["Heart of Wind"],
  [207894] = L["Heart of Wind"],
  [208967] = L["Cache of the Fire Lord"],
  [209261] = L["Cache of the Fire Lord"],
  [210079] = L["Elementium Fragment"],
  [210217] = L["Elementium Fragment"],
  [210218] = L["Elementium Fragment"],
  [210219] = L["Elementium Fragment"],
  [210220] = L["Elementium Fragment"],
  [210160] = L["Lesser Cache of the Aspects"],
  [210161] = L["Lesser Cache of the Aspects"],
  [210162] = L["Lesser Cache of the Aspects"],
  [210163] = L["Lesser Cache of the Aspects"],
  [210221] = L["Lesser Cache of the Aspects"],
  [209894] = L["Greater Cache of the Aspects"],
  [209895] = L["Greater Cache of the Aspects"],
  [209896] = L["Greater Cache of the Aspects"],
  [209897] = L["Greater Cache of the Aspects"],
  [210222] = L["Greater Cache of the Aspects"],
  [214383] = L["Cache of Pure Energy"],
  [214384] = L["Cache of Pure Energy"],
  [214385] = L["Cache of Pure Energy"],
  [214386] = L["Cache of Pure Energy"],
  [214387] = L["Cache of Pure Energy"],
  [212922] = L["Cache of Tsulong"],
  [215355] = L["Cache of Tsulong"],
  [215356] = L["Cache of Tsulong"],
  [215357] = L["Cache of Tsulong"],
  [215358] = L["Cache of Tsulong"],
  [297837] = L["Cache of Ancient Treasures"],
  [218805] = L["Cache of Ancient Treasures"],
  [218806] = L["Cache of Ancient Treasures"],
  [218807] = L["Cache of Ancient Treasures"],
  [218808] = L["Cache of Ancient Treasures"],
  [218997] = L["Cache of Storms"],
  [218998] = L["Cache of Storms"],
  [221776] = L["Tears of the Vale"],
  [223236] = L["Tears of the Vale"],
  [223237] = L["Tears of the Vale"],
  [223238] = L["Tears of the Vale"],
  [232092] = L["Tears of the Vale"],
  [232093] = L["Tears of the Vale"],
  [233028] = L["Tears of the Vale"],
  [222749] = L["Unlocked Stockpile of Pandaren Spoils"],
  [222750] = L["Unlocked Stockpile of Pandaren Spoils"],
  [222751] = L["Unlocked Stockpile of Pandaren Spoils"],
  [222752] = L["Unlocked Stockpile of Pandaren Spoils"],
  [232165] = L["Unlocked Stockpile of Pandaren Spoils"],
  [232166] = L["Unlocked Stockpile of Pandaren Spoils"],
  [233030] = L["Unlocked Stockpile of Pandaren Spoils"],
  [221739] = L["Vault of Forbidden Treasures"],
  [221740] = L["Vault of Forbidden Treasures"],
  [221741] = L["Vault of Forbidden Treasures"],
  [221742] = L["Vault of Forbidden Treasures"],
  [232163] = L["Vault of Forbidden Treasures"],
  [232164] = L["Vault of Forbidden Treasures"],
  [233029] = L["Vault of Forbidden Treasures"],
  [179564] = L["Gordok Tribute"], -- DEBUG
}
local class_to_firestoneitems = {
  DEATHKNIGHT = { 69109, 69113, 71562, 71563, 71564, 71587, 71590 },
  DRUID = { 71557, 71559, 71560, 71567, 71577, 71580 },
  HUNTER = { 71557, 71558, 71561 },
  MAGE = { 71559, 71560, 71575, 71579 },
  PALADIN = { 69109, 69113, 71562, 71563, 71564, 71577, 71580, 71587, 71590 },
  PRIEST = { 71559, 71560, 71575, 71579 },
  ROGUE = { 71558, 71568, 71641 },
  SHAMAN = { 71559, 71560, 71561, 71577, 71580 },
  WARLOCK = { 71559, 71560, 71575, 71579 },
  WARRIOR = { 69109, 69113, 71562, 71563, 71564, 71592, 71593 },
  UNKNOWN = { 69109, 69113, 71557, 71558, 71559, 71560, 71561, 71562, 71563, 71564, 71567, 71568, 71575, 71577, 71579, 71580, 71587, 71590, 71592, 71593, 71641 },
}
local defaults = {
  profile = {
    announce = "GUILD",
    decay = bepgp.VARS.decay,
    minep = bepgp.VARS.minep,
    system = bepgp.VARS.pricesystem,
    progress = bepgp.VARS.progress,
    fullnames = false,
    discount = 0.1,
    altspool = false,
    allypool = true,
    standinrank = bepgp.VARS.standinrank,
    altpercent = 1.0,
    main = false,
    minimap = {
      hide = false,
    },
    guildcache = {},
    alts = {},
    allies = {},
    patches = {},
  },
  char = {
    raidonly = false,
    tooltip = {
      prinfo = true,
      mlinfo = true,
      favinfo = true,
      useinfo = false,
      tkninfo = true,
    },
    classgroup = false,
    standby = false,
    bidpopup = true,
    mode = "epgp", -- "plusroll"
    priorank = bepgp.VARS.priorank,
    maxreserves = bepgp.VARS.maxreserves,
    minilvl = bepgp.VARS.minilvl,
    prveto = bepgp.VARS.prveto,
    rosterthrottle = bepgp.VARS.rosterthrottle,
    debugchat = 4, -- 1 is default, 2 is typically combatlog, 3 is typically voicetranscript
    priorank_ms = true,
    logs = {},
    loot = {},
    favorites = {},
    reserves = {
      locked=false,
      players={},
      items={}
    },
    wincount = {},
    plusroll_logs = {},
    wincountmanual = true,
    wincountignore = false,
    wincountepgp = false,
    xmogbid = false,
    wincounttoken = true,
    wincountstack = true,
    plusrollepgp = false,
    rollfilter = false,
    favalert = true,
    lootannounce = true,
    customlinks = true, -- MoP prepatch bug workaround
    groupcache = {},
    whitelist = {},
    patches = {},
  },
}
local admincmd, membercmd =
{type = "group", handler = bepgp, args = {
    bids = {
      type = "execute",
      name = L["Bids"],
      desc = L["Show Bids Table."],
      func = function()
        local bids = bepgp:GetModule(addonName.."_bids",true)
        if bids then
          bids:Toggle()
        end
      end,
      order = 1,
    },
    show = {
      type = "execute",
      name = L["Standings"],
      desc = L["Show Standings Table."],
      func = function()
        local standings = bepgp:GetModule(addonName.."_standings",true)
        if standings then
          standings:Toggle()
        end
      end,
      order = 2,
    },
    browser = {
      type = "execute",
      name = L["Favorites"],
      desc = L["Show Favorites Table."],
      func = function()
        local browser = bepgp:GetModule(addonName.."_browser",true)
        if browser then
          browser:Toggle()
        end
      end,
      order = 3,
    },
    clearloot = {
      type = "execute",
      name = L["ClearLoot"],
      desc = L["Clear Loot Table."],
      func = function()
        local loot = bepgp:GetModule(addonName.."_loot",true)
        if loot then
          loot:Clear()
        end
      end,
      order = 4,
    },
    clearlogs = {
      type = "execute",
      name = L["ClearLogs"],
      desc = L["Clear Logs Table."],
      func = function()
        local logs = bepgp:GetModule(addonName.."_logs",true)
        if logs then
          logs:Clear()
        end
      end,
      order = 5,
    },
    progress = {
      type = "execute",
      name = L["Progress"],
      desc = L["Print Progress Multiplier."],
      func = function()
        bepgp:Print(bepgp.db.profile.progress)
      end,
      order = 6,
    },
    offspec = {
      type = "execute",
      name = L["Offspec"],
      desc = L["Print Offspec Price."],
      func = function()
        bepgp:Print(string.format("%s%%",bepgp.db.profile.discount*100))
      end,
      order = 7,
    },
    mode = {
      type = "select",
      name = L["Mode of Operation"],
      desc = L["Select mode of operation."],
      get = function()
        return bepgp.db.char.mode
      end,
      set = function(info, val)
        bepgp.db.char.mode = val
        bepgp:SetMode(bepgp.db.char.mode)
      end,
      values = { ["epgp"]=L["EPGP"], ["plusroll"]=L["PlusRoll"]},
      sorting = {"epgp", "plusroll"},
      order = 8,
    },
    admin = {
      type = "execute",
      name = L["Get Loot Admin"],
      desc = L["Send Request for Loot Admin to Raid Leader"],
      func = "RequestLootAdmin",
      order = 9,
    },
    options = {
      type = "execute",
      name = _G.OPTIONS,
      desc = L["Admin Options"],
      func = "toggleOptions",
      order = 10,
    },
    restart = {
      type = "execute",
      name = L["Restart"],
      desc = L["Restart BastionLoot if having startup problems."],
      func = function()
        bepgp:OnEnable(true)
        bepgp:Print(L["Restarted"])
      end,
      order = 11,
    },
    stop = {
      type = "execute",
      name = L["Suspend"],
      desc = L["Suspend bid monitoring for this session.(does not persist relog)"],
      func = function()
        bepgp:Suspend()
      end,
      order = 12,
    },
  }},
{type = "group", handler = bepgp, args = {
    show = {
      type = "execute",
      name = L["Standings"],
      desc = L["Show Standings Table."],
      func = function()
        local standings = bepgp:GetModule(addonName.."_standings",true)
        if standings then
          standings:Toggle()
        end
      end,
      order = 1,
    },
    browser = {
      type = "execute",
      name = L["Favorites"],
      desc = L["Show Favorites Table."],
      func = function()
        local browser = bepgp:GetModule(addonName.."_browser",true)
        if browser then
          browser:Toggle()
        end
      end,
      order = 2,
    },
    progress = {
      type = "execute",
      name = L["Progress"],
      desc = L["Print Progress Multiplier."],
      func = function()
        bepgp:Print(bepgp.db.profile.progress)
      end,
      order = 3,
    },
    offspec = {
      type = "execute",
      name = L["Offspec"],
      desc = L["Print Offspec Price."],
      func = function()
        bepgp:Print(string.format("%s%%",bepgp.db.profile.discount*100))
      end,
      order = 4,
    },
    mode = {
      type = "select",
      name = L["Mode of Operation"],
      desc = L["Select mode of operation."],
      get = function()
        return bepgp.db.char.mode
      end,
      set = function(info, val)
        bepgp.db.char.mode = val
        bepgp:SetMode(bepgp.db.char.mode)
      end,
      values = { ["epgp"]=L["EPGP"], ["plusroll"]=L["PlusRoll"]},
      sorting = {"epgp", "plusroll"},
      order = 5,
    },
    options = {
      type = "execute",
      name = _G.OPTIONS,
      desc = L["Member Options"],
      func = "toggleOptions",
      order = 6
    },
    restart = {
      type = "execute",
      name = L["Restart"],
      desc = L["Restart BastionLoot if having startup problems."],
      func = function()
        bepgp:OnEnable(true)
        bepgp:Print(L["Restarted"])
      end,
      order = 7,
    },
    stop = {
      type = "execute",
      name = L["Suspend"],
      desc = L["Suspend bid monitoring for this session.(does not persist relog)"],
      func = function()
        bepgp:Suspend()
      end,
      order = 8,
    },
  }}
bepgp.cmdtable = function()
  if (bepgp:admin()) then
    return admincmd
  else
    return membercmd
  end
end

function bepgp:options(force)
  if not (self._options) or force then
    self._options = 
    {
      type = "group",
      handler = bepgp,
      args = {
        general = {
          type = "group",
          name = _G.OPTIONS,
          childGroups = "tab",
          args = {
            main = {
              type = "group",
              name = _G.GENERAL,
              order = 1,
              args = { },
            },
            alts = {
              type = "group",
              name = L["Alts"],
              order = 2,
              args = { },
              hidden = function()
                return not bepgp:admin()
              end,
            },
            allies = {
              type = "group",
              name = L["Allies"],
              order = 3,
              args = { },
              hidden = function()
                return not bepgp:admin()
              end,
            },
            ttip = {
              type = "group",
              name = L["Tooltip"],
              desc = L["Tooltip Additions"],
              order = 4,
              args = { },
            }
          }
        }
      }
    }
    self._options.args.general.args.ttip.args["prinfo"] = {
      type = "toggle",
      name = L["EPGP Info"],
      desc = L["Add EPGP Information to Item Tooltips"],
      order = 10,
      get = function() return not not bepgp.db.char.tooltip.prinfo end,
      set = function(info, val)
        bepgp.db.char.tooltip.prinfo = not bepgp.db.char.tooltip.prinfo
        bepgp:tooltipHook()
      end,
    }
    self._options.args.general.args.ttip.args["mlinfo"] = {
      type = "toggle",
      name = L["Masterlooter Hints"],
      desc = L["Show Masterlooter click action hints on item tooltips"],
      order = 11,
      get = function() return not not bepgp.db.char.tooltip.mlinfo end,
      set = function(info, val)
        bepgp.db.char.tooltip.mlinfo = not bepgp.db.char.tooltip.mlinfo
        bepgp:tooltipHook()
      end,
    }
    self._options.args.general.args.ttip.args["favinfo"] = {
      type = "toggle",
      name = L["Favorites Info"],
      desc = L["Show Favorite ranking on item tooltips"],
      order = 12,
      get = function() return not not bepgp.db.char.tooltip.favinfo end,
      set = function(info, val)
        bepgp.db.char.tooltip.favinfo = not bepgp.db.char.tooltip.favinfo
        bepgp:tooltipHook()
      end,
    }
    self._options.args.general.args.ttip.args["useinfo"] = {
      type = "toggle",
      name = L["Usable Info"],
      desc = L["Show Class and Spec Hints on item tooltips"],
      order = 13,
      get = function() return not not bepgp.db.char.tooltip.useinfo end,
      set = function(info, val)
        bepgp.db.char.tooltip.useinfo = not bepgp.db.char.tooltip.useinfo
        bepgp:tooltipHook()
      end,
    }
    self._options.args.general.args.ttip.args["tkninfo"] = {
      type = "toggle",
      name = L["Token Info"],
      desc = L["Show required trade-in Item on item tooltips"],
      order = 14,
      get = function() return not not bepgp.db.char.tooltip.tkninfo end,
      set = function(info, val)
        bepgp.db.char.tooltip.tkninfo = not bepgp.db.char.tooltip.tkninfo
        bepgp:tooltipHook()
      end,
    }
    self._options.args.general.args.main.args["set_main"] = {
      type = "input",
      name = L["Set Main"],
      desc = L["Set your Main Character for Standby List."],
      order = 70,
      usage = "Type your main name and press Enter",
      get = function() return bepgp.db.profile.main end,
      set = function(info, val)
        local name = (bepgp:verifyGuildMember(val))
        if name then
          bepgp.db.profile.main = name
        end
      end,
    }
    self._options.args.general.args.main.args["raid_only"] = {
      type = "toggle",
      name = L["Raid Only"],
      desc = L["Filter EPGP Standings to current raid members."],
      order = 80,
      get = function() return not not bepgp.db.char.raidonly end,
      set = function(info, val)
        bepgp.db.char.raidonly = not bepgp.db.char.raidonly
        local standings = bepgp:GetModule(addonName.."_standings",true)
        if standings then
          standings._widgetraid_only:SetValue(bepgp.db.char.raidonly)
        end
        bepgp:refreshPRTablets()
      end,
    }
    self._options.args.general.args.main.args["class_grouping"] = {
      type = "toggle",
      name = L["Group by class"],
      desc = L["Group EPGP Standings by class."],
      order = 81,
      get = function() return not not bepgp.db.char.classgroup end,
      set = function(info, val)
        bepgp.db.char.classgroup = not bepgp.db.char.classgroup
        local standings = bepgp:GetModule(addonName.."_standings",true)
        if standings then
          standings._widgetclass_grouping:SetValue(bepgp.db.char.classgroup)
        end
        bepgp:refreshPRTablets()
      end,
    }
    self._options.args.general.args.main.args["bid_popup"] = {
      type = "toggle",
      name = L["Bid Popup"],
      desc = L["Show a Popup for bidding on items in addition to the custom chat links"],
      order = 83,
      get = function() return not not bepgp.db.char.bidpopup end,
      set = function(info, val)
        bepgp.db.char.bidpopup = not bepgp.db.char.bidpopup
      end,
    }
    self._options.args.general.args.main.args["favalert"] = {
      type = "toggle",
      name = L["Favorite Alert"],
      desc = L["Alert when Favorited items show up in Bid Calls or the LootFrame"],
      order = 84,
      get = function() return not not bepgp.db.char.favalert end,
      set = function(info, val)
        bepgp.db.char.favalert = not bepgp.db.char.favalert
        if bepgp.db.char.favalert then
          bepgp:RegisterEvent("LOOT_OPENED", "lootAnnounce")
          bepgp:RegisterEvent("START_LOOT_ROLL", "favAlert")
        end
      end,
    }
    self._options.args.general.args.main.args["minimap"] = {
      type = "toggle",
      name = L["Hide from Minimap"],
      desc = L["Hide from Minimap"],
      order = 85,
      get = function() return bepgp.db.profile.minimap.hide end,
      set = function(info, val)
        bepgp.db.profile.minimap.hide = val
        if bepgp.db.profile.minimap.hide then
          LDI:Hide(addonName)
        else
          LDI:Show(addonName)
        end
      end
    }
    self._options.args.general.args.main.args["rollfilter"] = {
      type = "toggle",
      name = L["Hide Rolls"],
      desc = L["Hide other player rolls from the chatframe"],
      order = 86,
      get = function() return not not bepgp.db.char.rollfilter end,
      set = function(info, val)
        bepgp.db.char.rollfilter = not bepgp.db.char.rollfilter
      end,
      --hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["lootannounce"] = {
      type = "toggle",
      name = L["Announce Loot"],
      desc = L["Auto link loot to your Group when Masterlooter"],
      order = 87,
      get = function() return not not bepgp.db.char.lootannounce end,
      set = function(info, val)
        bepgp.db.char.lootannounce = not bepgp.db.char.lootannounce
        if bepgp.db.char.lootannounce then
          bepgp:RegisterEvent("LOOT_OPENED", "lootAnnounce")
        end
      end,
    }
    self._options.args.general.args.main.args["rosterthrottle"] = {
      type = "range",
      name = L["Delay Updates"],
      desc = L["Time in seconds between roster updates and initial roster scan.\nCan try higher values as a workaround for other addon compatibility issues (eg. Questie)"],
      order = 88,
      get = function() return bepgp.db.char.rosterthrottle end,
      set = function(info, val)
        local value = tonumber(val)
        if value <=0 then value = 1 end
        if value >60 then value = 60 end
        bepgp.db.char.rosterthrottle = value
      end,
      min = 0,
      max = 60,
      softMin = 5,
      softMax = 30,
      step = 5,
    }
    self._options.args.general.args.main.args["debugchat"] = {
      type = "select",
      name = L["Extra Messages"],
      desc = L["Select the Chatframe to print Extra Informational messages to."],
      order = 89,
      get = function() return bepgp.db.char.debugchat end,
      set = function(info, val)
        bepgp.db.char.debugchat = tonumber(val)
      end,
      values = function()
        local chatframes = {}
        for i=1,NUM_CHAT_WINDOWS do
          local name, fontsize, r, g, b, a, isShown, isLocked, isDocked = GetChatWindowInfo(i)
          local cf = _G["ChatFrame"..i]
          if (isShown or isDocked) and not IsBuiltinChatWindow(cf) then
            chatframes[i] = name
          end
        end
        EventUtil.ContinueOnAddOnLoaded("Chattynator",function()
          if Chattynator and Chattynator.API and Chattynator.API.GetWindowsAndTabs then
            wipe(chatframes)
            local windowtabs = Chattynator.API.GetWindowsAndTabs()
            local id
            bepgp._options.args.general.args.main.args["debugchat"].desc = L["Select the Chattynator tab to print Extra Informational messages to.\nBastionLoot must be whitelisted in Chattynator tab options."]
            for window,tabs in pairs(windowtabs) do
              id = window * 100
              for tab,tabName in pairs(tabs) do
                id = id + tab
                if not (window == 1 and tab == 1) then
                  chatframes[id] = _G[tabName] or tabName
                end
              end
            end
          end
        end)
        return chatframes
      end,
    }
    self._options.args.general.args.main.args["admin_options_header"] = {
      type = "header",
      name = L["Admin Options"],
      order = 91,
      hidden = function() return (not bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["progress_tier_header"] = {
      type = "header",
      name = string.format(L["Progress Setting: %s"],bepgp.db.profile.progress),
      order = 92,
      hidden = function() return bepgp:admin() end,
    }
    self._options.args.general.args.main.args["progress_tier"] = {
      type = "select",
      name = L["Raid Progress"],
      desc = L["Highest Tier the Guild is raiding.\nUsed to adjust GP Prices.\nUsed for suggested EP awards."],
      order = 93,
      hidden = function() return not (bepgp:admin()) end,
      get = function() return bepgp.db.profile.progress end,
      set = function(info, val)
        bepgp.db.profile.progress = val -- DEBUG print("optionset:"..val)
        bepgp:refreshPRTablets()
        if (IsGuildLeader()) then
          bepgp:shareSettings(true)
        end
      end,
      values = function()
        local system = bepgp.db.profile.system
        if price_systems[system] then
          local flavor = price_systems[system].flavor
          if flavor and bepgp._progsets[flavor] then
            return bepgp._progsets[flavor].progress_values
          end
        end
        if bepgp._mists then
          return bepgp._progsets._mists.progress_values
        elseif bepgp._cata then
          return bepgp._progsets._cata.progress_values
        elseif bepgp._wrath then
          return bepgp._progsets._wrath.progress_values
        elseif bepgp._bcc then
          return bepgp._progsets._bcc.progress_values
        elseif bepgp._classic then
          return bepgp._progsets._classic.progress_values
        end
      end,
      sorting = function()
        local system = bepgp.db.profile.system
        if price_systems[system] then
          local flavor = price_systems[system].flavor
          if flavor and bepgp._progsets[flavor] then
            return bepgp._progsets[flavor].progress_sorting
          end
        end
        if bepgp._mists then
          return bepgp._progsets._mists.progress_sorting
        elseif bepgp._cata then
          return bepgp._progsets._cata.progress_sorting
        elseif bepgp._wrath then
          return bepgp._progsets._wrath.progress_sorting
        elseif bepgp._bcc then
          return bepgp._progsets._bcc.progress_sorting
        elseif bepgp._classic then
          return bepgp._progsets._classic.progress_sorting
        end
      end,
    }
    self._options.args.general.args.main.args["report_channel"] = {
      type = "select",
      name = L["Reporting channel"],
      desc = L["Channel used by reporting functions."],
      order = 95,
      hidden = function() return not (bepgp:admin()) end,
      get = function() return bepgp.db.profile.announce end,
      set = function(info, val) bepgp.db.profile.announce = val end,
      values = { ["PARTY"]=_G.PARTY, ["RAID"]=_G.RAID, ["GUILD"]=_G.GUILD, ["OFFICER"]=_G.OFFICER },
    }
    self._options.args.general.args.main.args["decay"] = {
      type = "execute",
      name = L["Decay EPGP"],
      desc = string.format(L["Decays all EPGP by %s%%"],(1-(bepgp.db.profile.decay or bepgp.VARS.decay))*100),
      order = 100,
      hidden = function() return not (bepgp:admin()) end,
      func = function() bepgp:decay_epgp() end
    }
    self._options.args.general.args.main.args["set_decay_header"] = {
      type = "header",
      name = string.format(L["Weekly Decay: %s%%"],(1-(bepgp.db.profile.decay or bepgp.VARS.decay))*100),
      order = 105,
      hidden = function() return bepgp:admin() end,
    }
    self._options.args.general.args.main.args["set_decay"] = {
      type = "range",
      name = L["Set Decay %"],
      desc = L["Set Decay percentage (Admin only)."],
      order = 110,
      get = function() return (1.0-bepgp.db.profile.decay) end,
      set = function(info, val)
        bepgp.db.profile.decay = (1 - val)
        self._options.args.general.args.main.args["decay"].desc = string.format(L["Decays all EPGP by %s%%"],(1-bepgp.db.profile.decay)*100)
        if (IsGuildLeader()) then
          bepgp:shareSettings(true)
        end
      end,
      min = 0.01,
      max = 0.5,
      step = 0.01,
      bigStep = 0.05,
      isPercent = true,
      hidden = function() return not (bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["set_discount_header"] = {
      type = "header",
      name = string.format(L["Offspec Price: %s%%"],bepgp.db.profile.discount*100),
      order = 111,
      hidden = function() return bepgp:admin() end,
    }
    self._options.args.general.args.main.args["set_discount"] = {
      type = "range",
      name = L["Offspec Price %"],
      desc = L["Set Offspec Items GP Percent."],
      order = 115,
      hidden = function() return not (bepgp:admin()) end,
      get = function() return bepgp.db.profile.discount end,
      set = function(info, val)
        bepgp.db.profile.discount = val
        if (IsGuildLeader()) then
          bepgp:shareSettings(true)
        end
      end,
      min = 0,
      max = 1,
      step = 0.05,
      isPercent = true
    }
    self._options.args.general.args.main.args["set_min_ep_header"] = {
      type = "header",
      name = string.format(L["Minimum EP: %s"],bepgp.db.profile.minep),
      order = 116,
      hidden = function() return bepgp:admin() end,
    }
    self._options.args.general.args.main.args["set_min_ilvl"] = {
      type = "input",
      name = L["Minimum ItemLevel"],
      desc = L["Set Minimum ItemLevel (0 = disabled)"],
      usage = L["Only ItemLevel <N> or higher Items will prompt for awarding GP when Masterlooter."],
      order = 117,
      get = function() return tostring(bepgp.db.char.minilvl) end,
      set = function(info, val)
        local minilvlopt = tonumber(val)
        bepgp.db.char.minilvl = minilvlopt
        if minilvlopt and minilvlopt == 0 then
          bepgp.db.char.prveto = false
          bepgp.db.char.wincountepgp = false
          bepgp.db.char.xmogbid = false
        end
      end,
      validate = function(info, val)
        local n = tonumber(val)
        if n and n >= 0 and n <= bepgp.VARS.maxilvl then
          return true
        else
          return string.format(L["Value must fall between 0 and %s"],bepgp.VARS.maxilvl)
        end
      end,
      hidden = function()
        if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return true end
        if not bepgp:admin() then return true end
        return false
      end,
    }
    self._options.args.general.args.main.args["set_pr_veto"] = {
      type = "toggle",
      name = L["Allow PR veto"],
      desc = L["Allow players to spend PR for roll items"],
      order = 119,
      get = function() return not not bepgp.db.char.prveto end,
      set = function(info, val)
        bepgp.db.char.prveto = not bepgp.db.char.prveto
      end,
      hidden = function()
        if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return true end
        if bepgp.db.char.mode ~= "epgp" then return true end
        if not bepgp:admin() then return true end
        local minilvlopt = tonumber(bepgp.db.char.minilvl)
        if not (minilvlopt and minilvlopt > 0) then return true end
      end,
    }
    self._options.args.general.args.main.args["set_wincountepgp"] = {
      type = "toggle",
      name = L["Wincount Roll Bids"],
      desc = L["Use Wincount for MS Roll wins"],
      order = 120,
      get = function(info) return not not bepgp.db.char.wincountepgp end,
      set = function(info, val)
        bepgp.db.char.wincountepgp = not bepgp.db.char.wincountepgp
      end,
      hidden = function()
        if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return true end
        if bepgp.db.char.mode ~= "epgp" then return true end
        if not bepgp:admin() then return true end
        local minilvlopt = tonumber(bepgp.db.char.minilvl)
        if not (minilvlopt and minilvlopt > 0) then return true end
      end,
    }
    self._options.args.general.args.main.args["allow_xmog"] = {
      type = "toggle",
      name = L["Allow transmog Bids"],
      desc = L["Call and Accept transmog Bids for items that award no GP"],
      order = 121,
      get = function(info) return not not bepgp.db.char.xmogbid end,
      set = function(info, val)
        bepgp.db.char.xmogbid = not bepgp.db.char.xmogbid
      end,
      hidden = function()
        if not (bepgp._mists or bepgp._cata) then return true end
        local mode = bepgp.db.char.mode
        local minilvlopt = tonumber(bepgp.db.char.minilvl)
        local admin, lootMaster = bepgp:admin(), bepgp:lootMaster()
        if mode == "plusroll" and not bepgp:lootMaster() then return true end
        if mode == "epgp" and not bepgp:admin() then return true end
        if mode == "epgp" and not (minilvlopt and minilvlopt > 0) then return true end
      end,
    }
    self._options.args.general.args.main.args["set_min_ep"] = {
      type = "input",
      name = L["Minimum EP"],
      desc = L["Set Minimum EP"],
      usage = "<minep>",
      order = 123,
      get = function() return tostring(bepgp.db.profile.minep) end,
      set = function(info, val)
        bepgp.db.profile.minep = tonumber(val)
        bepgp:refreshPRTablets()
        if (IsGuildLeader()) then
          bepgp:shareSettings(true)
        end
      end,
      validate = function(info, val)
        local n = tonumber(val)
        if n and n >= 0 and n <= bepgp.VARS.max then
          return true
        else
          return string.format(L["Value must fall between 0 and %s"],bepgp.VARS.max)
        end
      end,
      hidden = function() return not bepgp:admin() end,
    }
    self._options.args.general.args.main.args["reset"] = {
     type = "execute",
     name = L["Reset EPGP"],
     desc = string.format(L["Resets everyone\'s EPGP to 0/%d (Guild Leader only)."],bepgp.VARS.basegp),
     order = 125,
     hidden = function() return not (IsGuildLeader()) end,
     func = function()
        if bepgp:checkDialog(addonName.."DialogResetPoints") then
          LD:Spawn(addonName.."DialogResetPoints")
        end
      end
    }
    self._options.args.general.args.main.args["system_header"] = {
      type = "header",
      name = string.format(L["Price System: %s"],(bepgp.db.profile.system or _G.NOT_APPLICABLE)),
      order = 127,
      hidden = function() return bepgp:admin() end,
    }
    self._options.args.general.args.main.args["system"] = {
      type = "select",
      name = L["Select Price Scheme"],
      desc = L["Select From Registered Price Systems"],
      order = 135,
      hidden = function() return not (bepgp:admin()) end,
      get = function() return bepgp.db.profile.system end,
      set = function(info, val)
        bepgp.db.profile.system = val
        bepgp:SetPriceSystem()
        bepgp:refreshPRTablets()
      end,
      values = function()
        local v = {}
        for k,_ in pairs(price_systems) do
          v[k]=k
        end
        return v
      end,
    }
    self._options.args.general.args.main.args["fullname"] = {
      type = "toggle",
      name = L["Use Fullnames"],
      desc = L["Use Playername-Realmname where available"],
      order = 136,
      get = function() return not not bepgp.db.profile.fullnames end,
      set = function(info, val)
        bepgp.db.profile.fullnames = not bepgp.db.profile.fullnames
        bepgp:refreshUnitCaches()
        if IsGuildLeader() then
          bepgp:shareSettings()
        end
      end,
      hidden = function() return not (bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["whitelist"] = {
      type = "input",
      name = L["Whitelist EPGP Admin"],
      desc = L["Auto-approve this EPGP admin's ML and Raid Size requests"],
      order = 137,
      usage = "Type EPGP admin name and press Enter",
      get = false,
      set = function(info, val)
        local name = (bepgp:verifyGuildMember(val,true))
        if name then
          bepgp.db.char.whitelist[name] = true
        end
      end,
      hidden = function() return not (bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["whitelist_rem"] = {
      type = "select",
      name = L["Remove from Whitelist"],
      desc = L["ML and Raid Size requests will need confirmation"],
      get = false,
      set = function(info, val)
        if bepgp.db.char.whitelist[val] then
          bepgp.db.char.whitelist[val] = nil
        end
      end,
      values = function()
        local tmpTab = {}
        for name,_ in pairs(self.db.char.whitelist) do
          tmpTab[name] = name
        end
        return tmpTab
      end,
      order = 138,
      hidden = function() return not (bepgp:admin() and bepgp:table_count(bepgp.db.char.whitelist) > 0 ) end,
    }
    self._options.args.general.args.main.args["push"] = {
      type = "execute",
      name = L["Share Admin Options"],
      desc = L["Push admin-only options to guild members currently online"],
      order = 139,
      hidden = function() return not (IsGuildLeader()) end,
      func = function()
        bepgp:shareSettings(true)
        bepgp:Print(L["Pushed admin-only options to online guild members"])
      end,
    }
    self._options.args.general.args.main.args["mode_options_header"] = {
      type = "header",
      name = L["PlusRoll"].."/"..L["EPGP"],
      order = 140,
    }
    self._options.args.general.args.main.args["mode"] = {
      type = "select",
      name = L["Mode of Operation"],
      desc = L["Select mode of operation."],
      get = function()
        return bepgp.db.char.mode
      end,
      set = function(info, val)
        bepgp.db.char.mode = val
        bepgp:SetMode(bepgp.db.char.mode)
      end,
      values = { ["epgp"]=L["EPGP"], ["plusroll"]=L["PlusRoll"]},
      sorting = {"epgp", "plusroll"},
      order = 143,
    }
    self._options.args.general.args.main.args["priorank"] = {
      type = "select",
      name = L["Rank Priority"],
      desc = L["Select Rank for increased Loot Prio\n(Selected Rank and Higher override PR of lower ranks)"],
      get = function()
        return bepgp.db.char.priorank
      end,
      set = function(info, val)
        bepgp.db.char.priorank = val
        bepgp:refreshPRTablets()
      end,
      values = function()
        if not bepgp._guildRanks then
          bepgp._guildRanks = bepgp:getGuildRanks()
        end
        return bepgp._guildRanks
      end,
      sorting = function()
        if not bepgp._guildRankSorting then
          bepgp._guildRanks, bepgp._guildRankSorting = bepgp:getGuildRanks()
        end
        return bepgp._guildRankSorting
      end,
      order = 144,
      hidden = function() return (bepgp.db.char.mode ~= "epgp") or (bepgp.db.char.mode == "epgp" and not bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["priorank_ms"] = {
      type = "toggle",
      name = L["Rank Priority MS"],
      desc = L["Rank Priority only applies to MS bids"],
      order = 145,
      get = function()
        return not not bepgp.db.char.priorank_ms
      end,
      set = function(info, val)
        bepgp.db.char.priorank_ms = not bepgp.db.char.priorank_ms
        bepgp:refreshPRTablets()
      end,
      hidden = function()
        return (bepgp.db.char.mode ~= "epgp") or (bepgp.db.char.mode == "epgp" and not bepgp:admin()) or (bepgp.db.char.priorank == bepgp.VARS.priorank)
      end,
    }
    self._options.args.general.args.main.args["lootclear"] = {
      type = "execute",
      name = L["Clear Loot"],
      desc = L["Clear Loot"],
      order = 146,
      func = function()
        local loot = bepgp:GetModule(addonName.."_loot",true)
        if loot then
          loot:Clear()
          loot:Toggle()
        end
      end,
      hidden = function() return (bepgp.db.char.mode ~= "epgp") or (bepgp.db.char.mode == "epgp" and not bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["wincountclear"] = {
      type = "execute",
      name = L["Clear Wincount"],
      desc = L["Clear Wincount"],
      order = 147,
      func = function()
        local plusroll_loot = bepgp:GetModule(addonName.."_plusroll_loot",true)
        if plusroll_loot then
          plusroll_loot:Clear()
          plusroll_loot:Toggle()
        end
      end,
      hidden = function()
        if bepgp.db.char.mode == "epgp" and bepgp.db.char.wincountepgp then
          return false
        elseif bepgp.db.char.mode == "plusroll" and bepgp.db.char.wincountmanual then
          return false
        end
        return true
      end,
    }
    self._options.args.general.args.main.args["reserveclear"] = {
      type = "execute",
      name = L["Clear reserves"],
      desc = L["Clear reserves"],
      order = 148,
      func = function()
        local plusroll_reserves = bepgp:GetModule(addonName.."_plusroll_reserves",true)
        if plusroll_reserves then
          plusroll_reserves:Clear()
          plusroll_reserves:Toggle()
        end
      end,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["wincountopt"] = {
      type = "toggle",
      name = L["Manual Wincount"],
      desc = L["Manually reset Wincount at end of raid."],
      order = 150,
      get = function() return not not bepgp.db.char.wincountmanual end,
      set = function(info, val)
        bepgp.db.char.wincountmanual = not bepgp.db.char.wincountmanual
      end,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["wincounttoken"] = {
      type = "toggle",
      name = L["Skip Autoroll Items"],
      desc = L["Skip Autoroll Items from Wincount Prompts."],
      order = 155,
      get = function() return not not bepgp.db.char.wincounttoken end,
      set = function(info, val)
        bepgp.db.char.wincounttoken = not bepgp.db.char.wincounttoken
      end,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["wincountstack"] = {
      type = "toggle",
      name = L["Skip Stackable Items"],
      desc = L["Skip Stackable Items from Wincount Prompts."],
      order = 157,
      get = function() return not not bepgp.db.char.wincountstack end,
      set = function(info,val)
        bepgp.db.char.wincountstack = not bepgp.db.char.wincountstack
      end,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["plusrollepgp"] = {
      type = "toggle",
      name = L["Award GP"],
      desc = L["|cff00ff00Guild members|r that win items also get awarded GP.\n|cffFFFF33Checked:|r Mainspec AND Reserve wins.\n|cffD3D3D3Grey:|r Reserve wins ONLY."],
      descStyle = "inline",
      width = "full",
      order = 158,
      get = function()
        if bepgp.db.char.plusrollepgp ~= nil then
          if bepgp.db.char.plusrollepgp == "sr" then
            return nil
          end
          if bepgp.db.char.plusrollepgp == "msr" then
            return true
          end
        end
        return bepgp.db.char.plusrollepgp
      end,
      set = function(info,val)
        if val == true then
          bepgp.db.char.plusrollepgp = "msr"
        elseif val == false then
          bepgp.db.char.plusrollepgp = false
        else -- nil / greyed
          bepgp.db.char.plusrollepgp = "sr"
        end
        --bepgp.db.char.plusrollepgp = not bepgp.db.char.plusrollepgp
      end,
      tristate = true,
      hidden = function() return not (bepgp.db.char.mode == "plusroll" and bepgp:admin()) end,
    }
    self._options.args.general.args.main.args["wincountignore"] = {
      type = "toggle",
      name = L["Ignore Wincount"],
      desc = L["Ignore Wincount for bid sorting.\n(plain SR > MS > OS, no +1)"],
      order = 160,
      get = function() return not not bepgp.db.char.wincountignore end,
      set = function(info, val)
        bepgp.db.char.wincountignore = not bepgp.db.char.wincountignore
      end,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
    self._options.args.general.args.main.args["maxreserves"] = {
      type = "range",
      name = L["Max reserves"],
      desc = L["Maximum number of reserves allowed"],
      order = 165,
      get = function() return bepgp.db.char.maxreserves end,
      set = function(info, val)
        local value = tonumber(val)
        if value <=0 then value = 1 end
        if value >5 then value = 5 end
        bepgp.db.char.maxreserves = value
      end,
      min = 1,
      max = 5,
      step = 1,
      hidden = function() return bepgp.db.char.mode ~= "plusroll" end,
    }
  end
  return self._options
end

function bepgp:ddoptions(refresh)
  local members = bepgp:buildRosterTable()
  self:debugPrint(string.format(L["Scanning %d members for EP/GP data. (%s)"],#(members),(bepgp.db.char.raidonly and "Raid" or "Full")))
  if not self._dda_options then
    self._dda_options = {
      type = "group",
      name = L["BastionLoot options"],
      desc = L["BastionLoot options"],
      handler = bepgp,
      args = { }
    }
    self._dda_options.args["mode"] = {
      type = "execute",
      name = switch_icon,
      desc = L["Switch Mode of Operation"],
      order = 5,
      func = function(info)
        local mode = bepgp.db.char.mode
        if mode == "epgp" then
          bepgp.db.char.mode = "plusroll"
          bepgp:SetMode("plusroll")
        else
          bepgp.db.char.mode = "epgp"
          bepgp:SetMode("epgp")
        end
      end,
    }
    self._dda_options.args["ep_raid"] = {
      type = "execute",
      name = L["+EPs to Raid"],
      desc = L["Award EPs to all raid members."],
      order = 10,
      func = function(info)
        if bepgp:checkDialog(addonName.."DialogGroupPoints") then
          LD:Spawn(addonName.."DialogGroupPoints", {"ep", C:Green(L["Effort Points"]), _G.RAID})
        end
      end,
    }
    self._dda_options.args["ep"] = {
      type = "group",
      name = L["+EPs to Member"],
      desc = L["Account EPs for member."],
      order = 40,
      args = { },
    }
    self._dda_options.args["gp"] = {
      type = "group",
      name = L["+GPs to Member"],
      desc = L["Account GPs for member."],
      order = 50,
      args = { },
    }
    self._dda_options.args["loot_admin"] = {
      type = "execute",
      name = lootareq_icon,
      desc = L["Send Request for Loot Admin to Raid Leader"],
      order = 52,
      --hidden = function() return bepgp.db.char.mode ~= "epgp" end,
      func = function(info)
        bepgp:RequestLootAdmin()
      end,
    }
    if (bepgp._mists or bepgp._cata or bepgp._wrath) then
      self._dda_options.args["size_toggle"] = {
        type = "execute",
        name = sizereq_icon,
        desc = L["Send Request for Raid Size change to Raid Leader"],
        order = 53,
        func = function(info)
          bepgp:RequestSizeToggle()
        end,
      }
      self._dda_options.args["diff_toggle"] = {
        type = "execute",
        name = diffreq_icon,
        desc = L["Send Request for Raid Difficulty change to Raid Leader"],
        order = 54,
        func = function(info)
          bepgp:RequestDiffToggle()
        end,
      }
    end
    self._dda_options.args["roster"] = {
      type = "execute",
      name = exportrost_icon,
      desc = L["Export Raid Roster"],
      order = 55,
      func = function(info)
        local roster = bepgp:GetModule(addonName.."_roster",true)
        if roster then
          roster:Toggle()
        end
      end,
    }
    self._dda_options.args["stop"] = {
      type = "execute",
      name = stop_icon,
      desc = L["Suspend bid monitoring for this session.(does not persist relog)"],
      order = 60,
      func = function(info)
        bepgp:Suspend()
      end,
    }
  end
  if not self._ddm_options then
    self._ddm_options = {
      type = "group",
      name = L["BastionLoot options"],
      desc = L["BastionLoot options"],
      handler = bepgp,
      args = { }
    }
    self._ddm_options.args["mode"] = {
      type = "execute",
      name = switch_icon,
      desc = L["Switch Mode of Operation"],
      order = 5,
      func = function(info)
        local mode = bepgp.db.char.mode
        if mode == "epgp" then
          bepgp.db.char.mode = "plusroll"
          bepgp:SetMode("plusroll")
        else
          bepgp.db.char.mode = "epgp"
          bepgp:SetMode("epgp")
        end
      end,
    }
    self._ddm_options.args["roster"] = {
      type = "execute",
      name = exportrost_icon,
      desc = L["Export Raid Roster"],
      order = 10,
      func = function(info)
        local roster = bepgp:GetModule(addonName.."_roster",true)
        if roster then
          roster:Toggle()
        end
      end,
      disabled = function(info)
        local wrong_mode = (bepgp.db.char.mode ~= "plusroll")
        local not_ml = not (bepgp:lootMaster())
        return (wrong_mode or not_ml)
      end,
    }
    self._ddm_options.args["stop"] = {
      type = "execute",
      name = stop_icon,
      desc = L["Suspend bid monitoring for this session.(does not persist relog)"],
      order = 60,
      func = function(info)
        bepgp:Suspend()
      end,
    }
  end
  if #(members) > 0 then
    self._dda_options.args["ep"].args = bepgp:buildClassMemberTable(members,"ep")
    self._dda_options.args["gp"].args = bepgp:buildClassMemberTable(members,"gp")
  else
    self._dda_options.args["ep"].args = {[_G.NONE]={type="execute",name=_G.NONE,func=function()end}}
    self._dda_options.args["gp"].args = {[_G.NONE]={type="execute",name=_G.NONE,func=function()end}}
  end
  return self._dda_options, self._ddm_options
end

function bepgp.OnLDBClick(obj,button)
  local is_admin = bepgp:admin()
  local mode = bepgp.db.char.mode
  local logs = bepgp:GetModule(addonName.."_logs",true)
  local alts = bepgp:GetModule(addonName.."_alts",true)
  local browser = bepgp:GetModule(addonName.."_browser",true)
  local standby = bepgp:GetModule(addonName.."_standby",true)
  local loot = bepgp:GetModule(addonName.."_loot",true)
  local bids = bepgp:GetModule(addonName.."_bids",true)
  local standings = bepgp:GetModule(addonName.."_standings",true)
  -- plusroll
  local reserves = bepgp:GetModule(addonName.."_plusroll_reserves",true)
  local rollbids = bepgp:GetModule(addonName.."_plusroll_bids",true)
  local rollloot = bepgp:GetModule(addonName.."_plusroll_loot",true)
  local rolllogs = bepgp:GetModule(addonName.."_plusroll_logs",true)
  local roll_admin = rollloot and rollloot:raidLootAdmin() or false
  if is_admin then
    if button == "LeftButton" then
      if IsControlKeyDown() and IsShiftKeyDown() then
        -- logs TODO: conditionally plusroll wincount
        if mode == "epgp" then
          if logs then
            logs:Toggle()
          end
        elseif mode == "plusroll" and roll_admin then
          if rollloot then -- wincount
            rollloot:Toggle()
          end
        end
      elseif IsControlKeyDown() and IsAltKeyDown() then
        -- alts
        if alts then
          alts:Toggle()
        end
      elseif IsAltKeyDown() and IsShiftKeyDown() then
        -- favorites
        if browser then
          browser:Toggle()
        end
      elseif IsControlKeyDown() then
        -- standby
        if standby then
          standby:Toggle()
        end
      elseif IsShiftKeyDown() then
        -- loot or reserves conditionally
        if mode == "epgp" then
          if loot then
            loot:Toggle()
            if bepgp.db.char.wincountepgp then
              if rollloot then
                rollloot:Toggle()
              end
            end
          end
        elseif mode == "plusroll" and roll_admin then
          if reserves then
            reserves:Toggle()
          end
        end
      elseif IsAltKeyDown() then
        -- bids conditionally
        if mode == "epgp" then
          if bids then
            bids:Toggle(obj)
          end
        elseif mode == "plusroll" and roll_admin then
          if rollbids then
            rollbids:Toggle(obj)
          end
        end
      else
        if standings then
          standings:Toggle()
        end
      end
    elseif button == "RightButton" then
      bepgp:OpenAdminActions(obj)
    elseif button == "MiddleButton" then
      bepgp:toggleOptions()
    end
  else
    if button == "LeftButton" then
      if IsAltKeyDown() then
        if browser then
          browser:Toggle()
        end
      elseif IsControlKeyDown() and IsShiftKeyDown() and (mode == "plusroll") and roll_admin then
        if rollloot then
          rollloot:Toggle()
        end
      elseif IsControlKeyDown() and (mode == "plusroll") and roll_admin then
        if rollbids then
          rollbids:Toggle()
        end
      elseif IsShiftKeyDown() and (mode == "plusroll") and roll_admin then
        if reserves then
          reserves:Toggle()
        end
      else
        if standings then
          standings:Toggle()
        end
      end
    elseif button == "RightButton" then
      bepgp:OpenAdminActions(obj)
    elseif button == "MiddleButton" then
      bepgp:toggleOptions()
    end
  end
end

function bepgp:optionSize()
  local mode = self.db.char.mode
  local is_admin = bepgp:admin()
  local default_w, default_h = 800, 660
  local w, h = default_w, default_h
  if not is_admin then
    h = h - 90
    if mode == "plusroll" then
      h = h - 50
    end
  end
  if mode == "epgp" then
    h = h - 90
  end
  return w, h
end

function bepgp:toggleOptions()
  if ACD.OpenFrames[addonName] then
    ACD:Close(addonName)
  else
    local w, h = self:optionSize()
    ACD:SetDefaultSize(addonName,w,h)
    ACD:Open(addonName,"general")
  end
end

function bepgp.OnLDBTooltipShow(tooltip)
  tooltip = tooltip or GameTooltip
  local is_admin = bepgp:admin()
  local mode = bepgp.db.char.mode
  local title = string.format("%s [%s]",label,modes[mode])
  if bepgp._SUSPEND then
    title = string.format("%s [%s]",label,modes.suspend)
  end
  local rollloot = bepgp:GetModule(addonName.."_plusroll_loot",true)
  local roll_admin = rollloot and rollloot:raidLootAdmin() or false
  tooltip:SetText(title)
  tooltip:AddLine(" ")
  local hint = L["|cffff7f00Click|r to toggle Standings."]
  tooltip:AddLine(hint)
  if is_admin then
    tooltip:AddLine(" ")
    hint = L["|cffff7f00Alt+Click|r to toggle Bids."]
    tooltip:AddLine(hint)
    if mode == "epgp" then
      hint = L["|cffff7f00Shift+Click|r to toggle Loot."]
      tooltip:AddLine(hint)
    elseif mode == "plusroll" and roll_admin then
      hint = L["|cffff7f00Shift+Click|r to toggle Reserves."]
      tooltip:AddLine(hint)
    end
    hint = L["|cffff7f00Ctrl+Click|r to toggle Standby."]
    tooltip:AddLine(hint)
    hint = L["|cffff7f00Ctrl+Alt+Click|r to toggle Alts."]
    tooltip:AddLine(hint)
    hint = L["|cffff7f00Shift+Alt+Click|r to toggle Favorites."]
    tooltip:AddLine(hint)
    if mode == "epgp" then
      hint = L["|cffff7f00Ctrl+Shift+Click|r to toggle Logs."]
      tooltip:AddLine(hint)
    elseif mode == "plusroll" and roll_admin then
      hint = L["|cffff7f00Ctrl+Shift+Click|r to toggle Wincount."]
      tooltip:AddLine(hint)
    end
    tooltip:AddLine(" ")
    hint = L["|cffff7f00Middle Click|r for %s"]:format(L["Admin Options"])
    tooltip:AddLine(hint)
    hint = L["|cffff7f00Right Click|r for %s."]:format(L["Admin Actions"])
    tooltip:AddLine(hint)
  else
    hint = L["|cffff7f00Alt+Click|r to toggle Favorites."]
    tooltip:AddLine(hint)
    if mode == "plusroll" and roll_admin then
      hint = L["|cffff7f00Ctrl+Click|r to toggle Bids."]
      tooltip:AddLine(hint)
      hint = L["|cffff7f00Shift+Click|r to toggle Reserves."]
      tooltip:AddLine(hint)
      hint = L["|cffff7f00Ctrl+Shift+Click|r to toggle Wincount."]
      tooltip:AddLine(hint)
    end
    hint = L["|cffff7f00Right Click|r for %s."]:format(L["Member Actions"])
    tooltip:AddLine(hint)
    hint = L["|cffff7f00Middle Click|r for %s"]:format(L["Member Options"])
    tooltip:AddLine(hint)
  end
end

function bepgp:checkDialog(delegate)
  if LD and LD.Spawn then
    if LD.delegates and LD.delegates[delegate] then
      return true
    end
    self:debugPrint(L["Dialogs not initialized, restarting addon"])
    self:OnEnable(true)
    return false
  end
  return false
end

function bepgp:templateCache(id)
  local key = addonName..id
  self._dialogTemplates = self._dialogTemplates or {}
  if self._dialogTemplates[key] then return self._dialogTemplates[key] end
  if not self._dialogTemplates[key] then
    if id == "DialogMemberPoints" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["You are assigning %s %s to %s."],
        on_show = function(self)
          local what = self.data[1]
          local amount
          if what == "ep" then
            amount = bepgp:suggestEPAward()
          elseif what == "gp" then
            amount = 0
          end
          self.text:SetText(string.format(L["You are assigning %s %s to %s."],amount,self.data[2],self.data[3]))
        end,
        on_update = function(self,elapsed)
          self._elapsed = (self._elapsed or 0) + elapsed
          if self._elapsed > 0.9 and self._elapsed < 1.0 then
            self.delegate.on_show(self)
            self.delegate.on_update = nil
            self._elapsed = nil
          end
        end,
        editboxes = {
          {
            on_enter_pressed = function(self)
              local who = self:GetParent().data[3]
              local what = self:GetParent().data[1]
              local amount = tonumber(self:GetText())
              if amount then
                if what == "ep" then
                  bepgp:givename_ep(who,amount,true)
                elseif what == "gp" then
                  bepgp:givename_gp(who,amount)
                end
              end
              LD:Dismiss(addonName.."DialogMemberPoints")
            end,
            on_escape_pressed = function(self)
              self:ClearFocus()
            end,
            on_text_changed = function(self, userInput)
              local dialog_text = self:GetParent().text
              local data = self:GetParent().data
              dialog_text:SetText(string.format(L["You are assigning %s %s to %s."],self:GetText(),data[2],data[3]))
            end,
            on_show = function(self)
              local amount
              local data = self:GetParent().data
              local what = data[1]
              if what == "ep" then
                amount = bepgp:suggestEPAward()
              elseif what == "gp" then
                amount = 0
              end
              self:SetText(tostring(amount))
              self:SetFocus()
            end,
            text = tostring(bepgp:suggestEPAward()),
          },
        },
        buttons = {
          {
            text = _G.ACCEPT,
            on_click = function(self, button, down)
              local data = self.data
              local what, who = data[1],data[3]
              local amount = self.editboxes[1]:GetText()
              amount = tonumber(amount)
              if amount then
                if what == "ep" then
                  bepgp:givename_ep(who,amount,true)
                elseif what == "gp" then
                  bepgp:givename_gp(who,amount)
                end
              end
              LD:Dismiss(addonName.."DialogMemberPoints")
            end,
          },
        },
      }
    elseif id == "DialogGroupPoints" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["You are assigning %s %s to %s."],
        on_show = function(self)
          local amount = bepgp:suggestEPAward()
          self.text:SetText(string.format(L["You are assigning %s %s to %s."],amount,self.data[2],self.data[3]))
        end,
        on_update = function(self,elapsed)
          self._elapsed = (self._elapsed or 0) + elapsed
          if self._elapsed > 0.9 and self._elapsed < 1.0 then
            self.delegate.on_show(self)
            self.delegate.on_update = nil
            self._elapsed = nil
          end
        end,
        editboxes = {
          {
            on_enter_pressed = function(self)
              local who = self:GetParent().data[3]
              local what = self:GetParent().data[1]
              local amount = tonumber(self:GetText())
              if amount then
                if who == _G.RAID then
                  bepgp:award_raid_ep(amount)
                elseif who == L["Standby"] then
                  bepgp:award_standby_ep(amount)
                end
              end
              LD:Dismiss(addonName.."DialogGroupPoints")
            end,
            on_escape_pressed = function(self)
              self:ClearFocus()
            end,
            on_text_changed = function(self, userInput)
              local dialog_text = self:GetParent().text
              local data = self:GetParent().data
              dialog_text:SetText(string.format(L["You are assigning %s %s to %s."],self:GetText(),data[2],data[3]))
            end,
            on_show = function(self)
              local amount = bepgp:suggestEPAward()
              self:SetText(tostring(amount))
              self:SetFocus()
            end,
            text = tostring(bepgp:suggestEPAward()),
          },
        },
        buttons = {
          {
            text = _G.ACCEPT,
            on_click = function(self, button, down)
              local data = self.data
              local what, who = data[1],data[3]
              local amount = self.editboxes[1]:GetText()
              amount = tonumber(amount)
              if amount then
                if who == _G.RAID then
                  bepgp:award_raid_ep(amount)
                elseif who == L["Standby"] then
                  bepgp:award_standby_ep(amount)
                end
              end
              LD:Dismiss(addonName.."DialogGroupPoints")
            end,
          },
        },
      }
    elseif id == "DialogItemPoints" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["%s looted %s. What do you want to do?"],
        on_show = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          local item_id = data[loot_indices.item_id]
          if bepgp.VARS.crystalfirestone and (item_id == bepgp.VARS.crystalfirestone) then -- Crystallized Firestone
            data.firestoneData = data.firestoneData or {}
            data.firestoneData.Items = bepgp:getFirestoneItems((data[loot_indices.class] or "UNKNOWN"), data)
          else
            data.firestoneData = nil
          end
          local price2 = data[loot_indices.price2]
          if self.checkboxes then
            for i=1,#self.checkboxes do
              if self.checkboxes[i] then
                local chkBoxText = self.checkboxes[i].Text or self.checkboxes[i].text
                if chkBoxText then
                  local label = chkBoxText:GetText()
                  if label == L["Class/Role Discount"] then
                    data._discountCheckbox = self.checkboxes[i]
                  else
                    data._firestoneCheckbox = self.checkboxes[i]
                  end
                end
              end
            end
          end
          if data._discountCheckbox then
            data._discountCheckbox:Show()
            data._discountCheckbox:HookScript("OnEnter",function(self)
              GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
              local chunks = strsplittable(";",L.DISCOUNT_HINT)
              if #chunks > 0 then
                GameTooltip:SetText(chunks[1])
                for i=2,#chunks do
                  GameTooltip:AddLine(chunks[i])
                end
                GameTooltip:Show()
              end
            end)
            data._discountCheckbox:HookScript("OnLeave",function(self)
              if GameTooltip:IsOwned(self) then
                GameTooltip:Hide()
              end
            end)
            if not price2 then
              data._discountCheckbox:Hide()
            end
          end
          if data._firestoneCheckbox then
            data._firestoneCheckbox:Show()
            data._firestoneCheckbox:HookScript("OnEnter",function(self)
              GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
              if self:GetChecked() then
                GameTooltip:SetText(L["Click Button again"])
                GameTooltip:AddLine(L["to finalize GP addition"])
                GameTooltip:AddLine(L[".. or clear the checkbox to change item"])
              else
                GameTooltip:SetText(L["Show Selected Item"])
                GameTooltip:AddLine(L["Use GP Button to Set"])
              end
              GameTooltip:Show()
            end)
            data._firestoneCheckbox:HookScript("OnLeave",function(self)
              if GameTooltip:IsOwned(self) then
                GameTooltip:Hide()
              end
            end)
            if not data.firestoneData then
              data._firestoneCheckbox:Hide()
            else
              data._firestoneCheckbox.Text:SetText(data.firestoneData.firestone)
            end
          end
          self.text:SetText(string.format(L["%s looted %s. What do you want to do?"],data[loot_indices.player_c],data[loot_indices.item]))
          if not bepgp:IsHooked(self.close_button, "OnClick") then
            bepgp:HookScript(self.close_button,"OnClick",function(f,button,down)
              local dialog = f:GetParent()
              if dialog then
                local data = dialog.data
                local loot_indices = data.loot_indices
                if loot_indices and loot_indices.action then
                  data[loot_indices.action] = bepgp.VARS.unassigned
                  local update = data[loot_indices.update] ~= nil
                  local loot = bepgp:GetModule(addonName.."_loot",true)
                  if loot then
                    loot:addOrUpdateLoot(data, update)
                  end
                end
              end
            end)
          end
        end,
        on_cancel = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          data[loot_indices.action] = bepgp.VARS.unassigned
          local update = data[loot_indices.update] ~= nil
          local loot = bepgp:GetModule(addonName.."_loot",true)
          if loot then
            loot:addOrUpdateLoot(data, update)
          end
        end,
        checkboxes = {
          { -- Firestone turn-in
            label = "Crystallized Firestone",
            get_value = function(self)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local status = data.firestoneData and data.firestoneData.gp and true or false
              return status
            end,
            set_value = function(self, value, dialogData, button, down)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              if (value) then
                if data.firestoneData and data.firestoneData.gp then
                  data._firestoneCheckbox.Text:SetText(data.firestoneData.firestone)
                  data.firestoneData.gp = nil
                  data.firestoneData.gp_os = nil
                  data.firestoneData.gp2 = nil
                  data.firestoneData.gp2_os = nil
                  data.firestoneData.item = nil
                end
              end
            end,
          },
          { -- Discount GP
            label = L["Class/Role Discount"],
            get_value = function(self)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local loot_indices = data.loot_indices
              return data.use_discount or false
            end,
            set_value = function(self, button, down)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local loot_indices = data.loot_indices
              data.use_discount = not data.use_discount
            end,
          },
        },
        buttons = {
          { -- MainSpec GP
            text = L["Add MainSpec GP"], 
            on_click = function(self, button, down) -- docs lie: it's dialog, dialog.data, "clicked"
              local data = self.data
              local loot_indices = data.loot_indices
              data[loot_indices.action] = bepgp.VARS.msgp
              local name = data[loot_indices.player]
              local gp = tonumber(data[loot_indices.price])
              local gp2 = tonumber(data[loot_indices.price2])
              if data.firestoneData then
                if (not data.firestoneData.gp) then
                  bepgp._firestoneDD = LDD:OpenAce3Menu(data.firestoneData.Items)
                  bepgp._firestoneDD:SetPoint("TOP", self.buttons[1], "BOTTOM", 0,0)
                  return true
                else
                  gp = data.firestoneData.gp
                  gp2 = data.firestoneData.gp2
                end
              end
              local update = data[loot_indices.update] ~= nil
              local loot = bepgp:GetModule(addonName.."_loot",true)
              if loot then
                loot:addOrUpdateLoot(data, update)
              end
              if data.use_discount and gp2 then
                bepgp:givename_gp(name, gp2)
              else
                bepgp:givename_gp(name, gp)
              end
              LD:Dismiss(addonName.."DialogItemPoints")
              LD:Dismiss(addonName.."DialogItemWinCount")
            end,
          },
          { -- OffSpec GP
            text = L["Add OffSpec GP"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              data[loot_indices.action] = bepgp.VARS.osgp
              local name = data[loot_indices.player]
              local gp = tonumber(data[loot_indices.off_price])
              local gp2 = tonumber(data[loot_indices.off_price2])
              local discount = bepgp.db.profile.discount
              if data.firestoneData and discount > 0 then
                if (not data.firestoneData.gp_os) then
                  bepgp._firestoneDD = LDD:OpenAce3Menu(data.firestoneData.Items)
                  bepgp._firestoneDD:SetPoint("TOP", self.buttons[2], "BOTTOM", 0,0)
                  return true
                else
                  gp = data.firestoneData.gp_os
                  gp2 = data.firestoneData.gp2_os
                end
              end
              local update = data[loot_indices.update] ~= nil
              local loot = bepgp:GetModule(addonName.."_loot",true)
              if loot then
                loot:addOrUpdateLoot(data, update)
              end
              if data.use_discount and gp2 then
                bepgp:givename_gp(name, gp2)
              else
                bepgp:givename_gp(name, gp)
              end
              LD:Dismiss(addonName.."DialogItemPoints")
              LD:Dismiss(addonName.."DialogItemWinCount")
            end,
          },
          { -- Bank/D-E
            text = L["Bank or D/E"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              data[loot_indices.action] = bepgp.VARS.bankde
              local update = data[loot_indices.update] ~= nil
              local loot = bepgp:GetModule(addonName.."_loot",true)
              if loot then
                loot:addOrUpdateLoot(data, update)
              end
              LD:Dismiss(addonName.."DialogItemPoints")
              LD:Dismiss(addonName.."DialogItemWinCount")
            end,
          },
        },        
      }
    elseif id == "DialogItemWinCount" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["%s looted to %s. Mark it as.."],
        on_show = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          local from_log = data[loot_indices.log]
          local item_id = data[loot_indices.item_id]
          local enClass = data[loot_indices.class]
          self.text:SetText(string.format(L["%s looted %s. What do you want to do?"],data[loot_indices.player_c],data[loot_indices.item]))
        end,
        on_cancel = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          local player = data[loot_indices.player]
          local player_c = data[loot_indices.player_c]
          local item = data[loot_indices.item]
          local item_id = data[loot_indices.item_id]
          local from_log = data[loot_indices.log]
          local bepgp_loot = bepgp:GetModule(addonName.."_loot",true)
          local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
          if from_log then -- update from log
            local log_indices = data.log_indices
            local log_entry = bepgp.db.char.plusroll_logs[from_log]
            local tag = log_entry[log_indices.tag]
            if tag ~= "none" then
              if tag == "+1" then
                -- remove from wincount and update log
              end
            end
          else -- new entry
            if plusroll_logs then
              plusroll_logs:addToLog(player,player_c,item,item_id,"none")
            end
          end
        end,
        buttons = {
          { -- Won as mainspec
            text = L["Mainspec"].." +1",
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              local player = data[loot_indices.player]
              local player_c = data[loot_indices.player_c]
              local item = data[loot_indices.item]
              local item_id = data[loot_indices.item_id]
              local from_log = data[loot_indices.log]
              local bepgp_loot = bepgp:GetModule(addonName.."_loot",true)
              local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
              if from_log then
                local log_entry = bepgp.db.char.plusroll_logs[from_log]
                local log_indices = data.log_indices
                local tag = log_entry[log_indices.tag]
                if tag ~= "+1" then
                  if bepgp_loot then
                    bepgp_loot:addWincount(player,item_id)
                  end
                  if plusroll_logs then
                    plusroll_logs:updateLog(from_log,"+1")
                  end
                end
              else -- new entry
                if bepgp_loot then
                  bepgp_loot:addWincount(player,item_id)
                end
                if plusroll_logs then
                  plusroll_logs:addToLog(player,player_c,item,item_id,"+1")
                end
              end
              LD:Dismiss(addonName.."DialogItemPoints")
              LD:Dismiss(addonName.."DialogItemWinCount")
            end,
          },
          { -- Won as offspec
            text = L["Offspec"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              local player = data[loot_indices.player]
              local player_c = data[loot_indices.player_c]
              local item = data[loot_indices.item]
              local item_id = data[loot_indices.item_id]
              local from_log = data[loot_indices.log]
              local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
              local bepgp_loot = bepgp:GetModule(addonName.."_loot",true)
              if from_log then
                local log_entry = bepgp.db.char.plusroll_logs[from_log]
                local log_indices = data.log_indices
                local tag = log_entry[log_indices.tag]
                if tag ~= "os" then
                  if tag == "+1" then
                    if bepgp_loot then
                      bepgp_loot:removeWincount(player,item_id)
                    end
                  end
                  if plusroll_logs then
                    plusroll_logs:updateLog(from_log,"os")
                  end
                end
              else
                if plusroll_logs then
                  plusroll_logs:addToLog(player,player_c,item,item_id,"os")
                end
              end
              LD:Dismiss(addonName.."DialogItemPoints")
              LD:Dismiss(addonName.."DialogItemWinCount")
            end,
          },
        },
      }
    elseif id == "DialogItemPlusPoints" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["%s looted to %s. Mark it as.."],
        on_show = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          local from_log = data[loot_indices.log]
          local item_id = data[loot_indices.item_id]
          local enClass = data[loot_indices.class]
          local price,tier,price2,wand_discount,ranged_discount,shield_discount,onehand_discount,twohand_discount,item_level = bepgp:GetPrice(item_id, bepgp.db.profile.progress)
          price2 = type(price2)=="number" and price2 or nil
          self.text:SetText(string.format(L["%s looted to %s. Mark it as.."],data[loot_indices.item],data[loot_indices.player_c]))
          local discountChkBx
          if self.checkboxes then
            for i=1,#self.checkboxes do
              if self.checkboxes[i] then
                local chkBoxText = self.checkboxes[i].Text or self.checkboxes[i].text
                if chkBoxText and chkBoxText:GetText() == L["Class/Role Discount"] then
                  discountChkBx = self.checkboxes[i]
                  break
                end
              end
            end
          end
          if discountChkBx then
            discountChkBx:Show()
            discountChkBx:HookScript("OnEnter",function(self)
              GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
              local chunks = strsplittable(";",L.DISCOUNT_HINT)
              if #chunks > 0 then
                GameTooltip:SetText(chunks[1])
                for i=2,#chunks do
                  GameTooltip:AddLine(chunks[i])
                end
                GameTooltip:Show()
              end
            end)
            discountChkBx:HookScript("OnLeave",function(self)
              if GameTooltip:IsOwned(self) then
                GameTooltip:Hide()
              end
            end)
            if not (price2 and bepgp.db.char.plusrollepgp) then
              discountChkBx:Hide()
            else
              if wand_discount then data.use_discount = true end
              if enClass then -- not available when we're coming from logs
                if ranged_discount and ranged_discount:match(enClass) then data.use_discount = true end
                if shield_discount and shield_discount:match(enClass) then data.use_discount = true end
                if onehand_discount and onehand_discount:match(enClass) then data.use_discount = true end
                if twohand_discount and twohand_discount:match(enClass) then data.use_discount = true end
              end
            end
          end          
        end,
        on_cancel = function(self)
          local data = self.data
          local loot_indices = data.loot_indices
          local player = data[loot_indices.player]
          local player_c = data[loot_indices.player_c]
          local item = data[loot_indices.item]
          local item_id = data[loot_indices.item_id]
          local from_log = data[loot_indices.log]
          local plusroll_loot = bepgp:GetModule(addonName.."_plusroll_loot",true)
          local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
          if from_log then -- update from log
            local log_indices = data.log_indices
            local log_entry = bepgp.db.char.plusroll_logs[from_log]
            local tag = log_entry[log_indices.tag]
            if tag ~= "none" then
              if tag == "+1" then
                -- remove from wincount and update log
              end
            end
          else -- new entry
            if plusroll_logs then
              plusroll_logs:addToLog(player,player_c,item,item_id,"none")
            end
          end
        end,
        checkboxes = {
          { -- Discount GP
            label = L["Class/Role Discount"],
            get_value = function(self)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local loot_indices = data.loot_indices
              return data.use_discount or false
            end,
            set_value = function(self, button, down)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local loot_indices = data.loot_indices
              data.use_discount = not data.use_discount
            end,
          },
        },        
        buttons = {
          { -- Won as reserve
            text = L["Reserve"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              local player = data[loot_indices.player]
              local player_c = data[loot_indices.player_c]
              local item = data[loot_indices.item]
              local item_id = data[loot_indices.item_id]
              local from_log = data[loot_indices.log]
              local reserves = bepgp:GetModule(addonName.."_plusroll_reserves",true)
              local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
              local plusroll_loot = bepgp:GetModule(addonName.."_plusroll_loot",true)
              if from_log then -- update
                local log_entry = bepgp.db.char.plusroll_logs[from_log]
                local log_indices = data.log_indices
                local tag = log_entry[log_indices.tag]
                if tag ~= "res" then
                  if reserves then
                    if reserves:IsReservedExact(item_id, player) then
                      reserves:RemoveReserve(player,item_id)
                    end
                  end
                  if tag == "+1" then
                    if plusroll_loot then
                      plusroll_loot:removeWincount(player,item_id)
                    end
                  end
                  if plusroll_logs then
                    plusroll_logs:updateLog(from_log,"res")
                  end
                end
              else -- new entry
                if bepgp.db.char.plusrollepgp and (bepgp.db.char.plusrollepgp == "sr" or bepgp.db.char.plusrollepgp == "msr") then
                  local price,tier,price2,_,_,_,_,_,item_level = bepgp:GetPrice(item_id, bepgp.db.profile.progress)
                  price2 = type(price2)=="number" and price2 or nil
                  if price and price > 0 and bepgp:itemLevelOptionPass(item_level) then
                    if data.use_discount and price2 then
                      bepgp:givename_gp(player, price2)
                    else
                      bepgp:givename_gp(player, price)
                    end
                  end
                end
                if reserves then
                  if reserves:IsReservedExact(item_id,player) then
                    reserves:RemoveReserve(player,item_id)
                  end
                end
                if plusroll_logs then
                  plusroll_logs:addToLog(player,player_c,item,item_id,"res")
                end
              end
              LD:Dismiss(addonName.."DialogItemPlusPoints")
            end,
          },
          { -- Won as mainspec
            text = L["Mainspec"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              local player = data[loot_indices.player]
              local player_c = data[loot_indices.player_c]
              local item = data[loot_indices.item]
              local item_id = data[loot_indices.item_id]
              local from_log = data[loot_indices.log]
              local plusroll_loot = bepgp:GetModule(addonName.."_plusroll_loot",true)
              local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
              if from_log then
                local log_entry = bepgp.db.char.plusroll_logs[from_log]
                local log_indices = data.log_indices
                local tag = log_entry[log_indices.tag]
                if tag ~= "+1" then
                  if plusroll_loot then
                    plusroll_loot:addWincount(player,item_id)
                  end
                  if plusroll_logs then
                    plusroll_logs:updateLog(from_log,"+1")
                  end
                end
              else -- new entry
                if bepgp.db.char.plusrollepgp and bepgp.db.char.plusrollepgp == "msr" then
                  local price,tier,price2,_,_,_,_,_,item_level = bepgp:GetPrice(item_id, bepgp.db.profile.progress)
                  price2 = type(price2)=="number" and price2 or nil
                  if price and price > 0 and bepgp:itemLevelOptionPass(item_level) then
                    if data.use_discount and price2 then
                      bepgp:givename_gp(player, price2)
                    else
                      bepgp:givename_gp(player, price)
                    end
                  end
                end
                if plusroll_loot then
                  plusroll_loot:addWincount(player,item_id)
                end
                if plusroll_logs then
                  plusroll_logs:addToLog(player,player_c,item,item_id,"+1")
                end
              end
              LD:Dismiss(addonName.."DialogItemPlusPoints")
            end,
          },
          { -- Won as offspec
            text = L["Offspec"],
            on_click = function(self, button, down)
              local data = self.data
              local loot_indices = data.loot_indices
              local player = data[loot_indices.player]
              local player_c = data[loot_indices.player_c]
              local item = data[loot_indices.item]
              local item_id = data[loot_indices.item_id]
              local from_log = data[loot_indices.log]
              local plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs",true)
              local plusroll_loot = bepgp:GetModule(addonName.."_plusroll_loot",true)
              if from_log then
                local log_entry = bepgp.db.char.plusroll_logs[from_log]
                local log_indices = data.log_indices
                local tag = log_entry[log_indices.tag]
                if tag ~= "os" then
                  if tag == "+1" then
                    if plusroll_loot then
                      plusroll_loot:removeWincount(player,item_id)
                    end
                  end
                  if plusroll_logs then
                    plusroll_logs:updateLog(from_log,"os")
                  end
                end
              else -- new entry
                --[[if bepgp.db.char.plusrollepgp then
                  local price = bepgp:GetPrice(item_id, bepgp.db.profile.progress)
                  if price and price > 0 then
                    local off_price = math.floor(price*bepgp.db.profile.discount)
                    if off_price > 0 then
                      bepgp:givename_gp(player, off_price)
                    end
                  end
                end]]
                if plusroll_logs then
                  plusroll_logs:addToLog(player,player_c,item,item_id,"os")
                end
              end
              LD:Dismiss(addonName.."DialogItemPlusPoints")
            end,
          },
        },
      }
    elseif id == "DialogMemberBid" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        is_exclusive = true,
        duration = 30,
        text = L["Bid Call for %s [%ds]"],
        on_show = function(self)
          local data = self.data
          local link = data[1]
          self.text:SetText(string.format(L["Bid Call for %s [%ds]"],link,self.duration))
          self:SetScript("OnEnter", function(f)
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
          end)
          self:SetScript("OnLeave", function(f)
            if GameTooltip:IsOwned(f) then
              GameTooltip_Hide()
            end
          end)
          if not bepgp:IsHooked(self, "OnHide") then
            bepgp:HookScript(self,"OnHide",function(f)
              if GameTooltip:IsOwned(f) then
                GameTooltip_Hide()
              end
            end)
          end
          local prveto = data[4]
          local xmog = data[5]
          if prveto then
            self.buttons[3]:Show()
          else
            self.buttons[3]:Hide()
          end
          if xmog then
            self.buttons[4]:Show()
          else
            self.buttons[4]:Hide()
          end
          self:Resize()
        end,
        on_update = function(self,elapsed)
          local remain = self.time_remaining
          local link = self.data[1]
          self.text:SetText(string.format(L["Bid Call for %s [%ds]"],link,remain))
        end,
        buttons = {
          { -- MainSpec
            text = msbid_icon,--L["Bid Mainspec"],
            on_click = function(self, button, down)
              local data = self.data
              local masterlooter = data[2]
              local roll = data[3]
              if roll then
                RandomRoll("1", "100")
              else
                SendChatMessage("+","WHISPER",nil,masterlooter)
              end
              LD:Dismiss(addonName.."DialogMemberBid")
            end,
          },
          { -- OffSpec
            text = osbid_icon,--L["Bid Offspec"],
            on_click = function(self, button, down)
              local data = self.data
              local masterlooter = data[2]
              local roll = data[3]
              if roll then
                RandomRoll("1", "99")
              else
                SendChatMessage("-","WHISPER",nil,masterlooter)
              end
              LD:Dismiss(addonName.."DialogMemberBid")
            end,
          },
          { -- PR Veto
            text = prveto_icon,--L["Use PR"],
            on_click = function(self, button, down)
              local data = self.data
              local masterlooter = data[2]
              local prveto = data[4]
              if prveto then
                SendChatMessage("+","WHISPER",nil,masterlooter)
              end
              LD:Dismiss(addonName.."DialogMemberBid")
            end,
          },
          { -- Transmog
            text = xbid_icon, -- [["Transmog"]]
            on_click = function(self, button, down)
              local data = self.data
              local xmog = data[5]
              if xmog then
                RandomRoll("1", "69")
              end
              LD:Dismiss(addonName.."DialogMemberBid")
            end,
          }
        },
      }
    elseif id == "DialogMemberRoll" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        is_exclusive = true,
        duration = 30,
        text = L["Bid Call for %s [%ds]"],
        width = 360,
        on_show = function(self)
          local link, xmog = unpack(self.data)
          self.text:SetText(string.format(L["Bid Call for %s [%ds]"],link,self.duration))
          self:SetScript("OnEnter", function(f)
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
          end)
          self:SetScript("OnLeave", function(f)
            if GameTooltip:IsOwned(f) then
              GameTooltip_Hide()
            end
          end)
          if not bepgp:IsHooked(self, "OnHide") then
            bepgp:HookScript(self,"OnHide",function(f)
              if GameTooltip:IsOwned(f) then
                GameTooltip_Hide()
              end
            end)
          end
          if xmog then
            self.buttons[3]:Show()
          else
            self.buttons[3]:Hide()
          end
          self:Resize()
        end,
        on_update = function(self,elapsed)
          local remain = self.time_remaining
          local link = unpack(self.data)
          self.text:SetText(string.format(L["Bid Call for %s [%ds]"],link,remain))
        end,
        buttons = {
          { -- MainSpec
            text = L["Roll MS/Reserve"],
            on_click = function(self, button, down)
              RandomRoll("1", "100")
              LD:Dismiss(addonName.."DialogMemberRoll")
            end,
          },
          { -- OffSpec
            text = L["Roll OS/Sidegrade"],
            on_click = function(self, button, down)
              RandomRoll("1", "99")
              LD:Dismiss(addonName.."DialogMemberRoll")
            end,
          },
          { -- Transmog
            text = L["Transmog"],
            on_click = function(self, button, down)
              RandomRoll("1", "69")
              LD:Dismiss(addonName.."DialogMemberRoll")
            end,
          }
        },
      }
    elseif id == "DialogSetMain" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["Set your main to be able to participate in Standby List EPGP Checks."],
        on_show = function(self)
          self.text:SetText(L["Set your main to be able to participate in Standby List EPGP Checks."])
        end,
        editboxes = {
          {
            on_enter_pressed = function(self)
              local main = self:GetText()
              main = bepgp:Capitalize(main)
              local name, class = bepgp:verifyGuildMember(main)
              if name then
                bepgp.db.profile.main = name
              end
              LD:Dismiss(addonName.."DialogSetMain")
            end,
            on_escape_pressed = function(self)
              self:ClearFocus()
            end,
            on_show = function(self)
              self:SetText(bepgp.db.profile.main or "")
              self:SetFocus()
            end,
            text = bepgp.db.profile.main or "",
          },
        },
        buttons = {
          {
            text = _G.ACCEPT,
            on_click = function(self, button, down)
              local main = self.editboxes[1]:GetText()
              main = bepgp:Capitalize(main)
              local name, class = bepgp:verifyGuildMember(main)
              if name then
                bepgp.db.profile.main = name
              end
              LD:Dismiss(addonName.."DialogSetMain")
            end,
          },
        },
      }
    elseif id == "DialogWhitelist" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        is_exclusive = true,
        text = L["%s wants to %s."],
        on_show = function(self)
          local data = self.data
          local func = data[1]
          local grant
          if func == "GrantLootAdmin" then
            grant = L["Get Loot Admin"]
          elseif func == "GrantSizeToggle" then
            grant = L["Change Raid Size"]
          elseif func == "GrantDiffToggle" then
            grant = L["Change Raid Difficulty"]
          end
          local name = data[2]
          local arg1 = data[3]
          self.text:SetText(L["%s wants to %s."]:format(name,grant))
        end,
        buttons = {
          {
            text = _G.ACCEPT,
            on_click = function(self, button, down)
              local data = self.data
              local name = data[2]
              local arg1 = data[3]
              local func = bepgp[data[1]]
              if data.save then
                bepgp.db.char.whitelist[name] = true
              else
                whitelist[name] = true
              end
              func(bepgp,name,arg1)
              LD:Dismiss(addonName.."DialogWhitelist")
            end,
          },
          {
            text = _G.CANCEL,
            on_click = function(self, button, down)
              local data = self.data
              LD:Dismiss(addonName.."DialogWhitelist")
            end
          },
        },
        checkboxes = {
          {
            label = L["Auto-approve\nin the future"],
            get_value = function(self)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              local name = data[2]
              if data.save or bepgp.db.char.whitelist[name] then
                return true
              else
                return false
              end
            end,
            set_value = function(self, button, down)
              local dialog = self:GetParent():GetParent()
              local data = dialog.data
              data.save = not data.save
            end,
          },
        },
      }
    elseif id == "DialogClearLoot" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["There are %d loot drops stored. It is recommended to clear loot info before a new raid. Do you want to clear it now?"],
        on_show = function(self)
          self.text:SetText(L["There are %d loot drops stored. It is recommended to clear loot info before a new raid. Do you want to clear it now?"]:format(self.data))
        end,
        on_cancel = function(self)
          local data = self.data
          bepgp:Print(L["Loot info can be cleared at any time from the loot window or '/bastionloot clearloot' command"])
        end,
        buttons = {
          {
            text = _G.YES,
            on_click = function(self, button, down)
              local loot = bepgp:GetModule(addonName.."_loot",true)
              if loot then
                loot:Clear()
              end
              LD:Dismiss(addonName.."DialogClearLoot")
            end,
          },
          {
            text = L["Show me"],
            on_click = function(self, button, down)
              local loot = bepgp:GetModule(addonName.."_loot",true)
              if loot then
                loot:Toggle()
              end
              LD:Dismiss(addonName.."DialogClearLoot")
              bepgp:Print(L["Loot info can be cleared at any time from the loot window or '/bastionloot clearloot' command"])
            end,
          },
        },
      }
    elseif id == "DialogStandbyCheck" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["Standby AFKCheck. Are you available? |cff00ff00%0d|rsec."],
        on_show = function(self)
          self.text:SetText(L["Standby AFKCheck. Are you available? |cff00ff00%0d|rsec."]:format(self.data))
        end,
        on_cancel = function(self)
          local data = self.data
          bepgp:Print(L["AFK Check Standby"])
        end,
        on_update = function(self,elapsed)
          self.data = self.data - elapsed
          self.text:SetText(L["Standby AFKCheck. Are you available? |cff00ff00%0d|rsec."]:format(self.data))
        end,
        duration = bepgp.VARS.timeout,
        buttons = {
          {
            text = _G.YES,
            on_click = function(self, button, down)
              local standby = bepgp:GetModule(addonName.."_standby",true)
              if standby then
                standby:sendCheckResponse()
              end
              LD:Dismiss(addonName.."DialogStandbyCheck")
            end,
          },
          {
            text = _G.NO,
            on_click = function(self, button, down)
              LD:Dismiss(addonName.."DialogStandbyCheck")
            end,
          },
        },
      }
    elseif id == "DialogResetPoints" then
      self._dialogTemplates[key] = {
        hide_on_escape = true,
        show_while_dead = true,
        text = L["|cffff0000Are you sure you want to wipe all EPGP data?|r"],
        buttons = {
          {
            text = _G.YES,
            on_click = function(self, button, down)
              bepgp:wipe_epgp()
            end,
          },
          {
            text = _G.CANCEL,
            on_click = function(self, button, down)
              LD:Dismiss(addonName.."DialogResetPoints")
            end,
          },
        }
      }
    end
  end
  return self._dialogTemplates[key]
end

function bepgp:OnInitialize() -- 1. ADDON_LOADED
  -- guild specific stuff should go in profile named after guild
  -- player specific in char
  strlen = string.utf8len or string.len
  self._versionString = bepgp.GetAddOnMetadata(addonName,"Version")
  self._websiteString = bepgp.GetAddOnMetadata(addonName,"X-Website")
  self._labelfull = string.format("%s %s",label,self._versionString)
  if self._classic then
    self.db = LibStub("AceDB-3.0"):New("BastionEPGPDB", defaults)
  else
    self.db = LibStub("AceDB-3.0"):New("BastionLootDB", defaults)
  end
  self:options()
  self._options.args.profile = ADBO:GetOptionsTable(self.db)
  self._options.args.profile.guiHidden = true
  self._options.args.profile.cmdHidden = true
  AC:RegisterOptionsTable(addonName.."_cmd", self.cmdtable, {"bastionloot"})
  AC:RegisterOptionsTable(addonName, self._options)
  self.blizzoptions = ACD:AddToBlizOptions(addonName,nil,nil,"general")
  self.blizzoptions.profile = ACD:AddToBlizOptions(addonName, "Profiles", addonName, "profile")
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
  LDBO.type = "launcher"
  LDBO.text = label
  LDBO.label = string.format("%s %s",addonName,self._versionString)
  LDBO.icon = icons.epgp
  LDBO.OnClick = bepgp.OnLDBClick
  LDBO.OnTooltipShow = bepgp.OnLDBTooltipShow
  LDI:Register(addonName, LDBO, bepgp.db.profile.minimap)

  -- upgrade patches
  self:applyUpgradePatch("3.4.2-groupcache")

end

function bepgp:OnEnable(reset) -- 2. PLAYER_LOGIN
  local _
  _, self._playerRealm = UnitFullName("player")
  self._playerFullName = string.format("%s-%s", self._playerName, self._playerRealm)
  self:setPlayerName()
  if GetMaxPlayerLevel and bepgp.VARS.minlevel > GetMaxPlayerLevel() then
    bepgp.VARS.minlevel = GetMaxPlayerLevel()
  end
  if reset then self._initdone = nil end
  RAID_CLASS_COLORS = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)
  if IsInGuild() then
    local guildname = GetGuildInfo("player")
    if not guildname then
      self:safeGuildRoster()
    end
    self._playerLevel = UnitLevel("player")
    if self._playerLevel and self._playerLevel < MAX_PLAYER_LEVEL then
      self:RegisterEvent("PLAYER_LEVEL_UP")
    end
    self._bucketGuildRoster = self:RegisterBucketEvent("GUILD_ROSTER_UPDATE",(bepgp.db.char.rosterthrottle or bepgp.VARS.rosterthrottle))
    local comms = self:GetModule(addonName.."_comms",true)
    if comms and reset then
      comms:Init(guildname)
    end
  else
    bepgp:RegisterEvent("PLAYER_GUILD_UPDATE")
    -- TODO: Refactor parts that shouldn't be reliant on guild to initialize properly without a guild
    bepgp:ScheduleTimer("deferredInit",(bepgp.db.char.rosterthrottle or bepgp.VARS.rosterthrottle))
  end
  self:SetMode(self.db.char.mode)
  if self:table_count(self.VARS.autoloot) > 0 then
    bepgp:RegisterEvent("LOOT_READY", "autoLoot")
  end
  if bepgp.db.char.lootannounce or bepgp.db.char.favalert then
    bepgp:RegisterEvent("LOOT_OPENED", "lootAnnounce")
    if bepgp.db.char.favalert then
      bepgp:RegisterEvent("START_LOOT_ROLL", "favAlert")
    end
  end
  self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "favCheckRemove")
  if not bepgp.cleuParser then -- re-use if someone did /disable /enable
    bepgp.cleuParser = CreateFrame("Frame")
    bepgp.cleuParser.OnEvent = function(frame, event, ...)
      bepgp.COMBAT_LOG_EVENT_UNFILTERED(bepgp, event, ...) -- make sure we get a proper 'self'
    end
    bepgp.cleuParser:SetScript("OnEvent", bepgp.cleuParser.OnEvent)
  end
  bepgp.cleuParser:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  bepgp:RegisterEvent("LOOT_SLOT_CLEARED", "checkPendingLoot")
  bepgp:RegisterEvent("CHAT_MSG_SYSTEM","funnyRoll")
end

function bepgp:OnDisable() -- ADHOC

end

function bepgp:RefreshConfig()

end

local patches = {
  ["3.4.2-groupcache"] = {
    storage="char",
    code=[[
    local groupcache = BastionLoot.db.char.groupcache
    if type(groupcache)=="table" then
      for name, nameinfo in pairs(groupcache) do
        if not nameinfo["eclass"] then
          groupcache[name] = nil
        end
      end
    end
    ]],},
}
function bepgp:applyUpgradePatch(patchname)
  local storage, code = patches[patchname].storage, patches[patchname].code
  if not self.db[storage].patches[patchname] then
    local func, errorMsg = loadstring(code, patchname)
    if func then
      func()
      self.db[storage].patches[patchname] = true
      self:debugPrint(format("Applied %s patch",patchname))
    else
      self:debugPrint(errorMsg)
    end
  end
end

function bepgp:SetMode(mode)
  if bepgp._SUSPEND then
    bepgp._SUSPEND = false
    bepgp._dda_options.args.stop.name = stop_icon
    bepgp._dda_options.args.stop.desc = L["Suspend"]
    bepgp._ddm_options.args.stop.name = stop_icon
    bepgp._ddm_options.args.stop.desc = L["Suspend"]
  end
  self:Print(string.format(L["Mode set to %s."],modes[mode]))
  LDBO.icon = icons[mode]
  LDBO.text = string.format("%s [%s]",label,modes[mode])
  local w, h = bepgp:optionSize()
  if ACD.OpenFrames[addonName] then
    local status = ACD:GetStatusTable(addonName)
    status.height = h
    ACD:Open(addonName)
  end
  ACD:SetDefaultSize(addonName,w,h)
  if self:GroupStatus()=="RAID" and self:lootMaster() then
    local addonMsg = string.format("MODE;%s;%s",mode,self._playerName)
    self:addonMessage(addonMsg,"RAID")
  end
end

function bepgp:Suspend(flag)
  bepgp._SUSPEND = not bepgp._SUSPEND
  if bepgp._SUSPEND then
    bepgp:Print(L["Bid processing suspended. (session only)"])
    LDBO.icon = icons.suspend
    LDBO.text = string.format("%s [%s]",label,modes.suspend)
    bepgp._dda_options.args.stop.name = resume_icon
    bepgp._dda_options.args.stop.desc = L["Resume"]
    bepgp._ddm_options.args.stop.name = resume_icon
    bepgp._ddm_options.args.stop.desc = L["Resume"]
  else
    bepgp:Print(L["Bid processing resumed."])
    local mode = bepgp.db.char.mode
    LDBO.icon = icons[mode]
    LDBO.text = string.format("%s [%s]",label,modes[mode])
    bepgp._dda_options.args.stop.name = stop_icon
    bepgp._dda_options.args.stop.desc = L["Suspend"]
    bepgp._ddm_options.args.stop.name = stop_icon
    bepgp._ddm_options.args.stop.desc = L["Suspend"]
  end
end

function bepgp:guildInfoSettings()
  local now = GetTime()
  if not self._lastInfoScan or (self._lastInfoScan and (now - self._lastInfoScan) > self.VARS.timeout) then
    local ginfotxt = GetGuildInfoText()
    if ginfotxt and ginfotxt ~= "" and ginfotxt ~= GUILD_INFO_EDITLABEL then
      local system = self.db.profile.system
      local pricesystem = ginfotxt:match("{([^%c{}]+)}")
      if pricesystem and pricesystem ~= system then
        self.db.profile.system = pricesystem
        self:SetPriceSystem(GUILD_INFORMATION)
        self._lastInfoScan = now
      end
    end
  end
end

function bepgp:deferredInit(guildname)
  if self._initdone then return end
  local realmname = GetRealmName()
  if not realmname then return end
  local panelHeader = self:admin() and L["Admin Options"] or L["Member Options"]
  if guildname then
    self._guildName = guildname
    self:guildInfoSettings()
    self:guildBranding()

    local profilekey = guildname.." - "..realmname
    self._options.name = self._labelfull
    self._options.args.general.name = panelHeader
    self.db:SetProfile(profilekey)
    -- register our dialogs
    LD:Register(addonName.."DialogMemberPoints", self:templateCache("DialogMemberPoints"))
    LD:Register(addonName.."DialogGroupPoints", self:templateCache("DialogGroupPoints"))
    LD:Register(addonName.."DialogSetMain", self:templateCache("DialogSetMain"))
    LD:Register(addonName.."DialogWhitelist", self:templateCache("DialogWhitelist"))
    LD:Register(addonName.."DialogClearLoot", self:templateCache("DialogClearLoot"))
    LD:Register(addonName.."DialogResetPoints", self:templateCache("DialogResetPoints"))
    self:tooltipHook()
    -- handle unnamed frames Esc
    if not self:IsHooked("CloseSpecialWindows") then
      self:RawHook("CloseSpecialWindows",true)
    end
    -- comms
    bepgp:RegisterComm(bepgp.VARS.prefix)
    -- monitor officernote changes
    if self:admin() then
      if not self:IsHooked("GuildRosterSetOfficerNote") then
        self:RawHook("GuildRosterSetOfficerNote",true)
      end
      if C_GuildInfo and C_GuildInfo.SetNote then
        if not self:IsHooked(C_GuildInfo, "SetNote") then
          self:SecureHook(C_GuildInfo, "SetNote", "C_GuildInfo_SetNote")
        end
      end
    end
    -- version check
    self:parseVersion(bepgp._versionString)
    local major_ver = self._version.major
    local addonMsg = string.format("VERSION;%s;%d",bepgp._versionString,major_ver)
    self:addonMessage(addonMsg,"GUILD")
    -- main
    self:testMain()
    -- group status change
    self:RegisterEvent("GROUP_ROSTER_UPDATE","groupStatusRouter")
    self:RegisterEvent("GROUP_JOINED","groupStatusRouter")
    self:RegisterEvent("GROUP_LEFT","groupStatusRouter")
    self:RegisterEvent("PLAYER_ENTERING_WORLD","groupStatusRouter")
    self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED","groupStatusRouter")
    -- set price system
    bepgp:SetPriceSystem()
    -- register whisper responder
    self:setupResponder()
    -- set roll filter
    self:setupRollFilter()

    self._initdone = true
    self:SendMessage(addonName.."_INIT_DONE")
  else
    local profilekey = realmname
    self._options.name = self._labelfull
    self._options.args.general.name = panelHeader
    self.db:SetProfile(profilekey)
    self:tooltipHook()
    -- handle unnamed frames Esc
    self:RawHook("CloseSpecialWindows",true)
    -- set price system
    bepgp:SetPriceSystem()
    -- set roll filter
    self:setupRollFilter()

    self._initdone = true
    self:SendMessage(addonName.."_INIT_DONE")
  end
  self:UnregisterBucket(self._bucketGuildRoster)
  self._bucketGuildRoster = self:RegisterBucketEvent("GUILD_ROSTER_UPDATE",bepgp.VARS.rosterthrottle)
  -- 2.5.1.39170 masterlooterframe bug workaround
  local oMasterLooterFrame_Show = _G.MasterLooterFrame_Show
  _G.MasterLooterFrame_Show = function(...)
    MasterLooterFrame:ClearAllPoints()
    oMasterLooterFrame_Show(...)
  end
  hooksecurefunc("MasterLooterFrame_OnHide", function(...)
    MasterLooterFrame:ClearAllPoints()
  end)
  -- workaround end
end

function bepgp:tooltipHook()
  local tipOptionGroup = bepgp.db.char.tooltip
  local status = tipOptionGroup.prinfo or tipOptionGroup.mlinfo or tipOptionGroup.favinfo or tipOptionGroup.useinfo or tipOptionGroup.tkninfo
  if status then
    -- tooltip
    if not self:IsHooked(GameTooltip, "OnTooltipSetItem") then
      self:HookScript(GameTooltip, "OnTooltipSetItem", "AddTipInfo")
    end
    if not self:IsHooked(ItemRefTooltip, "OnTooltipSetItem") then
      self:HookScript(ItemRefTooltip, "OnTooltipSetItem", "AddTipInfo")
    end
  else
    -- tooltip
    if self:IsHooked(GameTooltip, "OnTooltipSetItem") then
      self:Unhook(GameTooltip, "OnTooltipSetItem")
    end
    if self:IsHooked(ItemRefTooltip, "OnTooltipSetItem") then
      self:Unhook(ItemRefTooltip, "OnTooltipSetItem")
    end
  end
  if tipOptionGroup.tkninfo then
    self:RegisterEvent("MODIFIER_STATE_CHANGED", "TipItemSwap")
  else
    self:UnregisterEvent("MODIFIER_STATE_CHANGED")
  end
  if not self:IsHooked(GameTooltip, "OnTooltipSetUnit") then
    self:HookScript(GameTooltip, "OnTooltipSetUnit", "AddTipLootInfo")
  end
end

function bepgp:TipItemSwap(event,button,state)
  if not state then return end
  local preview_pressed = IsModifiedClick("DRESSUP")
  if preview_pressed then
    local name, link = GameTooltip:GetItem()
    if name and link then
      local item = Item:CreateFromItemLink(link)
      local itemid = item:GetItemID()
      if item_swaps[itemid] then
        GameTooltip:ClearLines()
        GameTooltip:SetHyperlink(item_swaps[itemid])
      end
    end
    name, link = ItemRefTooltip:GetItem()
    if name and link then
      local item = Item:CreateFromItemLink(link)
      local itemid = item:GetItemID()
      if item_swaps[itemid] then
        ItemRefTooltip:ClearLines()
        ItemRefTooltip:SetHyperlink(item_swaps[itemid])
      end
    end
  end
end

function bepgp:AddTipLootInfo(tooltip,...)
  local name, unitid = tooltip:GetUnit()
  local guid
  if name and unitid then
    guid = UnitGUID(unitid)
  end
  if not guid then return end
  local looters
  if pendingLoot[guid] then
    looters = bepgp._playerName
  end
  if pendingLooters[guid] and bepgp:table_count(pendingLooters[guid])>0 then
    for looter,hasLoot in pairs(pendingLooters[guid]) do
      if hasLoot then
        looters = looters and (looters..", "..looter) or looter
      end
    end
  end
  if looters then
    tooltip:AddDoubleLine(L["|cff33ff99Pending Loot:|r"], looters)
  end
end

function bepgp:AddTipInfo(tooltip,...)
  local name, link = tooltip:GetItem()
  local tipOptionGroup = bepgp.db.char.tooltip
  if name and link then
    local mode_epgp = bepgp.db.char.mode == "epgp"
    local mode_plusroll = bepgp.db.char.mode == "plusroll"
    local price, tier, useful = self:GetPrice(link, self.db.profile.progress)
    local roll_admin = self:GroupStatus()=="RAID" and self:lootMaster()
    local is_admin = self:admin()
    local owner = tooltip:GetOwner()
    local item = Item:CreateFromItemLink(link)
    local itemid = item:GetItemID()
    if price then
      if tipOptionGroup.prinfo then
        local off_price = math.floor(price*self.db.profile.discount)
        local ep,gp = (self:get_ep(self._playerName) or 0), (self:get_gp(self._playerName) or bepgp.VARS.basegp)
        local pr,new_pr,new_pr_off = ep/gp, ep/(gp+price), ep/(gp+off_price)
        local pr_delta = new_pr - pr
        local pr_delta_off = new_pr_off - pr
        local textRight2 = string.format(L["pr:|cffff0000%.02f|r(%.02f) pr_os:|cffff0000%.02f|r(%.02f)"],pr_delta,new_pr,pr_delta_off,new_pr_off)
        local textRight = string.format(L["gp:|cff32cd32%d|r gp_os:|cff20b2aa%d|r"],price,off_price)
        tooltip:AddDoubleLine(label, textRight)
        local price2 = type(useful)=="number" and useful or nil
        if price2 then
          local off_price2 = math.floor(price2*self.db.profile.discount)
          local textRight3 = string.format(L["gp:|cff32cd32%d|r gp_os:|cff20b2aa%d|r"],price2,off_price2)
          tooltip:AddDoubleLine(L["Class/Role Discount"],textRight3)
        end
        if (ep > 0) and (gp ~= bepgp.VARS.basegp) then
          tooltip:AddDoubleLine(" ", textRight2)
        end
      end
      if tipOptionGroup.mlinfo then
        if roll_admin and is_admin and mode_epgp then
          if owner then
            local ownerName = owner.GetName and owner:GetName() or ""
            if owner._bepgpclicks or owner.BGR or strfind(ownerName,"BetterBagsItemButton") then
              tooltip:AddDoubleLine(C:Yellow(L["Alt Click"]), C:Orange(L["Call for: MS/OS"]))
            end
          end
        end
      end
    end
    if tipOptionGroup.mlinfo and (roll_admin and mode_plusroll) then
      if owner then
        local ownerName = owner.GetName and owner:GetName() or ""
        if owner._bepgprollclicks or owner.BGR or strfind(ownerName,"BetterBagsItemButton") then
          tooltip:AddDoubleLine(C:Yellow(L["Alt Click"]), C:Orange(L["Call for Rolls"]))
        end
      end
    end
    if tipOptionGroup.favinfo and (owner and (owner.encounterID and owner.itemID)) then -- encounter journal
      tooltip:AddDoubleLine(C:Yellow(L["Alt Click"]), C:Orange(L["Add Favorite"]))
    end
    local favorite = self.db.char.favorites[itemid]
    if tipOptionGroup.favinfo and favorite then
      tooltip:AddLine(self._favmap[favorite])
    end
    if tipOptionGroup.tkninfo then
      if self.ItemUpgradeString then
        local token_markup = self:ItemUpgradeString(itemid)
        if token_markup then
          tooltip:AddDoubleLine(" ",token_markup)
        end
      end
      if self.TokensItemString and self.RewardItemString then
        wipe(item_swaps)
        local required_line = self:TokensItemString(itemid)
        local reward_line = self:RewardItemString(itemid)
        if required_line then
          tooltip:AddDoubleLine(_G.CTRL_KEY,_G.SOURCE..required_line)
          item_swaps[itemid] = required_line
        elseif reward_line then
          tooltip:AddDoubleLine(_G.CTRL_KEY,L["Token for:"]..reward_line)
          item_swaps[itemid] = reward_line
        end
      end
    end
    if tipOptionGroup.useinfo and (type(useful)=="table" and #(useful)>0) then
      local line1,line2,line3 = "","",""
      for prio,class_specs in ipairs(useful) do
        if prio == 1 then -- 90%+ of top
          for k=1,#(class_specs),2 do
            local class,spec = class_specs[k],class_specs[k+1]
            local classspecstring = self:ClassSpecString(class,spec)
            if line1 == "" then
              line1 = classspecstring
            else
              line1 = line1 .. ", " .. classspecstring
            end
          end
          tooltip:AddDoubleLine(string.format("|cff33ff99%s|r",L["Useful for"]),line1)
        elseif prio == 2 then --80%+ of top
          for k=1,#(class_specs),2 do
            local class,spec = class_specs[k],class_specs[k+1]
            local classspecstring = self:ClassSpecString(class,spec)
            if line2 == "" then
              line2 = classspecstring
            else
              line2 = line2 .. ", " .. classspecstring
            end
          end
          tooltip:AddDoubleLine(" ",line2)
        elseif prio == 3 then --70%+ of top
          for k=1,#(class_specs),2 do
            local class,spec = class_specs[k],class_specs[k+1]
            local classspecstring = self:ClassSpecString(class,spec)
            if line3 == "" then
              line3 = classspecstring
            else
              line3 = line3 .. ", " .. classspecstring
            end
          end
          tooltip:AddDoubleLine(" ",line3)
        end
      end
    end
  end
end

function bepgp:getInteractInfo()
  local name
  local guid = UnitGUID("npc")
  if guid then
    name = GetUnitName("npc",bepgp.db.profile.fullnames)
  end
  if guid and name then
    return name, guid
  end
  local guid = UnitExists("target") and UnitGUID("target")
  if guid then
    name = GetUnitName("target",bepgp.db.profile.fullnames)
  end
  if guid and name then
    return name, guid
  end
  return _G.UNKNOWNOBJECT, _G.NONE
end

function bepgp:getLootSourceName(guidType, guidID)
  local objectName = object_names[guidID]
  if objectName then
    return format("%s %s%q",_G.LOOT_NOUN, _G.FROM, objectName)
  else
    return format("%s %s%s=%d",_G.LOOT_NOUN, _G.FROM, guidType, guidID)
  end
end

function bepgp:lootAnnounce(event)
  local numLoot = GetNumLootItems()
  if numLoot == 0 then return end
  local isML = bepgp:lootMaster()
  local inGroup = IsInGroup()
  local threshold = GetLootThreshold()
  local tryName, tryGUID = bepgp:getInteractInfo()
  local lootsourceGUID
  for slot=1, numLoot do
    if LootSlotHasItem(slot) then
      local slotType = GetLootSlotType(slot)
      if slotType == LOOT_SLOT_ITEM then
        local itemLink = GetLootSlotLink(slot)
        if (itemLink) then
          local _,_,_,itemID = bepgp:getItemData(itemLink)
          -- favorites alert
          if bepgp.db.char.favalert then
            if itemID and bepgp.db.char.favorites[itemID] then
              bepgp:Alert(string.format(L["BastionLoot Favorite: %s"],itemLink))
            end
          end
          -- loot announce
          local lootIcon, lootName, _, _, lootQuality = GetLootSlotInfo(slot)
          if bepgp.db.char.lootannounce and isML and inGroup and (lootQuality >= threshold) then
            -- drag next block here when done testing
            lootsourceGUID = GetLootSourceInfo(slot) -- this will need changing if AoE loot is implemented
            local guidType, _, _, _, _, guidID = ("-"):split(lootsourceGUID)
            bepgp._announceDone = bepgp._announceDone or {}
            if not bepgp._announceDone[lootsourceGUID] then
              if lootsourceGUID == tryGUID then
                bepgp._announceDone[lootsourceGUID] = format("%s %s%q",_G.LOOT_NOUN, _G.FROM, tryName)
              else
                bepgp._announceDone[lootsourceGUID] = bepgp:getLootSourceName(guidType, tonumber(guidID))
              end
            end
            bepgp._announceItems = bepgp._announceItems or {}
            tinsert(bepgp._announceItems,itemLink)
          end
          -- testing block
        end
      end
    end
  end
  if bepgp._announceItems and #bepgp._announceItems > 0 then
    if type(bepgp._announceDone[lootsourceGUID])=="string" then
      bepgp:safeAudience(bepgp._announceDone[lootsourceGUID])
      for i,link in ipairs(bepgp._announceItems) do
        local msg = format("%2d.%s",i,link)
        bepgp:safeAudience(msg)
      end
    end
    for k,v in pairs(bepgp._announceDone) do
      bepgp._announceDone[k] = true
    end
    bepgp._announceItems = nil
  end
end

function bepgp:favAlert(event, rollID, rollTime, lootHandle)
  if not bepgp.db.char.favalert then return end
  local texture, name, count, quality, bindOnPickUp, canNeed, canGreed = GetLootRollItemInfo(rollID)
  if (name) and (canNeed or canGreed) then
    local link = GetLootRollItemLink(rollID)
    local _, _, _, itemID = bepgp:getItemData(link)
    if itemID and bepgp.db.char.favorites[itemID] then
      bepgp:Alert(string.format(L["BastionLoot Favorite: %s"],link))
    end
  end
end

function bepgp:favCheckRemove(event, slotid, emptied)
  if not emptied then
    local itemID = GetInventoryItemID("player", slotid)
    local itemLink = GetInventoryItemLink("player", slotid)
    if itemID and bepgp.db.char.favorites[itemID] then
      local browser = self:GetModule(addonName.."_browser",true)
      if browser then
        browser:favoriteClear(itemID)
        local msg = string.format(L["%s removed from Favorites"],itemLink)
        self:Print(msg)
      end
    end
  end
end

function bepgp:autoLoot(event,auto)
  local numLoot = GetNumLootItems()
  if numLoot == 0 then return end
  if auto or (GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")) then
    return
  end
  for slot = numLoot,1,-1 do
    if LootSlotHasItem(slot) then
      local itemLink = GetLootSlotLink(slot)
      local slotType = GetLootSlotType(slot)
      if slotType == LOOT_SLOT_CURRENCY then
        if (itemLink) then
          local _,_,_,currencyID = self:getCurrencyData(itemLink)
          local autolootCurrency = bepgp.VARS.autoloot[currencyID] and bepgp.VARS.autoloot[currencyID] == "currency"
          if currencyID and autolootCurrency then
            LootSlot(slot)
            ConfirmLootSlot(slot)
          end
        end
      else
        if (itemLink) then
          local _,_,_,itemID = self:getItemData(itemLink)
          local autolootItem = bepgp.VARS.autoloot[itemID] and bepgp.VARS.autoloot[itemID] ~= "currency"
          if itemID and autolootItem then
            LootSlot(slot)
            ConfirmLootSlot(slot)
            local dialog = StaticPopup_FindVisible("LOOT_BIND")
            if dialog then _G[dialog:GetName().."Button1"]:Click() end
          end
        end
      end
    end
  end
end

function bepgp:funnyRoll(event,...)
  if not IsInRaid() then return end
  local msg = ...
  local who, roll, low, high = DF.Deformat(msg, RANDOM_ROLL_RESULT)
  if not who or (who == "") then return end
  who = bepgp:Ambiguate(who)
  if who ~= self._playerName then return end
  if roll and tonumber(roll) == 69 then
    SendChatMessage(L["says.. Nice!"],"EMOTE")
  end
end

local recipients = {}
function bepgp:sendThrottle(recipient)
  local now = GetTime()
  local prev = recipients[recipient]
  recipients[recipient] = now
  if prev and ((now-prev) < TOOLTIP_UPDATE_TIME) then
    return true
  end
end

local function epgpResponder(frame, event, text, sender, ...)
  if event == "CHAT_MSG_WHISPER" then
    local query, name = text:match("^[%c%s]*(![pP][rR])[%c%s%p]*([^%c%d%p%s]*)")
    local sender_stripped = bepgp:Ambiguate(sender)
    local allies = bepgp.db.profile.allies
    local _,perms = bepgp:getGuildPermissions()
    if perms.OFFICER then
      if query and (query:upper()=="!PR") then
        local guild_name, _, _, guild_officernote = bepgp:verifyGuildMember(sender_stripped,true,true)
        if name and strlen(name)>=2 then -- query a 3rd player
          name = bepgp:Capitalize(name)
          local g_name, _, _, g_officernote = bepgp:verifyGuildMember(name,true) -- is it a guild member
          if g_name then
            local ep,gp
            local main_name, _, _, main_onote = bepgp:parseAlt(g_name, g_officernote)
            if main_name then
              ep = bepgp:get_ep(main_name,main_onote)
              gp = bepgp:get_gp(main_name,main_onote)
            else
              ep = bepgp:get_ep(g_name,g_officernote)
              gp = bepgp:get_gp(g_name,g_officernote)
            end
            if ep and gp then
              local pr = ep/gp
              local msg = string.format(L["{bepgp}%s has: %d EP %d GP %.03f PR."], name, ep,gp,pr)
              if not bepgp:sendThrottle(sender_stripped) then
                SendChatMessage(msg,"WHISPER",nil,sender_stripped)
              end
              return true
            end
          elseif allies[name] then -- is it an ally player
            local ep = bepgp:get_ep(name)
            local gp = bepgp:get_gp(name)
            if ep and gp then
              local pr = ep/gp
              local msg = string.format(L["{bepgp}%s has: %d EP %d GP %.03f PR."], name, ep,gp,pr)
              if not bepgp:sendThrottle(sender_stripped) then
                SendChatMessage(msg,"WHISPER",nil,sender_stripped)
              end
              return true
            end
          end
        else -- query sender
          if guild_name then --
            local ep = bepgp:get_ep(guild_name,guild_officernote)
            local gp = bepgp:get_gp(guild_name,guild_officernote)
            if ep and gp then
              local pr = ep/gp
              local msg = string.format(L["{bepgp}You have: %d EP %d GP %.03f PR"], ep,gp,pr)
              if not bepgp:sendThrottle(sender_stripped) then
                SendChatMessage(msg,"WHISPER",nil,sender_stripped)
              end
              return true
            end
          elseif allies[sender_stripped] then -- is it from an ally
            local ep = bepgp:get_ep(sender_stripped)
            local gp = bepgp:get_gp(sender_stripped)
            if ep and gp then
              local pr = ep/gp
              local msg = string.format(L["{bepgp}You have: %d EP %d GP %.03f PR"], ep,gp,pr)
              if not bepgp:sendThrottle(sender_stripped) then
                SendChatMessage(msg,"WHISPER",nil,sender_stripped)
              end
              return true
            end
          end
        end
      end
    end
    return false, text, sender, ...
  elseif event == "CHAT_MSG_WHISPER_INFORM" then
    local epgp = text:match("^({bepgp}).*")
    if epgp then
      return true
    else
      return false, text, sender, ...
    end
  end
end

function bepgp:setupResponder()
  -- Hopefully anyone that can think of doing this
  -- also knows enough to not cause side-effects for filters coming after their own.
  local filters_incoming = ChatFrame_GetMessageEventFilters("CHAT_MSG_WHISPER")
  if filters_incoming and #(filters_incoming) > 0 then
    for index, filterFunc in next, filters_incoming do
      if ( filterFunc == epgpResponder ) then
        return
      end
    end
    tinsert(filters_incoming,1,epgpResponder)
  else
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", epgpResponder)
  end
  local filters_outgoing = ChatFrame_GetMessageEventFilters("CHAT_MSG_WHISPER_INFORM")
  if filters_outgoing and #(filters_outgoing) > 0 then
    for index, filterFunc in next, filters_outgoing do
      if ( filterFunc == epgpResponder ) then
        return
      end
    end
    tinsert(filters_outgoing,1,epgpResponder)
  else
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", epgpResponder)
  end
end

local function rollfilter(frame, event, text, sender, ...)
  local wrong_mode = bepgp.db.char.mode ~= "plusroll"
  local filter_off = not bepgp.db.char.rollfilter
  local not_raid = not IsInRaid()
  if wrong_mode or filter_off or not_raid then
    return false, text, sender, ...
  end
  local who, roll, low, high = DF.Deformat(text, RANDOM_ROLL_RESULT)
  if who then
    who = bepgp:Ambiguate(who)
    if who == bepgp._playerName then
      return false, text, sender, ...
    else
      return true
    end
  end
  return false, text, sender, ...
end

function bepgp:setupRollFilter()
  ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", rollfilter)
end

function bepgp:guildBranding()
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetWidth(64)
  f:SetHeight(64)
  f:SetPoint("CENTER",UIParent,"CENTER",0,0)

  local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = bepgp.GetGuildTabardFileNames()
  if ( not tabardEmblemUpper ) then
    tabardBackgroundUpper = "Textures\\GuildEmblems\\Background_49_TU_U"
    tabardBackgroundLower = "Textures\\GuildEmblems\\Background_49_TL_U"
  end

  f.bgUL = f:CreateTexture(nil, "BACKGROUND")
  f.bgUL:SetWidth(32)
  f.bgUL:SetHeight(32)
  f.bgUL:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
  f.bgUL:SetTexCoord(0.5,1,0,1)
  f.bgUR = f:CreateTexture(nil, "BACKGROUND")
  f.bgUR:SetWidth(32)
  f.bgUR:SetHeight(32)
  f.bgUR:SetPoint("LEFT", f.bgUL, "RIGHT", 0, 0)
  f.bgUR:SetTexCoord(1,0.5,0,1)
  f.bgBL = f:CreateTexture(nil, "BACKGROUND")
  f.bgBL:SetWidth(32)
  f.bgBL:SetHeight(32)
  f.bgBL:SetPoint("TOP", f.bgUL, "BOTTOM", 0, 0)
  f.bgBL:SetTexCoord(0.5,1,0,1)
  f.bgBR = f:CreateTexture(nil, "BACKGROUND")
  f.bgBR:SetWidth(32)
  f.bgBR:SetHeight(32)
  f.bgBR:SetPoint("LEFT", f.bgBL, "RIGHT", 0,0)
  f.bgBR:SetTexCoord(1,0.5,0,1)

  f.bdUL = f:CreateTexture(nil, "BORDER")
  f.bdUL:SetWidth(32)
  f.bdUL:SetHeight(32)
  f.bdUL:SetPoint("TOPLEFT", f.bgUL, "TOPLEFT", 0,0)
  f.bdUL:SetTexCoord(0.5,1,0,1)
  f.bdUR = f:CreateTexture(nil, "BORDER")
  f.bdUR:SetWidth(32)
  f.bdUR:SetHeight(32)
  f.bdUR:SetPoint("LEFT", f.bdUL, "RIGHT", 0,0)
  f.bdUR:SetTexCoord(1,0.5,0,1)
  f.bdBL = f:CreateTexture(nil, "BORDER")
  f.bdBL:SetWidth(32)
  f.bdBL:SetHeight(32)
  f.bdBL:SetPoint("TOP", f.bdUL, "BOTTOM", 0,0)
  f.bdBL:SetTexCoord(0.5,1,0,1)
  f.bdBR = f:CreateTexture(nil, "BORDER")
  f.bdBR:SetWidth(32)
  f.bdBR:SetHeight(32)
  f.bdBR:SetPoint("LEFT", f.bdBL, "RIGHT", 0,0)
  f.bdBR:SetTexCoord(1,0.5,0,1)

  f.emUL = f:CreateTexture(nil, "BORDER")
  f.emUL:SetWidth(32)
  f.emUL:SetHeight(32)
  f.emUL:SetPoint("TOPLEFT", f.bgUL, "TOPLEFT", 0,0)
  f.emUL:SetTexCoord(0.5,1,0,1)
  f.emUR = f:CreateTexture(nil, "BORDER")
  f.emUR:SetWidth(32)
  f.emUR:SetHeight(32)
  f.emUR:SetPoint("LEFT", f.bdUL, "RIGHT", 0,0)
  f.emUR:SetTexCoord(1,0.5,0,1)
  f.emBL = f:CreateTexture(nil, "BORDER")
  f.emBL:SetWidth(32)
  f.emBL:SetHeight(32)
  f.emBL:SetPoint("TOP", f.emUL, "BOTTOM", 0,0)
  f.emBL:SetTexCoord(0.5,1,0,1)
  f.emBR = f:CreateTexture(nil, "BORDER")
  f.emBR:SetWidth(32)
  f.emBR:SetHeight(32)
  f.emBR:SetPoint("LEFT", f.emBL, "RIGHT", 0,0)
  f.emBR:SetTexCoord(1,0.5,0,1)

  f.bgUL:SetTexture(tabardBackgroundUpper)
  f.bgUR:SetTexture(tabardBackgroundUpper)
  f.bgBL:SetTexture(tabardBackgroundLower)
  f.bgBR:SetTexture(tabardBackgroundLower)

  f.emUL:SetTexture(tabardEmblemUpper)
  f.emUR:SetTexture(tabardEmblemUpper)
  f.emBL:SetTexture(tabardEmblemLower)
  f.emBR:SetTexture(tabardEmblemLower)

  f.bdUL:SetTexture(tabardBorderUpper)
  f.bdUR:SetTexture(tabardBorderUpper)
  f.bdBL:SetTexture(tabardBorderLower)
  f.bdBR:SetTexture(tabardBorderLower)

  f.mask = f:CreateMaskTexture()
  f.mask:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  f.mask:SetSize(48,48)
  f.mask:SetPoint("CENTER", f, "CENTER", 0,0)
  f.bgUL:AddMaskTexture(f.mask)
  f.bgUR:AddMaskTexture(f.mask)
  f.bgBL:AddMaskTexture(f.mask)
  f.bgBR:AddMaskTexture(f.mask)
  f.bdUL:AddMaskTexture(f.mask)
  f.bdUR:AddMaskTexture(f.mask)
  f.bdBL:AddMaskTexture(f.mask)
  f.bdBR:AddMaskTexture(f.mask)

  f:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(bepgp._guildName)
    GameTooltip:AddLine(string.format(INSPECT_GUILD_NUM_MEMBERS,bepgp:table_count(bepgp.db.profile.guildcache)),1,1,1)
    GameTooltip:Show()
  end)
  f:SetScript("OnLeave",function(self)
    if GameTooltip:IsOwned(self) then
      GameTooltip_Hide()
    end
  end)
  self._guildLogo = f
  self._guildLogo:SetParent(self.blizzoptions)
  self._guildLogo:ClearAllPoints()
  self._guildLogo:SetPoint("TOPRIGHT", self.blizzoptions, "TOPRIGHT", 0,0)
  --self._guildLogo:SetIgnoreParentAlpha(true)
end

function bepgp:officerNoteTamper(name,index,prevnote)
  name = bepgp:Ambiguate(name)
  prevnote = prevnote or ""
  local oldtype, _, olddata, _, t1, t2, t3, t4 = bepgp:parseNote(prevnote,index)
  local oldmain, ally, ally_class, ally_ep, ally_gp, ep, gp
  local msg, admin_msg
  if oldtype == "alt" --[[and self.db.profile.altspool]] then
    oldmain = t1
  elseif oldtype == "standin" --[[and self.db.profile.allypool]] then
    ally, ally_class, ally_ep, ally_gp = t1, t2, t3, t4
  elseif oldtype == "epgp" then
    ep, gp = t1, t2
  end
  if oldmain then
    admin_msg = string.format(L["Manually modified %s\'s note. Previous main was %s"],name,oldmain)
    msg = string.format(L["|cffff0000Manually modified %s\'s note. Previous main was %s|r"],name,oldmain)
  elseif ally and ally_class then
    admin_msg = string.format(L["Manually modified %s\'s note. Previous ally info %s, %d:%d"],name,ally,(ally_ep or 0), (ally_gp or bepgp.VARS.basegp))
    msg = string.format(L["|cffff0000Manually modified %s\'s note. Previous ally info %s, %d:%d"],name,ally,(ally_ep or 0), (ally_gp or bepgp.VARS.basegp))
  elseif ep and gp then
    local oldepgp = string.format("{%d:%d}",ep,gp)
    admin_msg = string.format(L["Manually modified %s\'s note. EPGP was %s"],name,oldepgp)
    msg = string.format(L["|cffff0000Manually modified %s\'s note. EPGP was %s|r"],name,oldepgp)
  end
  if admin_msg then
    self:adminSay(admin_msg)
  end
  if msg then
    self:Print(msg)
  end
end

function bepgp:C_GuildInfo_SetNote(guid,note,isPublicNote)
  if not isPublicNote then
    for index=1,GetNumGuildMembers(1) do
      local name, _, _, _, _, _, _, prevnote, _, _, _, _, _, _, _, _, g_GUID = GetGuildRosterInfo(index)
      if guid == g_GUID then
        self:officerNoteTamper(name,index,prevnote)
        return
      end
    end
  end
end

function bepgp:GuildRosterSetOfficerNote(index,note,fromAddon)
  if (fromAddon) then
    self.hooks["GuildRosterSetOfficerNote"](index,note)
  else
    local name, _, _, _, _, _, _, prevnote, _, _ = GetGuildRosterInfo(index)

    self:officerNoteTamper(name,index,prevnote)

    local safenote = string.gsub(note,"(.*)(%b{})(.*)",self.sanitizeNote)
    return self.hooks["GuildRosterSetOfficerNote"](index,safenote)
  end
end

local player_not_found_capture = _G.ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s","(.+)")
local function playerNotFoundFilter(self,event,msg,sender,...)
  local noPlayerMsg = msg:match(player_not_found_capture)
    if noPlayerMsg then
      return true
    else -- other system message just let it pass through
      return false, msg, sender, ...
    end
end

function bepgp:AddPlayerNotFoundFilter()
  if not bepgp._playerNotFoundfilterActive then
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", playerNotFoundFilter)
    bepgp._playerNotFoundfilterActive = true
  end
end

function bepgp:RemovePlayerNotFoundFilter()
  if bepgp._playerNotFoundfilterActive then
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", playerNotFoundFilter)
    bepgp._playerNotFoundfilterActive = nil
  end
end

function bepgp.commProgress(id, bytesSent, bytesTotal)
  if bytesSent >= bytesTotal then
    C_TimerAfter(1, function()
      bepgp:RemovePlayerNotFoundFilter()
    end)
  end
end

function bepgp:addonMessage(msg, distro, target, prio)
  local prio = prio or "BULK"
  local callbackFn
  if distro == "WHISPER" then
    prio = "NORMAL"
    callbackFn = bepgp.commProgress
    bepgp:AddPlayerNotFoundFilter()
  end
  self:SendCommMessage(bepgp.VARS.prefix,msg,distro,target,prio,callbackFn)
end

local guildComms = {
  ["ALL"] = true,
  ["ADMIN"] = true,
  ["SIZE"] = true,
  ["DIFF"] = true,
  ["SETTINGS"] = true,
}
function bepgp:OnCommReceived(prefix, msg, distro, sender)
  if not prefix == bepgp.VARS.prefix then return end -- not our message
  local sender = bepgp:Ambiguate(sender)
  if sender == self._playerName then return end -- don't care for our own message
  local name, class, rank = self:verifyGuildMember(sender, true)
  if (name and class) then
    self._network[sender] = true
  end
  local who,what,amount
  for name,epgp,change in string.gmatch(msg,"([^;]+);([^;]+);([^;]+)") do
    who = name
    what = epgp
    amount = tonumber(change)
  end
  if guildComms[who] and not (name and class) then return end -- filter by guild context
  local is_admin = self:admin()
  if (who) and (what) and (amount) then
    local out
    local for_main = (self.db.profile.main and (who == self.db.profile.main))
    if (who == self._playerName) or (for_main) then
      if what == "EP" then
        if amount < 0 then
          out = string.format(L["You have received a %d EP penalty."],amount)
        else
          out = string.format(L["You have been awarded %d EP."],amount)
        end
      elseif what == "GP" then
        out = string.format(L["You have gained %d GP."],amount)
      end
    elseif who == "ALL" and what == "DECAY" then
      out = string.format(L["%s%% decay to EP and GP."],amount)
    elseif who == "RAID" and what == "AWARD" then
      out = string.format(L["%d EP awarded to Raid."],amount)
    elseif who == "STANDBY" and what == "AWARD" then
      out = string.format(L["%d EP awarded to Reserves."],amount)
    elseif who == "VERSION" then
      local out_of_date, version_type = self:parseVersion(self._versionString,what)
      if (out_of_date) and self._newVersionNotification == nil then
        self._newVersionNotification = true -- only inform once per session
        self:Print(string.format(L["New %s version available: |cff00ff00%s|r"],version_type,what))
        self:Print(string.format(L["Visit %s to update."],self._websiteString))
      end
      if (IsGuildLeader()) then
        self:shareSettings()
      end
      local addonMsg = "ACK;0;0"
      self:addonMessage(addonMsg,"WHISPER",sender)
    elseif who == "MODE" then
      bepgp.db.char.mode = what
      self:SetMode(what)
    elseif who == "ADMIN" then
      self:GrantLootAdmin(what,amount)
    elseif who == "SIZE" then
      self:GrantSizeToggle(what)
    elseif who == "DIFF" then
      self:GrantDiffToggle(what)
    elseif who == "LOOT" then
      self:UpdatePendingLooters(sender,what,amount)
    elseif who == "SETTINGS" then
      for progress,discount,decay,minep,alts,altspct,allies,fullnames in string.gmatch(what, "([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)") do
        discount = tonumber(discount)
        decay = tonumber(decay)
        minep = tonumber(minep)
        alts = (alts == "true") and true or false
        altspct = tonumber(altspct)
        allies = (allies == "true") and true or false
        fullnames = (fullnames == "true") and true or false
        local settings_notice
        if progress and progress ~= bepgp.db.profile.progress then
          bepgp.db.profile.progress = progress -- DEBUG print("shared:"..progress)
          settings_notice = L["New raid progress"]
        end
        if discount and discount ~= bepgp.db.profile.discount then
          bepgp.db.profile.discount = discount
          if (settings_notice) then
            settings_notice = settings_notice..L[", offspec price %"]
          else
            settings_notice = L["New offspec price %"]
          end
        end
        if minep and minep ~= bepgp.db.profile.minep then
          bepgp.db.profile.minep = minep
          settings_notice = L["New Minimum EP"]
          bepgp:refreshPRTablets()
        end
        if decay and decay ~= bepgp.db.profile.decay then
          bepgp.db.profile.decay = decay
          if (is_admin) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", decay %"]
            else
              settings_notice = L["New decay %"]
            end
          end
        end
        if alts ~= nil and alts ~= bepgp.db.profile.altspool then
          bepgp.db.profile.altspool = alts
          if (is_admin) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", alts"]
            else
              settings_notice = L["New Alts"]
            end
          end
        end
        if altspct and altspct ~= bepgp.db.profile.altpercent then
          bepgp.db.profile.altpercent = altspct
          if (is_admin) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", alts ep %"]
            else
              settings_notice = L["New Alts EP %"]
            end
          end
        end
        if allies ~= nil and allies ~= bepgp.db.profile.allypool then
          bepgp.db.profile.allypool = allies
          if (is_admin) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", allies"]
            else
              settings_notice = L["New Allies"]
            end
          end
        end
        if fullnames ~= nil and fullnames ~= bepgp.db.profile.fullnames then
          bepgp.db.profile.fullnames = fullnames
          if (is_admin) then
            if (settings_notice) then
              settings_notice = settings_notice..L[", fullnames"]
            else
              settings_notice = L["New Fullnames"]
            end
          end
        end
        if (settings_notice) and settings_notice ~= "" then
          local _,_, hexclass = self:getClassData(class)
          local sender_rank = string.format("%s(%s)",C:Colorize(hexclass,sender),rank)
          settings_notice = settings_notice..string.format(L[" settings accepted from %s"],sender_rank)
          self:Print(settings_notice)
          self._options.args.general.args.main.args["progress_tier_header"].name = string.format(L["Progress Setting: %s"],bepgp.db.profile.progress)
          self._options.args.general.args.main.args["set_discount_header"].name = string.format(L["Offspec Price: %s%%"],bepgp.db.profile.discount*100)
          self._options.args.general.args.main.args["set_min_ep_header"].name = string.format(L["Minimum EP: %s"],bepgp.db.profile.minep)
        end
      end
    end
    if out and out~="" then
      self:Print(out)
      self:my_epgp(for_main)
    end
  end
end

local function GetDebugPrintChattynator()
  local debugchat = bepgp.db.char.debugchat
  if debugchat and debugchat > 100 and Chattynator and Chattynator.API and Chattynator.API.AddMessageToWindowAndTab then
    local window,tab = floor(debugchat/100), debugchat%100
    return Chattynator.API.AddMessageToWindowAndTab, window, tab
  end
  return false
end

function bepgp:debugPrint(msg,onlyWhenDebug)
  if onlyWhenDebug and not self._DEBUG then return end
  if not self._debugchat then
    for i=1,NUM_CHAT_WINDOWS do
      local tab = _G["ChatFrame"..i.."Tab"]
      local cf = _G["ChatFrame"..i]
      local tabName = tab and tab:GetText() or ""
      if tab ~= nil and (tabName:lower() == "debug") then
        self._debugchat = cf
        ChatFrame_RemoveAllMessageGroups(self._debugchat)
        ChatFrame_RemoveAllChannels(self._debugchat)
        self._debugchat:SetMaxLines(1024)
        break
      end
    end
  end
  local AddMessageToWindowAndTab, window, tab = GetDebugPrintChattynator()
  if self._optDebugChat==nil then
    if not AddMessageToWindowAndTab then
      local _, _, _, _, _, _, isShown, _, isDocked, _ = GetChatWindowInfo(self.db.char.debugchat or 0)
      if isShown or isDocked then
        self._optDebugChat = _G["ChatFrame"..self.db.char.debugchat]
      else
        self._optDebugChat = false
      end
    else
      self._optDebugChat = {window,tab}
    end
  end
  if self._debugchat then
    self:Print(self._debugchat,msg)
  elseif self._optDebugChat then
    if AddMessageToWindowAndTab then
      AddMessageToWindowAndTab(self._optDebugChat[1],self._optDebugChat[2],"|cff33ff99"..addonName.."|r:"..msg)
    else
      self:Print(self._optDebugChat,msg)
    end
  else
    self:Print(msg)
  end
end

function bepgp:simpleSay(msg)
  local perms = self:getGuildPermissions()
  if perms[self.db.profile.announce] then
    SendChatMessage(out_chat:format(msg), self.db.profile.announce)
  else
    self:Print(msg)
  end
end

function bepgp:adminSay(msg)
  local perms = self:getGuildPermissions()
  if perms.OFFICER then
    SendChatMessage(out_chat:format(msg),"OFFICER")
  end
end

local alertCache = {}
function bepgp:Alert(text)
  local now = GetTime()
  local lastAlert = alertCache[text]
  if not lastAlert or ((now - lastAlert) > 30) then
    --local id = GetChatTypeIndex("LOOT")
    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3,"Master")
    UIErrorsFrame:SetTimeVisible(6)
    UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0.0, 1.0) --, id) new signature (text[,r,g,b,a,id])
    C_TimerAfter(2,function()
      UIErrorsFrame:SetTimeVisible(2) -- back to defaults
    end)
    alertCache[text] = now
  end
end

function bepgp:my_epgp_announce(use_main)
  local ep,gp
  local main = self.db.profile.main
  if (use_main) then
    ep,gp = (self:get_ep(main) or 0), (self:get_gp(main) or bepgp.VARS.basegp)
  else
    ep,gp = (self:get_ep(self._playerName) or 0), (self:get_gp(self._playerName) or bepgp.VARS.basegp)
  end
  local pr = ep/gp
  local msg = string.format(L["You now have: %d EP %d GP |cffffff00%.03f|r|cffff7f00PR|r."], ep,gp,pr)
  self:Print(msg)
  local pr_decay, cap_ep, cap_pr = self:capcalc(ep,gp)
  if pr_decay < 0 then
    msg = string.format(L["Close to EPGP Cap. Next Decay will change your |cffff7f00PR|r by |cffff0000%.4g|r."],pr_decay)
    self:Print(msg)
  end
  self._myepgpTimer = nil
end

function bepgp:my_epgp(use_main)
  local _,perms = self:getGuildPermissions()
  if perms.OFFICER then
    self:safeGuildRoster()
    if not self._myepgpTimer then
      self._myepgpTimer = self:ScheduleTimer("my_epgp_announce",3,use_main)
    end
  end
end

function bepgp:shareSettings(force)
  local now = GetTime()
  if self._lastSettingsShare == nil or (now - self._lastSettingsShare > 30) or (force) then
    self._lastSettingsShare = now
    local addonMsg = string.format("SETTINGS;%s:%s:%s:%s:%s:%s:%s:%s;1",self.db.profile.progress, self.db.profile.discount, self.db.profile.decay, self.db.profile.minep, tostring(self.db.profile.altspool), self.db.profile.altpercent, tostring(self.db.profile.allypool),tostring(self.db.profile.fullnames))
    self:addonMessage(addonMsg,"GUILD")
  end
end

function bepgp:parseVersion(version,otherVersion)
  if not bepgp._version then bepgp._version = {} end
  for major,minor,patch in string.gmatch(version,"(%d+)[^%d]?(%d*)[^%d]?(%d*)") do
    bepgp._version.major = tonumber(major)
    bepgp._version.minor = tonumber(minor)
    bepgp._version.patch = tonumber(patch)
  end
  if (otherVersion) then
    if not bepgp._otherversion then bepgp._otherversion = {} end
    for major,minor,patch in string.gmatch(otherVersion,"(%d+)[^%d]?(%d*)[^%d]?(%d*)") do
      bepgp._otherversion.major = tonumber(major)
      bepgp._otherversion.minor = tonumber(minor)
      bepgp._otherversion.patch = tonumber(patch)
    end
    if (bepgp._otherversion.major ~= nil and bepgp._version.major ~= nil) then
      if (bepgp._otherversion.major < bepgp._version.major) then -- we are newer
        return
      elseif (bepgp._otherversion.major > bepgp._version.major) then -- they are newer
        return true, "major"
      else -- tied on major, go minor
        if (bepgp._otherversion.minor ~= nil and bepgp._version.minor ~= nil) then
          if (bepgp._otherversion.minor < bepgp._version.minor) then -- we are newer
            return
          elseif (bepgp._otherversion.minor > bepgp._version.minor) then -- they are newer
            return true, "minor"
          else -- tied on minor, go patch
            if (bepgp._otherversion.patch ~= nil and bepgp._version.patch ~= nil) then
              if (bepgp._otherversion.patch < bepgp._version.patch) then -- we are newer
                return
              elseif (bepgp._otherversion.patch > bepgp._version.patch) then -- they are newwer
                return true, "patch"
              end
            elseif (bepgp._otherversion.patch ~= nil and bepgp._version.patch == nil) then -- they are newer
              return true, "patch"
            end
          end
        elseif (bepgp._otherversion.minor ~= nil and bepgp._version.minor == nil) then -- they are newer
          return true, "minor"
        end
      end
    end
  end
end

function bepgp:safeAudience(msg)
  local groupstatus = self:GroupStatus()
  local inInstance, instanceType = IsInInstance()
  local channel
  if groupstatus == "RAID" then
    channel = "RAID"
  elseif groupstatus == "PARTY" then
    channel = "PARTY"
  elseif inInstance and (instanceType == "party" or instanceType == "raid") then
    channel = "SAY"
  end
  if channel then
    SendChatMessage(msg, channel)
  else
    self:debugPrint(msg)
  end
end

function bepgp:widestAudience(msg)
  local groupstatus = self:GroupStatus()
  local channel
  if groupstatus == "RAID" then
    if (self:raidLeader() or self:raidAssistant()) then
      channel = "RAID_WARNING"
    else
      channel = "RAID"
    end
  elseif groupstatus == "PARTY" then
    channel = "PARTY"
  end
  if channel then
    SendChatMessage(msg, channel)
  end
end

function bepgp:CloseSpecialWindows()
  local found = securecall(self.hooks["CloseSpecialWindows"])
  for key,object in pairs(special_frames) do
    object:Hide()
  end
  return found
end

function bepgp:make_escable(object,operation)
  if type(object) == "string" then
    local found
    for i,f in ipairs(UISpecialFrames) do
      if f==object then
        found = i
      end
    end
    if not found and operation=="add" then
      table.insert(UISpecialFrames,object)
    elseif found and operation=="remove" then
      table.remove(UISpecialFrames,found)
    end
  elseif type(object) == "table" then
    if object.Hide then
      local key = tostring(object):gsub("table: ","")
      if operation == "add" then
        special_frames[key] = object
      else
        special_frames[key] = nil
      end
    end
  end
end

function bepgp:RequestLootAdmin()
  if bepgp:admin() and bepgp:GroupStatus() == "RAID" then
    bepgp:Print(L["Sending request for Loot Admin"])
    local addonMsg = string.format("ADMIN;%s;%s",bepgp._playerName,LE_ITEM_QUALITY_RARE) -- rare
    bepgp:addonMessage(addonMsg,"RAID")
  end
end

function bepgp:GrantLootAdmin(name, threshold)
  if not name or name == "" then return end
  local threshold = threshold or LE_ITEM_QUALITY_RARE
  if not IsInRaid() then return end
  if not UnitIsGroupLeader("player") then return end
  if whitelist[name] or bepgp.db.char.whitelist[name] then
    whitelist[name] = nil
    local g_name = bepgp:verifyGuildMember(name, true)
    if g_name then
      SetLootMethod("master",g_name,threshold)
      bepgp:Print(string.format(L["Granting Loot Admin to %s."],name))
      if not (UnitIsGroupAssistant(g_name) or IsEveryoneAssistant()) then
        PromoteToAssistant(g_name, true)
      end
      return
    end
  else
    if bepgp:checkDialog(addonName.."DialogWhitelist") then
      LD:Spawn(addonName.."DialogWhitelist",{"GrantLootAdmin",name,threshold})
    end
    return
  end
end

function bepgp:RequestSizeToggle()
  if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return end
  if bepgp:admin() and bepgp:GroupStatus() == "RAID" then
    bepgp:Print(L["Sending request for raid size change"])
    local addonMsg = string.format("SIZE;%s;%s",bepgp._playerName,1)
    bepgp:addonMessage(addonMsg,"RAID")
  end
end

function bepgp:GrantSizeToggle(name)
  if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return end
  if not name or name == "" then return end
  if not IsInRaid() then return end
  if not UnitIsGroupLeader("player") then return end
  if whitelist[name] or bepgp.db.char.whitelist[name] then
    whitelist[name] = nil
    local g_name = bepgp:verifyGuildMember(name, true)
    if g_name then
      local toDiff
      local diffID = GetRaidDifficultyID()
      if diffID == DIFFICULTY_RAID10_NORMAL then
        toDiff = DIFFICULTY_RAID25_NORMAL
      elseif diffID == DIFFICULTY_RAID25_NORMAL then
        toDiff = DIFFICULTY_RAID10_NORMAL
      elseif diffID == DIFFICULTY_RAID10_HEROIC then
        toDiff = DIFFICULTY_RAID25_HEROIC
      elseif diffID == DIFFICULTY_RAID25_HEROIC then
        toDiff = DIFFICULTY_RAID10_HEROIC
      end
      if toDiff then
        SetRaidDifficultyID(toDiff, true)
        bepgp:Print(string.format(L["Granting raid size change to %s."],name))
      end
      return
    end
  else
    if bepgp:checkDialog(addonName.."DialogWhitelist") then
      LD:Spawn(addonName.."DialogWhitelist",{"GrantSizeToggle",name})
    end
    return
  end
end

function bepgp:RequestDiffToggle()
  if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return end
  if bepgp:admin() and bepgp.db.char.mode == "epgp" and bepgp:GroupStatus() == "RAID" then
    bepgp:Print(L["Sending request for raid difficulty change"])
    local addonMsg = string.format("DIFF;%s;%s",bepgp._playerName,1)
    bepgp:addonMessage(addonMsg,"RAID")
  end
end

function bepgp:GrantDiffToggle(name)
  if not (bepgp._mists or bepgp._cata or bepgp._wrath) then return end
  if not name or name == "" then return end
  if not IsInRaid() then return end
  if not UnitIsGroupLeader("player") then return end
  if whitelist[name] or bepgp.db.char.whitelist[name] then
    whitelist[name] = nil
    local g_name = bepgp:verifyGuildMember(name, true)
    if g_name then
      local toDiff
      local diffID = GetRaidDifficultyID()
      if diffID == DIFFICULTY_RAID10_NORMAL then
        toDiff = DIFFICULTY_RAID10_HEROIC
      elseif diffID == DIFFICULTY_RAID10_HEROIC then
        toDiff = DIFFICULTY_RAID10_NORMAL
      elseif diffID == DIFFICULTY_RAID25_NORMAL then
        toDiff = DIFFICULTY_RAID25_HEROIC
      elseif diffID == DIFFICULTY_RAID25_HEROIC then
        toDiff = DIFFICULTY_RAID25_NORMAL
      end
      if toDiff then
        SetRaidDifficultyID(toDiff, true)
        bepgp:Print(string.format(L["Granting raid difficulty change to %s."],name))
      end
      return
    end
  else
    if bepgp:checkDialog(addonName.."DialogWhitelist") then
      LD:Spawn(addonName.."DialogWhitelist",{"GrantDiffToggle",name})
    end
    return
  end
end

function bepgp:UpdatePendingLooters(looter, guid, action)
  if bepgp:lootMaster() or bepgp:raidLeader() then
    if action == 1 then
      pendingLooters[guid] = pendingLooters[guid] or {}
      pendingLooters[guid][looter] = true
    elseif action == 0 then
      if pendingLooters[guid] and pendingLooters[guid][looter] then
        pendingLooters[guid][looter] = nil
      end
    end
  end
end

function bepgp:OpenAdminActions(obj)
  local is_admin = self:admin()
  if is_admin then
    self:ddoptions()
    self._ddmenu = LDD:OpenAce3Menu(self._dda_options)
  else
    self:ddoptions()
    self._ddmenu = LDD:OpenAce3Menu(self._ddm_options)
  end
  local scale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
  local half_width, half_height = GetScreenWidth()*scale/2, GetScreenHeight()*scale/2
  local prefix,postfix,anchor
  if x >= half_width then
    postfix = "RIGHT"
  else
    postfix = "LEFT"
  end
  if y >= half_height then
    prefix = "TOP"
  else
    prefix = "BOTTOM"
  end
  anchor = prefix..postfix
  self._ddmenu:SetClampedToScreen(true)
  self._ddmenu:SetClampRectInsets(-25, 200, 25, -150)
  self._ddmenu:SetPoint(anchor, UIParent, "BOTTOMLEFT", x/scale, y/scale)
end

function bepgp:PLAYER_GUILD_UPDATE(...)
  local unitid = ...
  if unitid and UnitIsUnit(unitid,"player") then
    if IsInGuild() then
      self:OnEnable(true)
    end
  end
end

function bepgp:PLAYER_LEVEL_UP(event,...)
  local level = ...
  self._playerLevel = level
  if self._playerLevel == MAX_PLAYER_LEVEL then
    self:UnregisterEvent("PLAYER_LEVEL_UP")
  end
  if self._playerLevel and self._playerLevel >= bepgp.VARS.minlevel then
    self:testMain()
  end
end

function bepgp:PLAYER_REGEN_ENABLED()
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  self:GUILD_ROSTER_UPDATE("PLAYER_REGEN_ENABLED")
end

local COMBATLOG_FILTER_HOSTILE_NPC = bit.bor(
  COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
  COMBATLOG_OBJECT_REACTION_HOSTILE,
  COMBATLOG_OBJECT_CONTROL_NPC,
  COMBATLOG_OBJECT_TYPE_NPC
)
local DEATH_EVENTS = {
  ["UNIT_DIED"] = true,
  ["UNIT_DESTROYED"] = true,
  ["UNIT_DISSIPATES"] = true,
  ["PARTY_KILL"] = true,
}
local pendingLootUpdater = function(guid, name)
  if not guid or (guid == "") then return end
  C_TimerAfter(2, function()
    local hasLoot, canLoot = CanLootUnit(guid)
    if pendingLoot[guid] then
      if not hasLoot then
        pendingLoot[guid] = nil
        local addonMsg = string.format("LOOT;%s;0",guid)
        bepgp:addonMessage(addonMsg,"RAID",nil,"NORMAL")
      end
    else
      if hasLoot and canLoot then
        pendingLoot[guid] = name
        local addonMsg = string.format("LOOT;%s;1",guid)
        bepgp:addonMessage(addonMsg,"RAID",nil,"NORMAL")
      end
    end
  end)
end
function bepgp:COMBAT_LOG_EVENT_UNFILTERED(event,...)
  if not IsInRaid() then return end -- DEBUG
  if UnitInBattleground("player") or IsInActiveWorldPVP("player") then return end -- DEBUG
  local _, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  if not DEATH_EVENTS[subevent] then return end
  if not CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_NPC) then return end
  pendingLootUpdater(destGUID,destName)
end

function bepgp:checkPendingLoot(event, lootSlot)
  if not IsInRaid() then return end -- DEBUG
  if UnitInBattleground("player") or IsInActiveWorldPVP("player") then return end -- DEBUG
  local lootsourceGUID = GetLootSourceInfo(lootSlot)
  local sourceName = pendingLoot[lootsourceGUID]
  if sourceName then
    pendingLootUpdater(lootsourceGUID,sourceName)
  end
end

function bepgp:GUILD_ROSTER_UPDATE(event)
  local guildFrame = (CommunitiesFrame or GuildFrame)
  if guildFrame and guildFrame:IsShown() then return end
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end
  local guildname = GetGuildInfo("player")
  if guildname then
    self:deferredInit(guildname)
  end
  if not self._initdone then
    return
  end
  local members = self:buildRosterTable()
  self:guildCache()
end

function bepgp:admin()
  return IsInGuild() and (bepgp.CanEditOfficerNote())
end

function bepgp:lootMaster()
  if not IsInRaid() then return false end
  local method, partyidx, raididx = GetLootMethod()
  if method == "master" then
    if raididx and UnitIsUnit("player", "raid"..raididx) then
      return true
    elseif partyidx and (partyidx == 0) then
      return true
    else
      return false
    end
  else
    return false
  end
end

function bepgp:raidLeader()
  return IsInRaid() and UnitIsGroupLeader("player")
end

function bepgp:raidAssistant()
  return IsInRaid() and UnitIsGroupAssistant("player")
end

function bepgp:inRaid(name)
  local rid = bepgp:UnitInRaid(name)
  local inraid = IsInRaid() and rid and (rid >= 0)
  if inraid then
    local groupcache = self.db.char.groupcache
    if not groupcache[name] then
      groupcache[name] = {}
      local member, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML = bepgp:GetRaidRosterInfo(rid)
      member = bepgp:Ambiguate((member or ""))
      if member and (member == name) and (member ~= _G.UNKNOWNOBJECT) then
        local _,_,hexColor = self:getClassData(lclass)
        local colortab = RAID_CLASS_COLORS[eclass]
        groupcache[member]["level"] = level
        groupcache[member]["class"] = lclass
        groupcache[member]["eclass"] = eclass
        groupcache[member]["hex"] = hexColor
        groupcache[member]["color"] = {r=colortab.r, g=colortab.g, b=colortab.b, a=1.0}
      end
    end
  end
  return inraid
end

function bepgp:GroupStatus()
  if IsInRaid() and GetNumGroupMembers() > 1 then
    return "RAID"
  elseif UnitExists("party1") then
    return "PARTY"
  else
    return "SOLO"
  end
end

local raidZones, mapZones, tier_multipliers
if bepgp._mists then
  raidZones = {
    [(GetRealZoneText(1008))] = "T14", -- Mogu'shan Vaults
    [(GetRealZoneText(996))]  = "T14", -- Terrace of Endless Spring
    [(GetRealZoneText(1009))] = "T14", -- Heart of Fear
    [(GetRealZoneText(1098))] = "T15", -- Throne of Thunder
    [(GetRealZoneText(1136))] = "T16", -- Siege of Orgrrimmar
  }
  mapZones = {}
  tier_multipliers = {
    ["T16"]  = {["T16"]=1,["T15"]=0.75,["T14"]=0.4},
    ["T15"]  = {["T16"]=1,["T15"]=1,["T14"]=0.5},
    ["T14"]  = {["T16"]=1,["T15"]=1,["T14"]=1},
  }
end
if bepgp._cata then
  raidZones = {
    [(GetRealZoneText(669))] = "T11", -- Blackwing Descent
    [(GetRealZoneText(671))] = "T11", -- The Bastion of Twilight
    [(GetRealZoneText(754))] = "T11", -- Throne of Four Winds
    [(GetRealZoneText(757))] = "T11", -- Baradin Hold
    [(GetRealZoneText(720))] = "T12", -- Firelands
    [(GetRealZoneText(967))] = "T13", -- Dragon Soul
  }
  mapZones = {}
  tier_multipliers = {
    ["T13"]  = {["T13"]=1,["T12"]=0.75,["T11"]=0.4},
    ["T12"]  = {["T13"]=1,["T12"]=1,["T11"]=0.5},
    ["T11"]  = {["T13"]=1,["T12"]=1,["T11"]=1},
  }
end
if bepgp._wrath then
  raidZones = {
    [(GetRealZoneText(533))] = "T7", -- Naxxramas
    [(GetRealZoneText(624))] = "T7", -- Vault of Archavon
    [(GetRealZoneText(615))] = "T7", -- Obsidian Sanctum
    [(GetRealZoneText(616))] = "T7", -- Eye of Eternity
    [(GetRealZoneText(603))] = "T8", -- Ulduar
    [(GetRealZoneText(649))] = "T9", -- Trial of the Crusader
    [(GetRealZoneText(249))] = "T9", -- Onyxia
    [(GetRealZoneText(631))] = "T10", -- Icecrown Citadel
    [(GetRealZoneText(724))] = "T10.5", -- Ruby Sanctum
  }
  mapZones = {}
  tier_multipliers = {
    ["T10.5"] = {["T10.5"]=1,["T10"]=0.9,["T9"]=0.75,["T8"]=0.5,["T7"]=0.25},
    ["T10"]   = {["T10.5"]=1,["T10"]=1,["T9"]=0.75,["T8"]=0.6,["T7"]=0.3},
    ["T9"]    = {["T10.5"]=1,["T10"]=1,["T9"]=1,["T8"]=0.75,["T7"]=0.4},
    ["T8"]    = {["T10.5"]=1,["T10"]=1,["T9"]=1,["T8"]=1,["T7"]=0.5},
    ["T7"]    = {["T10.5"]=1,["T10"]=1,["T9"]=1,["T8"]=1,["T7"]=1},
  }
end
if bepgp._bcc then
  raidZones = {
    [(GetRealZoneText(532))] = "T4",   -- Karazhan
    [(GetRealZoneText(565))] = "T4",   -- Gruul's Lair
    [(GetRealZoneText(544))] = "T4",   -- Magtheridon's Lair
    [(GetRealZoneText(550))] = "T5",   -- Tempest Keep (The Eye)
    [(GetRealZoneText(548))] = "T5",   -- Coilfang: Serpentshrine Cavern
    [(GetRealZoneText(564))] = "T6",   -- Black Temple
    [(GetRealZoneText(534))] = "T6",   -- The Battle for Mount Hyjal
    [(GetRealZoneText(568))] = "T5",   -- Zul'Aman
    [(GetRealZoneText(580))] = "T6.5"  -- The Sunwell
  }
  mapZones = {
    [(C_Map.GetAreaInfo(3483))] = {"T4",(C_Map.GetAreaInfo(3547))}, -- Hellfire Peninsula - Throne of Kil'jaeden, Doom Lord Kazzak
    [(C_Map.GetAreaInfo(3520))] = {"T4",""}, -- Shadowmoon Valley, Doomwalker
  }
  tier_multipliers = {
    ["T6.5"] =   {["T6.5"]=1,["T6"]=0.75,["T5"]=0.5,["T4"]=0.25},
    ["T6"]   =   {["T6.5"]=1,["T6"]=1,   ["T5"]=0.7,["T4"]=0.4},
    ["T5"]   =   {["T6.5"]=1,["T6"]=1,   ["T5"]=1,  ["T4"]=0.5},
    ["T4"]   =   {["T6.5"]=1,["T6"]=1,   ["T5"]=1,  ["T4"]=1}
  }
end
if bepgp._classic then
  raidZones = {
    [(GetRealZoneText(249))] = "T1.5", -- Onyxia's Lair
    [(GetRealZoneText(409))] = "T1",   -- Molten Core
    [(GetRealZoneText(469))] = "T2",   -- Blackwing Lair
    [(GetRealZoneText(531))] = "T2.5", -- Ahn'Qiraj Temple
    [(GetRealZoneText(533))] = "T3",   -- Naxxramas
  }
  mapZones = {
    [(C_Map.GetAreaInfo(4))] = {"T1.5",(C_Map.GetAreaInfo(73))}, -- Blasted Lands - Tainted Scar, Kazzak
    [(C_Map.GetAreaInfo(16))] = {"T1.5",(C_Map.GetAreaInfo(1221))}, -- Azshara - Ruins of Eldarath, Azuregos
    [(C_Map.GetAreaInfo(10))] = {"T2",(C_Map.GetAreaInfo(856))}, -- Duskwood - Twilight Grove, 4Dragons
    [(C_Map.GetAreaInfo(47))] = {"T2",(C_Map.GetAreaInfo(356))}, -- The Hinterlands - Seradane, 4Dragons
    [(C_Map.GetAreaInfo(331))] = {"T2",(C_Map.GetAreaInfo(438))}, -- Ashenvale - Bough Shadow, 4Dragons
    [(C_Map.GetAreaInfo(357))] = {"T2",(C_Map.GetAreaInfo(1111))}, -- Feralas - Dream Bough, 4Dragons
  }
  tier_multipliers = {
    ["T3"] =   {["T3"]=1,["T2.5"]=0.75,["T2"]=0.5,["T1.5"]=0.25,["T1"]=0.25},
    ["T2.5"] = {["T3"]=1,["T2.5"]=1,   ["T2"]=0.7,["T1.5"]=0.4, ["T1"]=0.4},
    ["T2"] =   {["T3"]=1,["T2.5"]=1,   ["T2"]=1,  ["T1.5"]=0.5, ["T1"]=0.5},
    ["T1"] =   {["T3"]=1,["T2.5"]=1,   ["T2"]=1,  ["T1.5"]=1,   ["T1"]=1}
  }
end
function bepgp:suggestEPAward(debug)
  local currentTier, zoneLoc, checkTier, multiplier
  local inInstance, instanceType = IsInInstance()
  local inRaid = IsInRaid()
  if inInstance and instanceType == "raid" then
    local locZone, locSubZone = GetRealZoneText(), GetSubZoneText()
    if locZone then
      checkTier = raidZones[locZone]
      if checkTier then
        currentTier = checkTier
      else -- fallback to substring check
        for zone, tier in pairs(raidZones) do
          if zone:find(locZone) then
            currentTier = tier
            break
          end
        end
      end
    end
  else
    if inRaid then
      local locZone, locSubZone = GetRealZoneText(), GetSubZoneText()
      if locZone then
        checkTier = mapZones[locZone] and mapZones[locZone][1]
        if checkTier then
          currentTier = checkTier
        end
      end
    end
  end
  if currentTier then
    multiplier = tier_multipliers[self.db.profile.progress][currentTier]
    return tostring(multiplier*self.VARS.baseaward_ep)
  end
  return tostring(self.VARS.baseaward_ep)
end

function bepgp:SetPriceSystem(context)
  local system = self.db.profile.system
  if not price_systems[system] then
    self.GetPrice = price_systems[self.VARS.pricesystem].func
    self.db.profile.system = self.VARS.pricesystem
    context = "DEFAULT"
  else
    self.GetPrice = price_systems[system].func
  end
  if not (type(self.GetPrice)=="function") then -- fallback to first available
    for name,system in pairs(price_systems) do
      self.db.profile.system = name
      self.GetPrice = system.func
      context = "FALLBACK"
      break
    end
  end
  local progress = self.db.profile.progress
  local flavor = price_systems[self.db.profile.system].flavor
  if flavor and progress and not self._progsets[flavor].progress_values[progress] then
    self.db.profile.progress = self._progsets[flavor].progress_sorting[1]
    if IsGuildLeader() then
      self:shareSettings()
    end
  end
  self:SendMessage(addonName.."_PRICESYSTEM")
  self:debugPrint(string.format(L["Price system set to: %q %s"],self.db.profile.system,(context or "")))
end

function bepgp:GetPriceSystem(name)
  if price_systems[name] then
    return price_systems[name]
  end
end

function bepgp:RegisterPriceSystem(name, system)
  price_systems[name]=system
end

function bepgp:getRaidID()
  if self.db.char.wincountmanual then
    return "RID:MANUAL"
  end
  local inInstance, instanceType = IsInInstance()
  local instanceMapName, instanceName, instanceID, instanceReset
  if inInstance and instanceType=="raid" then
    instanceMapName = GetRealZoneText()
    local savedInstances = GetNumSavedInstances()
    if savedInstances > 0 then
      for i=1,savedInstances do
        instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i)
        if instanceName:lower() == instanceMapName:lower() then
          return string.format("%s:%s",instanceName,instanceID)
        end
      end
    end
  end
end

function bepgp:itemLevelOptionPass(item_level)
  local minilvl = self.db.char.minilvl
  item_level = tonumber(item_level)
  if item_level and minilvl and (minilvl > 0) and (item_level < minilvl) then
    return false
  end
  return true
end

bepgp._firestoneItems = { }
local function firestonDDClose()
  if bepgp._firestoneDD then
    bepgp._firestoneDD:Release()
  end
end
function bepgp:getFirestoneItems(enClass, dialogData)
  local firestoneItems
  local priceMenu = bepgp._firestoneItems
  if (not enClass) or (not class_to_firestoneitems[enClass]) then
    firestoneItems = class_to_firestoneitems["UNKNOWN"] -- return all
  else
    firestoneItems = class_to_firestoneitems[enClass]
  end
  wipe(priceMenu)
  if firestoneItems then
    local linkMod = GetModifiedClick("CHATLINK")
    linkMod = ("-"):split(linkMod)
    priceMenu.type = "group"
    priceMenu.name = "Crystallized Firestone"
    priceMenu.desc = "Crystallized Firestone ".. TURN_IN_QUEST
    priceMenu.args = priceMenu.args or {}
    priceMenu.args["Title"] = {
      type = "header",
      name = "Crystallized Firestone ".. TURN_IN_QUEST,
      order = 0,
    }
    local itemAsync = Item:CreateFromItemID(bepgp.VARS.crystalfirestone) -- Crystallized Firestone id
    itemAsync:ContinueOnItemLoad(function()
      local itemLink = itemAsync:GetItemLink()
      local itemName = itemAsync:GetItemName()
      priceMenu.name = itemLink
      priceMenu.desc = format("%s %s",itemLink, TURN_IN_QUEST)
      priceMenu.args["Title"].name = format(L["Select [%s] GP value"],itemName)
      dialogData.firestoneData.firestone = itemName
    end)
    for i,itemID in ipairs(firestoneItems) do
      local price1, tier, price2, wand_discount,ranged_discount,shield_discount,onehand_discount,twohand_discount, item_level = bepgp:GetPrice(itemID, bepgp.db.profile.progress)
      if price1 then
        local off_price = math.floor(price1*self.db.profile.discount)
        local off_price2
        if price2 and price2 > 0 then
          off_price2 = math.floor(price2*self.db.profile.discount)
        end
        local itemAsync = Item:CreateFromItemID(itemID)
        itemAsync:ContinueOnItemLoad(function()
          local itemLink = itemAsync:GetItemLink()
          local invTypeName = itemAsync:GetInventoryTypeName()
          priceMenu.args[itemID] = {
            type = "execute",
            name = format("%03d %s %s",price1, itemLink, (_G[invTypeName or "UNKNOWN"])),
            desc = format(L["%s-Click to Link Item"],linkMod),
            order = i,
            func = function(info)
              if ( IsModifiedClick("CHATLINK") ) then
                ChatEdit_LinkItem(itemID, itemLink)
                return
              end
              dialogData.firestoneData.gp = price1
              dialogData.firestoneData.gp_os = off_price
              dialogData.firestoneData.gp2 = price2
              dialogData.firestoneData.gp2_os = off_price2
              dialogData.firestoneData.item = itemLink
              dialogData._firestoneCheckbox.Text:SetText(itemLink)
              dialogData._firestoneCheckbox:SetChecked(true)
              C_Timer.After(0.2, firestonDDClose)
            end,
          }
        end)
      end
    end
    priceMenu.args.cancel = {
      type = "execute",
      name = _G.CANCEL,
      desc = _G.CANCEL,
      order = 25,
      func = function(info)
        C_Timer.After(0.2, firestonDDClose)
      end,
    }
  end
  return priceMenu
end
-------------------------------------------
--// UTILITY
-------------------------------------------
function bepgp:num_round(i)
  return math.floor(i+0.5)
end

function bepgp:table_count(t)
  local count = 0
  if type(t) == "table" then
    for k,v in pairs(t) do
      count = count+1
    end
  end
  return count
end

function bepgp:wrap_tuple(...)
  return {...}
end

-- in-place shuffle, the original array is "destroyed"
function bepgp:table_shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function bepgp:Capitalize(word)
  return (string.gsub(word,"^[%c%s]*([%U])([^%c%s%p%d]*)",function(head,tail)
    local newword = string.format("%s%s",string.upper(head),string.lower(tail))
      if string.len(newword) == string.len(word) then
        return newword
      else
        return word
      end
    end))
end

function bepgp:Ambiguate(name, passthroughOpt)
  if passthroughOpt then
    return Ambiguate(name, passthroughOpt)
  end
  local fullnames = self.db.profile.fullnames
  if fullnames then
    local name = Ambiguate(name,"mail")
    if strfind(name,"-") then
      return name
    else
      return name.."-"..self._playerRealm
    end
  else
    return Ambiguate(name,"short")
  end
end

function bepgp:UnitInRaid(name)
  local realm = name:match("%-(.+)")
  if realm and realm == bepgp._playerRealm then
    name = self:Ambiguate(name, "short")
  end
  return UnitInRaid(name)
end

function bepgp:GetRaidRosterInfo(rid)
  local fullnames = self.db.profile.fullnames
  if fullnames then
    local member, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML = GetRaidRosterInfo(rid)
    if member and not strfind(member,"-") then
      member = member .. "-" .. bepgp._playerRealm
    end
    return member, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML
  else
    return GetRaidRosterInfo(rid)
  end
end

local classSpecStringCache = {}
function bepgp:ClassSpecString(class,spec,text) -- pass it CLASS
  local key = class..(spec and "-"..spec or "")..(text and "text" or "")
  local cached = classSpecStringCache[key]
  if cached then
    return cached
  else
    if text then
      local eClass, lClass, hexclass = bepgp:getClassData(class) -- CLASS, class, classColor
      if spec then
        cached = string.format("|cff%s%s%s-%s%s|r",hexclass,lClass,bepgp._specmap[class].Icon,spec,bepgp._specmap[class][spec])
        classSpecStringCache[key] = cached
      else
        cached = string.format("|cff%s%s|r",hexclass,lClass,bepgp._specmap[class].Icon)
        classSpecStringCache[key] = cached
      end
    else
      if spec then
        cached = string.format("(%s:%s)",bepgp._specmap[class].Icon,bepgp._specmap[class][spec])
        classSpecStringCache[key] = cached
      else
        cached = string.format("(%s)",bepgp._specmap[class].Icon)
        classSpecStringCache[key] = cached
      end
    end
    if cached then return cached end
  end
end

function bepgp:getServerTime(date_fmt, time_fmt, epoch)
  local epoch = epoch or GetServerTime()
  local date_fmt = date_fmt or "%b-%d" -- Mon-dd, alt example: "%Y-%m-%d" > YYYY-MM-DD
  local time_fmt = time_fmt or "%H:%M:%S" -- HH:mm:SS
  local d = date(date_fmt,epoch)
  local t = date(time_fmt,epoch)
  local timestamp = string.format("%s %s",d,t)
  return tostring(epoch), timestamp
end

function bepgp:getClassData(class) -- CLASS, class, classColor
  local eClass = classToEnClass[class]
  local lClass = LOCALIZED_CLASS_NAMES_MALE[class] or LOCALIZED_CLASS_NAMES_FEMALE[class]
  if eClass then
    return eClass, class, hexClassColor[class]
  elseif lClass then
    return class, lClass, hexClassColor[lClass]
  end
end

function bepgp:getAnyItemLink(text)
  if (string.find(text, "|Hitem:", 1, true)) then
    return true
  else
    local bastionlinks = bepgp:GetModule(addonName.."_chatlinks",true)
    if bastionlinks then
      return bastionlinks:getAnyItemLink(text)
    end
  end
  return false
end

function bepgp:getStrippedLinkText(text)
  local linkstriptext, count = string.gsub(text,"|c%x+|H[eimt:%-%d]+|h%[.-%]|h|r"," ; ")
  local bastionlinks = bepgp:GetModule(addonName.."_chatlinks",true)
  if bastionlinks and count == 0 then
    linkstriptext, count = bastionlinks:getStrippedLinkText(text)
  end
  return string.lower(linkstriptext), count
end

function bepgp:getItemLinkText(text)
  local _,_,itemLink = string.find(text,"(|c%x+|H[eimt:%-%d]+|h%[.-%]|h|r)")
  local bastionlinks = bepgp:GetModule(addonName.."_chatlinks",true)
  if bastionlinks and not itemLink then
    itemLink = bastionlinks:getItemLinkText(text)
  end
  return itemLink
end

function bepgp:getItemData(itemLink) -- itemcolor, itemstring, itemname, itemid
  local link_found, _, itemColor, itemString, itemName = string.find(itemLink, "^(|c%x+)|H(.+)|h(%[.+%])")
  if link_found then
    local itemID = bepgp.GetItemInfoInstant(itemString)
    return itemColor, itemString, itemName, itemID
  else
    return
  end
end

function bepgp:getCurrencyData(itemLink) -- itemcolor, icon, currencyname, currenciid
  local link_found, _, itemColor, currencyID, currencyName = string.find(itemLink, "^(|c%x+)|Hcurrency:(%d+).*|h(%[.+%])")
  if link_found then
    currencyID = tonumber(currencyID)
    local func_currencyInfo = C_CurrencyInfo and C_CurrencyInfo.GetBasicCurrencyInfo
    if func_currencyInfo then
      local data = func_currencyInfo(currencyID)
      if data and data.name then
        if data.name:trim()~="" then
          return itemColor, data.icon or -1, data.name, currencyID
        end
      end
    end
  else
    return
  end
end

--/print tostring(BastionLoot:itemBinding("item:19727"))
-- item:19865,item:19724,item:19872,item:19727,item:19708,item:19802,item:22637
function bepgp:itemBinding(itemString)
  G:SetHyperlink(itemString)
  if G:Find(item_bind_patterns.CRAFT,2,4,nil,true) then
  else
    if G:Find(item_bind_patterns.BOP,2,4,nil,true) then
      return bepgp.VARS.bop
    elseif G:Find(item_bind_patterns.QUEST,2,4,nil,true) then
      return bepgp.VARS.bop
    elseif G:Find(item_bind_patterns.BOE,2,4,nil,true) then
      return bepgp.VARS.boe
    elseif G:Find(item_bind_patterns.BOU,2,4,nil,true) then
      return bepgp.VARS.boe
    else
      return bepgp.VARS.nobind
    end
  end
  return
end

function bepgp:getItemQualityData(quality) -- id, name, qualityColor
  -- WARNING: itemlink parsed color does NOT match the one returned by the ITEM_QUALITY_COLORS table
  local id, hex = tonumber(quality), type(quality) == "string"
  if id and id >=0 and id <= 5 then
    return id, _G["ITEM_QUALITY"..id.."_DESC"], ITEM_QUALITY_COLORS[id].hex
  elseif hex then
    id = hexColorQuality[quality]
    if id then
      return id, _G["ITEM_QUALITY"..id.."_DESC"], quality
    end
  end
end

-- local fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName, achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(index)
function bepgp:verifyGuildMember(name,silent,levelignore)
  for roster_index=1,GetNumGuildMembers(true) do
    local g_name, g_rank, g_rankIndex, g_level, g_class, g_zone, g_note, g_officernote, g_online, g_status, g_eclass, _, _, g_mobile, g_sor, _, g_GUID = GetGuildRosterInfo(roster_index)
    g_name = bepgp:Ambiguate(g_name)
    local level = tonumber(g_level)
    if (string.lower(name) == string.lower(g_name)) and ((level >= bepgp.VARS.minlevel) or (levelignore and level > 0)) then
      return g_name, g_class, g_rank, g_officernote, g_rankIndex, roster_index
    end
  end
  if (name) and name ~= "" and not (silent) then
    self:Print(string.format(L["%s not found in the guild or not raid level!"],name))
  end
  return
end

function bepgp:safeGuildRoster()
  if not IsInGuild() then return end
  local guildFrame = (CommunitiesFrame or GuildFrame)
  if guildFrame and guildFrame:IsShown() then return end
  if InCombatLockdown() then return end
  local now = GetTime()
  if not self._lastgRosterUpdate or (now - self._lastgRosterUpdate) >= 10 then
    bepgp.GuildRoster()
    self._lastgRosterUpdate = GetTime()
  end
end

local speakPermissions,readPermissions = {},{}
function bepgp:getGuildPermissions()
  table.wipe(speakPermissions)
  table.wipe(readPermissions)
  for i=1,GetNumGuildMembers(true) do
    local name, _, rankIndex = GetGuildRosterInfo(i)
    name = bepgp:Ambiguate(name)
    if name == self._playerName then
      speakPermissions.OFFICER = bepgp.GuildControlGetRankFlags(rankIndex+1)[4]
      readPermissions.OFFICER = bepgp.GuildControlGetRankFlags(rankIndex+1)[11]
      break
    end
  end
  speakPermissions.GUILD = bepgp.CanSpeakInGuildChat()
  local groupstatus = self:GroupStatus()
  speakPermissions.PARTY = (groupstatus == "PARTY") or (groupstatus == "RAID")
  speakPermissions.RAID = groupstatus == "RAID"
  return speakPermissions,readPermissions
end

function bepgp:getGuildRanks()
  self._guildRanks = {[100]=_G.NONE}
  self._guildRankSorting = {100}
  if IsInGuild() then
    for i=1, GuildControlGetNumRanks() do
      self._guildRanks[i-1]=GuildControlGetRankName(i)
      tinsert(self._guildRankSorting,i-1)
    end
  end
  self._guildRankIndex = tInvert(self._guildRanks)
  return self._guildRanks, self._guildRankSorting
end

function bepgp:testMain()
  if not IsInGuild() then return end
  if not self.db.char.standby then return end
  if (not self.db.profile.main) or self.db.profile.main == "" then
    if self._playerLevel and (self._playerLevel < bepgp.VARS.minlevel) then
      return
    else
      if bepgp:checkDialog(addonName.."DialogSetMain") then
        LD:Spawn(addonName.."DialogSetMain")
      end
    end
  end
end

function bepgp:groupStatusRouter(event)
  raidStatus = (self:GroupStatus() == "RAID") and true or false
  if (raidStatus == false) and (lastRaidStatus == nil or lastRaidStatus == true) then
    local hasLoothistory = #(self.db.char.loot)
    if hasLoothistory > 0 and (event ~= "PARTY_LOOT_METHOD_CHANGED") then
      if bepgp:checkDialog(addonName.."DialogClearLoot") then
        LD:Spawn(addonName.."DialogClearLoot",hasLoothistory)
      end
    end
  end
  lastRaidStatus = raidStatus
  if (event == "PLAYER_ENTERING_WORLD") or
  (event == "PARTY_LOOT_METHOD_CHANGED") or
  (event == "GROUP_ROSTER_UPDATE") then
    if raidStatus and self:lootMaster() then
      local addonMsg = string.format("MODE;%s;%s",self.db.char.mode,self._playerName)
      self:addonMessage(addonMsg,"RAID")
    end
  end
end

-- parse potential Alt (in-guild) officernote, return Main (in-guild)
function bepgp:parseAlt(name,officernote)
  if (officernote) then
    local _,_,_,main,_ = string.find(officernote or "","(.*){([^%c%s%d{}][^%c%s%d{}][^%c%s%d{}]*%-?[^%c%s%d{}]*)}(.*)")
    local namelimit = 13
    if main and main:match("%-") == "-" then
      namelimit = 30
    end
    if type(main)=="string" and (strlen(main) < namelimit) then
      main = self:Capitalize(main)
      local g_name, g_class, g_rank, g_officernote, g_rankIndex, roster_index = self:verifyGuildMember(main,true)
      if (g_name) then
        return g_name, g_class, g_rank, g_officernote
      else
        return nil
      end
    else
      return nil
    end
  else
    for i=1,GetNumGuildMembers(true) do
      local g_name, g_rank, g_rankIndex, g_level, g_class, g_zone, g_note, g_officernote, g_online, g_status, g_eclass, _, _, g_mobile, g_sor, _, g_GUID = GetGuildRosterInfo(i)
      g_name = bepgp:Ambiguate(g_name)
      if (name == g_name) then
        return self:parseAlt(g_name, g_officernote)
      end
    end
  end
  return nil
end

-- parse potential Standin (in-guild), return Ally, Ally class, ally epgp (off guild)
function bepgp:parseStandin(officernote) -- {Standin2;ep:gp} -- {<PlayerName><classid>;<epnum>:<gpnum>}
  if (officernote) then
    local allyinfo = officernote:match("%b{}")
    if allyinfo then
      local ally_name,classId,epgpinfo = allyinfo:match("{([^%c%s%d{};][^%c%s%d{};][^%c%s%d{};]*%-?[^%c%s%d{};]*)(%d+);([%d:]*)}")
      classId = tonumber(classId)
      local namelimit = 13
      if ally_name and ally_name:match("%-") == "-" then
        namelimit = 30
      end
      if type(ally_name)=="string" and (strlen(ally_name) < namelimit) then
        ally_name = self:Capitalize(ally_name)
        if ally_name and classId then
          local ally_class = classidToClass[classId]
          local ep, gp
          if epgpinfo then
            ep, gp = epgpinfo:match("(%d+):(%d+)")
            ep = tonumber(ep)
            gp = tonumber(gp)
          end
          return ally_name, ally_class, ep, gp
        else
          return nil
        end
      else
        return nil
      end
    end
  end
  return nil
end

function bepgp:linkAlt(main, alt)
  if not bepgp:admin() then return end
  -- check alt is not linked to another main
  local alts = self.db.profile.alts
  for checkmain, altinfo in pairs(alts) do
    for altname in pairs(altinfo) do
      if altname == alt and checkmain ~= main then
        bepgp:removeAlt(alt)
        break
      end
    end
  end
  local alt_name,alt_class,alt_rank,alt_ofnote,alt_rnkIdx,roster_index = self:verifyGuildMember(alt,true,true)
  if alt_name and roster_index then
    alt_ofnote = alt_ofnote or ""
    local newnote, count
    local epgpinfo = alt_ofnote:match("%b{}")
    if epgpinfo then -- some epgp modifications to the note already (epgp, existing main or ally notation)
    else
      newnote, count = string.gsub(alt_ofnote,main,"{"..main.."}")
      if count == 0 then
        newnote = string.format("{%s}",main)
        newnote = newnote..alt_ofnote
      end
      local notelen = strlen(newnote)
      if notelen > 31 then
        newnote = string.sub(newnote,1,notelen-31)
      end
    end
    if newnote then
      GuildRosterSetOfficerNote(roster_index,newnote,true)
      self:Print(string.format(L["%s set as an Alt of %s"],alt, main))
      self:safeGuildRoster()
    end
  end
end

function bepgp:linkStandin(ally, standin, ally_classid)
  if not bepgp:admin() then return end
  local std_name,std_class,std_rank,std_ofnote,std_rnkIdx,roster_index = self:verifyGuildMember(standin,true,true)
  if std_name and roster_index then -- intended standin exists and is in the guild
    std_ofnote = std_ofnote or ""
    local newnote,count
    local epgpinfo = std_ofnote:match("%b{}")
    if epgpinfo then -- already holds some kind of epgp data (pr, main or ally)
    else
      newnote, count = string.gsub(std_ofnote,ally,"{"..ally)
      if count == 0 then
        newnote = string.format("{%s%d;}",ally,ally_classid)
        newnote = newnote..std_ofnote
      end
      local notelen = strlen(newnote)
      if notelen > 31 then
        newnote = string.sub(newnote,1,notelen-31)
      end
    end
    if newnote then
      GuildRosterSetOfficerNote(roster_index,newnote,true)
      self:Print(string.format(L["%s set as the Stand-in for %s"],standin,ally))
      self:safeGuildRoster()
    end
    -- check its rank matches one allowed for standins
    -- check it's not marked as guildmain alt
    -- check it's not marked as another ally's standin
  end
end

function bepgp:removeAlt(alt)
  if not bepgp:admin() then return end
  local alt_name,alt_class,alt_rank,alt_ofnote,alt_rnkIdx,roster_index = self:verifyGuildMember(alt,true,true)
  if alt_name and roster_index then
    alt_ofnote = alt_ofnote or ""
    local newnote
    local datatype,_,_,_,main = self:parseNote(alt_ofnote, roster_index)
    if datatype == "alt" then
      newnote = alt_ofnote:gsub("{"," ")
      newnote = newnote:gsub("}"," ")
    else
      -- notify warning
    end
    if newnote then
      GuildRosterSetOfficerNote(roster_index,newnote,true)
      self:Print(string.format(L["%s removed as an Alt of %s"],alt,main))
      self:safeGuildRoster()
    end
  end
end

function bepgp:removeStandin(standin)
  if not bepgp:admin() then return end
  local std_name,std_class,std_rank,std_ofnote,std_rnkIdx,roster_index = self:verifyGuildMember(standin,true,true)
  if std_name and roster_index then
    std_ofnote = std_ofnote or ""
    local newnote
    local datatype,_,_,_,ally = self:parseNote(std_ofnote, roster_index)
    if datatype == "standin" then
      newnote = std_ofnote:gsub("{"," ")
      newnote = newnote:gsub("}"," ")
    else
      -- notify warning
    end
    if newnote then
      GuildRosterSetOfficerNote(roster_index,newnote,true)
      self:Print(string.format(L["%s removed as a Stand-in for %s"],standin,ally))
      self:safeGuildRoster()
    end
  end
end

function bepgp:guildCache()
  table.wipe(self.db.profile.guildcache)
  table.wipe(self.db.profile.alts)
  table.wipe(self.db.profile.allies)
  for i = 1, GetNumGuildMembers(true) do
    local member_name,rank,_,level,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    member_name = bepgp:Ambiguate((member_name or ""))
    if member_name and level and (member_name ~= UNKNOWNOBJECT) and (level > 0) then
      self.db.profile.guildcache[member_name] = {l=level,r=rank,c=class,o=(officernote or "")}
    end
  end
  for name,data in pairs(self.db.profile.guildcache) do
    local class,officernote = data.c, data.o
    local main, main_class, main_rank = self:parseAlt(name,officernote)
    if (main) then
      data.m = main
      if ((self._playerName) and (name == self._playerName)) then
        if (not self.db.profile.main) or (self.db.profile.main and self.db.profile.main ~= main) then
          self.db.profile.main = main
          self:Print(string.format(L["Your main has been set to %s"],self.db.profile.main))
        end
      end
      local main_c = C:Colorize(hexClassColor[main_class], main)
      self.db.profile.alts[main] = self.db.profile.alts[main] or {}
      self.db.profile.alts[main].c_name = main_c
      self.db.profile.alts[main][name] = class
    else
      local ally, ally_class = self:parseStandin(officernote)
      if (ally and ally_class) and not self.db.profile.guildcache[ally] then
        if not self.db.profile.allies[ally] then
          self.db.profile.allies[ally] = {}
          self.db.profile.allies[ally].standin = name
          self.db.profile.allies[ally].class = ally_class
          data.a = ally
        else
          local standin = self.db.profile.allies[ally].standin
          if standin and standin ~= name then
            self:debugPrint(L["Duplicate standin detected for ally %q: %s < %s"],ally,standin,name)
          end
        end
      end
    end
  end
  return self.db.profile.guildcache, self.db.profile.alts, self.db.profile.allies
end

function bepgp:buildRosterTable()
  local g, r = { }, { }
  local numGuildMembers = GetNumGuildMembers(true)
  if (self.db.char.raidonly) and self:GroupStatus()=="RAID" then
    for i = 1, MAX_RAID_MEMBERS do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = bepgp:GetRaidRosterInfo(i)
      if name and name ~= _G.UNKNOWNOBJECT then
        name = bepgp:Ambiguate(name)
        if (name) then
          r[name] = true
        end
      end
    end
  end
  for i = 1, numGuildMembers do
    local member_name,rank,_,level,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    if member_name and member_name ~= _G.UNKNOWNOBJECT then
      member_name = bepgp:Ambiguate(member_name)
      local level = tonumber(level)
      local is_raid_level = level and level >= bepgp.VARS.minlevel
      local main, main_class, main_rank = self:parseAlt(member_name,officernote)
      local ally_name, ally_class, ally_ep, ally_gp = self:parseStandin(officernote)
      if (self.db.char.raidonly) and next(r) then
        if is_raid_level and r[member_name] and not ally_name  then
          table.insert(g,{["name"]=member_name,["class"]=class,["onote"]=officernote,["alt"]=(not not main)})
        end
        if r[ally_name] then
          table.insert(g,{["name"]=ally_name,["class"]=ally_class,["onote"]=officernote,["standin"]=member_name})
        end
      else
        if is_raid_level and not ally_name then
          table.insert(g,{["name"]=member_name,["class"]=class,["onote"]=officernote,["alt"]=(not not main)})
        elseif ally_name then
          table.insert(g,{["name"]=ally_name,["class"]=ally_class,["onote"]=officernote,["standin"]=member_name})
        end
      end
    end
  end
  return g
end

function bepgp:buildClassMemberTable(roster,epgp)
  local desc,usage
  if epgp == "ep" then
    desc = L["Account EPs to %s."]
    usage = "<EP>"
  elseif epgp == "gp" then
    desc = L["Account GPs to %s."]
    usage = "<GP>"
  end
  local c = { }
  local order = 0
  for i,member in ipairs(roster) do
    local class,name,is_alt,is_standin = member.class, member.name, member.alt, member.standin
    if (class) and (not is_alt) and (not is_standin) and (c[class] == nil) then
      c[class] = { }
      c[class].type = "group"
      c[class].name = C:Colorize(hexClassColor[class],class)
      c[class].desc = class .. " members"
      c[class].order = order + 1
      c[class].args = { }
    end
    if is_standin and (c["ALLIES"] == nil) then
      c["ALLIES"] = { }
      c["ALLIES"].type = "group"
      c["ALLIES"].name = " "..C:Green(L["Allies"])
      c["ALLIES"].desc = L["Allies"]
      c["ALLIES"].order = 11
      c["ALLIES"].args = { }
    end
    if is_alt and (c["ALTS"] == nil) then
      c["ALTS"] = { }
      c["ALTS"].type = "group"
      c["ALTS"].name = "  ".. C:Silver(L["Alts"])
      c["ALTS"].desc = L["Alts"]
      c["ALTS"].order = 12
      c["ALTS"].args = { }
    end
    local key
    if name and class then
      if is_alt then
        key = "ALTS"
      elseif is_standin then
        key = "ALLIES"
      else
        key = class
      end
    end
    if (key) then
      if key == "ALTS" then
        local initial = strsub(name,1,1)
        if c[key].args[initial] == nil then
          c[key].args[initial] = { }
          c[key].args[initial].type = "group"
          c[key].args[initial].name = initial
          c[key].args[initial].desc = initial
          c[key].args[initial].args = { }
        end
        if c[key].args[initial].args[name] == nil then
          c[key].args[initial].args[name] = { }
          c[key].args[initial].args[name].type = "execute"
          c[key].args[initial].args[name].name = name
          c[key].args[initial].args[name].desc = string.format(desc,name)
          c[key].args[initial].args[name].func = function(info)
            local what = epgp == "ep" and C:Green(L["Effort Points"]) or C:Red(L["Gear Points"])
            if bepgp:checkDialog(addonName.."DialogMemberPoints") then
              LD:Spawn(addonName.."DialogMemberPoints", {epgp, what, name})
            end
          end
        end
      elseif key == "ALLIES" then
        local _,_,hexColor = bepgp:getClassData(class)
        if c[key].args[name] == nil then
          c[key].args[name] = { }
          c[key].args[name].type = "execute"
          c[key].args[name].name = C:Colorize(hexColor,name)
          c[key].args[name].desc = L["standin: "] .. is_standin
          c[key].args[name].func = function(info)
            local what = epgp == "ep" and C:Green(L["Effort Points"]) or C:Red(L["Gear Points"])
            if bepgp:checkDialog(addonName.."DialogMemberPoints") then
              LD:Spawn(addonName.."DialogMemberPoints", {epgp, what, name})
            end
          end
        end
      else
        if (c[key].args[name] == nil) then
          c[key].args[name] = { }
          c[key].args[name].type = "execute"
          c[key].args[name].name = name
          c[key].args[name].desc = string.format(desc,name)
          c[key].args[name].func = function(info)
            local what = epgp == "ep" and C:Green(L["Effort Points"]) or C:Red(L["Gear Points"])
            if bepgp:checkDialog(addonName.."DialogMemberPoints") then
              LD:Spawn(addonName.."DialogMemberPoints", {epgp, what, name})
            end
          end
        end
      end
    end
  end
  return c
end

function bepgp:groupCache(member,update)
  local groupcache = self.db.char.groupcache
  if (groupcache[member] and groupcache[member]["class"]) and (not update) then
    return groupcache[member]
  else
    if self:GroupStatus()=="RAID" then
      groupcache[member] = groupcache[member] or {}
      for i=1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML = bepgp:GetRaidRosterInfo(i)
        name = bepgp:Ambiguate((name or ""))
        if name and (name == member) and (name ~= _G.UNKNOWNOBJECT) then
          local _,_,hexColor = self:getClassData(lclass)
          local colortab = RAID_CLASS_COLORS[eclass]
          groupcache[member]["level"] = level
          groupcache[member]["class"] = lclass
          groupcache[member]["eclass"] = eclass
          groupcache[member]["hex"] = hexColor
          groupcache[member]["color"] = {r=colortab.r, g=colortab.g, b=colortab.b, a=1.0}
          break
        end
      end
      if self:table_count(groupcache[member]) > 0 then
        return groupcache[member]
      end
    end
  end
end

function bepgp:setPlayerName(force)
  if self.db.profile.fullnames then
    self._playerName = (UnitNameUnmodified("player")).."-"..GetNormalizedRealmName()
  else
    self._playerName = UnitNameUnmodified("player")
  end
end

function bepgp:refreshUnitCaches(force)
  self:setPlayerName(force)
  if IsInGuild() then
    self:guildCache()
  end
  local status = self:GroupStatus()
  if status == "RAID" then
    local groupcache = self.db.char.groupcache
    for i=1, MAX_RAID_MEMBERS do
      local name, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML = bepgp:GetRaidRosterInfo(i)
      name = bepgp:Ambiguate((name or ""))
      if name and (name ~= _G.UNKNOWNOBJECT) then
        local _,_,hexColor = self:getClassData(lclass)
        local colortab = RAID_CLASS_COLORS[eclass]
        groupcache[name] = groupcache[name] or {}
        groupcache[name]["level"] = level
        groupcache[name]["class"] = lclass
        groupcache[name]["eclass"] = eclass
        groupcache[name]["hex"] = hexColor
        groupcache[name]["color"] = {r=colortab.r, g=colortab.g, b=colortab.b, a=1.0}
      end
    end
  end
  self:buildRosterTable()
end

function bepgp:sanitizeNote(epgp,postfix)
  local prefix = self
  -- reserve enough chars for the epgp pattern {xxxxx:yyyy} max public/officernote = 31
  local remainder = string.format("%s%s",prefix,postfix)
  local clip = math.min(31-strlen(epgp),strlen(remainder))
  local prepend = string.sub(remainder,1,clip)
  return string.format("%s%s",prepend,epgp)
end

-- returns type ("standin"|"alt"|"epgp")
-- tail arguments per type, also the pre and post epgp pattern text fragments
--  "standin": pre, epgppattern, post, ally, ally_class, ally_ep, ally_gp
--  "alt": pre, epgppattern, post, main
--  "epgp": pre, epgppattern, post, ep, gp
function bepgp:parseNote(officernote, guild_index)
  if not IsInGuild() then return end
  if not (officernote or guild_index) then return end
  if guild_index and not officernote then
    local g_name, g_rank, g_rankIndex, g_level, g_class, g_zone, g_note, g_officernote, g_online, g_status, g_eclass, _, _, g_mobile, g_sor, _, g_GUID = GetGuildRosterInfo(guild_index)
    if g_officernote then
      return bepgp:parseNote(g_officernote)
    else
      return
    end
  end
  local officernote = officernote or ""
  local pre, epgpdata, post = officernote:match("(.*)(%b{})(.*)")
  local main, ally, ally_class, ep, gp, epgp
  if epgpdata and #epgpdata>3 then
    local namelimit = 13
    ally, ally_class, epgp = epgpdata:match("{([^%c%s%d{};][^%c%s%d{};][^%c%s%d{};]*%-?[^%c%s%d{};]*)(%d+);([%d:]*)}")
    if ally and ally:match("%-") == "-" then
      namelimit = 30
    end
    if ally and strlen(ally)<namelimit and ally_class then
      ep, gp = epgp:match("(%d+):(%d+)")
      ep = tonumber(ep) or 0
      gp = tonumber(gp) or bepgp.VARS.basegp
      return "standin", pre, epgpdata, post, ally, tonumber(ally_class), ep, gp
    end
    main = epgpdata:match("{([^%c%s%d{}][^%c%s%d{}][^%c%s%d{}]*%-?[^%c%s%d{}]*)}")
    namelimit = 13
    if main and main:match("%-") == "-" then
      namelimit = 30
    end
    if main and strlen(main)<namelimit then
      return "alt", pre, epgpdata, post, main
    end
    ep, gp = epgpdata:match("{(%d+):(%d+)}")
    ep = tonumber(ep) or 0
    gp = tonumber(gp) or bepgp.VARS.basegp
    if ep and gp then
      return "epgp", pre, epgpdata, post, ep, gp
    end
  end
  -- test for: <epgp pattern>, <mainname pattern>, <allyinfo pattern>
end

function bepgp:award_raid_ep(ep) -- awards ep to raid members in zone
  if IsInRaid() and GetNumGroupMembers() > 1 then
    local guildcache = self:guildCache()
    for i = 1, MAX_RAID_MEMBERS do
      local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = bepgp:GetRaidRosterInfo(i)
      if name and name ~= _G.UNKNOWNOBJECT then
        if level == 0 or (not online) then
          level = (guildcache[name] and guildcache[name].l) or 0
          self:Print(string.format(L["%s is offline. Getting info from guild cache."],name))
        end
        if level >= bepgp.VARS.minlevel then
          local main = guildcache[name] and guildcache[name].m or false
          if main and self:inRaid(main) then
            self:Print(string.format(L["Skipping %s. Main %q is also in the raid."],name,main))
          else
            self:givename_ep(name,ep)
          end
        end
      end
    end
    self:simpleSay(string.format(L["Giving %d ep to all raidmembers"],ep))
    local logs = self:GetModule(addonName.."_logs",true)
    if logs then
      logs:addToLog(string.format(L["Giving %d ep to all raidmembers"],ep))
    end
    self:refreshPRTablets()
    local addonMsg = string.format("RAID;AWARD;%s",ep)
    self:addonMessage(addonMsg,"RAID")
    local comms = bepgp:GetModule(addonName.."_comms",true)
    if comms then
      comms:Transmit(comms:GetDataForSending(),"GUILD")
    end
  --[[else UIErrorsFrame:AddMessage(L["You aren't in a raid dummy"],1,0,0)]]
  end
end

function bepgp:award_standby_ep(ep) -- awards ep to reserve list
  local standby = self:GetModule(addonName.."_standby",true)
  if standby then
    if #(standby.roster) > 0 then
      self:guildCache()
      for i, standby in ipairs(standby.roster) do
        local name, class, rank, alt = unpack(standby)
        self:givename_ep(name, ep)
      end
      self:simpleSay(string.format(L["Giving %d ep to active standby"],ep))
      local logs = self:GetModule(addonName.."_logs",true)
      if logs then
        logs:addToLog(string.format(L["Giving %d ep to active standby"],ep))
      end
      local addonMsg = string.format("STANDBY;AWARD;%s",ep)
      self:addonMessage(addonMsg,"GUILD")
      table.wipe(standby.roster)
      table.wipe(standby.blacklist)
      self:refreshPRTablets()
      local standby = self:GetModule(addonName.."_standby",true)
      if standby then
        standby:Refresh()
      end
    end
  end
end

function bepgp:decay_epgp()
  if not (bepgp:admin()) then return end
  local decay = self.db.profile.decay
  local announce = self.db.profile.announce
  for i = 1, GetNumGuildMembers(true) do
    local name,_,_,_,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    local ep,gp = self:get_ep(name,officernote), self:get_gp(name,officernote)
    if (ep and gp) then
      ep = self:num_round(ep*decay)
      gp = self:num_round(gp*decay)
      self:update_epgp(ep,gp,i,name,officernote)
    end
  end
  local msg = string.format(L["All EP and GP decayed by %s%%"],(1-decay)*100)
  self:simpleSay(msg)
  if not (announce=="OFFICER") then self:adminSay(msg) end
  local logs = self:GetModule(addonName.."_logs",true)
  if logs then
    logs:addToLog(msg)
  end
  self:refreshPRTablets()
  local addonMsg = string.format("ALL;DECAY;%s",(1-(decay or bepgp.VARS.decay))*100)
  self:addonMessage(addonMsg,"GUILD")
  local comms = bepgp:GetModule(addonName.."_comms",true)
  if comms then
    comms:Transmit(comms:GetDataForSending(),"GUILD")
  end
end

function bepgp:wipe_epgp()
  if not IsGuildLeader() then return end
  local announce = self.db.profile.announce
  for i = 1, GetNumGuildMembers(true) do
    local name,_,_,_,class,_,note,officernote,_,_ = GetGuildRosterInfo(i)
    local ep,gp = self:get_ep(name,officernote), self:get_gp(name,officernote)
    if (ep and gp) then
      self:update_epgp(0,bepgp.VARS.basegp,i,name,officernote)
    end
  end
  local msg = L["All EP and GP data has been reset."]
  self:simpleSay(msg)
  if not (announce=="OFFICER") then self:adminSay(msg) end
  local logs = self:GetModule(addonName.."_logs",true)
  if logs then
    logs:addToLog(msg)
  end
  self:refreshPRTablets()
  local comms = bepgp:GetModule(addonName.."_comms",true)
  if comms then
    comms:Transmit(comms:GetDataForSending(),"GUILD")
  end
end

function bepgp:get_ep(getname,officernote) -- gets ep by name or note
  local canViewONote = bepgp.CanViewOfficerNote()
  local cacheDB
  local bepgp_comms = bepgp:GetModule(addonName.."_comms",true)
  if bepgp_comms and bepgp_comms.db then
    cacheDB = bepgp_comms.db.profile.epgp
  end
  if canViewONote then
  local allies = self.db.profile.allies
    if allies[getname] then
      local standin = allies[getname].standin
      --print("getting standin")
      return bepgp:get_ep(standin)
    end
    if (officernote) then
      local datatype, prefix, epgpdata, postfix, t1, t2, t3, t4 = self:parseNote(officernote)
      --print(datatype)
      if datatype == "epgp" then
        local ep, gp = t1, t2
        return ep
      elseif datatype == "standin" then
        local ally_name, ally_class, ally_ep, ally_gp = t1, t2, t3, t4
        --print("%s:%s:%s",ally_name,ally_class,ally_ep)
        return ally_ep
      else
        return
      end
    end
    for i = 1, GetNumGuildMembers(true) do
      local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
      name = bepgp:Ambiguate(name)
      if (name == getname) and officernote then
        return bepgp:get_ep(getname,officernote)
      end
    end
    return
  elseif (cacheDB) then
    local epgp = cacheDB[getname]
    if epgp then
      local _epoch = cacheDB._epoch
      return (cacheDB[getname][1] or 0), _epoch
    end
  end
end

function bepgp:get_gp(getname,officernote) -- gets gp by name or officernote
  local canViewONote = bepgp.CanViewOfficerNote()
  local cacheDB
  local bepgp_comms = bepgp:GetModule(addonName.."_comms",true)
  if bepgp_comms and bepgp_comms.db then
    cacheDB = bepgp_comms.db.profile.epgp
  end
  if canViewONote then
    local allies = self.db.profile.allies
    if allies[getname] then
      local standin = allies[getname].standin
      return bepgp:get_gp(standin)
    end
    if (officernote) then
      local datatype, prefix, epgpdata, postfix, t1, t2, t3, t4 = self:parseNote(officernote)
      if datatype == "epgp" then
        local ep, gp = t1, t2
        return gp
      elseif datatype == "standin" then
        local ally_name, ally_class, ally_ep, ally_gp = t1, t2, t3, t4
        return ally_gp
      else
        return
      end
    end
    for i = 1, GetNumGuildMembers(true) do
      local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
      name = bepgp:Ambiguate(name)
      if (name == getname) and officernote then
        return bepgp:get_gp(getname,officernote)
      end
    end
    return
  elseif (cacheDB) then
    local epgp = cacheDB[getname]
    if epgp then
      local _epoch = cacheDB._epoch
      return (cacheDB[getname][2] or bepgp.VARS.basegp), _epoch
    end
  end
end

function bepgp:init_notes(guild_index,name,officernote)
  local datatype, prefix, epgpdata, postfix, t1, t2, t3, t4 = self:parseNote(officernote,guild_index)
  if datatype == "epgp" then
    local ep, gp = t1, t2
    officernote = string.gsub(officernote,"(.*)({%d+:%d+})(.*)",self.sanitizeNote)
  elseif datatype == "standin" then
    local ally_name, ally_class, ally_ep, ally_gp = t1, t2, t3, t4
    epgpdata = string.format("{%s%d;%d:%d}",ally_name,ally_class,ally_ep,ally_gp)
    local newnote = string.gsub(officernote,"%b{}",epgpdata)
    newnote = string.gsub(newnote,"(.*)({[^%c%s%d{};][^%c%s%d{};][^%c%s%d{};]*%d+;[%d:]*})(.*)",self.sanitizeNote)
    officernote = newnote
  elseif datatype == "alt" then
    local main = t1
  else -- no epgp infoblock found, add a standard {ep:gp} string
    epgpdata = string.format("{%d:%d}",0,100)
    local newnote = string.format("%s%s",officernote,epgpdata)
    newnote = string.gsub(newnote,"(.*)({%d+:%d+})(.*)",self.sanitizeNote)
    officernote = newnote
  end
  GuildRosterSetOfficerNote(guild_index,officernote,true)
  return officernote, datatype
end

function bepgp:update_epgp(ep,gp,guild_index,name,officernote,special_action)
  local officernote, datatype = self:init_notes(guild_index,name,officernote)
  local newnote
  if (ep) then
    ep = math.max(0,ep)
    newnote = string.gsub(officernote,"(.*[{;])(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
      return string.format("%s%s%s%s%s",head,ep,divider,oldgp,tail)
      end)
  end
  if (gp) then
    gp = math.max(100,gp)
    if (newnote) then
      newnote = string.gsub(newnote,"(.*[{;])(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
        return string.format("%s%s%s%s%s",head,oldep,divider,gp,tail)
        end)
    else
      newnote = string.gsub(officernote,"(.*[{;])(%d+)(:)(%d+)(}.*)",function(head,oldep,divider,oldgp,tail)
        return string.format("%s%s%s%s%s",head,oldep,divider,gp,tail)
        end)
    end
  end
  if (newnote) then
    newnote = string.gsub(newnote,"(.*)(%b{})(.*)",bepgp.sanitizeNote)
    GuildRosterSetOfficerNote(guild_index,newnote,true)
  end
end

function bepgp:givename_ep(getname,ep,single) -- awards ep to a single character
  if not (self:admin()) then return end
  local postfix, alt, ally = ""
  local guildcache = self.db.profile.guildcache
  local main = guildcache[getname] and guildcache[getname].m or false
  local logs = self:GetModule(addonName.."_logs",true)
  if (main) then
    if self.db.profile.altspool then
      alt = getname
      getname = main
      ep = self:num_round(ep * self.db.profile.altpercent)
      postfix = string.format(L[", %s\'s Main."],alt)
    else
      local msg = string.format(L["%s is %s and %s is an Alt of %s. Skipping %s."],L["Enable Alts"],_G.OFF,getname,main,string.upper(L["ep"]))
      self:debugPrint(msg)
      if logs then
        logs:addToLog(msg)
      end
      return
    end
  end
  local allies = self.db.profile.allies
  if allies[getname] then
    local standin = allies[getname].standin
    if (standin) then
      if self.db.profile.allypool then
        ally = getname
        getname = standin
        postfix = string.format(L[", %s\'s Standin"],ally)
      else
        local msg = string.format(L["%s is %s and %s is an Ally with %s standin. Skipping %s."],L["Enable Allies"],_G.OFF,ally,getname,string.upper(L["ep"]))
        self:debugPrint(msg)
        if logs then
          logs:addToLog(msg)
        end
      end
    end
  end
  local newep = ep + (self:get_ep(getname) or 0)
  self:update_ep(getname,newep)
  local msg = string.format(L["Giving %d ep to %s%s."],ep,getname,postfix)
  local addonMsg = string.format("%s;%s;%s",getname,"EP",ep)
  if ep < 0 then -- inform member of penalty
    msg = string.format(L["%s EP Penalty to %s%s."],ep,getname,postfix)
    self:debugPrint(msg)
    self:adminSay(msg)
    if logs then
      logs:addToLog(msg)
    end
    self:addonMessage(addonMsg,"WHISPER",getname)
  else
    self:debugPrint(msg)
    if (single == true) then
      self:adminSay(msg)
      if logs then
        logs:addToLog(msg)
      end
      self:addonMessage(addonMsg,"WHISPER",getname)
    end
  end
  local comms = bepgp:GetModule(addonName.."_comms",true)
  if comms and single then
    comms:Transmit(comms:GetDataForSending(),"GUILD")
  end
end

function bepgp:givename_gp(getname,gp) -- assigns gp to a single character
  if not (self:admin()) then return end
  local postfix, alt, ally = ""
  local guildcache = self.db.profile.guildcache
  local main = guildcache[getname] and guildcache[getname].m or false
  local logs = self:GetModule(addonName.."_logs",true)
  if (main) then
    if self.db.profile.altspool then
      alt = getname
      getname = main
      postfix = string.format(L[", %s\'s Main."],alt)
    else
      local msg = string.format(L["%s is %s and %s is an Alt of %s. Skipping %s."],L["Enable Alts"],_G.OFF,getname,main,string.upper(L["gp"]))
      self:debugPrint(msg)
      if logs then
        logs:addToLog(msg)
      end
      return
    end
  end
  local allies = self.db.profile.allies
  if allies[getname] then
    local standin = allies[getname].standin
    if (standin) then
      if self.db.profile.allypool then
        ally = getname
        getname = standin
        postfix = string.format(L[", %s\'s Standin"],ally)
      else
        local msg = string.format(L["%s is %s and %s is an Ally with %s standin. Skipping %s."],L["Enable Allies"],_G.OFF,ally,getname,string.upper(L["gp"]))
        self:debugPrint(msg)
        if logs then
          logs:addToLog(msg)
        end
      end
    end
  end
  local oldgp = (self:get_gp(getname) or bepgp.VARS.basegp)
  local newgp = gp + oldgp
  self:update_gp(getname,newgp)
  self:debugPrint(string.format(L["Giving %d gp to %s%s."],gp,getname,postfix))
  local msg = string.format(L["Awarding %d GP to %s%s. (Previous: %d, New: %d)"],gp,getname,postfix,oldgp,math.max(bepgp.VARS.basegp,newgp))
  self:adminSay(msg)
  if logs then
    logs:addToLog(msg)
  end
  local addonMsg = string.format("%s;%s;%s",getname,"GP",gp)
  self:addonMessage(addonMsg,"WHISPER",getname)
  local comms = bepgp:GetModule(addonName.."_comms",true)
  if comms then
    comms:Transmit(comms:GetDataForSending(),"GUILD")
  end
end

function bepgp:update_ep(getname,ep)
  for i = 1, GetNumGuildMembers(true) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    name = bepgp:Ambiguate(name)
    if (name==getname) then
      self:update_epgp(ep,nil,i,name,officernote)
    end
  end
end
function bepgp:update_gp(getname,gp)
  for i = 1, GetNumGuildMembers(true) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    name = bepgp:Ambiguate(name)
    if (name==getname) then
      self:update_epgp(nil,gp,i,name,officernote)
    end
  end
end

function bepgp:capcalc(ep,gp,gain)
  -- CAP_EP = EP_GAIN*DECAY/(1-DECAY) CAP_PR = CAP_EP/base_gp
  local pr = ep/gp
  local ep_decayed = self:num_round(ep*self.db.profile.decay)
  local gp_decayed = math.max(bepgp.VARS.basegp,self:num_round(gp*self.db.profile.decay))
  local pr_decay = tonumber(string.format("%.03f",pr))-tonumber(string.format("%.03f",ep_decayed/gp_decayed))
  if (pr_decay < 0.1) then
    pr_decay = 0
  else
    pr_decay = -tonumber(string.format("%.02f",pr_decay))
  end
  local cycle_gain = tonumber(gain)
  local cap_ep, cap_pr
  if (cycle_gain) then
    cap_ep = self:num_round(cycle_gain*self.db.profile.decay/(1-self.db.profile.decay))
    cap_pr = tonumber(string.format("%.03f",cap_ep/bepgp.VARS.basegp))
  end
  return pr_decay, cap_ep, cap_pr
end

function bepgp:refreshPRTablets()
  local standings = self:GetModule(addonName.."_standings",true)
  if standings then
    standings:Refresh()
  end
  local bids = self:GetModule(addonName.."_bids",true)
  if bids then
    bids:Refresh()
  end
  local plusroll_bids = self:GetModule(addonName.."_plusroll_bids",true)
  if plusroll_bids then
    plusroll_bids:Refresh()
  end
  local browser = self:GetModule(addonName.."_browser",true)
  if browser then
    browser:Refresh()
  end
end

_G[addonName] = bepgp
