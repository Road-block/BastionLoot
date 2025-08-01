local addonName, bepgp = ...
local moduleName = addonName.."_logs"
local bepgp_logs = bepgp:NewModule(moduleName)
local ST = LibStub("ScrollingTable")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")

local data = { }
local colorSilver = {r=199/255, g=199/255, b=207/255, a=1.0}
local colorRed = {r=1.0, g=0, b=0, a=.9}
local colorYellow = {r=0, g=1, b=1, a=.9}
local colorHidden = {r=0.0, g=0.0, b=0.0, a=0.0}
local colorHighlight = {r=0, g=0, b=0, a=.9}

local function st_sorter_numeric(st,rowa,rowb,col)
  local cella = st.data[rowa].cols[3].value
  local cellb = st.data[rowb].cols[3].value
  return tonumber(cella) > tonumber(cellb)
end

function bepgp_logs:OnEnable()
  local container = GUI:Create("Window")
  container:SetTitle(L["BastionLoot logs"])
  container:SetWidth(505)
  container:SetHeight(320)
  container:EnableResize(false)
  container:SetLayout("Flow")
  container:Hide()
  self._container = container
  local headers = {
    {["name"]=C:Orange(L["Time"]),["width"]=130,["comparesort"]=st_sorter_numeric}, -- server time
    {["name"]=C:Orange(L["Action"]),["width"]=320,["comparesort"]=st_sorter_numeric}, --action
    {["name"]="",["width"]=1,["comparesort"]=st_sorter_numeric,["sort"]=ST.SORT_DSC} -- order
  }
  self._logs_table = ST:CreateST(headers,15,nil,colorHighlight,container.frame) -- cols, numRows, rowHeight, highlight, parent
  self._logs_table.frame:SetPoint("BOTTOMRIGHT",self._container.frame,"BOTTOMRIGHT", -10, 10)
  container:SetCallback("OnShow", function() bepgp_logs._logs_table:Show() end)
  container:SetCallback("OnClose", function() bepgp_logs._logs_table:Hide() end)
  
  local clear = GUI:Create("Button")
  clear:SetAutoWidth(true)
  clear:SetText(L["Clear"])
  clear:SetCallback("OnClick",function()
    bepgp_logs:Clear()
  end)
  container:AddChild(clear)

  local export = GUI:Create("Button")
  export:SetAutoWidth(true)
  export:SetText(L["Export"])
  export:SetCallback("OnClick",function()
    local iof = bepgp:GetModule(addonName.."_io",true)
    if iof then
      iof:Logs()
    end
  end)
  container:AddChild(export)
  bepgp:make_escable(container,"add")
end

function bepgp_logs:addToLog(line,skipTime)
  local over = #(bepgp.db.char.logs)-bepgp.VARS.maxloglines+1
  if over > 0 then
    for i=1,over do
      table.remove(bepgp.db.char.logs,1)
    end
  end
  local timestamp,epoch
  if (skipTime) then
    timestamp = ""
  else
    epoch, timestamp = bepgp:getServerTime("%Y-%m-%d")
  end
  table.insert(bepgp.db.char.logs,{timestamp,line})
  self:Refresh()
end

function bepgp_logs:Toggle()
  if self._container.frame:IsShown() then
    self._container:Hide()
  else
    self._container:Show()
  end
  self:Refresh()
end

function bepgp_logs:Refresh()
  table.wipe(data)
  for i,v in ipairs(bepgp.db.char.logs) do
    table.insert(data,{["cols"]={{["value"]=v[1],["color"]=colorSilver},{["value"]=v[2],["color"]=colorYellow},{["value"]=i,["color"]=colorHidden}}})
  end
  self._logs_table:SetData(data)  
  if self._logs_table and self._logs_table.showing then
    self._logs_table:SortData()
  end
end

function bepgp_logs:Clear()
  table.wipe(bepgp.db.char.logs)
  self:Refresh()
  bepgp:Print(L["Logs cleared"])
end
