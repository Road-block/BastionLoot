local addonName, bepgp = ...
local moduleName = addonName.."_bench"
local bepgp_bench = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local ACD = LibStub("AceConfigDialog-3.0")

local volatile = {
  raid = "",
  bench = {
    [_G.TANK]={b=0,f=0,t=0},
    [_G.HEALER]={b=0,f=0,t=0},
    [_G.RANGED]={b=0,f=0,t=0},
    [_G.MELEE]={b=0,f=0,t=0},
  },
  pool = {},
  [_G.TANK] = 0,
  [_G.HEALER] = 0,
  [_G.RANGED] = 0,
  [_G.MELEE] = 0,
}
local roleorder = {_G.TANK,_G.HEALER,_G.RANGED,_G.MELEE}
function bepgp_bench:calcRoleBench(roleid,rolenum,raidid,totalsigned)
  local raidLimits = bepgp.db.char.benchcalc.raidLimits
  local raidlimit = raidLimits[raidid].total
  local bench = totalsigned - raidlimit
  if bench <= 0 then return 0 end
  local ratio = rolenum/totalsigned
  local minrole = raidLimits[raidid][roleid] or 0
  if rolenum <= minrole then return 0,0 end
  local rolebench, _ = math.modf(bench*ratio)
  local free
  if rolenum > rolebench then
    if minrole > 0 and rolenum > minrole then
      free = rolenum-minrole-rolebench
    else
      free = rolenum - rolebench
    end
  else
    free = 0
  end
  return rolebench, free
end

function bepgp_bench:clearRoles(roles)
  roles[_G.TANK].b=0
  roles[_G.TANK].t=0
  roles[_G.TANK].f=0
  roles[_G.HEALER].b=0
  roles[_G.HEALER].t=0
  roles[_G.HEALER].f=0
  roles[_G.RANGED].b=0
  roles[_G.RANGED].t=0
  roles[_G.RANGED].f=0
  roles[_G.MELEE].b=0
  roles[_G.MELEE].t=0
  roles[_G.MELEE].f=0
end

function bepgp_bench:calcRaidBench(raidid)
  local _, signed, cap = self:SignupTotals()
  local raidLimits = bepgp.db.char.benchcalc.raidLimits
  local pool = volatile.pool
  local roles = volatile.bench
  self:clearRoles(roles)
  table.wipe(pool)
  local bench = signed - cap
  local rolebenchtotal = 0
  for _,roleid in ipairs(roleorder) do
    local rolebench,free = self:calcRoleBench(roleid,volatile[roleid],raidid,signed)
    roles[roleid].b = rolebench
    roles[roleid].f = free
    roles[roleid].t = volatile[roleid]
    for i=1,(free or 0) do
      local rationed = (rolebench + i)/volatile[roleid]
      table.insert(pool,{roleid,rationed})
    end
    rolebenchtotal = rolebenchtotal + rolebench
  end
  table.sort(pool,function(a,b)
    return a[2] > b[2] -- we sort high to low bench since table.remove will work off the back of the scale
  end)
  local deficit = bench - rolebenchtotal
  if deficit > 0 then
    for i=1,deficit do
      local data = table.remove(pool)
      local roleid = data[1]
      roles[roleid].b = roles[roleid].b + 1
    end
  end
end

