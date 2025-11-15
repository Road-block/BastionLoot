local addonName, bepgp = ...
local moduleName = addonName.."_alts"
local bepgp_alts = bepgp:NewModule(moduleName)
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")

local data = { }
local colorHighlight = {r=0, g=0, b=0, a=.9}
local volatile = {
  mainranks = {},
}

local row_onenter = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
  if not realrow then return false end
  local main, altstring = data[realrow].cols[1].value, data[realrow].cols[2].value
  if main and altstring then
    altstring = altstring:gsub(", ","\n")
    GameTooltip:SetOwner(rowFrame,"ANCHOR_TOP")
    GameTooltip:SetText(format("%s: %s",L["Main"],main))
    GameTooltip:AddDoubleLine(" ",L["Alts"])
    GameTooltip:AddLine(altstring,nil,nil,nil,true)
    GameTooltip:Show()
  end
end
local row_onleave = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
  if not realrow then return false end
  if GameTooltip:IsOwned(rowFrame) then
    GameTooltip_Hide()
  end
end

function bepgp_alts:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot alts"])
  container:SetWidth(600)
  container:SetHeight(290)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Main"]),["width"]=100}, --name
    {["name"]=C:Orange(L["Alts"]),["width"]=445}, --alts
  }
  self._alts_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._alts_table:RegisterEvents({
    ["OnEnter"] = row_onenter,
    ["OnLeave"] = row_onleave,
  })
  self._alts_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_alts._alts_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_alts._alts_table:Hide() end)
  bepgp:make_escable(container,"add")
  self:injectOptions()  
end

