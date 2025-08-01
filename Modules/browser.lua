local addonName, bepgp = ...
local moduleName = addonName.."_browser"
local bepgp_browser = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceBucket-3.0")
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
local locsorted = {"_FAV", "INVTYPE_HEAD", "INVTYPE_NECK", "INVTYPE_SHOULDER", "INVTYPE_CHEST", "INVTYPE_ROBE", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_FINGER", "INVTYPE_TRINKET", "INVTYPE_CLOAK", "INVTYPE_WEAPON", "INVTYPE_SHIELD", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND", "INVTYPE_HOLDABLE", "INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT", "INVTYPE_RELIC", "INVTYPE_NON_EQUIP", "INVTYPE_NON_EQUIP_IGNORE"}
local progressmap
local tierlist,tiersort
local typelist,typesort = {["_ALL"]=C:Green(_G.ALL)}, { }
local modlist,modsort
local bulletpoint = "•"

local questionblue = CreateAtlasMarkup("QuestRepeatableTurnin")
local chatballon = CreateAtlasMarkup("ChatBallon")

local function itemtype_sort(a, b)
  if a == "_ALL" then return true end
  if b == "_ALL" then return false end
  if typelist[a] and typelist[b] then
    return typelist[a] < typelist[b]
  else
    return a < b
  end
end

local function st_sorter_plain(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[col].value
  local cellb = st.data[rowb].cols[col].value
  local sort = st.cols[col].sort or st.cols[col].defaultsort
  if cella == cellb then
    local sortnext = st.cols[col].sortnext
    if sortnext then
      return st.data[rowa].cols[sortnext].value < st.data[rowb].cols[sortnext].value
    end
  else
    local plain_a = cella and strmatch(cella,"|h(%b[])|h|r") or ""
    local plain_b = cellb and strmatch(cellb,"|h(%b[])|h|r") or ""
    if sort == ST.SORT_DSC then
      return plain_a > plain_b
    else
      return plain_a < plain_b
    end
  end
end

local function safe_equiploc(equiploc)
  if (equiploc == nil) or (equiploc == "") or (equiploc == "INVTYPE_NON_EQUIP_IGNORE") then
    return _G.INVTYPE_NON_EQUIP
  else
    return _G[equiploc]
  end
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
        C_Timer.After(0.2, menu_close)
      end,
    },
    ["0"] = {
      type = "execute",
      name = C:Red(L["Remove Favorite"]),
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
      order = 10,
      func = function(info)
        C_Timer.After(0.2, menu_close)
      end,
    }
  }
}
local item_interact = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  local itemID = data[realrow].cols[7].value
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
  local itemID = data[realrow].cols[7].value
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
  container:SetWidth(720)
  container:SetHeight(305)
  container:EnableResize(false)
  container:SetLayout("List")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(_G.ITEMS),["width"]=150,["comparesort"]=st_sorter_plain,["sortnext"]=2}, --name
    {["name"]=C:Orange(L["Item Type"]),["width"]=80}, --type
    {["name"]=C:Orange(_G.ITEMSLOTTEXT),["width"]=80}, --equip location
    {["name"]=C:Orange(L["Mainspec GP"]),["width"]=80}, --ms_gp
    {["name"]=C:Orange(L["Item Pool"]),["width"]=60,}, --tier
    {["name"]=C:Orange(L["Favorites"]),["width"]=60,["sort"]=ST.SORT_DSC}, -- favorited
  }
  self._browser_table = ST:CreateST(headers,16,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
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

  local filtertype = GUI:Create("Dropdown")
  filtertype:SetList(typelist,typesort)
  filtertype:SetCallback('OnValueChanged', function(obj, event, choice)
    bepgp_browser:Refresh()
  end)
  filtertype:SetLabel(L["Filter by Item Type"])
  filtertype:SetWidth(150)
  self._container._filtertype = filtertype
  container:AddChild(filtertype)

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
    local iof = bepgp:GetModule(addonName.."_io",true)
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
    local iof = bepgp:GetModule(addonName.."_io",true)
    if iof then
      iof._iobrowserimport:Show()
    end
  end)
  self._container._browserimport = import
  container:AddChild(import)

  local help = GUI:Create("Label")
  help:SetWidth(150)
  help:SetText(string.format("%s%s",questionblue,L["Right-click a row to add or remove a Favorite."]))
  help:SetColor(1,1,0)
  help:SetJustifyV("TOP")
  help:SetJustifyH("LEFT")
  self._container._help = help
  container:AddChild(help)

  local help_sr = GUI:Create("Label")
  help_sr:SetWidth(150)
  help_sr:SetText(string.format("%s%s",chatballon,L["Send Soft-Reserve"]))
  help_sr:SetColor(0,1,1)
  help_sr:SetJustifyV("TOP")
  help_sr:SetJustifyH("LEFT")
  self._container._help_sr = help_sr
  container:AddChild(help_sr)
  help_sr.frame:Hide()

  local clear = GUI:Create("Button")
  clear:SetAutoWidth(true)
  clear:SetText(_G.CLEAR_ALL)
  clear:SetCallback("OnClick",function()
    for item in pairs(favorites) do
      favorites[item] = nil
    end
    bepgp_browser:Refresh()
  end)
  self._container._clear = clear
  container:AddChild(clear)

  bepgp:make_escable(container,"add")
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
  self:RegisterMessage(addonName.."_PRICESYSTEM", "PriceSystemUpdate")

  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE",1.0,"CheckStatus")
  self:RegisterEvent("PARTY_LEADER_CHANGED","CheckStatus")
  self:RegisterEvent("GROUP_JOINED","CheckStatus")
  self:RegisterEvent("GROUP_LEFT","CheckStatus")
  self:RegisterEvent("PLAYER_ENTERING_WORLD","CheckStatus")

  self:RegisterEvent("CHAT_MSG_RAID", "captureSoftResCall")
  self:RegisterEvent("CHAT_MSG_RAID_LEADER", "captureSoftResCall")
  self:RegisterEvent("CHAT_MSG_RAID_WARNING", "captureSoftResCall")

  self:PriceSystemUpdate()
