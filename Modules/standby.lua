local addonName, bepgp = ...
local moduleName = addonName.."_standby"
local bepgp_standby = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local C = LibStub("LibCrayon-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LD = LibStub("LibDialog-1.0")
local DF = LibStub("LibDeformat-3.0")
local T = LibStub("LibQTip-1.0")

bepgp_standby.roster = {}
bepgp_standby.blacklist = {}
local standbycall = string.format(L["{BEPGP}Type \"+\" if on main, or \"+<YourMainName>\" (without quotes) if on alt within %dsec."],bepgp.VARS.timeout)
local standbyanswer = "^(%+)(%a*)$"

local pr_sorter_standby = function(a,b)
  if (a[2] ~= b[2]) then
    return a[2] > b[2]
  else
    return a[1] > b[1]
  end
end

function bepgp_standby:OnEnable()
  self.qtip = T:Acquire(addonName.."standbyTablet") -- name, class, rank, alt
  self.qtip:SetColumnLayout(3, "LEFT", "CENTER", "RIGHT")
  self.qtip:ClearAllPoints()
  self.qtip:SetClampedToScreen(true)
  self.qtip:SetClampRectInsets(-100,100,50,-50)
  self.qtip:SetPoint("TOP",UIParent,"TOP",0,-50)
  if IsInGuild() then
    LD:Register(addonName.."DialogStandbyCheck", bepgp:templateCache("DialogStandbyCheck"))
    self._channelTimer = self:ScheduleTimer("injectOptions",10)
  end
end

function bepgp_standby:injectOptions()
  if bepgp._guildName then
    local sanitized_guild = bepgp._guildName:gsub("[%A]+","")
    self._standbyChannel = string.format("%s%s",sanitized_guild,L["Standby"])
    bepgp._options.args.general.args.main.args["standby"] = {
      type = "toggle",
      name = L["Enable Standby"],
      desc = L["Participate in Standby Raiders List.\n|cffff0000Requires Main Character Name.|r"],
      order = 50,
      get = function()
        return not not bepgp.db.char.standby
      end,
      set = function(info, val)
        bepgp.db.char.standby = not bepgp.db.char.standby
        bepgp_standby:standbyToggle(bepgp.db.char.standby)
      end,
      disabled = function() return not bepgp.db.profile.main end
    }
    if not bepgp._dda_options then bepgp._dda_options = bepgp:ddoptions() end
    bepgp._dda_options.args["ep_standby"] = {
      type = "execute",
      name = L["+EPs to Standby"],
      desc = L["Award EPs to all active Standby."],
      order = 20,
      func = function(info)
        LD:Spawn(addonName.."DialogGroupPoints", {"ep", C:Green(L["Effort Points"]), L["Standby"]})
      end,
    }
    bepgp._dda_options.args["afkcheck_standby"] = {
      type = "execute",
      name = L["AFK Check Standby"],
      desc = L["AFK Check Standby List"],
      order = 30,
      func = function(info) bepgp_standby:sendStandbyCheck() end,
    }
    self:standbyToggle(not not bepgp.db.char.standby)
  else
    self._channelTimer = self:ScheduleTimer("injectOptions",10)
  end
end

function bepgp_standby:standbyToggle(flag)
  local id = GetChannelName(GetChannelName(self._standbyChannel))
  local joined = id > 0 and true or false
  if flag then -- join
    if not joined then -- join
      self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "channelChange")
      JoinTemporaryChannel(self._standbyChannel,nil,DEFAULT_CHAT_FRAME:GetID())
    else
      self._standbyID = id
      self:RegisterEvent("CHAT_MSG_CHANNEL","captureStandbyChat")
      bepgp.db.char.standby = flag
    end
  else -- leave
    if joined then -- leave
      local id = ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME,self._standbyChannel)
      LeaveChannelByName(self._standbyChannel)
    end
    self:UnregisterEvent("CHAT_MSG_CHANNEL")
    bepgp.db.char.standby = flag
    self._standbyID = nil
  end
  return flag
