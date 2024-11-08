local addonName, bepgp = ...
local moduleName = addonName.."_tokens_cata"
local bepgp_tokens_cata = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local tokens = {} -- item = token
local rewards = {} -- token = items
local last_reward_flipped = {} -- token = reward
local item_upgrades = {} -- baseitemid = token
-- crystallized firestone for now
item_upgrades[68915] = 71617
item_upgrades[68972] = 71617
item_upgrades[70929] = 71617
item_upgrades[70939] = 71617
item_upgrades[71146] = 71617
item_upgrades[71147] = 71617
item_upgrades[71148] = 71617
item_upgrades[71149] = 71617
item_upgrades[71150] = 71617
item_upgrades[71151] = 71617
item_upgrades[71152] = 71617
item_upgrades[71154] = 71617
item_upgrades[71218] = 71617
item_upgrades[71359] = 71617
item_upgrades[71360] = 71617
item_upgrades[71361] = 71617
item_upgrades[71362] = 71617
item_upgrades[71365] = 71617
item_upgrades[71366] = 71617
item_upgrades[71367] = 71617
item_upgrades[71640] = 71617

-- T11.359 (normal)
rewards[63682] = { 60341,60351, 60277,60282,60286, 60243, 60299  } -- Helm of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[63683] = { 60346,60356,60359, 60256,60258, 60249 } -- Helm of the Forlorn Conqueror (paladin/priest/warlock)
rewards[63684] = { 60303, 60308,60315,60320, 60325,60328 } -- Helm of the Forlorn Protector (hunter/shaman/warrior)
rewards[64314] = { 60343,60353, 60279,60284,60289, 60246, 60302 } -- Mantle of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[64315] = { 60348,60358,60362, 60253,60262, 60252 } -- Mantle of the Forlorn Conqueror (paladin/priest/warlock)
rewards[64316] = { 60306, 60311,60317,60322, 60327,60331 } -- Mantle of the Forlorn Protector (hunter/shaman/warrior)
-- T11.372 (heroic)
rewards[65000] = { 65206, 65246,65251,65256, 65266,65271 } -- Crown of the Forlorn Protector (hunter/shaman/warrior)
rewards[65001] = { 65216,65221,65226, 65230,65235, 65260 } -- Crown of the Forlorn Conqueror (paladin/priest/warlock)
rewards[65002] = { 65181,65186, 65190,65195,65200, 65210, 65241 } -- Crown of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[65087] = { 65208, 65248,65253,65258, 65268,65273 } -- Shoulders of the Forlorn Protector (hunter/shaman/warrior)
rewards[65088] = { 65218,65223,65228, 65233,65238, 65263 } -- Shoulders of the Forlorn Conqueror (paladin/priest/warlock)
rewards[65089] = { 65183,65188, 65193,65198,65203, 65213, 65243 } -- Shoulders of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67423] = { 65214,65219,65224, 65232,65237, 65262 } -- Chest of the Forlorn Conqueror (paladin/priest/warlock)
rewards[67424] = { 65204, 65244,65249,65254, 65264,65269 } -- Chest of the Forlorn Protector (hunter/shaman/warrior)
rewards[67425] = { 65179,65184, 65192,65197,65202, 65212, 65239 } -- Chest of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67429] = { 65215,65220,65225, 65229,65234, 65259 } -- Gauntlets of the Forlorn Conqueror (paladin/priest/warlock)
rewards[67430] = { 65205, 65245,65250,65255, 65265,65270 } -- Gauntlets of the Forlorn Protector (hunter/shaman/warrior)
rewards[67431] = { 65180,65185, 65189,65194,65199, 65209, 65240 } -- Gauntlets of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67426] = { 65182,65187, 65191,65196,65201, 65211, 65242 } -- Leggings of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67427] = { 65207, 65247,65252,65257, 65267,65272 } -- Leggings of the Forlorn Protector (hunter/shaman/warrior)
rewards[67428] = { 65217,65222,65227, 65231,65236, 65261 } -- Leggings of the Forlorn Conqueror (paladin/priest/warlock)
rewards[66998] = { 67423,67424,67425,67429,67430,67431,67426,67427,67428 } -- Essence of the Forlorn
  -- T12.378 (normal)
