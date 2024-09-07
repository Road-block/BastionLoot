local addonName, bepgp = ...
local falsey = function() return false end

local GetGuildTabardFileNames = _G.GetGuildTabardFileNames or _G.GetGuildTabardFiles
local GuildRoster = function(...)
  if _G.GuildRoster then
    return _G.GuildRoster(...)
  elseif C_GuildInfo and C_GuildInfo.GuildRoster then
    return C_GuildInfo.GuildRoster(...)
  end
end
local CanEditOfficerNote = function(...)
  if _G.CanEditOfficerNote then
    return _G.CanEditOfficerNote(...)
  elseif C_GuildInfo and C_GuildInfo.CanEditOfficerNote then
    return C_GuildInfo.CanEditOfficerNote(...)
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
  if _G.CanSpeakInGuildChat then
    return _G.CanSpeakInGuildChat(...)
  elseif C_GuildInfo and C_GuildInfo.CanSpeakInGuildChat then
    return C_GuildInfo and C_GuildInfo.CanSpeakInGuildChat(...)
  end
end
local GuildControlGetRankFlags = function(...)
  if _G.GuildControlGetRankFlags then
    return _G.GuildControlGetRankFlags(...)
  elseif C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags then
    return C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags(...)
  end
end
local GetAddOnMetadata = function(...)
  if _G.GetAddOnMetadata then
    return _G.GetAddOnMetadata(...)
  elseif C_AddOns and C_AddOns.GetAddOnMetadata then
    return C_AddOns.GetAddOnMetadata(...)
  end
end
local IsAddOnLoaded = function(...)
  if _G.IsAddOnLoaded then
    return _G.IsAddOnLoaded(...)
  elseif C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded(...)
  end
end
local GetAddOnInfo = function(...)
  if _G.GetAddOnInfo then
    return _G.GetAddOnInfo(...)
  elseif C_AddOns and C_AddOns.GetAddOnInfo then
    return C_AddOns.GetAddOnInfo(...)
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
  if _G.GetItemInfo then
    return _G.GetItemInfo(...)
  elseif C_Item and C_Item.GetItemInfo then
    return C_Item.GetItemInfo(...)
  end
end
local GetItemSubClassInfo = function(...)
  if _G.GetItemSubClassInfo then
    return _G.GetItemSubClassInfo(...)
  elseif C_Item and C_Item.GetItemSubClassInfo then
    return C_Item.GetItemSubClassInfo(...)
  end
end
local GetItemInventoryTypeByID = function(...)
  if _G.GetItemInventoryTypeByID then
    return _G.GetItemInventoryTypeByID(...)
  elseif C_Item and C_Item.GetItemInventoryTypeByID then
    return C_Item.GetItemInventoryTypeByID(...)
  end
end
local GetItemStats = function(...)
  if _G.GetItemStats then
    return _G.GetItemStats(...)
  elseif C_Item and C_Item.GetItemStats then
    return C_Item.GetItemStats(...)
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