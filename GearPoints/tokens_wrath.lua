local addonName, bepgp = ...
local moduleName = addonName.."_tokens_lk"
local bepgp_tokens_lk = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local tokens = {} -- item = token
local rewards = {} -- token = items
local last_reward_flipped = {} -- token = reward
-- T7
rewards[40610] = {39629, 39633, 39638, 39515, 39523, 39497}
rewards[40611] = {39606, 39611, 39579, 39588, 39592, 39597}
rewards[40612] = {39558, 39617, 39623, 39492, 39538, 39547, 39554}
rewards[40613] = {39632, 39634, 39639, 39519, 39530, 39500}
rewards[40614] = {39609, 39622, 39582, 39591, 39593, 39601}
rewards[40615] = {39560, 39618, 39624, 39495, 39543, 39544, 39557}
rewards[40616] = {39628, 39635, 39640, 39514, 39521, 39496}
rewards[40617] = {39605, 39610, 39578, 39583, 39594, 39602}
rewards[40618] = {39561, 39619, 39625, 39491, 39531, 39545, 39553}
rewards[40619] = {39630, 39636, 39641, 39517, 39528, 39498}
rewards[40620] = {39607, 39612, 39580, 39589, 39595, 39603}
rewards[40621] = {39564, 39620, 39626, 39493, 39539, 39546, 39555}
rewards[40622] = {39631, 39637, 39642, 39518, 39529, 39499}
rewards[40623] = {39608, 39613, 39581, 39590, 39596, 39604}
rewards[40624] = {39565, 39621, 39627, 39494, 39542, 39548, 39556}
rewards[40625] = {40569, 40574, 40579, 40449, 40458, 40423}
rewards[40626] = {40525, 40544, 40503, 40508, 40514, 40523}
rewards[40627] = {40495, 40550, 40559, 40418, 40463, 40469, 40471}
rewards[40628] = {40570, 40575, 40580, 40445, 40454, 40420}
rewards[40629] = {40527, 40545, 40504, 40509, 40515, 40520}
rewards[40630] = {40496, 40552, 40563, 40415, 40460, 40466, 40472}
rewards[40631] = {40571, 40576, 40581, 40447, 40456, 40421}
rewards[40632] = {40528, 40546, 40505, 40510, 40516, 40521}
rewards[40633] = {40499, 40554, 40565, 40416, 40461, 40467, 40473}
rewards[40634] = {40572, 40577, 40583, 40448, 40457, 40422}
rewards[40635] = {40529, 40547, 40506, 40512, 40517, 40522}
rewards[40636] = {40500, 40556, 40567, 40417, 40462, 40468, 40493}
rewards[40637] = {40573, 40578, 40584, 40450, 40459, 40424}
rewards[40638] = {40530, 40548, 40507, 40513, 40518, 40524}
rewards[40639] = {40502, 40557, 40568, 40419, 40465, 40470, 40494}
rewards[44569] = {44658, 44657, 44659, 44660} -- key to the focusing iris 10man
rewards[44577] = {44661, 44662, 44664, 44665} -- key to the focusing iris 25man
-- T8
rewards[45635] = {45374, 45375, 45381, 45389, 45395, 45421}
rewards[45636] = {45424, 45429, 45364, 45405, 45411, 45413}
rewards[45637] = {45396, 45335, 45340, 45368, 45348, 45354, 45358}
rewards[45647] = {45372, 45377, 45382, 45386, 45391, 45417}
rewards[45648] = {45425, 45431, 45361, 45402, 45408, 45412}
rewards[45649] = {45398, 45336, 45342, 45365, 45346, 45356, 46313}
rewards[45644] = {45370, 45376, 45383, 45387, 45392, 45419}
rewards[45645] = {45426, 45430, 45360, 45401, 45406, 45414}
rewards[45646] = {45397, 45337, 45341, 46131, 45345, 45351, 45355}
rewards[45650] = {45371, 45379, 45384, 45388, 45394, 45420}
rewards[45651] = {45427, 45432, 45362, 45403, 45409, 45416}
rewards[45652] = {45399, 45338, 45343, 45367, 45347, 45353, 45357}
rewards[45659] = {45373, 45380, 45385, 45390, 45393, 45422}
rewards[45660] = {45428, 45433, 45363, 45404, 45410, 45415}
rewards[45661] = {45400, 45339, 45344, 45369, 45349, 45352, 45359}
rewards[45632] = {46154, 46173, 46178, 46168, 46193, 46137}
rewards[45633] = {46146, 46162, 46141, 46198, 46205, 46206}
rewards[45634] = {46123, 46111, 46118, 46130, 46159, 46186, 46194}
rewards[45638] = {46156, 46175, 46180, 46172, 46197, 46140}
rewards[45639] = {46151, 46166, 46143, 46201, 46209, 46212}
rewards[45640] = {46125, 46115, 46120, 46129, 46161, 46184, 46191}
rewards[45641] = {46155, 46174, 46179, 46163, 46188, 46135}
rewards[45642] = {46148, 46164, 46142, 46199, 46200, 46207}
rewards[45643] = {46124, 46113, 46119, 46132, 46158, 46183, 46189}
rewards[45653] = {46153, 46176, 46181, 46170, 46195, 46139}
rewards[45654] = {46150, 46169, 46144, 46202, 46208, 46210}
rewards[45655] = {46126, 46116, 46121, 46133, 46160, 46185, 46192}
rewards[45656] = {46152, 46177, 46182, 46165, 46190, 46136}
rewards[45657] = {46149, 46167, 46145, 46203, 46204, 46211}
rewards[45658] = {46127, 46117, 46122, 46134, 46157, 46187, 46196}
rewards[46052] = {46320, 46321, 46322, 46323} -- Reply code Alpha 10man
rewards[46053] = {45588, 45618, 45608, 45614} -- Reply code Alpha 25man
-- T9
rewards[47242] = {
48500, 48499, 48498, 48497, 48496, 48481, 48482, 48483, 48484, 48485, 48557, 48555, 48556, 48554, 48553, 48538, 48540, 48539, 48541, 48542, -- DK
48164, 48163, 48167, 48165, 48166, 48152, 48151, 48150, 48149, 48148, 48133, 48134, 48135, 48136, 48137, 48181, 48182, 48178, 48180, 48179, 48193, 48194, 48195, 48196, 48197, 48212, 48211, 48210, 48209, 48208, -- Druid
48256, 48257, 48258, 48259, 48255, 48273, 48272, 48271, 48270, 48274, -- Hunter
47772, 47771, 47770, 47769, 47768, 47753, 47754, 47755, 47756, 47757, -- Mage
48607, 48608, 48609, 48610, 48611, 48576, 48578, 48577, 48579, 48575, 48626, 48625, 48624, 48623, 48622, 48657, 48659, 48658, 48660, 48661, 48641, 48639, 48640, 48638, 48637, 48593, 48591, 48592, 48590, 48594, -- Paladin
48078, 48077, 48081, 48079, 48080, 48065, 48066, 48064, 48063, 48062, 47984, 47983, 47985, 47986, 47987, 48095, 48096, 48092, 48094, 48093, -- Priest
48223, 48224, 48225, 48226, 48227, 48242, 48241, 48240, 48239, 48238, -- Rogue
48346, 48348, 48347, 48350, 48349, 48317, 48316, 48318, 48319, 48320, 48334, 48335, 48333, 48332, 48331, 48286, 48287, 48288, 48289, 48285, 48361, 48362, 48363, 48364, 48365, 48301, 48302, 48303, 48304, 48300, -- Shaman
47803, 47804, 47805, 47806, 47807, 47782, 47778, 47780, 47779, 47781, -- Warlock
48461, 48463, 48462, 48464, 48465, 48450, 48430, 48452, 48446, 48454, 48391, 48392, 48393, 48394, 48395, 48376, 48377, 48378, 48379, 48380, -- Warrior
}
rewards[47557] = {
48583, 48581, 48582, 48580, 48584, 48588, 48586, 48587, 48585, 48589, 48642, 48644, 48643, 48645, 48646, 48651, 48649, 48650, 48648, 48647, 48617, 48618, 48619, 48620, 48621, 48616, 48615, 48614, 48613, 48612, 48085, 48086, 48082, 48084, 48083, 48088, 48087, 48091, 48089, 48090, 48035, 48037, 48033, 48031, 48029, 48058, 48057, 48059, 48060, 48061, 47788, 47789, 47790, 47791, 47792, 47797, 47796, 47795, 47794, 47793, -- Paladin, Priest, Warlock
}
rewards[47558] = {
48263, 48262, 48261, 48260, 48264, 48266, 48267, 48268, 48269, 48265, 48324, 48325, 48323, 48322, 48321, 48306, 48307, 48308, 48309, 48305, 48355, 48353, 48354, 48351, 48352, 48293, 48292, 48291, 48290, 48294, 48360, 48359, 48358, 48357, 48356, 48327, 48326, 48328, 48329, 48330, 48466, 48468, 48467, 48469, 48470, 48396, 48397, 48398, 48399, 48400, 48385, 48384, 48383, 48382, 48381, 48451, 48433, 48453, 48447, 48455, -- Hunter, Shaman, Warrior
}
rewards[47559] = {
48491, 48492, 48493, 48494, 48495, 48548, 48550, 48549, 48551, 48552, 48547, 48545, 48546, 48544, 48543, 48490, 48489, 48488, 48487, 48486, 48171, 48172, 48168, 48170, 48169, 48202, 48201, 48200, 48199, 48198, 48142, 48141, 48140, 48139, 48138, 48174, 48173, 48177, 48175, 48176, 48143, 48144, 48145, 48146, 48147, 48203, 48204, 48205, 48206, 48207, 47762, 47761, 47760, 47759, 47758, 47763, 47764, 47765, 47766, 47767, 48232, 48231, 48230, 48229, 48228, 48233, 48234, 48235, 48236, 48237, -- DK, Druid, Mage, Rogue
}
rewards[49643] = {49485, 49486, 49487} -- Onyxia Horde
rewards[49644] = {49485, 49486, 49487} -- Onyxia Alliance
-- T10
rewards[52025] = {
51129, 51128, 51127, 51126, 51125, 51130, 51131, 51133, 51132, 51134, 51147, 51146, 51149, 51148, 51145, 51140, 51142, 51143, 51144, 51141, 51139, 51138, 51137, 51136, 51135, 51159, 51158, 51157, 51156, 51155, 51185, 51187, 51186, 51189, 51188, -- DK, Druid, Mage, Rogue
}
rewards[52026] = {
51154, 51153, 51152, 51151, 51150, 51195, 51196, 51197, 51198, 51199, 51200, 51201, 51202, 51203, 51204, 51190, 51191, 51192, 51193, 51194, 51215, 51216, 51218, 51217, 51219, 51214, 51213, 51212, 51211, 51210, -- Hunter, Shaman, Warrior
}
rewards[52027] = {
51170, 51171, 51173, 51172, 51174, 51166, 51168, 51167, 51169, 51165, 51160, 51161, 51162, 51163, 51164, 51181, 51180, 51182, 51183, 51184, 51177, 51176, 51175, 51179, 51178, 51209, 51208, 51207, 51206, 51205, -- Paladin, Priest, Warlock
}
rewards[52028] = {
51310, 51311, 51312, 51313, 51314, 51309, 51308, 51306, 51307, 51305, 51300, 51301, 51302, 51303, 51304, 51299, 51297, 51296, 51295, 51298, 51292, 51293, 51290, 51291, 51294, 51280, 51281, 51282, 51283, 51284, 51254, 51252, 51253, 51250, 51251, -- DK, Druid, Mage, Rogue
}
rewards[52029] = {
51285, 51286, 51287, 51288, 51289, 51239, 51238, 51237, 51236, 51235, 51244, 51243, 51242, 51241, 51240, 51249, 51248, 51247, 51246, 51245, 51225, 51226, 51227, 51228, 51229, 51224, 51223, 51221, 51222, 51220, -- Hunter, Shaman, Warrior
}
rewards[52030] = {
51279, 51278, 51277, 51276, 51275, 51273, 51271, 51272, 51270, 51274, 51269, 51268, 51266, 51267, 51265, 51258, 51259, 51257, 51256, 51255, 51262, 51263, 51264, 51260, 51261, 51230, 51231, 51232, 51233, 51234, -- Paladin, Priest, Warlock
}

