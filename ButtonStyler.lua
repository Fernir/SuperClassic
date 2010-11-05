--Addon author: Allez
local module = {}
module.name = "Button Styler"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	if SCDB[module.name] == nil then SCDB[module.name] = {} end
	if SCDB[module.name]["Hide hotkeys"] == nil then SCDB[module.name]["Hide hotkeys"] = false end
	if SCDB[module.name]["Hide macro"] == nil then SCDB[module.name]["Hide macro"] = false end
	local opts = SCDB[module.name]

	-- Config start
	local update_timer = ATTACK_BUTTON_FLASH_TIME
	-- Config end

	local modSetBorderColor = function(button)
		if not button.bd then return end
		if button.pushed then
			button.bd:SetVertexColor(1, 1, 1)
		elseif button.hover then
			button.bd:SetVertexColor(144, 255, 0)
		elseif button.checked then
			button.bd:SetVertexColor(0, 144, 255)
		elseif button.equipped then
			button.bd:SetVertexColor(0, 0.5, 0)
		else
			button.bd:SetVertexColor(.6, .6, .6)
		end
	end

	local modActionButtonDown = function(id)
		local button
		if ( BonusActionBarFrame:IsShown() ) then
			button = _G["BonusActionButton"..id]
		else
			button = _G["ActionButton"..id]
		end
		button.pushed = true
		modSetBorderColor(button)
	end
	  
	local modActionButtonUp = function(id)
		local button;
		if ( BonusActionBarFrame:IsShown() ) then
			button = _G["BonusActionButton"..id]
		else
			button = _G["ActionButton"..id]
		end
		button.pushed = false
		modSetBorderColor(button)
	end

	local modMultiActionButtonDown = function(bar, id)
		local button = _G[bar.."Button"..id]
		button.pushed = true
		modSetBorderColor(button)
	end
	  
	local modMultiActionButtonUp = function(bar, id)
		local button = _G[bar.."Button"..id]
		button.pushed = false
		modSetBorderColor(button)
	end

	local modActionButton_UpdateState = function(button)
		local action = button.action
		if not button.bd then return end
		if ( IsCurrentAction(action) or IsAutoRepeatAction(action) ) then
			button.checked = true
		else
			button.checked = false
		end
		modSetBorderColor(button)
	end
	  
	local setStyle = function(bname)
		local button = _G[bname]
		local icon   = _G[bname.."Icon"]
		local flash  = _G[bname.."Flash"]
		local hotkey = _G[bname.."HotKey"]
		local macro  = _G[bname.."Name"]

		if icon then
			icon:SetDrawLayer("ARTWORK")
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
			icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
		end
		
		if hotkey then
			if opts["Hide hotkeys"]==false then 
				hotkey:SetDrawLayer("OVERLAY")
				hotkey:SetPoint("TOPRIGHT", -2, -2) 
				hotkey:SetFont(hotkey:GetFont(), 10, "OUTLINE")
			else
				hotkey:Hide()
			end
		end
		
		if macro then
			if opts["Hide macro"]==false then 
				macro:SetDrawLayer("OVERLAY")
				local font = hotkey:GetFont()
				macro:SetFont(font, 8, "OUTLINE")
			else
				macro:Hide()
			end
		end
		
		if not button.bd then
			local bd = button:CreateTexture(nil, "OVERLAY")
			bd:SetAllPoints(button)
			bd:SetTexture("Interface\\Buttons\\UI-TotemBar")
			bd:SetTexCoord(1 / 128, 35 / 128, 207 / 256, 240 / 256)
			
			--bd:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
			--bd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
			--bd:SetTexture("Interface\\Calendar\\CurrentDay")
			--bd:SetTexCoord(0.0078125, 0.57421875, 0.0390625, 0.5859375)
			bd:SetDesaturated(1)
			button.bd = bd
			
			button:HookScript("OnEnter", function(self)
				self.hover = true
				modSetBorderColor(self)
			end)
			button:HookScript("OnLeave", function(self)
				self.hover = false
				modSetBorderColor(self)
			end)
		end

		button:SetHighlightTexture("")
		button.SetHighlightTexture = function() end
		button:SetNormalTexture("")
		button.SetNormalTexture = function() end
		button:SetPushedTexture("")
		button.SetPushedTexture = function() end
		
		if flash then flash:SetTexture(""); flash.SetTexture = function() end end
	end

	local modActionButton_Update = function(self)
		if not self.styled and self:GetParent() and  self:GetParent():GetName() ~= "MultiCastActionBarFrame" and self:GetParent():GetName() ~= "MultiCastActionPage1" and self:GetParent():GetName() ~= "MultiCastActionPage2" and self:GetParent():GetName() ~= "MultiCastActionPage3" then
			local action = self.action
			local name = self:GetName()
			local button  = self
			local count  = _G[name.."Count"]
			local duration  = _G[name.."Duration"]
			local border  = _G[name.."Border"]
			
			if border then border:Hide() end
			if count then 
				count:SetDrawLayer("OVERLAY")
				count:SetFont(count:GetFont(), 10, "OUTLINE") 
			end
			if duration then
				duration:SetDrawLayer("OVERLAY")
				duration:SetFont(duration:GetFont(), 10)
				duration:SetShadowOffset(.5,-.5)
			end
			
			setStyle(name)
			if action and IsEquippedAction(action) then
				button.equipped = true
			else
				button.equipped = false
			end
			modSetBorderColor(button)
			
			self.styled = true
		end
	end
	  
	local modPetActionBar_Update = function()
		for i=1, NUM_PET_ACTION_SLOTS do
			local name = "PetActionButton"..i
			local button  = _G[name]

			setStyle(name)
			
			local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
			if ( isActive ) then
				button.checked = true
			else
				button.checked = false
			end
			
			
			modSetBorderColor(button)
		end  
	end
	  
	local modShapeshiftBar_UpdateState = function()    
		for i=1, NUM_SHAPESHIFT_SLOTS do
			local name = "ShapeshiftButton"..i
			local button  = _G[name]
	  
			setStyle(name)
			local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
			if ( isActive ) then
				button.checked = true
			else
				button.checked = false
			end
			modSetBorderColor(button)
		end    
	end

	local modActionButton_UpdateUsable = function(self)
		local name = self:GetName()
		local action = self.action
		local icon = _G[name.."Icon"]
		local isUsable, notEnoughMana = IsUsableAction(action)
		if (ActionHasRange(action) and IsActionInRange(action) == 0) then
			icon:SetVertexColor(0.8, 0.1, 0.1, 1)
			return
		elseif (notEnoughMana) then
			icon:SetVertexColor(0.1, 0.3, 1, 1)
			return
		elseif (isUsable) then
			icon:SetVertexColor(1, 1, 1, 1)
			return
		else
			icon:SetVertexColor(0.4, 0.4, 0.4, 1)
			return
		end
	end

	local modActionButton_OnUpdate = function(self, elapsed)
		local t = self.mod_range
		if (not t) then
			self.mod_range = 0
			return
		end
		t = t + elapsed
		if (t < update_timer) then
			self.mod_range = t
			return
		else
			self.mod_range = 0
			modActionButton_UpdateUsable(self)
		end
	end

	local modActionButton_UpdateHotkeys = function(self, actionButtonType)
		if (not actionButtonType) then
			actionButtonType = "ACTIONBUTTON"
		end
		local hotkey = _G[self:GetName().."HotKey"]
		local macro  = _G[self:GetName().."Name"]
			
		local key = GetBindingKey(actionButtonType..self:GetID()) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
		local text = GetBindingText(key, "KEY_", 1)
		hotkey:SetText(text)
		
			
		if hotkey then
			if opts["Hide hotkeys"]==false then 
				hotkey:Show()
			else
				hotkey:Hide()
			end
		end
		
		if macro then
			if opts["Hide macro"]==false then 
				macro:Show()
			else
				macro:Hide()
			end
		end
	end

	
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", function() 
		for index=1, BUFF_ACTUAL_DISPLAY do 
			modActionButton_Update(_G["BuffButton"..index]) 
		end 
	end)
	
	hooksecurefunc("DebuffButton_UpdateAnchors", function(bn, index) 
		local dtype = select(5, UnitDebuff("player",index))
		local color
		if (dtype ~= nil) then color = DebuffTypeColor[dtype] else color = DebuffTypeColor["none"] end
		modActionButton_Update(_G[bn..index])
		_G[bn..index].bd:SetVertexColor(color.r * .4, color.g * .4, color.b * .4)
	end)

	hooksecurefunc("ActionButton_Update",   modActionButton_Update)
	hooksecurefunc("ActionButton_UpdateUsable",   modActionButton_UpdateUsable)
	hooksecurefunc("ActionButton_UpdateState",   modActionButton_UpdateState)
	hooksecurefunc("ActionButtonDown", modActionButtonDown)
	hooksecurefunc("ActionButtonUp", modActionButtonUp)
	hooksecurefunc("MultiActionButtonDown", modMultiActionButtonDown)
	hooksecurefunc("MultiActionButtonUp", modMultiActionButtonUp)
	  
	ActionButton_OnUpdate = modActionButton_OnUpdate
	hooksecurefunc("ShapeshiftBar_OnLoad",   modShapeshiftBar_UpdateState)
	hooksecurefunc("ShapeshiftBar_UpdateState",   modShapeshiftBar_UpdateState)
	hooksecurefunc("PetActionBar_Update",   modPetActionBar_Update)
	hooksecurefunc("ActionButton_UpdateHotkeys", modActionButton_UpdateHotkeys)

end
tinsert(SuperClassic.modules, module) -- finish him!