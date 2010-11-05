local module = {}
module.name = "Raid"
module.Init = function()
	if not SCDB.modules[module.name] then return end
   
   SetCVar("raidFramesDisplayAggroHighlight", 1)
   SetCVar("raidFramesDisplayClassColor", 1)
   SetCVar("raidOptionShowBorders", 0)

   local CanDispel = {
      PRIEST = { Magic = true, Disease = true, },
      SHAMAN = { Magic = true, Curse = true, },
      PALADIN = { Magic = true, Poison = true, Disease = true, },
      MAGE = { Curse = true, },
      DRUID = { Magic = true, Curse = true, Poison = true, }
   }
   local dispellist = CanDispel[select(2,UnitClass("player"))] or {}
   
   local function GetDebuffType(unit)
      if not unit then return end
      if not UnitCanAssist("player", unit) then return nil end
      local i = 1
      while true do
         local _, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
         if not texture then break end
         if debufftype and dispellist[debufftype] then
            return debufftype, texture
         end
         i = i + 1
      end
   end
   
   if SCDB[module.name] == nil then SCDB[module.name] = {} end
   
   if SCDB[module.name]["Show solo"] == nil then SCDB[module.name]["Show solo"] = false end
   
   local Texture_SetSize = ActionButton1Icon.SetSize
   local fixedFrames = {}
   
   function styleCompactFrame(frame)
      frame.name:SetFontObject(GameFontHighlightLarge)
      frame.name:ClearAllPoints()
      frame.name:SetPoint("CENTER")
      
      local buffs = frame.buffFrames
      local debuffs = frame.debuffFrames
      local d_debuffs = frame.dispelDebuffFrames
      
      for i=1,3 do
         Texture_SetSize(buffs[i], 12, 12)
         Texture_SetSize(debuffs[i], 24, 24)
         Texture_SetSize(d_debuffs[i], 12, 12)
         debuffs[i]:ClearAllPoints()
         debuffs[i]:SetPoint("CENTER")
         debuffs[i].noOCC = true
      end
      
      buffs[1]:ClearAllPoints()
      buffs[1]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
      
      --frame.healthBar:SetStatusBarTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2", "BORDER")
      frame.healthBar:SetStatusBarTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
      frame.healthBar:GetStatusBarTexture():SetTexCoord(0.8203125, 1.0, 0.34375, 0.484375)
   
      
      --frame.background:SetTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar", "BORDER")
      --frame.background:SetTexCoord(0.8203125, 1.0, 0.34375, 0.484375)
      --frame.background:SetVertexColor(.1, .1, .1)
      
      if not fixedFrames[frame] then
         fixedFrames[frame] = true
         frame:RegisterEvent("RAID_TARGET_UPDATE")
         frame.raidIcon = frame:CreateTexture(frame:GetName().."RaidTarget", "BORDER")
         frame.raidIcon:SetWidth(16)
         frame.raidIcon:SetHeight(16)
         frame.raidIcon:SetPoint("TOPRIGHT", -2, -2)
         frame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
         frame.raidIcon:Hide()
         
         frame.DebuffHighlight = frame:CreateTexture(frame:GetName().."RaidDebuffIcon", "OVERLAY")
         frame.DebuffHighlight:SetWidth(26)
         frame.DebuffHighlight:SetHeight(26)
         frame.DebuffHighlight:SetPoint("CENTER")
         
         -- make debuffs 12x12
         for i=1,3 do
            hooksecurefunc(debuffs[i], "SetSize", function(debuffFrame) 
               debuffFrame:Hide()
            end)
         end
      end
   end

   local showRaidIcon = function(self)
      if not self.unit then return end
      local index = GetRaidTargetIndex(self.unit)
      local icon = self.raidIcon
      if index then
         SetRaidTargetIconTexture(icon, index)
         icon:Show()
      else
         icon:Hide()
      end
   end
   
   local showDebuff = function(self)
      if not self.unit then return end
      local debuffType, texture  = GetDebuffType(self.unit)
      if debuffType then
         self.DebuffHighlight:SetTexture(texture)
      else
         self.DebuffHighlight:SetTexture(nil)
      end
   end
         
   hooksecurefunc("CompactUnitFrame_OnEvent", function(self, event, ...)
      local arg1, arg2, arg3, arg4 = ...
      if ( event == "RAID_TARGET_UPDATE") then
         showRaidIcon(self)
      elseif (event == "UNIT_AURA") then
         showDebuff(self)
      elseif (event == "PLAYER_ENTERING_WORLD") then
         showRaidIcon(self)
         showDebuff(self)
      end
   end)
   
   hooksecurefunc("DefaultCompactUnitFrameSetup", styleCompactFrame)
   hooksecurefunc("DefaultCompactMiniFrameSetup", styleCompactFrame)
   hooksecurefunc("CompactRaidFrameReservation_RegisterReservation", function(_, frame, _) styleCompactFrame(frame) end)

   hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
      if frame.name and #frame.name:GetText() > 8 then
         frame.name:SetText(frame.name:GetText():sub(1,8))
      end
   end)

   hooksecurefunc("CompactRaidFrameManager_UpdateContainerBounds", function(frame)
      frame.containerResizeFrame:SetMaxResize(frame.containerResizeFrame:GetWidth(), (GetScreenHeight()*2) - 90)
   end)

   hooksecurefunc("CompactRaidFrameManager_ResizeFrame_CheckMagnetism", function(manager)
      local point, relativeTo, relativePoint, xOffset, yOffset = manager.containerResizeFrame:GetPoint(1)
      if relativeTo == manager then
         CompactRaidFrameManager_ResetContainerPosition()
      end
   end)
   
   if SCDB[module.name]["Show solo"] == true then
      hooksecurefunc("CompactPartyFrame_UpdateShown", function(self)
         if GetCVarBool("useCompactPartyFrames") and not UnitInRaid("player") then
            self:Show()
         else
            self:Hide()
         end
      end)
      
      CompactPartyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

      hooksecurefunc("CompactPartyFrame_OnEvent", function(self, event, ...)
         if ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
            CompactPartyFrame_UpdateShown(self)
         end
      end)
   end
   
end
tinsert(SuperClassic.modules, module) -- finish him!