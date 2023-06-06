local addonName, bepgp = ...
local moduleName = addonName.."_loot"
local bepgp_loot = bepgp:NewModule(moduleName,"AceEvent-3.0","AceHook-3.0","AceTimer-3.0")
local ST = LibStub("ScrollingTable")
local LD = LibStub("LibDialog-1.0")
local LDD = LibStub("LibDropdown-1.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local G = LibStub("LibGratuity-3.0")
local DF = LibStub("LibDeformat-3.0")

local data = { }
local colorSilver = {r=199/255, g=199/255, b=207/255, a=1.0}
local colorHidden = {r=0.0, g=0.0, b=0.0, a=0.0}
local colorHighlight = {r=0, g=0, b=0, a=.9}
local tradeable_pattern = string.gsub(_G.BIND_TRADE_TIME_REMAINING, "%%s", "(.+)")
local nop = function() end
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or _G.GetContainerItemLink
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or _G.GetContainerNumSlots

local loot_indices = {
  time=1,
  player=2,
  player_c=3,
  item=4,
  item_id=5,
  bind=6,
  price=7,
  off_price=8,
  action=9,
  update=10,
  price2=11,
  off_price2=12,
  class=13,
}
local itemCache = {}
local function st_sorter_numeric(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[7].value
  local cellb = st.data[rowb].cols[7].value
  return tonumber(cella) > tonumber(cellb)
end
local menu_close = function()
  if bepgp_loot._ddmenu then
    bepgp_loot._ddmenu:Release()
  end
end
local assign_options = {
  type = "group",
  name = L["BastionLoot options"],
  desc = L["BastionLoot options"],
  handler = bepgp_loot,
  args = {
    ["bankde"] = {
      type = "execute",
      name = L["Bank or D/E"],
      desc = L["Bank or D/E"],
      order = 1,
      func = function(info)
        bepgp_loot._selected[loot_indices.action] = L["Bank-D/E"]
        bepgp_loot:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["cancel"] = {
      type = "execute",
      name = _G.CANCEL,
      desc = _G.CANCEL,
      order = 2,
      func = function(info)
        C_Timer.After(0.2, menu_close)
      end,
    }
  }
}
local manual_assign = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  local loot_index = data[realrow].cols[7].value
  local loot_entry
  if loot_index then
    loot_entry = bepgp.db.char.loot[loot_index]
    bepgp_loot._selected = loot_entry
  else
    bepgp_loot._selected = nil
  end
  if bepgp_loot._selected then
    local loot_action = data[realrow].cols[5].value
    if loot_action and loot_action == bepgp.VARS.unassigned then
      bepgp_loot._ddmenu = LDD:OpenAce3Menu(assign_options)
      bepgp_loot._ddmenu:SetPoint("CENTER", cellFrame, "CENTER", 0,0)
    else
      C_Timer.After(0.2, menu_close)
    end
  end
  return false
end

function bepgp_loot:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot loot info"])
  container:SetWidth(555)
  container:SetHeight(320)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Time"]),["width"]=100,["comparesort"]=st_sorter_numeric,["sort"]=ST.SORT_DSC}, -- server time
    {["name"]=C:Orange(L["Item"]),["width"]=150,["comparesort"]=st_sorter_numeric}, -- item name
    {["name"]=C:Orange(L["Looter"]),["width"]=100,["comparesort"]=st_sorter_numeric}, -- looter
    {["name"]=C:Orange(L["Binds"]),["width"]=50,["comparesort"]=st_sorter_numeric}, -- binds
    {["name"]=C:Orange(L["GP Action"]),["width"]=100,["comparesort"]=st_sorter_numeric}, -- action
    --{["name"]="",["width"]=1,["comparesort"]=st_sorter_numeric,["sort"]=ST.SORT_DSC} -- order
  }
  self._loot_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  --self._loot_table:EnableSelection(true)
  self._loot_table:RegisterEvents({
    ["OnClick"] = manual_assign
  })
  self._loot_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_loot._loot_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_loot._loot_table:Hide() end)

  local clear = GUI:Create("Button")
  clear:SetAutoWidth(true)
  clear:SetText(L["Clear"])
  clear:SetCallback("OnClick",function()
    bepgp_loot:Clear()
  end)
  container:AddChild(clear)

  local export = GUI:Create("Button")
  export:SetAutoWidth(true)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof:Loot(loot_indices)
    end
  end)
  container:AddChild(export)
  bepgp:make_escable(container,"add")
  LD:Register(addonName.."DialogItemPoints", bepgp:templateCache("DialogItemPoints"))

  -- loot awarded
  self:RegisterEvent("CHAT_MSG_LOOT","captureLoot")
  self:SecureHook("GiveMasterLoot")
  -- trade
  self:SecureHook("InitiateTrade","tradeUnit") -- we are trading
  self:RegisterEvent("TRADE_REQUEST","tradeName") -- another is trading
  self:SecureHookScript(TradeFrameTradeButton, "OnClick", "tradeItemAccept")
  -- bid call handlers
  self:SecureHook("LootFrame_Update","clickHandlerLoot")
  self:clickHandlerMasterLoot()
  self:SecureHook("ToggleBag","clickHandlerBags") -- default bags
  self._bagsTimer = self:ScheduleTimer("hookBagAddons",30)
  self._lootTimer = self:ScheduleTimer("hookLootAddons",20)
