local module = {}
module.name = "MirrorBars"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	if SCDB[module.name] == nil then SCDB[module.name] = {} end
	
	if SCDB[module.name]["Width"] == nil then SCDB[module.name]["Width"] = 200 end
	if SCDB[module.name]["Height"] == nil then SCDB[module.name]["Height"] = 18 end
	if SCDB[module.name]["Spacing"] == nil then SCDB[module.name]["Spacing"] = 4 end
	if SCDB[module.name]["Anchor"] == nil then SCDB[module.name]["Anchor"] = "TOP" end
	if SCDB[module.name]["PosX"] == nil then SCDB[module.name]["PosX"] = 0 end
	if SCDB[module.name]["PosY"] == nil then SCDB[module.name]["PosY"] = -100 end
		
	local opts = SCDB[module.name]

	
		-- Config start
	local width = opts["Width"] or 200
	local height = opts["Height"] or 18
	local spacing = opts["Spacing"] or 4
	local anchor = opts["Anchor"] or "TOP"
	local x, y = opts["PosX"] or 0, opts["PosY"] or -100
	-- Config end

	local CreateBG = function(parent)
		local bg = CreateFrame("Frame", nil, parent)
		bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -4, 4)
		bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 4, -4)
		bg:SetFrameStrata("LOW")
		bg:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tileSize = 16,
				edgeSize = 16,
				insets = {left=3, right=3, top=3, bottom=3},
			})
		return bg
	end

	local mirrorTimers = {}

	local CreateMirrorTimer = function()
		local mtimer = CreateFrame("StatusBar", nil, UIParent)
		mtimer:SetWidth(width)
		mtimer:SetHeight(height)
		mtimer:SetPoint(anchor, UIParent, anchor, x, y - (#mirrorTimers * (1 + spacing)))
		mtimer:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
		mtimer.bg = CreateBG(mtimer)
		mtimer.label = mtimer:CreateFontString(nil, "ARTWORK")
		mtimer.label:SetPoint("LEFT", 3, 0)
		mtimer.label:SetPoint("RIGHT", -3, 0)
		mtimer.label:SetFontObject("GameFontNormal")
		mtimer.label:SetJustifyH("CENTER")
		mtimer:Hide()
		tinsert(mirrorTimers, mtimer)
		return mtimer
	end

	local GetMirrorTimer = function(timer)
		for i, v in pairs(mirrorTimers) do
			if v.timer == timer then
				return v
			end
		end
		for i, v in pairs(mirrorTimers) do
			if not v.timer then
				return v
			end
		end
		return CreateMirrorTimer()
	end

	local OnUpdate = function(self, elapsed)
		if self.paused then return end
		self:SetValue(GetMirrorTimerProgress(self.timer) / 1000)
	end

	local ShowTimer = function(timer, value, maxvalue, scale, paused, label)
		local mTimer = GetMirrorTimer(timer)
		mTimer.timer = timer
		if paused > 0 then
			mTimer.paused = 1
		else
			mTimer.paused = nil
		end
		mTimer.label:SetText(label)
		local color = MirrorTimerColors[timer]
		mTimer:SetStatusBarColor(color.r, color.g, color.b)
		mTimer:SetMinMaxValues(0, (maxvalue / 1000))
		mTimer:SetValue(value / 1000)
		mTimer:SetScript("OnUpdate", OnUpdate)
		mTimer:Show()
	end

	local OnEvent = function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			for i = 1, MIRRORTIMER_NUMTIMERS do
				local timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)
				if  timer ~=  "UNKNOWN" then
					ShowTimer(timer, value, maxvalue, scale, paused, label)
				end
			end
		elseif event == "MIRROR_TIMER_START" then
			local timer, value, maxvalue, scale, paused, label = ...
			ShowTimer(timer, value, maxvalue, scale, paused, label)
		elseif event == "MIRROR_TIMER_STOP" then
			local timer = ...
			for i, v in pairs(mirrorTimers) do
				if v.timer == timer then
					v.timer = nil
					v:SetScript("OnUpdate", nil)
					v:Hide()
				end
			end
		elseif event == "MIRROR_TIMER_PAUSE" then
			local duration = ...
			for i, v in pairs(mirrorTimers) do
				if duration > 0 then
					v.paused = 1
				else
					v.paused = nil
				end
			end
		end
	end


	local addon = CreateFrame("frame")
	addon:SetScript("OnEvent", OnEvent)
	addon:RegisterEvent("MIRROR_TIMER_START")
	addon:RegisterEvent("MIRROR_TIMER_STOP")
	addon:RegisterEvent("MIRROR_TIMER_PAUSE")
	addon:RegisterEvent("PLAYER_ENTERING_WORLD")
	UIParent:UnregisterEvent("MIRROR_TIMER_START")
	for i = 1, MIRRORTIMER_NUMTIMERS do
		_G["MirrorTimer"..i]:UnregisterAllEvents()
	end

end
tinsert(SuperClassic.modules, module) -- finish him!