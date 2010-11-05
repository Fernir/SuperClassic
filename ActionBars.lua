-- author: Allez
-- some rewrited

local module = {}
module.name = "ActionBars"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	local settings = SCDB
	
	-- Config start
	local size = 30
	local spacing = size/8
	local frame_positions = {
		[1]	=	{ a = "BOTTOM",     x = 0,   y = spacing/2  },	-- MainBar
		[2]	=	{ a = "BOTTOM",     x = 0,   y = size+spacing*4},	-- MultiBarBottomLeft
		[3]	=	{ a = "BOTTOM",     x = 0,   y = (size+spacing*3)*2  },	-- MultiBarBottomRight
		[4]	=	{ a = "RIGHT",      x = -35, y = 0   },	-- MultiBarLeft
		[5]	=	{ a = "RIGHT",      x = -3, y = 0   },	-- MultiBarRight
		[6]	=	{ a = "BOTTOM",     x = 0,   y = 120 },	-- PetBar
		[7]	=	{ a = "BOTTOMLEFT", x = 12,  y = 210 },	-- ShapeShiftBar
		[8]	=	{ a = "BOTTOM",       x = 220, y = 80  },	-- VehicleBar
	}
	-- Config end

	local CreateBarFrame = function(name, pos)
		local bar = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
		bar:SetPoint(pos.a, pos.x, pos.y)
		return bar
	end

	local SetButtons = function(bar, button, num, orient, bsize)
		local size = bsize or size
		spacing = size/8
		for i = 1, num do
			_G[button..i]:ClearAllPoints()
			_G[button..i]:SetAttribute("unit2", "player")
			_G[button..i]:SetWidth(size)
			_G[button..i]:SetHeight(size)
			if _G[button..i.."Cooldown"] then
				_G[button..i.."Cooldown"]:SetWidth(size)
				_G[button..i.."Cooldown"]:SetHeight(size)
				_G[button..i.."Cooldown"].SetWidth = function() end
				_G[button..i.."Cooldown"].SetHeight = function() end
			end
			if _G[button..i.."Shine"] then
				_G[button..i.."Shine"]:SetWidth(size)
				_G[button..i.."Shine"]:SetHeight(size)
				_G[button..i.."Shine"].SetWidth = function() end
				_G[button..i.."Shine"].SetHeight = function() end
			end
			if _G[button..i.."AutoCastable"] then
				_G[button..i.."AutoCastable"]:SetWidth(size*2)
				_G[button..i.."AutoCastable"]:SetHeight(size*2)
				_G[button..i.."AutoCastable"].SetWidth = function() end
				_G[button..i.."AutoCastable"].SetHeight = function() end
			end
			if i == 1 then
				_G[button..i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			else
				if orient == "H" then
					_G[button..i]:SetPoint("TOPLEFT", _G[button..(i-1)], "TOPRIGHT", spacing, 0)
				else
					_G[button..i]:SetPoint("TOPLEFT", _G[button..(i-1)], "BOTTOMLEFT", 0, -spacing)
				end
			end
		end
		if orient == "H" then
			bar:SetWidth(size*num + spacing*(num-1))
			bar:SetHeight(size)
		else
			bar:SetWidth(size)
			bar:SetHeight(size*num + spacing*(num-1))
		end
	end

	local bar1 = CreateBarFrame("mod_MainBar", frame_positions[1])
	local bar2 = CreateBarFrame("mod_MultiBarBottomLeftBar", frame_positions[2])
	local bar3 = CreateBarFrame("mod_MultiBarBottomRightBar", frame_positions[3])
	local bar4 = CreateBarFrame("mod_MultiBarLeftBar", frame_positions[4])
	local bar5 = CreateBarFrame("mod_MultiBarRightBar", frame_positions[5])
	local bar6 = CreateBarFrame("mod_PetBar", frame_positions[6])
	local bar7 = CreateBarFrame("mod_ShapeShiftBar", frame_positions[7])
	local bar8 = CreateBarFrame("mod_VehicleBar", frame_positions[8])
	
	 
	local VehicleLeaveButton = CreateFrame("Button", "VehicleLeaveButton1", UIParent)
	VehicleLeaveButton:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	VehicleLeaveButton:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	VehicleLeaveButton:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	VehicleLeaveButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
	VehicleLeaveButton:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	VehicleLeaveButton:SetScript("OnClick", function(self)
		VehicleExit()
	end)
	VehicleLeaveButton:SetScript("OnEvent", function(self)
		if CanExitVehicle() then
			self:Show()
		else
			self:Hide()
		end
	end)
	VehicleLeaveButton:Hide()

	for _, v in pairs({
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MultiBarLeft,
		MultiBarRight,
		PetActionBarFrame,
		ShapeshiftBarFrame,
	}) do
		v:SetParent(UIParent)
		v:SetWidth(0.01)
	end

	SetButtons(bar1, "ActionButton", NUM_ACTIONBAR_BUTTONS, "H")
	SetButtons(bar2, "MultiBarBottomLeftButton", NUM_MULTIBAR_BUTTONS, "H")
	SetButtons(bar3, "MultiBarBottomRightButton", NUM_MULTIBAR_BUTTONS, "H")
	SetButtons(bar4, "MultiBarLeftButton", NUM_MULTIBAR_BUTTONS, "V")
	SetButtons(bar5, "MultiBarRightButton", NUM_MULTIBAR_BUTTONS, "V")
	SetButtons(bar6, "PetActionButton", NUM_PET_ACTION_SLOTS, "H", 26)
	SetButtons(bar7, "ShapeshiftButton", NUM_SHAPESHIFT_SLOTS, "H", 26)
	SetButtons(bar8, "VehicleLeaveButton", 1, "H", 40)

	MainMenuBarTexture0:SetParent(bar1)
	MainMenuBarTexture0:SetDrawLayer("BACKGROUND")
	MainMenuBarTexture0:ClearAllPoints()
	MainMenuBarTexture0:SetPoint("TOPLEFT", bar1, "TOPLEFT", -spacing, spacing/2)
	MainMenuBarTexture0:SetPoint("BOTTOMRIGHT", bar1, "BOTTOM", 0, -spacing/2)
	
	MainMenuBarTexture1:SetParent(bar1)
	MainMenuBarTexture1:SetDrawLayer("BACKGROUND")
	MainMenuBarTexture1:ClearAllPoints()
	MainMenuBarTexture1:SetPoint("TOPLEFT", bar1, "TOP", 0, spacing/2)
	MainMenuBarTexture1:SetPoint("BOTTOMRIGHT", bar1, "BOTTOMRIGHT", spacing, -spacing/2)
	
	MainMenuMaxLevelBar0:SetParent(bar1)
	MainMenuMaxLevelBar0:SetDrawLayer("OVERLAY")
	MainMenuMaxLevelBar0:ClearAllPoints()
	MainMenuMaxLevelBar0:SetPoint("TOPLEFT", bar1, "TOPLEFT", -spacing, spacing*2)
	MainMenuMaxLevelBar0:SetPoint("BOTTOMRIGHT", bar1, "TOP", 0, 0)

	MainMenuMaxLevelBar1:SetParent(bar1)
	MainMenuMaxLevelBar1:SetDrawLayer("OVERLAY")
	MainMenuMaxLevelBar1:ClearAllPoints()
	MainMenuMaxLevelBar1:SetPoint("TOPLEFT", bar1, "TOP", 0, spacing*2)
	MainMenuMaxLevelBar1:SetPoint("BOTTOMRIGHT", bar1, "TOPRIGHT", 0, 0)

	MainMenuBarLeftEndCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
	MainMenuBarRightEndCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
	MainMenuBarLeftEndCap:SetParent(bar1)
	MainMenuBarLeftEndCap:ClearAllPoints()
	MainMenuBarLeftEndCap:SetPoint("BOTTOMRIGHT", bar1, "BOTTOMLEFT", 23, -5)
	MainMenuBarLeftEndCap:SetWidth(110)
	MainMenuBarLeftEndCap:SetHeight(110)
	MainMenuBarRightEndCap:SetParent(bar1)
	MainMenuBarRightEndCap:ClearAllPoints()
	MainMenuBarRightEndCap:SetPoint("BOTTOMLEFT", bar1, "BOTTOMRIGHT", -23, -5) 
	MainMenuBarRightEndCap:SetWidth(110)
	MainMenuBarRightEndCap:SetHeight(110)
	MainMenuBarLeftEndCap:SetDrawLayer("OVERLAY")
	MainMenuBarRightEndCap:SetDrawLayer("OVERLAY")
	
	hooksecurefunc("ShapeshiftBar_Update", function()
		if GetNumShapeshiftForms() == 1 and not InCombatLockdown() then
			ShapeshiftButton1:SetPoint("BOTTOMLEFT", bar7, "BOTTOMLEFT", 0, 0)
		end
	end)

	for _, obj in pairs({
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		BonusActionBarFrameTexture0,
		BonusActionBarFrameTexture1,
		BonusActionBarFrame,
		ShapeshiftBarLeft,
		ShapeshiftBarRight,
		ShapeshiftBarMiddle,
		MainMenuBar,
		VehicleMenuBar,
		PossessBarFrame,
	}) do
		if obj:GetObjectType() == 'Texture' then
			obj:SetTexture("")
		else
			obj:SetScale(0.001)
			obj:SetAlpha(0)
		end
	end
	
	local function UpdateActionBarsPos()
		local anchor
		local anchorOffset = 4
		
		if MultiBarBottomLeft:IsShown() then
			anchor = bar2
			anchorOffset = 4
		else
			anchor = bar1
			anchorOffset = 14
		end

		if MultiBarBottomRight:IsShown() then
			bar3:ClearAllPoints()
			bar3:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, anchorOffset )
			anchor = bar3
			anchorOffset = 4
		end

		if ShapeshiftButton1:IsShown() then
			bar7:ClearAllPoints()
			bar7:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, anchorOffset)
			--anchor = bar7
			anchorOffset = 4
		end

		if MultiCastActionBarFrame:IsShown() then
			MultiCastActionBarFrame:SetScript("OnUpdate", nil)
			MultiCastActionBarFrame:SetScript("OnShow", nil)
			MultiCastActionBarFrame:SetScript("OnHide", nil)
			MultiCastActionBarFrame:SetParent(bar1)
			MultiCastActionBarFrame:ClearAllPoints()
			MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, anchorOffset)
	 
			hooksecurefunc("MultiCastActionButton_Update", function(self) if not InCombatLockdown() then self:SetAllPoints(self.slotButton) end end)
	 
			MultiCastRecallSpellButton.SetPoint = function() end
			--anchor = MultiCastActionBarFrame
			anchorOffset = 4
		end
		
		bar6:ClearAllPoints()
		bar6:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, anchorOffset)
		anchor = bar6
		anchorOffset = 4
	end

	InterfaceOptionsActionBarsPanelBottomLeft:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelBottomRight:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelLockActionBars:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelSecureAbilityToggle:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelRightTwo:HookScript("OnClick", UpdateActionBarsPos)
	InterfaceOptionsActionBarsPanelRight:HookScript("OnClick", UpdateActionBarsPos)
	----------------------------------------------------------------------------------------
	--	Setup Main Action Bar by Tukz
	----------------------------------------------------------------------------------------

	--[[ 
		Bonus bar classes id

		DRUID: Caster: 0, Cat: 1, Tree of Life: 2, Bear: 3, Moonkin: 4
		WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
		ROGUE: Normal: 0, Stealthed: 1
		PRIEST: Normal: 0, Shadowform: 1
		
		When Possessing a Target: 5
	]]--

	local Page = {
		["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",		["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
		["PRIEST"] = "[bonusbar:1] 7;",
		["ROGUE"] = "[bonusbar:1] 7; [form:3] 10;",
		["WARLOCK"] = "[form:2] 10;",
		["DEFAULT"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;",
	}

	local GetBar = function()
		local condition = Page["DEFAULT"]
		local class = select(2, UnitClass('player'))
		local page = Page[class]
		if page then
			condition = condition.." "..page
		end
		condition = condition.." 1"
		return condition
	end

	bar1:RegisterEvent("PLAYER_LOGIN")
	bar1:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar1:RegisterEvent("PLAYER_TALENT_UPDATE")
	bar1:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	bar1:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
	bar1:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	bar1:RegisterEvent("BAG_UPDATE")

	bar1:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			PetActionBarFrame.showgrid = 1
			
			local button
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				button = _G["ActionButton"..i]
				self:SetFrameRef("ActionButton"..i, button)
			end	
			self:Execute([[
				buttons = table.new()
				for i = 1, 12 do
					table.insert(buttons, self:GetFrameRef("ActionButton"..i))
				end
			]])
			self:SetAttribute("_onstate-page", [[ 
				for i, button in ipairs(buttons) do
					button:SetAttribute("actionpage", tonumber(newstate))
				end
			]])
			RegisterStateDriver(self, "page", GetBar())
		elseif event == "PLAYER_ENTERING_WORLD" then
			MainMenuBar_UpdateKeyRing()
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				_G["ActionButton"..i]:SetParent(UIParent)
			end
		elseif event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
			if not InCombatLockdown() then
				RegisterStateDriver(self, "page", GetBar())
			end
		else
			UpdateActionBarsPos()
			MainMenuBar_OnEvent(self, event, ...)
		end
	end)
	
	bar6:RegisterEvent("PLAYER_LOGIN")
	bar6:RegisterEvent("PLAYER_CONTROL_LOST")
	bar6:RegisterEvent("PLAYER_CONTROL_GAINED")
	bar6:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar6:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	bar6:RegisterEvent("PET_BAR_UPDATE")
	bar6:RegisterEvent("PET_BAR_UPDATE_USABLE")
	bar6:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	bar6:RegisterEvent("PET_BAR_HIDE")
	bar6:RegisterEvent("UNIT_PET")
	bar6:RegisterEvent("UNIT_FLAGS")
	bar6:RegisterEvent("UNIT_AURA")
	
	bar6:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			PetActionBarFrame.showgrid = 1 -- hack to never hide pet button. :X

			local button
			for i = 1, 10 do
				button = _G["PetActionButton"..i]
				button:SetParent(self)
				self:SetAttribute("addchild", button)
			end
			RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		else
			UpdateActionBarsPos()
		end
	end)
end
tinsert(SuperClassic.modules, module) -- finish him!