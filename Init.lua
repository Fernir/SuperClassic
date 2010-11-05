addonName, ns = ...

local media = "Interface\\Addons\\"..addonName.."\\media\\"
local settingsChanged = false
INTERFACE_ACTION_BLOCKED = ""

DefaultSettings = {
	firstStart = true,
	
	["Main"] = {
		["Set WatchFrame movable"] = true,
		["UIScale"] = false,
		["Font"] = media.."font.ttf",               -- global font
	},
}

local function setupVars()
	SetCVar("buffDurations", 1)
	SetCVar("consolidateBuffs", 0)
	SetCVar("autoLootDefault", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowFriendlyPets", 0)
	SetCVar("nameplateShowFriendlyGuardians", 0)
	SetCVar("nameplateShowFriendlyTotems", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyPets", 0)
	SetCVar("nameplateShowEnemyGuardians", 0)
	SetCVar("nameplateShowEnemyTotems", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("bloattest", 1)--0.0
	SetCVar("bloatnameplates", 0.0)--0.0
	SetCVar("spreadnameplates", 0)--1
	SetCVar("bloatthreat", 0)--1
	SetCVar("screenshotQuality", 8)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("chatMouseScroll", 1)
	SetCVar("showTimestamps", "none")
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	SetCVar("CombatDamage", 1)
	SetCVar("CombatHealing", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("Maxfps", 120)
	SetCVar("autoDismountFlying", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("showLootSpam", 1)
	SetCVar("guildMemberNotify", 1)
	SetCVar("chatBubblesParty", 1)
	SetCVar("chatBubbles", 1)
	SetCVar("UnitNameOwn", 1)
	SetCVar("UnitNameNPC", 1)
	SetCVar("UnitNameNonCombatCreatureName", 1)
	SetCVar("UnitNamePlayerGuild", 1)
	SetCVar("UnitNamePlayerPVPTitle", 1)
	SetCVar("UnitNameFriendlyPlayerName", 1)
	SetCVar("UnitNameFriendlyPetName", 1)
	SetCVar("UnitNameFriendlyGuardianName", 1)
	SetCVar("UnitNameFriendlyTotemName", 1)
	SetCVar("UnitNameEnemyPlayerName", 1)
	SetCVar("UnitNameEnemyPetName", 1)
	SetCVar("UnitNameEnemyGuardianName", 1)
	SetCVar("UnitNameEnemyTotemName", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("colorblindMode", 1)
end

local function SetValue(group, option, value, parent)
	if parent then
		SCDB[parent][group][option] = value
		settingsChanged = true
	else
		SCDB[group][option] = value
		settingsChanged = true
	end
end

local NewButton = function(text,parent)
	local result = CreateFrame("Button", "btn_"..parent:GetName(), parent, "UIPanelButtonTemplate")
	result:SetText(text)
	return result
end

local NewLabel = function(text,parent, justify)
	local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetText(text)
	--label:SetWidth(220)
	--label:SetHeight(20)
	label:SetJustifyH(justify or "LEFT")
	return label
end

parseOptions = function(mainframe, group, opt, parent)
	if not opt then return end
	
	local scrollf = CreateFrame("ScrollFrame", "interface_scrollf"..group, mainframe, "UIPanelScrollFrameTemplate")
	local frame = CreateFrame("frame", group, scrollf)
	scrollf:SetScrollChild(frame)
	scrollf:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 20, -40)
	scrollf:SetPoint("BOTTOMRIGHT", mainframe, "BOTTOMRIGHT", -40, 45)
	frame:SetPoint("TOPLEFT")
   frame:SetWidth(130)
   frame:SetHeight(130)
	
	local offset=5
	local tmparr = {}
	for option, value in pairs(opt) do
		table.insert(tmparr, { ["option"] = option, ["value"] = value })
	end
	table.sort(tmparr, function(a,b) return tostring(a.option) < tostring(b.option) end)
	
	for index, array in ipairs(tmparr) do
		local option, value = array.option, array.value
		if type(value) == "boolean" then
			local button = CreateFrame("CheckButton", "config_"..option, frame, "InterfaceOptionsCheckButtonTemplate")
			_G["config_"..option.."Text"]:SetText(option)
			button:SetChecked(value)
			button:SetScript("OnClick", function(self) SetValue(group,option,(self:GetChecked() and true or false), parent); _G[self:GetName().."Text"]:SetTextColor(.1,1,.1); end)
			button:SetPoint("TOPLEFT", 15, -(offset))
			offset = offset+25
		elseif type(value) == "number" or type(value) == "string" and not value:find("function") then
			local label = NewLabel(option, frame)
			label:SetPoint("TOPLEFT", 15, -(offset))
			
			local editbox = CreateFrame("EditBox", "editbox_"..option, frame)
			editbox:SetAutoFocus(false)
			editbox:SetMultiLine(false)
			editbox:SetWidth(220)
			editbox:SetHeight(20)
			editbox:SetMaxLetters(255)
			editbox:SetTextInsets(3,0,0,0)
			editbox:SetJustifyH("LEFT")
			editbox:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8", 
				tiled = false,
			})
			editbox:SetBackdropColor(0,0,0,0.5)
			editbox:SetBackdropBorderColor(0,0,0,1)
			editbox:SetFontObject("GameFontHighlight")
			editbox:SetPoint("TOPLEFT", 15, -(offset+20))
			editbox:SetText(value)
			
			local save = CreateFrame("button", option.."SaveButton", frame)
			save:SetNormalTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Up")
			save:SetPushedTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Down")
			save:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
			save:SetWidth(32)
			save:SetHeight(32)
			save:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
			save:SetScript("OnClick", function(self) 
				editbox:ClearFocus()
				editbox:SetBackdropBorderColor(.2,1,.2)
				if type(value) == "number" then
					SetValue(group,option,tonumber(editbox:GetText()), parent)
				else
					SetValue(group,option,tostring(editbox:GetText()), parent)
				end
			end)
			
			offset = offset+45
		elseif type(value) == "table" then
			if value.vtype ~= nil then
				
			else
				if #value <= 4 and type(value[1]) == "number" and value[1] <= 1 and value[2] <= 1 and value[3] <= 1 then
					local label = NewLabel(option, frame)
			
					local but = CreateFrame("Button", "btnt_"..option, frame)
					but:SetWidth(20)
					but:SetHeight(20)
					but:SetPoint("TOPLEFT", 15, -(offset))
					
					label:SetPoint("LEFT", but, "RIGHT", 5, 0)
					
					but.tex = but:CreateTexture(nil)
					but.tex:SetTexture(value[1], value[2], value[3], value[4] or 1)
					but.tex:SetPoint("TOPLEFT", 2, -2)
					but.tex:SetPoint("BOTTOMRIGHT", -2, 2)
					offset = offset+25
					
					but:SetScript("OnClick", function(self) 
						self = self.tex
					
						local function ColorCallback(self,r,g,b,a,isAlpha)
							but.tex:SetTexture(r, g, b, a)
							
							if not ColorPickerFrame:IsVisible() then
								--colorpicker is closed, color callback is first, ignore it, alpha callback is the final call after it closes so confirm now
								if isAlpha then
									value = {r, g, b, a}
									if parent then
										SCDB[parent][group][option] = {r, g, b, a}
									else
										SCDB[group][option] = {r, g, b, a}
									end
									but:SetBackdropBorderColor(.1, 1, .1)
								end
							end
						end
						
						HideUIPanel(ColorPickerFrame)
						ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
						
						ColorPickerFrame.func = function()
							local r,g,b = ColorPickerFrame:GetColorRGB()
							local a = 1 - OpacitySliderFrame:GetValue()
							ColorCallback(self,r,g,b,a, true)
						end
						
						ColorPickerFrame.hasOpacity = value[4] or false
						ColorPickerFrame.opacityFunc = function()
							local r,g,b = ColorPickerFrame:GetColorRGB()
							local a = 1 - OpacitySliderFrame:GetValue()
							ColorCallback(self,r,g,b,a,true)
						end
						
						local r, g, b, a = value[1], value[2], value[3], value[4]
						ColorPickerFrame.opacity = 1 - (a or 0)
						ColorPickerFrame:SetColorRGB(r, g, b)
						
						ColorPickerFrame.cancelFunc = function()
							ColorCallback(self,r,g,b,a,true)
						end
						ShowUIPanel(ColorPickerFrame)
					end)
				end
			end
		elseif type(value) == "string" and value:find("function") then
			local button = NewButton(option, frame)
			button:SetHeight(20)
			button:SetWidth(90)
			local func = value:gsub("function(.+)", "%1")
			button:SetScript("OnClick", function(self) RunScript(func) end)
			button:SetPoint("TOPLEFT", 15, -(offset))
			offset = offset+25
		end
	end
			
   frame:SetHeight(offset)
	mainframe:Hide()
end


local LaunchMain = function(settings)
	if SCDB["Main"].UIScale == true then
		local tmp = CreateFrame("frame")
		tmp:RegisterEvent("PLAYER_LOGIN")
		tmp:SetScript("OnEvent", function(self, ...)
			local index = GetCurrentResolution()
			local resolution = select(index, GetScreenResolutions())
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
		end)
	end
	
	if SCDB["Main"]["Set WatchFrame movable"] then
		local wf = _G["WatchFrame"]
		local wfh = _G["WatchFrameHeader"]
		if wf then
			wf:SetMovable(true)
			wf:SetUserPlaced(true)
			wfh:EnableMouse(true)
			wfh:RegisterForDrag("LeftButton")
			
			wfh:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", })
			wfh:SetBackdropColor(0,0,0,.2)
			wf:ClearAllPoints()
			
			wfh:SetScript("OnDragStart", function(self) wf:StartMoving() end)
			wfh:SetScript("OnDragStop", function(self) wf:StopMovingOrSizing() end)
    	end
	end
	
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOPLEFT", 4, -20)
end

StaticPopupDialogs["INSTALL"] = {
	text = "SuperClassic Install.|nNeed to reload ui for save all settings.|n In future you can change settings in |cffaaaaff\"Settings - Interface - Addons - SuperClassic\"|r by press a key |cffaaffaa\"Save\"|r",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() SCDB.firstStart = false; setupVars(); ReloadUI(); end,
	OnCancel = function() SCDB.firstStart = true end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["SAVEOPTS"] = {
	text = "Settings changed.|nReload UI?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
}


SuperClassic = CreateFrame("frame", "SuperClassic", UIParent)
SuperClassic.modules = {}
SuperClassic:RegisterEvent("VARIABLES_LOADED")
SuperClassic:SetScript("OnEvent", function()
	if not SCDB or SCDB.firstStart then
		 StaticPopup_Show("INSTALL")
	end
   SCDB = SCDB or DefaultSettings
	
	for k,v in pairs(DefaultSettings) do
		if SCDB[k] == nil then
			SCDB[k] = v
			if type(v) == "table" then
				for n,m in pairs(v) do
					if SCDB[k][n] == nil then
						SCDB[k][n] = m
						print("|cffaaffaaRestored|r "..k.." |cffaaffaaoption."..n.."|r value")
					end
				end
			end
			print("|cffaaffaaRestored|r "..k.." |cffaaffaaoption|r")
		end
	end
 
	InterfaceOptionsFrameOkay:HookScript("OnClick", function() 
		if settingsChanged then
			StaticPopup_Show("SAVEOPTS")
		end
	end)
	
   if not SCDB.modules then SCDB.modules = {} end
   SuperClassic.main = CreateFrame("frame", "|cff00DDAASuperClassic|r", InterfaceOptionsFramePanelContainer)
   SuperClassic.main.name = "|cff00DDAASuperClassic|r"
   InterfaceOptions_AddCategory(SuperClassic.main)
		
	parseOptions(SuperClassic.main, "Main", SCDB["Main"])
	
	LaunchMain(SCDB)
	
	local resetm = NewButton("|cffff0000Reset All|r", SuperClassic.main)
	resetm:SetWidth(90)
	resetm:SetHeight(20)
	resetm:SetPoint("BOTTOMLEFT",10, 10)
	resetm:SetScript("OnClick", function(self) SCDB = nil ReloadUI() end)
	
	local savem = NewButton("Save", SuperClassic.main)
	savem:SetWidth(90)
	savem:SetHeight(20)
	savem:SetPoint("BOTTOMRIGHT", -10, 10)
	savem:SetScript("OnClick", function(self) ReloadUI() end)
		
	table.sort(SuperClassic.modules, function(a,b) return a.name < b.name end)
   for i, module in pairs(SuperClassic.modules) do
      if SCDB.modules[module.name] == nil then SCDB.modules[module.name] = true end
			
		local childpanel = CreateFrame("frame", module.name, InterfaceOptionsFramePanelContainer)
		childpanel.name = module.name
		childpanel.parent = SuperClassic.main.name
		
		local label = NewLabel(module.name, childpanel)
		label:SetPoint("TOP", 0, -10)

		local checkbox = CreateFrame("CheckButton", "cb_module"..module.name, childpanel, "InterfaceOptionsCheckButtonTemplate")
		if SCDB.modules[module.name] then
			_G["cb_module"..module.name.."Text"]:SetText("|cff00ff00Enable|r")
		else
			_G["cb_module"..module.name.."Text"]:SetText("|cffff0000Enable|r")
		end
		checkbox:SetChecked(SCDB.modules[module.name])
		checkbox:SetScript("OnClick", function() 
			SCDB.modules[module.name] = not SCDB.modules[module.name] 
			if SCDB.modules[module.name] then
				_G["cb_module"..module.name.."Text"]:SetText("|cff00ff00Enable|r")
			else
				_G["cb_module"..module.name.."Text"]:SetText("|cffff0000Enable|r")
			end
		end)
		checkbox:SetPoint("TOPLEFT", childpanel, 20, -20)
			
		InterfaceOptions_AddCategory(childpanel)
		
		local reset = NewButton("Reset module options", childpanel)
		reset:SetWidth(140)
		reset:SetHeight(20)
		reset:SetPoint("BOTTOMLEFT",10, 10)
		reset:SetScript("OnClick", function(self) SCDB[module.name] = nil ReloadUI() end)
	
		local save = NewButton("Save", childpanel)
		save:SetWidth(90)
		save:SetHeight(20)
		save:SetPoint("BOTTOMRIGHT", -10, 10)
		save:SetScript("OnClick", function(self) ReloadUI() end)

		module.Init()
		
		parseOptions(childpanel, module.name, SCDB[module.name])
   end
   SuperClassic:UnregisterEvent("VARIABLES_LOADED")
   SuperClassic:SetScript("OnEvent", nil)
end)