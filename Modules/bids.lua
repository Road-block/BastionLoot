local addonName, bepgp = ...
local moduleName = addonName.."_bids"
local bepgp_bids = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local DF = LibStub("LibDeformat-3.0")
local T = LibStub("LibQTip-1.0")
local LD = LibStub("LibDialog-1.0_Roadblock")
local RAID_CLASS_COLORS = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)
--/run BastionLoot:GetModule("BastionLoot_bids"):bidPrint("\124cff0070dd\124Hitem:19915:0:0:0:0:0:0:0:0\124h[Zulian Defender]\124h\124r","Gotwood","need","greed","bid","roll")
local colorUnknown = {r=.75, g=.75, b=.75, a=.9}
local colorPRcell = {r=1.0, g=240/255, b=167/255, a=1.0}
bepgp_bids.bids_main,bepgp_bids.bids_off,bepgp_bids.bids_xmog,bepgp_bids.bid_item = {},{},{},{}
local bids_blacklist = {}
local bidlink = {
  ["ms"]      = "|cff4DA6FF|Haddon:"..addonName..":1:$ML|h["..L["Mainspec"].."]|h|r",
  ["os"]      = "|cffB6FFA7|Haddon:"..addonName..":2:$ML|h["..L["Offspec"].."]|h|r",
  ["msroll"]  = "|cff4DA6FF|Haddon:"..addonName..":3:$ML|h["..L["Mainspec"].."]|h|r",
  ["osroll"]  = "|cffB6FFA7|Haddon:"..addonName..":4:$ML|h["..L["Offspec"].."]|h|r",
  ["prveto"]  = "|cffFFF0A7|Haddon:"..addonName..":5:$ML|h["..L["Use PR"].."]|h|r",
  ["xmog"]    = "|cffD2B48C|Haddon:"..addonName..":6:$ML|h["..L["Transmog"].."]|h|r",
}
local out = "|cff9664c8"..addonName..":|r %s"
local running_bid
local color_msgp, color_osgp = "4DA6FF", "B6FFA7"
local DATAID = {NAME=1,CLASS=2,VAL1=3,VAL2=4,PRIO=5,PRIOTYPE=6,RANK=7,RANKID=8,MAIN=9,WINCOUNT=10}
local prioRoll, prioEpgp = 1,2
local bepgp_loot

-- rank > minep > pr
local pr_sorter_bids_rank = function(a,b)
  local minep = bepgp.db.profile.minep
  local priorank = bepgp.db.char.priorank
  local wincount_sort = bepgp.db.char.wincountepgp
  -- name(1), class(2), ep(3), gp(4), pr or roll(5), priotype(6), rank(7), rankid(8), main(9), wincount(10)
  local a_rank_pass = a[8] <= priorank
  local b_rank_pass = b[8] <= priorank
  if a[6] ~= b[6] then -- comparing different prio types
    return tonumber(a[6]) > tonumber(b[6]) -- PR before Rolls
  else -- comparing same prio types
    if a[6] == prioEpgp then -- comparing epgp
      if a_rank_pass and b_rank_pass or (not a_rank_pass and not b_rank_pass) then
        if minep > 0 then -- compare EP cuttoff, then PR
          local a_over = a[3]-minep >= 0
          local b_over = b[3]-minep >= 0
          if a_over and b_over or (not a_over and not b_over) then
            if a[5] ~= b[5] then
              return tonumber(a[5]) > tonumber(b[5])
            else
              return tonumber(a[3]) > tonumber(b[3])
            end
          elseif a_over and (not b_over) then
            return true
          elseif b_over and (not a_over) then
            return false
          end
        else -- just PR compare
          if a[5] ~= b[5] then
            return tonumber(a[5]) > tonumber(b[5])
          else
            return tonumber(a[3]) > tonumber(b[3])
          end
        end
      elseif a_rank_pass and (not b_rank_pass) then
        return true
      elseif b_rank_pass and (not a_rank_pass) then
        return false
      end
    else -- comparing rolls
      if wincount_sort and (a[10] and b[10] and a[10] ~= b[10]) then
        return a[10] < b[10]
      else
        if a[5] ~= b[5] then -- highest PR or roll wins
          return tonumber(a[5]) > tonumber(b[5])
        else -- highest EP fallback (not a decider)
          return tonumber(a[3]) > tonumber(b[3])
        end
      end
    end
  end
end

