-- author: Zork (Roth)

local module = {}
module.name = "Nameplates"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	local opts = SCDB[module.name]
	
	local nameplates = CreateFrame("Frame", nil, UIParent)
	nameplates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

	local styleNamePlate = function(self)
		if self.styled == true then return end
		local healthBar, castBar = self:GetChildren()
		local threatTexture, borderTexture, castborderTexture, shield, castbaricon, highlightTexture, nameText, levelText, bossIcon, raidIcon, dragonTexture = self:GetRegions()
		local r, g, b, a

		--enemycolor
		self.enemycolor = {}
		r,g,b = healthBar:GetStatusBarColor()
		self.enemycolor.r, self.enemycolor.g, self.enemycolor.b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100

		--difficultycolor
		self.difficultycolor = {}
		r,g,b = levelText:GetTextColor()
		self.difficultycolor.r,self.difficultycolor.g,self.difficultycolor.b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100

		self.unitname = nameText:GetText() or ""
		self.unitlvl = levelText:GetText() or ""

		local elite = ""
			if dragonTexture:IsShown() == 1 then
			elite = "+"
		end
		
		--hp bg
		healthBar.bg = healthBar:CreateTexture(nil,"BACKGROUND",-8)
		healthBar.bg:SetAllPoints(healthBar)
		healthBar.bg:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
		healthBar.bg:SetVertexColor(0,0,0,0.4)
		
		--new name
		self.na = self:CreateFontString(nil, "BORDER")
		self.na:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
		self.na:SetPoint("BOTTOM", healthBar, "TOP", 0, 4)
		self.na:SetPoint("RIGHT", healthBar, 5, 0)
		if self.enemycolor.r == 0 and self.enemycolor.g == 0 and self.enemycolor.b == 1 then
			self.na:SetTextColor(0,0.7,1)
		else
			self.na:SetTextColor(self.enemycolor.r,self.enemycolor.g,self.enemycolor.b)
		end
		self.na:SetText(self.unitname)
		self.na:SetJustifyH("LEFT")    

		--new lvl txt
		self.lvl = self:CreateFontString(nil, "BORDER")
		self.lvl:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
		self.lvl:SetPoint("BOTTOM", healthBar, "TOP", 0, 4)
		self.lvl:SetPoint("LEFT", healthBar, 0, 0)
		self.lvl:SetTextColor(self.difficultycolor.r,self.difficultycolor.g,self.difficultycolor.b)
		self.lvl:SetText(self.unitlvl..elite)
		self.lvl:SetJustifyH("LEFT")

		self.na:SetPoint("LEFT", self.lvl, "RIGHT", 0, 0)

		--boss icon
		bossIcon:ClearAllPoints()
		bossIcon:SetPoint("RIGHT", self.na, "LEFT", 0, 0)

		--castbars
		local w,h = healthBar:GetWidth(), healthBar:GetHeight()
		castBar:SetSize(w,h)
		castBar:ClearAllPoints()
		castBar:SetPoint("BOTTOM",healthBar,0,-20)

		castborderTexture:SetTexture("Interface\\Tooltips\\Nameplate-CastBar")
		castborderTexture:SetSize(w+25,(w+25)/4)
		castborderTexture:ClearAllPoints()
		castborderTexture:SetPoint("CENTER",-19,-29)
		castborderTexture:SetTexCoord(0,1,0,1)

		shield:SetSize(w+25,(w+25)/4)
		shield:ClearAllPoints()
		shield:SetPoint("CENTER",-19,-29)    
		shield:SetTexCoord(0,1,0,1)

		castbaricon:ClearAllPoints()
		castbaricon:SetPoint("LEFT",castBar,-20,0)
		castbaricon:SetTexCoord(0.1,0.9,0.1,0.9)

		--castbar bg
		castBar.bg = castBar:CreateTexture(nil,"BACKGROUND",-8)
		castBar.bg:SetAllPoints(castBar)
		castBar.bg:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
		castBar.bg:SetVertexColor(0,0,0,0.4)
		castBar.bg:Hide()

		castBar.border = castborderTexture
		castBar.shield = shield
		castBar.icon = castbaricon

		--raidicon
		raidIcon:ClearAllPoints()
		raidIcon:SetSize(20,20)
		raidIcon:SetPoint("BOTTOM",healthBar,"TOP",0,17)

		--disable some stuff
		nameText:Hide()
		levelText:Hide()
		dragonTexture:SetTexture("") --just plain ugly!

		threatTexture:SetTexture("")
		borderTexture:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
		borderTexture:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
		borderTexture:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
		
		--make castbar stuff get into position on castbar load
		castBar:HookScript("OnShow", function(s)
			s:ClearAllPoints()
			s:SetPoint("BOTTOM",healthBar,0,-20)
			s.bg:Show()
			s.bg:SetAllPoints(castBar)
			s.border:ClearAllPoints()
			s.border:SetPoint("CENTER",-19,-29)
			s.shield:ClearAllPoints()
			s.shield:SetPoint("CENTER",-19,-29)
			s.icon:ClearAllPoints()
			s.icon:SetPoint("LEFT",castBar,-20,0)
		end)

		castBar:HookScript("OnHide", function(s)
			s.bg:Hide()
		end)

		self:HookScript("OnShow", function(s) 
			local healthBar, castBar = s:GetChildren()
			local threatTexture, borderTexture, castborderTexture, shield, castbaricon, highlightTexture, nameText, levelText, bossIcon, raidIcon, dragonTexture = s:GetRegions()
			s.na:SetText(nameText:GetText())
			local r,g,b = healthBar:GetStatusBarColor()
			r,g,b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
			if r == 0 and g == 0 and b == 1 then
				s.na:SetTextColor(0,0.7,1)
			else
				s.na:SetTextColor(r,g,b)
			end
			local elite = ""
				if dragonTexture:IsShown() == 1 then
				elite = "+"
			end
			if bossIcon:IsShown() ~= 1 then
				s.lvl:SetText(levelText:GetText()..elite)
				s.lvl:SetTextColor(levelText:GetTextColor())
			else
				s.lvl:SetText("")
			end
			levelText:Hide()
			nameText:Hide()
		end)

		self.styled = true
	end

	local IsNamePlateFrame = function(self)
		if self:GetName() then return false end
		local region = select(2, self:GetRegions())
		if not region or region:GetObjectType() ~= "Texture" or region:GetTexture() ~= "Interface\\Tooltips\\Nameplate-Border" then return false end
		return true
	end
  
	nameplates:SetScript("OnUpdate", function(self, elapsed)
		if not self.lastupdate then self.lastupdate = 0 end
		self.lastupdate = self.lastupdate + elapsed
		if self.lastupdate > 0.33 then
			self.lastupdate = 0
			local num = select("#", WorldFrame:GetChildren())
			for i = 1, num do
				local f = select(i, WorldFrame:GetChildren())
				if not self.styled and IsNamePlateFrame(f) then 
					styleNamePlate(f)
				end
			end
		end
	end)
	
	nameplates:RegisterEvent("PLAYER_REGEN_DISABLED")
	function nameplates.PLAYER_REGEN_DISABLED()
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("ShowClassColorInNameplate", 1)
		SetCVar("UnitNameEnemyTotemName", 1)
		SetCVar("nameplateShowEnemyTotems", 1)
	end

end
tinsert(SuperClassic.modules, module) -- finish him!