local options = {
  type = "group",
  name = L["Bench"],
  desc = L["Bench"],
  hidden = function()
    return not bepgp:admin()
  end,
  handler = bepgp_bench,
  args = {
    ["raid"] = {
      type = "select",
      name = _G.RAID,
      desc = _G.CHOOSE_RAID,
      order = 10,
      get = function() return volatile.raid~="" and volatile.raid or bepgp.db.profile.progress end,
      set = function(info, val)
        volatile.raid = val
      end,
      values = {["T10.5"]=L["5.RS"], ["T10"]=L["4.ICC, VoA-T"], ["T9"]=L["3.ToCR, Ony, VoA-K"], ["T8"]=L["2.EoE, Uld, VoA-E"], ["T7"]=L["1.Naxx, OS, VoA-A"]},
      sorting = {"T7", "T8", "T9", "T10", "T10.5"},
    },
    ["tank_min"] = {
      type = "input",
      name = string.format("%s %s",_G.RECOMMENDED,_G.TANK),
      get = function(info)
        local raidid = volatile.raid~="" and volatile.raid or bepgp.db.profile.progress
        return tostring(bepgp.db.char.benchcalc.raidLimits[raidid][_G.TANK])
      end,
      set = function(info,val)
        local raidid = volatile.raid~="" and volatile.raid or bepgp.db.profile.progress
        bepgp.db.char.benchcalc.raidLimits[raidid][_G.TANK] = tonumber(val)
      end,
      order = 15
    },
    ["healer_min"] = {
      type = "input",
      name = string.format("%s %s",_G.RECOMMENDED,_G.HEALER),
      get = function(info)
        local raidid = volatile.raid~="" and volatile.raid or bepgp.db.profile.progress
        return tostring(bepgp.db.char.benchcalc.raidLimits[raidid][_G.HEALER])
      end,
      set = function(info,val)
        local raidid = volatile.raid~="" and volatile.raid or bepgp.db.profile.progress
        bepgp.db.char.benchcalc.raidLimits[raidid][_G.HEALER] = tonumber(val)
      end,
      order = 16
    },
    ["header_signups"] = {
      type = "header",
      name = function(info)
        return (bepgp_bench:SignupTotals())
      end,
      order = 17,
    },
    ["tank"] = {
      type = "input",
      name = _G.TANK,
      get = function(info)
        return tostring(tonumber(volatile[_G.TANK]))
      end,
      set = function(info,val)
        volatile[_G.TANK] = tonumber(val)
      end,
      order = 18
    },
    ["healer"] = {
      type = "input",
      name = _G.HEALER,
      get = function(info)
        return tostring(tonumber(volatile[_G.HEALER]))
      end,
      set = function(info,val)
        volatile[_G.HEALER] = tonumber(val)
      end,
      order = 19
    },
    ["ranged"] = {
      type = "input",
      name = _G.RANGED,
      get = function(info)
        return tostring(tonumber(volatile[_G.RANGED]))
      end,
      set = function(info,val)
        volatile[_G.RANGED] = tonumber(val)
      end,
      order = 20
    },
    ["melee"] = {
      type = "input",
      name = _G.MELEE,
      get = function(info)
        return tostring(tonumber(volatile[_G.MELEE]))
      end,
      set = function(info,val)
        volatile[_G.MELEE] = tonumber(val)
      end,
      order = 21
    },
    ["header_bench"] = {
      type = "header",
      name = function(info)
        return (bepgp_bench:BenchTotals())
      end,
      order = 25,
    },
    ["calc"] = {
      type = "execute",
      name = L["Suggest"],
      desc = L["Suggest a bench breakdown"],
      func = function(info)
        local raid = volatile.raid ~= "" and volatile.raid or bepgp.db.profile.progress
        bepgp_bench:calcRaidBench(raid)
      end,
      disabled = function(info)

      end,
      order = 26,
    },
    ["output"] = {
      type = "description",
      fontSize = "medium",
      name = function(info)
        return bepgp_bench:BenchBreakDown()
      end,
      order = 27
    }
  }
}

function bepgp_bench:SignupTotals()
    local signed = 0
    local raid = volatile.raid ~= "" and volatile.raid or bepgp.db.profile.progress
    local cap = bepgp.db.char.benchcalc.raidLimits[raid].total
    if volatile[_G.TANK] then
      signed = signed + tonumber(volatile[_G.TANK])
    end
    if volatile[_G.HEALER] then
      signed = signed + tonumber(volatile[_G.HEALER])
    end
    if volatile[_G.RANGED] then
      signed = signed + tonumber(volatile[_G.RANGED])
    end
    if volatile[_G.MELEE] then
      signed = signed + tonumber(volatile[_G.MELEE])
    end
    return string.format("%s: %d/%d",L["Signups"], signed, cap), signed, cap