local pr_sorter_bids = function(a,b)
  local minep = bepgp.db.profile.minep
  local wincount_sort = bepgp.db.char.wincountepgp
  -- name(1), class(2), ep(3), gp(4), pr or roll(5), priotype(6), rank(7), rankid(8), main(9), wincount(10)
  if a[6] ~= b[6] then -- comparing different prio types
    return tonumber(a[6]) > tonumber(b[6]) -- PR before Rolls
  else -- comparing same prio types
    if a[6] == prioEpgp then -- comparing epgp
      if minep > 0 then -- compare EP cuttoff, then PR
        local a_over = a[3]-minep >= 0
        local b_over = b[3]-minep >= 0
        if a_over and b_over or (not a_over and not b_over) then
          if a[5] ~= b[5] then
            return tonumber(a[5]) > tonumber(b[5])
          else
            return tonumber(a[3]) > tonumber(b[3])
          end
        elseif a_over and (not b_over) then
          return true
        elseif b_over and (not a_over) then
          return false
        end
      else -- just PR compare
        if a[5] ~= b[5] then
          return tonumber(a[5]) > tonumber(b[5])
        else
          return tonumber(a[3]) > tonumber(b[3])
        end
      end
    else -- comparing rolls
      if wincount_sort and (a[10] and b[10] and a[10] ~= b[10]) then
        return a[10] < b[10]
      else
        if a[5] ~= b[5] then -- highest PR or roll wins
          return tonumber(a[5]) > tonumber(b[5])
        else -- highest EP fallback (not a decider)
          return tonumber(a[3]) > tonumber(b[3])
        end
      end
    end
  end
end

local cell_tooltip_show = function(cell, hintKey)
  if not bepgp_bids.qtip then return end
  bepgp_bids.qtip:SetFrameStrata("DIALOG")
  GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
  GameTooltip:SetText(L[hintKey], LIGHTYELLOW_FONT_COLOR.r, LIGHTYELLOW_FONT_COLOR.g, LIGHTYELLOW_FONT_COLOR.b, 0.8, true)
  GameTooltip:Show()
end

local cell_tooltip_hide = function(cell)
  if not bepgp_bids.qtip then return end
  if GameTooltip:IsOwned(cell) then
    GameTooltip:Hide()
  end
  bepgp_bids.qtip:SetFrameStrata("TOOLTIP")
end

function bepgp_bids:OnEnable()
  self:RegisterEvent("CHAT_MSG_WHISPER", "captureBid")
  self:RegisterEvent("CHAT_MSG_SYSTEM", "captureBidRoll")
  self:RegisterEvent("CHAT_MSG_RAID", "captureLootCall")
  self:RegisterEvent("CHAT_MSG_RAID_LEADER", "captureLootCall")
  self:RegisterEvent("CHAT_MSG_RAID_WARNING", "captureLootCall")
  self:SecureHook("SetItemRef")
  --self:RawHook(ItemRefTooltip,"SetHyperlink",true)

  self.qtip = T:Acquire(addonName.."bidsTablet") -- Name, ep, gp, pr, rank, Main
  self.qtip:SetColumnLayout(6, "LEFT", "CENTER", "CENTER", "CENTER", "RIGHT", "RIGHT")
  self.qtip:ClearAllPoints()
  self.qtip:SetClampedToScreen(true)
  self.qtip:SetClampRectInsets(-100,100,50,-50)
  self.qtip:SetPoint("TOP",UIParent,"TOP",0,-50)
  LD:Register(addonName.."DialogMemberBid", bepgp:templateCache("DialogMemberBid"))
  RAID_CLASS_COLORS = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)
end

function bepgp_bids:announceWinner(data)
  local minep_applies = bepgp.db.profile.minep > 0
  local rank_applies = bepgp.db.char.priorank ~= bepgp.VARS.priorank
  local rankos_applies = rank_applies and not bepgp.db.char.priorank_ms
  local name, pr, msos, mode, wincount = data[1], data[2], data[3], data[4], (data[5] or false)
  local wincountOpt = bepgp.db.char.wincountepgp
  local out
  if mode == prioRoll then
    if msos == "ms" then
      -- do something with wincount?
      out = L["Winning Mainspec Roll: %s (%s)"]
      if wincount and wincountOpt then
        out = L["Winning Mainspec Roll: %s (%s)"]..string.format(" +%d ",wincount)
      end
      if rank_applies then
        out = out .. L["+RankPrio"]
      end
      if minep_applies then
        out = out .. string.format(L[",MinEP:%d"],bepgp.db.profile.minep)
      end
    elseif msos == "os" then
      out = L["Winning Offspec Roll: %s (%s)"]
      if rankos_applies then
        out = out .. L["+RankPrio"]
      end
      if minep_applies then
        out = out .. string.format(L[",MinEP:%d"],bepgp.db.profile.minep)
      end
    elseif msos == "x" then
      out = L["Winning Transmog Roll: %s (%s)"]
    end
  else
    if msos == "ms" then
      out = L["Winning Mainspec Bid: %s (%.03f PR)"]
      if rank_applies then
        out = out .. L["+RankPrio"]
      end
      if minep_applies then
        out = out .. string.format(L[",MinEP:%d"],bepgp.db.profile.minep)
      end
    elseif msos == "os" then
      out = L["Winning Offspec Bid: %s (%.03f PR)"]
      if rankos_applies then
        out = out .. L["+RankPrio"]
      end
      if minep_applies then
        out = out .. string.format(L[",MinEP:%d"],bepgp.db.profile.minep)
      end
    end
  end
  if out then
    bepgp:widestAudience(out:format(name,pr))
  end