end

function bepgp_browser:Toggle(forceShow)
  if self._container.frame:IsShown() and (not forceShow) then
    self._container:Hide()
  else
    if self._initDone then
      self._container:Show()
    else
      bepgp:Print(L["Initializing.. Try again in a few seconds!"])
      return
    end
  end
  self:Refresh()
end

function bepgp_browser:favoriteAdd(level,id)
  if not favorites then return end
  local itemID = id or bepgp_browser._selected
  if not itemID then return end
  itemID = bepgp.GetItemInfoInstant(itemID)
  if not itemID then return end
  local update = bepgp_browser._selected and (not id)
  if update or (not favorites[itemID]) then
    favorites[itemID] = level
  end
  -- check if we're adding a reward and add the required turn-in (token)
  if tokens and tokens.GetToken then
    local token = tokens:GetToken(itemID)
    if token then
      favorites[token] = level
    end
  end
  if tokens and tokens.GetReward then
    local reward = tokens:GetReward(itemID)
    if type(reward) == "number" then -- a single reward, add it as well
      if favorites[reward] then
        favorites[reward] = level
      end
    elseif type(reward) == "table" then
      -- tbd
    end
  end
  C_Timer.After(0.1,function()
    bepgp_browser:Refresh()
  end)
end

function bepgp_browser:favoriteClear(id)
  local itemID = bepgp_browser._selected or id
  if not itemID then return end
  favorites[itemID] = nil
  if tokens and tokens.GetReward then
    local reward = tokens:GetReward(itemID)
    if type(reward) == "number" then -- a single reward, remove it as well
      if favorites[reward] then
        favorites[reward] = nil
      end
    elseif type(reward) == "table" then
      -- tbd
    end
  end
end

function bepgp_browser:softReserveSend(id)
  local itemID = bepgp_browser._selected or id
  if not itemID then return end
  itemID = bepgp.GetItemInfoInstant(itemID)
  if not itemID then return end
  local itemAsync = Item:CreateFromItemID(itemID)
  itemAsync:ContinueOnItemLoad(function()
    local link = itemAsync:GetItemLink()
    if bepgp._ML and bepgp:inRaid(bepgp._ML) then
      local msg = format("%s %s",L["res"],link)
      SendChatMessage(msg,"WHISPER",nil,bepgp._ML)
    end
  end)
