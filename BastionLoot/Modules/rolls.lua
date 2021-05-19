local addonName, bepgp = ...
local moduleName = addonName.."_rolls"
local bepgp_rolls = bepgp:NewModule(moduleName, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

bepgp_rolls.special_recipients = {}
bepgp_rolls.eligible_recipients = {}

function bepgp_rolls:ToggleMenus(flag)
  if flag then
    local frame_name = moduleName.."ExtraFrame"
    self._extraFrame = self._extraFrame or CreateFrame("Frame",frame_name, UIParent)
    self._extraFrame:SetWidth(150)
    self._extraFrame:SetHeight(40)
    self._extraFrame:SetFrameStrata("DIALOG")
    self._extraFrame.btnBanker = CreateFrame("Button", frame_name.."Banker", self._extraFrame, "UIMenuButtonStretchTemplate")
    self._extraFrame.btnBanker:SetHeight(20)
    self._extraFrame.btnDisenchanter = CreateFrame("Button", frame_name.."Disenchanter", self._extraFrame, "UIMenuButtonStretchTemplate")
    self._extraFrame.btnDisenchanter:SetHeight(20)
    self._extraFrame.btnBanker:SetPoint("TOPLEFT",self._extraFrame,"TOPLEFT",0,0)
    self._extraFrame.btnBanker:SetPoint("TOPRIGHT",self._extraFrame,"TOPRIGHT",0,0)
    self._extraFrame.btnDisenchanter:SetPoint("BOTTOMLEFT",self._extraFrame,"BOTTOMLEFT",0,0)
    self._extraFrame.btnDisenchanter:SetPoint("BOTTOMRIGHT",self._extraFrame,"BOTTOMRIGHT",0,0)
    self._extraFrame.btnBanker.Text:SetPoint("LEFT",self._extraFrame.btnBanker,"LEFT", 15, -1)
    self._extraFrame.btnBanker:SetText(L["Set Banker"])
    self._extraFrame.btnDisenchanter.Text:SetPoint("LEFT",self._extraFrame.btnDisenchanter,"LEFT", 15, -1)
    self._extraFrame.btnDisenchanter:SetText(L["Set Disenchanter"])
    self._extraFrame.btnBanker:SetScript("OnClick",bepgp_rolls.SetBanker)
    self._extraFrame.btnDisenchanter:SetScript("OnClick",bepgp_rolls.SetDisenchanter)
    self._extraFrame.btnBanker:SetScript("OnEnter",bepgp_rolls.StopMenuTimer)
    self._extraFrame.btnBanker:SetScript("OnLeave",bepgp_rolls.StartMenuTimer)
    self._extraFrame.btnDisenchanter:SetScript("OnEnter",bepgp_rolls.StopMenuTimer)
    self._extraFrame.btnDisenchanter:SetScript("OnLeave",bepgp_rolls.StartMenuTimer)
    self._extraFrame:Hide()
    if not self:IsHooked(DropDownList1, "OnShow") then
      self:SecureHookScript(DropDownList1,"OnShow","ExtraShow")
    end
    if not self:IsHooked(DropDownList1, "OnHide") then
      self:SecureHookScript(DropDownList1,"OnHide","ExtraHide")
    end
  else
    self:Unhook(DropDownList1,"OnShow")
    self:Unhook(DropDownList1,"OnHide")
  end
end

function bepgp_rolls:ExtraShow()
  if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU.which == "RAID" then
    self._extraFrame:SetPoint("BOTTOMLEFT",DropDownList1,"TOPLEFT")
    self._extraFrame:SetWidth(DropDownList1:GetWidth())
    self._extraFrame:Show()
  end
end

function bepgp_rolls:ExtraHide()
  self._extraFrame:Hide()
end

function bepgp_rolls:StopMenuTimer()
  if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU.which == "RAID" then
    UIDropDownMenu_StopCounting(DropDownList1)
  end
end

function bepgp_rolls:StartMenuTimer()
  if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU.which == "RAID" then
    UIDropDownMenu_StartCounting(DropDownList1)
  end
end

function bepgp_rolls:SetBanker()
  local name = UIDROPDOWNMENU_OPEN_MENU.name
  if type(name)=="string" then
    bepgp_rolls.special_recipients.BANKER = name
    bepgp:Print(L["Banker"]..":"..name)
  end
  CloseDropDownMenus()
end

function bepgp_rolls:SetDisenchanter()
  local name = UIDROPDOWNMENU_OPEN_MENU.name
  if type(name)=="string" then
    bepgp_rolls.special_recipients.DISENCHANTER = name
    bepgp:Print(L["Disenchanter"]..":"..name)
  end
  CloseDropDownMenus()
end

function bepgp_rolls:resetMasterLootAdditions()
  self._playerFrame.tooltip = nil
  self._bankerFrame.tooltip = nil
  self._disenchanterFrame.tooltip = nil
  self._randomFrame.tooltip = nil
  self._playerFrame.Name:SetText("")
  self._bankerFrame.Name:SetText("")
  self._disenchanterFrame.Name:SetText("")
  self._randomFrame.Name:SetText("")
  self._playerFrame.id = nil
  self._bankerFrame.id = nil
  self._disenchanterFrame.id = nil
  self._randomFrame.id = nil
  table.wipe(self.eligible_recipients)
end

function bepgp_rolls:positionMasterLootAdditions()
  local parent = MasterLooterFrame
  self._randomFrame:SetPoint("TOPLEFT",parent,"TOPRIGHT",5,-5)
  if self._randomFrame.id then
    self._randomFrame:Show()
  else
    self._randomFrame:Hide()
  end

  local anchor, point, x, y = self._randomFrame, "BOTTOMLEFT", 0, -5
  if not self._randomFrame:IsShown() then
    anchor, point, x, y = parent, "TOPRIGHT", 5,-5
  end
  self._playerFrame:SetPoint("TOPLEFT", anchor, point, x, y)
  if self._playerFrame.id then
    self._playerFrame:Show()
  else
    self._playerFrame:Hide()
  end

  anchor, point, x, y = self._playerFrame,"BOTTOMLEFT",0,-5
  if not self._playerFrame:IsShown() then
    anchor, point, x, y = self._randomFrame,"BOTTOMLEFT",0,-5
  end
  if not self._randomFrame:IsShown() then
    anchor, point, x, y = parent, "TOPRIGHT", 5,-5
  end
  self._bankerFrame:SetPoint("TOPLEFT",anchor,point,x,y)
  if self._bankerFrame.id then
    self._bankerFrame:Show()
  else
    self._bankerFrame:Hide()
  end

  anchor, point, x, y = self._bankerFrame, "BOTTOMLEFT",0,-5
  if not self._bankerFrame:IsShown() then
    anchor, point, x, y = self._playerFrame,"BOTTOMLEFT",0,-5
  end
  if not self._playerFrame:IsShown() then
    anchor, point, x, y = self._randomFrame,"BOTTOMLEFT",0,-5
  end
  if not self._randomFrame:IsShown() then
    anchor, point, x, y = parent, "TOPRIGHT", 5,-5
  end
  self._disenchanterFrame:SetPoint("TOPLEFT",anchor,point,x,y)
  if self._disenchanterFrame.id then
    self._disenchanterFrame:Show()
  else
    self._disenchanterFrame:Hide()
  end
end

function bepgp_rolls:MasterLooterFrame_UpdatePlayers()
  self:resetMasterLootAdditions()
  for key,frame in pairs(MasterLooterFrame) do
    if type(key) == "string" then
      local buttonIndex = key:match("player(%d+)")
      if buttonIndex then
        local id, name = frame.id, frame.Name:GetText()
        table.insert(self.eligible_recipients,{id,name})
        local banker, disenchanter = self.special_recipients.BANKER, self.special_recipients.DISENCHANTER
        if name == bepgp._playerName then
          self._playerFrame.id = id
          self._playerFrame.Name:SetText(L["Self"])
          self._playerFrame.tooltip = name
        end
        if banker and name == banker then
          self._bankerFrame.id = id
          self._bankerFrame.Name:SetText(L["Banker"])
          self._bankerFrame.tooltip = name
        end
        if disenchanter and name == disenchanter then
          self._disenchanterFrame.id = id
          self._disenchanterFrame.Name:SetText(L["Disenchanter"])
          self._disenchanterFrame.tooltip = name
        end
      end
    end
  end
  local num_recipients = #(self.eligible_recipients)
  if num_recipients > 0 then
    local random_recipient = random(1,num_recipients)
    local id, name = self.eligible_recipients[random_recipient][1], self.eligible_recipients[random_recipient][2]
    self._randomFrame.id = id
    self._randomFrame.Name:SetText(L["Random"])
    self._randomFrame.tooltip = string.format("%d:%s (1-%d)",random_recipient, name, num_recipients)
  end
  self:positionMasterLootAdditions()
end

function bepgp_rolls:CoreInit()
  if not self._initDone then
    self:CheckStatus()
  end
end

function bepgp_rolls:CheckStatus()
  if bepgp:admin() or bepgp:lootMaster() then
    if InCombatLockdown() then
      self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
      if not self:IsHooked("MasterLooterFrame_UpdatePlayers") then
        self:SecureHook("MasterLooterFrame_UpdatePlayers")
      end
      self:ToggleMenus(true)
      -- create our special buttons
      self._playerFrame = self._playerFrame or CreateFrame("BUTTON", nil, MasterLooterFrame, "MasterLooterPlayerTemplate")
      self._playerFrame:Hide()
      self._bankerFrame = self._bankerFrame or CreateFrame("BUTTON", nil, MasterLooterFrame, "MasterLooterPlayerTemplate")
      self._bankerFrame:Hide()
      self._disenchanterFrame = self._disenchanterFrame or CreateFrame("BUTTON", nil, MasterLooterFrame, "MasterLooterPlayerTemplate")
      self._disenchanterFrame:Hide()
      self._randomFrame = self._randomFrame or CreateFrame("BUTTON", nil, MasterLooterFrame, "MasterLooterPlayerTemplate")
      self._randomFrame:Hide()
      self._playerFrame.Bg:SetColorTexture(0, 0, 0, .75)
      self._bankerFrame.Bg:SetColorTexture(0, 0, 0, .75)
      self._disenchanterFrame.Bg:SetColorTexture(0, 0, 0, .75)
      self._randomFrame.Bg:SetColorTexture(0, 0, 0, .75)
      self._initDone = true
    end
  end
end

function bepgp_rolls:PLAYER_REGEN_ENABLED()
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  self:CheckStatus()
end

function bepgp_rolls:OnEnable()
  self:RegisterMessage(addonName.."_INIT_DONE","CoreInit")
  self:RegisterEvent("PARTY_LEADER_CHANGED","CheckStatus")
  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE",1.0,"CheckStatus")
  self:CheckStatus()
end
