local addonName, bepgp = ...
local moduleName = addonName.."_comms"
local bepgp_comms = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

local inProgress = { }
local messageQueue = { }
local guildName

local defaults = {
  profile = {
    epgp = {},
  }
}

function bepgp_comms:OnEnable()
  if not (bepgp._cata or bepgp._mists) then return end
  if IsInGuild() then
    guildName = GetGuildInfo("player")
    if not guildName then
      self:RegisterEvent("GUILD_ROSTER_UPDATE")
      bepgp:safeGuildRoster()
    else
      self:Init(guildName)
    end
  else
    self:RegisterEvent("PLAYER_GUILD_UPDATE")
    return
  end
end

function bepgp_comms:Init(guild_name)
  if self._initDone then return end
  local realmname = GetRealmName()
  local profilekey = guild_name.." - "..realmname
  self._oReadRanks = self:GetOReadRanks()
  if bepgp.CanViewOfficerNote() then
    bepgp._network[bepgp._playerName] = true
  end
  self.db = LibStub("AceDB-3.0"):New("BastionLootCache",defaults,profilekey)
  self._prefixData = addonName:upper().."_DB"
  self._prefixRQ = addonName:upper().."_RQ"
  self._prefixes = {}
  self._prefixes[self._prefixData] = true
  self._prefixes[self._prefixRQ] = true
  self:RegisterComm(self._prefixData)
  self:RegisterComm(self._prefixRQ)
end

function bepgp_comms:GUILD_ROSTER_UPDATE()
  guildName = GetGuildInfo("player")
  if guildName then
    self:Init(guildName)
  end
end

function bepgp_comms:PLAYER_GUILD_UPDATE(...)
  local unitid = ...
  if unitid and UnitIsUnit(unitid,"player") then
    if IsInGuild() then
      self:OnEnable()
    end
  end
end

function bepgp_comms:GetOReadRanks()
  self._oReadRanks = wipe(self._oReadRanks or {})
  for rankIndex=1,GuildControlGetNumRanks() do
    local onote_read = bepgp.GuildControlGetRankFlags(rankIndex)[11]
    local roster_rank = rankIndex-1
    if onote_read then
      self._oReadRanks[roster_rank] = GuildControlGetRankName(rankIndex)
    end
  end
  return self._oReadRanks
end

