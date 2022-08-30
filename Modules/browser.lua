local addonName, bepgp = ...
local moduleName = addonName.."_browser"
local bepgp_browser = bepgp:NewModule(moduleName, "AceEvent-3.0")
local ST = LibStub("ScrollingTable")
local LDD = LibStub("LibDropdown-1.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local Item = Item
--/run BastionLoot:GetModule("BastionEPGP_browser"):Toggle()
local data, subdata = { }, { }
local colorHighlight = {r=0, g=0, b=0, a=.9}
local progress, pricelist
local favorites, tokens
local tiervalues = { }
local filter = {["_FAV"]=C:Yellow(L["Favorites"])}
local locsorted = {"_FAV", "INVTYPE_HEAD", "INVTYPE_NECK", "INVTYPE_SHOULDER", "INVTYPE_CHEST", "INVTYPE_ROBE", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_FINGER", "INVTYPE_TRINKET", "INVTYPE_CLOAK", "INVTYPE_WEAPON", "INVTYPE_SHIELD", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND", "INVTYPE_HOLDABLE", "INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT", "INVTYPE_RELIC", "INVTYPE_NON_EQUIP"}
local progressmap
local tierlist,tiersort
local modlist,modsort
if bepgp._wrath then
  progressmap = {
    ["T10.5"] = {"T10.5", "T10","T9.5", "T9", "T8.5", "T8", "T7.5", "T7"},
    ["T10"]   = {"T10","T9.5", "T9", "T8.5", "T8", "T7.5", "T7"},
    ["T9.5"]  = {"T9.5", "T9", "T8.5", "T8", "T7.5", "T7"},
    ["T9"]    = {"T9", "T8.5", "T8", "T7.5", "T7"},
    ["T8.5"]  = {"T8.5", "T8", "T7.5", "T7"},
    ["T8"]    = {"T8", "T7.5", "T7"},
    ["T7.5"]  = {"T7.5","T7"},
    ["T7"]    = {"T7"}
  }
  tierlist,tiersort = {["T10.5"]="T10.5",["T10"]="T10",["T9.5"]="T9.5",["T9"]="T9",["T8.5"]="T8.5",["T8"]="T8",["T7.5"]="T7.5",["T7"]="T7"}, {"T10.5","T10","T9.5","T9","T8.5","T8","T7.5","T7"}
  modlist,modsort = {["T10.5"]="T10.5",["T10"]="T10",["T9"]="T9",["T8"]="T8",["T7"]="T7"},{"T10.5","T10","T9","T8","T7"}
end
if bepgp._bcc then
  progressmap = {
    ["T6.5"] = {"T6.5","T6","T5","T4"},
    ["T6"] = {"T6", "T5", "T4"},
    ["T5"] = {"T5", "T4"},
    ["T4"] = {"T4"}
  }
  tierlist,tiersort = {["T6.5"]="T6.5",["T6"]="T6",["T5"]="T5",["T4"]="T4"}, {"T6.5","T6","T5","T4"}
  modlist,modsort = {["T6.5"]="T6.5",["T6"]="T6",["T5"]="T5",["T4"]="T4"}, {"T6.5","T6","T5","T4"}
end
if bepgp._classic then
  progressmap = {
    ["T3"] = {"T3","T2.5","T2","T1.5","T1"},
    ["T2.5"] = {"T2.5","T2","T1.5","T1"},
    ["T2"] = {"T2","T1.5","T1"},
    ["T1"] = {"T1.5","T1"}
  }
  tierlist,tiersort = {["T3"]="T3",["T2.5"]="T2.5",["T2"]="T2",["T1.5"]="T1.5",["T1"]="T1"}, {"T3","T2.5","T2","T1.5","T1"}
  modlist,modsort = {["T3"]="T3",["T2.5"]="T2.5",["T2"]="T2",["T1"]="T1"}, {"T3","T2.5","T2","T1.5","T1"}
end
local questionblue = CreateAtlasMarkup("QuestRepeatableTurnin")

local function st_sorter_numeric(st,rowa,rowb,col)

end
local favmap = bepgp._favmap
local fav5,fav4,fav3,fav2,fav1 = favmap[5],favmap[4],favmap[3],favmap[2],favmap[1]
local menu_close = function()
  if bepgp_browser._ddmenu then
    bepgp_browser._ddmenu:Release()
  end
end
local favorite_options = {
  type = "group",
  name = L["BastionLoot options"],
  desc = L["BastionLoot options"],
  handler = bepgp_browser,
  args = {
    ["5"] = {
      type = "execute",
      name = fav5,
      desc = L["Add Favorite"],
      order = 1,
      func = function(info)
        bepgp_browser:favoriteAdd(5)
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["4"] = {
      type = "execute",
      name = fav4,
      desc = L["Add Favorite"],
      order = 2,
      func = function(info)
        bepgp_browser:favoriteAdd(4)
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["3"] = {
      type = "execute",
      name = fav3,
      desc = L["Add Favorite"],
      order = 3,
      func = function(info)
        bepgp_browser:favoriteAdd(3)
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["2"] = {
      type = "execute",
      name = fav2,
      desc = L["Add Favorite"],
      order = 4,
      func = function(info)
        bepgp_browser:favoriteAdd(2)
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["1"] = {
      type = "execute",
      name = fav1,
      desc = L["Add Favorite"],
      order = 5,
      func = function(info)
        bepgp_browser:favoriteAdd(1)
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["0"] = {
      type = "execute",
      name = L["Remove Favorite"],
      order = 6,
      func = function(info)
        bepgp_browser:favoriteClear()
        bepgp_browser:Refresh()
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["cancel"] = {
      type = "execute",
      name = _G.CANCEL,
      desc = _G.CANCEL,
      order = 7,
      func = function(info)
        C_Timer.After(0.2, menu_close)
      end,
    }
  }
}
local item_interact = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  local itemID = data[realrow].cols[6].value
  if itemID then
    bepgp_browser._selected = tonumber(itemID)
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
      if bepgp_browser._selected then
        bepgp_browser._ddmenu = LDD:OpenAce3Menu(favorite_options)
        bepgp_browser._ddmenu:SetPoint("CENTER", cellFrame, "CENTER", 0,0)
        return true
      end
    end
  end
  return false
end
local item_onenter = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
  if not realrow then return false end
  local itemID = data[realrow].cols[6].value
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

function bepgp_browser:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot browser"])
  container:SetWidth(640)
  container:SetHeight(290)
  container:EnableResize(false)
  container:SetLayout("List")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(_G.ITEMS),["width"]=150}, --name
    {["name"]=C:Orange(L["Item Type"]),["width"]=80}, --type
    {["name"]=C:Orange(L["Mainspec GP"]),["width"]=80}, --ms_gp
    {["name"]=C:Orange(L["Item Pool"]),["width"]=60,}, --tier
    {["name"]=C:Orange(L["Favorites"]),["width"]=60}, -- favorited
  }
  self._browser_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._browser_table:EnableSelection(true)
  self._browser_table:RegisterEvents({
    ["OnClick"] = item_interact,
    ["OnEnter"] = item_onenter,
    ["OnLeave"] = item_onleave,
  })
  self._browser_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_browser._browser_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_browser._browser_table:Hide() end)

  local filterslots = GUI:Create("Dropdown")
  filterslots:SetList(filter)
  filterslots:SetValue("FAV")
  filterslots:SetCallback("OnValueChanged", function(obj, event, choice)
    bepgp_browser:Refresh()
  end)
  filterslots:SetLabel(L["Filter by Slot"])
  filterslots:SetWidth(150)
  self._container._filterslots = filterslots
  container:AddChild(filterslots)

  local filtertier = GUI:Create("Dropdown")
  filtertier:SetList(tierlist,tiersort)
  filtertier:SetCallback("OnValueChanged", function(obj, event, choice, checked)
    bepgp_browser:Refresh()
  end)
  filtertier:SetLabel(L["Filter by Tier"])
  filtertier:SetWidth(150)
  filtertier:SetMultiselect(true)
  self._container._filtertier = filtertier
  container:AddChild(filtertier)

  local modpreview = GUI:Create("Dropdown")
  modpreview:SetList(modlist,modsort)
  modpreview:SetValue("FAV")
  modpreview:SetCallback("OnValueChanged", function(obj, event, choice)
    progress = choice
    bepgp_browser:Refresh()
  end)
  modpreview:SetLabel(L["Modifier Preview"])
  modpreview:SetWidth(150)
  self._container._modpreview = modpreview
  container:AddChild(modpreview)

  local export = GUI:Create("Button")
  export:SetAutoWidth(true)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof:Browser(subdata)
    end
  end)
  self._container._export = export
  container:AddChild(export)

  local import = GUI:Create("Button")
  import:SetAutoWidth(true)
  import:SetText(L["Import"])
  import:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof._iobrowserimport:Show()
    end
  end)
  self._container._browserimport = import
  container:AddChild(import)

  local help = GUI:Create("Label")
  help:SetWidth(150)
  help:SetText("\n\n"..string.format("%s%s",questionblue,L["Right-click a row to add or remove a Favorite."]))
  help:SetColor(1,1,0)
  help:SetJustifyV("TOP")
  help:SetJustifyH("CENTER")
  self._container._help = help
  container:AddChild(help)

  bepgp:make_escable(container,"add")
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end

function bepgp_browser:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_browser:favoriteAdd(level,id)
  local itemID = bepgp_browser._selected or id
  if not itemID then return end
  if not (GetItemInfoInstant(itemID)) then return end
  favorites[itemID] = level
  if tokens and tokens.GetToken then
    local token = tokens:GetToken(itemID)
    if token then
      favorites[token] = level
    end
  end
  if tokens and tokens.GetReward then
    local reward = tokens:GetReward(itemID)
    if reward and favorites[reward] then
      favorites[reward] = level
    end
  end
end

function bepgp_browser:favoriteClear(id)
  local itemID = bepgp_browser._selected or id
  if not itemID then return end
  favorites[itemID] = nil
  if tokens and tokens.GetReward then
    local reward = tokens:GetReward(itemID)
    if reward then
      if favorites[reward] then
        favorites[reward] = nil
      end
    end
  end
end

local function populate(data,link,subtype,price,tier,favrank,id,slotvalue)
  table.insert(data,{["cols"]={
    {["value"]=link},
    {["value"]=subtype},
    {["value"]=price},
    {["value"]=tier},
    {["value"]=favrank},
    {["value"]=id} -- 6
  }})
  bepgp_browser:RefreshGUI(slotvalue)
end

function bepgp_browser:RefreshGUI(slotvalue)
  self._browser_table:SetData(subdata)
  if self._browser_table and self._browser_table.showing then
    self._browser_table:SortData()
    if slotvalue == "_FAV" then
      local count = bepgp:table_count(subdata)
      self._container:SetTitle(string.format("%s (%s)",L["BastionLoot browser"],count))
    else
      self._container:SetTitle(L["BastionLoot browser"])
    end
  end
end

function bepgp_browser:Refresh()
  local slotvalue = self._container._filterslots:GetValue() or "_FAV"
  for i, widget in self._container._filtertier.pullout:IterateItems() do
    if widget.GetValue and widget.userdata.value then
      tiervalues[widget.userdata.value] = widget:GetValue()
    end
  end
  table.wipe(subdata)
  if slotvalue == "_FAV" then
    for id, rank in pairs(favorites) do
      if not (GetItemInfoInstant(id)) or type(id)~="number" then -- cleanup bad items
        self:favoriteClear(id)
      else
        local price, tier = bepgp:GetPrice(id,progress) --,pricelist[id][2]
        price = price or 0
        local favrank = favmap[rank]
        local name,link,_,_,_,_,subtype = GetItemInfo(id)
        if (link) then
          populate(subdata,link,subtype,price,tier,favrank,id,slotvalue)
        else
          local item = Item:CreateFromItemID(id)
          item:ContinueOnItemLoad(function()
            local id = item:GetItemID()
            local name,link,_,_,_,_,subtype = GetItemInfo(id)
            populate(subdata,link,subtype,price,tier,favrank,id,slotvalue)
          end)
        end        
      end
    end
    self._container._export.frame:Show()
  else
    for _, info in pairs(data[slotvalue]) do
      local id,price,tier = info[1],info[2],info[3]
      price, tier = bepgp:GetPrice(id,progress)
      price = price or 0
      if tiervalues[tier] then
        local rank = favorites[id]
        local favrank = rank and favmap[rank] or ""
        local name,link,_,_,_,_,subtype = GetItemInfo(id)
        if (link) then
          populate(subdata,link,subtype,price,tier,favrank,id,slotvalue)
        else
          local item = Item:CreateFromItemID(id)
          item:ContinueOnItemLoad(function()
            local id = item:GetItemID()
            local name,link,_,_,_,_,subtype = GetItemInfo(id)
            populate(subdata,link,subtype,price,tier,favrank,id,slotvalue)
          end)
        end
      end
    end
    self._container._export.frame:Hide()
  end
  self:RefreshGUI(slotvalue)
end

local lastEquipLoc -- DEBUG
function bepgp_browser:CoreInit()
  if not self._initDone then
    progress = bepgp.db.profile.progress
    favorites = bepgp.db.char.favorites
    local bepgp_prices
    if bepgp._classic then
      bepgp_prices = bepgp:GetModule(addonName.. "_prices")
      tokens = bepgp:GetModule(addonName.."_tokens")
    end
    if bepgp._bcc then
      bepgp_prices = bepgp:GetModule(addonName.."_prices_bc")
      tokens = bepgp:GetModule(addonName.."_tokens_bc")
    end
    if bepgp._wrath then
      bepgp_prices = bepgp:GetModule(addonName.."_prices_wrath")
      tokens = {}
    end
    if bepgp_prices and bepgp_prices._prices then
      pricelist = bepgp_prices._prices
    else
      pricelist = {}
    end
    for id,info in pairs(pricelist) do
      local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(id)
      local price, tier = bepgp:GetPrice(id,progress)
      --local tier = info[2]
      price = price or 0
      local equipLocDesc
      if itemEquipLoc and itemEquipLoc ~= "" then
        if itemEquipLoc == "INVTYPE_ROBE" then itemEquipLoc = "INVTYPE_CHEST" end
        data[itemEquipLoc] = data[itemEquipLoc] or {}
        table.insert(data[itemEquipLoc],{id,price,tier})
        equipLocDesc = _G[itemEquipLoc]
        if itemEquipLoc == "INVTYPE_SHIELD" then equipLocDesc = _G["SHIELDSLOT"] end
        if itemEquipLoc == "INVTYPE_RANGEDRIGHT" then equipLocDesc = _G["INVTYPE_RANGED"].."2" end
        filter[itemEquipLoc] = equipLocDesc
      else
        itemEquipLoc = "INVTYPE_NON_EQUIP"
        equipLocDesc = _G[itemEquipLoc]
        data[itemEquipLoc] = data[itemEquipLoc] or {}
        table.insert(data[itemEquipLoc],{id,price,tier})
        filter[itemEquipLoc] = equipLocDesc
      end
    end
    for i=#(locsorted),1,-1 do
      local loc = locsorted[i]
      if loc ~= "_FAV" and filter[loc]==nil then
        table.remove(locsorted,i)
      end
    end
    self._container._filterslots:SetList(filter,locsorted)
    self._container._filterslots:SetValue("_FAV")
    local tierfilter = progressmap[progress]
    for _,option in pairs(tierfilter) do
      self._container._filtertier:SetItemValue(option,true)
    end
    self._container._modpreview:SetValue(progress)
    self._initDone = true
  end
end