end

function bepgp_loot:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_loot:Refresh()
  table.wipe(data)
  for i,v in ipairs(bepgp.db.char.loot) do
    -- account for old data
    local timestamp, _ = v[loot_indices.time]
    if not string.find(timestamp, " ") then
      _, timestamp = bepgp:getServerTime(nil,nil,timestamp)
    end
    table.insert(data,{["cols"]={
      {["value"]=timestamp,["color"]=colorSilver},
      {["value"]=v[loot_indices.item]},
      {["value"]=v[loot_indices.player_c]},
      {["value"]=v[loot_indices.bind]},
      {["value"]=v[loot_indices.action]},
      {["value"]=v[loot_indices.item_id]}, -- 6
      {["value"]=i,} -- 7
    }})
  end
  self._loot_table:SetData(data)
  if self._loot_table and self._loot_table.showing then
    self._loot_table:SortData()
  end
end

function bepgp_loot:Clear()
  table.wipe(bepgp.db.char.loot)
  self:Refresh()
  bepgp:Print(L["Loot info cleared"])
end

function bepgp_loot:GiveMasterLoot(slot, index)
  if bepgp.db.char.mode ~= "epgp" then return end
  if LootSlotHasItem(slot) then
    local icon, itemname, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
    if quantity == 1 and quality >= LE_ITEM_QUALITY_RARE then -- not a stack and rare or higher
      local itemLink = GetLootSlotLink(slot)
      local player = GetMasterLootCandidate(slot, index)
      player = bepgp:Ambiguate(player)
      if not (player and itemLink) then return end
      self:processLoot(player,itemLink,"masterloot")
    end
  end
end

-- /run BastionLoot:GetModule("BastionLoot_loot"):captureLoot("You receive loot: \124cffa335ee\124Hitem:18205::::::::60:::::\124h[Eskhandar's Collar]\124h\124r.")
function bepgp_loot:captureLoot(message)
  if bepgp.db.char.mode ~= "epgp" then return end
  if not self:raidLootAdmin() then return end -- DEBUG
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
  if player and type(player) == "string" then
    player = bepgp:Ambiguate(player)
  end
  if not (player and itemLink) then return end
  self:processLoot(player,itemLink,"chat")
end

function bepgp_loot:processLootDupe(player,itemName,source)
  local now = GetTime()
  local player_item = string.format("%s%s",player,itemName)
  if ((self._lastPlayerItem) and self._lastPlayerItem == player_item)
  and ((self._lastPlayerItemTime) and (now - self._lastPlayerItemTime) < 2)
  and ((self._lastPlayerItemSource) and self._lastPlayerItemSource ~= source) then
    return true, player_item, now
  end
  return false, player_item, now
