local addonName, bepgp = ...
local moduleName = addonName.."_io"
local bepgp_io = bepgp:NewModule(moduleName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local Dump = LibStub("LibTextDump-1.0")
local Parse = LibStub("LibParse")

local temp_data = {}

function bepgp_io:OnEnable()
  self._iostandings = Dump:New(L["Export Standings"],250,290)
  self._ioloot = Dump:New(L["Export Loot"],500,320)
  self._iologs = Dump:New(L["Export Logs"],450,320)
  self._iobrowser = Dump:New(L["Export Favorites"],520,290)
  self._ioreserves = Dump:New(L["Export Reserves"],450,300)
  self._ioroster = Dump:New(L["Export Raid Roster"],250,320)
  local bastionexport,_,_,_,reason = GetAddOnInfo("BastionEPGP_Export")
  if not (reason == "ADDON_MISSING" or reason == "ADDON_DISABLED") then
    local loaded, finished = IsAddOnLoaded("BastionEPGP_Export")
    if loaded then
      BastionEPGPExport = BastionEPGPExport or {}
      self._fileexport = BastionEPGPExport
      bepgp:debugPrint(L["BastionLoot will be saving to file in `\\WTF\\Account\\<ACCOUNT>\\SavedVariables\\BastionEPGP_Export.lua`"])
    end
  end
end

function bepgp_io:Standings()
  local keys
  self._iostandings:Clear()
  local members = bepgp:buildRosterTable()
  self._iostandings:AddLine(string.format("%s;%s;%s;%s",L["Name"],L["ep"],L["gp"],L["pr"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Name"],L["ep"],L["gp"],L["pr"]}
  end
  for k,v in pairs(members) do
    local ep = bepgp:get_ep(v.name,v.onote) or 0
    if ep > 0 then
      local gp = bepgp:get_gp(v.name,v.onote) or bepgp.VARS.basegp
      local pr = ep/gp
      self._iostandings:AddLine(string.format("%s;%s;%s;%.4g",v.name,ep,gp,pr))
      if self._fileexport then
        local entry = {}
        entry[L["Name"]] = v.name
        entry[L["ep"]] = ep
        entry[L["gp"]] = gp
        entry[L["pr"]] = tonumber(string.format("%.4g",pr))
        table.insert(temp_data, entry)
      end
    end
  end
  self._iostandings:Display()
  self:export("Standings", temp_data, keys, ";")
end

function bepgp_io:StandingsImport()
  if not IsGuildLeader() then return end
end

function bepgp_io:Loot(loot_indices)
  local keys
  self._ioloot:Clear()
  self._ioloot:AddLine(string.format("%s;%s;%s;%s",L["Time"],L["Item"],L["Looter"],L["GP Action"],L["ItemID"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Time"],L["Item"],L["Looter"],L["GP Action"],L["ItemID"]}
  end
  for i,data in ipairs(bepgp.db.char.loot) do
    local time = data[loot_indices.time]
    local item = data[loot_indices.item]
    local itemColor, itemString, itemName, itemID = bepgp:getItemData(item)
    local looter = data[loot_indices.player]
    local action = data[loot_indices.action]
    if action == bepgp.VARS.msgp or action == bepgp.VARS.osgp or action == bepgp.VARS.bankde then
      self._ioloot:AddLine(string.format("%s;%s;%s;%s;%s",time,itemName,looter,action,itemID))
      if self._fileexport then
        local entry = {}
        entry[L["Time"]] = time
        entry[L["Item"]] = itemName
        entry[L["Looter"]] = looter
        entry[L["GP Action"]] = action
        entry[L["ItemID"]] = itemID
        table.insert(temp_data, entry)
      end
    end
  end
  self._ioloot:Display()
  self:export("Loot", temp_data, keys, ";")
end

function bepgp_io:Logs()
  local keys
  self._iologs:Clear()
  self._iologs:AddLine(string.format("%s;%s",L["Time"],L["Action"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Time"],L["Action"]}
  end
  for i,data in ipairs(bepgp.db.char.logs) do
    self._iologs:AddLine(string.format("%s;%s",data[1],data[2]))
    if self._fileexport then
      local entry = {}
      entry[L["Time"]] = data[1]
      entry[L["Action"]] = data[2]
      table.insert(temp_data, entry)
    end
  end
  self._iologs:Display()
  self:export("Logs", temp_data, ";")
end

local url_link = "=HYPERLINK(\"https://tbc.wowhead.com/item=%d\";%q)"
function bepgp_io:Browser(favorites)
  local keys
  self._iobrowser:Clear() -- item,itemtype,itempool,gp
  self._iobrowser:AddLine(string.format("%s?%s?%s?%s",L["Item"],L["Item Type"],L["Item Pool"],L["Mainspec GP"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Item"],L["Item Type"],L["Item Pool"],L["Mainspec GP"]}
  end
  for _,data in pairs(favorites) do
    local id,link,subtype,price,tier = data.cols[6].value, data.cols[1].value, data.cols[2].value, data.cols[3].value, data.cols[4].value
    local _,_,itemname = bepgp:getItemData(link)
    local url = string.format(url_link,id,itemname)
    self._iobrowser:AddLine(string.format("%s?%s?%s?%s",url,subtype,tier,price))
    if self._fileexport then
      local entry = {}
      entry[L["Item"]] = string.format("https://classic.wowhead.com/item=%d",id)
      entry[L["Item Type"]] = subtype
      entry[L["Item Pool"]] = tier
      entry[L["Mainspec GP"]] = price
      table.insert(temp_data, entry)
    end
  end
  self._iobrowser:Display()
  self:export("Favorites", temp_data, ";")
end

local function sort_reserves(a,b)
  return tonumber(a.cols[4].value) > tonumber(b.cols[4].value)
end
function bepgp_io:Reserves(reserves)
  local keys
  self._ioreserves:Clear()
  local char_count = 8
  local num_reserves = #(reserves)
  local locked = bepgp.db.char.reserves.locked
  if num_reserves > 0 then
    self._ioreserves:AddLine("```css")
    table.sort(reserves,sort_reserves)
  end
  for i,data in ipairs(reserves) do
    local link, player, lock, id = data.cols[1].value, data.cols[2].value, data.cols[3].value, data.cols[4].value
    local _,_,itemname = bepgp:getItemData(link)
    local line = string.format("%s - %s",itemname,player)
    char_count = char_count + line:len()
    if char_count > 2000 then
      self._ioreserves:AddLine("```")
      self._ioreserves:AddLine("```css")
      i = i - 1
      char_count = 8
    else
      self._ioreserves:AddLine(line)
    end
  end
  if num_reserves > 0 then
    self._ioreserves:AddLine("```")
    local line
    if locked then
      line = string.format("%s:%s",L["Locked"],locked)
    else
      line = L["Unlocked"]
    end
    self._ioreserves:AddLine(line)
    self._ioreserves:Display()
  end
end

local sorted_roster = {}
function bepgp_io:Roster(roster)
  table.wipe(sorted_roster)
  self._ioroster:Clear()
  for k,v in pairs(roster) do
    table.insert(sorted_roster,{k,v.rank,v.main})
  end
  table.sort(sorted_roster, function(a,b)
    return a[1] < b[1]
  end)
  if #(sorted_roster) > 0 then
    self._ioroster:AddLine(string.format("**%s,%s,%s**",L["Name"],L["Rank"],L["Main"]))
    for _,member in ipairs(sorted_roster) do
      self._ioroster:AddLine(string.format("%s,%s,%s",member[1],member[2],member[3]))
    end
    self._ioroster:Display()
  end
end

function bepgp_io:export(context,data,keys,sep)
  if not self._fileexport then return end
  if context == "Standings" then
    table.sort(data, function(a,b)
      return a[L["pr"]] > b[L["pr"]]
    end)
  end
  self._fileexport[context] = {}
  self._fileexport[context].JSON = Parse:JSONEncode(data)
  self._fileexport[context].CSV = Parse:CSVEncode(keys, data, sep)
end

--[[
function sepgp_standings:Import()
  if not IsGuildLeader() then return end
  shooty_export.action:Show()
  shooty_export.title:SetText(C:Red("Ctrl-V to paste data. Esc to close."))
  shooty_export.AddSelectText(L.IMPORT_WARNING)
  shooty_export:Show()
end

function sepgp_standings.import()
  if not IsGuildLeader() then return end
  local text = shooty_export.edit:GetText()
  local t = {}
  local found
  for line in string.gmatch(text,"[^\r\n]+") do
    local name,ep,gp,pr = bepgp:strsplit(";",line)
    ep,gp,pr = tonumber(ep),tonumber(gp),tonumber(pr)
    if (name) and (ep) and (gp) and (pr) then
      t[name]={ep,gp}
      found = true
    end
  end
  if (found) then
    local count = 0
    shooty_export.edit:SetText("")
    for i=1,GetNumGuildMembers(1) do
      local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
      local name_epgp = t[name]
      if (name_epgp) then
        count = count + 1
        --bepgp:debugPrint(string.format("%s {%s:%s}",name,name_epgp[1],name_epgp[2])) -- Debug
        bepgp:update_epgp_v3(name_epgp[1],name_epgp[2],i,name,officernote)
        t[name]=nil
      end
    end
    bepgp:defaultPrint(string.format(L["Imported %d members."],count))
    local report = string.format(L["Imported %d members.\n"],count)
    report = string.format(L["%s\nFailed to import:"],report)
    for name,epgp in pairs(t) do
      report = string.format("%s%s {%s:%s}\n",report,name,t[1],t[2])
    end
    shooty_export.AddSelectText(report)
  end
end
]]
