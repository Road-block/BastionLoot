local addonName, bepgp = ...
local moduleName = addonName.."_tokens"
local bepgp_tokens = bepgp:NewModule(moduleName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)