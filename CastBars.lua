local module = {}
module.name = "CastBars"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	if SCDB[module.name] == nil then SCDB[module.name] = {} end
	if SCDB[module.name]["player"] == nil then SCDB[module.name]["player"] = true end
	if SCDB[module.name]["target"] == nil then SCDB[module.name]["target"] = true end
	if SCDB[module.name]["focus"] == nil then SCDB[module.name]["focus"] = true end
	if SCDB[module.name]["pet"] == nil then SCDB[module.name]["pet"] = false end
	
	SCDB[module.name].opt = SCDB[module.name].opt or {
		["player"] = {parent = "CastingBarFrame"},
		["target"] = {parent = "TargetFrameSpellBar"},
		["focus"] = {parent = "FocusFrameSpellBar"},
		["pet"] = {parent = "PetCastingBarFrame"},
	}
	
	if SCDB[module.name]["player"] == true then 
		CastingBarFrame.showCastbar = false 
		CastingBarFrame:UnregisterAllEvents()
		CastingBarFrame:SetScript("OnUpdate", function() end)
	end
	if SCDB[module.name]["target"] == true then 
		TargetFrameSpellBar.showCastbar = false 
		TargetFrameSpellBar:UnregisterAllEvents()
		TargetFrameSpellBar:SetScript("OnUpdate", function() end)
	end
	if SCDB[module.name]["focus"] == true then 
		FocusFrameSpellBar.showCastbar = false 
		FocusFrameSpellBar:UnregisterAllEvents()
		FocusFrameSpellBar:SetScript("OnUpdate", function() end)
	end
	if SCDB[module.name]["pet"] == true then 
		PetCastingBarFrame.showCastbar = false 
		PetCastingBarFrame:UnregisterAllEvents()
		PetCastingBarFrame:SetScript("OnUpdate", function() end)
	end
	
	local CastingBarHideContent = function(self)
		if not self.locked then
			self:SetAlpha(1)
			self.icon:Hide(); self.bar:Hide()
			self.text:Hide(); self.spark:Hide()
			self.flash:Hide(); self.timer:Hide()
			if self.lag then self.lag:Hide() end
			self.resize:Show(); self.name:Show()
		else
			self:SetAlpha(0)
			self.icon:Show(); self.bar:Show()
			self.text:Show(); self.spark:Show()
			self.flash:Show(); self.timer:Show()
			if self.lag then self.lag:Show() end
			self.resize:Hide(); self.name:Hide()
		end
	end
	
	local CastingBarFinishSpell = function(self, barSpark, barFlash)
		self.bar:SetStatusBarColor(0, 1, 0)
		if barSpark then self.spark:Hide() end
		if barFlash then
			self.flash:SetAlpha(0)
			self.flash:Show()
		end
		self.flashing = 1
		self.fadeOut = 1
		self.casting = nil
		self.channeling = nil
	end
	
	for unit, opts in pairs(SCDB[module.name].opt) do
		local cbframe = CreateFrame("frame", unit.."BlizzCastbar", UIParent)
		cbframe:SetWidth((opts.w or 200)+8)
		cbframe:SetHeight((opts.h or 18)+8)
		if opts.x ~= nil then
			cbframe:SetPoint("CENTER", UIParent, "BOTTOMLEFT", opts.x, opts.y)
		else
			cbframe:SetAllPoints(_G[opts.parent])
			cbframe:ClearAllPoints()
			cbframe:SetHeight(20)
			cbframe:SetPoint("TOPLEFT", _G[opts.parent], 0, 0)
		end
		cbframe:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, edgeSize = 16, insets = {left=3, right=3, top=3, bottom=3}, })
		cbframe:SetBackdropColor(.01, .01, .01, .85)
		cbframe:SetBackdropBorderColor(.4, .4, .4, 1)
		cbframe:SetMovable(true)
		cbframe:EnableMouse(false)
		cbframe:SetClampedToScreen(true)
		cbframe:RegisterForDrag("LeftButton")
		cbframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
		cbframe:SetScript("OnDragStop", function(self) 
			self:StopMovingOrSizing()
			local x, y = self:GetCenter()
			SCDB[module.name].opt[self.unit].x = x
			SCDB[module.name].opt[self.unit].y = y
		end)
		cbframe:SetResizable(true)
		cbframe.resize = CreateFrame("button", cbframe:GetName().."ResizeButton", cbframe)
		cbframe:SetMinResize(16, 16)
		cbframe:SetMaxResize(600, 400)
		cbframe.resize:SetPoint("BOTTOMRIGHT")
		cbframe.resize:SetWidth(16)
		cbframe.resize:SetHeight(16)
		cbframe.resize:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
		cbframe.resize:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
		cbframe.resize:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
		cbframe.resize:SetScript("OnMouseDown", function(self) self:GetParent():StartSizing() end)
		cbframe.resize:SetScript("OnMouseUp", function(self)
			local parent = self:GetParent()
			parent:StopMovingOrSizing()
			local w, h = parent:GetWidth(), parent:GetHeight()
			SCDB[module.name].opt[parent.unit].w = w-8
			SCDB[module.name].opt[parent.unit].h = h-8
			
			parent.icon:SetWidth(parent:GetHeight()-8)
			parent.icon:SetHeight(parent:GetHeight()-8)
			if parent.lag then
				parent.lag:SetWidth(0)
				parent.lag:SetHeight(parent.bar:GetHeight()) 
				parent.lag:SetPoint("RIGHT")
			end
		end)
		cbframe.resize:Hide()
		
		cbframe.name = cbframe:CreateFontString(cbframe:GetName().."Name", "OVERLAY", "GameFontHighlight")
		cbframe.name:SetAllPoints(cbframe)
   
		cbframe.icon = cbframe:CreateTexture(cbframe:GetName().."Icon", "OVERLAY")
		cbframe.icon:SetWidth(cbframe:GetHeight()-8)
		cbframe.icon:SetHeight(cbframe:GetHeight()-8)
		cbframe.icon:SetPoint("LEFT", 4, 0)
		cbframe.icon:SetTexCoord(.1, .9, .1, .9)
		
		cbframe.bar = CreateFrame("StatusBar", cbframe:GetName().."Bar", cbframe)
		cbframe.bar:SetWidth(cbframe:GetWidth()-cbframe.icon:GetWidth()-9)
		cbframe.bar:SetHeight(cbframe:GetHeight()-8)
		cbframe.bar:SetPoint("TOPLEFT", cbframe.icon, "TOPRIGHT", 1, 0)
		cbframe.bar:SetPoint("BOTTOMRIGHT", cbframe, "BOTTOMRIGHT", -4, 4)
		cbframe.bar:SetStatusBarTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
		cbframe.bar:GetStatusBarTexture():SetDesaturated(1)
		cbframe.bar:GetStatusBarTexture():SetTexCoord(0, 1, 0.609375, 0.796875)
		cbframe.bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND")
		cbframe.bar:GetStatusBarTexture():SetHorizTile(true)
		cbframe.bar:GetStatusBarTexture():SetVertTile(false)
		cbframe.bar:SetStatusBarColor(1, .7, 0)
		
		if unit == "player" then
			cbframe.lag = cbframe.bar:CreateTexture(cbframe:GetName().."Lag", "BORDER")
			cbframe.lag:SetPoint("TOPRIGHT")
			cbframe.lag:SetPoint("BOTTOMRIGHT")
			cbframe.lag:SetTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
			cbframe.lag:SetTexCoord(0.8203125, 1.0, 0.34375, 0.484375)
			cbframe.lag:SetVertexColor(1, 0, 0)
			cbframe.lag:SetBlendMode("ADD")
		end
			
		cbframe.timer = cbframe.bar:CreateFontString(cbframe:GetName().."Timer", "OVERLAY", "GameFontHighlight")
		cbframe.timer:SetPoint("RIGHT", -4, 0)
		cbframe.timer:SetJustifyH("RIGHT")
		cbframe.timerUpdate = .1
		
		cbframe.text = cbframe.bar:CreateFontString(cbframe:GetName().."Text", "OVERLAY", "GameFontHighlight")
		cbframe.text:SetWidth(cbframe.bar:GetWidth()-30)
		cbframe.text:SetHeight(cbframe.bar:GetHeight())
		cbframe.text:SetPoint("LEFT", 4, 0)
		cbframe.text:SetJustifyH("LEFT")
		
		cbframe.spark = cbframe.bar:CreateTexture(cbframe:GetName().."Spark", "OVERLAY")
		cbframe.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		cbframe.spark:SetWidth(32)
		cbframe.spark:SetHeight(cbframe:GetHeight()+32)
		cbframe.spark:SetPoint("CENTER")
		cbframe.spark:SetBlendMode("ADD")
		
		cbframe.flash = cbframe.bar:CreateTexture(cbframe:GetName().."Flash", "OVERLAY")
		cbframe.flash:SetTexture(1,1,1,1)
		cbframe.flash:SetWidth(cbframe:GetWidth()-6)
		cbframe.flash:SetHeight(cbframe:GetHeight()-6)
		cbframe.flash:SetBlendMode("ADD")
		
		cbframe:RegisterEvent("PLAYER_TARGET_CHANGED")
		cbframe:RegisterEvent("UNIT_SPELLCAST_START")
		cbframe:RegisterEvent("UNIT_SPELLCAST_STOP")
		cbframe:RegisterEvent("UNIT_SPELLCAST_FAILED")
		cbframe:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		cbframe:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		cbframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		cbframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		cbframe:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		cbframe:RegisterEvent("PLAYER_ENTERING_WORLD")
    
		cbframe.unit = unit
		cbframe.casting = nil
		cbframe.channeling = nil
		cbframe.holdTime = 0
		cbframe.showCastbar = SCDB[module.name][unit]
		cbframe.locked = true
		cbframe:Hide()
		
		cbframe:SetScript("OnShow", function(self)
			if not self.locked then return end
			if self.casting then
				local _, _, _, _, st = UnitCastingInfo(self.unit)
				if st then
					self.value = (GetTime() - (st / 1000))
				end
			else
				local _, _, _, _, _, et = UnitChannelInfo(self.unit)
				if et then
					self.value = ((et / 1000) - GetTime())
				end
			end
		end)
		
		cbframe:SetScript("OnEvent", function(self, event, ...)
			local arg1 = ...
			if not self.locked then return end
			local unit = self.unit
			if  event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" then
				local spellChannel  = UnitChannelInfo(unit)
				local spellName  = UnitCastingInfo(unit)
				if  spellChannel then
					event = "UNIT_SPELLCAST_CHANNEL_START"
					arg1 = unit
				elseif spellName then
					event = "UNIT_SPELLCAST_START"
					arg1 = unit
				else
					CastingBarFinishSpell(self)
				end
			end

			if arg1 ~= unit then return end
			
			if event == "UNIT_SPELLCAST_START" then
				local name, _, text, texture, startTime, endTime, _, castID = UnitCastingInfo(unit)
				if not name then
					self:Hide()
					return
				end

				self.bar:SetStatusBarColor(1, .7, 0)
				self.spark:Show()
				if self.lag then self.lag:Show() end
				self.value = GetTime() - (startTime / 1000)
				self.maxValue = (endTime - startTime) / 1000
				self.bar:SetMinMaxValues(0, self.maxValue)
				self.bar:SetValue(self.value)
				self.text:SetText(text)
				self.icon:SetTexture(texture)
				self:SetAlpha(1)
				self.holdTime = 0
				self.casting = 1
				self.castID = castID
				self.channeling = nil
				self.fadeOut = nil
				if self.showCastbar then self:Show() end
			elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				if not self:IsVisible() then
					self:Hide()
				end
				if (self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") then
					if self.spark then
						self.spark:Hide()
					end
					self.flash:SetAlpha(0)
					self.flash:Show()
					self.bar:SetValue(self.maxValue)
					if event == "UNIT_SPELLCAST_STOP" then
						self.casting = nil
						self.bar:SetStatusBarColor(0, 1, 0)
					else
						self.channeling = nil
					end
					self.flashing = 1
					self.fadeOut = 1
					self.holdTime = 0
				end
			elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
				if self:IsShown() and (self.casting and select(4, ...) == self.castID) and not self.fadeOut then
					self.bar:SetValue(self.maxValue)
					self.bar:SetStatusBarColor(1, 0, 0)
					self.spark:Hide()
					if event == "UNIT_SPELLCAST_FAILED" then
						self.text:SetText(FAILED)
					else
						self.text:SetText(INTERRUPTED)
					end
					if self.lag then self.lag:Hide() end
					self.casting = nil
					self.channeling = nil
					self.fadeOut = 1
					self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
				end
			elseif event == "UNIT_SPELLCAST_DELAYED" then
				if self:IsShown() then
					local name, _, text, texture, startTime, endTime = UnitCastingInfo(unit)
					if not name then
						-- if there is no name, there is no bar
						self:Hide()
						return
					end
					self.value = (GetTime() - (startTime / 1000))
					self.maxValue = (endTime - startTime) / 1000
					self.bar:SetMinMaxValues(0, self.maxValue)
					if not self.casting then
						self.bar:SetStatusBarColor(1, .7, 0)
						self.spark:Show()
						self.flash:SetAlpha(0)
						self.flash:Hide()
						self.casting = 1
						self.channeling = nil
						self.flashing = 0
						self.fadeOut = 0
					end
				end
			elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
				local name, _, text, texture, startTime, endTime = UnitChannelInfo(unit)
				if not name then
					-- if there is no name, there is no bar
					self:Hide()
					return
				end

				self.bar:SetStatusBarColor(0, 1, 0)
				self.value = (endTime / 1000) - GetTime()
				self.maxValue = (endTime - startTime) / 1000
				self.bar:SetMinMaxValues(0, self.maxValue)
				self.bar:SetValue(self.value)
				self.text:SetText(text)
				self.icon:SetTexture(texture)
				self.spark:Hide()
				self:SetAlpha(1)
				self.holdTime = 0
				self.casting = nil
				self.channeling = 1
				self.fadeOut = nil
				if self.showCastbar then self:Show() end
			elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			  if self:IsShown() then
					local name, _, text, texture, startTime, endTime = UnitChannelInfo(unit)
					if not name then
						self:Hide()
						return
					end
					self.value = (endTime / 1000) - GetTime()
					self.maxValue = (endTime - startTime) / 1000
					self.bar:SetMinMaxValues(0, self.maxValue)
					self.bar:SetValue(self.value)
				end
			end
		end)
		
		cbframe:SetScript("OnUpdate", function(self, elapsed)
			if not self.locked then return end
			
			if not self.timer then return end
			if self.timerUpdate and self.timerUpdate < elapsed then
				if self.casting then
					self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
				elseif self.channeling then
					self.timer:SetText(format("%.1f", max(self.value, 0)))
				else
					self.timer:SetText("")
				end
				self.timerUpdate = .1
			else
				self.timerUpdate = self.timerUpdate - elapsed
			end

			if self.casting then
				self.value = self.value + elapsed
				if self.value >= self.maxValue then
					self.bar:SetValue(self.maxValue)
					CastingBarFinishSpell(self, self.spark, self.flash)
					return
				end
				self.bar:SetValue(self.value)
				self.flash:Hide()
				--local sparkPosition = (self.value / self.maxValue) * self.bar:GetWidth()
				self.spark:SetPoint("CENTER", self.bar:GetStatusBarTexture(), "RIGHT", 0, 0)
				if self.unit == "player" then
					local down, up, lag = GetNetStats()
					local castingmin, castingmax = self.bar:GetMinMaxValues()
					local lagvalue = ( lag / 1000 ) / ( castingmax - castingmin )
					if ( lagvalue < 0 ) then lagvalue = 0; elseif ( lagvalue > 1 ) then lagvalue = 1 end
					self.lag:ClearAllPoints()
					self.lag:SetPoint("RIGHT")
					self.lag:SetHeight(self.bar:GetHeight())
					self.lag:SetWidth(self.bar:GetWidth() * lagvalue)
				end
			elseif self.channeling then
				self.value = self.value - elapsed
				if self.value <= 0 then
					CastingBarFinishSpell(self, self.spark, self.flash)
					return
				end
				self.bar:SetValue(self.value)
				self.flash:Hide()
			elseif GetTime() < self.holdTime then
				return
			elseif self.flashing then
				local alpha = 0
				alpha = self.flash:GetAlpha() + CASTING_BAR_FLASH_STEP
				if alpha < 1 then
					self.flash:SetAlpha(alpha)
				else
					self.flash:SetAlpha(1)
					self.flashing = nil
				end
			elseif self.fadeOut then
				local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP
				if alpha > 0 then
					self:SetAlpha(alpha)
				else
					self.fadeOut = nil
					self:Hide()
				end
			end
		end)
		
	end
	
	-- setup slash command /tcb
	SLASH_BlizzCastbars1 = "/tcb";
	SlashCmdList["BlizzCastbars"] = function()
		for unit, opts in pairs(SCDB[module.name].opt) do
			if SCDB[module.name][unit] then
				local castbar = unit.."BlizzCastbar"
				_G[castbar].locked = not _G[castbar].locked
				if _G[castbar].locked then
					_G[castbar]:EnableMouse(false)
					_G[castbar].name:SetText("")
					_G[castbar]:Hide()
				else
					_G[castbar]:EnableMouse(true)
					_G[castbar].name:SetText(unit)
					_G[castbar]:Show()
				end
				CastingBarHideContent(_G[castbar])
			end
		end
	end
	
end
tinsert(SuperClassic.modules, module) -- finish him!