end

local srcall_capture = L["Whisper %s \`res [itemlink]\` to soft reserve."]:gsub("%%s","(.+)"):gsub("%b[]","")
function bepgp_browser:captureSoftResCall(event, text, sender)
  if bepgp._SUSPEND then return end
  if bepgp.db.char.mode ~= "plusroll" then return end
  if not (bepgp._ML and bepgp:inRaid(bepgp._ML)) then return end
  local cleantext = text:gsub("%b[]","")
  if string.match(cleantext,srcall_capture) then
    self:Toggle(true)
  end
end

local function populate(data,link,subtype,price,tier,favrank,id,locdesc,slotvalue)
  tier = tier or NOT_APPLICABLE -- probably outside our pricelist
  table.insert(data,{["cols"]={
    {["value"]=link},
    {["value"]=subtype},
    {["value"]=locdesc},
    {["value"]=price},
    {["value"]=tier},
    {["value"]=favrank},
    {["value"]=id} -- 7
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
  self:CheckStatus()
end

function bepgp_browser:Refresh()
  if not bepgp_browser._container.frame:IsShown() then return end
  local slotvalue = self._container._filterslots:GetValue() or "_FAV"
  for i, widget in self._container._filtertier.pullout:IterateItems() do
    if widget.GetValue and widget.userdata.value then
      tiervalues[widget.userdata.value] = widget:GetValue()
    end
  end
  local typevalue = self._container._filtertype:GetValue() or "_ALL"
  table.wipe(subdata)
  if slotvalue == "_FAV" then
    for id, rank in pairs(favorites) do
      if not (bepgp.GetItemInfoInstant(id)) or type(id)~="number" then -- cleanup bad items
        self:favoriteClear(id)
      else
        local price, tier = bepgp:GetPrice(id,progress) --,pricelist[id][2]
        price = price or 0
        local favrank = favmap[rank]
        local _,link,_,_,_,_,subtype,_,equiploc = bepgp.GetItemInfo(id)
        local locdesc = safe_equiploc(equiploc)
        if (link) then
          if typevalue == "_ALL" or subtype == typevalue then
            populate(subdata,link,subtype,price,tier,favrank,id,locdesc,slotvalue)
          end
        else
          local item = Item:CreateFromItemID(id)
          item:ContinueOnItemLoad(function()
            local id = item:GetItemID()
            local link = item:GetItemLink()
            local _,_, subtype,equiploc = bepgp.GetItemInfoInstant(id)
            local locdesc = safe_equiploc(equiploc)
            if typevalue == "_ALL" or subtype == typevalue then
              populate(subdata,link,subtype,price,tier,favrank,id,locdesc,slotvalue)
            end
          end)
        end        
      end
    end
    self._container._export.frame:Show()
    self._container._browserimport.frame:Show()
  else
    for _, info in pairs(data[slotvalue]) do
      local id,price,tier = info[1],info[2],info[3]
      price, tier = bepgp:GetPrice(id,progress)
      price = price or 0
      if tiervalues[tier] then
        local rank = favorites[id]
        local favrank = rank and favmap[rank] or ""
        local _,link,_,_,_,_,subtype,_,equiploc = bepgp.GetItemInfo(id)
        local locdesc = safe_equiploc(equiploc)
        if (link) then
          if typevalue == "_ALL" or subtype == typevalue then
            populate(subdata,link,subtype,price,tier,favrank,id,locdesc,slotvalue)
          end
        else
          local item = Item:CreateFromItemID(id)
          item:ContinueOnItemLoad(function()
            local id = item:GetItemID()
            local link = item:GetItemLink()
            local _,_, subtype,equiploc = bepgp.GetItemInfoInstant(id)
            local locdesc = safe_equiploc(equiploc)
            if typevalue == "_ALL" or subtype == typevalue then
              populate(subdata,link,subtype,price,tier,favrank,id,locdesc,slotvalue)
            end
          end)
        end
      end
    end
    self._container._export.frame:Hide()
    self._container._browserimport.frame:Hide()
  end
  self:RefreshGUI(slotvalue)
end

function bepgp_browser:CheckStatus()
  if not (IsInRaid() and GetNumGroupMembers() > 1) then
    bepgp._ML = nil
  end
  local method, partyidx, raididx = GetLootMethod()
  if method == "master" then
    if raididx then
      local name = GetUnitName("raid"..raididx, bepgp.db.profile.fullnames)
      if name and name ~= _G.UNKNOWNOBJECT then
        name = bepgp:Ambiguate(name)
        bepgp._ML = name
      else
        bepgp._ML = nil
      end
    elseif partyidx then
      if partyidx == 0 then
        bepgp._ML = bepgp.db.profile.fullnames and bepgp._playerFullName or bepgp._playerName
      else
        local name = GetUnitName("party"..partyidx, bepgp.db.profile.fullnames)
        if name and name ~= _G.UNKNOWNOBJECT then
          name = bepgp:Ambiguate(name)
          bepgp._ML = name
        else
          bepgp._ML = nil
        end
      end
    else
      bepgp._ML = nil
    end
  else
    bepgp._ML = nil
  end
  if self._container then
    self._container:SetStatusText(bepgp._ML or "")
    if bepgp._ML then
      if not favorite_options.args["sr"] then
        favorite_options.args["sr"] = {
          type = "execute",
          name = C:Cyan(L["Soft-Reserve"]),
          desc = L["Send Soft-Reserve"],
          order = 7,
          func = function(info)
            bepgp_browser:softReserveSend()
            C_Timer.After(0.2, menu_close)
          end,
        }
      end
      self._container._help_sr.frame:Show()
    else
      if favorite_options.args["sr"] then
        favorite_options.args["sr"] = nil
      end
      self._container._help_sr.frame:Hide()
    end
  end
end

local function hookEJLoot()
  if ( not EncounterJournal ) and EncounterJournal_LoadUI then
    EncounterJournal_LoadUI()
  end
  if EncounterJournal_Loot_OnClick then
    hooksecurefunc("EncounterJournal_Loot_OnClick", function(self)
      if IsAltKeyDown() and self.itemID then
        bepgp_browser:favoriteAdd(-1,self.itemID)
        bepgp_browser:Toggle(true)
      end
    end)
  end
end

local lastEquipLoc -- DEBUG
function bepgp_browser:CoreInit()
  if not self._initDone then
    progress = bepgp.db.profile.progress
    favorites = bepgp.db.char.favorites
    self:PriceListLookups()
    self:PriceListData()
    self._container._filterslots:SetList(filter,locsorted)
    self._container._filterslots:SetValue("_FAV")
    self._container._filtertype:SetList(typelist,typesort)
    self._container._filtertype:SetValue("_ALL")
    local tierfilter = progressmap[progress]
    for _,option in pairs(tierfilter) do
      self._container._filtertier:SetItemValue(option,true)
    end    
    self._container._modpreview:SetValue(progress)
    if bepgp._cata or bepgp._mists then
      hookEJLoot()
    end
    self._initDone = true
  end
end

function bepgp_browser:PriceListData(redo)
  if pricelist then
    if redo then
      data = table.wipe(data)
      typesort = table.wipe(typesort)
    end
    for id,info in pairs(pricelist) do
      local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = bepgp.GetItemInfoInstant(id)
      local subName, isArmor = bepgp.GetItemSubClassInfo(itemClassID, itemSubClassID)
      local price, tier = bepgp:GetPrice(id,progress)
      --local tier = info[2]
      price = price or 0
      local equipLocDesc
      if itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE" then itemEquipLoc = _G["INVTYPE_NON_EQUIP_IGNORE"] or "" end
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
      typelist[itemSubType] = isArmor and format(" %s",C:Yellow(itemSubType)) or itemSubType
    end
    for i=#(locsorted),1,-1 do
      local loc = locsorted[i]
      if loc ~= "_FAV" and filter[loc]==nil then
        table.remove(locsorted,i)
      end
    end
    for k,v in pairs(typelist) do
      table.insert(typesort,k)
    end
    table.sort(typesort,itemtype_sort)
  end
end

local priceModLookup = {_classic={"_prices","_tokens"},_bcc={"_prices_bc","_tokens_bc"},_wrath={"_prices_wrath","_tokens_lk"},_cata={"_prices_cata","_tokens_cata"},_mists={"_prices_mists","_tokens_mists"}}
function bepgp_browser:PriceListLookups()
  local system = bepgp:GetPriceSystem(bepgp.db.profile.system)
  local flavor = system and system.flavor
  local bepgp_prices
  if bepgp._classic then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup._classic[1])
    tokens = bepgp:GetModule(addonName..priceModLookup._classic[2],true)
  end
  if bepgp._bcc then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup._bcc[1])
    tokens = bepgp:GetModule(addonName..priceModLookup._bcc[2],true)
  end
  if bepgp._wrath then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup._wrath[1])
    tokens = bepgp:GetModule(addonName..priceModLookup._wrath[2],true) or {}
  end
  if bepgp._cata then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup._cata[1])
    tokens = bepgp:GetModule(addonName..priceModLookup._cata[2],true) or {}
  end
  if bepgp._mists then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup._mists[1])
    tokens = bepgp:GetModule(addonName..priceModLookup._mists[2],true) or {}
  end
  if flavor then
    bepgp_prices = bepgp:GetModule(addonName..priceModLookup[flavor][1])
    tokens = bepgp:GetModule(addonName..priceModLookup[flavor][2],true) or {}
  end
  if bepgp_prices and bepgp_prices._prices then
    pricelist = bepgp_prices._prices
  else
    pricelist = {}
  end
