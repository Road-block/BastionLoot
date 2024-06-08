local addonName, bepgp = ...
local moduleName = addonName.."_standings"
local bepgp_standings = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0")
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local RAID_CLASS_COLORS = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)
local falsey = function() return false end
local CanViewOfficerNote = C_GuildInfo and C_GuildInfo.CanViewOfficerNote or _G.CanViewOfficerNote or falsey
local lastRequest, lastPush

local PLATE, MAIL, LEATHER, CLOTH = 4,3,2,1
local DPS, CASTER, HEALER, TANK = 4,3,2,1
local class_to_armor = {
  PALADIN = PLATE,
  WARRIOR = PLATE,
  DEATHKNIGHT = PLATE,
  HUNTER = MAIL,
  SHAMAN = MAIL,
  DRUID = LEATHER,
  ROGUE = LEATHER,
  MAGE = CLOTH,
  PRIEST = CLOTH,
  WARLOCK = CLOTH,
}
local armor_text = {
  [CLOTH] = L["CLOTH"],
  [LEATHER] = L["LEATHER"],
  [MAIL] = L["MAIL"],
  [PLATE] = L["PLATE"],
}
local class_to_role = {
  PALADIN = {HEALER,DPS,TANK,CASTER},
  PRIEST = {HEALER,CASTER},
  DRUID = {HEALER,TANK,DPS,CASTER},
  DEATHKNIGHT = {TANK,DPS},
  SHAMAN = {HEALER,DPS,CASTER},
  MAGE = {CASTER},
  WARLOCK = {CASTER},
  ROGUE = {DPS},
  HUNTER = {DPS},
  WARRIOR = {TANK,DPS},
}
local role_text = {
  [TANK] = L["TANK"],
  [HEALER] = L["HEALER"],
  [CASTER] = L["CASTER"],
  [DPS] = L["PHYS DPS"],
}
local data = { }
local colorHighlight = {r=0, g=0, b=0, a=.9}

local function st_sorter_numeric(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[col].value
  local cellb = st.data[rowb].cols[col].value
  local sort = st.cols[col].sort or st.cols[col].defaultsort
  if bepgp.db.char.classgroup then
    local classa = st.data[rowa].cols[5].value
    local classb = st.data[rowb].cols[5].value
    if classa == classb then
      if cella == cellb then
        local sortnext = st.cols[col].sortnext
        if sortnext then
          return st.data[rowa].cols[sortnext].value < st.data[rowb].cols[sortnext].value
        end
      else
        return tonumber(cella) > tonumber(cellb)
      end
    else
      if sort == ST.SORT_DSC then
        return classa < classb
      else
        return classa > classb
      end
    end
  else
    if cella == cellb then
      local sortnext = st.cols[col].sortnext
      if sortnext then
        return st.data[rowa].cols[sortnext].value < st.data[rowb].cols[sortnext].value
      end
    else
      if sort == ST.SORT_DSC then
        return tonumber(cella) > tonumber(cellb)
      else
        return tonumber(cella) < tonumber(cellb)
      end
    end
  end
end

function bepgp_standings:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot standings"])
  container:SetWidth(430)
  container:SetHeight(290)
  container:EnableResize(false)
  container:SetLayout("List")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(_G.NAME),["width"]=100}, --name
    {["name"]=C:Orange(L["ep"]:upper()),["width"]=50,["comparesort"]=st_sorter_numeric}, --ep
    {["name"]=C:Orange(L["gp"]:upper()),["width"]=50,["comparesort"]=st_sorter_numeric}, --gp
    {["name"]=C:Orange(L["pr"]:upper()),["width"]=50,["comparesort"]=st_sorter_numeric,["sortnext"]=1,["sort"]=ST.SORT_DSC}, --pr
  }
  self._standings_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._standings_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function()
    bepgp_standings._standings_table:Show()
    self:ContextShowHide()
  end)
  container:SetCallback("OnClose", function()
    bepgp_standings._standings_table:Hide()
    bepgp_standings._widgetoverlaylabel.frame:Hide()
  end)

  local overlay = GUI:Create("Label")
  overlay:SetWidth(250)
  overlay:SetText(L.STANDINGS_OVERLAY)
  overlay.frame:SetParent(self._standings_table.frame)
  overlay.frame:SetPoint("TOPLEFT",self._standings_table.frame,"TOPLEFT",5,-5)
  self._widgetoverlaylabel = overlay

  local export = GUI:Create("Button")
  export:SetAutoWidth(true)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof:Standings()
    end
  end)
  container:AddChild(export)

  local raid_only = GUI:Create("CheckBox")
  raid_only:SetLabel(L["Raid Only"])
  raid_only:SetValue(bepgp.db.char.raidonly)
  raid_only:SetCallback("OnValueChanged", function(widget,callback,value)
    bepgp.db.char.raidonly = value
    bepgp_standings:Refresh()
  end)
  container:AddChild(raid_only)
  self._widgetraid_only = raid_only

  local class_grouping = GUI:Create("CheckBox")
  class_grouping:SetLabel(L["Group by class"])
  class_grouping:SetValue(bepgp.db.char.classgroup)
  class_grouping:SetCallback("OnValueChanged", function(widget,callback,value)
    bepgp.db.char.classgroup = value
    bepgp_standings:Refresh()
  end)
  container:AddChild(class_grouping)
  self._widgetclass_grouping = class_grouping

  local update = GUI:Create("Button")
  update:SetAutoWidth(true)
  update:SetText(_G.UPDATE)
  update:SetCallback("OnClick",function()
    local bepgp_comms = bepgp:GetModule(addonName.."_comms",true)
    local now = GetTime()
    if bepgp_comms then
      if not lastRequest or (now - lastRequest >= 300) then -- 5mins CD on manual requests
        bepgp_comms:RequestData()
        lastRequest = now
        bepgp:Print(L["Request for standings sent."])
      else
        local cd = 300 - (now - lastRequest)
        bepgp:Print(format(L["On cooldown: Can send a new request in %s"],SecondsToClock(cd)))
      end
    end
  end)
  container:AddChild(update)
  self._widget_update = update

  local push = GUI:Create("Button")
  push:SetAutoWidth(true)
  push:SetText(L["Send"])
  push:SetCallback("OnClick",function()
    local bepgp_comms = bepgp:GetModule(addonName.."_comms",true)
    local now = GetTime()
    if bepgp_comms then
      if not lastPush or (now - lastPush >= 120) then -- 5mins CD on manual requests
        bepgp_comms:Transmit(bepgp_comms:GetDataForSending(),"GUILD")
        lastPush = now
        bepgp:Print(L["Sending Standings to Members."])
      else
        local cd = 120 - (now - lastPush)
        bepgp:Print(format(L["On cooldown: Can push updates in %s"],SecondsToClock(cd)))
      end
    end
  end)
  container:AddChild(push)
  self._widget_push = push

  bepgp:make_escable(container,"add")
  self:RegisterMessage(addonName.."_EPGPCACHE","CacheUpdate")