end

--/run BastionLoot:GetModule("BastionLoot_loot"):processLootCallback("Bushido","\124cffa335ee\124Hitem:40296::::::::80:::::\124h[Cover of Silence]\124h\124r","chat","|cffa335ee","item:40296","Cover of Silence",40296)
--/run BastionLoot:GetModule("BastionLoot_loot"):processLootCallback("Bushido","\124cffa335ee\124Hitem:40266::::::::80:::::\124h[Hero's Surrender]\124h\124r","chat","|cffa335ee","item:40266","Hero's Surrender",40266)
function bepgp_loot:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
  local iName, iLink, iRarity, iLevel, iMinLevel, iType, iSubType, iStackCount, iEquipLoc, iTexture,
    iSellPrice, iClassID, iSubClassID, bindType, expacID, iSetID, isCraft = GetItemInfo(itemID)
  itemCache[itemID] = true
  local dupe, player_item, now = self:processLootDupe(player,itemName,source)
  if dupe then
    return
  end
  local bind = bepgp:itemBinding(itemString)
  if not (bind) then return end
  local price,tier,price2,wand_discount,ranged_discount,shield_discount,onehand_discount,twohand_discount = bepgp:GetPrice(itemString, bepgp.db.profile.progress)
  price2 = type(price2)=="number" and price2 or nil
  if (not (price)) or (price == 0) then
    return
  end
  local class,_
  if player == bepgp._playerName then
    class = UnitClass("player") -- localized
  else
    _, class = bepgp:verifyGuildMember(player,true) -- localized
  end
  local allies = bepgp.db.profile.allies
  if allies[player] and not class then
    local standin = allies[player].standin
    if standin then
      class = allies[player].class
    end
  end
  if not (class) then return end
  local enClass,_,hexclass = bepgp:getClassData(class)
  self._lastPlayerItem, self._lastPlayerItemTime, self._lastPlayerItemSource = player_item, now, source
  local player_color = C:Colorize(hexclass,player)
  local off_price,off_price2 = math.floor(price*bepgp.db.profile.discount)
  if price2 then
    off_price2 = math.floor(price2*bepgp.db.profile.discount)
  end
  local epoch, timestamp = bepgp:getServerTime()
  local data = {[loot_indices.time]=epoch,[loot_indices.player]=player,[loot_indices.player_c]=player_color,[loot_indices.item]=itemLink,[loot_indices.item_id]=itemID,[loot_indices.bind]=bind,[loot_indices.price]=price,[loot_indices.off_price]=off_price,[loot_indices.price2]=price2,[loot_indices.off_price2]=off_price2,[loot_indices.class]=enClass,loot_indices=loot_indices}
  if price2 then
    if wand_discount then data.use_discount = true end
    if ranged_discount and ranged_discount:match(enClass) then data.use_discount = true end
    if shield_discount and shield_discount:match(enClass) then data.use_discount = true end
    if onehand_discount and onehand_discount:match(enClass) then data.use_discount = true end
    if twohand_discount and twohand_discount:match(enClass) then data.use_discount = true end
  end
  LD:Spawn(addonName.."DialogItemPoints", data)
end

function bepgp_loot:processLoot(player,itemLink,source)
  local itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
  if itemName then
    if itemCache[itemID] then
      self:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
    else
      local item = Item:CreateFromItemID(itemID)
      item:ContinueOnItemLoad(function()
        bepgp_loot:processLootCallback(player,itemLink,source,itemColor,itemString,itemName,itemID)
      end)
    end
  end
end

-- /run local _,link = GetItemInfo(16857)local data=BastionLoot:GetModule("BastionEPGP_loot"):findLootUnassigned(link)print(data[8] or "nodata")
function bepgp_loot:findLootUnassigned(itemID)
  for i,data in ipairs(bepgp.db.char.loot) do
    if data[loot_indices.item_id] == itemID and data[loot_indices.action] == bepgp.VARS.unassigned then
      return data
    end
  end
