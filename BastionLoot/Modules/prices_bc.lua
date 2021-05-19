local addonName, bepgp = ...
local moduleName = addonName.."_prices_bc"
local bepgp_prices_bc = bepgp:NewModule(moduleName, "AceEvent-3.0")
local ST = LibStub("ScrollingTable")
local name_version = "BastionEPGPFixed_bc-1.0"
local prices = {}

--[[TODO
Compile lists by
- armor class
- role
- class/spec
- droprate
- itempower
]]

-- Karazhan (IL115-125)
--- Trash
prices[30643] = {1, "T4"} -- Belt of the tracker (Mail - caster)
prices[30641] = {1, "T4"} -- Boots of Elusion (Plate - tank)
prices[30642] = {1, "T4"} -- Drape of the Righteous (Cloth - Holy dmg)
prices[30668] = {1, "T4"} -- Grasp of the Dead (Cloth - Frost dmg)
prices[30644] = {1, "T4"} -- Grips of Deftness (Leather - melee dps)
prices[30673] = {1, "T4"} -- Inferno Waist Cord (Cloth - Fire dmg)
prices[30667] = {1, "T4"} -- Ring of Unrelenting Storms (Nature dmg)
prices[30666] = {1, "T4"} -- Ritssyn's Lost Pendant (Shadow dmg)
prices[30674] = {1, "T4"} -- Zierhut's Lost Treads (Leather - tank)
--- Attumen
prices[28453] = {1, "T4"} -- Bracers of the White Stag (Leather - caster)
prices[30480] = {0, "T4"} -- Fiery Warhorse's Reins (mount)
prices[28505] = {1, "T4"} -- Gauntlets of Renewed Hope (Plate - heal)
prices[28506] = {1, "T4"} -- Gloves of Dexterous Manipulation (Leather - melee dps)
prices[28508] = {1, "T4"} -- Gloves of Saintly Blessings (Cloth - heal)
prices[28507] = {1, "T4"} -- Handwraps of Flowing Thought (Cloth - caster)
prices[28477] = {1, "T4"} -- Harbinger Bands (Cloth - caster)
prices[28510] = {1, "T4"} -- Spectral Band of Innervation (caster)
prices[28454] = {1, "T4"} -- Stalker's War Bands (Mail - physical)
prices[28504] = {1, "T4"} -- Steelhawk Crossbow (xbow - physical)
prices[28502] = {1, "T4"} -- Vambraces of Courage (plate - tank)
prices[28503] = {1, "T4"} -- Whirlwind Bracers (mail - heal)
prices[28509] = {1, "T4"} -- Worgen Claw Necklace (physical)
--- Moroes
prices[28567] = {1, "T4"} -- Belt of Gale Force (Mail - heal)
prices[28569] = {1, "T4"} -- Boots of Valiance (Plate - heal)
prices[28530] = {1, "T4"} -- Brooch of Unquenchable Fury (caster)
prices[28566] = {1, "T4"} -- Crimson Girdle of the Indomitable (Plate - tank)
prices[28545] = {1, "T4"} -- Edgewalker Longboots (Leather - melee dps)
prices[28524] = {1, "T4"} -- Emerald Ripper (physical)
prices[28568] = {1, "T4"} -- Idol of the Avian Heart (Druid - heal)
prices[28528] = {1, "T4"} -- Moroes' Lucky Pocket Watch (tank)
prices[28565] = {1, "T4"} -- Nethershard Girdle (Cloth - caster)
prices[28529] = {1, "T4"} -- Royal Cloak of Arathi Kings (Cloth - melee dps)
prices[28570] = {1, "T4"} -- Shadow-Cloak of Dalaran (Cloth - caster)
prices[28525] = {1, "T4"} -- Signet of Unshakable Faith (heal)
--- Maiden of Virtue
prices[28511] = {1, "T4"} -- Bands of Indwelling (Cloth - heal)
prices[28515] = {1, "T4"} -- Bands of Nefarious Deeds (Cloth - caster)
prices[28516] = {1, "T4"} -- Barbed Choker of Discipline (tank)
prices[28517] = {1, "T4"} -- Boots of Foretelling (Cloth - caster)
prices[28512] = {1, "T4"} -- Bracers of Justice (Plate - heal)
prices[28514] = {1, "T4"} -- Bracers of Maliciousness (Leather - melee dps)
prices[28520] = {1, "T4"} -- Gloves of Centering (Mail - heal)
prices[28519] = {1, "T4"} -- Gloves of Quickening (Mail - Caster)
prices[28518] = {1, "T4"} -- Iron Gauntlets of the Maiden (Plate - tank)
prices[28521] = {1, "T4"} -- Mitts of the Treemender (Leather - heal)
prices[28522] = {1, "T4"} -- Shard of the Virtuous (Mace - heal)
prices[28523] = {1, "T4"} -- Totem of Healing Rains (Shaman - heal)
--- Opera Event
---- Crone
prices[28588] = {1, "T4"} -- Blue Diamond Witchwand (heal)
prices[28587] = {1, "T4"} -- Legacy (2H Axe - physical)
prices[28585] = {1, "T4"} -- Ruby Slippers (Cloth - caster - hearthstone)
prices[28586] = {1, "T4"} -- Wicked Witch's Hat (Cloth - caster)
---- Wolf
prices[28583] = {1, "T4"} -- Big Bad Wolf's Head (Mail - caster)
prices[28584] = {1, "T4"} -- Big Bad Wolf's Paw (physical)
prices[28582] = {1, "T4"} -- Red Riding Hood's Cloak (Cloth - heal)
prices[28581] = {1, "T4"} -- Wolfslayer Sniper Rifle (Hunter)
---- Romulo & Juliane
prices[28572] = {1, "T4"} -- Blade of the Unrequited (physical)
prices[28573] = {1, "T4"} -- Despair (melee dps)
prices[28578] = {1, "T4"} -- Masquerade Gown (Cloth - heal)
prices[28579] = {1, "T4"} -- Romulo's Poison Vial (physical)
---- Shared
prices[28589] = {1, "T4"} -- Beastmaw Pauldrons (Mail - dps)
prices[28591] = {1, "T4"} -- Earthsoul Leggings (Leather - heal)
prices[28593] = {1, "T4"} -- Eternium Greathelm (Plate - tank)
prices[28592] = {1, "T4"} -- Libram of Souls Redeemed (Paladin - heal)
prices[28590] = {1, "T4"} -- Ribbon of Sacrifice (heal)
prices[28594] = {1, "T4"} -- Trial-Fire Trousers (Cloth - caster)
--- Curator
prices[28631] = {1, "T4"} -- Dragon-Quake Shoulderguards (Mail - heal)
prices[28647] = {1, "T4"} -- Forest Wind Shoulderpads (Leather - heal)
prices[28649] = {1, "T4"} -- Garona's Signet Ring (physical)
prices[28612] = {1, "T4"} -- Pauldrons of the Solace-Giver (Cloth - heal)
prices[28633] = {1, "T4"} -- Staff of Infinite Mysteries (caster)
prices[28621] = {1, "T4"} -- Wrynn Dynasty Greaves (Plate - tank)
prices[29757] = {1, "T4"} -- Gloves of the Fallen Champion (T4 Gloves shaman/rogue/pala)
prices[29032] = {1, "T4"} -- Shaman T4 Gloves
prices[29034] = {1, "T4"} -- Shaman
prices[29039] = {1, "T4"} -- Shaman
prices[29048] = {1, "T4"} -- Rogue T4 Gloves
prices[29065] = {1, "T4"} -- Paladin T4 Gloves
prices[29067] = {1, "T4"} -- Paladin
prices[29072] = {1, "T4"} -- Paladin
prices[29758] = {1, "T4"} -- Gloves of the Fallen Defender (T4 Gloves warrior/priest/druid)
prices[29017] = {1, "T4"} -- Warrior T4 Gloves
prices[29020] = {1, "T4"} --
prices[29055] = {1, "T4"} -- Priest T4 Gloves
prices[29057] = {1, "T4"} --
prices[29090] = {1, "T4"} -- Druid T4 Gloves
prices[29092] = {1, "T4"} --
prices[29097] = {1, "T4"} --
prices[29756] = {1, "T4"} -- Gloves of the Fallen Hero (T4 Gloves hunter/mage/warlock)
prices[28968] = {1, "T4"} -- Warlock T4 Gloves
prices[29080] = {1, "T4"} -- Mage T4 Gloves
prices[29085] = {1, "T4"} -- Hunter T4 Gloves
--- Illhoof
prices[28662] = {1, "T4"} -- Breastplate of the Lightbinder (Plate - heal)
prices[28652] = {1, "T4"} -- Cincture of Will (Cloth - heal)
prices[28655] = {1, "T4"} -- Cord of Nature's Sustenance (Leather - heal)
prices[28657] = {1, "T4"} -- Fool's Bane (physical)
prices[28660] = {1, "T4"} -- Gilded Thorium Cloak (Bear > Tank)
prices[28656] = {1, "T4"} -- Girdle of the Prowler (Mail - physical)
prices[28654] = {1, "T4"} -- Malefic Girdle (Cloth - caster)
prices[28661] = {1, "T4"} -- Mender's Heart-Ring (heal)
prices[28653] = {1, "T4"} -- Shadowvine Cloak of Infusion (heal)
prices[28658] = {1, "T4"} -- Terestian's Stranglestaff (druid)
prices[28785] = {1, "T4"} -- The Lightning Capacitor (caster)
prices[28659] = {1, "T4"} -- Xavian Stiletto (melee)
--- Aran
prices[28728] = {1, "T4"} -- Aran's Soothing Sapphire (heal)
prices[28663] = {1, "T4"} -- Boots of the Incorrupt (Cloth - heal)
prices[28670] = {1, "T4"} -- Boots of the Infernal Coven (Cloth - caster)
prices[28672] = {1, "T4"} -- Drape of the Dark Reavers (Cloth - physical)
prices[28726] = {1, "T4"} -- Mantle of the Mind Flayer (Cloth - heal)
prices[28666] = {1, "T4"} -- Pauldrons of the Justice-Seeker (Plate - heal)
prices[28727] = {1, "T4"} -- Pendant of the Violet Eye (heal > caster)
prices[28669] = {1, "T4"} -- Rapscallion Boots (Leather - physical)
prices[28674] = {1, "T4"} -- Saberclaw Talisman (physical)
prices[28675] = {1, "T4"} -- Shermanar Great-Ring (Bear > Tank)
prices[28671] = {1, "T4"} -- Steelspine Faceguard (Mail - physical)
prices[28673] = {1, "T4"} -- Tirisfal Wand of Ascendancy (caster)
--- Chess
prices[28747] = {1, "T4"} -- Battlescar Boots (Plate - tank)
prices[28755] = {1, "T4"} -- Bladed Shoulderpads of the Merciless (Leather - physical)
prices[28746] = {1, "T4"} -- Fiend Slayer Boots (Mail - physical)
prices[28752] = {1, "T4"} -- Forestlord Striders (Leather - heal)
prices[28750] = {1, "T4"} -- Girdle of Treachery (Leather - physical)
prices[28756] = {1, "T4"} -- Headdress of the High Potentate (Cloth - heal)
prices[28751] = {1, "T4"} -- Heart-Flame Leggings (Mail - heal)
prices[28749] = {1, "T4"} -- King's Defender (Tank)
prices[28748] = {1, "T4"} -- Legplates of the Innocent (Plate - heal)
prices[28745] = {1, "T4"} -- Mithril Chain of Heroism (melee)
prices[28753] = {1, "T4"} -- Ring of Recurrence (caster)
prices[28754] = {1, "T4"} -- Triptych Shield of the Ancients (heal)
--- Netherspite
prices[28732] = {1, "T4"} -- Cowl of Defiance (Leather - physical)
prices[28735] = {1, "T4"} -- Earthblood Chestguard (Mail - heal)
prices[28733] = {1, "T4"} -- Girdle of Truth (Plate - heal)
prices[28734] = {1, "T4"} -- Jewel of Infinite Possibilities (caster)
prices[28743] = {1, "T4"} -- Mantle of Abrahmis (Plate - tank)
prices[28730] = {1, "T4"} -- Mithril Band of the Unscarred (melee)
prices[28742] = {1, "T4"} -- Pantaloons of Repentance (Cloth - heal)
prices[28740] = {1, "T4"} -- Rip-Flayer Leggings (Mail - physical)
prices[28731] = {1, "T4"} -- Shining Chain of the Afterworld (heal)
prices[28741] = {1, "T4"} -- Skulker's Greaves (Leather - physical)
prices[28729] = {1, "T4"} -- Spiteblade (physical)
prices[28744] = {1, "T4"} -- Uni-Mind Headdress (Cloth - caster)
--- Prince
prices[28762] = {1, "T4"} -- Adornment of Stolen Souls (caster)
prices[28764] = {1, "T4"} -- Farstrider Wildercloak (physical)
prices[28773] = {1, "T4"} -- Gorehowl (melee)
prices[28763] = {1, "T4"} -- Jade Ring of the Everliving (heal)
prices[28771] = {1, "T4"} -- Light's Justice (heal)
prices[28768] = {1, "T4"} -- Malchazeen (physical)
prices[28770] = {1, "T4"} -- Nathrezim Mindblade (caster)
prices[28757] = {1, "T4"} -- Ring of a Thousand Marks (physical)
prices[28766] = {1, "T4"} -- Ruby Drape of the Mysticant (caster)
prices[28765] = {1, "T4"} -- Stainless Cloak of the Pure Hearted (Cloth - heal)
prices[28772] = {1, "T4"} -- Sunfury Bow of the Phoenix (Hunter > physical)
prices[28767] = {1, "T4"} -- The Decapitator (melee)
prices[29760] = {1, "T4"} -- Helm of the Fallen Champion (T4 Head - pala/rogue/shaman)
prices[29028] = {1, "T4"} -- Shaman T4 Head
prices[29035] = {1, "T4"} --
prices[29040] = {1, "T4"} --
prices[29044] = {1, "T4"} -- Rogue T4 Head
prices[29061] = {1, "T4"} -- Paladin T4 Head
prices[29068] = {1, "T4"} --
prices[29073] = {1, "T4"} --
prices[29761] = {1, "T4"} -- Helm of the Fallen Defender (T4 Head - warrior/priest/druid)
prices[29011] = {1, "T4"} -- Warrior T4 Head
prices[29021] = {1, "T4"} --
prices[29049] = {1, "T4"} -- Priest T4 Head
prices[29058] = {1, "T4"} --
prices[29086] = {1, "T4"} -- Druid T4 Head
prices[29093] = {1, "T4"} --
prices[29098] = {1, "T4"} --
prices[29759] = {1, "T4"} -- Helm of the Fallen Hero (T4 Head - hunter/mage/warlock)
prices[28963] = {1, "T4"} -- Warlock T4 Head
prices[29076] = {1, "T4"} -- Mage T4 Head
prices[29081] = {1, "T4"} -- Hunter T4 Head
--- Nightbane
prices[28601] = {1, "T4"} -- Chestguard of the Conniver (Leather - physical)
prices[28611] = {1, "T4"} -- Dragonheart Flameshield (caster)
prices[28609] = {1, "T4"} -- Emberspur Talisman (heal)
prices[28610] = {1, "T4"} -- Ferocious Swift-Kickers (Mail - physical)
prices[28608] = {1, "T4"} -- Ironstriders of Urgency (Plate - melee)
prices[28604] = {1, "T4"} -- Nightstaff of the Everliving (heal)
prices[28597] = {1, "T4"} -- Panzar'Thar Breastplate (Plate - tank)
prices[28602] = {1, "T4"} -- Robe of the Elder Scribes (Cloth - caster)
prices[28599] = {1, "T4"} -- Scaled Breastplate of Carnage (Mail - physical)
prices[28606] = {1, "T4"} -- Shield of Impenetrable Darkness (tank)
prices[28600] = {1, "T4"} -- Stonebough Jerkin (Leather - heal)
prices[28603] = {1, "T4"} -- Talisman of Nightbane (caster)
-- World Bosses (IL120)
--- Doom Lord Kazzak
prices[30735] = {1, "T4"} -- Ancient Spellcloak of the Highborne (Cloth - caster)
prices[30732] = {1, "T4"} -- Exodar Life-Staff (heal)
prices[30737] = {1, "T4"} -- Gold-Leaf Wildboots (Leather - heal)
prices[30733] = {1, "T4"} -- Hope Ender (physical)
prices[30734] = {1, "T4"} -- Leggings of the Seventh Circle (Cloth - caster)
prices[30736] = {1, "T4"} -- Ring of Flowing Light (heal)
prices[30738] = {1, "T4"} -- Ring of Reciprocity (physical)
prices[30740] = {1, "T4"} -- Ripfiend Shoulderplates (Plate - melee)
prices[30739] = {1, "T4"} -- Scaled Greaves of the Marksman (Mail - physical)
prices[30741] = {1, "T4"} -- Topaz-Studded Battlegrips (Plate - tank)
--- Doomwalker
prices[30725] = {1, "T4"} -- Anger-Spark Gloves (Cloth - caster)
prices[30726] = {1, "T4"} -- Archaic Charm of Presence (heal)
prices[30724] = {1, "T4"} -- Barrel-Blade Longrifle (melee/tank)
prices[30729] = {1, "T4"} -- Black-Iron Battlecloak (Cloth - physical)
prices[30722] = {1, "T4"} -- Ethereum Nexus-Reaver (melee)
prices[30731] = {1, "T4"} -- Faceguard of the Endless Watch (Plate - tank)
prices[30728] = {1, "T4"} -- Fathom-Helm of the Deeps (Mail - heal)
prices[30727] = {1, "T4"} -- Gilded Trousers of Benediction (Cloth - heal)
prices[30723] = {1, "T4"} -- Talon of the Tempest (caster)
prices[30730] = {1, "T4"} -- Terrorweave Tunic (Leather - physical)
-- Magtheridon (IL125)
prices[34845] = {1, "T4"} -- Pit Lord's Satchel
prices[32385] = {1, "T4"} -- Magtheridon's Head (Alliance)
prices[32386] = {1, "T4"} -- Magtheridon's Head (Horde)
prices[28790] = {1, "T4"} -- Mag quest rewards
prices[28791] = {1, "T4"} --
prices[28792] = {1, "T4"} --
prices[28793] = {1, "T4"} --
prices[29458] = {1, "T4"} -- Aegis of the Vindicator (heal)
prices[28777] = {1, "T4"} -- Cloak of the Pit Stalker (Cloth - physical)
prices[28782] = {1, "T4"} -- Crystalheart Pulse-Staff (heal)
prices[28783] = {1, "T4"} -- Eredar Wand of Obliteration (caster)
prices[28789] = {1, "T4"} -- Eye of Magtheridon (caster)
prices[28779] = {1, "T4"} -- Girdle of the Endless Pit (Plate - melee)
prices[28774] = {1, "T4"} -- Glaive of the Pit (physical)
prices[28781] = {1, "T4"} -- Karaborian Talisman (caster)
prices[28776] = {1, "T4"} -- Liar's Tongue Gloves (Leather - physical)
prices[28780] = {1, "T4"} -- Soul-Eater's Handwraps (Cloth - caster)
prices[28778] = {1, "T4"} -- Terror Pit Girdle (Mail - physical)
prices[28775] = {1, "T4"} -- Thundering Greathelm (Plate - melee)
prices[29754] = {1, "T4"} -- Chestguard of the Fallen Champion (T4 Chest - paladin/rogue/shaman)
prices[29029] = {1, "T4"} -- Shaman T4 Chest
prices[29033] = {1, "T4"} --
prices[29038] = {1, "T4"} --
prices[29045] = {1, "T4"} -- Rogue T4 Chest
prices[29062] = {1, "T4"} -- Paladin T4 Chest
prices[29066] = {1, "T4"} --
prices[29071] = {1, "T4"} --
prices[29753] = {1, "T4"} -- Chestguard of the Fallen Defender (T4 Chest - warrior/priest/druid)
prices[29012] = {1, "T4"} -- Warrior T4 Chest
prices[29019] = {1, "T4"} --
prices[29050] = {1, "T4"} -- Priest T4 Chest
prices[29056] = {1, "T4"} --
prices[29087] = {1, "T4"} -- Druid T4 Chest
prices[29091] = {1, "T4"} --
prices[29096] = {1, "T4"} --
prices[29755] = {1, "T4"} -- Chestguard of the Fallen Hero (T4 Chest - hunter/mage/warlock)
prices[28964] = {1, "T4"} -- Warlock T4 Chest
prices[29077] = {1, "T4"} -- Mage T4 Chest
prices[29082] = {1, "T4"} -- Hunter T4 Chest
-- Gruul's (IL125)
--- Maulgar
prices[28799] = {1, "T4"} -- Belt of Divine Inspiration (Cloth - caster)
prices[28795] = {1, "T4"} -- Bladespire Warbands (Plate - melee)
prices[28797] = {1, "T4"} -- Brute Cloak of the Ogre-Magi (Cloth - caster)
prices[28800] = {1, "T4"} -- Hammer of the Naaru (paladin/enhshaman)
prices[28796] = {1, "T4"} -- Malefic Mask of the Shadows (Leather - physical)
prices[28801] = {1, "T4"} -- Maulgar's Warhelm (mail - physical)
prices[29763] = {1, "T4"} -- Pauldrons of the Fallen Champion (T4 Shoulder - paladin/rogue/shaman)
prices[29031] = {1, "T4"} -- Shaman T4 Shoulder
prices[29037] = {1, "T4"} --
prices[29043] = {1, "T4"} --
prices[29047] = {1, "T4"} -- Rogue T4 Shoulder
prices[29064] = {1, "T4"} -- Paladin T4 Shoulder
prices[29070] = {1, "T4"} --
prices[29075] = {1, "T4"} --
prices[29764] = {1, "T4"} -- Pauldrons of the Fallen Defender (T4 Shoulder - warrior/priest/druid)
prices[29016] = {1, "T4"} -- Warrior T4 Shoulder
prices[29023] = {1, "T4"} --
prices[29054] = {1, "T4"} -- Priest T4 Shoulder
prices[29060] = {1, "T4"} --
prices[29089] = {1, "T4"} -- Druid T4 Shoulder
prices[29095] = {1, "T4"} --
prices[29100] = {1, "T4"} --
prices[29762] = {1, "T4"} -- Pauldrons of the Fallen Hero (T4 Shoulder - hunter/mage/warlock)
prices[28967] = {1, "T4"} -- Warlock T4 Shoulder
prices[29079] = {1, "T4"} -- Mage T4 Shoulder
prices[29084] = {1, "T4"} -- Hunter T4 Shoulder
--- Gruul
prices[28830] = {1, "T4"} -- Dragonspine Trophy (physical)
prices[28823] = {1, "T4"} -- Eye of Gruul (heal)
prices[28824] = {1, "T4"} -- Gauntlets of Martial Perfection (Plate - melee)
prices[28827] = {1, "T4"} -- Gauntlets of the Dragonslayer (Mail - physical)
prices[28822] = {1, "T4"} -- Teeth of Gruul (heal)
prices[28810] = {1, "T4"} -- Windshear Boots (Mail - caster)
prices[28825] = {1, "T4"} -- Aldori Legacy Defender (tank)
prices[28794] = {1, "T4"} -- Axe of the Gronn Lords (physical)
prices[28802] = {1, "T4"} -- Bloodmaw Magus-Blade (caster)
prices[28804] = {1, "T4"} -- Collar of Cho'gall (Cloth - caster)
prices[28803] = {1, "T4"} -- Cowl of Nature's Breath (Leather - heal)
prices[28828] = {1, "T4"} -- Gronn-Stitched Girdle (Leather - physical)
prices[28826] = {1, "T4"} -- Shuriken of Negation (rogue)
prices[29766] = {1, "T4"} -- Leggings of the Fallen Champion (T4 Leggings - paladin/rogue/shaman)
prices[29030] = {1, "T4"} -- Shaman T4 Leggings
prices[29036] = {1, "T4"} --
prices[29042] = {1, "T4"} --
prices[29046] = {1, "T4"} -- Rogue T4 Leggings
prices[29063] = {1, "T4"} -- Paladin T4 Leggings
prices[29069] = {1, "T4"} --
prices[29074] = {1, "T4"} --
prices[29767] = {1, "T4"} -- Leggings of the Fallen Defender (T4 Leggings - warrior/priest/druid)
prices[29015] = {1, "T4"} -- Warrior T4 Leggings
prices[29022] = {1, "T4"} --
prices[29053] = {1, "T4"} -- Priest T4 Leggings
prices[29059] = {1, "T4"} --
prices[29088] = {1, "T4"} -- Druid T4 Leggings
prices[29094] = {1, "T4"} --
prices[29099] = {1, "T4"} --
prices[29765] = {1, "T4"} -- Leggings of the Fallen Hero (T4 Leggings - hunter/mage/warlock)
prices[28966] = {1, "T4"} -- Warlock T4 Leggings
prices[29078] = {1, "T4"} -- Mage T4 Leggings
prices[29083] = {1, "T4"} -- Hunter T4 Leggings
-- SSC (IL128-141)
--- Trash
prices[30025] = {1, "T5"} -- Serpentshrine Shuriken (physical)
prices[30021] = {1, "T5"} -- Wildfury Greatstaff (druid)
prices[30027] = {1, "T5"} -- Boots of Courage Unending (Plate - heal)
prices[30022] = {1, "T5"} -- Pendant of the Perilous (melee)
prices[30620] = {1, "T5"} -- Spyglass of the Hidden Fleet (tank - pvp)
prices[30023] = {1, "T5"} -- Totem of the Maelstrom (shaman - heal)
--- Hydross
prices[33055] = {1, "T5"} -- Band of Vile Aggression (pvp - physical)
prices[30047] = {1, "T5"} -- Blackfathom Warbands (Mail - heal)
prices[30050] = {1, "T5"} -- Boots of the Shifting Nightmare (Cloth - caster shadow)
prices[30048] = {1, "T5"} -- Brighthelm of Justice (Plate - heal)
prices[30049] = {1, "T5"} -- Fathomstone (caster)
prices[30051] = {1, "T5"} -- Idol of the Crescent Goddess (druid - heal)
prices[30664] = {1, "T5"} -- Living Root of the Wildheart (druid)
prices[30053] = {1, "T5"} -- Pauldrons of the Wardancer (Plate - melee)
prices[30054] = {1, "T5"} -- Ranger-General's Chestguard (Mail - physical)
prices[30052] = {1, "T5"} -- Ring of Lethality (physical)
prices[30056] = {1, "T5"} -- Robe of Hateful Echoes (Cloth - caster)
prices[30629] = {1, "T5"} -- Scarab of Displacement (tank)
prices[30055] = {1, "T5"} -- Shoulderpads of the Stranger (Leather - physical)
prices[32516] = {1, "T5"} -- Wraps of Purification (Cloth - heal)
--- Lurker
prices[30061] = {1, "T5"} -- Ancestral Ring of Conquest (melee)
prices[30060] = {1, "T5"} -- Boots of Effortless Striking (Leather - physical)
prices[30057] = {1, "T5"} -- Bracers of Eradication (Plate - melee)
prices[30059] = {1, "T5"} -- Choker of Animalistic Fury (physical)
prices[30064] = {1, "T5"} -- Cord of Screaming Terrors (Cloth - caster)
prices[30665] = {1, "T5"} -- Earring of Soulful Meditation (priest - heal)
prices[30065] = {1, "T5"} -- Glowing Breastplate of Truth (Plate - heal)
prices[30062] = {1, "T5"} -- Grove-Bands of Remulos (Leather - heal)
prices[30063] = {1, "T5"} -- Libram of Absolute Truth (paladin - heal)
prices[30058] = {1, "T5"} -- Mallet of the Tides (tank)
prices[30066] = {1, "T5"} -- Tempest-Strider Boots (Maiil - heal)
prices[30067] = {1, "T5"} -- Velvet Boots of the Guardian (Cloth - caster)
--- Morogrim
prices[30068] = {1, "T5"} -- Girdle of the Tidal Call (Mail - melee)
prices[30075] = {1, "T5"} -- Gnarled Chestpiece of the Ancients (Leather - heal)
prices[30079] = {1, "T5"} -- Illidari Shoulderpads (Cloth - caster)
prices[30080] = {1, "T5"} -- Luminescent Rod of the Naaru (heal)
prices[30085] = {1, "T5"} -- Mantle of the Tireless Tracker (Mail - physical)
prices[30084] = {1, "T5"} -- Pauldrons of the Argent Sentinel (Plate - heal)
prices[30008] = {1, "T5"} -- Pendant of the Lost Ages (pvp - caster)
prices[30098] = {1, "T5"} -- Razor-Scale Battlecloak (melee)
prices[30083] = {1, "T5"} -- Ring of Sundered Souls (tank)
prices[30720] = {1, "T5"} -- Serpent-Coil Braid (mage)
prices[30082] = {1, "T5"} -- Talon of Azshara (physical)
prices[30081] = {1, "T5"} -- Warboots of Obliteration (Plate - melee)
--- Karathress
prices[30101] = {1, "T5"} -- Bloodsea Brigand's Vest (Leather - physical)
prices[30663] = {1, "T5"} -- Fathom-Brooch of the Tidewalker (shaman - caster/heal)
prices[30099] = {1, "T5"} -- Frayed Tether of the Drowned (tank/feral)
prices[30626] = {1, "T5"} -- Sextant of Unstable Currents (caster)
prices[30100] = {1, "T5"} -- Soul-Strider Boots (Cloth - heal)
prices[30090] = {1, "T5"} -- World Breaker (melee)
prices[30245] = {1, "T5"} -- Leggings of the Vanquished Champion (T5 Leggings - paladin/rogue/shaman)
prices[30126] = {1, "T5"} -- Paladin T5 Leggings
prices[30132] = {1, "T5"} --
prices[30137] = {1, "T5"} --
prices[30148] = {1, "T5"} -- Rogue T5 Leggings
prices[30167] = {1, "T5"} -- Shaman T5 Leggings
prices[30172] = {1, "T5"} --
prices[30192] = {1, "T5"} --
prices[30246] = {1, "T5"} -- Leggings of the Vanquished Defender (T5 Leggings - warrior/priest/druid)
prices[30116] = {1, "T5"} -- Warrior T5 Leggings
prices[30121] = {1, "T5"} --
prices[30153] = {1, "T5"} -- Priest T5 Leggings
prices[30162] = {1, "T5"} --
prices[30220] = {1, "T5"} -- Druid T5 Leggings
prices[30229] = {1, "T5"} --
prices[30234] = {1, "T5"} --
prices[30247] = {1, "T5"} -- Leggings of the Vanquished Hero (T5 Leggings - hunter/mage/warlock)
prices[30142] = {1, "T5"} -- Hunter T5 Leggings
prices[30207] = {1, "T5"} -- Mage T5 Leggings
prices[30213] = {1, "T5"} -- Warlock T5 Leggings
--- Leotheras
prices[30097] = {1, "T5"} -- Coral-Barbed Shoulderpads (Mail - heal)
prices[30095] = {1, "T5"} -- Fang of the Leviathan (caster)
prices[30096] = {1, "T5"} -- Girdle of the Invulnerable (Plate - tank)
prices[30092] = {1, "T5"} -- Orca-Hide Boots (Leather - heal)
prices[30091] = {1, "T5"} -- True-Aim Stalker Bands (Mail - physical)
prices[30627] = {1, "T5"} -- Tsunami Talisman (physical)
prices[30239] = {1, "T5"} -- Gloves of the Vanquished Champion (T5 Gloves - paladin/rogue/shaman)
prices[30124] = {1, "T5"} -- Paladin T5 Gloves
prices[30130] = {1, "T5"} --
prices[30135] = {1, "T5"} --
prices[30145] = {1, "T5"} -- Rogue T5 Gloves
prices[30165] = {1, "T5"} -- Shaman T5 Gloves
prices[30170] = {1, "T5"} --
prices[30189] = {1, "T5"} --
prices[30240] = {1, "T5"} -- Gloves of the Vanquished Defender (T5 Gloves - warrior/priest/druid)
prices[30114] = {1, "T5"} -- Warrior T5 Gloves
prices[30119] = {1, "T5"} --
prices[30151] = {1, "T5"} -- Priest T5 Gloves
prices[30160] = {1, "T5"} --
prices[30217] = {1, "T5"} -- Druid T5 Gloves
prices[30223] = {1, "T5"} --
prices[30232] = {1, "T5"} --
prices[30241] = {1, "T5"} -- Gloves of the Vanquished Hero (T5 Gloves - hunter/mage/warlock)
prices[30140] = {1, "T5"} -- Hunter T5 Gloves
prices[30205] = {1, "T5"} -- Mage T5 Gloves
prices[30211] = {1, "T5"} -- Warlock T5 Gloves
--- Lady Vashj
prices[30106] = {1, "T5"} -- Belt of One-Hundred Deaths (Leather - melee)
prices[30104] = {1, "T5"} -- Cobra-Lash Boots (Mail - physical)
prices[30110] = {1, "T5"} -- Coral Band of the Revived (heal)
prices[30103] = {1, "T5"} -- Fang of Vashj (melee)
prices[30112] = {1, "T5"} -- Glorious Gauntlets of Crestfall (Plate - heal)
prices[30102] = {1, "T5"} -- Krakken-Heart Breastplate (Plate - melee)
prices[30108] = {1, "T5"} -- Lightfathom Scepter (heal)
prices[30621] = {1, "T5"} -- Prism of Inner Calm (physical)
prices[30109] = {1, "T5"} -- Ring of Endless Coils (caster)
prices[30111] = {1, "T5"} -- Runetotem's Mantle (Leather - heal)
prices[30105] = {1, "T5"} -- Serpent Spine Longbow (physical)
prices[30107] = {1, "T5"} -- Vestments of the Sea-Witch (Cloth - caster)
prices[30242] = {1, "T5"} -- Helm of the Vanquished Champion (T5 Helm - paladin/rogue/shaman)
prices[30125] = {1, "T5"} -- Paladin T5 Helm
prices[30131] = {1, "T5"} --
prices[30136] = {1, "T5"} --
prices[30146] = {1, "T5"} -- Rogue T5 Helm
prices[30166] = {1, "T5"} -- Shaman T5 Helm
prices[30171] = {1, "T5"} --
prices[30190] = {1, "T5"} --
prices[30243] = {1, "T5"} -- Helm of the Vanquished Defender (T5 Helm - warrior/priest/druid)
prices[30115] = {1, "T5"} -- Warrior T5 Helm
prices[30120] = {1, "T5"} --
prices[30152] = {1, "T5"} -- Priest T5 Helm
prices[30161] = {1, "T5"} --
prices[30219] = {1, "T5"} -- Druid T5 Helm
prices[30228] = {1, "T5"} --
prices[30233] = {1, "T5"} --
prices[30244] = {1, "T5"} -- Helm of the Vanquished Hero (T5 Helm - hunter/mage/warlock)
prices[30141] = {1, "T5"} -- Hunter T5 Helm
prices[30206] = {1, "T5"} -- Mage T5 Helm
prices[30212] = {1, "T5"} -- Warlock T5 Helm
-- EyE (IL128-141)
--- Trash
prices[30020] = {1, "T5"} -- Fire-Cord of the Magus (Cloth = caster fire)
prices[30024] = {1, "T5"} -- Mantle of the Elven Kings (Cloth - caster)
prices[30029] = {1, "T5"} -- Bark-Gloves of Ancient Wisdom (Leather - heal)
prices[30026] = {1, "T5"} -- Bands of the Celestial Archer (Mail - physical)
prices[30030] = {1, "T5"} -- Girdle of Fallen Stars (Mail - heal)
prices[30028] = {1, "T5"} -- Seventh Ring of the Tirisfalen (tank)
--- Al'ar
prices[32944] = {1, "T5"} -- Talon of the Phoenix (physical)
prices[29948] = {1, "T5"} -- Claw of the Phoenix (physical - dualwield)
prices[30448] = {1, "T5"} -- Talon of Al'ar (hunter)
prices[29949] = {1, "T5"} -- Arcanite Steam-Pistol (physical)
prices[29922] = {1, "T5"} -- Band of Al'ar (caster)
prices[29921] = {1, "T5"} -- Fire Crest Breastplate (Mail - heal)
prices[29947] = {1, "T5"} -- Gloves of the Searing Grip (Leather - melee)
prices[29918] = {1, "T5"} -- Mindstorm Wristbands (Cloth - caster)
prices[29924] = {1, "T5"} -- Netherbane (physical)
prices[29920] = {1, "T5"} -- Phoenix-Ring of Rebirth (heal)
prices[29925] = {1, "T5"} -- Phoenix-Wing Cloak (tank)
prices[29923] = {1, "T5"} -- Talisman of the Sun King (heal)
prices[30447] = {1, "T5"} -- Tome of Fiery Redemption (paladin)
--- Void Reaver
prices[29986] = {1, "T5"} -- Cowl of the Grand Engineer (Cloth - caster)
prices[30619] = {1, "T5"} -- Fel Reaver's Piston (heal)
prices[29983] = {1, "T5"} -- Fel-Steel Warhelm (Plate - Melee)
prices[29984] = {1, "T5"} -- Girdle of Zaetar (Leather - heal)
prices[29985] = {1, "T5"} -- Void Reaver Greaves (Mail - physical)
prices[30450] = {1, "T5"} -- Warp-Spring Coil (rogue)
prices[32515] = {1, "T5"} -- Wristguards of Determination (Plate - tank)
prices[30248] = {1, "T5"} -- Pauldrons of the Vanquished Champion (T5 Shoulders - paladin/rogue/shaman)
prices[30127] = {1, "T5"} -- Paladin T5 Shoulders
prices[30133] = {1, "T5"} --
prices[30138] = {1, "T5"} --
prices[30149] = {1, "T5"} -- Rogue T5 Shoulders
prices[30168] = {1, "T5"} -- Shaman T5 Shoulders
prices[30173] = {1, "T5"} --
prices[30194] = {1, "T5"} --
prices[30249] = {1, "T5"} -- Pauldrons of the Vanquished Defender (T5 Shoulders - warrior/priest/druid)
prices[30117] = {1, "T5"} -- Warrior T5 Shoulders
prices[30122] = {1, "T5"} --
prices[30154] = {1, "T5"} -- Priest T5 Shoulders
prices[30163] = {1, "T5"} --
prices[30221] = {1, "T5"} -- Druid T5 Shoulders
prices[30230] = {1, "T5"} --
prices[30235] = {1, "T5"} --
prices[30250] = {1, "T5"} -- Pauldrons of the Vanquished Hero (T5 Shoulders - hunter/mage/warlock)
prices[30143] = {1, "T5"} -- Hunter T5 Shoulders
prices[30210] = {1, "T5"} -- Mage T5 Shoulders
prices[30215] = {1, "T5"} -- Warlock T5 Shoulders
--- Solarian
prices[32267] = {1, "T5"} -- Boots of the Resilient (Plate - tank)
prices[29981] = {1, "T5"} -- Ethereum Life-Staff (heal)
prices[29965] = {1, "T5"} -- Girdle of the Righteous Path (Plate - heal)
prices[29950] = {1, "T5"} -- Greaves of the Bloodwarder (Plate - melee)
prices[29962] = {1, "T5"} -- Heartrazor (physical)
prices[30446] = {1, "T5"} -- Solarian's Sapphire (warrior)
prices[29977] = {1, "T5"} -- Star-Soul Breeches (Cloth - heal)
prices[29951] = {1, "T5"} -- Star-Strider Boots (Mail - physical)
prices[29972] = {1, "T5"} -- Trousers of the Astromancer (Cloth - caster)
prices[29966] = {1, "T5"} -- Vambraces of Ending (Leather - physical)
prices[30449] = {1, "T5"} -- Void Star Talisman (warlock)
prices[29982] = {1, "T5"} -- Wand of the Forgotten Star (caster)
prices[29976] = {1, "T5"} -- Worldstorm Gauntlets (Mail - heal)
--- Kael'thas
prices[29997] = {1, "T5"} -- Band of the Ranger-General (physical)
prices[29990] = {1, "T5"} -- Crown of the Sun (Cloth - heal)
prices[29987] = {1, "T5"} -- Gauntlets of the Sun King (Cloth - caster)
prices[29995] = {1, "T5"} -- Leggings of Murderous Intent (Leather - physical)
prices[29996] = {1, "T5"} -- Rod of the Sun King (melee)
prices[29992] = {1, "T5"} -- Royal Cloak of the Sunstriders (Cloth - caster)
prices[29998] = {1, "T5"} -- Royal Gauntlets of Silvermoon (Plate - tank)
prices[29991] = {1, "T5"} -- Sunhawk Leggings (Mail - heal)
prices[29989] = {1, "T5"} -- Sunshower Light Cloak (Cloth - heal)
prices[29994] = {1, "T5"} -- Thalassian Wildercloak (Cloth - physical)
prices[29988] = {1, "T5"} -- The Nexus Key (caster)
prices[29993] = {1, "T5"} -- Twinblade of the Phoenix (physical)
prices[32405] = {1, "T5"} -- Verdant Sphere (quest)
prices[30018] = {1, "T5"} -- Lord Sanguinar's Claim (sphere - heal)
prices[30017] = {1, "T5"} -- Telonicus's Pendant of Mayhem (sphere - physical)
prices[30007] = {1, "T5"} -- The Darkener's Grasp (sphere - tank)
prices[30015] = {1, "T5"} -- The Sun King's Talisman (sphere - caster)
prices[32458] = {0, "T5"} -- Ashes of Al'ar (mount)
prices[30236] = {1, "T5"} -- Chestguard of the Vanquished Champion (T5 Chest - paladin/rogue/shaman)
prices[30123] = {1, "T5"} -- Paladin T5 Chest
prices[30129] = {1, "T5"} --
prices[30134] = {1, "T5"} --
prices[30144] = {1, "T5"} -- Rogue T5 Chest
prices[30164] = {1, "T5"} -- Shaman T5 Chest
prices[30169] = {1, "T5"} --
prices[30185] = {1, "T5"} --
prices[30237] = {1, "T5"} -- Chestguard of the Vanquished Defender (T5 Chest - warrior/priest/druid)
prices[30113] = {1, "T5"} -- Warrior T5 Chest
prices[30118] = {1, "T5"} --
prices[30150] = {1, "T5"} -- Priest T5 Chest
prices[30159] = {1, "T5"} --
prices[30216] = {1, "T5"} -- Druid T5 Chest
prices[30222] = {1, "T5"} --
prices[30231] = {1, "T5"} --
prices[30238] = {1, "T5"} -- Chestguard of the Vanquished Hero (T5 Chest - hunter/mage/warlock)
prices[30139] = {1, "T5"} -- Hunter T5 Chest
prices[30196] = {1, "T5"} -- Mage T5 Chest
prices[30214] = {1, "T5"} -- Warlock T5 Chest
-- BT (IL141-156)
--- Trash
prices[34011] = {1, "T6"} -- Illidari Runeshield (caster)
prices[32943] = {1, "T6"} -- Swiftsteel Bludgeon (physical)
prices[32609] = {1, "T6"} -- Boots of the Divine Light (Cloth - caster)
prices[32593] = {1, "T6"} -- Treads of the Den Mother (Leather - tank/melee)
prices[32592] = {1, "T6"} -- Chestguard of Relentless Storms (Mail - caster)
prices[32606] = {1, "T6"} -- Girdle of the Lightbearer (Plate - caster)
prices[32608] = {1, "T6"} -- Pillager's Gauntlets (Plate - melee)
prices[32590] = {1, "T6"} -- Nethervoid Cloak (Cloth - caster shadow)
prices[34012] = {1, "T6"} -- Shroud of the Final Stand (Cloth - heal)
prices[32526] = {1, "T6"} -- Band of Devastation (physical)
prices[32528] = {1, "T6"} -- Blessed Band of Karabor (heal)
prices[32591] = {1, "T6"} -- Choker of Serrated Blades (melee)
prices[32589] = {1, "T6"} -- Hellfire-Encased Pendant (caster fire)
prices[32527] = {1, "T6"} -- Ring of Ancient Knowledge (caster)
prices[34009] = {1, "T6"} -- Hammer of Judgement (caster)
prices[34010] = {1, "T6"} -- Pepe's Shroud of Pacification (druid > tank)
--- Najentus
prices[32242] = {1, "T6"} -- Boots of Oceanic Fury (mail - caster)
prices[32232] = {1, "T6"} -- Eternium Shell Bracers (plate - tank)
prices[32234] = {1, "T6"} -- Fists of Mukoa (mail - physical)
prices[32240] = {1, "T6"} -- Guise of the Tidal Lurker (leather - heal)
prices[32248] = {1, "T6"} -- Halberd of Desolation (physical)
prices[32241] = {1, "T6"} -- Helm of Soothing Currents (mail - heal)
prices[32377] = {1, "T6"} -- Mantle of Darkness (leather - physical)
prices[32243] = {1, "T6"} -- Pearl Inlaid Boots (plate - heal)
prices[32238] = {1, "T6"} -- Ring of Calming Waves (heal)
prices[32247] = {1, "T6"} -- Ring of Captured Storms (caster)
prices[32236] = {1, "T6"} -- Rising Tide (physical)
prices[32239] = {1, "T6"} -- Slippers of the Seacaller (cloth - caster)
prices[32237] = {1, "T6"} -- The Maelstrom's Fury (caster)
prices[32245] = {1, "T6"} -- Tide-stomper's Greaves (plate - tank)
--- Supremus
prices[32261] = {1, "T6"} -- Band of the Abyssal Lord (tank)
prices[32259] = {1, "T6"} -- Bands of the Coming Storm (mail - caster)
prices[32260] = {1, "T6"} -- Choker of Endless Nightmares (physical)
prices[32255] = {1, "T6"} -- Felstone Bulwark (heal)
prices[32257] = {1, "T6"} -- Idol of the White Stag (druid physical)
prices[32253] = {1, "T6"} -- Legionkiller (physical)
prices[32258] = {1, "T6"} -- Naturalist's Preserving Cinch (mail - heal)
prices[32252] = {1, "T6"} -- Nether Shadow Tunic (leather - physical)
prices[32250] = {1, "T6"} -- Pauldrons of Abyssal Fury (plate - tank)
prices[32262] = {1, "T6"} -- Syphon of the Nathrezim (physical)
prices[32254] = {1, "T6"} -- The Brutalizer (tank)
prices[32256] = {1, "T6"} -- Waistwrap of Infinity (cloth - caster)
prices[32251] = {1, "T6"} -- Wraps of Precise Flight (mail - physical)
--- Shade of Akama
prices[32273] = {1, "T6"} -- Amice of Brilliant Light (cloth - heal)
prices[32361] = {1, "T6"} -- Blind-Seers Icon (caster)
prices[32276] = {1, "T6"} -- Flashfire Girdle (mail - caster)
prices[32270] = {1, "T6"} -- Focused Mana Bindings (cloth - caster)
prices[32278] = {1, "T6"} -- Grips of Silent Justice (plate - melee)
prices[32271] = {1, "T6"} -- Kilt of Immortal Nature (leather - heal)
prices[32268] = {1, "T6"} -- Myrmidon's Treads (plate - tank)
prices[32263] = {1, "T6"} -- Praetorian's Legguards (plate - tank)
prices[32266] = {1, "T6"} -- Ring of Deceitful Intent (physical)
prices[32265] = {1, "T6"} -- Shadow-walker's Cord (leather - physical)
prices[32264] = {1, "T6"} -- Shoulders of the Hidden Predator (mail - physical)
prices[32275] = {1, "T6"} -- Spiritwalker Gauntlets (mail - heal)
prices[32279] = {1, "T6"} -- The Seeker's Wristguards (paladin - tank)
prices[32513] = {1, "T6"} -- Wristbands of Divine Influence (cloth - heal)
--- Gorefiend
prices[32328] = {1, "T6"} -- Botanist's Gloves of Growth (leather - heal)
prices[32329] = {1, "T6"} -- Cowl of Benevolence (cloth - heal)
prices[32280] = {1, "T6"} -- Gauntlets of Enforcement (plate - tank)
prices[32512] = {1, "T6"} -- Girdle of Lordaeron's Fallen (plate - heal)
prices[32324] = {1, "T6"} -- Insidious Bands (leather - physical)
prices[32325] = {1, "T6"} -- Rifle of the Stoic Guardian (tank)
prices[32327] = {1, "T6"} -- Robe of the Shadow Council (cloth - caster)
prices[32323] = {1, "T6"} -- Shadowmoon Destroyer's Drape (physical)
prices[32510] = {1, "T6"} -- Softstep Boots of Tracking (mail - physical)
prices[32348] = {1, "T6"} -- Soul Cleaver (melee)
prices[32330] = {1, "T6"} -- Totem of Ancestral Guidance (shaman - elemental)
prices[32326] = {1, "T6"} -- Twisted Blades of Zarak (melee)
--- Bloodboil
prices[32339] = {1, "T6"} -- Belt of Primal Majesty (leather - heal)
prices[32338] = {1, "T6"} -- Blood-cursed Shoulderpads (cloth - caster)
prices[32340] = {1, "T6"} -- Garments of Temperance (heal)
prices[32342] = {1, "T6"} -- Girdle of Mighty Resolve (paladin - tank)
prices[32333] = {1, "T6"} -- Girdle of Stability (plate - tank)
prices[32341] = {1, "T6"} -- Leggings of Divine Retribution (plate - melee)
prices[32269] = {1, "T6"} -- Messenger of Fate (physical)
prices[32501] = {1, "T6"} -- Shadowmoon Insignia (tank)
prices[32337] = {1, "T6"} -- Shroud of Forgiveness (heal)
prices[32344] = {1, "T6"} -- Staff of Immaculate Recovery (heal)
prices[32335] = {1, "T6"} -- Unstoppable Aggressor's Ring (melee)
prices[32334] = {1, "T6"} -- Vest of Mounting Assault (mail - physical)
prices[32343] = {1, "T6"} -- Wand of Prismatic Focus (caster)
--- Reliquary
prices[32346] = {1, "T6"} -- Boneweave Girdle (mal - physical)
prices[32354] = {1, "T6"} -- Crown of Empowered Fate (plate - heal)
prices[32345] = {1, "T6"} -- Dreadboots of the Legion (plate - melee)
prices[32351] = {1, "T6"} -- Elunite Empowered Bracers (leather - caster)
prices[32353] = {1, "T6"} -- Gloves of Unfailing Faith (cloth - heal)
prices[32347] = {1, "T6"} -- Grips of Damnation (leather - physical)
prices[32363] = {1, "T6"} -- Naaru-Blessed Life Rod (heal)
prices[32352] = {1, "T6"} -- Naturewarden's Treads (leather - caster)
prices[32362] = {1, "T6"} -- Pendant of Titans (tank)
prices[32517] = {1, "T6"} -- The Wavemender's Mantle (mail - heal)
prices[32332] = {1, "T6"} -- Torch of the Damned (melee)
prices[32350] = {1, "T6"} -- Touch of Inspiration (heal)
prices[32349] = {1, "T6"} -- Translucent Spellthread Necklace (caster)
--- Shahraz
prices[32369] = {1, "T6"} -- Blade of Savagery (physical)
prices[32365] = {1, "T6"} -- Heartshatter Breastplate (plate - melee)
prices[32367] = {1, "T6"} -- Leggings of Devastation (cloth - caster)
prices[32370] = {1, "T6"} -- Nadina's Pendant of Purity (heal)
prices[32366] = {1, "T6"} -- Shadowmaster's Boots (leather - physical)
prices[32368] = {1, "T6"} -- Tome of the Lightbringer (paladin - tank)
prices[31101] = {1, "T6"} -- Pauldrons of the Forgotten Conqueror (T6 Shoulders - paladin/priest/warlock)
prices[30996] = {1, "T6"} -- Paladin - T6 Shoulders
prices[30997] = {1, "T6"} --
prices[30998] = {1, "T6"} --
prices[31069] = {1, "T6"} -- Priest - T6 Shoulders
prices[31070] = {1, "T6"} --
prices[31054] = {1, "T6"} -- Warlock - T6 Shoulders
prices[31103] = {1, "T6"} -- Pauldrons of the Forgotten Protector (T6 Shoulders - warrior/hunter/shaman)
prices[30979] = {1, "T6"} -- Warrior - T6 Shoulders
prices[30980] = {1, "T6"} --
prices[31006] = {1, "T6"} -- Hunter - T6 Shoulders
prices[31022] = {1, "T6"} -- Shaman - T6 Shoulders
prices[31023] = {1, "T6"} --
prices[31024] = {1, "T6"} --
prices[31102] = {1, "T6"} -- Pauldrons of the Forgotten Vanquisher (T6 Shoulders - rogue/mage/druid)
prices[31030] = {1, "T6"} -- Rogue - T6 Shoulders
prices[31047] = {1, "T6"} -- Druid - T6 Shoulders
prices[31048] = {1, "T6"} --
prices[31049] = {1, "T6"} --
prices[31059] = {1, "T6"} -- Mage - T6 Shoulders
--- Council
prices[32519] = {1, "T6"} -- Belt of Divine Guidance (cloth - heal)
prices[32331] = {1, "T6"} -- Cloak of the Illidari Council (caster)
prices[32376] = {1, "T6"} -- Forest Prowler's Helm (mail - physical)
prices[32373] = {1, "T6"} -- Helm of the Illidari Shatterer (plate - melee)
prices[32505] = {1, "T6"} -- Madness of the Betrayer (physical)
prices[32518] = {1, "T6"} -- Veil of Turning Leaves (leather - heal)
prices[31098] = {1, "T6"} -- Leggings of the Forgotten Conqueror (T6 Legs - paladin/priest/warlock)
prices[30993] = {1, "T6"} -- Paladin - T6 Legs
prices[30994] = {1, "T6"} --
prices[30995] = {1, "T6"} --
prices[31067] = {1, "T6"} -- Priest - T6 Legs
prices[31068] = {1, "T6"} --
prices[31053] = {1, "T6"} -- Warlock - T6 Legs
prices[31100] = {1, "T6"} -- Leggings of the Forgotten Protector (T6 Legs - warrior/hunter/shaman)
prices[30977] = {1, "T6"} -- Warrior - T6 Legs
prices[30978] = {1, "T6"} --
prices[31005] = {1, "T6"} -- Hunter - T6 Legs
prices[31019] = {1, "T6"} -- Shaman - T6 Legs
prices[31020] = {1, "T6"} --
prices[31021] = {1, "T6"} --
prices[31099] = {1, "T6"} -- Leggings of the Forgotten Vanquisher (T6 Legs - rogue/mage/druid)
prices[31029] = {1, "T6"} -- Rogue - T6 Legs
prices[31044] = {1, "T6"} -- Druid - T6 Legs
prices[31045] = {1, "T6"} --
prices[31046] = {1, "T6"} --
prices[31058] = {1, "T6"} -- Mage - T6 Legs
--- Illidan
prices[32837] = {0, "T6"} -- Warglaive of Azzinoth (rogue/warrior - mh)
prices[32838] = {0, "T6"} -- Warglaive of Azzinoth (rogue/warrior - oh)
prices[32336] = {1, "T6"} -- Black Bow of the Betrayer (hunter)
prices[32375] = {1, "T6"} -- Bulwark of Azzinoth (tank)
prices[32500] = {1, "T6"} -- Crystal Spire of Karabor (heal)
prices[32471] = {1, "T6"} -- Shard of Azzinoth (physical)
prices[32374] = {1, "T6"} -- Zhar'doom, Greatstaff of the Devourer (caster)
prices[32525] = {1, "T6"} -- Cowl of the Illidari High Lord (cloth - caster)
prices[32235] = {1, "T6"} -- Cursed Vision of Sargeras (leather - physical)
prices[32521] = {1, "T6"} -- Faceplate of the Impenetrable (plate - tank)
prices[32496] = {1, "T6"} -- Memento of Tyrande (heal)
prices[32524] = {1, "T6"} -- Shroud of the Highborne (heal)
prices[32497] = {1, "T6"} -- Stormrage Signet Ring (physical)
prices[32483] = {1, "T6"} -- The Skull of Gul'dan (caster)
prices[31089] = {1, "T6"} -- Chestguard of the Forgotten Conqueror (T6 Chest - paladin/priest/warlock)
prices[30990] = {1, "T6"} -- Paladin T6 Chest
prices[30991] = {1, "T6"} --
prices[30992] = {1, "T6"} --
prices[31052] = {1, "T6"} -- Warlock T6 Chest
prices[31065] = {1, "T6"} -- Priest T6 Chest
prices[31066] = {1, "T6"} --
prices[31091] = {1, "T6"} -- Chestguard of the Forgotten Protector (T6 Chest - warrior/hunter/shaman)
prices[30975] = {1, "T6"} -- Warrior T6 Chest
prices[30976] = {1, "T6"} --
prices[31004] = {1, "T6"} -- Hunter T6 Chest
prices[31016] = {1, "T6"} -- Shaman T6 Chest
prices[31017] = {1, "T6"} --
prices[31018] = {1, "T6"} --
prices[31090] = {1, "T6"} -- Chestguard of the Forgotten Vanquisher (T6 Chest - rogue/mage/druid)
prices[31028] = {1, "T6"} -- Rogue T6 Chest
prices[31041] = {1, "T6"} -- Druid T6 Chest
prices[31042] = {1, "T6"} --
prices[31043] = {1, "T6"} --
prices[31057] = {1, "T6"} -- Mage T5 Chest
-- Hyjal (IL141)
--- Trash
prices[32946] = {1, "T6"} -- Claw of Molten Fury (physical mh)
prices[32945] = {1, "T6"} -- Fist of Molten Fury (physical oh)
prices[34009] = {1, "T6"} -- Hammer of Judgement (caster)
prices[32609] = {1, "T6"} -- Boots of the Divine Light (cloth - heal)
prices[32592] = {1, "T6"} -- Chestguard of Relentless Storms (mail - caster)
prices[32590] = {1, "T6"} -- Nethervoid Cloak (cloth - caster shadow)
prices[34010] = {1, "T6"} -- Pepe's Shroud of Pacification (druid > tank)
prices[32591] = {1, "T6"} -- Choker of Serrated Blades (physical)
prices[32589] = {1, "T6"} -- Hellfire-Encased Pendant (caster fire)
--- Rage Winterchill
prices[30862] = {1, "T6"} -- Blessed Adamantite Bracers (plate - heal)
prices[30866] = {1, "T6"} -- Blood-stained Pauldrons (plate - melee)
prices[30871] = {1, "T6"} -- Bracers of Martyrdom (cloth - heal)
prices[30864] = {1, "T6"} -- Bracers of the Pathfinder (mail - physical)
prices[30872] = {1, "T6"} -- Chronicle of Dark Secrets (caster)
prices[30870] = {1, "T6"} -- Cuffs of Devastation (cloth - caster)
prices[30863] = {1, "T6"} -- Deadly Cuffs (leather - physical)
prices[30861] = {1, "T6"} -- Furious Shackles (plate - melee)
prices[30869] = {1, "T6"} -- Howling Wind Bracers (mail - heal)
prices[30868] = {1, "T6"} -- Rejuvenating Bracers (leather - heal)
prices[30873] = {1, "T6"} -- Stillwater Boots (mail - heal)
prices[30865] = {1, "T6"} -- Tracker's Blade (physical)
--- Anetheron
prices[30888] = {1, "T6"} -- Anetheron's Noose (cloth - caster)
prices[30885] = {1, "T6"} -- Archbishop's Slippers (cloth - caster)
prices[30882] = {1, "T6"} -- Bastion of Light (heal)
prices[30881] = {1, "T6"} -- Blade of Infamy (physical)
prices[30879] = {1, "T6"} -- Don Alejandro's Money Belt (leather - physical)
prices[30886] = {1, "T6"} -- Enchanted Leather Sandals (leather - caster)
prices[30878] = {1, "T6"} -- Glimmering Steel Mantle (plate - caster)
prices[30887] = {1, "T6"} -- Golden Links of Restoration (mail - heal)
prices[30884] = {1, "T6"} -- Hatefury Mantle (cloth - caster)
prices[30883] = {1, "T6"} -- Pillar of Ferocity (druid - feral)
prices[30880] = {1, "T6"} -- Quickstrider Moccasins (mail - physical)
prices[30874] = {1, "T6"} -- The Unbreakable Will (tank)
--- Kaz'rogal
prices[30895] = {1, "T6"} -- Angelista's Sash (cloth - heal)
prices[30892] = {1, "T6"} -- Beast-tamer's Shoulders (mail - hunter)
prices[30915] = {1, "T6"} -- Belt of Seething Fury (plate - melee)
prices[30914] = {1, "T6"} -- Belt of the Crescent Moon (leather - caster)
prices[30891] = {1, "T6"} -- Black Featherlight Boots (leather - physical)
prices[30894] = {1, "T6"} -- Blue Suede Shoes (cloth - caster)
prices[30918] = {1, "T6"} -- Hammer of Atonement (heal)
prices[30889] = {1, "T6"} -- Kaz'rogal's Hardened Heart (tank)
prices[30916] = {1, "T6"} -- Leggings of Channeled Elements (cloth - caster)
prices[30917] = {1, "T6"} -- Razorfury Mantle (leather - physical)
prices[30893] = {1, "T6"} -- Sun-touched Chain Leggings (mail - heal)
prices[30919] = {1, "T6"} -- Valestalker Girdle (mail - physical)
--- Azgalor
prices[30901] = {1, "T6"} -- Boundless Agony (physical)
prices[30900] = {1, "T6"} -- Bow-stitched Leggings (mail - physical)
prices[30899] = {1, "T6"} -- Don Rodrigo's Poncho (leather - heal)
prices[30897] = {1, "T6"} -- Girdle of Hope (plate - heal)
prices[30896] = {1, "T6"} -- Glory of the Defender (plate - tank)
prices[30898] = {1, "T6"} -- Shady Dealer's Pantaloons (leather - physical)
prices[31092] = {1, "T6"} -- Gloves of the Forgotten Conqueror (T6 Gloves - paladin/priest/warlock)
prices[30982] = {1, "T6"} -- Paladin T6 Gloves
prices[30983] = {1, "T6"} --
prices[30985] = {1, "T6"} --
prices[31050] = {1, "T6"} -- Warlock T6 Gloves
prices[31060] = {1, "T6"} -- Priest T6 Gloves
prices[31061] = {1, "T6"} --
prices[31094] = {1, "T6"} -- Gloves of the Forgotten Protector (T6 Gloves - warrior/hunter/shaman)
prices[30969] = {1, "T6"} -- Warrior T6 Gloves
prices[30970] = {1, "T6"} --
prices[31001] = {1, "T6"} -- Hunter T6 Gloves
prices[31007] = {1, "T6"} -- Shaman T6 Gloves
prices[31008] = {1, "T6"} --
prices[31011] = {1, "T6"} --
prices[31093] = {1, "T6"} -- Gloves of the Forgotten Vanquisher (T6 Gloves - rogue/mage/druid)
prices[31026] = {1, "T6"} -- Rogue T6 Gloves
prices[31032] = {1, "T6"} -- Druid T6 Gloves
prices[31034] = {1, "T6"} --
prices[31035] = {1, "T6"} --
prices[31055] = {1, "T6"} -- Mage T6 Gloves
--- Archimonde
prices[30909] = {1, "T6"} -- Antonidas's Aegis of Rapt Concentration (caster)
prices[30908] = {1, "T6"} -- Apostle of Argus (heal)
prices[30906] = {1, "T6"} -- Bristleblitz Striker (physical)
prices[30902] = {1, "T6"} -- Cataclysm's Edge (melee)
prices[30912] = {1, "T6"} -- Leggings of Eternity (cloth - heal)
prices[30903] = {1, "T6"} -- Legguards of Endless Rage (plate - melee)
prices[30907] = {1, "T6"} -- Mail of Fevered Pursuit (mail - physical)
prices[30905] = {1, "T6"} -- Midnight Chestguard (leather - physical)
prices[30913] = {1, "T6"} -- Robes of Rhonin (cloth - caster)
prices[30904] = {1, "T6"} -- Savior's Grasp (plate - heal)
prices[30911] = {1, "T6"} -- Scepter of Purification (heal)
prices[30910] = {1, "T6"} -- Tempest of Chaos (caster)
prices[31097] = {1, "T6"} -- Helm of the Forgotten Conqueror (T6 Head - paladin/priest/warlock)
prices[30987] = {1, "T6"} -- Paladin T6 Head
prices[30988] = {1, "T6"} --
prices[30989] = {1, "T6"} --
prices[31051] = {1, "T6"} -- Warlock T6 Head
prices[31063] = {1, "T6"} -- Priest T6 Head
prices[31064] = {1, "T6"} --
prices[31095] = {1, "T6"} -- Helm of the Forgotten Protector (T6 Head - warrior/hunter/shaman)
prices[30972] = {1, "T6"} -- Warrior T6 Head
prices[30974] = {1, "T6"} --
prices[31003] = {1, "T6"} -- Hunter T6 Head
prices[31012] = {1, "T6"} -- Shaman T6 Head
prices[31014] = {1, "T6"} --
prices[31015] = {1, "T6"} --
prices[31096] = {1, "T6"} -- Helm of the Forgotten Vanquisher (T6 Head - rogue/mage/druid)
prices[31027] = {1, "T6"} -- Rogue T6 Head
prices[31037] = {1, "T6"} -- Druid T6 Head
prices[31039] = {1, "T6"} --
prices[31040] = {1, "T6"} --
prices[31056] = {1, "T6"} -- Mage T6 Head
-- ZA (IL133-138)
--- Timed
prices[33809] = {0, "T5"} -- Amani War Bear
prices[33496] = {1, "T5"} -- Signet of Primal Wrath (physical)
prices[33497] = {1, "T5"} -- Mana Attuned Band (caster)
prices[33498] = {1, "T5"} -- Signet of the Quiet Forest (heal)
prices[33499] = {1, "T5"} -- Signet of the Last Defender (warrior/pala tank)
prices[33500] = {1, "T5"} -- Signet of Eternal Life (pvp > tank)
prices[33490] = {1, "T5"} -- Staff of Dark Mending (heal)
prices[33491] = {1, "T5"} -- Tuskbreaker (physical)
prices[33492] = {1, "T5"} -- Trollbane (physical)
prices[33493] = {1, "T5"} -- Umbral Shiv (physical)
prices[33494] = {1, "T5"} -- Amani Divining Staff (caster)
prices[33495] = {1, "T5"} -- Rage (physical)
prices[33480] = {1, "T5"} -- Cord of Braided Troll Hair (Cloth - heal)
prices[33481] = {1, "T5"} -- Pauldrons of Stone Resolve (Plate - tank)
prices[33483] = {1, "T5"} -- Life-step Belt (Leather - heal)
prices[33489] = {1, "T5"} -- Mantle of Ill Intent (cloth - caster)
prices[33590] = {1, "T5"} -- Cloak of Fiends (physical)
prices[33591] = {1, "T5"} -- Shadowcaster's Drape (cloth - caster)
prices[33805] = {1, "T5"} -- Shadowhunter's Treads (Mail - physical)
prices[33971] = {1, "T5"} -- Elunite Imbued Leggings (Leather - caster)
--- Nalorakk
prices[33211] = {1, "T5"} -- Bladeangel's Money Belt (Leather - physical)
prices[33640] = {1, "T5"} -- Fury (physical)
prices[33285] = {1, "T5"} -- Fury of the Ursine (Cloth - caster)
prices[33191] = {1, "T5"} -- Jungle Stompers (Plate - tank)
prices[33327] = {1, "T5"} -- Mask of Introspection (Plate - heal)
prices[33206] = {1, "T5"} -- Pauldrons of Primal Fury (Mail - physical)
prices[33203] = {1, "T5"} -- Robes of Heavenly Purpose (Cloth - heal)
--- Jan'Alai
prices[33328] = {1, "T5"} -- Arrow-fall Chestguard (Mail - physical)
prices[33326] = {1, "T5"} -- Bulwark of the Amani Empire (tank)
prices[33332] = {1, "T5"} -- Enamelled Disc of Mojo (heal)
prices[33357] = {1, "T5"} -- Footpads of Madness (Cloth - caster)
prices[33356] = {1, "T5"} -- Helm of Natural Regeneration (Leather - heal)
prices[33329] = {1, "T5"} -- Shadowtooth Trollskin Cuirass (Leather - physical)
prices[33354] = {1, "T5"} -- Wub's Cursed Hexblade (caster)
--- Akil'zon
prices[33214] = {1, "T5"} -- Akil'zon's Talonblade (physical oh/tank mh)
prices[33283] = {1, "T5"} -- Amani Punisher (caster)
prices[33215] = {1, "T5"} -- Bloodstained Elven Battlevest (Plate - melee)
prices[33281] = {1, "T5"} -- Brooch of Nature's Mercy (heal)
prices[33216] = {1, "T5"} -- Chestguard of Hidden Purpose (Plate - heal)
prices[33286] = {1, "T5"} -- Mojo-mender's Mask (Mail - heal)
prices[33293] = {1, "T5"} -- Signet of Ancient Magics (caster)
--- Halazzi
prices[33533] = {1, "T5"} -- Avalanche Leggings (Mail - caster)
prices[33317] = {1, "T5"} -- Robe of Departed Spirits (Cloth - caster)
prices[33322] = {1, "T5"} -- Shimmer-pelt Vest (Leather - heal)
prices[33300] = {1, "T5"} -- Shoulderpads of Dancing Blades (Leather - physical)
prices[33303] = {1, "T5"} -- Skullshatter Warboots (Plate - melee)
prices[33299] = {1, "T5"} -- Spaulders of the Advocate (Plate - heal)
prices[33297] = {1, "T5"} -- The Savage's Choker (physical)
--- Malacrass
prices[33421] = {1, "T5"} -- Battleworn Tuskguard (Plate - tank)
prices[33592] = {1, "T5"} -- Cloak of Ancient Rituals (heal)
prices[33432] = {1, "T5"} -- Coif of the Jungle Stalker (Mail - physical)
prices[33389] = {1, "T5"} -- Dagger of Bad Mojo (physical)
prices[33446] = {1, "T5"} -- Girdle of Stromgarde's Hope (Plate - heal)
prices[33388] = {1, "T5"} -- Heartless (physical)
prices[33464] = {1, "T5"} -- Hex Lord's Voodoo Pauldrons (Mail - heal)
prices[33829] = {1, "T5"} -- Hex Shrunken Head (caster)
prices[33453] = {1, "T5"} -- Hood of Hexing (Cloth - caster)
prices[33463] = {1, "T5"} -- Hood of the Third Eye (Cloth - heal)
prices[33298] = {1, "T5"} -- Prowler's Strikeblade (physical)
prices[33465] = {1, "T5"} -- Staff of Primal Fury (druid - physical)
prices[34029] = {1, "T5"} -- Tiny Voodoo Mask (all)
prices[33828] = {1, "T5"} -- Tome of Diabolic Remedy (heal)
--- Zul'jin
prices[33102] = {0, "T5"} -- Blood of Zul'jin (10 badges - all)
prices[33474] = {1, "T5"} -- Ancient Amani Longbow (physical)
prices[33830] = {1, "T5"} -- Ancient Aqir Artifact (paladin/warrior - tank)
prices[33831] = {1, "T5"} -- Berserker's Call (physical)
prices[33467] = {1, "T5"} -- Blade of Twisted Visions (caster)
prices[33473] = {1, "T5"} -- Chestguard of the Warlord (Plate - tank)
prices[33476] = {1, "T5"} -- Cleaver of the Unforgiving (warrior>paladin tank)
prices[33468] = {1, "T5"} -- Dark Blessing (heal)
prices[33479] = {1, "T5"} -- Grimgrin Faceguard (Leather - physical)
prices[33469] = {1, "T5"} -- Hauberk of the Empire's Champion (Mail - heal)
prices[33478] = {1, "T5"} -- Jin'rohk, The Great Apocalypse (physical)
prices[33466] = {1, "T5"} --  Loop of Cursed Bones (caster)
prices[33471] = {1, "T5"} -- Two-toed Sandals (Cloth - heal)
-- Sunwell (IL154-159)
--- Trash
prices[34349] = {1, "T6.5"} -- Blade of Life's Inevitability (physical)
prices[34346] = {1, "T6.5"} -- Mounting Vengeance (physical)
prices[34183] = {1, "T6.5"} -- Shivering Felspine (physical)
prices[34348] = {1, "T6.5"} -- Wand of Cleansing Light (heal)
prices[34347] = {1, "T6.5"} -- Wand of the Demonsoul (caster)
prices[34351] = {1, "T6.5"} -- Tranquil Majesty Wraps (Leather - heal)
prices[34350] = {1, "T6.5"} -- Gauntlets of the Ancient Shadowmoon (Mail - caster)
prices[35733] = {1, "T6.5"} -- Ring of Harmonic Beauty (heal)
--- Kalecgos
prices[34166] = {1, "T6.5"} -- Band of Lucent Beams (heal)
prices[34169] = {1, "T6.5"} -- Breeches of Natural Aggression (Leather - caster)
prices[34164] = {1, "T6.5"} -- Dragonscale-Encrusted Longblade (physical oh / tank mh)
prices[34165] = {1, "T6.5"} -- Fang of Kalecgos (physical)
prices[34167] = {1, "T6.5"} -- Legplates of the Holy Juggernaut (Plate - heal)
prices[34170] = {1, "T6.5"} -- Pantaloons of Calming Strife (Cloth - heal)
prices[34168] = {1, "T6.5"} -- Starstalker Legguards (Mail - physical)
prices[34848] = {1, "T6"} -- Bracers of the Forgotten Conqueror (T6 bracers - paladin/priest/warlock)
prices[34431] = {1, "T6"} -- Paladin T6 Bracers
prices[34432] = {1, "T6"} --
prices[34433] = {1, "T6"} --
prices[34434] = {1, "T6"} -- Priest T6 Bracers
prices[34435] = {1, "T6"} --
prices[34436] = {1, "T6"} -- Warlock T6 Bracers
prices[34851] = {1, "T6"} -- Bracers of the Forgotten Protector (T6 Bracers - warrior/hunter/shaman)
prices[34437] = {1, "T6"} -- Shaman T6 Bracers
prices[34438] = {1, "T6"} --
prices[34439] = {1, "T6"} --
prices[34441] = {1, "T6"} -- Warrior T6 Bracers
prices[34442] = {1, "T6"} --
prices[34443] = {1, "T6"} -- Hunter T6 Bracers
prices[34852] = {1, "T6"} -- Bracers of the Forgotten Vanquisher (T6 Bracers - rogue/mage/druid)
prices[34444] = {1, "T6"} -- Druid T6 Bracers
prices[34445] = {1, "T6"} --
prices[34446] = {1, "T6"} --
prices[34447] = {1, "T6"} -- Mage T6 Bracers
prices[34448] = {1, "T6"} -- Rogue T6 Bracers
--- Brutallus
prices[34177] = {1, "T6.5"} -- Clutch of Demise (physical)
prices[34178] = {1, "T6.5"} -- Collar of the Pit Lord (tank)
prices[34180] = {1, "T6.5"} -- Felfury Legplates (Plate - melee)
prices[34179] = {1, "T6.5"} -- Heart of the Pit (caster)
prices[34181] = {1, "T6.5"} -- Leggings of Calamity (Cloth - caster)
prices[34176] = {1, "T6.5"} -- Reign of Misery (caster)
prices[34853] = {1, "T6"} -- Belt of the Forgotten Conqueror (T6 Belt - paladin/priest/warlock)
prices[34485] = {1, "T6"} -- Paladin T6 Belt
prices[34487] = {1, "T6"} --
prices[34488] = {1, "T6"} --
prices[34527] = {1, "T6"} -- Priest T6 Belt
prices[34528] = {1, "T6"} --
prices[34541] = {1, "T6"} -- Warlock T6 Belt
prices[34854] = {1, "T6"} -- Belt of the Forgotten Protector (T6 Belt - warrior/hunter/shaman)
prices[34542] = {1, "T6"} -- Shaman T6 Belt
prices[34543] = {1, "T6"} --
prices[34545] = {1, "T6"} --
prices[34546] = {1, "T6"} -- Warrior T6 Belt
prices[34547] = {1, "T6"} --
prices[34549] = {1, "T6"} -- Hunter T6 Belt
prices[34855] = {1, "T6"} -- Belt of the Forgotten Vanquisher (T6 Belt - rogue/mage/druid)
prices[34554] = {1, "T6"} -- Druid T6 Belt
prices[34555] = {1, "T6"} --
prices[34556] = {1, "T6"} --
prices[34557] = {1, "T6"} -- Mage T6 Belt
prices[34558] = {1, "T6"} -- Rogue T6 Belt
--- Felmyst
prices[34352] = {1, "T6.5"} -- Borderland Fortress Grips (Plate - tank)
prices[34184] = {1, "T6.5"} -- Brooch of the Highborne (heal)
prices[34186] = {1, "T6.5"} -- Chain Links of the Tumultuous Storm (Mail - caster)
prices[34182] = {1, "T6.5"} -- Grand Magister's Staff of Torrents (caster)
prices[34188] = {1, "T6.5"} -- Leggings of the Immortal Night (Leather - physical)
prices[34185] = {1, "T6.5"} -- Sword Breaker's Bulwark (tank)
prices[34856] = {1, "T6"} -- Boots of the Forgotten Conqueror (T6 Boots - paladin/priest/warlock)
prices[34559] = {1, "T6"} -- Paladin T6 Boots
prices[34560] = {1, "T6"} --
prices[34561] = {1, "T6"} --
prices[34562] = {1, "T6"} -- Priest T6 Boots
prices[34563] = {1, "T6"} --
prices[34564] = {1, "T6"} -- Warlock T6 Boots
prices[34857] = {1, "T6"} -- Boots of the Forgotten Protector (T6 Boots - warrior/hunter/shaman)
prices[34565] = {1, "T6"} -- Shaman T6 Boots
prices[34566] = {1, "T6"} --
prices[34567] = {1, "T6"} --
prices[34568] = {1, "T6"} -- Warrior T6 Boots
prices[34569] = {1, "T6"} --
prices[34570] = {1, "T6"} -- Hunter T6 Boots
prices[34858] = {1, "T6"} -- Boots of the Forgotten Vanquisher (T6 Boots - rogue/mage/druid)
prices[34571] = {1, "T6"} -- Druid T6 Boots
prices[34572] = {1, "T6"} --
prices[34573] = {1, "T6"} --
prices[34574] = {1, "T6"} -- Mage T6 Boots
prices[34575] = {1, "T6"} -- Rogue T6 Boots
--- Eredar Twins
prices[35290] = {1, "T5"} -- Sin'dorei Pendant of Conquest (Caster - pvp)
prices[35291] = {1, "T5"} -- Sin'dorei Pendant of Salvation (Healer - pvp)
prices[35292] = {1, "T5"} -- Sin'dorei Pendant of Triumph (Physical - pvp)
prices[34210] = {1, "T6.5"} -- Amice of the Convoker (Cloth - caster)
prices[34204] = {1, "T6.5"} -- Amulet of Unfettered Magics (caster)
prices[34199] = {1, "T6.5"} -- Archon's Gavel (heal)
prices[34189] = {1, "T6.5"} -- Band of Ruinous Delight (physical)
prices[34206] = {1, "T6.5"} -- Book of Highborne Hymns (heal)
prices[34190] = {1, "T6.5"} -- Crimson Paragon's Cover (tank)
prices[34208] = {1, "T6.5"} -- Equilibrium Epaulets (Mail - heal)
prices[34196] = {1, "T6.5"} -- Golden Bow of Quel'Thalas (hunter > physical)
prices[34203] = {1, "T6.5"} -- Grip of Mannoroth (physical)
prices[34194] = {1, "T6.5"} -- Mantle of the Golden Forest (Mail - physical)
prices[34192] = {1, "T6.5"} -- Pauldrons of Perseverance (Plate - tank)
prices[34202] = {1, "T6.5"} -- Shawl of Wonderment (Cloth - heal)
prices[34197] = {1, "T6.5"} -- Shiv of Exsanguination (physical)
prices[34195] = {1, "T6.5"} -- Shoulderpads of Vehemence (leather - physical)
prices[34205] = {1, "T6.5"} -- Shroud of Redeemed Souls (heal)
prices[34209] = {1, "T6.5"} -- Spaulders of Reclamation (Leather - heal)
prices[34193] = {1, "T6.5"} -- Spaulders of the Thalassian Savior (Plate - heal)
prices[34198] = {1, "T6.5"} -- Stanchion of Primal Instinct (Druid - physical)
--- M'uru
prices[34231] = {1, "T6.5"} -- Aegis of Angelic Fortune (heal)
prices[34427] = {1, "T6.5"} -- Blackened Naaru Sliver (physical)
prices[34232] = {1, "T6.5"} -- Fel Conquerer Raiments (Cloth - caster)
prices[34229] = {1, "T6.5"} -- Garments of Serene Shores (Mail - heal)
prices[34240] = {1, "T6.5"} -- Gauntlets of the Soothed Soul (Plate - heal)
prices[34430] = {1, "T6.5"} -- Glimmering Naaru Sliver (heal)
prices[34211] = {1, "T6.5"} -- Harness of Carnal Instinct (Leather - druid > physical)
prices[34216] = {1, "T6.5"} -- Heroic Judicator's Chestguard (Plate - pala tank)
prices[34214] = {1, "T6.5"} -- Muramasa (physical)
prices[34213] = {1, "T6.5"} -- Ring of Hardened Resolve (tank)
prices[34230] = {1, "T6.5"} -- Ring of Omnipotence (caster)
prices[34233] = {1, "T6.5"} -- Robes of Faltered Light (Cloth - heal)
prices[34234] = {1, "T6.5"} -- Shadowed Gauntlets of Paroxysm
prices[34429] = {1, "T6.5"} -- Shifting Naaru Sliver (caster)
prices[34428] = {1, "T6.5"} -- Steely Naaru Sliver (tank > physical/pvp)
prices[34228] = {1, "T6.5"} -- Vicious Hawkstrider Hauberk (Mail - physical)
prices[34215] = {1, "T6.5"} -- Warharness of Reckless Fury (Plate - melee)
prices[35282] = {1, "T5"} -- Sin'dorei Band of Dominance (caster - pvp)
prices[35283] = {1, "T5"} -- Sin'dorei Band of Salvation (heal - pvp)
prices[35284] = {1, "T5"} -- Sin'dorei Band of Triumph (physical - pvp)
--- Kil'jaeden
prices[34334] = {0, "T6.5"} -- Thori'dal, the Stars' Fury (Hunter > Rogue/Warrior)
prices[34341] = {1, "T6.5"} -- Borderland Paingrips (Plate - melee)
prices[34241] = {1, "T6.5"} -- Cloak of Unforgivable Sin (physical)
prices[34333] = {1, "T6.5"} -- Coif of Alleria (Mail - physical)
prices[34245] = {1, "T6.5"} -- Cover of Ursol the Wise (Leather - heal)
prices[34332] = {1, "T6.5"} -- Cowl of Gul'dan (Mail - caster)
prices[34339] = {1, "T6.5"} -- Cowl of Light's Purity (Cloth - heal)
prices[34345] = {1, "T6.5"} -- Crown of Anasterian (Plate - melee)
prices[34340] = {1, "T6.5"} -- Dark Conjuror's Collar (Cloth - caster)
prices[34244] = {1, "T6.5"} -- Duplicitous Guise (Leather - physical)
prices[34344] = {1, "T6.5"} -- Handguards of Defiled Worlds (Cloth - caster)
prices[34342] = {1, "T6.5"} -- Handguards of the Dawn (Cloth - heal)
prices[34243] = {1, "T6.5"} -- Helm of Burning Righteousness (Plate - heal)
prices[34242] = {1, "T6.5"} -- Tattered Cape of Antonidas (caster)
prices[34343] = {1, "T6.5"} -- Thalassian Ranger Gauntlets (Mail - physical)
prices[34247] = {1, "T6.5"} -- Apolyon, the Soul-Render (physical)
prices[34329] = {1, "T6.5"} -- Crux of the Apocalypse (physical)
prices[34337] = {1, "T6.5"} -- Golden Staff of the Sin'dorei (heal)
prices[34331] = {1, "T6.5"} -- Hand of the Deceiver (physical)
prices[34336] = {1, "T6.5"} -- Sunflare (caster)
local progress_scaling = {
  ["T6.5"] =  {["T6.5"]=1,["T6"]=1.2,["T5"]=1.4,["T4"]=1.6},
  ["T6"] =    {["T6.5"]=1,["T6"]=1.2,["T5"]=1.4,["T4"]=1.6},
  ["T5"] =    {["T6.5"]=1,["T6"]=1.2,["T5"]=1.4,["T4"]=1.6},
  ["T4"] =    {["T6.5"]=1,["T6"]=1.2,["T5"]=1.4,["T4"]=1.6}
}
local function get_adjusted_price(price,tier,progress)
  if not progress_scaling[progress] then return price end
  if not progress_scaling[progress][tier] then return price end
  return math.floor(progress_scaling[progress][tier] * price)