end

function bepgp_standings:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_standings:ContextShowHide()
  if CanViewOfficerNote() then
    self._widgetoverlaylabel.frame:Hide()
    self._widget_update.frame:Hide()
    self._widget_push.frame:Show()
  else
    if #data > 0 then
      self._widgetoverlaylabel.frame:Hide()
    else
      self._widgetoverlaylabel.frame:Show()
    end
    self._widget_update.frame:Show()
    self._widget_push.frame:Hide()
  end
end

function bepgp_standings:CacheUpdate()
  if not CanViewOfficerNote() then
    self:Refresh()
  end
end

function bepgp_standings:Refresh()
  local members = bepgp:buildRosterTable()
  local container = self._container
  local canViewONote = CanViewOfficerNote()
  local _epoch
  table.wipe(data)
  for k,v in pairs(members) do
    local ep, gp = 0, bepgp.VARS.basegp
    ep = bepgp:get_ep(v.name,v.onote) or 0
    if ep > 0 then
      gp, _epoch = bepgp:get_gp(v.name,v.onote)
      gp = gp or bepgp.VARS.basegp
    end
    if ep > 0 then
      local pr = ep/gp
      local eClass, class, hexclass = bepgp:getClassData(v.class)
      local color = RAID_CLASS_COLORS[eClass]
      --local armor_class = armor_text[class_to_armor[eClass]]
      table.insert(data,{["cols"]={
        {["value"]=v.name,["color"]=color},
        {["value"]=string.format("%.4g", ep)},
        {["value"]=string.format("%.4g", gp)},
        {["value"]=string.format("%.4g", pr),["color"]={r=1.0,g=215/255,b=0,a=1.0}},
        {["value"]=eClass}
      }})
    end
  end
  if _epoch then
    local _,timestamp = bepgp:getServerTime("%d,%b`%y","%H:%M",_epoch)
    container:SetTitle(format("%s (%s)",L["BastionLoot standings"],timestamp))
  elseif canViewONote then
    container:SetTitle(format("%s (%s)",L["BastionLoot standings"],GREEN_FONT_COLOR:WrapTextInColorCode(L["LIVE"])))
  else
    container:SetTitle(L["BastionLoot standings"])
  end
  self:ContextShowHide()
  self._standings_table:SetData(data)
  if self._standings_table and self._standings_table.showing then
    self._standings_table:SortData()
  end
end