rewards[71668] = { 70954,71060, 71098,71103,71108, 71287, 71047 } -- Helm of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71675] = { 70948,71065,71093, 71272,71277, 71282 } -- Helm of the Fiery Conqueror (paladin/priest/warlock)
rewards[71682] = { 71051, 71293,71298,71303, 70944,71070 } -- Helm of the Fiery Protector (hunter/shaman/warrior)
rewards[71674] = { 70951,71062, 71101,71106,71111, 71290, 71049 } -- Mantle of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71681] = { 70946,71067,71095, 71275,71280, 71285 } -- Mantle of the Fiery Conqueror (paladin/priest/warlock)
rewards[71688] = { 71053, 71295,71300,71305, 70941,71072 } -- Mantle of the Fiery Protector (hunter/shaman/warrior)
-- T12.391 (heroic)
rewards[71670] = { 71478,71483, 71488,71492,71497, 71508, 71539 } -- Crown of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71677] = { 71514,71519,71524, 71528,71533, 71595 } -- Crown of the Fiery Conqueror (paladin/priest/warlock)
rewards[71684] = { 71503, 71544,71549,71554, 71599,71606 } -- Crown of the Fiery Protector (hunter/shaman/warrior)
rewards[71673] = { 71480,71485, 71490,71495,71500, 71511, 71541 } -- Shoulders of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71680] = { 71516,71521,71526, 71531,71536, 71598 } -- Shoulders of the Fiery Conqueror (paladin/priest/warlock)
rewards[71687] = { 71505, 71546,71551,71556, 71603,71608 } -- Shoulders of the Fiery Protector (hunter/shaman/warrior)
rewards[71672] = { 71476,71481, 71486,71494,71499, 71510, 71537 } -- Chest of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71679] = { 71512,71517,71522, 71530,71535, 71597 } -- Chest of the Fiery Conqueror (paladin/priest/warlock)
rewards[71686] = { 71501, 71542,71547,71552, 71600,71604 } -- Chest of the Fiery Protector (hunter/shaman/warrior)
rewards[71669] = { 71477,71482, 71487,71491,71496, 71507, 71538 } -- Gauntlets of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71676] = { 71513,71518,71523, 71527,71532, 71594 } -- Gauntlets of the Fiery Conqueror (paladin/priest/warlock)
rewards[71683] = { 71502, 71543,71548,71553, 71601,71605 } -- Gauntlets of the Fiery Protector (hunter/shaman/warrior)
rewards[71671] = { 71479,71484, 71489,71493,71498, 71509, 71540 } -- Leggings of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71678] = { 71515,71520,71525, 71529,71534, 71596 } -- Leggings of the Fiery Conqueror (paladin/priest/warlock)
rewards[71685] = { 71504, 71545,71550,71555, 71602,71607 } -- Leggings of the Fiery Protector (hunter/shaman/warrior)
rewards[71617] = { 69109, 69113, 71557, 71558, 71559, 71560, 71561, 71562, 71563, 71564, 71567, 71568, 71575, 71577, 71579, 71580, 71587, 71590, 71592, 71593, 71641 } -- Crystallized Firestone (various)
-- T13.397 (normal)
rewards[78172] = { 76976,77010, 76750,77015,77019, 76213, 77025 } -- Crown of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78177] = { 77030, 76758,77037,77042, 76983,76990 } -- Crown of the Corrupted Protector (hunter/shaman/warrior)
rewards[78182] = { 76767,76876,77005, 76347,76358, 76342 } -- Crown of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78170] = { 76978,77012, 76753,77017,77022, 76216, 77027 } -- Shoulders of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78175] = { 77032, 76760,77035,77044, 76987,76992 } -- Shoulders of the Corrupted Protector (hunter/shaman/warrior)
rewards[78180] = { 76769,76878,77007, 76344,76361, 76339 } -- Shoulders of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78174] = { 76974,77008, 76752,77013,77021, 76215, 77023 } -- Chest of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78179] = { 77028, 76756,77039,77040, 76984,76988 } -- Chest of the Corrupted Protector (hunter/shaman/warrior)
rewards[78184] = { 76765,76874,77003, 76345,76360, 76340 } -- Chest of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78173] = { 76975,77009, 76749,77014,77018, 76212, 77024 } -- Gauntlets of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78178] = { 77029, 76757,77038,77041, 76985,76989 } -- Gauntlets of the Corrupted Protector (hunter/shaman/warrior)
rewards[78183] = { 76766,76875,77004, 76348,76357, 76343 } -- Gauntlets of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78171] = { 76977,77011, 76751,77016,77020, 76214, 77026 } -- Leggings of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78176] = { 77031, 76759,77036,77043, 76986,76991 } -- Leggings of the Corrupted Protector (hunter/shaman/warrior)
rewards[78181] = { 76768,76877,77006, 76346,76359, 76341 } -- Leggings of the Corrupted Conqueror (paladin/priest/warlock)
-- T13.410 (heroic)
rewards[78850] = { 78692,78693,78695, 78700,78703, 78702 } -- Crown of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78851] = { 78698, 78685,78686,78691, 78688,78689 } -- Crown of the Corrupted Protector (hunter/shaman/warrior)
rewards[78852] = { 78687,78697, 78690,78694,78696, 78701, 78699 } -- Crown of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78859] = { 78742,78745,78746, 78747,78750, 78749 } -- Shoulders of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78860] = { 78737, 78733,78739,78741, 78734,78735 } -- Shoulders of the Corrupted Protector (hunter/shaman/warrior)
rewards[78861] = { 78736,78751, 78740,78743,78744, 78748, 78738 } -- Shoulders of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78847] = { 78726,78727,78732, 78728,78731, 78730 } -- Chest of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78848] = { 78661, 78723,78724,78725, 78657,78658 } -- Chest of the Corrupted Protector (hunter/shaman/warrior)
rewards[78849] = { 78659,78663, 78660,78662,78665, 78729, 78664 } -- Chest of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78853] = { 78673,78675,78677, 78682,78683, 78681 } -- Gauntlets of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78854] = { 78674, 78666,78667,78672, 78668,78669 } -- Gauntlets of the Corrupted Protector (hunter/shaman/warrior)
rewards[78855] = { 78670,78678, 78676,78680,78684, 78671, 78679 } -- Gauntlets of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78856] = { 78712,78715,78717, 78719,78722, 78721 } -- Leggings of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78857] = { 78709, 78704,78711,78718, 78705,78706 } -- Leggings of the Corrupted Protector (hunter/shaman/warrior)
rewards[78858] = { 78707,78716, 78710,78713,78714, 78720, 78708 } -- Leggings of the Corrupted Vanquisher (dk/druid/mage/rogue)