end

function bepgp_bids:announcedisench(data)
  local out = string.format(L["%s >> Disenchant."],data)
  bepgp:widestAudience(out)
end

function bepgp_bids:shuffleOffbids(off_bids)
  if #off_bids > 1 then
    bepgp:table_shuffle(off_bids)
    bepgp_bids:Refresh()
  end
  bepgp:Print(L["Offspec Bids Shuffled"])
end

function bepgp_bids:updateBids()
  if bepgp._SUSPEND then return end
  -- {name,class,ep,gp,ep/gp,rank,rankid[,main]}
  if bepgp.db.char.priorank ~= bepgp.VARS.priorank then
    table.sort(self.bids_main, pr_sorter_bids_rank)
    if not bepgp.db.char.priorank_ms then
      table.sort(self.bids_off, pr_sorter_bids_rank)
    else
      table.sort(self.bids_off, pr_sorter_bids)
    end
    table.sort(self.bids_xmog, pr_sorter_bids)
  else
    table.sort(self.bids_main, pr_sorter_bids)
    table.sort(self.bids_off, pr_sorter_bids)
    table.sort(self.bids_xmog, pr_sorter_bids)
  end
end

function bepgp_bids:Refresh()
  local frame = self.qtip
  if not frame then return end
  if bepgp._SUSPEND then return end
  local discount = bepgp.db.profile.discount
  frame:StopMovingOrSizing() -- free the mouse if we're mid-drag
  frame:Clear()
  frame:SetMovable(true)
  local minep = bepgp.db.profile.minep
  local prvetoOpt = bepgp.db.char.prveto
  local wincountOpt = bepgp.db.char.wincountepgp
  local minilvlOpt = bepgp.db.char.minilvl and bepgp.db.char.minilvl > 0
  local xmogOpt = bepgp.db.char.xmogbid
  local line
  line = frame:AddHeader()
  frame:SetCell(line,1,L["BastionLoot bids"],nil,"CENTER",5)
  --frame:SetCell(line,5,C:Red("[x]"),nil,"RIGHT")
  frame:SetCell(line,6,"|TInterface\\Buttons\\UI-Panel-MinimizeButton-Up:16:16:2:-2:32:32:8:24:8:24|t",nil,"RIGHT")
  frame:SetCellScript(line,6,"OnMouseUp", function() frame:Hide() end)
  frame:SetCellScript(line,1,"OnMouseDown", function() frame:StartMoving() end)
  frame:SetCellScript(line,1,"OnMouseUp", function() frame:StopMovingOrSizing() end)

  if self.bid_item.itemlink then
    line = frame:AddHeader()
    --SetCell spec : lineNum, colNum, value, font, justification, colSpan, provider
    frame:SetCell(line,1,C:Orange(L["Item"]),nil,"LEFT",2)
    frame:SetCell(line,3,C:Orange(L["Mainspec GP"]),nil,"RIGHT")
    frame:SetCell(line,4,C:Orange(L["Offspec GP"]),nil,"RIGHT")
    frame:SetCell(line,5,"",nil,"RIGHT")
    frame:SetCell(line,6,"",nil,"RIGHT")
    line = frame:AddSeparator(2)
    line = frame:AddLine()
    frame:SetCell(line,1,self.bid_item.itemlink,nil,"LEFT",2)
    frame:SetCell(line,3,C:Colorize(color_msgp,self.bid_item.price),nil,"RIGHT")
    frame:SetCell(line,4,C:Colorize(color_osgp,self.bid_item.off_price),nil,"RIGHT")
    frame:SetCell(line,5,"|TInterface\\Buttons\\UI-GroupLoot-DE-Up:18:18:-1:1:32:32:2:30:2:30|t",nil,"RIGHT")
    frame:SetCellScript(line,5,"OnMouseUp", bepgp_bids.announcedisench, bepgp_bids.bid_item.itemlink)
    frame:SetCellScript(line,5,"OnEnter", cell_tooltip_show, "DISENCHANT_TIP_HINT")
    frame:SetCellScript(line,5,"OnLeave", cell_tooltip_hide)
    frame:SetCell(line,6,"",nil,"RIGHT")

    if #(self.bids_main) > 0 then
      line = frame:AddLine(" ")
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Gold(L["Mainspec Bids"]),nil,"LEFT",6)
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Orange(L["Name"]),nil,"LEFT")
      frame:SetCell(line,2,C:Orange(L["ep"]),nil,"CENTER")
      frame:SetCell(line,3,C:Orange(L["gp"]),nil,"CENTER")
      if minilvlOpt then
        frame:SetCell(line,4,C:Orange(L["pr"].."/"..ROLL),nil,"CENTER")
      else
        frame:SetCell(line,4,C:Orange(L["pr"]),nil,"CENTER")
      end
      frame:SetCell(line,5,C:Orange(_G.RANK),nil,"RIGHT")
      frame:SetCell(line,6,C:Orange(L["Main"]),nil,"RIGHT")
      line = frame:AddSeparator(1)
      for i,data in ipairs(self.bids_main) do
        local name, class, ep, gp, pr, prtype, rank, rankidx, main, wincount = unpack(data,1,10)
        local eclass,_,hexclass = bepgp:getClassData(class)
        local r,g,b = RAID_CLASS_COLORS[eclass].r, RAID_CLASS_COLORS[eclass].g, RAID_CLASS_COLORS[eclass].b
        --local name_c = C:Colorize(hexclass,name)
        local text2, text4
        if minep > 0 and ep < minep then
          text2 = C:Red(string.format("%.4g", ep))
          text4 = C:Red(string.format("%.4g", pr))
        else
          text2 = string.format("%.4g", ep)
          text4 = string.format("%.4g", pr)
        end
        local text3, text6 = string.format("%.4g", gp), (main or "")
        line = frame:AddLine()
        frame:SetCell(line,1,name,nil,"LEFT")
        frame:SetCellTextColor(line,1,r,g,b)
        frame:SetCell(line,2,text2,nil,"CENTER")
        frame:SetCell(line,3,text3,nil,"CENTER")
        if prtype == prioRoll then
          if wincountOpt and wincount then
            text4 = string.format("%s (+%d)",text4,wincount)
          end
        end
        frame:SetCell(line,4,text4,nil,"CENTER")
        if prtype == prioEpgp then
          frame:SetCellColor(line,4,colorPRcell.r, colorPRcell.g, colorPRcell.b)
        end
        frame:SetCell(line,5,rank,nil,"RIGHT")
        frame:SetCell(line,6,text6,nil,"RIGHT")
        frame:SetLineScript(line, "OnMouseUp", bepgp_bids.announceWinner, {name, pr, "ms", prtype, (wincountOpt and wincount)})
      end
    end
    if #(self.bids_off) > 0 then
      line = frame:AddLine(" ")
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Silver(L["Offspec Bids"]),nil,"LEFT",5)
      if discount == 0 then
        frame:SetCell(line,6,"|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:18:18:-1:1:32:32:2:30:2:30|t",nil,"RIGHT")
        frame:SetCellScript(line,6,"OnMouseUp", bepgp_bids.shuffleOffbids, bepgp_bids.bids_off)
        frame:SetCellScript(line,6,"OnEnter", cell_tooltip_show, "OSBID_SHUFFLE_TIP_HINT")
        frame:SetCellScript(line,6,"OnLeave", cell_tooltip_hide)
      end
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Orange(L["Name"]),nil,"LEFT")
      frame:SetCell(line,2,C:Orange(L["ep"]),nil,"CENTER")
      frame:SetCell(line,3,C:Orange(L["gp"]),nil,"CENTER")
      if minilvlOpt then
        frame:SetCell(line,4,C:Orange(L["pr"].."/"..ROLL),nil,"CENTER")
      else
        frame:SetCell(line,4,C:Orange(L["pr"]),nil,"CENTER")
      end
      frame:SetCell(line,5,C:Orange(_G.RANK),nil,"RIGHT")
      frame:SetCell(line,6,C:Orange(L["Main"]),nil,"RIGHT")
      line = frame:AddSeparator(1)
      for i,data in ipairs(self.bids_off) do
        local name, class, ep, gp, pr, prtype, rank, rankidx, main, wincount = unpack(data,1,10)
        local eclass,_,hexclass = bepgp:getClassData(class)
        local r,g,b = RAID_CLASS_COLORS[eclass].r, RAID_CLASS_COLORS[eclass].g, RAID_CLASS_COLORS[eclass].b
        --local name_c = C:Colorize(hexclass,name)
        local text2, text4
        if minep > 0 and ep < minep then
          text2 = C:Red(string.format("%.4g", ep))
          text4 = C:Red(string.format("%.4g", pr))
        else
          text2 = string.format("%.4g", ep)
          text4 = string.format("%.4g", pr)
        end
        local text3, text6 = string.format("%.4g", gp), (main or "")
        line = frame:AddLine()
        frame:SetCell(line,1,name,nil,"LEFT")
        frame:SetCellTextColor(line,1,r,g,b)
        frame:SetCell(line,2,text2,nil,"CENTER")
        frame:SetCell(line,3,text3,nil,"CENTER")
        frame:SetCell(line,4,text4,nil,"CENTER")
        frame:SetCell(line,5,rank,nil,"RIGHT")
        frame:SetCell(line,6,text6,nil,"RIGHT")
        frame:SetLineScript(line,"OnMouseUp", bepgp_bids.announceWinner, {name, pr, "os", prtype})
      end
    end
    if #(self.bids_xmog) > 0 then
      line = frame:AddLine(" ")
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Copper(L["Transmog Rolls"]),nil,"LEFT",5)
      line = frame:AddHeader()
      frame:SetCell(line,1,C:Orange(L["Name"]),nil,"LEFT")
      frame:SetCell(line,2,C:Orange(L["ep"]),nil,"CENTER")
      frame:SetCell(line,3,C:Orange(L["gp"]),nil,"CENTER")
      frame:SetCell(line,4,C:Orange(ROLL),nil,"CENTER")
      frame:SetCell(line,5,C:Orange(_G.RANK),nil,"RIGHT")
      frame:SetCell(line,6,C:Orange(L["Main"]),nil,"RIGHT")
      line = frame:AddSeparator(1)
      for i,data in ipairs(self.bids_xmog) do
        local name, class, ep, gp, pr, prtype, rank, rankidx, main, wincount = unpack(data,1,10)
        local eclass,_,hexclass = bepgp:getClassData(class)
        local r,g,b = RAID_CLASS_COLORS[eclass].r, RAID_CLASS_COLORS[eclass].g, RAID_CLASS_COLORS[eclass].b
        --local name_c = C:Colorize(hexclass,name)
        local text2, text4
        if minep > 0 and ep < minep then
          text2 = C:Red(string.format("%.4g", ep))
          text4 = C:Red(string.format("%.4g", pr))
        else
          text2 = string.format("%.4g", ep)
          text4 = string.format("%.4g", pr)
        end
        local text3, text6 = string.format("%.4g", gp), (main or "")
        line = frame:AddLine()
        frame:SetCell(line,1,name,nil,"LEFT")
        frame:SetCellTextColor(line,1,r,g,b)
        frame:SetCell(line,2,text2,nil,"CENTER")
        frame:SetCell(line,3,text3,nil,"CENTER")
        frame:SetCell(line,4,text4,nil,"CENTER")
        frame:SetCell(line,5,rank,nil,"RIGHT")
        frame:SetCell(line,6,text6,nil,"RIGHT")
        frame:SetLineScript(line,"OnMouseUp", bepgp_bids.announceWinner, {name, pr, "x", prtype})
      end
    end
  end
  frame:UpdateScrolling()
