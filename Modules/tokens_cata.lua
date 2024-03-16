local addonName, bepgp = ...
local moduleName = addonName.."_tokens_cata"
local bepgp_tokens_cata = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local tokens = {} -- item = token
local rewards = {} -- token = items
local last_reward_flipped = {} -- token = reward

-- T11.359 (normal)
rewards[63682] = {  } -- Helm of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[63683] = {  } -- Helm of the Forlorn Conqueror (paladin/priest/warlock)
rewards[63684] = {  } -- Helm of the Forlorn Protector (hunter/shaman/warrior)
rewards[64314] = {  } -- Mantle of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[64315] = {  } -- Mantle of the Forlorn Conqueror (paladin/priest/warlock)
rewards[64316] = {  } -- Mantle of the Forlorn Protector (hunter/shaman/warrior)
-- T11.372 (heroic)
rewards[65000] = {  } -- Crown of the Forlorn Protector (hunter/shaman/warrior)
rewards[65001] = {  } -- Crown of the Forlorn Conqueror (paladin/priest/warlock)
rewards[65002] = {  } -- Crown of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[65087] = {  } -- Shoulders of the Forlorn Protector (hunter/shaman/warrior)
rewards[65088] = {  } -- Shoulders of the Forlorn Conqueror (paladin/priest/warlock)
rewards[65089] = {  } -- Shoulders of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67423] = {  } -- Chest of the Forlorn Conqueror (paladin/priest/warlock)
rewards[67424] = {  } -- Chest of the Forlorn Protector (hunter/shaman/warrior)
rewards[67425] = {  } -- Chest of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67429] = {  } -- Gauntlets of the Forlorn Conqueror (paladin/priest/warlock)
rewards[67430] = {  } -- Gauntlets of the Forlorn Protector (hunter/shaman/warrior)
rewards[67431] = {  } -- Gauntlets of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67426] = {  } -- Leggings of the Forlorn Vanquisher (dk/druid/mage/rogue)
rewards[67427] = {  } -- Leggings of the Forlorn Protector (hunter/shaman/warrior)
rewards[67428] = {  } -- Leggings of the Forlorn Conqueror (paladin/priest/warlock)
rewards[66998] = {  } -- Essence of the Forlorn
  -- T12.378 (normal)
rewards[71668] = {  } -- Helm of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71675] = {  } -- Helm of the Fiery Conqueror (paladin/priest/warlock)
rewards[71682] = {  } -- Helm of the Fiery Protector (hunter/shaman/warrior)
rewards[71674] = {  } -- Mantle of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71681] = {  } -- Mantle of the Fiery Conqueror (paladin/priest/warlock)
rewards[71688] = {  } -- Mantle of the Fiery Protector (hunter/shaman/warrior)
-- T12.391 (heroic)
rewards[71670] = {  } -- Crown of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71677] = {  } -- Crown of the Fiery Conqueror (paladin/priest/warlock)
rewards[71684] = {  } -- Crown of the Fiery Protector (hunter/shaman/warrior)
rewards[71673] = {  } -- Shoulders of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71680] = {  } -- Shoulders of the Fiery Conqueror (paladin/priest/warlock)
rewards[71687] = {  } -- Shoulders of the Fiery Protector (hunter/shaman/warrior)
rewards[71672] = {  } -- Chest of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71679] = {  } -- Chest of the Fiery Conqueror (paladin/priest/warlock)
rewards[71686] = {  } -- Chest of the Fiery Protector (hunter/shaman/warrior)
rewards[71669] = {  } -- Gauntlets of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71676] = {  } -- Gauntlets of the Fiery Conqueror (paladin/priest/warlock)
rewards[71683] = {  } -- Gauntlets of the Fiery Protector (hunter/shaman/warrior)
rewards[71671] = {  } -- Leggings of the Fiery Vanquisher (dk/druid/mage/rogue)
rewards[71678] = {  } -- Leggings of the Fiery Conqueror (paladin/priest/warlock)
rewards[71685] = {  } -- Leggings of the Fiery Protector (hunter/shaman/warrior)
-- T13.397 (normal)
rewards[78172] = {  } -- Crown of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78177] = {  } -- Crown of the Corrupted Protector (hunter/shaman/warrior)
rewards[78182] = {  } -- Crown of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78170] = {  } -- Shoulders of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78175] = {  } -- Shoulders of the Corrupted Protector (hunter/shaman/warrior)
rewards[78180] = {  } -- Shoulders of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78174] = {  } -- Chest of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78179] = {  } -- Chest of the Corrupted Protector (hunter/shaman/warrior)
rewards[78184] = {  } -- Chest of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78173] = {  } -- Gauntlets of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78178] = {  } -- Gauntlets of the Corrupted Protector (hunter/shaman/warrior)
rewards[78183] = {  } -- Gauntlets of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78171] = {  } -- Leggings of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78176] = {  } -- Leggings of the Corrupted Protector (hunter/shaman/warrior)
rewards[78181] = {  } -- Leggings of the Corrupted Conqueror (paladin/priest/warlock)
-- T13.410 (heroic)
rewards[78850] = {  } -- Crown of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78851] = {  } -- Crown of the Corrupted Protector (hunter/shaman/warrior)
rewards[78852] = {  } -- Crown of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78859] = {  } -- Shoulders of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78860] = {  } -- Shoulders of the Corrupted Protector (hunter/shaman/warrior)
rewards[78861] = {  } -- Shoulders of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78847] = {  } -- Chest of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78848] = {  } -- Chest of the Corrupted Protector (hunter/shaman/warrior)
rewards[78849] = {  } -- Chest of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78853] = {  } -- Gauntlets of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78854] = {  } -- Gauntlets of the Corrupted Protector (hunter/shaman/warrior)
rewards[78855] = {  } -- Gauntlets of the Corrupted Vanquisher (dk/druid/mage/rogue)
rewards[78856] = {  } -- Leggings of the Corrupted Conqueror (paladin/priest/warlock)
rewards[78857] = {  } -- Leggings of the Corrupted Protector (hunter/shaman/warrior)
rewards[78858] = {  } -- Leggings of the Corrupted Vanquisher (dk/druid/mage/rogue)

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

function bepgp_tokens_cata:RewardItemString(tokenItem)
  if not (type(tokenItem)=="number" or type(tokenItem)=="string") then return end
  local tokenID = GetItemInfoInstant(tokenItem)
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
  local rewardID = GetItemInfoInstant(rewardItem)
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
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_tokens_cata:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end