end

function bepgp_bench:BenchTotals()
  local _, signups, cap = self:SignupTotals()
  local bench = math.max(0,signups-cap)
  return string.format("%s: %d",L["Bench"],bench), bench
end

function bepgp_bench:BenchBreakDown()
  local out = string.format("|cffc69b6d%s|r: |cffff7f00%d|r/|cff00ff00%d|r",_G.TANK, volatile.bench[_G.TANK].b,volatile.bench[_G.TANK].t)
  out = out .. "\n" .. string.format("|cffffffff%s|r: |cffff7f00%d|r/|cff00ff00%d|r",_G.HEALER, volatile.bench[_G.HEALER].b,volatile.bench[_G.HEALER].t)
  out = out .. "\n" .. string.format("|cff3fc6ea%s|r: |cffff7f00%d|r/|cff00ff00%d|r",_G.RANGED, volatile.bench[_G.RANGED].b,volatile.bench[_G.RANGED].t)
  out = out .. "\n" .. string.format("|cfffff468%s|r: |cffff7f00%d|r/|cff00ff00%d|r",_G.MELEE, volatile.bench[_G.MELEE].b,volatile.bench[_G.MELEE].t)
  return out
end

local limits = {
  raidLimits = {
    ["T7"] = {
      total = 25,
      [_G.TANK] = 2,
      [_G.HEALER] = 5,
    },
    ["T8"] = {
      total = 25,
      [_G.TANK] = 2,
      [_G.HEALER] = 5,
    },
    ["T9"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 5,
    },
    ["T10"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 5,
    },
    ["T10.5"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 6,
    },
  },
}

if bepgp._bcc then
  options.args.raid.values = { ["T6.5"]=L["4.Sunwell Plateau"], ["T6"]=L["3.Black Temple, Hyjal"], ["T5"]=L["2.Serpentshrine Cavern, The Eye"], ["T4"]=L["1.Karazhan, Magtheridon, Gruul, World Bosses"]}
  options.args.raid.sorting = {"T4", "T5", "T6", "T6.5"}
  limits.raidLimits = {
    ["T4"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 6,
    },
    ["T5"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 7,
    },
    ["T6"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 7,
    },
    ["T6.5"] = {
      total = 25,
      [_G.TANK] = 3,
      [_G.HEALER] = 8,
    }
  }
end

if bepgp._classic then
  options.args.raid.values = { ["T3"]=L["4.Naxxramas"], ["T2.5"]=L["3.Temple of Ahn\'Qiraj"], ["T2"]=L["2.Blackwing Lair"], ["T1"]=L["1.Molten Core"]}
  options.args.raid.sorting = {"T1", "T2", "T2.5", "T3"}
  limits.raidLimits = {
    ["T1"] = {
      total = 40,
      [_G.TANK] = 3,
      [_G.HEALER] = 10,
    },
    ["T2"] = {
      total = 40,
      [_G.TANK] = 4,
      [_G.HEALER] = 12,
    },
    ["T2.5"] = {
      total = 40,
      [_G.TANK] = 5,
      [_G.HEALER] = 14,
    },
    ["T3"] = {
      total = 40,
      [_G.TANK] = 6,
      [_G.HEALER] = 15,
    }
  }
end

function bepgp_bench:injectOptions()
  bepgp.db.char.benchcalc = bepgp.db.char.benchcalc or limits
  bepgp._options.args.general.args.benchcalc = options
  bepgp._options.args.general.args.benchcalc.cmdHidden = true
end

function bepgp_bench:delayInit()
  if bepgp:admin() then
    self:injectOptions()
  end
  self._initDone = true
end

function bepgp_bench:CoreInit()
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_bench:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
  self:delayInit()
end