end

function bepgp_loot:addOrUpdateLoot(data,update)
  if not (update) then
    table.insert(bepgp.db.char.loot,data)
  end
  self:Refresh()
end

function bepgp_loot:tradeLootCallback(tradeTarget,itemColor,itemString,itemName,itemID,itemLink,tmpTrade)
  itemCache[itemID] = true
  local price,tier,price2 = bepgp:GetPrice(itemString, bepgp.db.profile.progress)
  price2 = type(price2)=="number" and price2 or nil
  if not (price) or price == 0 then
    return
  end
  local bind = bepgp:itemBinding(itemString)
  if (not bind) then return end
  if (bind == bepgp.VARS.bop) and (not tmpTrade) then return end
  local _, class = bepgp:verifyGuildMember(tradeTarget,true)
  local allies = bepgp.db.profile.allies
  if allies[tradeTarget] and not class then
    local standin = allies[tradeTarget].standin
    if standin then
      class = allies[tradeTarget].class
    end
  end
  if not class then return end
  local _,_,hexclass = bepgp:getClassData(class)
  local target_color = C:Colorize(hexclass,tradeTarget)
  local epoch, timestamp = bepgp:getServerTime()
  local data = self:findLootUnassigned(itemID)
  if (data) then
    data[loot_indices.time] = epoch
    data[loot_indices.player] = tradeTarget
    data[loot_indices.player_c] = target_color
    data.loot_indices = loot_indices
    data[loot_indices.update] = 1
    LD:Spawn(addonName.."DialogItemPoints", data)
  end
end

function bepgp_loot:raidLootAdmin()
  return (bepgp:GroupStatus()=="RAID" and bepgp:lootMaster() and bepgp:admin())
end

function bepgp_loot:tradeLoot()
  if self._tradeTarget and self._itemLink then
    local tradeTarget, itemLink, tmpTrade = self._tradeTarget, self._itemLink, self._tmpTrade
    local itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
    if (itemName) then
      if itemCache[itemID] then
        self:tradeLootCallback(tradeTarget,itemColor,itemString,itemName,itemID,itemLink,tmpTrade)
        self:tradeReset()
      else
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
          bepgp_loot:tradeLootCallback(tradeTarget,itemColor,itemString,itemName,itemID,itemLink,tmpTrade)
          self:tradeReset()
        end)
      end
    end
  else
    self:tradeReset()
  end
end
function bepgp_loot:tradeUnit(unit) -- we are trading a unit
  if self:raidLootAdmin() then
    self._tradeTarget = GetUnitName(unit,bepgp.db.profile.fullnames)
  end
end
function bepgp_loot:tradeName(event, name) -- someone else is trading us
  if self:raidLootAdmin() then
    local name = bepgp:Ambiguate(name)
    self._tradeTarget = name
  end
end
function bepgp_loot:tradeItemAccept() -- we accepted trade
  if self:raidLootAdmin() then
    local name = GetUnitName("npc",bepgp.db.profile.fullnames)
    if name and name ~= _G.UNKNOWNOBJECT then
      name = bepgp:Ambiguate(name)
      self._tradeTarget = name
    end
    if self._tradeTarget then
      local itemLink
      for id=1,MAX_TRADABLE_ITEMS do
        itemLink = GetTradePlayerItemLink(id)
        if (itemLink) then
          self._itemLink = itemLink
          self._tmpTrade = self:bopTradeable(id)
          self:RegisterEvent("TRADE_REQUEST_CANCEL","tradeReset")
          self:RegisterEvent("UI_ERROR_MESSAGE","tradeError")
          self:RegisterEvent("TRADE_CLOSED","awaitTradeLoot")
          return
        end
      end
      self._tradeTarget = nil
      self._itemLink = nil
      self._tmpTrade = nil
    end
  end
