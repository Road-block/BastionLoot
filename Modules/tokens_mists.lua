local addonName, bepgp = ...
local moduleName = addonName.."_tokens_mists"
local bepgp_tokens_mists = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local tokens = {} -- item = token
local rewards = {} -- token = items
local last_reward_flipped = {} -- token = reward
local item_upgrades = {} -- baseitemid = token

-- T14
rewards[89234] = { 85301, 85316,85336, 85377, 85357,85381,85307,85311 } -- helm-of-the-shadowy-vanquisher
rewards[89235] = { 85341,85321,85346, 85365,85362, 85370 } -- helm-of-the-shadowy-conqueror
rewards[89236] = { 85333,85326, 85296, 85351,85291,85286, 85386,85390,85396 } -- helm-of-the-shadowy-protector
rewards[89237] = { 85343,85323,85348, 85367,85360, 85372 } -- chest-of-the-shadowy-conqueror
rewards[89238] = { 85332,85328, 85298, 85353,85289,85288, 85388,85392,85394 } -- chest-of-the-shadowy-protector
rewards[89239] = { 85303, 85318,85338, 85375, 85355,85379,85305,85313 } -- chest-of-the-shadowy-vanquisher
rewards[89240] = { 85342,85322,85347, 85364,85363, 85369 } -- gauntlets-of-the-shadowy-conqueror
rewards[89241] = { 85331,85327, 85297, 85352,85290,85287, 85387,85389,85395 } -- gauntlets-of-the-shadowy-protector
rewards[89242] = { 85302, 85317,85337, 85378, 85358,85380,85308,85312 } -- gauntlets-of-the-shadowy-vanquisher
rewards[89243] = { 85340,85320,85345, 85366,85361, 85371 } -- leggings-of-the-shadowy-conqueror
rewards[89244] = { 85330,85325, 85295, 85350,85292,85285, 85385,85391,85397 } -- leggings-of-the-shadowy-protector
rewards[89245] = { 85300, 85315,85335, 85376, 85356,85382,85306,85310 } -- leggings-of-the-shadowy-vanquisher
rewards[89246] = { 85339,85319,85344, 85368,85359, 85373 } -- shoulders-of-the-shadowy-conqueror
rewards[89247] = { 85329,85324, 85294, 85349,85293,85284, 85384,85393,85398 } -- shoulders-of-the-shadowy-protector
rewards[89248] = { 85299, 85314,85334, 85374, 85354,85383,85304,85309 } -- shoulders-of-the-shadowy-vanquisher
rewards[89249] = { 87124, 86918,86913, 87010, 86936,86938,86923,86931 } -- chest-of-the-shadowy-vanquisher
rewards[89250] = { 87104,87099,87109, 87117,87122, 87190 } -- chest-of-the-shadowy-conqueror
rewards[89251] = { 87193,87197, 87002, 87134,87139,87129, 87094,87084,87092 } -- chest-of-the-shadowy-protector
rewards[89252] = { 87127, 86921,86916, 87009, 86935,86941,86926,85930 } -- leggings-of-the-shadowy-vanquisher
rewards[89253] = { 87107,87102,87112, 87116,87121, 87189 } -- leggings-of-the-shadowy-conqueror
rewards[89254] = { 87195,87200, 87005, 87137,87142,87132, 87097,87087,87091 } -- leggings-of-the-shadowy-protector
rewards[89255] = { 87125, 86919,86914, 87007, 86933,86939,86924,86928 } -- gauntlets-of-the-shadowy-vanquisher
rewards[89256] = { 87105,87100,87110, 87114,87119, 87187 } -- gauntlets-of-the-shadowy-conqueror
rewards[89257] = { 87194,87198, 87003, 87135,87140,87130, 87095,87085,87089 } -- gauntlets-of-the-shadowy-protector
rewards[89258] = { 87126, 86920,86915, 87008, 86934,86940,85925,86929 } -- helm-of-the-shadowy-vanquisher
rewards[89259] = { 87106,87101,87111, 87115,87120, 87188 } -- helm-of-the-shadowy-conqueror
rewards[89260] = { 87192,87199, 87004, 87136,87141,87131, 87096,87086,87090 } -- helm-of-the-shadowy-protector
rewards[89261] = { 87128, 86922,86917, 87011, 86937,86942,86927,86932 } -- shoulders-of-the-shadowy-vanquisher
rewards[89262] = { 87108,87103,87113, 87118,87123, 87191 } -- shoulders-of-the-shadowy-conqueror
rewards[89263] = { 87196,87201, 87006, 87138,87143,87133, 87098,87088,87093 } -- shoulders-of-the-shadowy-protector
rewards[89264] = {} -- chest-of-the-shadowy-vanquisher
rewards[89265] = {} -- chest-of-the-shadowy-conqueror
rewards[89266] = {} -- chest-of-the-shadowy-protector
rewards[89267] = {} -- leggings-of-the-shadowy-vanquisher
rewards[89268] = {} -- leggings-of-the-shadowy-conqueror
rewards[89269] = {} -- leggings-of-the-shadowy-protector
rewards[89270] = {} -- gauntlets-of-the-shadowy-vanquisher
rewards[89271] = {} -- gauntlets-of-the-shadowy-conqueror
rewards[89272] = {} -- gauntlets-of-the-shadowy-protector
rewards[89273] = {} -- helm-of-the-shadowy-vanquisher
rewards[89274] = {} -- helm-of-the-shadowy-conqueror
rewards[89275] = {} -- helm-of-the-shadowy-protector
rewards[89276] = {} -- shoulders-of-the-shadowy-vanquisher
rewards[89277] = {} -- shoulders-of-the-shadowy-conqueror
rewards[89278] = {} -- shoulders-of-the-shadowy-protector
-- T15
rewards[95569] = { 95305, 95225,95230, 95263, 95250,95248,95243,95235 } -- chest-of-the-crackling-vanquisher
rewards[95570] = { 95306, 95226,95231, 95260, 95251,95245,95240,95236 } -- gauntlets-of-the-crackling-vanquisher
rewards[95571] = { 95307, 95227,95232, 95261, 95252,95246,95241,95237 } -- helm-of-the-crackling-vanquisher
rewards[95572] = { 95308, 95228,95233, 95262, 95253,95247,95242,95238 } -- leggings-of-the-crackling-vanquisher
rewards[95573] = { 95309, 95229,95234, 95264, 95254,95249,95244,95239 } -- shoulders-of-the-crackling-vanquisher
rewards[95574] = { 95290,95280,95285, 95298,95303, 95328 } -- chest-of-the-crackling-conqueror
rewards[95575] = { 95291,95281,95286, 95295,95300, 95325 } -- gauntlets-of-the-crackling-conqueror
rewards[95576] = { 95293,95283,95288, 95297,95302, 95327 } -- leggings-of-the-crackling-conqueror
rewards[95577] = { 95292,95282,95287, 95296,95301, 95326 } -- helm-of-the-crackling-conqueror
rewards[95578] = { 95294,95284,95289, 95299,95304, 95329 } -- shoulders-of-the-crackling-conqueror
rewards[95579] = { 95331,95335, 95255, 95315,95320,95310, 95275,95273,95265 } -- chest-of-the-crackling-protector
rewards[95580] = { 95332,95336, 95256, 95316,95321,95311, 95276,95270,95266 } -- gauntlets-of-the-crackling-protector
rewards[95581] = { 95333,95338, 95258, 95318,95323,95313, 95278,95272,95268 } -- leggings-of-the-crackling-protector
rewards[95582] = { 95330,95337, 95257, 95317,95322,95312, 95277,95271,95267 } -- helm-of-the-crackling-protector
rewards[95583] = { 95334,95339, 95259, 95319,95324,95314, 95279,95274,95269 } -- shoulders-of-the-crackling-protector
rewards[95822] = {} -- chest-of-the-crackling-vanquisher
rewards[95823] = {} -- chest-of-the-crackling-conqueror
rewards[95824] = {} -- chest-of-the-crackling-protector
rewards[95855] = {} -- gauntlets-of-the-crackling-vanquisher
rewards[95856] = {} -- gauntlets-of-the-crackling-conqueror
rewards[95857] = {} -- gauntlets-of-the-crackling-protector
rewards[95879] = {} -- helm-of-the-crackling-vanquisher
rewards[95880] = {} -- helm-of-the-crackling-conqueror
rewards[95881] = {} -- helm-of-the-crackling-protector
rewards[95887] = {} -- leggings-of-the-crackling-vanquisher
rewards[95888] = {} -- leggings-of-the-crackling-conqueror
rewards[95889] = {} -- leggings-of-the-crackling-protector
rewards[95955] = {} -- shoulders-of-the-crackling-vanquisher
rewards[95956] = {} -- shoulders-of-the-crackling-conqueror
rewards[95957] = {} -- shoulders-of-the-crackling-protector
rewards[96194] = {} -- chest-of-the-crackling-vanquisher
rewards[96195] = {} -- chest-of-the-crackling-conqueror
rewards[96196] = {} -- chest-of-the-crackling-protector
rewards[96227] = {} -- gauntlets-of-the-crackling-vanquisher
rewards[96228] = {} -- gauntlets-of-the-crackling-conqueror
rewards[96229] = {} -- gauntlets-of-the-crackling-protector
rewards[96251] = {} -- helm-of-the-crackling-vanquisher
rewards[96252] = {} -- helm-of-the-crackling-conqueror
rewards[96253] = {} -- helm-of-the-crackling-protector
rewards[96259] = {} -- leggings-of-the-crackling-vanquisher
rewards[96260] = {} -- leggings-of-the-crackling-conqueror
rewards[96261] = {} -- leggings-of-the-crackling-protector
rewards[96327] = {} -- shoulders-of-the-crackling-vanquisher
rewards[96328] = {} -- shoulders-of-the-crackling-conqueror
rewards[96329] = {} -- shoulders-of-the-crackling-protector
rewards[96566] = { 96679, 96569,96574, 96637, 96579,96587,96594,96592 } -- chest-of-the-crackling-vanquisher
rewards[96567] = { 96664,96654,96659, 96672,96677, 96728 } -- chest-of-the-crackling-conqueror
rewards[96568] = { 96735,96731, 96626, 96684,96689,96694, 96647,96649,96639 } -- chest-of-the-crackling-protector
rewards[96599] = { 96680, 96570,96575, 96634, 96584,96580,96589,96595 } -- gauntlets-of-the-crackling-vanquisher
rewards[96600] = { 96665,96655,96660, 96674,96669, 96725 } -- gauntlets-of-the-crackling-conqueror
rewards[96601] = { 96732,96736, 96627, 96695,96690,96685, 96650,96644,96640 } -- gauntlets-of-the-crackling-protector
rewards[96623] = { 96681, 96571,96576, 96635, 96585,96581,96590,96596 } -- helm-of-the-crackling-vanquisher
rewards[96624] = { 96666,96656,96661, 96670,96675, 96726 } -- helm-of-the-crackling-conqueror
rewards[96625] = { 96730,96737, 96628, 96686,96696,96691, 96651,96645,96641 } -- helm-of-the-crackling-protector
rewards[96631] = { 96682, 96577,96572, 96636, 96597,96582,96586,96591 } -- leggings-of-the-crackling-vanquisher
rewards[96632] = { 96662,96667,96657, 96671,96676, 96727 } -- leggings-of-the-crackling-conqueror
rewards[96633] = { 96738,96733, 96629, 96687,96697,96692, 96642,96646,96652 } -- leggings-of-the-crackling-protector
rewards[96699] = { 96683, 96573,96578, 96638, 96593,96583,96588,96598 } -- shoulders-of-the-crackling-vanquisher
rewards[96700] = { 96658,96663,96668, 96673,96678, 96729 } -- shoulders-of-the-crackling-conqueror
rewards[96701] = { 96734,96739, 96630, 96688,96693,96698, 96653,96648,96643 } -- shoulders-of-the-crackling-protector
rewards[96938] = {} -- chest-of-the-crackling-vanquisher
rewards[96939] = {} -- chest-of-the-crackling-conqueror
rewards[96940] = {} -- chest-of-the-crackling-protector
rewards[96971] = {} -- gauntlets-of-the-crackling-vanquisher
rewards[96972] = {} -- gauntlets-of-the-crackling-conqueror
rewards[96973] = {} -- gauntlets-of-the-crackling-protector
rewards[96995] = {} -- helm-of-the-crackling-vanquisher
rewards[96996] = {} -- helm-of-the-crackling-conqueror
rewards[96997] = {} -- helm-of-the-crackling-protector
rewards[97003] = {} -- leggings-of-the-crackling-vanquisher
rewards[97004] = {} -- leggings-of-the-crackling-conqueror
rewards[97005] = {} -- leggings-of-the-crackling-protector
rewards[97071] = {} -- shoulders-of-the-crackling-vanquisher
rewards[97072] = {} -- shoulders-of-the-crackling-conqueror
rewards[97073] = {} -- shoulders-of-the-crackling-protector
-- T16
rewards[99667] = {} -- gauntlets-of-the-cursed-protector
rewards[99668] = {} -- shoulders-of-the-cursed-vanquisher
rewards[99669] = {} -- shoulders-of-the-cursed-conqueror
rewards[99670] = {} -- shoulders-of-the-cursed-protector
rewards[99671] = {} -- helm-of-the-cursed-vanquisher
rewards[99672] = {} -- helm-of-the-cursed-conqueror
rewards[99673] = {} -- helm-of-the-cursed-protector
rewards[99674] = {} -- leggings-of-the-cursed-vanquisher
rewards[99675] = {} -- leggings-of-the-cursed-conqueror
rewards[99676] = {} -- leggings-of-the-cursed-protector
rewards[99677] = {} -- chest-of-the-cursed-vanquisher
rewards[99678] = {} -- chest-of-the-cursed-conqueror
rewards[99679] = {} -- chest-of-the-cursed-protector
rewards[99680] = {} -- gauntlets-of-the-cursed-vanquisher
rewards[99681] = {} -- gauntlets-of-the-cursed-conqueror
rewards[99682] = { 99113, 99189,99193, 99160, 99181,99163,99185,99174 } -- gauntlets-of-the-cursed-vanquisher
rewards[99683] = { 99114, 99194,99190, 99161, 99164,99175,99182,99178 } -- helm-of-the-cursed-vanquisher
rewards[99684] = { 99115, 99191,99186, 99162, 99176,99183,99165,99171 } -- leggings-of-the-cursed-vanquisher
rewards[99685] = { 99116, 99187,99179, 99153, 99184,99166,99169,99173 } -- shoulders-of-the-cursed-vanquisher
rewards[99686] = { 99136,99126,99133, 99110,99119, 99204 } -- chest-of-the-cursed-conqueror
rewards[99687] = { 99137,99127,99134, 99121,99131, 99096 } -- gauntlets-of-the-cursed-conqueror
rewards[99688] = { 99124,99129,99139, 99118,99123, 99098 } -- leggings-of-the-cursed-conqueror
rewards[99689] = { 99128,99138,99135, 99117,99122, 99097 } -- helm-of-the-cursed-conqueror
rewards[99690] = { 99125,99132,99130, 99111,99120, 99205 } -- shoulders-of-the-cursed-conqueror
rewards[99691] = { 99197,99201, 99167, 99101,99107,99106, 99150,99140,99154 } -- chest-of-the-cursed-protector
rewards[99692] = { 99202,99198, 99168, 99092,99102,99108, 99141,99155,99147 } -- gauntlets-of-the-cursed-protector
rewards[99693] = { 99195,99199, 99158, 99099,99104,99094, 99149,99145,99143 } -- leggings-of-the-cursed-protector
rewards[99694] = { 99206,99203, 99157, 99093,99109,99103, 99142,99148,99156 } -- helm-of-the-cursed-protector
rewards[99695] = { 99196,99200, 99159, 99095,99105,99100, 99151,99144,99146 } -- shoulders-of-the-cursed-protector
rewards[99696] = { 99112, 99188,99192, 99152, 99170,99177,99180,99172 } -- chest-of-the-cursed-vanquisher
rewards[99697] = {} -- helm-of-the-cursed-protector
rewards[99698] = {} -- leggings-of-the-cursed-vanquisher
rewards[99699] = {} -- leggings-of-the-cursed-conqueror
rewards[99700] = {} -- leggings-of-the-cursed-protector
rewards[99701] = {} -- shoulders-of-the-cursed-vanquisher
rewards[99702] = {} -- gauntlets-of-the-cursed-vanquisher
rewards[99703] = {} -- gauntlets-of-the-cursed-conqueror
rewards[99704] = {} -- gauntlets-of-the-cursed-protector
rewards[99705] = {} -- helm-of-the-cursed-vanquisher
rewards[99706] = {} -- helm-of-the-cursed-conqueror
rewards[99707] = {} -- shoulders-of-the-cursed-conqueror
rewards[99708] = {} -- shoulders-of-the-cursed-protector
rewards[99709] = {} -- chest-of-the-cursed-vanquisher
rewards[99710] = {} -- chest-of-the-cursed-conqueror
rewards[99711] = {} -- chest-of-the-cursed-protector
rewards[99712] = { 99371,99372,99377, 99361,99367, 99426 } -- leggings-of-the-cursed-conqueror
rewards[99713] = { 99410,99413, 99403, 99342,99333,99354, 99385,99394,99390 } -- leggings-of-the-cursed-protector
rewards[99714] = { 99356, 99330,99335, 99400, 99326,99419,99430,99427 } -- chest-of-the-cursed-vanquisher
rewards[99715] = { 99374,99387,99368, 99362,99357, 99416 } -- chest-of-the-cursed-conqueror
rewards[99716] = { 99415,99411, 99405, 99351,99344,99347, 99382,99391,99396 } -- chest-of-the-cursed-protector
rewards[99717] = { 99350, 99325,99339, 99401, 99428,99423,99431,99322 } -- shoulders-of-the-cursed-vanquisher
rewards[99718] = { 99364,99373,99378, 99358,99363, 99417 } -- shoulders-of-the-cursed-conqueror
rewards[99719] = { 99414,99407, 99404, 99346,99343,99334, 99381,99395,99386 } -- shoulders-of-the-cursed-protector
rewards[99720] = { 99355, 99336,99331, 99397, 99327,99432,99435,99420 } -- gauntlets-of-the-cursed-vanquisher
rewards[99721] = { 99369,99375,99380, 99359,99365, 99424 } -- gauntlets-of-the-cursed-conqueror
rewards[99722] = { 99412,99408, 99406, 99352,99340,99345, 99392,99383,99388 } -- gauntlets-of-the-cursed-protector
rewards[99723] = { 99348, 99337,99323, 99398, 99346,99421,99433,99328 } -- helm-of-the-cursed-vanquisher
rewards[99724] = { 99376,99370,99379, 99360,99366, 99425 } -- helm-of-the-cursed-conqueror
rewards[99725] = { 99418,99409, 99402, 99353,99332,99341, 99384,99393,99389 } -- helm-of-the-cursed-protector
rewards[99726] = { 99349, 99338,99324, 99399, 99434,99329,99422,99429 } -- leggings-of-the-cursed-vanquisher
rewards[99727] = {} -- chest-of-the-cursed-vanquisher
rewards[99728] = {} -- chest-of-the-cursed-conqueror
rewards[99729] = {} -- chest-of-the-cursed-protector
rewards[99730] = {} -- shoulders-of-the-cursed-vanquisher
rewards[99731] = {} -- shoulders-of-the-cursed-conqueror
rewards[99732] = {} -- shoulders-of-the-cursed-protector
rewards[99733] = {} -- gauntlets-of-the-cursed-protector
rewards[99734] = {} -- helm-of-the-cursed-vanquisher
rewards[99735] = {} -- helm-of-the-cursed-conqueror
rewards[99736] = {} -- helm-of-the-cursed-protector
rewards[99737] = {} -- leggings-of-the-cursed-vanquisher
rewards[99738] = {} -- leggings-of-the-cursed-conqueror
rewards[99739] = {} -- leggings-of-the-cursed-protector
rewards[99740] = {} -- gauntlets-of-the-cursed-vanquisher
rewards[99741] = {} -- gauntlets-of-the-cursed-conqueror
rewards[99742] = { 99629, 99640,99608, 99658, 99582,99622,99632,99620 } -- chest-of-the-cursed-vanquisher
rewards[99743] = { 99598,99566,99626, 99584,99627, 99570 } -- chest-of-the-cursed-conqueror
rewards[99744] = { 99562,99603, 99577, 99579,99636,99615, 99555,99643,99641 } -- chest-of-the-cursed-protector
rewards[99745] = { 99630, 99604,99609, 99575, 99633,99623,99637,99617 } -- gauntlets-of-the-cursed-vanquisher
rewards[99746] = { 99625,99648,99595, 99586,99590, 99567 } -- gauntlets-of-the-cursed-conqueror
rewards[99747] = { 99563,99559, 99578, 99611,99580,99616, 99552,99644,99556 } -- gauntlets-of-the-cursed-protector
rewards[99748] = { 99631, 99571,99605, 99576, 99618,99599,99624,99638 } -- helm-of-the-cursed-vanquisher
rewards[99749] = { 99596,99665,99651, 99591,99587, 99568 } -- helm-of-the-cursed-conqueror
rewards[99750] = { 99557,99602, 99660, 99612,99649,99645, 99653,99607,99553 } -- helm-of-the-cursed-protector
rewards[99751] = { 99634, 99572,99564, 99657, 99581,99610,99619,99600 } -- leggings-of-the-cursed-vanquisher
rewards[99752] = { 99593,99661,99666, 99588,99592, 99569 } -- leggings-of-the-cursed-conqueror
rewards[99753] = { 99558,99560, 99573, 99613,99646,99650, 99606,99554,99654 } -- leggings-of-the-cursed-protector
rewards[99754] = { 99635, 99652,99639, 99659, 99621,99589,99664,99583 } -- shoulders-of-the-cursed-vanquisher
rewards[99755] = { 99594,99662,99656, 99628,99585, 99601 } -- shoulders-of-the-cursed-conqueror
rewards[99756] = { 99597,99561, 99574, 99647,99663,99614, 99642,99565,99655 } -- shoulders-of-the-cursed-protector
rewards[105857] = { 99691,99692,99693,99694,99695 } -- essence-of-the-cursed-protector
rewards[105858] = { 99686,99687,99688,99689,99690 } -- essence-of-the-cursed-conqueror
rewards[105859] = { 99682,99683,99684,99685,99696 } -- essence-of-the-cursed-vanquisher
rewards[105860] = { 99667,99670,99673,99676,99679 } -- essence-of-the-cursed-protector
rewards[105861] = { 99669,99672,99675,99678,99681 } -- essence-of-the-cursed-conqueror
rewards[105862] = { 99668,99671,99674,99677,99680 } -- essence-of-the-cursed-vanquisher
rewards[105863] = { 99744,99747,99750,99753,99756 } -- essence-of-the-cursed-protector
rewards[105864] = { 99743,99746,99749,99752,99755 } -- essence-of-the-cursed-conqueror
rewards[105865] = { 99742,99745,99748,99751,99754 } -- essence-of-the-cursed-vanquisher
rewards[105866] = { 99713,99716,99719,99722,99725 } -- essence-of-the-cursed-protector
rewards[105867] = { 99712,99715,99718,99721,99724 } -- essence-of-the-cursed-conqueror
rewards[105868] = { 99714,99717,99720,99723,99726 } -- essence-of-the-cursed-vanquisher