local token_info = {}
local token_info_string = {}
local item_icon_markup = setmetatable({},{__index = function(t,k)
  local markup = CreateTextureMarkup(k,32, 32, 16, 16, 0, 1, 0, 1)
  rawset(t,k,markup)
  return markup
end})
local item_cache = {}

function bepgp_tokens_lk:GetReward(token)
  local reward = rewards[token]
  if reward then
    local count = #reward
    if count > 1 then
      return reward -- array
    elseif count == 1 then
      return reward[1] -- number
    end
  end
end

function bepgp_tokens_lk:GetToken(reward)
  return tokens[reward] or nil
end

function bepgp_tokens_lk:RewardItemString(tokenItem)
  if not (type(tokenItem)=="number" or type(tokenItem)=="string") then return end
  local tokenID = GetItemInfoInstant(tokenItem)
  if not tokenID then return end
  local rewardID = last_reward_flipped[tokenID]
  if rewardID then
    if item_cache[rewardID] then
      return item_cache[rewardID]
    else
      local rewardAsync = Item:CreateFromItemID(rewardID)
      rewardAsync:ContinueOnItemLoad(function()
        local link = rewardAsync:GetItemLink()
        item_cache[rewardID] = link
      end)
      return format("item:%d",rewardID)
    end
  end