end

function bepgp_bids:Toggle(anchor)
  if not T:IsAcquired(addonName.."bidsTablet") then
    self.qtip = T:Acquire(addonName.."bidsTablet") -- Name, ep, gp, pr, rank, Main
    self.qtip:SetColumnLayout(6, "LEFT", "CENTER", "CENTER", "CENTER", "RIGHT", "RIGHT")
    return
  end
  if self.qtip:IsShown() then
    self.qtip:Hide()
  else
    if anchor then
      self.qtip:SmartAnchorTo(anchor)
    else
      self.qtip:ClearAllPoints()
      self.qtip:SetClampedToScreen(true)
      self.qtip:SetClampRectInsets(-100,100,50,-50)
      self.qtip:SetPoint("TOP",UIParent,"TOP",0,-50)
    end
    self:Refresh()
    self.qtip:Show()
  end
end

function bepgp_bids:SetItemRef(link, text, button, chatFrame)
  if bepgp.db.char.mode ~= "epgp" then return end
  local linktype, addon, bid, masterlooter = strsplit(":",link)
  if linktype == "addon" and addon == addonName then
    if bid == "1" or bid == "5" then
      bid = "+"
    elseif bid == "2" then
      bid = "-"
    elseif bid == "3" then -- ms roll
      bid = "100"
    elseif bid == "4" then -- os roll
      bid = "99"
    elseif bid == "6" then -- xmog roll
      bid = "69"
    else
      bid = nil
    end
    if not (bepgp:inRaid(masterlooter)) then
      masterlooter = nil
    end
    if (bid and masterlooter) then
      if tonumber(bid) then
        RandomRoll("1", bid)
      else
        SendChatMessage(bid,"WHISPER",nil,masterlooter)
      end
      if LD:ActiveDialog(addonName.."DialogMemberBid") then
        LD:Dismiss(addonName.."DialogMemberBid")
      end
    end
    return false
  end