local token_info = {}
local token_info_string = {}
local item_icon_markup = setmetatable({},{__index = function(t,k)
  local markup = CreateTextureMarkup(k,32, 32, 16, 16, 0, 1, 0, 1)
  rawset(t,k,markup)
  return markup
end})
local item_cache = {}

function bepgp_tokens_mists:GetReward(token)
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

function bepgp_tokens_mists:GetToken(reward)
  return tokens[reward] or nil
end

function bepgp_tokens_mists:ItemUpgradeString(baseItem)
  if not (type(baseItem)=="number" or type(baseItem)=="string") then return end
  local baseitemID = bepgp.GetItemInfoInstant(baseItem)
  if not baseitemID then return end
  local tokenID = item_upgrades[baseitemID]
  if not tokenID then return end
  local _,_,_,_,icon = bepgp.GetItemInfoInstant(tokenID)
  local markup = item_icon_markup[icon]
  return string.format("%s +%s",L["|cff00ff00Upgradeable:|r"],(markup or tokenID))
end

function bepgp_tokens_mists:RewardItemString(tokenItem)
  if not (type(tokenItem)=="number" or type(tokenItem)=="string") then return end
  local tokenID = bepgp.GetItemInfoInstant(tokenItem)
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

function bepgp_tokens_mists:TokensItemString(rewardItem)
  if not (type(rewardItem)=="number" or type(rewardItem)=="string") then return end
  local rewardID = bepgp.GetItemInfoInstant(rewardItem)
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
      bepgp_tokens_mists:cacheRequiredToken(tokenID, rewardID)
      return format("item:%d",tokenID), tokenID
    end
  end