end

function bepgp_browser:PriceSystemUpdate()
  local system = bepgp:GetPriceSystem(bepgp.db.profile.system)
  local flavor = system and system.flavor 
  if flavor then
    progressmap = bepgp._progsets[flavor].progressmap
    tierlist = bepgp._progsets[flavor].tierlist
    tiersort = bepgp._progsets[flavor].tiersort
    modlist = bepgp._progsets[flavor].modlist
    modsort = bepgp._progsets[flavor].modsort
  elseif bepgp._mists then
    progressmap = bepgp._progsets._mists.progressmap
    tierlist = bepgp._progsets._mists.tierlist
    tiersort = bepgp._progsets._mists.tiersort
    modlist = bepgp._progsets._mists.modlist
    modsort = bepgp._progsets._mists.modsort
  elseif bepgp._cata then
    progressmap = bepgp._progsets._cata.progressmap
    tierlist = bepgp._progsets._cata.tierlist
    tiersort = bepgp._progsets._cata.tiersort
    modlist = bepgp._progsets._cata.modlist
    modsort = bepgp._progsets._cata.modsort
  elseif bepgp._wrath then
    progressmap = bepgp._progsets._wrath.progressmap
    tierlist = bepgp._progsets._wrath.tierlist
    tiersort = bepgp._progsets._wrath.tiersort
    modlist = bepgp._progsets._wrath.modlist
    modsort = bepgp._progsets._wrath.modsort
  elseif bepgp._bcc then
    progressmap = bepgp._progsets._bcc.progressmap
    tierlist = bepgp._progsets._bcc.tierlist
    tiersort = bepgp._progsets._bcc.tiersort
    modlist = bepgp._progsets._bcc.modlist
    modsort = bepgp._progsets._bcc.modsort
  elseif bepgp._classic then
    progressmap = bepgp._progsets._classic.progressmap
    tierlist = bepgp._progsets._classic.tierlist
    tiersort = bepgp._progsets._classic.tiersort
    modlist = bepgp._progsets._classic.modlist
    modsort = bepgp._progsets._classic.modsort
  end
  if self._initDone then
    self:PriceListLookups()
    self:PriceListData(true)
  end   
  self._container._filtertier:SetList(tierlist,tiersort)
  self._container._modpreview:SetList(modlist,modsort)
  self._container._filterslots:SetList(filter,locsorted)
  self._container._filtertype:SetList(typelist,typesort)
  local tierfilter = progress and progressmap[progress]
  if tierfilter then
    for _,option in pairs(tierfilter) do
      self._container._filtertier:SetItemValue(option,true)
    end
  end
end
-- /run BastionLoot:GetModule("BastionLoot_browser"):CheckStatus()
