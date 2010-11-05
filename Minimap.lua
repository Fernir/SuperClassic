local module = {}
module.name = "Minimap"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	if SCDB[module.name] == nil then SCDB[module.name] = {} end
	if SCDB[module.name]["Square Minimap"] == nil then SCDB[module.name]["Square Minimap"] = false end
	
	-- map coords
	local coords = CreateFrame("frame", nil, WorldMapFrame)
	coords.txt=coords:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	coords.txt:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 20, 10)
	coords.txt:SetJustifyH("CENTER")
	coords:SetScript("OnUpdate", function(self, elapsed)
		local scale = WorldMapDetailFrame:GetEffectiveScale()
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local centerX, centerY = WorldMapDetailFrame:GetCenter()
		local x, y = GetCursorPosition()
		-- Tweak coords so they are accurate
		local adjustedX = (x / scale - (centerX - (width/2))) / width
		local adjustedY = (centerY + (height/2) - y / scale) / height
		local rcpx, rcpy = GetPlayerMapPosition("player")
		local rcoutput= format("Cursor: %d,%d      Player: %d,%d", adjustedX*100, adjustedY*100, floor(rcpx*100), floor(rcpy*100))
		self.txt:SetText(rcoutput)
	end)

	local function Minimap_CreateDropDown()
		local calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
		local button = {
			  { text = MAINMENU_BUTTON, func = function() ShowUIPanel(GameMenuFrame) end },
			  { text = CHARACTER_BUTTON, func = function() ToggleCharacter("PaperDollFrame") end },
			  { text = SPELLBOOK_ABILITIES_BUTTON, func = function() ToggleFrame(SpellBookFrame) end },
			  { text = TALENTS_BUTTON, func = function() ToggleTalentFrame() end },
			  { text = ACHIEVEMENT_BUTTON, func = function() ToggleAchievementFrame() end },
			  { text = calendar, func = function() ToggleCalendar() end },
			  { text = QUESTLOG_BUTTON, func = function() ToggleFrame(QuestLogFrame) end },
			  { text = SOCIAL_BUTTON, func = function() ToggleFriendsFrame() end },
			  { text = GUILD, func = function() ToggleGuildFrame() end },
			  { text = PLAYER_V_PLAYER, func = function() ToggleFrame(PVPFrame) end },
			  { text = LFG_TITLE, func = function() ToggleLFDParentFrame() end },
			  { text = HELP_BUTTON, func = function() ToggleHelpFrame() end },
		}
		 
		for i=1, 10 do
			UIDropDownMenu_AddButton(button[i])
		end
	end

	local EventFrame = CreateFrame("Frame")
	EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	EventFrame:SetScript("OnEvent", function(self, event, ...)
		if (event == "PLAYER_ENTERING_WORLD") then
		
			WorldMapFrame:SetBackdropColor(0,0,0,0)
			
			MiniMapMailText = MiniMapMailFrame:CreateFontString("MiniMapMailText", "OVERLAY", "GameFontHighlightLarge")
			MiniMapMailText:SetPoint("CENTER")
			MiniMapMailText:SetText("New Mail")
			MiniMapMailFrame:SetWidth((MiniMapMailText:GetStringWidth()))
			MiniMapMailFrame:SetHeight(18)
			MiniMapMailFrame:ClearAllPoints()
			MiniMapMailFrame:SetPoint("BOTTOM", 0, 5)
			MiniMapMailIcon:SetTexture(nil)
			
			GameTimeFrame:SetWidth(14)
			GameTimeFrame:SetHeight(14)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOP", Minimap, 0, -5)

			local fontName, fontHeight, fontFlags = GameTimeFrame:GetFontString():GetFont()
			GameTimeFrame:GetFontString():SetFont(fontName, 16, "OUTLINE")
			GameTimeFrame:GetFontString():SetPoint("TOP", GameTimeFrame)
			local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {0,0,0}
			GameTimeFrame:GetFontString():SetTextColor(color.r, color.g, color.b)
				
			for i = 1, select("#", GameTimeFrame:GetRegions()) do
				local obj = select(i, GameTimeFrame:GetRegions())
				if (obj and obj:GetObjectType() == "Texture") then
					obj:SetTexture(nil)
				end
			end
			if SCDB[module.name]["Square Minimap"] == false then
				function GetMinimapShape() return "ROUND" end
				Minimap:SetMaskTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
			else
				GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -5, -5)
				MiniMapMailFrame:SetPoint("TOP", 0, -5)
				function GetMinimapShape() return "SQUARE" end
				Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
				MinimapBorder:Hide()
				MinimapBackdrop:SetParent(Minimap)
				MinimapBackdrop:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, edgeSize = 16, insets = {left=3, right=3, top=3, bottom=3}, })
				MinimapBackdrop:SetBackdropColor(.01, .01, .01, .85)
				MinimapBackdrop:SetBackdropBorderColor(.4, .4, .4, 1)
				MinimapBackdrop:SetPoint("TOPLEFT", Minimap, -5, 5)
				MinimapBackdrop:SetPoint("BOTTOMRIGHT", Minimap, 5, -5)
				MinimapBackdrop:SetFrameLevel(Minimap:GetFrameLevel()-1)
				
				MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 10)
				MiniMapInstanceDifficulty:SetScale(.7)
				
				MiniMapLFGFrame:ClearAllPoints()
				MiniMapLFGFrame:SetPoint("BOTTOMLEFT", Minimap, -2, -2)
				MiniMapLFGFrame:SetScale(0.93)
				MiniMapLFGFrameBorder:SetAlpha(0)

				MiniMapBattlefieldFrame:ClearAllPoints()
				MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, -2, 1)
				
				for i = 1, select("#", TimeManagerClockButton:GetRegions()) do
					local texture = select(i, TimeManagerClockButton:GetRegions())
					if (texture and texture:GetObjectType() == "Texture") then
						texture:SetTexture(nil)
					end
					if (texture and texture:GetObjectType() == "FontString") then
						texture:SetFont(texture:GetFont(), 12, "OUTLINE")
						texture:SetParent(Minimap)
						texture:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
						TimeManagerClockButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
						TimeManagerClockButton:SetWidth(texture:GetWidth())
						TimeManagerClockButton:SetHeight(texture:GetHeight())
					end
				end
				
			end
			
			MinimapCluster:SetScale(.9)
			
			
			for i,v in pairs({
				MinimapZoomIn,
				MinimapZoomOut,
				MiniMapWorldMapButton,
				MinimapZoneTextButton,
				MinimapBorderTop,
				MiniMapTracking,
				MiniMapBattlefieldBorder,
				MiniMapMailBorder,
				MiniMapMailBackground,
			}) do
				v:Hide()
				v.Show = function() end
			end

			for _, texture in pairs({
				GameTimeCalendarEventAlarmTexture,
				GameTimeCalendarInvitesTexture,
				GameTimeCalendarInvitesGlow,
			}) do
			
				texture:SetAlpha(0)
				GameTimeFrame:HookScript("OnEnter", function(self)
					local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {0,0,0}
					GameTimeFrame:GetFontString():SetTextColor(color.r, color.g, color.b)
				end)
				GameTimeFrame:HookScript("OnLeave", function(self)
					local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {0,0,0}
					GameTimeFrame:GetFontString():SetTextColor(color.r, color.g, color.b)
				end)

				texture.Show = function()
					texture:SetAlpha(0)
					GameTimeFrame:GetFontString():SetTextColor(1, 0, 0)
				end

				texture.Hide = function() 
					texture:SetAlpha(0)
					GameTimeFrame:GetFontString():SetTextColor(1, 1, 1)
				end
			end
		 
			MinimapNorthTag:SetAlpha(0)

			Minimap:EnableMouseWheel(true)
			Minimap:SetScript("OnMouseWheel", function(self, arg1)
				if (arg1 > 0) then
					Minimap_ZoomIn()
				else
					Minimap_ZoomOut()
				end
			end)

			Minimap:SetScript("OnMouseUp", function(self, button)
				if(button == "MiddleButton") then
					ToggleDropDownMenu(1, nil, TimeManagerClockDropDown, self, -0, -0)
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
				elseif (button == "LeftButton") then
					ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
				else
					Minimap_OnClick(self)
				end
			end)
			  
			TimeManagerClockDropDown = CreateFrame("Frame", "TimeManagerClockDropDown", nil, "UIDropDownMenuTemplate")
			UIDropDownMenu_Initialize(TimeManagerClockDropDown, Minimap_CreateDropDown, "MENU")
			
			--[ GAME MENU OPTIONS ]--
			local function MakeMovable(f, ...)
				f:EnableMouse(true)
				f:RegisterForDrag("LeftButton")
				f:SetClampedToScreen(true)
				f:SetMovable(true)
				f:SetScript("OnDragStart", function(self) self:StartMoving() end)
				f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
			end

			local header = {"GameMenuFrame", "InterfaceOptionsFrame", "AudioOptionsFrame", "VideoOptionsFrame", "ColorPickerFrame", }
			for i = 1, getn(header) do
				local title = _G[header[i].."Header"]
				if title then
					title:SetTexture("")
					title:ClearAllPoints()
					if title == _G["GameMenuFrameHeader"] then
						title:SetPoint("TOP", GameMenuFrame, 0, 7)
					else
						title:SetPoint("TOP", header[i], 0, 0)
					end
					MakeMovable(_G[header[i]])
				end
			end
		end
	end)

   
end
tinsert(SuperClassic.modules, module) -- finish him!