end
function bepgp_loot:awaitTradeLoot() -- TRADE_CLOSED
  self._awaitTradeTimer = self:ScheduleTimer("tradeLoot",2)
end
local tradeErrors = {
  [LE_GAME_ERR_TRADE_BOUND_ITEM] = true,
  [LE_GAME_ERR_TRADE_TARGET_BAG_FULL] = true,
  [LE_GAME_ERR_TRADE_QUEST_ITEM] = true,
  [LE_GAME_ERR_TRADE_MAX_COUNT_EXCEEDED] = true,
  [LE_GAME_ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED] = true,
  [LE_GAME_ERR_TRADE_BAG_FULL] = true,
  [LE_GAME_ERR_TRADE_TARGET_MAX_LIMIT_CATEGORY_COUNT_EXCEEDED_IS] = true,
  [LE_GAME_ERR_TRADE_NOT_ON_TAPLIST] = true,
  [LE_GAME_ERR_TRADE_TEMP_ENCHANT_BOUND] = true,
}
function bepgp_loot:tradeError(event,...)
  local err_type = ...
  if tradeErrors[err_type] then
    self:tradeReset()
  end
end
function bepgp_loot:tradeReset() -- TRADE_REQUEST_CANCEL, adhoc
  self._tradeTarget = nil
  self._itemLink = nil
  self._tmpTrade = nil
  if self._awaitTradeTimer then
    self:CancelTimer(self._awaitTradeTimer)
    self._awaitTradeTimer = nil
  end
  self:UnregisterEvent("TRADE_REQUEST_CANCEL")
  self:UnregisterEvent("TRADE_CLOSED")
  self:UnregisterEvent("UI_ERROR_MESSAGE")
end

function bepgp_loot:bopTradeable(id)
  G:SetTradePlayerItem(id)
  if G:Find(tradeable_pattern) then
    return true
  end
  return false
end

function bepgp_loot:bidCall(frame, button, context) -- context is one of "masterloot", "lootframe", "container"
  if bepgp.db.char.mode ~= "epgp" then return end
  if not IsAltKeyDown() then return end
  if not self:raidLootAdmin() then return end
  if not context then return end
  local itemLink,slot,hasItem,bagID,slotID
  if context == "lootframe" or context == "masterloot" then
    slot = frame.slot
    if not (slot and LootSlotHasItem(slot)) then return end
    itemLink = GetLootSlotLink(slot)
  elseif context == "container" then
    hasItem = frame.hasItem -- default bags, Bagnon, Combuctor, Baggins, AdiBags, tdBag2, Tukui, ElvUI
    if hasItem then
      if frame.ARK_Data then -- ArkInventory
        bagID, slotID = frame.ARK_Data.blizzard_id, frame.ARK_Data.slot_id
        if bagID and slotID then
          itemLink = GetContainerItemLink(bagID, slotID)
        end
      elseif frame.itemLink then -- AdiBags
        itemLink = frame.itemLink
      elseif frame.slots then -- Baggins
        bagID, slotID = frame.slots[1]:match("(%d+):(%d+)")
        if bagID and slotID then
          itemLink = GetContainerItemLink(bagID, slotID)
        end
      elseif frame.bag and frame.slot then -- Inventorian, tdBag2
        bagID, slotID = frame.bag, frame.slot
        if bagID and slotID then
          itemLink = GetContainerItemLink(bagID, slotID)
        end
      else -- get from ItemButton (default bags, Bagnon, BaudManifest, tdBag2, Baggins, Tukui, ElvUI)
        bagID, slotID = frame:GetParent():GetID(), frame:GetID()
        if bagID and slotID then
          itemLink = GetContainerItemLink(bagID, slotID)
        end
      end
    elseif (frame.bagID and frame.slotID) then -- cargBags_Nivaya
      bagID, slotID = frame.bagID, frame.slotID
      if bagID and slotID then
        itemLink = GetContainerItemLink(bagID, slotID)
      end
    end
  end
  if not itemLink then return end
  local itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
  local price = bepgp:GetPrice(itemString)
  if (not (price)) or (price == 0) then
    return
  end
  if button == "LeftButton" then
    bepgp:widestAudience(string.format(L["Whisper %s a + for %s (mainspec)"],bepgp._playerName,itemLink))
  elseif button == "RightButton" then
    bepgp:widestAudience(string.format(L["Whisper %s a - for %s (offspec)"],bepgp._playerName,itemLink))
  elseif button == "MiddleButton" then
    bepgp:widestAudience(string.format(L["Whisper %s a + or - for %s (mainspec or offspec)"],bepgp._playerName,itemLink))
  end