end

function bepgp_prices_bc:GetPrice(item,progress)
  if not (type(item)=="number" or type(item)=="string") then return end
  if not progress then progress = "T3" end
  local price,itemID,data,tier
  itemID = GetItemInfoInstant(item)
  if (itemID) then
    data = prices[itemID]
    if (data) then
      price, tier = data[1], data[2]
      price = get_adjusted_price(price,tier,progress)
    else
      return
    end
  end
  return price
end

function bepgp_prices_bc:OnEnable()
  bepgp:RegisterPriceSystem(name_version,bepgp_prices_bc.GetPrice)
  local mzt,_,_,_,reason = GetAddOnInfo("MizusRaidTracker")
  if not (reason == "ADDON_MISSING" or reason == "ADDON_DISABLED") then
    local loaded, finished = IsAddOnLoaded("MizusRaidTracker")
    if loaded then
      self:ADDON_LOADED("ADDON_LOADED","MizusRaidTracker")
    else
      self:RegisterEvent("ADDON_LOADED")
    end
  end
end

function bepgp_prices_bc:ADDON_LOADED(event,...)
  if ... == "MizusRaidTracker" then
    self:UnregisterEvent("ADDON_LOADED")
    local MRT_ItemCost = function(mrt_data)
      local itemstring = mrt_data.ItemString
      local dkpValue = self:GetPrice(itemstring, bepgp.db.profile.progress)
      local itemNote
      if not dkpValue then
        dkpValue = 0
        itemNote = ""
      else
        local dkpValue2 = math.floor(dkpValue*bepgp.db.profile.discount)
        itemNote = string.format("%d or %d", dkpValue, dkpValue2)
      end
      return dkpValue, mrt_data.Looter, itemNote, "", true
    end
    if MRT_RegisterItemCostHandlerCore then
      MRT_RegisterItemCostHandlerCore(MRT_ItemCost, addonName)
    end
  end
end
bepgp_prices_bc._prices = prices