local module = {}
module.name = "Chat"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	SCDB[module.name] = SCDB[module.name] or {}
	if SCDB[module.name]["CopyURL"] == nil then SCDB[module.name]["CopyURL"] = true end
	if SCDB[module.name]["CopyChat"] == nil then SCDB[module.name]["CopyChat"] = true end
	if SCDB[module.name]["ChatScroll"] == nil then SCDB[module.name]["ChatScroll"] = true end
	if SCDB[module.name]["MoveEditBox"] == nil then SCDB[module.name]["MoveEditBox"] = true end
	local opts = SCDB[module.name]
	
	local replaceschan = {
		[CHAT_MSG_GUILD] = '[G]',
		[CHAT_MSG_PARTY] = '[P]',
		[CHAT_MSG_RAID] = '[R]',
		[CHAT_MSG_RAID_LEADER] = '[LR]',
		[CHAT_MSG_RAID_WARNING] = '[RW]',
		[CHAT_MSG_OFFICER] = '[O]',
		[CHAT_MSG_BATTLEGROUND] = '[BG]',
		[CHAT_MSG_BATTLEGROUND_LEADER] = '[BGL]',
		['(%d+)%. .-'] = '[%1]',
	}
	
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")

	------------------------------------------------------------------------
	-- Enhance/rewrite a Blizzard feature, chatframe mousewheel.
	------------------------------------------------------------------------

	local ScrollLines = 3 -- set the jump when a scroll is done !
	function FloatingChatFrame_OnMouseScroll(self, delta)
		if delta < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			else
				for i = 1, ScrollLines do
					self:ScrollDown()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			else
				for i = 1, ScrollLines do
					self:ScrollUp()
				end
			end
		end
	end

	-----------------------------------------------------------------------------
	-- copy url
	-----------------------------------------------------------------------------
	if opts.CopyURL == true then
		local color = "0022FF"
		local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

		function string.color(text, color)
			return "|cff"..color..text.."|r"
		end

		function string.link(text, type, value, color)
			return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
		end

		StaticPopupDialogs["LINKME"] = {
			text = "URL COPY",
			button2 = CANCEL,
			hasEditBox = true,
			hasWideEditBox = true,
			timeout = 0,
			exclusive = 1,
			hideOnEscape = 1,
			EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
			whileDead = 1,
			maxLetters = 255,
		}

		local function f(url)
			return string.link("["..url.."]", "url", url, color)
		end

		local function hook(self, text, ...)
			self:f(text:gsub(pattern, f), ...)
		end

		for i = 1, NUM_CHAT_WINDOWS do
			if ( i ~= 2 ) then
				local frame = _G["ChatFrame"..i]
				frame.f = frame.AddMessage
				frame.AddMessage = hook
			end
		end

		local f = ChatFrame_OnHyperlinkShow
		function ChatFrame_OnHyperlinkShow(self, link, text, button)
			local type, value = link:match("(%a+):(.+)")
			if ( type == "url" ) then
				local dialog = StaticPopup_Show("LINKME")
				local editbox = _G[dialog:GetName().."EditBox"]  
				editbox:SetText(value)
				editbox:SetFocus()
				editbox:HighlightText()
				local button = _G[dialog:GetName().."Button2"]
						
				button:ClearAllPoints()
					  
				button:SetPoint("CENTER", editbox, "CENTER", 0, -30)
			else
				f(self, link, text, button)
			end
		end
	end
	
	-----------------------------------------------------------------------------
	-- Copy Chat (credit: shestak for this version)
	-----------------------------------------------------------------------------
	if opts.CopyChat == true then
		local lines = {}
		local frame = nil
		local editBox = nil
		local isf = nil
		
		local function MakeMovable(f, ...)
			f:EnableMouse(true)
			f:RegisterForDrag("LeftButton")
			f:SetClampedToScreen(true)
			f:SetMovable(true)
			f:SetScript("OnDragStart", function(self) self:StartMoving() end)
			f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		end
		
		local function CreatCopyFrame()
			copyframe = _G["CopyFrame"] or CreateFrame("Frame", "CopyFrame", UIParent)
			copyframe:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, edgeSize = 16, insets = {left=3, right=3, top=3, bottom=3}, })
			copyframe:SetBackdropColor(.01, .01, .01, .85)
			copyframe:SetBackdropBorderColor(.4, .4, .4, 1)
			copyframe:SetWidth(410)
			copyframe:SetHeight(200)
			copyframe:SetScale(1)
			copyframe:SetPoint("CENTER")
			copyframe:Hide()
			copyframe:SetFrameStrata("DIALOG")

			local scrollArea = _G["CopyScroll"] or CreateFrame("ScrollFrame", "CopyScroll", copyframe, "UIPanelScrollFrameTemplate")
			scrollArea:SetPoint("TOPLEFT", copyframe, "TOPLEFT", 8, -30)
			scrollArea:SetPoint("BOTTOMRIGHT", copyframe, "BOTTOMRIGHT", -30, 8)

			editBox = _G["CopyBox"] or CreateFrame("EditBox", "CopyBox", copyframe)
			editBox:SetMultiLine(true)
			editBox:SetMaxLetters(99999)
			editBox:EnableMouse(true)
			editBox:SetAutoFocus(false)
			editBox:SetFontObject("ChatFontNormal")
			editBox:SetWidth(410)
			editBox:SetHeight(200)
			editBox:SetScript("OnEscapePressed", function() copyframe:Hide() end)

			scrollArea:SetScrollChild(editBox)

			local close = _G["CopyCloseButton"] or CreateFrame("Button", "CopyCloseButton", copyframe, "UIPanelCloseButton")
			close:SetPoint("TOPRIGHT", copyframe, "TOPRIGHT")

			isf = true
			return copyframe
		end

		local function GetLines(...)
			--[[ Grab all those lines ]]--
			local ct = 1
			for i = select("#", ...), 1, -1 do
				local region = select(i, ...)
				if region:GetObjectType() == "FontString" then
					lines[ct] = tostring(region:GetText())
					ct = ct + 1
				end
			end
			return ct - 1
		end

		local function Copy(cf)
			local _, size = cf:GetFont()
			FCF_SetChatWindowFontSize(cf, cf, 0.01)
			local lineCt = GetLines(cf:GetRegions())
			local text = table.concat(lines, "\n", 1, lineCt)
			FCF_SetChatWindowFontSize(cf, cf, size)
			if not isf then 
				MakeMovable(CreatCopyFrame())
			end
			copyframe:Show()
			editBox:SetText(text)
			editBox:HighlightText(0)
		end

		for i = 1, NUM_CHAT_WINDOWS do
			if i ~= 2 then
				local cf = _G[format("ChatFrame%d",  i)]
				local but = CreateFrame("button", "copybutton_"..i, cf)
				but:SetNormalTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Up")
				but:SetPushedTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Down")
				but:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
				but:SetPoint("TOPRIGHT", 0, 0)
				but:SetHeight(32)
				but:SetWidth(32)
				but:SetAlpha(0)
				but:SetScript("OnClick", function(self) Copy(self:GetParent()) end)
				but:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
				but:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
			end
		end
	end

	-- Player entering the world
	local eventframe = CreateFrame("Frame")
	eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventframe:SetScript("OnEvent", function(self, event)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		if opts.ChatScroll == true then
			SetCVar("chatMouseScroll", 1)
		else
			SetCVar("chatMouseScroll", 0)
		end

		-- Hook into the AddMessage function
		local function AddMessageHook(frame, text, ...)
			-- chan text smaller or hidden
			for k,v in pairs(replaceschan) do
				text = string.gsub(text, '|h%['..k..'%]|h', '|h'..v..'|h')
			end
			text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')
			text = string.gsub(text, "has come online.", "is now |cff298F00online|r !")
			text = string.gsub(text, "|Hplayer:(.+)|h%[(.+)%]|h has earned", "|Hplayer:%1|h%2|h has earned")
			text = string.gsub(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h whispers:", "From [|Hplayer:%1:%2|h%3|h]:")
			text = string.gsub(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h says:", "[|Hplayer:%1:%2|h%3|h]:")
			text = string.gsub(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h yells:", "[|Hplayer:%1:%2|h%3|h]:")
		--[[local txt = string.gsub(text, "%]:(.+)%", "%2")
			if txt:find(select(1, UnitName("player"))) then
				RaidNotice_AddMessage(RaidBossEmoteFrame, txt, ChatTypeInfo["RAID_WARNING"]) 
			end]]
			return frame.AddMessageOriginal(frame, text, ...)
		end

		for i = 1, NUM_CHAT_WINDOWS do
			if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
				frame.AddMessageOriginal = frame.AddMessage
				frame.AddMessage = AddMessageHook
			end
		end

		ChatFrameMenuButton:Hide()
		ChatFrameMenuButton:SetScript("OnShow", function(self) self:Hide() end)

		-- Hide friends micro button (added in 3.3.5)
		FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
		FriendsMicroButton:Hide()

		GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
		GeneralDockManagerOverflowButton:Hide()
		
		hooksecurefunc("ChatEdit_OnTextSet", function(text, chatFrame)
			if ( not chatFrame ) then
				chatFrame = DEFAULT_CHAT_FRAME;
			end
			local x=({chatFrame.editBox:GetRegions()})
			local r,g,b,a = x[9]:GetVertexColor()
			--chatFrame.editBox:SetBackdropColor(0,0,0,.8)
			--chatFrame.editBox:SetBackdropBorderColor(r,g,b)
		end)
		
		hooksecurefunc("ChatEdit_OnEscapePressed", function(eb)
			eb:Hide()
		end)
		
		-- Remember last channel
		ChatTypeInfo.WHISPER.sticky = 1
		ChatTypeInfo.BN_WHISPER.sticky = 1
		ChatTypeInfo.OFFICER.sticky = 1
		ChatTypeInfo.RAID_WARNING.sticky = 1
		ChatTypeInfo.CHANNEL.sticky = 1
		
		-----------------------------------------------------------------------
		-- OVERWRITE GLOBAL VAR FROM BLIZZARD
		-----------------------------------------------------------------------

		CHAT_FRAME_FADE_OUT_TIME = 0
		CHAT_TAB_HIDE_DELAY = 0
		CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
		CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
		CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0

		for i = 1, NUM_CHAT_WINDOWS do
			_G["ChatFrame"..i]:SetClampRectInsets(0,0,0,0)
			
			--for j = 1, #CHAT_FRAME_TEXTURES do
			--	_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
			--end
			
			_G["ChatFrame"..i]:SetScript("OnUpdate", nil)
			
			-- hide chat tabs
			_G["ChatFrame"..i.."TabLeft"].Show = function() end
			_G["ChatFrame"..i.."TabLeft"]:Hide()
			_G["ChatFrame"..i.."TabRight"].Show = function() end
			_G["ChatFrame"..i.."TabRight"]:Hide()
			_G["ChatFrame"..i.."TabMiddle"].Show = function() end
			_G["ChatFrame"..i.."TabMiddle"]:Hide()
			_G["ChatFrame"..i.."TabSelectedLeft"].Show = function() end
			_G["ChatFrame"..i.."TabSelectedLeft"]:Hide()
			_G["ChatFrame"..i.."TabSelectedRight"].Show = function() end
			_G["ChatFrame"..i.."TabSelectedRight"]:Hide()
			_G["ChatFrame"..i.."TabSelectedMiddle"].Show = function() end
			_G["ChatFrame"..i.."TabSelectedMiddle"]:Hide()
			_G["ChatFrame"..i.."TabHighlightLeft"].Show = function() end
			_G["ChatFrame"..i.."TabHighlightLeft"]:Hide()
			_G["ChatFrame"..i.."TabHighlightRight"].Show = function() end
			_G["ChatFrame"..i.."TabHighlightRight"]:Hide()
			_G["ChatFrame"..i.."TabHighlightMiddle"].Show = function() end
			_G["ChatFrame"..i.."TabHighlightMiddle"]:Hide()
			_G["ChatFrame"..i.."TabGlow"].Show = function() end
			_G["ChatFrame"..i.."TabGlow"]:Hide()
			
			-- Hide chat buttons
			_G["ChatFrame"..i.."ButtonFrameUpButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameDownButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameBottomButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrame"]:Hide()

			_G["ChatFrame"..i.."ButtonFrameUpButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameDownButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameBottomButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrame"]:SetScript("OnShow", function(self) self:Hide() end)


			-- Stop the chat frame from fading out
			_G["ChatFrame"..i]:SetFading(false)
			
			-- Texture and align the chat edit box
			local editbox = _G["ChatFrame"..i.."EditBox"]
			local left, mid, right = select(6, editbox:GetRegions())
			left:Hide(); mid:Hide(); right:Hide()
			editbox:ClearAllPoints()
			if opts.MoveEditBox == true then
				editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
				editbox:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 0, 60)
			else
				editbox:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", 0, 0)
				editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, -30)
			end
			editbox:Hide()
			
			-- Disable alt key usage
			editbox:SetAltArrowKeyMode(false)
			
			local _, size = _G[format("ChatFrame%d", i)]:GetFont()
			_G[format("ChatFrame%d", i)]:SetFont("Fonts\\ARIALN.ttf", size, "OUTLINE")
			_G[format("ChatFrame%d", i)]:SetShadowOffset(0, 0)
			_G[format("ChatFrame%d", i)]:SetMinResize(50,50)
			_G[format("ChatFrame%d", i)]:SetClampedToScreen(false)
						
			FCF_SavePositionAndDimensions(_G[format("ChatFrame%d", i)])
		end

	end)
	
 end
 tinsert(SuperClassic.modules, module) -- finish him!