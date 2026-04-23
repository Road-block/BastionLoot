local addonName, bepgp = ...
local falsey = function() return false end

local GetGuildTabardFileNames = _G.GetGuildTabardFileNames or _G.GetGuildTabardFiles
local GuildRoster = C_GuildInfo and C_GuildInfo.GuildRoster or _G.GuildRoster
local CanEditOfficerNote = C_GuildInfo and C_GuildInfo.CanEditOfficerNote or _G.CanEditOfficerNote
local CanViewOfficerNote = C_GuildInfo and C_GuildInfo.CanViewOfficerNote or _G.CanViewOfficerNote
local CanSpeakInGuildChat = C_GuildInfo and C_GuildInfo.CanSpeakInGuildChat or _G.CanSpeakInGuildChat
local GuildControlGetRankFlags = C_GuildInfo and C_GuildInfo.GuildControlGetRankFlags or _G.GuildControlGetRankFlags
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded
local GetAddOnInfo = C_AddOns and C_AddOns.GetAddOnInfo or _G.GetAddOnInfo
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or _G.GetItemInfoInstant
local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo
local GetItemSubClassInfo = C_Item and C_Item.GetItemSubClassInfo or _G.GetItemSubClassInfo
local GetItemInventoryTypeByID = C_Item and C_Item.GetItemInventoryTypeByID or _G.GetItemInventoryTypeByID
local GetItemStats = C_Item and C_Item.GetItemStats or _G.GetItemStats
local GetLootMethod = C_PartyInfo and C_PartyInfo.GetLootMethod or _G.GetLootMethod
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
local SetLootMethod = falsey
if C_PartyInfo and C_PartyInfo.SetLootMethod then
  SetLootMethod = function(...)
    local loot_method, unit, threshold = ...
    if type(loot_method) == "string" then
      local new_method = loot_old_to_new[loot_method:lower()]
      if new_method then
        loot_method = new_method
      end
    end
    C_PartyInfo.SetLootMethod(loot_method,unit,threshold)
  end
elseif _G.SetLootMethod then
  SetLootMethod = function(...)
    local loot_method, unit, threshold = ...
    if type(loot_method) == "number" then
      local old_method = loot_new_to_old[loot_method]
      if old_method then
        loot_method = old_method
      end
    end
    _G.SetLootMethod(loot_method,unit,threshold)
  end
end
local GetMessageEventFilters = ChatFrameUtil and ChatFrameUtil.GetMessageEventFilters or _G.ChatFrame_GetMessageEventFilters
local AddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or _G.ChatFrame_AddMessageEventFilter
local RemoveMessageEventFilter = ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter or _G.ChatFrame_RemoveMessageEventFilter
local ChatEdit_LinkItem = ChatFrameUtil and ChatFrameUtil.LinkItem or _G.ChatEdit_LinkItem
local ChatEdit_InsertLink = ChatFrameUtil and ChatFrameUtil.InsertLink or _G.ChatEdit_InsertLink
local SendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or _G.SendChatMessage
local ChatFrame_RemoveAllMessageGroups = ChatFrameMixin and ChatFrameMixin.RemoveAllMessageGroups or _G.ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveAllChannels = ChatFrameMixin and ChatFrameMixin.RemoveAllChannels or _G.ChatFrame_RemoveAllChannels
local GuildRosterSetOfficerNote = falsey
if _G.GuildRosterSetOfficerNote then
  GuildRosterSetOfficerNote = _G.GuildRosterSetOfficerNote
elseif C_GuildInfo and C_GuildInfo.SetNote then
  GuildRosterSetOfficerNote = function(...)
    local index,note,fromAddon = ...
    if type(index) == "number" then
      local name, _, _, _, _, _, _, prevnote, _, _, _, _, _, _, _, _, g_GUID = GetGuildRosterInfo(index)
      C_GuildInfo.SetNote(g_GUID,note,false,fromAddon)
    else
      C_GuildInfo.SetNote(index,note,false,fromAddon)
    end
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
bepgp.GetMessageEventFilters = GetMessageEventFilters
bepgp.AddMessageEventFilter = AddMessageEventFilter
bepgp.RemoveMessageEventFilter = RemoveMessageEventFilter
bepgp.ChatEdit_LinkItem = ChatEdit_LinkItem
bepgp.ChatEdit_InsertLink = ChatEdit_InsertLink
bepgp.SendChatMessage = SendChatMessage
bepgp.ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
bepgp.ChatFrame_RemoveAllChannels = ChatFrame_RemoveAllChannels
bepgp.GuildRosterSetOfficerNote = GuildRosterSetOfficerNote
-- TODO:
--[[
C_ChatInfo.
ChatFrameUtil.
ChatFrameMixin.
]]