function bepgp_alts:injectOptions() -- .general.args.main.args
  bepgp._options.args.general.args.alts.args["alts"] = {
    type = "toggle",
    name = L["Enable Alts"],
    desc = L["Allow Alts to use Main\'s EPGP."],
    order = 5,
    hidden = function() return not (bepgp:admin()) end,
    disabled = function() return not (IsGuildLeader()) end,
    get = function() return not not bepgp.db.profile.altspool end,
    set = function(info, val) 
      bepgp.db.profile.altspool = not bepgp.db.profile.altspool
      if (IsGuildLeader()) then
        bepgp:shareSettings(true)
      end
    end,
  }
  bepgp._options.args.general.args.alts.args["alts_percent"] = {
    type = "range",
    name = L["Alts EP %"],
    desc = L["Set the % EP Alts can earn."],
    order = 10,
    hidden = function() return (not bepgp.db.profile.altspool) or (not bepgp:admin()) end,
    disabled = function() return not (IsGuildLeader()) end,
    get = function() return bepgp.db.profile.altpercent end,
    set = function(info, val) 
      bepgp.db.profile.altpercent = val
      if (IsGuildLeader()) then
        bepgp:shareSettings(true)
      end
    end,
    min = 0.5,
    max = 1,
    step = 0.05,
    isPercent = true
  }  
  bepgp._options.args.general.args.alts.args["alts_manager"] = {
    type = "group",
    name = L["Manage Alts"],
    order = 15,
    args = { },
  }
  local alts_manager = bepgp._options.args.general.args.alts.args["alts_manager"].args
  alts_manager["rank_filter"] = {
    type = "header",
    name = L["Rank Filters"],
    order = 16,
  }
  alts_manager["alts_rank"] = {
    type = "select",
    name = L["Alt Rank"],
    desc = L["Rank containing Alts for selection"],
    order = 17,
    get = function(info)
      return volatile.altrank
    end,
    set = function(info, val)
      volatile.altrank = val
      if volatile.mainranks[val]==true then
        volatile.mainranks[val] = false
      end
    end,
    values = function()
      if not bepgp._guildRanks then
        bepgp._guildRanks = bepgp:getGuildRanks()
      end
      return bepgp._guildRanks
    end,
    sorting = function()
      if not bepgp._guildRankSorting then
        bepgp._guildRanks, bepgp._guildRankSorting = bepgp:getGuildRanks()
      end
      return bepgp._guildRankSorting
    end,
  }
  alts_manager["main_ranks"] = {
    type = "multiselect",
    name = L["Main Ranks"],
    desc = L["Ranks containing Mains"],
    order = 18,
    get = function(info, key)
      return volatile.mainranks[key]
    end,
    set = function(info, key, value)
      volatile.mainranks[key] = value
      if volatile.altrank and volatile.altrank == key and value == true then
        volatile.mainranks[key] = false
      end
    end,
    values = function()
      return bepgp._guildRanks
    end,
    dialogControl = "Dropdown",
  }
  alts_manager["setup_alts"] = {
    type = "header",
    name = L["Add/Remove Alts"],
    desc = L["Select a Main first, then Add or Remove Alts"],
    order = 19,
  }
  alts_manager["main"] = {
    type = "select",
    name = L["Main"],
    get = function(info)
      return volatile.main
    end,
    set = function(info, val)
      volatile.main = val
    end,
    values = function()
      local tmpTab = {}
      for name,info in pairs(bepgp.db.profile.guildcache) do
        local rank
        if bepgp._guildRankIndex then
          rank = bepgp._guildRankIndex[info["r"]]
        end
        if rank and volatile.mainranks[rank] then
          tmpTab[name] = name
        end
      end
      return tmpTab
    end,
    order = 20,
  }
  alts_manager["add_alt"] = {
    type = "select",
    name = L["Add Alt"],
    get = false,
    set = function(info, val)
      bepgp:linkAlt(volatile.main, val)
    end,
    values = function()
      local tmpTab = {}
      for name,info in pairs(bepgp.db.profile.guildcache) do
        local rank
        local level, has_main, has_ally = info.l, info.m, info.a
        if bepgp._guildRankIndex then
          rank = bepgp._guildRankIndex[info["r"]]
        end
        if rank and volatile.altrank == rank and not (has_main or has_ally) then
          if level and level >= (bepgp.VARS.minlevel - 2) then
            tmpTab[name] = name
          end
        end
      end
      return tmpTab
    end,
    disabled = function()
      return not volatile.main or volatile.main == ""
    end,
    order = 21,
  }
  alts_manager["remove_alt"] = {
    type = "select",
    name = L["Remove Alt"],
    get = false,
    set = function(info, val)
      bepgp:removeAlt(val)
    end,
    values = function()
      local tmpTab = {}
      local main = volatile.main
      local alts = bepgp.db.profile.alts and bepgp.db.profile.alts[main]
      if main and alts then
        for alt,_ in pairs(alts) do
          if alt ~= "c_name" then
            tmpTab[alt]=alt
          end
        end
      end
      return tmpTab
    end,
    disabled = function()
      return not volatile.main or volatile.main == ""
    end,
    order = 22,
  }
  alts_manager["toggle"] = {
    type = "execute",
    name = L["Toggle Alts"],
    func = function()
      bepgp_alts:Toggle()
    end,
  }
end

function bepgp_alts:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_alts:Refresh()
  local alts = bepgp.db.profile.alts
  table.wipe(data)
  for main,t_alts in pairs(alts) do
    local altstring = ""
    local c_main
    for alt,class in pairs(t_alts) do
      if alt == "c_name" then
        c_main = class
      else
        local _,_,hexclass = bepgp:getClassData(class)
        local coloredalt = C:Colorize(hexclass, alt)
        if altstring == "" then
          altstring = coloredalt
        else
          altstring = string.format("%s, %s",altstring,coloredalt)
        end
      end
    end    
    table.insert(data,{["cols"]={
      {["value"]=c_main},
      {["value"]=altstring},
    }})
  end
  self._alts_table:SetData(data)  
  if self._alts_table and self._alts_table.showing then
    self._alts_table:SortData()
  end
end