end

local bag_addons = {
  ["AdiBags"] = false,
  ["ArkInventory"] = false,
  ["Baggins"] = false,
  ["Bagnon"] = false,
  ["cargBags_Nivaya"] = false,
  ["Combuctor"] = false,
  ["ElvUI"] = false,
  ["Inventorian"] = false,
  ["tdBag2"] = false,
  ["Tukui"] = false,
}
function bepgp_loot:hookBagAddons()
  local hook_install = false
  for k,v in pairs(bag_addons) do
    local loading, finished = IsAddOnLoaded(k)
    if finished and loading and v == false then
      self:clickHandlerBags(k)
      hook_install = true
      -- break -- some players might have multiple bag addons, hook any found
    end
  end
  if hook_install then
    bepgp:debugPrint(format("%s %s",L["EPGP"],L["Bag hooks initialized"]))
  end
end

function bepgp_loot:hookContainerButton(itemButton)
  if itemButton and not itemButton._bepgpclicks then
    if type(itemButton:GetScript("OnClick")) == "function" then
      itemButton:RegisterForClicks("AnyUp")
      itemButton.RegisterForClicks = nop
      if not self:IsHooked(itemButton,"OnClick") then
        self:SecureHookScript(itemButton,"OnClick", function(frame, button) bepgp_loot:bidCall(frame, button, "container") end)
      end
      itemButton._bepgpclicks = true
    end
  end
end

function bepgp_loot:bagginsHook()
  local numbuttons = Baggins.db.char.lastNumItemButtons + Baggins.minSpareItemButtons
  for i=1,numbuttons do
    local itemButton = _G["BagginsPooledItemButton"..i]
    bepgp_loot:hookContainerButton(itemButton)
  end
end

-- /run BastionLoot:GetModule("BastionEPGP_loot"):clickHandlerBags()
function bepgp_loot:clickHandlerBags(id)
  if tonumber(id) then -- default bags
    for b = BACKPACK_CONTAINER,NUM_BAG_FRAMES do
      local containerName = "ContainerFrame"..(b+1)
      local numslots = GetContainerNumSlots(b)
      if numslots > 0 then
        for i = 1,numslots do
          local itemButton = _G[containerName.."Item"..i]
          self:hookContainerButton(itemButton)
        end
      end
    end
  else
    local addon = id
    if addon == "Bagnon" or addon == "Combuctor" or addon == "Tukui" then
      for b = BACKPACK_CONTAINER,NUM_BAG_FRAMES do
        local containerName = "ContainerFrame"..(b+1)
        for i = 1, MAX_CONTAINER_ITEMS do
          local itemButton = _G[containerName.."Item"..i]
          self:hookContainerButton(itemButton)
        end
      end
      bag_addons[addon] = true
    elseif addon == "Baggins" then
      self:SecureHook(Baggins,"RepopulateButtonPool","bagginsHook")
      self:bagginsHook()
      bag_addons[addon] = true
    elseif addon == "tdBag2" or addon == "Inventorian" then
      for b = 1, NUM_CONTAINER_FRAMES do
        local containerName = "ContainerFrame"..b
        for i = 1, MAX_CONTAINER_ITEMS do
          local itemButton = _G[containerName.."Item"..i]
          self:hookContainerButton(itemButton)
        end
      end
      bag_addons[addon] = true
    elseif addon == "AdiBags" then
      for i = 1, 160 do
        local itemButton = _G["AdiBagsItemButton"..i]
        self:hookContainerButton(itemButton)
      end
      bag_addons[addon] = true
    elseif addon == "ArkInventory" then
      for i=1,NUM_CONTAINER_FRAMES do
        for j=1,MAX_CONTAINER_ITEMS do
          local itemButton = _G["ARKINV_Frame1ScrollContainerBag"..i.."Item"..j]
          self:hookContainerButton(itemButton)
        end
      end
      bag_addons[addon] = true
    elseif addon == "cargBags_Nivaya" then
      local slotcount = 0
      for bagID = -3, 11, 1 do
        local slots = GetContainerNumSlots(bagID)
        for slot=1, slots do
          slotcount = slotcount + 1
          if BACKPACK_CONTAINER <= bagID or bagID <= NUM_BAG_FRAMES then
            local itemButton = _G["NivayaSlot"..slotcount]
            self:hookContainerButton(itemButton)
          end
        end
      end
      bag_addons[addon] = true
    elseif addon == "ElvUI" then
      for b = BACKPACK_CONTAINER,NUM_BAG_FRAMES do
        local containerName = "ElvUI_ContainerFrame"
        for i = 1, MAX_CONTAINER_ITEMS do
          local itemButton = _G[containerName.."Bag"..b.."Slot"..i]
          self:hookContainerButton(itemButton)
        end
      end
      bag_addons[addon] = true
    end
  end