end

function bepgp_standby:channelChange(event, text, playerName, _, _, _, _, _, channelIndex, channelBaseName)
  if channelIndex > 0 then
    if (text == "YOU_JOINED" or text == "YOU_CHANGED") and channelBaseName == self._standbyChannel then
      self._standbyID = channelIndex
      --ChatFrame_AddChannel(DEFAULT_CHAT_FRAME,self._standbyChannel)
      ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME,self._standbyChannel)
      if self._standbyID and self._standbyID > 0 then
        self:RegisterEvent("CHAT_MSG_CHANNEL","captureStandbyChat")
        bepgp.db.char.standby = true
      end
    end
  end
end
-- /run BastionLoot:GetModule("BastionEPGP_standby"):sendStandbyCheck()
function bepgp_standby:sendStandbyCheck()
  if not (self._standbyID and self._standbyID > 0) then return end
  if bepgp:GroupStatus() == "RAID" and bepgp:admin() then
    SendChatMessage(standbycall, "CHANNEL", nil, self._standbyID)
    table.wipe(self.roster)
    table.wipe(self.blacklist)
    self._runningcheck = true
    self.qtip:Show()
    self._checkTimer = self:ScheduleTimer("stopStandbyCheck", bepgp.VARS.timeout)
    bepgp:Print(L["Started Standby AFKCheck for 1min."])
  end
end

function bepgp_standby:captureStandbyChat(event, text, sender, _, _, _, _, _, channelIndex)
  if channelIndex ~= self._standbyID then return end
  local sender = bepgp:Ambiguate(sender)
  local sender_name, sender_class, sender_rank, sender_officernote = bepgp:verifyGuildMember(sender,true)
  if not sender_name then return end
  -- call incoming, should we respond?
  local query = string.find(text,L["^{BEPGP}Type"])
  if query and not self._runningcheck then
    if not (bepgp:inRaid(sender_name)) then
      LD:Spawn(addonName.."DialogStandbyCheck", bepgp.VARS.timeout)
    end
    return
  end
  -- response incoming
  local standby, standby_class, standby_rank, standby_alt = nil,nil,nil,nil
  local r,_,rdy,main = string.find(text,standbyanswer)
  if (r) and (self._runningcheck) then
    if (rdy) then
      if (bepgp:inRaid(sender_name)) then return end -- sender is in our raid, whatever name they sent can't be standby
      if main and main ~= "" then -- we got a `+Mainname` message
        main = bepgp:Capitalize(main)
        if (bepgp:inRaid(main)) then return end -- the character they're trying to add to standby is in our raid
        local main_name, main_class, main_rank, main_officernote = bepgp:verifyGuildMember(main,true)
        if main_name and sender_name ~= main_name then
          local checked_main = bepgp:parseAlt(sender_name, sender_officernote)
          if checked_main == main_name then
            standby, standby_class, standby_rank, standby_alt = main_name, main_class, main_rank, sender_name
          else
            bepgp:Print(string.format(L["|cffffff00%s|r is trying to add %s to Standby but {%s} is missing from Alt's Officer Note."],sender_name,main_name,main_name))
          end
        end
      else -- we got a `+` message
        local main_name, main_class, main_rank, main_officernote = bepgp:verifyGuildMember(sender_name,true)
        if main_name then
          local checked_main = bepgp:parseAlt(main_name, main_officernote)
          if checked_main then
            bepgp:Print(string.format(L["|cffffff00%s|r is trying to add themselves to Standby as a Main but are marked as an Alt of %s in Officer Note."],main_name,checked_main))
          else
            standby, standby_class, standby_rank = main_name, main_class, main_rank
          end
        end
      end
      if standby and standby_class and standby_rank then
        if standby_alt then
          if not bepgp_standby.blacklist[standby_alt] then
            bepgp_standby.blacklist[standby_alt] = true
            table.insert(bepgp_standby.roster,{standby,standby_class,standby_rank,standby_alt})
          else
            bepgp:Print(string.format(L["|cffff0000%s|r trying to add %s to Standby, but has already added a member. Discarding!"],standby_alt,standby))
          end
        else
          if not bepgp_standby.blacklist[standby] then
            bepgp_standby.blacklist[standby] = true
            table.insert(bepgp_standby.roster,{standby,standby_class,standby_rank})
          else
            bepgp:Print(string.format(L["|cffff0000%s|r has already been added to Standby. Discarding!"],standby))
          end
        end
      end
    end
    self:updateStandby()
    self:Refresh()
    return
  end
