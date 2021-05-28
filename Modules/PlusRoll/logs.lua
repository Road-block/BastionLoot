local addonName, bepgp = ...
local moduleName = addonName.."_plusroll_logs"
local bepgp_plusroll_logs = bepgp:NewModule(moduleName)
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local LD = LibStub("LibDialog-1.0")
local LDD = LibStub("LibDropdown-1.0")

local data = { }
local colorSilver = {r=199/255, g=199/255, b=207/255, a=1.0}
local colorRed = {r=1.0, g=0, b=0, a=.9}
local colorYellow = {r=0, g=1, b=1, a=.9}
local colorHidden = {r=0.0, g=0.0, b=0.0, a=0.0}
local colorHighlight = {r=0, g=0, b=0, a=.9}
local questionblue = CreateAtlasMarkup("QuestRepeatableTurnin")
local tags = {
  ["res"] = L["Reserve"],
  ["+1"] = L["Mainspec"],
  ["os"] = L["Offspec"],
  ["none"] = _G.NONE,
}
local loot_indices = { -- duplication from loot.lua here but beats coding around load order stuff
  time=1,
  player=2,
  player_c=3,
  item=4,
  item_id=5,
  log=6,
}
local log_indices = {
  time=1,
  player=2,
  player_c=3,
  item=4,
  item_id=5,
  tag=6
}

local function st_sorter_numeric(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[5].value
  local cellb = st.data[rowb].cols[5].value
  return tonumber(cella) > tonumber(cellb)
end

local menu_close = function()
  if bepgp_plusroll_logs._ddmenu then
    bepgp_plusroll_logs._ddmenu:Release()
  end
end
local assign_options = {
  type = "group",
  name = L["BastionLoot options"],
  desc = L["BastionLoot options"],
  handler = bepgp_plusroll_logs,
  args = {
    ["redo"] = {
      type = "execute",
      name = L["Redo Assignment"],
      desc = L["Redo Assignment"],
      order = 1,
      func = function(info)
        local log_index = bepgp_plusroll_logs._selected
        local log_entry = bepgp.db.char.plusroll_logs[log_index]
        local entry = {[loot_indices.player]=log_entry[log_indices.player],[loot_indices.item]=log_entry[log_indices.item],[loot_indices.item_id]=log_entry[log_indices.item_id],[loot_indices.player_c]=log_entry[log_indices.player_c],[loot_indices.log]=log_index,loot_indices=loot_indices,log_indices=log_indices}
        LD:Spawn(addonName.."DialogItemPlusPoints", entry)
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
local item_reassign = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
  if not realrow then return false end
  local log_index = data[realrow].cols[5].value
  if log_index then
    bepgp_plusroll_logs._selected = log_index
  else
    bepgp_plusroll_logs._selected = nil
  end
  if button == "RightButton" then
    if bepgp_plusroll_logs._selected then
      bepgp_plusroll_logs._ddmenu = LDD:OpenAce3Menu(assign_options)
      bepgp_plusroll_logs._ddmenu:SetPoint("CENTER", cellFrame, "CENTER", 0,0)
      return true
    end
  end
  return false
end

function bepgp_plusroll_logs:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot logs"])
  container:SetWidth(505)
  container:SetHeight(320)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Time"]),["width"]=100,["comparesort"]=st_sorter_numeric}, -- server time
    {["name"]=C:Orange(L["Name"]),["width"]=80,["comparesort"]=st_sorter_numeric}, -- player name
    {["name"]=C:Orange(L["Item"]),["width"]=200,["comparesort"]=st_sorter_numeric}, -- itemlink
    {["name"]=C:Orange(L["Action"]),["width"]=70,["comparesort"]=st_sorter_numeric}, --tag
    {["name"]="",["width"]=1,["comparesort"]=st_sorter_numeric,["sort"]=ST.SORT_DSC} -- order
  }
  self._logs_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._logs_table:RegisterEvents({
    ["OnClick"] = item_reassign,
  })
  self._logs_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_plusroll_logs._logs_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_plusroll_logs._logs_table:Hide() end)

  local clear = GUI:Create("Button")
  clear:SetAutoWidth(true)
  clear:SetText(L["Clear"])
  clear:SetCallback("OnClick",function()
    bepgp_plusroll_logs:Clear()
  end)
  container:AddChild(clear)

  local help = GUI:Create("Label")
  help:SetWidth(350)
  help:SetText(string.format("%s%s",questionblue,L["Right-click a row to redo assignment tag in case of error."]))
  help:SetColor(1,1,0)
  help:SetJustifyV("TOP")
  help:SetJustifyH("LEFT")
  self._container._help = help
  container:AddChild(help)

  bepgp:make_escable(container,"add")
end

function bepgp_plusroll_logs:addToLog(player,player_c,item,item_id,tag,skipTime)
  local over = #(bepgp.db.char.plusroll_logs)-bepgp.VARS.maxloglines+1
  if over > 0 then
    for i=1,over do
      table.remove(bepgp.db.char.plusroll_logs,1)
    end
  end
  local timestamp,_
  if (skipTime) then
    timestamp = ""
  else
    _, timestamp = bepgp:getServerTime()
  end
  table.insert(bepgp.db.char.plusroll_logs,{timestamp,player,player_c,item,item_id,tag})
  self:Refresh()
end

function bepgp_plusroll_logs:updateLog(index,tag)
  local entry = table.remove(bepgp.db.char.plusroll_logs,index)
  local player,player_c,item,item_id = entry[log_indices.player],entry[log_indices.player_c],entry[log_indices.item],entry[log_indices.item_id]
  self:addToLog(player,player_c,item,item_id,tag)
end

function bepgp_plusroll_logs:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_plusroll_logs:Refresh()
  table.wipe(data)
  for i,v in ipairs(bepgp.db.char.plusroll_logs) do
    local tag = tags[v[log_indices.tag]]
    table.insert(data,
      {["cols"]={
        {["value"]=v[log_indices.time],["color"]=colorSilver}, -- timestamp
        {["value"]=v[log_indices.player_c],}, -- name
        {["value"]=v[log_indices.item]}, -- link
        {["value"]=tag}, -- tag
        {["value"]=i,["color"]=colorHidden} -- log entry
      }})
  end
  self._logs_table:SetData(data)
  if self._logs_table and self._logs_table.showing then
    self._logs_table:SortData()
  end
end

function bepgp_plusroll_logs:Clear()
  table.wipe(bepgp.db.char.plusroll_logs)
  self:Refresh()
  bepgp:Print(L["Logs cleared"])
end
