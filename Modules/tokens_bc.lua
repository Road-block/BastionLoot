local addonName, bepgp = ...
local moduleName = addonName.."_tokens_bc"
local bepgp_tokens_bc = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- item = token
local tokens = {}
-- token = item
local rewards = {}

-- Sunwell
tokens[34399] = {34233, 34664} -- Robes of Ghostly Hatred < Robes of Faltered Light
tokens[34406] = {34342, 34664} -- Gloves of Tyri's Power < Handguards of the Dawn
tokens[34405] = {34339, 34664} -- Helm of Arcane Purity < Cowl of Purity's Light
tokens[34386] = {34170, 34664} -- Pantaloons of Growing Strife < Pantaloons of Calming Strife
tokens[34393] = {34202, 34664} -- Soulderpads of Knowledge's Pursuit < Shawl of Wonderment
tokens[34397] = {34211, 34664} -- Bladed Chaos Tunic < Harness of Carnal Instinct
tokens[34398] = {34212, 34664} -- Utopian Tunic of Elune < Sunglow Vest
tokens[34408] = {34234, 34664} -- Gloves of the Forest Drifter < Shadowed Gauntlets of Paroxysm
tokens[34407] = {34351, 34664} -- Tranquil Moonlight Wraps < Tranquil Majesty Wraps
tokens[34403] = {34245, 34664} -- Cover of Ursoc the Mighty < Cover of Ursoc the Wise
tokens[34404] = {34244, 34664} -- Mask of the Fury Hunter < Duplicitous Guise
tokens[34384] = {34169, 34664} -- Breeches of Natural Splendor < Breeches of Natural Aggression
tokens[34385] = {34188, 34664} -- Leggings of the Immortal Beast < Leggings of the Immortal Night
tokens[34392] = {34195, 34664} -- Demontooth Shoulderpads < Soulderpads of Vehemence
tokens[34391] = {34209, 34664} -- Spaulders of Devastation < Spaulders of Reclamation
tokens[34396] = {34229, 34664} -- Garments of Crashing Shores < Garments of Serene Shores
tokens[34409] = {34350, 34664} -- Gauntlets of the Ancient Frostwolf < Gauntlets of the Ancient Shadowmoon
tokens[34402] = {34332, 34664} -- Shroud of Chieftain Ner'zhul < Cowl of Gul'dan
tokens[34383] = {34186, 34664} -- Kilt of Spiritual Reconstruction < Chain Links of the Tumultuous Storm
tokens[34390] = {34208, 34664} -- Erupting Epaulets < Equilibrium Epaulets
tokens[34394] = {34215, 34664} -- Breastplate of Agony's Aversion < Warharness of Reckless Fury
tokens[34395] = {34216, 34664} -- Noble Jidicator's Chestguard < Heroic Judicator's Chestguard
tokens[34400] = {34345, 34664} -- Crown of Dath'Remar < Crown of Anasterian
tokens[34401] = {34243, 34664} -- Helm of Uther's Resolve < Helm of Burning Righteousness
tokens[34381] = {34180, 34664} -- Felstrength Legplates < Felfury Legplates
tokens[34382] = {34167, 34664} -- Judicator's Legguards < Legplates of the Holy Juggernaut
tokens[34388] = {34192, 34664} -- Pauldrons of Berserking < Pauldrons of Perseverance
tokens[34389] = {34193, 34664} -- Spaulders of the Thalassian Defender < Spaulders of the Thalassian Savior

local cached_info = {}
local cached_info_string = {}
local cached_icon_markup = setmetatable({},{__index = function(t,k)
  local markup = CreateTextureMarkup(k,32, 32, 16, 16, 0, 1, 0, 1)
  rawset(t,k,markup)
  return markup
end})

function bepgp_tokens_bc:GetReward(token)
  local reward = rewards[token]
  if reward and type(reward)=="number" then
    return reward
  end
end

function bepgp_tokens_bc:GetToken(reward)
  local tokenData = tokens[reward]
  if tokenData and tokenData[1] then
    return tokenData[1]
  end
end

function bepgp_tokens_bc:RewardItemString(tokenItem)
  if not (type(tokenItem)=="number" or type(tokenItem)=="string") then return end
  local itemID = GetItemInfoInstant(tokenItem)
  if not itemID then return end
  local rewardData = rewards[itemID]
  if rewardData and type(rewardData)=="number" then
    local rewardID = rewardData
    if type(rewards[rewardID]) == "string" then
      return rewards[rewardID]
    else
      return rewardID .. " caching"
    end
  end
end

function bepgp_tokens_bc:TokensItemString(rewardItem)
  if not (type(rewardItem)=="number" or type(rewardItem)=="string") then return end
  local itemID = GetItemInfoInstant(rewardItem)
  if not itemID then return end
  if tokens[itemID] then
    if cached_info[itemID] and cached_info[itemID].done then
      if not cached_info_string[itemID] then
        local i = 1
        while tokens[itemID][i] do
          if i == 1 then
            cached_info_string[itemID] = cached_info[itemID][i].link
          else
            cached_info_string[itemID] = cached_info_string[itemID]..string.format("+%s",cached_icon_markup[cached_info[itemID][i].icon])
          end
          i = i + 1
        end
      end
      return cached_info_string[itemID]
    else
      local numReq = #(tokens[itemID])
      for i=1,numReq do
        local srcID = tokens[itemID][i]
        self:cacheItem(srcID,i,numReq,itemID)
      end
      return table.concat(tokens[itemID],", ").." caching.."
    end
  end
end

function bepgp_tokens_bc:cacheItem(srcID,index,total,rewardID)
  local srcAsync = Item:CreateFromItemID(srcID)
  srcAsync:ContinueOnItemLoad(function()
    local itemName = srcAsync:GetItemName()
    local itemLink = srcAsync:GetItemLink()
    local itemIcon = srcAsync:GetItemIcon()
    cached_info[rewardID] = cached_info[rewardID] or {}
    cached_info[rewardID][index] = {name=itemName,link=itemLink,icon=itemIcon}
    if index==total then
      cached_info[rewardID].done = true
    end
  end)
end

function bepgp_tokens_bc:cacheRewards()
  for reward,tokenData in pairs(tokens) do
    rewards[tokenData[1]] = reward
    local rewardAsync = Item:CreateFromItemID(reward)
    rewardAsync:ContinueOnItemLoad(function()
      local link = rewardAsync:GetItemLink()
      rewards[reward] = link
    end)
  end
end

function bepgp_tokens_bc:delayInit()
  for item, requires in pairs(tokens) do
    local numReq = #requires
    for i=1,numReq do
      local srcID = requires[i]
      self:cacheItem(srcID,i,numReq,item)
    end
  end
  self._initDone = true
end

function bepgp_tokens_bc:CoreInit()
  self:cacheRewards()
  bepgp.TokensItemString = self.TokensItemString
  bepgp.RewardItemString = self.RewardItemString
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_tokens_bc:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
  self:delayInit()
end