end

local lootCall = {
  ["whisper"] = {
  "^(w)[%s%p%c]+.+",".+[%s%p%c]+(w)$",".+[%s%p%c]+(w)[%s%p%c]+.*",".*[%s%p%c]+(w)[%s%p%c]+.+",
  "^(whisper)[%s%p%c]+.+",".+[%s%p%c]+(whisper)$",".+[%s%p%c]+(whisper)[%s%p%c]+.*",".*[%s%p%c]+(whisper)[%s%p%c]+.+",
  ".+[%s%p%c]+(bid)[%s%p%c]*.*",".*[%s%p%c]*(bid)[%s%p%c]+.+"
  },
  ["ms"] = {
  ".+(%+).*",".*(%+).+",
  "^(ms)[%s%p%c]+.+",".+[%s%p%c]+(ms)$",".+[%s%p%c]+(ms)[%s%p%c]+.*",".*[%s%p%c]+(ms)[%s%p%c]+.+",
  ".+(mainspec).*",".*(mainspec).+"
  },
  ["os"] = {
  ".+(%-).*",".*(%-).+",
  "^(os)[%s%p%c]+.+",".+[%s%p%c]+(os)$",".+[%s%p%c]+(os)[%s%p%c]+.*",".*[%s%p%c]+(os)[%s%p%c]+.+",
  ".+(offspec).*",".*(offspec).+"
  },
  ["roll"] = { -- specifically ordered from narrow to broad
    "^roll (69)[%s%p%c]+.+",
    ".+[%s%p%c]+/roll (69)$",".*[%s%p%c]+/roll (69)[%s%p%c]+.*",
    ".+[%s%p%c]+roll (69)$",".*[%s%p%c]+roll (69)[%s%p%c]+.*",
    "^roll (99)[%s%p%c]+.+",
    ".+[%s%p%c]+/roll (99)$",".*[%s%p%c]+/roll (99)[%s%p%c]+.*",
    ".+[%s%p%c]+roll (99)$",".*[%s%p%c]+roll (99)[%s%p%c]+.*",
    "^(roll)[%s%p%c]+.+",
    ".+[%s%p%c]+(/roll)$",".*[%s%p%c]+(/roll)[%s%p%c]+.*",
    ".+[%s%p%c]+(roll)$",".*[%s%p%c]+(roll)[%s%p%c]+.*",
  },
}
function bepgp_bids:captureLootCall(event, text, sender)
  if not (string.find(text, "|Hitem:", 1, true)) then return end
  if bepgp.db.char.mode ~= "epgp" then return end
  local linkstriptext, count = string.gsub(text,"|c%x+|H[eimt:%-%d]+|h%[.-%]|h|r"," ; ")
  if count > 1 then return end
  local prvetoOpt = bepgp.db.char.prveto
  local lowtext = string.lower(linkstriptext)
  local whisperkw_found, mskw_found, oskw_found, link_found, rollkw_found, keyword
  sender = bepgp:Ambiguate(sender)
  local _, itemLink, itemColor, itemString, itemName, itemID
  for _,f in ipairs(lootCall.roll) do
    rollkw_found,_,keyword = string.find(lowtext,f)
    if (rollkw_found) then break end
  end
  for _,f in ipairs(lootCall.whisper) do
    whisperkw_found = string.find(lowtext,f)
    if (whisperkw_found) then break end
  end
  for _,f in ipairs(lootCall.ms) do
    mskw_found = string.find(lowtext,f)
    if (mskw_found) then break end
  end
  for _,f in ipairs(lootCall.os) do
    oskw_found = string.find(lowtext,f)
    if (oskw_found) then break end
  end
  local prveto = (mskw_found or whisperkw_found) and rollkw_found
  local xmog = rollkw_found and keyword == "69"
  if (whisperkw_found) or (mskw_found) or (oskw_found) then
    _,_,itemLink = string.find(text,"(|c%x+|H[eimt:%-%d]+|h%[.-%]|h|r)")
    if (itemLink) and (itemLink ~= "") then
      itemColor, itemString, itemName, itemID = bepgp:getItemData(itemLink)
    end
    if (itemName) then
      local price,tier,price2,_,_,_,_,_,item_level = bepgp:GetPrice(itemString, bepgp.db.profile.progress)
      if (price and price > 0) then
        if (bepgp:raidLeader() or bepgp:lootMaster()) and (sender == bepgp._playerName) then
          self:clearBids(true)
          bepgp_bids.bid_item.itemstring = itemString
          bepgp_bids.bid_item.itemlink = itemLink
          bepgp_bids.bid_item.name = string.format("%s%s|r",itemColor,itemName)
          bepgp_bids.bid_item.price = price
          bepgp_bids.bid_item.off_price = math.floor(price*bepgp.db.profile.discount)
          self._bidTimer = self:ScheduleTimer("clearBids",300)
          if bepgp:itemLevelOptionPass(item_level) then
            running_bid = "bid"
          else
            if prvetoOpt and prveto then
              running_bid = "roll:bid"
            else
              running_bid = "roll"
            end
          end
          bepgp:debugPrint(L["Capturing Bids for 5min."])
          self.qtip:Show()
        end
        self:bidPrint(itemLink,sender,mskw_found,oskw_found,whisperkw_found,rollkw_found,xmog)
        if bepgp.db.char.favalert then
          if bepgp.db.char.favorites[itemID] then
            bepgp:Alert(string.format(L["BastionLoot Favorite: %s"],itemLink))
          end
        end
      end
    end
  end
