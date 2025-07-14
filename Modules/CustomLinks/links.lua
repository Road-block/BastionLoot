local addonName, bepgp = ...
if not (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC) then return end
local moduleName = addonName.."_chatlinks"
local bepgp_chatlinks = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local chatTypesToFix = {
  CHAT_MSG_RAID = true,
  CHAT_MSG_RAID_LEADER = true,
  CHAT_MSG_RAID_WARNING = true,
  CHAT_MSG_PARTY = true,
  CHAT_MSG_PARTY_LEADER = true,
  CHAT_MSG_INSTANCE_CHAT = true,
  CHAT_MSG_INSTANCE_CHAT_LEADER = true,
  CHAT_MSG_GUILD = true,
  CHAT_MSG_OFFICER = true,
  CHAT_MSG_WHISPER = true,
  CHAT_MSG_WHISPER_INFORM = true,
}
local chatTypesSend = {
  RAID = true,
  RAID_WARNING = true,
  PARTY = true,
  INSTANCE_CHAT = true,
  GUILD = true,
  OFFICER = true,
  WHISPER = true,
  WHISPER_INFORM = true,
}

local itemLinkCache = { }
local helperPrint = { }
local function preCache(itemID)
  local itemAsync = Item:CreateFromItemID(itemID)
  local cached = itemAsync:IsItemDataCached()
  itemAsync:ContinueOnItemLoad(function()
    local itemName = itemAsync:GetItemName()
    local itemColor = itemAsync:GetItemQualityColor()
    if not cached then
      local itemLink = itemAsync:GetItemLink()
      local now = GetTime()
      local lastPrint = helperPrint[itemLink]
      if not lastPrint or (now - lastPrint > 1.0) then
        helperPrint[itemLink] = now
        bepgp:Print(itemLink)
      end
    end
    itemLinkCache[itemID] = format("%s|Haddon:bastionlootlinks:%d|h[%s]|h|r",itemColor.hex,itemID,itemName)
  end)
end
local function linkMaker(name,itemID)
  local itemID = tonumber(itemID)
  if itemID then
    local cachedLink = itemLinkCache[itemID]
    if cachedLink then
      return cachedLink
    else
      if (bepgp.GetItemInfoInstant(itemID)) then
        preCache(itemID)
        return itemLinkCache[itemID]
      end
    end
  end
end

local function itemLinkFilter(frame,event,text,sender,...)
  for name,itemID in text:gmatch("{([^}]+):(%d+)}") do
    itemID = tonumber(itemID)
    if itemID and not itemLinkCache[itemID] then
      if (bepgp.GetItemInfoInstant(itemID)) then
        preCache(itemID)
      end
    end
  end
  local newtext = text:gsub("{([^}]+):(%d+)}",linkMaker)
  return false,newtext,sender,...
end

function bepgp_chatlinks:setupLinkFilters()
  -- Hopefully anyone that can think of doing this
  -- also knows enough to not cause side-effects for filters coming after their own.
  for chatType,_ in pairs(chatTypesToFix) do
    local filters = ChatFrame_GetMessageEventFilters(chatType)
    if filters and #(filters) > 0 then
      for index, filterFunc in next, filters do
        if ( filterFunc == itemLinkFilter ) then
          return
        end
      end
      tinsert(filters,1,itemLinkFilter)
    else
      ChatFrame_AddMessageEventFilter(chatType, itemLinkFilter)
    end
  end
end

function bepgp_chatlinks:OnHyperlinkLeave(...)
  if GameTooltip._bastionlootlinks then
    GameTooltip._bastionlootlinks = nil
    GameTooltip:Hide()
  end
end

