local addonName, bepgp = ...
local moduleName = addonName.."_roster"
local bepgp_roster = bepgp:NewModule(moduleName, "AceEvent-3.0")
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")

local roster, data = { }, { }
local colorHighlight = {r=0, g=0, b=0, a=.9}
local colorSilver = {r=199/255, g=199/255, b=207/255, a=1.0}

--/run BastionLoot:GetModule("BastionEPGP_roster"):Toggle()
function bepgp_roster:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot raid roster"])
  container:SetWidth(405)
  container:SetHeight(320)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(_G.NAME),["width"]=100,["sort"]=ST.SORT_ASC}, -- name
    {["name"]=C:Orange(L["Rank"]),["width"]=150}, -- guild rank
    {["name"]=C:Orange(L["Main"]),["width"]=100}, -- main
  }
  self._roster_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._roster_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_roster._roster_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_roster._roster_table:Hide() end)

  local refresh = GUI:Create("Button")
  refresh:SetAutoWidth(true)
  refresh:SetText(L["Refresh"])
  refresh:SetCallback("OnClick",function()
    bepgp_roster:Refresh()
  end)
  container:AddChild(refresh)

  local export = GUI:Create("Button")
  export:SetAutoWidth(true)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io")
    if iof then
      iof:Roster(roster)
    end
  end)
  container:AddChild(export)
  bepgp:make_escable(container,"add")
end

function bepgp_roster:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_roster:Refresh()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
  else
    table.wipe(data)
    table.wipe(roster)
    local guildcache = bepgp:guildCache()
    if bepgp:GroupStatus() == "RAID" then
      for i=1,GetNumGroupMembers() do
        local name, rank, subgroup, level, lclass, eclass, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if name and (name ~= _G.UNKNOWNOBJECT) then
          name = Ambiguate(name,"short")
          local colortab = RAID_CLASS_COLORS[eclass]
          roster[name] = roster[name] or {}
          roster[name].color = colortab and {r=colortab.r, g=colortab.g, b=colortab.b, a=1.0} or colorSilver
          roster[name].rank = guildcache[name] and guildcache[name][2] or _G.NOT_APPLICABLE
          roster[name].main = guildcache[name] and guildcache[name][5] or _G.NOT_APPLICABLE
        end
      end
    end
    for name,info in pairs(roster) do
      table.insert(data,{["cols"]={
        {["value"]=name,["color"]=info.color},
        {["value"]=info.rank},
        {["value"]=info.main}
      }})
    end
    self._roster_table:SetData(data)
    if self._roster_table and self._roster_table.showing then
      self._roster_table:SortData()
    end
  end
end

function bepgp_roster:PLAYER_REGEN_ENABLED()
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  self:Refresh()
end
