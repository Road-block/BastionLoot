local addonName, bepgp = ...
local moduleName = addonName.."_autoroll"
local bepgp_autoroll = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local GUI = LibStub("AceGUI-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
-- -1 = manual rolling, 0 = pass, 1 = need, 2 = greed
-- [9454] = true, -- acidic walkers
-- [9453] = true, -- toxic revenger
-- [9452] = true, -- hydrocane
local autoroll = {
  zg_coin = {
-- ZG coin
    [19698] = true, --zulian
    [19699] = true, --razzashi
    [19700] = true, --hakkari -- turnin 1
    [19701] = true, --gurubashi
    [19702] = true, --vilebranch
    [19703] = true, --witherbark -- turnin 2
    [19704] = true, --sandfury
    [19705] = true, --skullsplitter
    [19706] = true, --bloodscalp -- turnin 3
  },
  zg_bijou = {
-- ZG bijou
    [19707] = true, --red
    [19708] = true, --blue
    [19709] = true, --yellow
    [19710] = true, --orange
    [19711] = true, --green
    [19712] = true, --purple
    [19713] = true, --bronze
    [19714] = true, --silver
    [19715] = true, --gold
  },
  aq_scarab = {
  -- AQ scarabs
    [20858] = true, --stone
    [20859] = true, --gold
    [20860] = true, --silver
    [20861] = true, --bronze
    [20862] = true, --crystal
    [20863] = true, --clay
    [20864] = true, --bone
    [20865] = true, --ivory
  },
  aq_20_idol = {
  -- AQ20 idols
    [20866] = {["HUNTER"]=true,["ROGUE"]=true,["MAGE"]=true}, --azure
    [20867] = {["WARRIOR"]=true,["ROGUE"]=true,["WARLOCK"]=true}, --onyx
    [20868] = {["WARRIOR"]=true,["HUNTER"]=true,["PRIEST"]=true}, --lambent
    [20869] = {["PALADIN"]=true,["HUNTER"]=true,["SHAMAN"]=true,["WARLOCK"]=true}, --amber
    [20870] = {["PRIEST"]=true,["WARLOCK"]=true,["DRUID"]=true}, --jasper
    [20871] = {["PALADIN"]=true,["PRIEST"]=true,["SHAMAN"]=true,["MAGE"]=true}, --obsidian
    [20872] = {["PALADIN"]=true,["ROGUE"]=true,["SHAMAN"]=true,["DRUID"]=true}, --vermillion
    [20873] = {["WARRIOR"]=true,["MAGE"]=true,["DRUID"]=true}, --alabaster
  },
  aq_40_idol = {
  -- AQ40 idols
    [20874] = {["WARRIOR"]=true,["HUNTER"]=true,["ROGUE"]=true,["MAGE"]=true}, --sun
    [20875] = {["WARRIOR"]=true,["ROGUE"]=true,["MAGE"]=true,["WARLOCK"]=true}, --night
    [20876] = {["WARRIOR"]=true,["PRIEST"]=true,["MAGE"]=true,["WARLOCK"]=true}, --death
    [20877] = {["PALADIN"]=true,["PRIEST"]=true,["SHAMAN"]=true,["MAGE"]=true,["WARLOCK"]=true}, --sage
    [20878] = {["PALADIN"]=true,["PRIEST"]=true,["SHAMAN"]=true,["WARLOCK"]=true,["DRUID"]=true}, --rebirth
    [20879] = {["PALADIN"]=true,["HUNTER"]=true,["PRIEST"]=true,["SHAMAN"]=true,["DRUID"]=true}, --life
    [20881] = {["PALADIN"]=true,["HUNTER"]=true,["ROGUE"]=true,["SHAMAN"]=true,["DRUID"]=true}, --strife
    [20882] = {["WARRIOR"]=true,["HUNTER"]=true,["ROGUE"]=true,["DRUID"]=true}, --war
  },
  nx_scrap = {
  -- wartorn scraps
    [22373] = true, --leather
    [22374] = true, --Chain/Mail
    [22375] = true, --Plate
    [22376] = true, --Cloth
  },
}
if bepgp._bcc or bepgp._wrath then
  autoroll["dark_heart"] = {[32428] = true} -- Heart of Darkness
  autoroll["illi_mark"]  = {[32897] = true} -- Mark of the Illidari
  autoroll["sunmote"]    = {[34664] = true} -- Sunmote
end
if bepgp._wrath then
  autoroll["frozen_orb"]          = {[43102] = true} -- Frozen Orb
  autoroll["runed_orb"]           = {[45087] = true} -- Runed Orb
  autoroll["crusader_orb"]        = {[47556] = true} -- Crusader Orb
  autoroll["primordial_saronite"] = {[49908] = true} -- Primordial Saronite
end

function bepgp_autoroll:getAction(itemID)
  local group,item
  for option,data in pairs(autoroll) do
    if data[itemID] then
      group = option
      item = data[itemID]
      break
    end
  end
  if group and item then
    if (group == "aq_40_idol") or (group == "aq_20_idol") then
      if item[self._playerClass] then
        return bepgp.db.char.autoroll[group].class
      else
        return bepgp.db.char.autoroll[group].other
      end
    else
      return bepgp.db.char.autoroll[group]
    end
  end
end

local flat_data = {}
function bepgp_autoroll:ItemsHash()
  table.wipe(flat_data)
  for option,data in pairs(autoroll) do
    for item,_ in pairs(data) do
      flat_data[item] = true
    end
  end
  if bepgp:table_count(flat_data) > 0 then
    return flat_data
  else
    return
  end
end

local actions = {
  [0] = {L["passed"],""},
  [1] = {L["rolled"],_G.NEED},
  [2] = {L["rolled"],_G.GREED}
}
function bepgp_autoroll:Roll(event, rollID, rollTime, lootHandle)
  local texture, name, count, quality, bindOnPickUp, canNeed, canGreed = GetLootRollItemInfo(rollID)
  if (name) then
    local link = GetLootRollItemLink(rollID)
    local _, _, _, itemID = bepgp:getItemData(link)
    if (itemID) then
      local action = self:getAction(itemID)
      if (action) and ( action >= 0 ) then
        local shouldRoll = (action == 0) or ((action == 1) and canNeed) or ((action == 2) and canGreed)
        if shouldRoll then
          RollOnLoot(rollID,action)
          bepgp:debugPrint(string.format(L["Auto%s %s for %s"],actions[action][1],actions[action][2],link))
        end
      end
    end
  end
end

local zg_label = string.format("%s %%s",(GetRealZoneText(309)))
local aq20_label = string.format("%s %%s",(GetRealZoneText(509)))
local aq40_label = string.format("%s %%s",(GetRealZoneText(531)))
local aq_label = string.format("%s %%s",(C_Map.GetAreaInfo(3428)))
local nx_label = string.format("%s %%s",(GetRealZoneText(533)))
local options = {
  type = "group",
  name = L["Autoroll"],
  desc = L["Autoroll"],
  handler = bepgp_autoroll,
  args = {
    ["zg_coin"] = {
      type = "select",
      name = string.format(zg_label,L["Coins"]),
      desc = string.format(zg_label,L["Coins"]),
      order = 10,
      get = function() return bepgp.db.char.autoroll.zg_coin end,
      set = function(info, val) bepgp.db.char.autoroll.zg_coin = val end,
      values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
      sorting = {-1, 1, 2, 0}
    },
    ["zg_bijou"] = {
      type = "select",
      name = string.format(zg_label,L["Bijous"]),
      desc = string.format(zg_label,L["Bijous"]),
      order = 20,
      get = function() return bepgp.db.char.autoroll.zg_bijou end,
      set = function(info, val) bepgp.db.char.autoroll.zg_bijou = val end,
      values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
      sorting = {-1, 1, 2, 0}
    },
    ["aq_scarab"] = {
      type = "select",
      name = string.format(aq_label,L["Scarabs"]),
      desc = string.format(aq_label,L["Scarabs"]),
      order = 30,
      get = function() return bepgp.db.char.autoroll.aq_scarab end,
      set = function(info, val) bepgp.db.char.autoroll.aq_scarab = val end,
      values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
      sorting = {-1, 1, 2, 0}
    },
    ["aq_20_idol"] = {
      type = "group",
      name = string.format(aq20_label,L["Idols"]),
      desc = string.format(aq20_label,L["Idols"]),
      order = 40,
      args = {
        ["aq_20_class"] = {
          type = "select",
          name = string.format(aq20_label,L["Class Idols"]),
          desc = string.format(aq20_label,L["Class Idols"]),
          order = 10,
          get = function() return bepgp.db.char.autoroll.aq_20_idol.class end,
          set = function(info, val) bepgp.db.char.autoroll.aq_20_idol.class = val end,
          values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
          sorting = {-1, 1, 2, 0}
        },
        ["aq_20_other"] = {
          type = "select",
          name = string.format(aq20_label,L["Other Idols"]),
          desc = string.format(aq20_label,L["Other Idols"]),
          order = 20,
          get = function() return bepgp.db.char.autoroll.aq_20_idol.other end,
          set = function(info, val) bepgp.db.char.autoroll.aq_20_idol.other = val end,
          values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
          sorting = {-1, 1, 2, 0}
        }
      }
    },
    ["aq_40_idol"] = {
      type = "group",
      name = string.format(aq40_label,L["Idols"]),
      desc = string.format(aq40_label,L["Idols"]),
      order = 50,
      args = {
        ["aq_40_class"] = {
          type = "select",
          name = string.format(aq40_label,L["Class Idols"]),
          desc = string.format(aq40_label,L["Class Idols"]),
          order = 10,
          get = function() return bepgp.db.char.autoroll.aq_40_idol.class end,
          set = function(info, val) bepgp.db.char.autoroll.aq_40_idol.class = val end,
          values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
          sorting = {-1, 1, 2, 0}
        },
        ["aq_40_other"] = {
          type = "select",
          name = string.format(aq40_label,L["Other Idols"]),
          desc = string.format(aq40_label,L["Other Idols"]),
          order = 20,
          get = function() return bepgp.db.char.autoroll.aq_40_idol.other end,
          set = function(info, val) bepgp.db.char.autoroll.aq_40_idol.other = val end,
          values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
          sorting = {-1, 1, 2, 0}
        }
      }
    },
    ["nx_scrap"] = {
      type = "select",
      name = string.format(nx_label,L["Scraps"]),
      desc = string.format(nx_label,L["Scraps"]),
      order = 60,
      get = function() return bepgp.db.char.autoroll.nx_scrap end,
      set = function(info,val) bepgp.db.char.autoroll.nx_scrap = val end,
      values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
      sorting = {-1, 1, 2, 0}
    },
  }
}
if bepgp._bcc or bepgp._wrath then
  options.args["dark_heart"] = {
    type = "select",
    name = "Heart of Darkness", -- we'll delay load updates
    desc = "Heart of Darkness", -- we'll delay load updates
    order = 70,
    get = function() return bepgp.db.char.autoroll.dark_heart end,
    set = function(info,val) bepgp.db.char.autoroll.dark_heart = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
  options.args["illi_mark"] = {
    type = "select",
    name = "Mark of the Illidari", -- delay loading localized versions
    desc = "Mark of the Illidari", -- delay load updates
    order = 80,
    get = function() return bepgp.db.char.autoroll.illi_mark end,
    set = function(info,val) bepgp.db.char.autoroll.illi_mark = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
  options.args["sunmote"] = {
    type = "select",
    name = "Sunmote", -- delay loading localized versions
    desc = "Sunmote", -- delay load updates
    order = 90,
    get = function() return bepgp.db.char.autoroll.sunmote end,
    set = function(info,val) bepgp.db.char.autoroll.sunmote = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
end
if bepgp._wrath then
    options.args["frozen_orb"] = {
    type = "select",
    name = "Frozen Orb", -- we'll delay load updates
    desc = "Frozen Orb", -- we'll delay load updates
    order = 100,
    get = function() return bepgp.db.char.autoroll.frozen_orb end,
    set = function(info,val) bepgp.db.char.autoroll.frozen_orb = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
  options.args["runed_orb"] = {
    type = "select",
    name = "Frozen Orb", -- delay loading localized versions
    desc = "Frozen Orb", -- delay load updates
    order = 110,
    get = function() return bepgp.db.char.autoroll.runed_orb end,
    set = function(info,val) bepgp.db.char.autoroll.runed_orb = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
  options.args["crusader_orb"] = {
    type = "select",
    name = "Crusader Orb", -- delay loading localized versions
    desc = "Crusader Orb", -- delay load updates
    order = 120,
    get = function() return bepgp.db.char.autoroll.crusader_orb end,
    set = function(info,val) bepgp.db.char.autoroll.crusader_orb = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
  options.args["primordial_saronite"] = {
    type = "select",
    name = "Primordial Saronite", -- delay loading localized versions
    desc = "Primordial Saronite", -- delay load updates
    order = 130,
    get = function() return bepgp.db.char.autoroll.primordial_saronite end,
    set = function(info,val) bepgp.db.char.autoroll.primordial_saronite = val end,
    values = { [-1]=_G.TRACKER_SORT_MANUAL, [0]=_G.PASS, [1]=_G.NEED, [2]=_G.GREED },
    sorting = {-1, 1, 2, 0}
  }
end
function bepgp_autoroll:injectOptions() -- .general.args.main.args
  bepgp.db.char.autoroll = bepgp.db.char.autoroll or {
    ["zg_coin"] = 1,
    ["zg_bijou"] = 1,
    ["aq_scarab"] = 1,
    ["nx_scrap"] = 1,
  }
  if bepgp.db.char.autoroll.nx_scrap == nil then
    bepgp.db.char.autoroll.nx_scrap = 1
  end
  bepgp.db.char.autoroll.aq_20_idol = bepgp.db.char.autoroll.aq_20_idol or {
    ["class"] = 1,
    ["other"] = 2,
  }
  bepgp.db.char.autoroll.aq_40_idol = bepgp.db.char.autoroll.aq_40_idol or {
    ["class"] = 1,
    ["other"] = 2,
  }
  if bepgp._bcc or bepgp._wrath then
    self:ScheduleTimer("cacheItemOptions",20)
    if bepgp.db.char.autoroll.dark_heart == nil then
      bepgp.db.char.autoroll.dark_heart = -1
    end
    if bepgp.db.char.autoroll.illi_mark == nil then
      bepgp.db.char.autoroll.illi_mark = 1
    end
    if bepgp.db.char.autoroll.sunmote == nil then
      bepgp.db.char.autoroll.sunmote = 1
    end
  end
  if bepgp._wrath then
    if bepgp.db.char.autoroll.frozen_orb == nil then
      bepgp.db.char.autoroll.frozen_orb = -1
    end
    if bepgp.db.char.autoroll.runed_orb == nil then
      bepgp.db.char.autoroll.runed_orb = -1
    end
    if bepgp.db.char.autoroll.crusader_orb == nil then
      bepgp.db.char.autoroll.crusader_orb = -1
    end
    if bepgp.db.char.autoroll.primordial_saronite == nil then
      bepgp.db.char.autoroll.primordial_saronite = -1
    end
  end
  bepgp._options.args.general.args.autoroll = options
  bepgp._options.args.general.args.autoroll.cmdHidden = true
end

local items_to_cache = {
  dark_heart          = 32428,
  illi_mark           = 32897,
  sunmote             = 34664,
  frozen_orb          = 43102,
  runed_orb           = 45087,
  crusader_orb        = 47556,
  primordial_saronite = 49908,
}
function bepgp_autoroll:cacheItemOptions()
  for option, itemid in pairs(items_to_cache) do
    local id = GetItemInfoInstant(itemid)
    if id then
      local itemAsync = Item:CreateFromItemID(id)
      itemAsync:ContinueOnItemLoad(function()
        local color = itemAsync:GetItemQualityColor().color
        local itemname = itemAsync:GetItemName()
        local markup = CreateTextureMarkup(itemAsync:GetItemIcon(), 32, 32, 16, 16, 0, 1, 0, 1)
        local name = string.format("%s %s",markup,color:WrapTextInColorCode(itemname))
        options.args[option]["name"] = name
        options.args[option]["desc"] = itemname
      end)
    end
  end
end

function bepgp_autoroll:delayInit()
  self:injectOptions()
  self:RegisterEvent("START_LOOT_ROLL","Roll")
  local _
  _, self._playerClass = UnitClass("player")
  self._initDone = true
end

function bepgp_autoroll:CoreInit()
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_autoroll:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end