local token_info = {}
local token_info_string = {}
local item_icon_markup = setmetatable({},{__index = function(t,k)
  local markup = CreateTextureMarkup(k,32, 32, 16, 16, 0, 1, 0, 1)
  rawset(t,k,markup)
  return markup
end})
local item_cache = {}

function bepgp_tokens_cata:GetReward(token)
  local reward = rewards[token]
  if reward then
    local count = #reward
    if count > 1 then
      return reward -- array
    elseif count == 1 then
      return reward[1] -- number
    end
  end
end

function bepgp_tokens_cata:GetToken(reward)
  return tokens[reward] or nil
end

function bepgp_tokens_cata:ItemUpgradeString(baseItem)
  if not (type(baseItem)=="number" or type(baseItem)=="string") then return end
  local baseitemID = bepgp.GetItemInfoInstant(baseItem)
  if not baseitemID then return end
  local tokenID = item_upgrades[baseitemID]
  if not tokenID then return end
  local _,_,_,_,icon = bepgp.GetItemInfoInstant(tokenID)
  local markup = item_icon_markup[icon]
  return string.format("%s +%s",L["|cff00ff00Upgradeable:|r"],(markup or tokenID))
end

function bepgp_tokens_cata:RewardItemString(tokenItem)
  if not (type(tokenItem)=="number" or type(tokenItem)=="string") then return end
  local tokenID = bepgp.GetItemInfoInstant(tokenItem)
  if not tokenID then return end
  local rewardID = last_reward_flipped[tokenID]
  if rewardID then
    if item_cache[rewardID] then
      return item_cache[rewardID]
    else
      local rewardAsync = Item:CreateFromItemID(rewardID)
      rewardAsync:ContinueOnItemLoad(function()
        local link = rewardAsync:GetItemLink()
        item_cache[rewardID] = link
      end)
      return format("item:%d",rewardID)
    end
  end
end

function bepgp_tokens_cata:TokensItemString(rewardItem)
  if not (type(rewardItem)=="number" or type(rewardItem)=="string") then return end
  local rewardID = bepgp.GetItemInfoInstant(rewardItem)
  if not rewardID then return end
  local tokenID = tokens[rewardID]
  if tokenID then
    if token_info[rewardID] and token_info[rewardID].done then
      if not token_info_string[rewardID] then
        token_info_string[rewardID] = token_info[rewardID].link
      end
      last_reward_flipped[tokenID] = rewardID
      return token_info_string[rewardID], tokenID
    else
      bepgp_tokens_cata:cacheRequiredToken(tokenID, rewardID)
      return format("item:%d",tokenID), tokenID
    end
  end
end

function bepgp_tokens_cata:cacheRequiredToken(tokenID,rewardID)
  local tokenAsync = Item:CreateFromItemID(tokenID)
  tokenAsync:ContinueOnItemLoad(function()
    local itemName = tokenAsync:GetItemName()
    local itemLink = tokenAsync:GetItemLink()
    local itemIcon = tokenAsync:GetItemIcon()
    token_info[rewardID] = {name=itemName,link=itemLink,icon=itemIcon}
    token_info[rewardID].done = true
  end)
end

function bepgp_tokens_cata:cacheTokens()
  for tokenID, rewardData in pairs(rewards) do
    for _, rewardID in pairs(rewardData) do
      tokens[rewardID] = tokenID
    end
  end
end

function bepgp_tokens_cata:delayInit()
  for rewardID, tokenID in pairs(tokens) do
    self:cacheRequiredToken(tokenID,rewardID)
  end
  self._initDone = true
end

function bepgp_tokens_cata:CoreInit()
  self:cacheTokens()
  bepgp.TokensItemString = self.TokensItemString
  bepgp.RewardItemString = self.RewardItemString
  bepgp.ItemUpgradeString = self.ItemUpgradeString
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_tokens_cata:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end