function bepgp_chatlinks:setupLinkClicks()
  self._cbID = EventRegistry:RegisterCallback("SetItemRef", function(_, link, text, button, chatFrame)
    local linkType, addonName, linkData = strsplit(":", link)
    if linkType == "addon" and addonName == "bastionlootlinks" then
        local itemID = tonumber(linkData)
        if itemID then
          GameTooltip:SetOwner(UIParent,"ANCHOR_CURSOR_RIGHT")
          --GameTooltip:SetOwner(chatFrame,"ANCHOR_TOP")
          GameTooltip:SetHyperlink(format("item:%d",itemID))
          GameTooltip._bastionlootlinks = itemID
          GameTooltip:Show()
          if not bepgp_chatlinks:IsHooked(chatFrame,"OnHyperlinkLeave") then
            bepgp_chatlinks:HookScript(chatFrame,"OnHyperlinkLeave")
          end
        end
    end
  end)
end

function bepgp_chatlinks:SendChatMessage(...)
  local msg, chatType, lang, target = ...
  if chatTypesSend[chatType] then
    local newmsg,count = msg:gsub("|c%x+|Hitem:(%d+)[^|]+|h%[(.-)%]|h|r","{%2:%1}")
    if count > 0 then
      return self.hooks.SendChatMessage(newmsg,chatType,lang,target)
    end
  end
  self.hooks.SendChatMessage(...)
end

function bepgp_chatlinks:RaidNotice_AddMessage(...)
  local noticeFrame, textString, colorInfo, displayTime = ...
  if noticeFrame == RaidWarningFrame then
    local newmsg,count = textString:gsub("{([^}]+):(%d+)}",linkMaker)
    if count > 0 then
      return self.hooks.RaidNotice_AddMessage(noticeFrame, newmsg, colorInfo, displayTime)
    end
  end
  self.hooks.RaidNotice_AddMessage(...)
end

function bepgp_chatlinks:setupLinkPost()
  bepgp_chatlinks:RawHook("SendChatMessage",true)
  bepgp_chatlinks:RawHook("RaidNotice_AddMessage",true)
end

function bepgp_chatlinks:injectOption()
  bepgp._options.args.general.args.main.args["customlinks"] = {
    type = "toggle",
    name = L["ChatLink *Fix*"],
    desc = L["|cffff0000Workaround for MoP Prepatch ItemLink Bug|r\nDisable when fixed."],
    order = 90,
    get = function() return bepgp_chatlinks:IsEnabled() end,
    set = function(info, val)
      bepgp.db.char.customlinks = not bepgp.db.char.customlinks
      if bepgp.db.char.customlinks then
        bepgp_chatlinks:Enable()
      else
        bepgp_chatlinks:Disable()
      end
    end,
  }
end

function bepgp_chatlinks:OnEnable()
  self:setupLinkFilters()
  self:setupLinkClicks()
  self:setupLinkPost()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end

function bepgp_chatlinks:OnDisable()
  for chatType,_ in pairs(chatTypesToFix) do
    ChatFrame_RemoveMessageEventFilter(chatType, itemLinkFilter)
  end
  EventRegistry:UnregisterCallback("SetItemRef",bepgp_chatlinks._cbID)
  self:UnhookAll()
end

function bepgp_chatlinks:getAnyItemLink(text)
  return (string.find(text,"{[^}]+:%d+")) and true or false
end
function bepgp_chatlinks:getStrippedLinkText(text)
  local linkstriptext, count = string.gsub(text,"{[^}]+:%d+}"," ; ")
  return string.lower(linkstriptext), count
end
function bepgp_chatlinks:getItemLinkText(text)
--  local _,_,itemLink = string.find(text,"(|c%x+|H[eimt:%-%d]+|h%[.-%]|h|r)")
  local itemid = tonumber(text:match("{[^}]+:(%d+)"))
  if itemid then
    local itemAsync = Item:CreateFromItemID(itemid)
    itemAsync:ContinueOnItemLoad(function()
      itemAsync._itemLink = itemAsync:GetItemLink()
    end)
    return itemAsync._itemLink
  end
end

function bepgp_chatlinks:CoreInit()
  if not self._initDone then
    self:injectOption()
    self._initDone = true
  end
  if not bepgp.db.char.customlinks then
    self:Disable()
  end
end