local dataNodes = { }
function bepgp_comms:GetDataNodes(context)
  wipe(dataNodes)
  local numTotal, numOnline = GetNumGuildMembers()
  for i=1,numOnline do
    local g_name, _, g_rankIndex, _, _, _, _, _, g_online = GetGuildRosterInfo(i)
    if g_name and (g_name ~= _G.UNKNOWNOBJECT) and g_rankIndex then
      local name = bepgp:Ambiguate(g_name)
      if self._oReadRanks[g_rankIndex] and bepgp._network[name] then
        dataNodes[#dataNodes+1] = name
      end
    end
  end
  if #dataNodes > 1 then
    table.sort(dataNodes)
  end
  return dataNodes[1], dataNodes[#dataNodes]
end

local raw_epgp_data = { }
function bepgp_comms:GetDataForSending(name)
  if not bepgp.CanViewOfficerNote() then return end
  local cacheDB = self.db and self.db.profile and self.db.profile.epgp
  wipe(raw_epgp_data)
  if name then
    local ep, gp = 0, bepgp.VARS.basegp
    ep = bepgp:get_ep(name) or 0
    gp = bepgp:get_gp(name) or bepgp.VARS.basegp
    if ep > 0 then
      raw_epgp_data[name] = {ep, gp}
      return raw_epgp_data
    end
  else
    local members = bepgp:buildRosterTable()
    local cacheUpdated = false
    for i,member in pairs(members) do
      local is_alt, is_standin, g_onote = member.alt, member.standin, member.onote
      local ep, gp = 0, bepgp.VARS.basegp
      local g_name
      if is_standin then
        g_name = is_standin
      elseif (not is_alt) then
        g_name = member.name
      end
      if g_name then
        ep = bepgp:get_ep(g_name,g_onote) or 0
        if ep > 0 then
          gp = bepgp:get_gp(g_name,g_onote) or bepgp.VARS.basegp
          raw_epgp_data[g_name] = {ep, gp}
          if cacheDB then
            cacheDB[g_name] = {ep, gp}
            cacheUpdated = true
          end
        end
      end
    end
    if cacheUpdated then
      local epoch, timestamp = bepgp:getServerTime()
      cacheDB._epoch = epoch
    end
    return raw_epgp_data
  end
end

function bepgp_comms:RequestData(name)
  if name then
    self:SendCommMessage(self._prefixRQ, bepgp._playerName, "WHISPER", name)
  else
    self:SendCommMessage(self._prefixRQ, bepgp._playerName, "GUILD")
  end
end

function bepgp_comms.sendProgress(recipient, bytesSent, bytesTotal)
  if bytesTotal == bytesSent then
    local channel, target = unpack(recipient,1,2)
    local recipientKey = string.format("%s:%s",channel, (target or ""))
    local epoch, timestamp = bepgp:getServerTime()
    bepgp_comms:SendCommMessage(bepgp_comms._prefixData, string.format("_epoch:%s",epoch), channel, target, "NORMAL")
    inProgress[recipientKey] = nil
    if bepgp_comms:GetQueueSize() > 0 then
      local data, channel, target = unpack(bepgp_comms:DeQueue(),1,3)
      bepgp_comms:ClearQueue()
      bepgp_comms:Transmit(data,channel,target)
    end
  end
end

function bepgp_comms:Transmit(data, channel, target)
  local recipientKey = string.format("%s:%s",channel,(target or ""))
  if inProgress[recipientKey] then
    self:EnQueue({data,channel,target})
    return
  end
  local serialized = LibSerialize:Serialize(data)
  local compressed = LibDeflate:CompressDeflate(serialized)
  local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
  inProgress[recipientKey] = true
  self:SendCommMessage(self._prefixData, encoded, channel, target, "NORMAL", bepgp_comms.sendProgress, {channel, target})
end

function bepgp_comms:EnQueue(item)
  messageQueue[#messageQueue+1] = item
end
function bepgp_comms:DeQueue()
  --return table.remove(messageQueue, 1) --oldest first
  return table.remove(messageQueue,#messageQueue) --newest first
end

function bepgp_comms:GetQueue()
  return messageQueue
end

function bepgp_comms:GetQueueSize()
  return #messageQueue
end

function bepgp_comms:ClearQueue()
  wipe(messageQueue)
end

local incoming = { }
function bepgp_comms:OnCommReceived(prefix, payload, distribution, sender)
  if UnitIsUnit("player",sender) then return end -- don't care for our own message
  if not self._prefixes[prefix] then return end -- not our message
  local sender = bepgp:Ambiguate(sender)
  local name, class, rank = bepgp:verifyGuildMember(sender, true)
  if not (name and class) then return end -- not in our guild
  bepgp._network[sender] = true
  if prefix == self._prefixRQ then -- someone is requesting epgp data
    if not bepgp.CanViewOfficerNote() then return end -- we don't have access to raw data
    if distribution == "GUILD" then
      -- logic to decide if we are sending or leaving it to someone else
      local name1, name2 = self:GetDataNodes()
      if (name1 and name1 == bepgp._playerName) or (name2 and name2 == bepgp._playerName) then
        self:Transmit(self:GetDataForSending(),"GUILD")
      end
    --elseif distribution == "RAID" then
      -- send
    elseif distribution == "WHISPER" then
      -- package and send
      self:Transmit(self:GetDataForSending(),"WHISPER",sender)
    end
    return
  end
  if prefix == self._prefixData then -- someone is sending us epgp data
    if not self.db.profile.epgp then return end
    if bepgp.CanViewOfficerNote() then return end -- we have real-time access
    local _, _epoch = payload:match("^(_epoch:)(%d+)$")
    _epoch = _epoch and tonumber(_epoch)
    if _epoch then
      if (not self.db.profile.epgp._epoch) or (_epoch > tonumber(self.db.profile.epgp._epoch)) then
        if incoming[sender] then
          wipe(self.db.profile.epgp)
          self.db.profile.epgp._epoch = _epoch
          for name,epgp in pairs(incoming[sender]) do
            self.db.profile.epgp[name] = {epgp[1],epgp[2]}
          end
          wipe(incoming[sender])
        end
        self:SendMessage(addonName.."_EPGPCACHE")
      end
      return
    else
      incoming[sender] = incoming[sender] or {}
      local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
      if not decoded then return end
      local decompressed = LibDeflate:DecompressDeflate(decoded)
      if not decompressed then return end
      local success, data = LibSerialize:Deserialize(decompressed)
      if not success then return end
      incoming[sender] = incoming[sender] or {}
      for name,epgp in pairs(data) do
        incoming[sender][name]={epgp[1],epgp[2]}
      end
    end
  end
end