end

local lootBid = {
  ["ms"] = {"(%+)",".+(%+).*",".*(%+).+",".*(%+).*",L["(ms)"],L["(need)"]},
  ["os"] = {"(%-)",".+(%-).*",".*(%-).+",".*(%-).*",L["(os)"],L["(greed)"]}
}
function bepgp_bids:captureBid(event, text, sender)
  if bepgp.db.char.mode ~= "epgp" then return end
  if not (running_bid and running_bid:find("bid")) then return end
  if not (bepgp:raidLeader() or bepgp:lootMaster()) then return end
  if not bepgp_bids.bid_item.itemstring then return end
  sender = bepgp:Ambiguate(sender)
  local mskw_found,oskw_found,is_ally
  local lowtext = string.lower(text)
  for _,f in ipairs(lootBid.ms) do
    mskw_found = string.find(lowtext,f)
    if (mskw_found) then break end
  end
  for _,f in ipairs(lootBid.os) do
    oskw_found = string.find(lowtext,f)
    if (oskw_found) then break end
  end
  if (mskw_found) or (oskw_found) then
    if bepgp:inRaid(sender) then
      if bids_blacklist[sender] == nil then
        local name, class, rank, officernote, rankIdx, roster_index = bepgp:verifyGuildMember(sender)
        if not name and bepgp.db.profile.allypool then
          local allies = bepgp.db.profile.allies
          if allies[sender] then
            name = sender
            class = allies[sender].class
            rank = L["Ally"]
            rankIdx = 100
            is_ally = true
          end
        end
        if name then
          local ep = (bepgp:get_ep(name,officernote) or 0)
          local gp = (bepgp:get_gp(name,officernote) or bepgp.VARS.basegp)
          local main_name
          if (bepgp.db.profile.altspool) and not is_ally then
            local main, main_class, main_rank, main_offnote = bepgp:parseAlt(name,officernote)
            if (main) then
              ep = (bepgp:get_ep(main,main_offnote) or 0)
              gp = (bepgp:get_gp(main,main_offnote) or bepgp.VARS.basegp)
              main_name = main
            end
          end
          if (mskw_found) then
            bids_blacklist[sender] = true
            if (bepgp.db.profile.altspool) and (main_name) then
              table.insert(bepgp_bids.bids_main,{name,class,ep,gp,ep/gp,prioEpgp,rank,rankIdx,main_name})
            else
              table.insert(bepgp_bids.bids_main,{name,class,ep,gp,ep/gp,prioEpgp,rank,rankIdx})
            end
          elseif (oskw_found) then
            bids_blacklist[sender] = true
            if (bepgp.db.profile.altspool) and (main_name) then
              table.insert(bepgp_bids.bids_off,{name,class,ep,gp,ep/gp,prioEpgp,rank,rankIdx,main_name})
            else
              table.insert(bepgp_bids.bids_off,{name,class,ep,gp,ep/gp,prioEpgp,rank,rankIdx})
            end
          end
          self:updateBids()
          self:Refresh()
        end
      end
    end
  end
