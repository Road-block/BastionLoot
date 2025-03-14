local addonName, bepgp = ...
local moduleName = addonName.."_io"
local bepgp_io = bepgp:NewModule(moduleName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local Dump = LibStub("LibTextDump-1.0")
local Parse = LibStub("LibParse")
local GUI = LibStub("AceGUI-3.0")

local temp_data = {}

function bepgp_io:OnEnable()
  self._iostandings = Dump:New(L["Export Standings"],250,320)
  self._ioloot = Dump:New(L["Export Loot"],520,320)
  self._iologs = Dump:New(L["Export Logs"],450,320)
  self._iobrowser = Dump:New(L["Export Favorites"],520,320)
  
  self._iobrowserimport = GUI:Create("Window")
  self._iobrowserimport:SetTitle(L["Import"])
  self._iobrowserimport:SetWidth(520)
  self._iobrowserimport:SetHeight(320)
  self._iobrowserimport:EnableResize(false)
  self._iobrowserimport:SetLayout("Fill")
  local browserImportEB = GUI:Create("MultiLineEditBox")
  browserImportEB:SetLabel(L["AtlasLootClassic and eightyupgrades.com exports are supported"])
  browserImportEB:SetFullWidth(true)
  self._iobrowserimport.editBox = browserImportEB
  self._iobrowserimport:Hide()
  self._iobrowserimport.editBox:SetCallback("OnEnterPressed", function(editBox)
    local text = editBox:GetText():trim()
    if text ~= "" then
      bepgp_io:BrowserImport(text)
      bepgp_io._iobrowserimport:Hide()
    end
  end)
  self._iobrowserimport:AddChild(browserImportEB)

  local thirdparty = GUI:Create("Button")
  thirdparty:SetAutoWidth(true)
  thirdparty:SetText(ADDONS)
  thirdparty:SetCallback("OnClick",bepgp_io.addonImport)
  self._iobrowserimport.addonBtn = thirdparty
  self._iobrowserimport:AddChild(thirdparty)
  thirdparty:SetPoint("LEFT", browserImportEB.button, "RIGHT", 5, 0)
  thirdparty:SetDisabled(true)
  hooksecurefunc(self._iobrowserimport, "Show", function()
    bepgp_io._iobrowserimport.editBox:SetText("")
    if LootReserve and LootReserve.Client and LootReserve.Client.CharacterFavorites then
      if bepgp:table_count(LootReserve.Client.CharacterFavorites)>0 then
        bepgp_io._iobrowserimport.addonBtn:SetDisabled(false)
        bepgp_io._iobrowserimport.addonBtn:SetText("LootReserve")
      end
    end
  end)

  self._ioreserves = Dump:New(L["Export Reserves"],450,320)
  self._ioroster = Dump:New(L["Export Raid Roster"],250,320)
  local bastionexport,_,_,_,reason = bepgp.GetAddOnInfo("BastionEPGP_Export")
  if not (reason == "ADDON_MISSING" or reason == "ADDON_DISABLED") then
    local loaded, finished = bepgp.IsAddOnLoaded("BastionEPGP_Export")
    if loaded then
      BastionEPGPExport = BastionEPGPExport or {}
      self._fileexport = BastionEPGPExport
      bepgp:debugPrint(L["BastionLoot will be saving to file in `\\WTF\\Account\\<ACCOUNT>\\SavedVariables\\BastionEPGP_Export.lua`"])
    end
  end
end

function bepgp_io:addonImport()
  local text
  for k,v in pairs(LootReserve.Client.CharacterFavorites) do
    if v then
      text = text and (text..format("\nitem=%d",k)) or format("item=%d",k)
    end
  end
  if text then
    bepgp_io._iobrowserimport.editBox:SetText(text)
    bepgp_io._iobrowserimport.editBox:Fire("OnTextChanged",text)
    bepgp_io._iobrowserimport.editBox.button:Enable()
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
  self._ioloot:AddLine(string.format("%s;%s;%s;%s;%s",L["Time"],L["ItemID"],L["Item"],L["Looter"],L["GP Action"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Time"],L["ItemID"],L["Item"],L["Looter"],L["GP Action"]}
  end
  for i,data in ipairs(bepgp.db.char.loot) do
    local timestamp, _ = data[loot_indices.time]
    -- account for old data
    if not string.find(timestamp, " ") then
      _, timestamp = bepgp:getServerTime("%Y-%m-%d",nil,timestamp)
    end
    local item = data[loot_indices.item]
    local itemColor, itemString, itemName, itemID = bepgp:getItemData(item)
    local looter = data[loot_indices.player]
    local action = data[loot_indices.action]
    if action == bepgp.VARS.msgp or action == bepgp.VARS.osgp or action == bepgp.VARS.bankde then
      self._ioloot:AddLine(string.format("%s;%s;%s;%s;%s",timestamp,itemID,itemName,looter,action))
      if self._fileexport then
        local entry = {}
        entry[L["Time"]] = timestamp
        entry[L["ItemID"]] = itemID
        entry[L["Item"]] = itemName
        entry[L["Looter"]] = looter
        entry[L["GP Action"]] = action
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

local url_link = "=HYPERLINK(\"https://www.wowhead.com/cata/item=%d\";%q)"
local wowhead_url = "https://www.wowhead.com/cata/item=%d"
if bepgp._wrath then
  url_link = "=HYPERLINK(\"https://www.wowhead.com/wotlk/item=%d\";%q)"
  wowhead_url = "https://www.wowhead.com/wotlk/item=%d"
end
if bepgp._bcc then
  url_link = "=HYPERLINK(\"https://www.wowhead.com/tbc/item=%d\";%q)"
  wowhead_url = "https://www.wowhead.com/tbc/item=%d"
end
if bepgp._classic then
  url_link = "=HYPERLINK(\"https://www.wowhead.com/classic/item=%d\";%q)"
  wowhead_url = "https://www.wowhead.com/classic/item=%d"
end
function bepgp_io:Browser(favorites)
  local keys
  self._iobrowser:Clear() -- item,itemtype,itempool,gp
  self._iobrowser:AddLine(string.format("%s?%s?%s?%s?%s",L["Item"],L["Item Type"],(_G.ITEMSLOTTEXT),L["Item Pool"],L["Mainspec GP"]))
  if self._fileexport then
    table.wipe(temp_data)
    keys = {L["Item"],L["Item Type"],L["Item Pool"],L["Mainspec GP"]}
  end
  for _,data in pairs(favorites) do
    local id,link,subtype,equiploc,price,tier = data.cols[7].value, data.cols[1].value, data.cols[2].value, data.cols[3].value, data.cols[4].value, data.cols[5].value
    local _,_,itemname = bepgp:getItemData(link)
    local url = string.format(url_link,id,itemname)
    self._iobrowser:AddLine(string.format("%s?%s?%s?%s?%s",url,subtype,equiploc,tier,price))
    if self._fileexport then
      local entry = {}
      entry[L["Item"]] = string.format(wowhead_url,id)
      entry[L["Item Type"]] = subtype
      entry[(_G.ITEMSLOTTEXT)] = equiploc
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
  local char_count = 11
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
    char_count = char_count + line:len() + 1 -- also add the linefeed
    if char_count >= 2000 then
      self._ioreserves:AddLine("```")
      self._ioreserves:AddLine("```css")
      i = i - 1
      char_count = 11
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

function bepgp_io:BrowserImport(text)
  local browser = bepgp:GetModule(addonName.."_browser")
  local retOK, data = pcall(Parse.JSONDecode,Parse,text)
  local change = false
  if retOK then -- sixty/seventy/eightyupgrades
    for k,v in pairs(data) do
      if k=="items" then
        for _,itemData in pairs(v) do
          local id = itemData.id and tonumber(itemData.id)
          if id then
            browser:favoriteAdd(-1,id)
            change = true
          end
        end
      end
    end
  else
    -- try atlasloot export format
    for strid in text:gmatch(":(%d+)") do
      local id = tonumber(strid)
      if id then
        browser:favoriteAdd(-2,id)
        change = true
      end
    end
    -- try our own export format
    for strid in text:gmatch("item=(%d+)") do
      local id = tonumber(strid)
      if id then
        browser:favoriteAdd(-2,id)
        change = true
      end
    end
  end
  if change then
    browser:Refresh()
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