end

function bepgp_tokens_mists:cacheRequiredToken(tokenID,rewardID)
  local tokenAsync = Item:CreateFromItemID(tokenID)
  tokenAsync:ContinueOnItemLoad(function()
    local itemName = tokenAsync:GetItemName()
    local itemLink = tokenAsync:GetItemLink()
    local itemIcon = tokenAsync:GetItemIcon()
    token_info[rewardID] = {name=itemName,link=itemLink,icon=itemIcon}
    token_info[rewardID].done = true
  end)
end

function bepgp_tokens_mists:cacheTokens()
  for tokenID, rewardData in pairs(rewards) do
    for _, rewardID in pairs(rewardData) do
      tokens[rewardID] = tokenID
    end
  end
end

function bepgp_tokens_mists:delayInit()
  for rewardID, tokenID in pairs(tokens) do
    self:cacheRequiredToken(tokenID,rewardID)
  end
  self._initDone = true
end

function bepgp_tokens_mists:CoreInit()
  self:cacheTokens()
  bepgp.TokensItemString = self.TokensItemString
  bepgp.RewardItemString = self.RewardItemString
  bepgp.ItemUpgradeString = self.ItemUpgradeString
  if not self._initDone then
    self:delayInit()
  end
end

function bepgp_tokens_mists:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
end