end

function bepgp_loot:clickHandlerMasterLoot()
  MasterLooterFrame.Item:EnableMouse(true)
  MasterLooterFrame.Item._bepgpclicks = true
  MasterLooterFrame.Item:HookScript("OnMouseUp", function(self,button)
    local frame = self
    frame.slot = LootFrame.selectedSlot
    if frame.slot then
      bepgp_loot:bidCall(frame, button, "masterloot")
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

function bepgp_loot:clickHandlerLootElvUI()
  if ElvLootFrame and ElvLootFrame.slots then
    for id,button in pairs(ElvLootFrame.slots) do
      if button and not button._bepgpclicks then
        button:RegisterForClicks("AnyUp")
        button.RegisterForClicks = nop
        if not self:IsHooked(button,"OnClick") then
          button.slot = button:GetID()
          self:HookScript(button,"OnClick", function(frame, button) bepgp_loot:bidCall(frame, button, "lootframe") end)
        end
        button._bepgpclicks = true
      end
    end
  end
end

function bepgp_loot:clickHandlerLootXLoot(row,button,handled)
  if not handled then
    self:bidCall(row, button, "lootframe")
  end
end

function bepgp_loot:xlootUpdate()
  if XLootFrame and type(XLootFrame.rows) == "table" then
    for i,row in pairs(XLootFrame.rows) do
      if not row._bepgpclicks then
        row:RegisterForClicks("AnyUp")
        row.RegisterForClicks = nop
        row._bepgpclicks = true
      end
    end
  end
end

function bepgp_loot:hookLootAddons()
  local loading, finished = IsAddOnLoaded("ElvUI")
  if loading and finished then
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
  loading, finished = IsAddOnLoaded("XLoot_Frame")
  if loading and finished and XLootButtonOnClick then
    self:Hook("XLootButtonOnClick","clickHandlerLootXLoot")
    if XLootFrame then
      self:SecureHook(XLootFrame,"Update","xlootUpdate")
    end
  end
end

function bepgp_loot:clickHandlerLoot()
  for i=1,GetNumLootItems() do
    local button = _G["LootButton"..i]
    if button and not button._bepgpclicks then
      button:RegisterForClicks("AnyUp")
      button.RegisterForClicks = nop
      if not self:IsHooked(button,"OnClick") then
        self:HookScript(button,"OnClick", function(frame, button) bepgp_loot:bidCall(frame, button, "lootframe") end)
      end
      button._bepgpclicks = true
    end
  end
end

