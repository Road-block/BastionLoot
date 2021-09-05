local addonName, bepgp = ...
local moduleName = addonName.."_plusroll_loot"
local bepgp_plusroll_loot = bepgp:NewModule(moduleName,"AceEvent-3.0","AceHook-3.0","AceTimer-3.0")
local ST = LibStub("ScrollingTable")
local LD = LibStub("LibDialog-1.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local G = LibStub("LibGratuity-3.0")
local DF = LibStub("LibDeformat-3.0")
--/run BastionLoot:GetModule("BastionEPGP_plusroll_loot"):Toggle()
local data = { }
local colorSilver = {r=199/255, g=199/255, b=207/255, a=1.0}
local colorHidden = {r=0.0, g=0.0, b=0.0, a=0.0}
local colorHighlight = {r=0, g=0, b=0, a=.9}
local nop = function() end
local function st_sorter_numeric(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[2].value
  local cellb = st.data[rowb].cols[2].value
  return tonumber(cella) > tonumber(cellb)
end
local autoroll, autoroll_data
local plusroll_logs

local loot_indices = {
  time=1,
  player=2,
  player_c=3,
  item=4,
  item_id=5,
  log=6,
}

local itemCache = {}
local item_interact = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  if button ~= "LeftButton" then return false end
  local selected = bepgp_plusroll_loot._wincount_table:GetSelection()
  if selected then
    bepgp_plusroll_loot._container._announce:SetDisabled(true)
  else
    bepgp_plusroll_loot._container._announce:SetDisabled(false)
  end
end

function bepgp_plusroll_loot:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot wincount"])
  container:SetWidth(380)
  container:SetHeight(245)
  container:EnableResize(false)
  container:SetLayout("List")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Name"]),["width"]=100,["comparesort"]=st_sorter_numeric}, --name
    {["name"]=C:Orange(L["Wincount"]),["width"]=80,["comparesort"]=st_sorter_numeric,["sort"]=ST.SORT_DSC}, --wincount
  }
  self._wincount_table = ST:CreateST(headers,12,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._wincount_table:EnableSelection(true)
  self._wincount_table:RegisterEvents({
    ["OnClick"] = item_interact,
  })
  self._wincount_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function()
    bepgp_plusroll_loot._wincount_table:Show()
    if bepgp_plusroll_loot._wincount_table:GetSelection() then
      bepgp_plusroll_loot._container._announce:SetDisabled(false)
    else
      bepgp_plusroll_loot._container._announce:SetDisabled(true)
    end
    local ident = bepgp:getRaidID()
    if ident then
      bepgp_plusroll_loot._container._raidid:SetText(string.format(L["RaidID %s"],ident).."\n\n")
    else
      bepgp_plusroll_loot._container._raidid:SetText(string.format(L["RaidID %s"],"").."\n\n")
    end
  end)
  container:SetCallback("OnClose", function() bepgp_plusroll_loot._wincount_table:Hide() end)

  local raidid = GUI:Create("Label")
  raidid:SetWidth(150)
  raidid:SetText("\n\n")
  raidid:SetColor(1,1,0)
  raidid:SetJustifyV("TOP")
  raidid:SetJustifyH("LEFT")
  self._container._raidid = raidid
  container:AddChild(raidid)

  local announce = GUI:Create("Button")
  announce:SetWidth(100)
  announce:SetText(L["Announce"])
  announce:SetCallback("OnClick",function()
    local realrow = bepgp_plusroll_loot._wincount_table:GetSelection()
    if realrow then
      local name = data[realrow].cols[1].value
      bepgp_plusroll_loot:announceWincount(name,realrow)
    end
  end)
  announce:SetCallback("OnEnter",function(widget,script)
    local realrow = bepgp_plusroll_loot._wincount_table:GetSelection()
    if realrow then
      local items = data[realrow].cols[3].value
      GameTooltip:SetOwner(widget.frame,"ANCHOR_TOP")
      GameTooltip:SetText(_G.ITEMS)
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(items,nil,nil,nil,1)
      GameTooltip:Show()
    end
  end)
  announce:SetCallback("OnLeave",function(widget,script)
    if GameTooltip:IsOwned(widget.frame) then
      GameTooltip_Hide()
    end
  end)
  self._container._announce = announce
  container:AddChild(announce)

  local clear = GUI:Create("Button")
  clear:SetWidth(100)
  clear:SetText(L["Clear"])
  clear:SetCallback("OnClick",function()
    bepgp_plusroll_loot:Clear()
  end)
  self._container._clear = clear
  container:AddChild(clear)

  local logs = GUI:Create("Button")
  logs:SetWidth(100)
  logs:SetText(L["Logs"])
  logs:SetCallback("OnClick",function()
    if plusroll_logs then
      plusroll_logs:Toggle()
    end
  end)
  self._container._logs = logs
  container:AddChild(logs)

  bepgp:make_escable(container,"add")

  LD:Register(addonName.."DialogItemPlusPoints", bepgp:templateCache("DialogItemPlusPoints"))
  -- loot awarded
  --self:RegisterEvent("CHAT_MSG_LOOT","captureLoot")
  self:SecureHook("GiveMasterLoot")
  -- bid call handlers
  self:SecureHook("LootFrame_Update","clickHandlerLoot")
  self:clickHandlerMasterLoot()
  self._lootTimer = self:ScheduleTimer("hookLootAddons",20)

  autoroll = bepgp:GetModule(addonName.."_autoroll")
  autoroll_data = autoroll and autoroll:ItemsHash()
  plusroll_logs = bepgp:GetModule(addonName.."_plusroll_logs")
end

function bepgp_plusroll_loot:Toggle(show)
  if self._container.frame:IsShown() and (not show) then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

local function append(realrow,link,last)
  local entry = data[realrow]
  if entry then
    if entry.cols[3].value == "" then
      entry.cols[3].value = link
    else
      entry.cols[3].value = entry.cols[3].value .. ", " .. link
    end
  end
  if last then
    bepgp_plusroll_loot:RefreshGUI()
  end
end

function bepgp_plusroll_loot:RefreshGUI()
  self._wincount_table:SetData(data)
  if self._wincount_table and self._wincount_table.showing then
    self._wincount_table:SortData()
  end
end

function bepgp_plusroll_loot:Refresh()
  table.wipe(data)
  local wincount = bepgp.db.char.wincount
  local raidident = bepgp:getRaidID()
  if raidident and wincount[raidident] then
    for name, items in pairs(wincount[raidident]) do
      local items_concat = ""
      local count = #(items)
      local realrow = #(data)+1
      table.insert(data,{["cols"]={
        {["value"]=name},
        {["value"]=count},
        {["value"]=items_concat}
      }})
      for i,id in ipairs(items) do
        local _,link = GetItemInfo(id)
        local last = i==count
        if (link) then
          append(realrow,link,last)
        else
          local item = Item:CreateFromItemID(id)
          item:ContinueOnItemLoad(function()
            local id = item:GetItemID()
            local _,link = GetItemInfo(id)
            append(realrow,link,last)
          end)
        end
      end
    end
  end
  self:RefreshGUI()
end

function bepgp_plusroll_loot:GiveMasterLoot(slot, index)
  if bepgp.db.char.mode ~= "plusroll" then return end
  if LootSlotHasItem(slot) then
    local icon, itemname, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
    if quantity == 1 and quality >= LE_ITEM_QUALITY_RARE then -- not a stack and rare or higher
      local itemLink = GetLootSlotLink(slot)
      local player = GetMasterLootCandidate(slot, index)
      if not (player and itemLink) then return end
      self:processLoot(player,itemLink,"masterloot")
    end
  end
end

--/run BastionLoot:GetModule("BastionEPGP_plusroll_loot"):addWincount("Bushido",19871)
function bepgp_plusroll_loot:addWincount(name,item)
  local wincount = bepgp.db.char.wincount
  local raidident = bepgp:getRaidID()
  if raidident then
    wincount[raidident] = wincount[raidident] or {}
    wincount[raidident][name] = wincount[raidident][name] or {}
    table.insert(wincount[raidident][name],item)
  end
  self:Refresh()
end

function bepgp_plusroll_loot:removeWincount(name,item)
  local wincount = bepgp.db.char.wincount
  local raidident = bepgp:getRaidID()
  local wins = wincount[raidident] and wincount[raidident][name]
  if wins then
    local count = #(wins)
    for i=count,1,-1 do
      if wins[i]==item then
        wins[i]=nil
        break
      end
    end
    if #(wins)==0 then
      wincount[raidident][name]=nil
    end
  end
  self:Refresh()
end

function bepgp_plusroll_loot:getWincount(name)
  local wincount = bepgp.db.char.wincount
  local raidident = bepgp:getRaidID()
  if raidident then
    if wincount[raidident] and wincount[raidident][name] then
      return #(wincount[raidident][name])
    else
      return 0
    end
  end
end

function bepgp_plusroll_loot:announceWincount(name, row)
  local out = row and string.format("%s %s",name,L["Wincount"]) or "{bepgp}"
  local channel
  if row then
    local group = bepgp:GroupStatus()
    channel = group ~= "SOLO" and group or nil
  elseif name then
    channel = name
  end
  if channel then -- DEBUG
    if row then
      local count, items = data[row].cols[2].value, data[row].cols[3].value
      out = string.format("%s: %s (%s)",out,count,items)
      SendChatMessage(out,channel)
    else
      out = self:getWincount(channel)
      SendChatMessage(out,"WHISPER",nil,channel)
    end
  end
end

function bepgp_plusroll_loot:Clear()
  table.wipe(bepgp.db.char.wincount)
  bepgp:Print(L["Wincount Cleared."])
  self:Refresh()
end

function bepgp_plusroll_loot:captureLoot(message)
  if bepgp.db.char.mode ~= "plusroll" then return end
  if not self:raidLootAdmin() then return end
  local who,what,amount,player,itemLink
  who,what,amount = DF.Deformat(message,LOOT_ITEM_MULTIPLE)
  if (amount) then -- skip multiples / stacks
  else
    player, itemLink = DF.Deformat(message,LOOT_ITEM)
  end
  who,what,amount = bepgp._playerName, DF.Deformat(message,LOOT_ITEM_SELF_MULTIPLE)
  if (amount) then -- skip multiples / stacks
  else
    if not (player and itemLink) then
      player, itemLink = bepgp._playerName, DF.Deformat(message,LOOT_ITEM_SELF)
    end
  end
  if not (player and itemLink) then return end
  self:processLoot(player,itemLink,"chat")
end

function bepgp_plusroll_loot:processLootDupe(player,itemName,source)
  local now = GetTime()
  local player_item = string.format("%s%s",player,itemName)
  if ((self._lastPlayerItem) and self._lastPlayerItem == player_item)
  and ((self._lastPlayerItemTime) and (now - self._lastPlayerItemTime) < 2)
  and ((self._lastPlayerItemSource) and self._lastPlayerItemSource ~= source) then
    return true, player_item, now
  end
  return false, player_item, now
end

function bepgp_plusroll_loot:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
  local iName, iLink, iRarity, iLevel, iMinLevel, iType, iSubType, iStackCount, iEquipLoc, iTexture,
    iSellPrice, iClassID, iSubClassID, bindType, expacID, iSetID, isCraft = GetItemInfo(itemID)
  itemCache[itemID] = true
  local dupe, player_item, now = self:processLootDupe(player,itemName,source)
  if dupe then
    return
  end
  --[[local bind = bepgp:itemBinding(itemString) -- let recipes register for plusroll mode
  if not (bind) then return end]]
  local skiptokens = bepgp.db.char.wincounttoken
  local is_token = autoroll_data and autoroll_data[itemID]
  if skiptokens and is_token then return end
  local skipstacks = bepgp.db.char.wincountstack
  local is_stackable = iStackCount and (iStackCount > 1) or false
  if skipstacks and is_stackable then return end
  local _,cached,class,hex
  if player == bepgp._playerName then
    class = UnitClass("player") -- localized
    _,_,hex = bepgp:getClassData(class)
  else
    cached = bepgp:groupCache(player)
    if cached then
      class, hex = cached.class, cached.hex
    end
  end
  if not (class) then return end
  self._lastPlayerItem, self._lastPlayerItemTime, self._lastPlayerItemSource = player_item, now, source
  local player_color = C:Colorize(hex,player)
  local epoch, timestamp = bepgp:getServerTime()
  local data = {[loot_indices.time]=epoch,[loot_indices.player]=player,[loot_indices.player_c]=player_color,[loot_indices.item]=itemLink,[loot_indices.item_id]=itemID,loot_indices=loot_indices}
  LD:Spawn(addonName.."DialogItemPlusPoints", data)
end

function bepgp_plusroll_loot:processLoot(player,itemLink,source)
  local itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
  if itemName then
    if itemCache[itemID] then
      self:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
    else
      local item = Item:CreateFromItemID(itemID)
      item:ContinueOnItemLoad(function()
        bepgp_plusroll_loot:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
      end)
    end
  end
end

function bepgp_plusroll_loot:raidLootAdmin()
  return (bepgp:GroupStatus()=="RAID" and bepgp:lootMaster())
end

function bepgp_plusroll_loot:bidCall(frame, button, context) -- context is one of "masterloot", "lootframe"
  if bepgp.db.char.mode ~= "plusroll" then return end
  if not IsAltKeyDown() then return end
  if not self:raidLootAdmin() then return end
  if not context then return end
  local itemLink,slot,hasItem,bagID,slotID
  if context == "lootframe" or context == "masterloot" then
    slot = frame.slot
    if not (slot and LootSlotHasItem(slot)) then return end
    itemLink = GetLootSlotLink(slot)
  end
  if not itemLink then return end
  local itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
  bepgp:widestAudience(string.format(L["'/roll' (ms,res) or '/roll 50' (os) for %s"],itemLink))
end

function bepgp_plusroll_loot:clickHandlerMasterLoot()
  MasterLooterFrame.Item:EnableMouse(true)
  MasterLooterFrame.Item._bepgprollclicks = true
  MasterLooterFrame.Item:HookScript("OnMouseUp", function(self,button)
    local frame = self
    frame.slot = LootFrame.selectedSlot
    if frame.slot then
      bepgp_plusroll_loot:bidCall(frame, button, "masterloot")
    end
  end)
  local onenter = MasterLooterFrame.Item:GetScript("OnEnter")
  if type(onenter)~="function" then
    MasterLooterFrame.Item:SetScript("OnEnter", function(self)
      local slot = LootFrame.selectedSlot
      if slot then
        GameTooltip:SetOwner(self,"ANCHOR_TOP")
        GameTooltip:SetLootItem(slot)
        GameTooltip:Show()
      end
    end)
  end
  local onleave = MasterLooterFrame.Item:GetScript("OnLeave")
  if type(onleave)~="function" then
    MasterLooterFrame.Item:SetScript("OnLeave", function(self)
      if GameTooltip:IsOwned(self) then
        GameTooltip_Hide()
      end
    end)
  end
end

function bepgp_plusroll_loot:clickHandlerLootElvUI()
  if ElvLootFrame and ElvLootFrame.slots then
    for id,button in pairs(ElvLootFrame.slots) do
      if button and not button._bepgprollclicks then
        if not self:IsHooked(button,"OnClick") then
          button.slot = button:GetID()
          self:HookScript(button,"OnClick", function(frame, button) bepgp_plusroll_loot:bidCall(frame, button, "lootframe") end)
        end
        button._bepgprollclicks = true
      end
    end
  end
end

function bepgp_plusroll_loot:hookLootAddons()
  if IsAddOnLoaded("ElvUI") then
    local E = ElvUI and ElvUI[1]
    local elvloot = E and E.private.general.loot or false
    if elvloot then
      local M = E:GetModule("Misc")
      if M and M.LOOT_OPENED then
        if not self:IsHooked(M,"LOOT_OPENED") then
          self:SecureHook(M,"LOOT_OPENED","clickHandlerLootElvUI")
        end
      end
    end
  end
end

function bepgp_plusroll_loot:clickHandlerLoot()
  for i=1,GetNumLootItems() do
    local button = _G["LootButton"..i]
    if button and not button._bepgprollclicks then
      button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
      button.RegisterForClicks = nop
      if not self:IsHooked(button,"OnClick") then
        self:HookScript(button,"OnClick", function(frame, button) bepgp_plusroll_loot:bidCall(frame, button, "lootframe") end)
      end
      button._bepgprollclicks = true
    end
  end
end