end

function bepgp_standby:sendCheckResponse()
  if self._standbyID and self._standbyID > 0 then
    local main = bepgp.db.profile.main
    if main then
      if bepgp._playerName == main then
        SendChatMessage("+", "CHANNEL", nil, self._standbyID)
      else
        SendChatMessage(string.format("+%s",main),"CHANNEL", nil, self._standbyID)
      end
    end
  end
end

function bepgp_standby:stopStandbyCheck()
  self._runningcheck = false
  if self._checkTimer then
    self:CancelTimer(self._checkTimer)
  end
  bepgp:Print(L["Standby AFKCheck finished."])
end

function bepgp_standby:updateStandby()
  --{name,class,rank,alt}
  table.sort(self.roster, pr_sorter_standby)
end

function bepgp_standby:sendTell(name)
  ChatFrame_SendTell(name, DEFAULT_CHAT_FRAME)
end

function bepgp_standby:Refresh()
  local frame = self.qtip
  if not frame then return end
  frame:StopMovingOrSizing() -- free the mouse if we're mid-drag
  frame:Clear()
  frame:SetMovable(true)
  local line
  line = frame:AddHeader()
  frame:SetCell(line,1,L["BastionLoot standby"],nil,"CENTER",2)
  --frame:SetCell(line,3,C:Red("[x]"),nil,"RIGHT")
  frame:SetCell(line,3,"|TInterface\\Buttons\\UI-Panel-MinimizeButton-Up:16:16:2:-2:32:32:8:24:8:24|t",nil,"RIGHT")
  frame:SetCellScript(line,3,"OnMouseUp", function() frame:Hide() end)
  frame:SetCellScript(line,1,"OnMouseDown", function() frame:StartMoving() end)
  frame:SetCellScript(line,1,"OnMouseUp", function() frame:StopMovingOrSizing() end)

  if #(self.roster) > 0 then
    line = frame:AddLine(" ")
    line = frame:AddHeader()
    frame:SetCell(line,1,C:Orange(L["Name"]),nil,"LEFT")
    frame:SetCell(line,2,C:Orange(L["Rank"]),nil,"CENTER")
    frame:SetCell(line,3,C:Orange(L["OnAlt"]),nil,"RIGHT")
    line = frame:AddSeparator(1)
    for i,data in ipairs(self.roster) do
      local name, class, rank, alt = unpack(data)
      local eclass,_,hexclass = bepgp:getClassData(class)
      local r,g,b = RAID_CLASS_COLORS[eclass].r, RAID_CLASS_COLORS[eclass].g, RAID_CLASS_COLORS[eclass].b
      line = frame:AddLine()
      frame:SetCell(line,1,name,nil,"LEFT")
      frame:SetCellTextColor(line,1,r,g,b)
      frame:SetCell(line,2,rank,nil,"CENTER")
      frame:SetCell(line,3,(alt or ""),nil,"RIGHT")
      frame:SetLineScript(line, "OnMouseUp", bepgp_standby.sendTell, (alt or name))
    end
  end
  frame:UpdateScrolling()
end

function bepgp_standby:Toggle(anchor)
  if not T:IsAcquired(addonName.."standbyTablet") then
    self.qtip = T:Acquire(addonName.."standbyTablet") -- Name, Rank, OnAlt
    self.qtip:SetColumnLayout(3, "LEFT", "CENTER", "RIGHT")
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