end

function bepgp_bids:captureBidRoll(event, text)
  if bepgp.db.char.mode ~= "epgp" then return end
  if not (running_bid and running_bid:find("roll")) then return end -- DEBUG
  if not (bepgp:raidLeader() or bepgp:lootMaster()) then return end
  if not bepgp_bids.bid_item.itemstring then return end
  local wincountOpt = bepgp.db.char.wincountepgp
  local xmogOpt = bepgp.db.char.xmogbid
  local who, roll, low, high = DF.Deformat(text, RANDOM_ROLL_RESULT)
  roll, low, high = tonumber(roll),tonumber(low),tonumber(high)
  local msroll, osroll,is_ally, xroll
  local inraid
  if who then
    who = bepgp:Ambiguate(who)
    inraid = bepgp:inRaid(who)
    if inraid then -- DEBUG
      msroll = (low == 1 and high == 100) and roll
      osroll = (low == 1 and high < 100 and high ~= 69) and roll
      xroll = xmogOpt and (low == 1 and high == 69) and roll
    end -- DEBUG
    if (msroll) or (osroll) or (xroll) then
      if bids_blacklist[who] == nil then
        local name, class, rank, officernote, rankIdx, roster_index = bepgp:verifyGuildMember(who)
        if not name and bepgp.db.profile.allypool then
          local allies = bepgp.db.profile.allies
          if allies[who] then
            name = who
            class = allies[who].class
            rank = L["Ally"]
            rankIdx = 100
            is_ally = true
          end
        end
        if name then
          local ep = (bepgp:get_ep(name,officernote) or 0)
          local gp = (bepgp:get_gp(name,officernote) or bepgp.VARS.basegp)
          local main_name
          if (bepgp.db.profile.altspool) and not is_ally then
            local main, main_class, main_rank, main_offnote = bepgp:parseAlt(name,officernote)
            if (main) then
              ep = (bepgp:get_ep(main,main_offnote) or 0)
              gp = (bepgp:get_gp(main,main_offnote) or bepgp.VARS.basegp)
              main_name = main
            end
          end
          if msroll then
            bids_blacklist[who] = true
            bepgp_loot = bepgp_loot or bepgp:GetModule(addonName.."_loot",true)
            local wincount = bepgp_loot and bepgp_loot:getWincount(who) or 0
            if (bepgp.db.profile.altspool) and (main_name) then
              table.insert(bepgp_bids.bids_main,{name,class,ep,gp,msroll,prioRoll,rank,rankIdx,main_name,wincount})
            else
              table.insert(bepgp_bids.bids_main,{name,class,ep,gp,msroll,prioRoll,rank,rankIdx,nil,wincount})
            end
          elseif osroll then
            bids_blacklist[who] = true
            if (bepgp.db.profile.altspool) and (main_name) then
              table.insert(bepgp_bids.bids_off,{name,class,ep,gp,osroll,prioRoll,rank,rankIdx,main_name})
            else
              table.insert(bepgp_bids.bids_off,{name,class,ep,gp,osroll,prioRoll,rank,rankIdx})
            end
          elseif xroll then
            bids_blacklist[who] = true
            if (bepgp.db.profile.altspool) and (main_name) then
              table.insert(bepgp_bids.bids_xmog,{name,class,ep,gp,xroll,prioRoll,rank,rankIdx,main_name})
            else
              table.insert(bepgp_bids.bids_xmog,{name,class,ep,gp,xroll,prioRoll,rank,rankIdx})
            end
          end
          self:updateBids()
          self:Refresh()
        end
      end
    end
  end
