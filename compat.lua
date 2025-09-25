local addonName, bepgp = ...
local falsey = function() return false end

local GetGuildTabardFileNames = _G.GetGuildTabardFileNames or _G.GetGuildTabardFiles
local GuildRoster = function(...)
  if C_GuildInfo and C_GuildInfo.GuildRoster then
    return C_GuildInfo.GuildRoster(...)
  elseif _G.GuildRoster then
    return _G.GuildRoster(...)
  end
end
local CanEditOfficerNote = function(...)
  if C_GuildInfo and C_GuildInfo.CanEditOfficerNote then
    return C_GuildInfo.CanEditOfficerNote(...)
  elseif _G.CanEditOfficerNote then
    return _G.CanEditOfficerNote(...)
  end
end
local CanViewOfficerNote = function(...)
  if _G.CanViewOfficerNote then
    return _G.CanViewOfficerNote(...)
  elseif C_GuildInfo and C_GuildInfo.CanViewOfficerNote then
    return C_GuildInfo.CanViewOfficerNote(...)
  end
end
local CanSpeakInGuildChat = function(...)
  if C_GuildInfo and C_GuildInfo.CanSpeakInGuildChat then
    return C_GuildInfo and C_GuildInfo.CanSpeakInGuildChat(...)
  elseif _G.CanSpeakInGuildChat then
    return _G.CanSpeakInGuildChat(...)
  end
end
local GuildControlGetRankFlags = function(...)
  if C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags then
    return C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags(...)
  elseif _G.GuildControlGetRankFlags then
    return _G.GuildControlGetRankFlags(...)
  end
end
local GetAddOnMetadata = function(...)
  if C_AddOns and C_AddOns.GetAddOnMetadata then
    return C_AddOns.GetAddOnMetadata(...)
  elseif _G.GetAddOnMetadata then
    return _G.GetAddOnMetadata(...)
  end
end
local IsAddOnLoaded = function(...)
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded(...)
  elseif _G.IsAddOnLoaded then
    return _G.IsAddOnLoaded(...)
  end
end
local GetAddOnInfo = function(...)
  if C_AddOns and C_AddOns.GetAddOnInfo then
    return C_AddOns.GetAddOnInfo(...)
  elseif _G.GetAddOnInfo then
    return _G.GetAddOnInfo(...)
  end
end
local GetItemInfoInstant = function(...)
  if _G.GetItemInfoInstant then
    return _G.GetItemInfoInstant(...)
  elseif C_Item and C_Item.GetItemInfoInstant then
    return C_Item.GetItemInfoInstant(...)
  end
end
local GetItemInfo = function(...)
  if C_Item and C_Item.GetItemInfo then
    return C_Item.GetItemInfo(...)
  elseif _G.GetItemInfo then
    return _G.GetItemInfo(...)
  end
end
local GetItemSubClassInfo = function(...)
  if C_Item and C_Item.GetItemSubClassInfo then
    return C_Item.GetItemSubClassInfo(...)
  elseif _G.GetItemSubClassInfo then
    return _G.GetItemSubClassInfo(...)
  end
end
local GetItemInventoryTypeByID = function(...)
  if C_Item and C_Item.GetItemInventoryTypeByID then
    return C_Item.GetItemInventoryTypeByID(...)
  elseif _G.GetItemInventoryTypeByID then
    return _G.GetItemInventoryTypeByID(...)
  end
end
local GetItemStats = function(...)
  if C_Item and C_Item.GetItemStats then
    return C_Item.GetItemStats(...)
  elseif _G.GetItemStats then
    return _G.GetItemStats(...)
  end
end
local GetLootMethod = function(...)
  if C_PartyInfo and C_PartyInfo.GetLootMethod then
    return C_PartyInfo.GetLootMethod(...)
  elseif _G.GetLootMethod then
    return _G.GetLootMethod(...)
  end
end
local loot_old_to_new = {
  freeforall      = (Enum.LootMethod.Freeforall or 0),
  roundrobin      = (Enum.LootMethod.Roundrobin or 1),
  master          = (Enum.LootMethod.Masterlooter or 2),
  group           = (Enum.LootMethod.Group or 3),
  needbeforegreed = (Enum.LootMethod.Needbeforegreed or 4),
}
local loot_new_to_old = {
  [(Enum.LootMethod.Freeforall or 0)]      = "master",
  [(Enum.LootMethod.Roundrobin or 1)]      = "roundrobin",
  [(Enum.LootMethod.Masterlooter or 2)]    = "master",
  [(Enum.LootMethod.Group or 3)]           = "group",
  [(Enum.LootMethod.Needbeforegreed or 4)] = "needbeforegreed",
}
local SetLootMethod = function(...)
  local loot_method, unit, threshold = ...
  if C_PartyInfo and C_PartyInfo.SetLootMethod then
    if type(loot_method) == "string" then
      local new_method = loot_old_to_new[loot_method:lower()]
      if new_method then
        loot_method = new_method
      end
    end
    return C_PartyInfo.SetLootMethod(loot_method,unit,threshold)
  elseif _G.SetLootMethod then
    if type(loot_method) == "number" then
      local old_method = loot_new_to_old[loot_method]
      if old_method then
        loot_method = old_method
      end
    end
    return _G.SetLootMethod(loot_method,unit,threshold)
  end
end

bepgp.GetGuildTabardFileNames = GetGuildTabardFileNames
bepgp.GuildRoster = GuildRoster
bepgp.CanEditOfficerNote = CanEditOfficerNote
bepgp.CanViewOfficerNote = CanViewOfficerNote
bepgp.CanSpeakInGuildChat = CanSpeakInGuildChat
bepgp.GuildControlGetRankFlags = GuildControlGetRankFlags
bepgp.GetAddOnMetadata = GetAddOnMetadata
bepgp.IsAddOnLoaded = IsAddOnLoaded
bepgp.GetAddOnInfo = GetAddOnInfo
bepgp.GetItemInfoInstant = GetItemInfoInstant
bepgp.GetItemInfo = GetItemInfo
bepgp.GetItemSubClassInfo = GetItemSubClassInfo
bepgp.GetItemInventoryTypeByID = GetItemInventoryTypeByID
bepgp.GetItemStats = GetItemStats
bepgp.GetLootMethod = GetLootMethod
bepgp.SetLootMethod = SetLootMethod
