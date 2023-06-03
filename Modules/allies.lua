local addonName, bepgp = ...
local moduleName = addonName.."_allies"
local bepgp_allies = bepgp:NewModule(moduleName)
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")

local data = { }
local colorHighlight = {r=0, g=0, b=0, a=.9}
local classValues = { }
local volatile = { }

function bepgp_allies:getClasses()
  if bepgp:table_count(classValues) > 0 then
    return classValues
  else
    for id = 1, GetNumClasses() do
      local lClass, eClass, classId = GetClassInfo(id)
      local _,_,hexColor = bepgp:getClassData(eClass)
      if classId then
        local key = format("%02d",classId)
        classValues[key] = C:Colorize(hexColor,lClass)
      end
    end
    return classValues
  end
end

function bepgp_allies:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot Allies"])
  container:SetWidth(290)
  container:SetHeight(290)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Ally"]),["width"]=100},
    {["name"]=C:Orange(L["Stand-in"]),["width"]=135},
  }
  self._allies_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._allies_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_allies._allies_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_allies._allies_table:Hide() end)
  bepgp:make_escable(container,"add")
  self:injectOptions()
end

function bepgp_allies:injectOptions() -- .general.args.allies.args
  bepgp._options.args.general.args.allies.args["allies"] = {
    type = "toggle",
    name = L["Enable Allies"],
    desc = L["Allow Allies to use Stand-in\'s EPGP."],
    order = 5,
    disabled = function() return not (IsGuildLeader()) end,
    get = function() return not not bepgp.db.profile.allypool end,
    set = function(info, val)
      bepgp.db.profile.allypool = not bepgp.db.profile.allypool
      if (IsGuildLeader()) then
        bepgp:shareSettings(true)
      end
    end,
  }
  bepgp._options.args.general.args.allies.args["standin_rank"] = {
    type = "select",
    name = L["Allowed Stand-in Rank"],
    desc = L["Select Rank that can be used as a Stand-in for Allies"],
    get = function()
      return bepgp.db.profile.standinrank
    end,
    set = function(info, val)
      bepgp.db.profile.standinrank = val
      if (IsGuildLeader()) then
        bepgp:shareSettings(true)
      end
    end,
    values = function()
      if not bepgp._guildRanks then
        bepgp._guildRanks = bepgp:getGuildRanks()
      end
      return bepgp._guildRanks
    end,
    sorting = function()
      local _
      if not bepgp._guildRankSorting then
        _, bepgp._guildRankSorting = bepgp:getGuildRanks()
      end
      return bepgp._guildRankSorting
    end,
    order = 10,
    disabled = function() return not (IsGuildLeader()) end,
  }
  bepgp._options.args.general.args.allies.args["stand_ins"] = {
    type = "group",
    name = L["Manage stand-ins"],
    order = 15,
    args = { },
  }
  local args_standins = bepgp._options.args.general.args.allies.args["stand_ins"].args
  args_standins["stand_in_help"] = {
    type = "description",
    name = L["Select a member to act \nas an epgp stand-in for an out of guild ally. \n|cffff0000Cannot be a guild main's Alt.|r"],
    fontSize = "medium",
    order = 21,
  }
  args_standins["stand_in"] = {
    type = "select",
    name = L["Stand-in (guild)"],
    desc = L["Select stand-in for ally"],
    order = 22,
    get = function(info)
      return volatile.standin
    end,
    set = function(info, val)
      volatile.standin = val
    end,
    values = function()
      local tmpTab = {}
      for name,info in pairs(bepgp.db.profile.guildcache) do
        local rank
        local level, has_main, has_ally = info.l, info.m, info.a
        if bepgp._guildRankIndex then
          rank = bepgp._guildRankIndex[info["r"]]
        end
        if rank and bepgp.db.profile.standinrank == rank and not (has_main or has_ally) then
          if level and level >= 1 then
            tmpTab[name] = name
          end
        end
      end
      return tmpTab
    end,
  }
  args_standins["add_header"] = {
    type = "header",
    name = L["Add Allies"],
    desc = L["Select a Stand-in first, then input the Ally name (exact) and Class"],
    order = 23,
  }
  args_standins["ally_class"] = {
    type = "select",
    name = L["Ally Class (off-guild)"],
    desc = L["Ally Class"],
    order = 23,
    get = function(info)
      return format("%02d",volatile.class)
    end,
    set = function(info, val)
      volatile.class = tonumber(val)
    end,
    values = function()
      return bepgp_allies:getClasses()
    end,
  }
  args_standins["add_ally"] = {
    type = "input",
    name = L["Ally Name (off-guild)"],
    desc = L["MUST be exact (capitalization, special chars)"],
    order = 25,
    get = false,
    set = function(info, val)
      bepgp:linkStandin(val, volatile.standin, volatile.class)
    end,
    disabled = function()
      return not (volatile.standin and volatile.class)
    end,
  }
  args_standins["rem_header"] = {
    type = "header",
    name = L["Remove Allies"],
    desc = L["Removes in-guiid epgp stand-in for an Ally"],
    order = 26,
  }
  args_standins["remove_ally"] = {
    type = "select",
    name = L["Remove Ally"],
    desc = L["Remove linked Ally stand-in"],
    order = 27,
    get = false,
    set = function(info, val)
      bepgp:removeStandin(val)
    end,
    values = function()
      local tmpTab = {}
      local allies = bepgp.db.profile.allies
      for ally, stdinfo in pairs(allies) do
        tmpTab[stdinfo["standin"]] = ally
      end
      return tmpTab
    end,
  }
  args_standins["toggle"] = {
    type = "execute",
    name = L["Toggle Allies"],
    func = function()
      bepgp_allies:Toggle()
    end,
  }
end

function bepgp_allies:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_allies:Refresh()
  local allies = bepgp.db.profile.allies
  table.wipe(data)
  for ally,t_ally in pairs(allies) do
    local _,_,hexClass = bepgp:getClassData(t_ally.class)
    local c_ally = C:Colorize(hexClass, ally)
    local standin = t_ally.standin
    table.insert(data,{["cols"]={
      {["value"]=c_ally},
      {["value"]=standin},
    }})
  end
  self._allies_table:SetData(data)
  if self._allies_table and self._allies_table.showing then
    self._allies_table:SortData()
  end
end
