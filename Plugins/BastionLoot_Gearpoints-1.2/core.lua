local addonName, prices = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(prices, addonName)
local GP = LibStub("LibGearPoints-1.2-MRT")

local name_version = "GearPoints-1.2"
function prices:OnEnable()
  if BastionLoot and BastionLoot.RegisterPriceSystem then
    BastionLoot:RegisterPriceSystem(name_version, prices.GetPrice)
  end
end

function prices:num_round(i)
  return math.floor(i+0.5)
end

function prices:GetPrice(item)
  local high, low, level, rarity, equipLoc = GP:GetValue(item)
  high = high or 0
  low = low or 0
  return self:num_round(high/10), self:num_round(low/10)
end

_G[addonName]=prices
