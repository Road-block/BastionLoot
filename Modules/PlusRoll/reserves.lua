local addonName, bepgp = ...
local moduleName = addonName.."_plusroll_reserves"
local bepgp_plusroll_reserves = bepgp:NewModule(moduleName,"AceEvent-3.0")
local ST = LibStub("ScrollingTable")
local LDD = LibStub("LibDropdown-1.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local DF = LibStub("LibDeformat-3.0")
local Item = Item
--/run BastionLoot:GetModule("BastionLoot_plusroll_reserves"):Toggle()
local data = { }
local colorHighlight = {r=0, g=0, b=0, a=.9}
local colorLocked = {r=1, g=0, b=0, a=.9}
local colorUnlocked = {r=0, g=1, b=0, a=.9}
local colorUnknown = {r=.75, g=.75, b=.75, a=.9}
local players, items, unlocks = {},{},{}
local bepgp_plusroll_bids
local questionblue = CreateAtlasMarkup("QuestRepeatableTurnin")
local call_icon = L["Call"].."|TInterface\\CHATFRAME\\UI-ChatIcon-ArmoryChat:16:16:0:0:16:16:0:16:0:16:255:127:0|t"
local function st_sorter(st,rowa,rowb,col)
  --[[local cella = st.data[rowa].cols[4].value
  local cellb = st.data[rowb].cols[4].value
  return tonumber(cella) > tonumber(cellb)]]
  local cella = st.data[rowa].cols[col].value
  local cellb = st.data[rowb].cols[col].value
  local sort = st.cols[col].sort or st.cols[col].defaultsort
  if cella == cellb then
    local sortnext = st.cols[col].sortnext
    if sortnext then
      return st.data[rowa].cols[sortnext].value < st.data[rowb].cols[sortnext].value
    end
  else
    if sort == ST.SORT_DSC then
      return cella > cellb
    else
      return cella < cellb
    end
  end
end
local menu_close = function()
  if bepgp_plusroll_reserves._ddmenu then
    bepgp_plusroll_reserves._ddmenu:Release()
  end
end
local reserve_options = {
  type = "group",
  name = L["BastionLoot options"],
  desc = L["BastionLoot options"],
  handler = bepgp_plusroll_reserves,
  args = {
    ["unlock"] = {
      type = "execute",
      name = L["Unlock Reserve"],
      desc = L["Unlock Reserve"],
      order = 2,
      func = function(info)
        local p, i = bepgp_plusroll_reserves._selected.player,bepgp_plusroll_reserves._selected.item
        unlocks[p] = true
        bepgp_plusroll_reserves:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["remove"] = {
      type = "execute",
      name = L["Remove Reserve"],
      desc = L["Remove Reserve"],
      order = 3,
      func = function(info)
        local p, i = bepgp_plusroll_reserves._selected.player,bepgp_plusroll_reserves._selected.item
        bepgp_plusroll_reserves:RemoveReserve(p, i, true)
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["cancel"] = {
      type = "execute",
      name = _G.CANCEL,
      desc = _G.CANCEL,
      order = 4,
      func = function(info)
        C_Timer.After(0.2, menu_close)
      end,
    }
  }
}
local item_interact = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  local player, item_id = data[realrow].cols[2].value, data[realrow].cols[4].value
  if player and item_id then
    bepgp_plusroll_reserves._selected = bepgp_plusroll_reserves._selected or {}
    bepgp_plusroll_reserves._selected["player"] = player
    bepgp_plusroll_reserves._selected["item"] = item_id
    local link = data[realrow].cols[1].value
    if button == "LeftButton" then
      if IsModifiedClick("DRESSUP") then
        return DressUpItemLink(link)
      elseif IsModifiedClick("CHATLINK") then
        if ( ChatEdit_InsertLink(link) ) then
          return true
        end
      else
        return false
      end
    elseif button == "RightButton" then
      if bepgp_plusroll_reserves._selected.player then
        bepgp_plusroll_reserves._ddmenu = LDD:OpenAce3Menu(reserve_options)
        bepgp_plusroll_reserves._ddmenu:SetPoint("CENTER", cellFrame, "CENTER", 0,0)
        return true
      end
    end
  end
  return false
end
local item_onenter = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
  if not realrow then return false end
  local itemID = data[realrow].cols[4].value
  if itemID then
    GameTooltip:SetOwner(rowFrame,"ANCHOR_TOP")
    GameTooltip:SetItemByID(itemID)
    GameTooltip:Show()
  end
end
local item_onleave = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
  if not realrow then return false end
  if GameTooltip:IsOwned(rowFrame) then
    GameTooltip_Hide()
  end
end

function bepgp_plusroll_reserves:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot reserves"])
  container:SetWidth(580)
  container:SetHeight(365)
  container:EnableResize(false)
  container:SetLayout("List")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Item"]),["width"]=200,["comparesort"]=st_sorter,["sortnext"]=2,["sort"]=ST.SORT_DSC}, --item
    {["name"]=C:Orange(L["Name"]),["width"]=100,["comparesort"]=st_sorter}, --name
    {["name"]=C:Orange(L["Locked"]),["width"]=80,["comparesort"]=st_sorter}, --lock
  }
  self._reserves_table = ST:CreateST(headers,20,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._reserves_table:EnableSelection(true)
  self._reserves_table:RegisterEvents({
    ["OnClick"] = item_interact,
    ["OnEnter"] = item_onenter,
    ["OnLeave"] = item_onleave,
  })
  self._reserves_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_plusroll_reserves._reserves_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_plusroll_reserves._reserves_table:Hide() end)

  local togglelock = GUI:Create("CheckBox")
  togglelock:SetLabel(C:Green(L["Unlocked"]))
  togglelock:SetDescription(" ")
  togglelock:SetImage("Interface\\Buttons\\LockButton-Unlocked-Up")
  togglelock:SetValue(bepgp.db.char.reserves.locked)
  togglelock:SetCallback("OnValueChanged",function(widget,callback,value)
    bepgp_plusroll_reserves:ToggleLock(value)
  end)
  self._container._togglelock = togglelock
  container:AddChild(togglelock)

  local export = GUI:Create("Button")
  export:SetWidth(100)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof:Reserves(data)
    end
  end)
  self._container._export = export
  container:AddChild(export)

  local call = GUI:Create("Button")
  call:SetWidth(100)
  call:SetText(call_icon)
  call:SetCallback("OnClick",function()
    bepgp_plusroll_reserves:Call()
  end)
  container:AddChild(call)

  local spacer = GUI:Create("Label")
  spacer:SetWidth(100)
  spacer:SetHeight(20)
  spacer:SetText(" ")
  container:AddChild(spacer)

  local clear = GUI:Create("Button")
  clear:SetWidth(100)
  clear:SetText(L["Clear"])
  clear:SetCallback("OnClick",function()
    bepgp_plusroll_reserves:Clear()
  end)
  self._container._clear = clear
  container:AddChild(clear)

  local help = GUI:Create("Label")
  help:SetWidth(150)
  help:SetText("\n\n"..string.format("%s%s",questionblue,L["Right-click a row to manage player reserve."]))
  help:SetColor(1,1,0)
  help:SetJustifyV("TOP")
  help:SetJustifyH("CENTER")
  self._container._help = help
  container:AddChild(help)

  bepgp:make_escable(container,"add")
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end

function bepgp_plusroll_reserves:ToggleLock(value)
  table.wipe(unlocks)
  local bvalue = value and true or false
  if bvalue then
    if type(value)=="string" then
      bepgp.db.char.reserves.locked = value
    else
      local epoch, timestamp = bepgp:getServerTime("%a,%b-%d")
      bepgp.db.char.reserves.locked = timestamp
    end
    self._container._togglelock:SetDescription(bepgp.db.char.reserves.locked)
    self._container._togglelock:SetImage("Interface\\Buttons\\LockButton-Locked-Up")
    self._container._togglelock:SetLabel(C:Red(L["Locked"]))
  else
    self._container._togglelock:SetDescription(" ")
    self._container._togglelock:SetImage("Interface\\Buttons\\LockButton-Unlocked-Up")
    self._container._togglelock:SetLabel(C:Green(L["Unlocked"]))
    bepgp.db.char.reserves.locked = bvalue
  end
  self:Refresh()
end

function bepgp_plusroll_reserves:Clear()
  table.wipe(players)
  table.wipe(items)
  table.wipe(unlocks)
  bepgp.db.char.reserves.locked = false
  self:Refresh()
  bepgp:Print(L["Soft reserves Cleared."])
end

function bepgp_plusroll_reserves:Call()
  local out = string.format(L["Whisper %s \`res [itemlink]\` to soft reserve."],bepgp._playerName)
  bepgp:widestAudience(out)
end

local lootRes = {
  ["res"] = {L["(res)"],L["(reserve)"]},
  ["resq"] = {L["res"],L["reserve"],L["reserves"]},
  ["resrm"] = {L["rem"],L["cancel"]},
}
function bepgp_plusroll_reserves:captureRes(fromfilter, event, text, sender)
  if type(fromfilter)~="boolean" then
    sender = text
    text = event
    event = fromfilter
    fromfilter = nil
  end
  if bepgp.db.char.mode ~= "plusroll" then return false end
  if not (bepgp:lootMaster()) then return false end -- DEBUG
  sender = Ambiguate(sender,"short")
  if not bepgp:inRaid(sender) then return false end -- DEBUG
  if sender ~= bepgp._playerName then
    if not fromfilter then
      if self:resReply(text,sender) then
        return true
      end
      if self:resRemove(text,sender) then
        return true
      end
    end
  end
  if not (string.find(text, "|Hitem:", 1, true)) then return false end
  local linkstriptext, count = string.gsub(text,"|c%x+|H[eimt:%d]+|h%[.-%]|h|r"," ; ")
  if count > 1 then return false end
  local reskw_found
  local lowtext = string.lower(linkstriptext)
  for _,f in ipairs(lootRes.res) do
    reskw_found = string.find(lowtext,f)
    if (reskw_found) then break end
  end
  if (reskw_found) then
    local _, itemLink, itemColor, itemString, itemName, itemID
    _,_,itemLink = string.find(text,"(|c%x+|H[eimt:%d]+|h%[.-%]|h|r)")
    if (itemLink) and (itemLink ~= "") then
      itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
    end
    if (itemName) then
      if not fromfilter then
        self:AddReserve(sender,itemID)
      end
      return true
    end
    return false
  end
  return false
end

local function filterCapture(frame, event, text, sender, ...)
  local filter = bepgp_plusroll_reserves:captureRes(true, event, text, sender)
  if filter then
    return true
  else
    return false, text, sender, ...
  end
end

local function filterResponse(frame, event, text, sender, ...)
  if bepgp.db.char.mode ~= "plusroll" then 
    return false, text, sender, ...
  end
  if not (bepgp:lootMaster()) then 
    return false, text, sender, ...
  end
  local bastion_colon = string.format("^(%s:).*",addonName)
  local bastion_locked = string.format(".*(%s).*",L["Reserves are locked."])
  local bastion_remove = string.format(".*(%s).*",L["Reserve removed."])
  if text:match(bastion_colon) then
    if text:match(bastion_locked) or text:match(bastion_remove) then
      return false, text, sender, ...
    end
    return true
  end
  return false, text, sender, ...
end

function bepgp_plusroll_reserves:resReply(text,sender)
  local res_query
  for _,f in ipairs(lootRes.resq) do
    res_query = (string.lower(text) == f)
    if res_query then break end
  end
  if res_query then
    local entries = players[sender]
    if bepgp:table_count(entries) > 0 then
      for _,item in ipairs(entries) do
        local num_reserves, players = self:IsReserved(item)
        local names = ""
        if num_reserves > 0 then
          local msg = L["%s Reserves:"]
          local _, link = GetItemInfo(item)
          msg = string.format(msg,link)
          local first = true
          for player in pairs(players) do
            if player == sender then
              names = names .. (first and ("<"..player..">") or (",<"..player..">"))
            else
              names = names .. (first and player or (","..player))
            end
            first = false
          end
          msg = msg .. names
          SendChatMessage(string.format("%s:%s",addonName,msg),"WHISPER",nil,sender)
        end
      end
    end
    return true
  end
end

function bepgp_plusroll_reserves:resRemove(text, sender)
  local rem_query
  for _,f in ipairs(lootRes.resrm) do
    rem_query = (string.match(text, "^("..f..")%A+"))
    if rem_query then break end
  end
  if rem_query then
    if not (string.find(text, "|Hitem:", 1, true)) then return false end
    local linkstriptext, count = string.gsub(text,"|c%x+|H[eimt:%d]+|h%[.-%]|h|r"," ; ")
    if count > 1 then return false end
    local _, itemLink, itemColor, itemString, itemName, itemID
    _,_,itemLink = string.find(text,"(|c%x+|H[eimt:%d]+|h%[.-%]|h|r)")
    if (itemLink) and (itemLink ~= "") then
      itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
    end
    if (itemName) then
      bepgp_plusroll_reserves:RemoveReserve(sender, itemID, true)
      return true
    end
  end
end

function bepgp_plusroll_reserves:IsReservedExact(item, player)
  if not players[player] then return false end
  local index = tIndexOf(players[player], item)
  if index then
    return true, index
  end
end

function bepgp_plusroll_reserves:NumReserves(player)
  if not players[player] then return 0 end
  return #players[player]
end

function bepgp_plusroll_reserves:RemoveReserve(player, item, masterlooter)
  local reserved, index = bepgp_plusroll_reserves:IsReservedExact(item, player)
  if reserved then
    table.remove(players[player],index)
    if bepgp:table_count(players[player]) == 0 then
      players[player] = nil
    end
    if items[item] and items[item][player] then
      items[item][player] = nil
      if bepgp:table_count(items[item]) == 0 then
        items[item]=nil
      end
    end
    if masterlooter and (player ~= bepgp._playerName) and bepgp:inRaid(player) then
      SendChatMessage(string.format("%s:%s",addonName,L["Reserve removed."]),"WHISPER",nil,player)
    end
  end
  self:Refresh()
end

--[[
Add the ability to send reserve requests from browser
Add comms sending reserve list
]]
--/run BastionLoot:GetModule("BastionLoot_plusroll_reserves"):AddReserve("Bushido",45587)
function bepgp_plusroll_reserves:AddReserve(player,item)
  local reserved, index = bepgp_plusroll_reserves:IsReservedExact(item, player)
  if reserved and index then return end
  local inform = player ~= bepgp._playerName
  if bepgp.db.char.reserves.locked and not unlocks[player] then
    SendChatMessage(string.format("%s:%s",addonName,L["Reserves are locked."]),"WHISPER",nil,player)
    return
  end
  local count = bepgp_plusroll_reserves:NumReserves(player)
  local max_reserves = bepgp.db.char.maxreserves
  if count == max_reserves and max_reserves > 1 then
    if inform then
      SendChatMessage(string.format("%s:%s",addonName,string.format(L["You already have %s/%s reserves. Whisper \'rem [itemlink]\' to remove one."],count,max_reserves)),"WHISPER",nil,player)
    end
    return
  end
  if count < max_reserves or max_reserves == 1 then
    players[player] = players[player] or {}
    local index = math.min(#(players[player])+1,max_reserves)
    local prev_item = players[player][index]
    if prev_item and items[prev_item] and items[prev_item][player] then
      items[prev_item][player] = nil
      if bepgp:table_count(items[prev_item]) == 0 then
        items[prev_item]=nil
      end
    end
    players[player][index] = item
    items[item] = items[item] or {}
    items[item][player] = true
    if unlocks[player] and bepgp.db.char.reserves.locked then
      unlocks[player] = nil
    end
    if inform then
      if prev_item then
        SendChatMessage(string.format("%s:%s",addonName,L["Reserve updated."]),"WHISPER",nil,player)
      else
        SendChatMessage(string.format("%s:%s",addonName,L["Reserve added."]),"WHISPER",nil,player)
      end
    end
  end
  self:Toggle(true)
end

function bepgp_plusroll_reserves:IsReserved(item)
  local num_reserves = bepgp:table_count(items[item])
  if num_reserves > 0 then
    return num_reserves, items[item]
  else
    return
  end
end

function bepgp_plusroll_reserves:Toggle(show)
  if self._container.frame:IsShown() and (not show) then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

local function populate(data,link,player,lock,id)
  local cached = bepgp:groupCache(player)
  local color = cached and cached.color or colorUnknown
  local c_lock = lock and colorLocked or colorUnlocked
  lock = lock and _G.YES or _G.NO
  table.insert(data,{["cols"]={
    {["value"]=link},
    {["value"]=player,["color"]=color},
    {["value"]=tostring(lock),["color"]=c_lock},
    {["value"]=id} -- 4
  }})
  bepgp_plusroll_reserves:RefreshGUI()
end

function bepgp_plusroll_reserves:RefreshGUI()
  self._reserves_table:SetData(data)
  if self._reserves_table and self._reserves_table.showing then
    self._reserves_table:SortData()
    local player_count = bepgp:table_count(players)
    local item_count = bepgp:table_count(data)
    player_count = string.format("%d |4Player:Players;",player_count)
    item_count = string.format("%d |4Item:Items;",item_count)
    self._container:SetTitle(string.format("%s: %s/%s",L["BastionLoot reserves"],player_count, item_count))
  end
end

function bepgp_plusroll_reserves:Refresh()
  table.wipe(data)
  for player,items in pairs(players) do
    for i,id in ipairs(items) do
      local lock = bepgp.db.char.reserves.locked
      if unlocks[player] then
        lock = false
      end
      if tonumber(id) then
        local _, link = GetItemInfo(id)
        if (link) then
          populate(data,link,player,lock,id)
        else
          local itemAsync = Item:CreateFromItemID(id)
          itemAsync:ContinueOnItemLoad(function()
            local id = itemAsync:GetItemID()
            local link = itemAsync:GetItemLink()
            populate(data,link,player,lock,id)
          end)
        end
      else
        -- cleanup old structure
        items[i] = nil
      end
    end
  end
  self:RefreshGUI()
end

function bepgp_plusroll_reserves:CoreInit()
  if not self._initDone then
    bepgp_plusroll_bids = bepgp:GetModule(addonName.."_plusroll_bids")
    players = bepgp.db.char.reserves.players
    items = bepgp.db.char.reserves.items
    self:ToggleLock(bepgp.db.char.reserves.locked)
    self:RegisterEvent("CHAT_MSG_WHISPER", "captureRes")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterCapture)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterResponse)
    bepgp_plusroll_bids = bepgp:GetModule(addonName.."_plusroll_bids")
    self._initDone = true
  end
end