end

function bepgp_tokens_lk:TokensItemString(rewardItem)
  if not (type(rewardItem)=="number" or type(rewardItem)=="string") then return end
  local rewardID = GetItemInfoInstant(rewardItem)
  if not rewardID then return end
  local tokenID = tokens[rewardID]
  if tokenID then
    if token_info[rewardID] and token_info[rewardID].done then
      if not token_info_string[rewardID] then
        token_info_string[rewardID] = token_info[rewardID].link
      end
      last_reward_flipped[tokenID] = rewardID
      return token_info_string[rewardID], tokenID
    else
      bepgp_tokens_lk:cacheRequiredToken(tokenID, rewardID)
      return format("item:%d",tokenID), tokenID
    end
  end
end

function bepgp_tokens_lk:cacheRequiredToken(tokenID,rewardID)
  local tokenAsync = Item:CreateFromItemID(tokenID)
  tokenAsync:ContinueOnItemLoad(function()
    local itemName = tokenAsync:GetItemName()
    local itemLink = tokenAsync:GetItemLink()
    local itemIcon = tokenAsync:GetItemIcon()
    token_info[rewardID] = {name=itemName,link=itemLink,icon=itemIcon}
    token_info[rewardID].done = true
  end)
end

function bepgp_tokens_lk:cacheTokens()
  for tokenID, rewardData in pairs(rewards) do
    for _, rewardID in pairs(rewardData) do
      tokens[rewardID] = tokenID
    end
  end
end

function bepgp_tokens_lk:delayInit()
  for rewardID, tokenID in pairs(tokens) do
    self:cacheRequiredToken(tokenID,rewardID)
  end
  self._initDone = true
end

function bepgp_tokens_lk:CoreInit()
  self:cacheTokens()
  bepgp.TokensItemString = self.TokensItemString
  bepgp.RewardItemString = self.RewardItemString
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_tokens_lk:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end