end

function bepgp_bids:clearBids(reset)
  if reset~=nil then
    bepgp:debugPrint(L["Clearing old Bids"])
  else
    self.qtip:Hide()
  end
  table.wipe(bepgp_bids.bid_item) -- = {}
  table.wipe(bepgp_bids.bids_main) -- = {}
  table.wipe(bepgp_bids.bids_off) -- = {}
  table.wipe(bepgp_bids.bids_xmog)
  table.wipe(bids_blacklist) -- = {}
  if self._bidTimer then
    self:CancelTimer(self._bidTimer)
    self._bidTimer = nil
  end
  running_bid = false
  self:updateBids()
  self:Refresh()
end

function bepgp_bids:bidPrint(link,masterlooter,need,greed,bid,roll,xmog)
  local mslink = string.gsub(bidlink["ms"],"$ML",masterlooter)
  local oslink = string.gsub(bidlink["os"],"$ML",masterlooter)
  local msrollink = string.gsub(bidlink["msroll"],"$ML",masterlooter)
  local osrollink = string.gsub(bidlink["osroll"],"$ML",masterlooter)
  local prvetolink = string.gsub(bidlink["prveto"],"$ML",masterlooter)
  local xmoglink = string.gsub(bidlink["xmog"],"$ML",masterlooter)
  local msg = string.format(L["Click $MS or $OS for %s"],link)
  local prveto = (need or bid) and roll
  if (prveto) or (xmog) then
    if (prveto) and (xmog) then
      msg = string.format(L["Click $MS, $OS $X or $PR for %s"],link)
      msg = string.gsub(msg,"$X",xmoglink)
      msg = string.gsub(msg,"$PR",prvetolink)
    elseif (prveto) then
      msg = string.format(L["Click $MS, $OS or $PR for %s"],link)
      msg = string.gsub(msg,"$PR",prvetolink)
    elseif (xmog) then
      msg = string.format(L["Click $MS $OS or $X for %s"],link)
      msg = string.gsub(msg,"$X",xmoglink)
    end
    msg = string.gsub(msg,"$MS",msrollink)
    if greed then
      msg = string.gsub(msg,"$OS",osrollink)
    else
      msg = string.gsub(msg,L[", $OS"],"")
    end
  else
    if (roll) then
      msg = string.gsub(msg,"$MS",msrollink)
      msg = string.gsub(msg,"$OS",osrollink)
    else
      if (need and greed) or bid then
        msg = string.gsub(msg,"$MS",mslink)
        msg = string.gsub(msg,"$OS",oslink)
      elseif (need and not greed) then
        msg = string.gsub(msg,"$MS",mslink)
        msg = string.gsub(msg,L["or $OS "],"")
      elseif (greed and not need) then
        msg = string.gsub(msg,"$OS",oslink)
        msg = string.gsub(msg,L["$MS or "],"")
      end
    end
  end
  local _, count = string.gsub(msg,"%$","%$")
  if (count > 0) then return end
  local chatframe
  if (SELECTED_CHAT_FRAME) then
    chatframe = SELECTED_CHAT_FRAME
  else
    if not DEFAULT_CHAT_FRAME:IsVisible() then
      FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)
    end
    chatframe = DEFAULT_CHAT_FRAME
  end
  if not bepgp._SUSPEND then
    if (chatframe) then
      chatframe:AddMessage(" ")
      chatframe:AddMessage(string.format(out,msg),NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b)
    end
    if bepgp.db.char.bidpopup then
      LD:Spawn(addonName.."DialogMemberBid", {link,masterlooter,roll,prveto,xmog})
    end
  end
  self:updateBids()
  self:Refresh()
end
-- /run LibStub("LibDialog-1.0_Roadblock"):Spawn("BastionLootDialogMemberBid", {"\124cff0070dd\124Hitem:19915:0:0:0:0:0:0:0:0\124h[Zulian Defender]\124h\124r","Gotwood",true,true})
