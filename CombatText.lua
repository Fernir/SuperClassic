-- author: ALZA

local settings = nil
local eventframe = CreateFrame("Frame")
local StartX, EndX = 305, 305
local StartY, EndY = 550, 300
local FontHeight = 25 -- this setting increase font quality

local locations = {}
local auras = nil

local function OnEvent(self, event, addon)
	if(addon=="Blizzard_CombatText") then
		COMBAT_TEXT_DEFLECT = "Deflect"
		COMBAT_TEXT_REFLECT = "Reflect"
		COMBAT_TEXT_IMMUNE = "Immune"
		COMBAT_TEXT_RESIST = "Resist"
		COMBAT_TEXT_ABSORB = "Absorb"
		COMBAT_TEXT_BLOCK = "Block"
		COMBAT_TEXT_DODGE = "Dodge"
		COMBAT_TEXT_PARRY = "Parry"
		COMBAT_TEXT_EVADE = "Evade"
		COMBAT_TEXT_MISS = "Miss"

		DEFLECT = "Deflect"
		REFLECT = "Reflect"
		IMMUNE = "Immune"
		RESIST = "Resist"
		ABSORB = "Absorb"
		BLOCK = "Block"
		DODGE = "Dodge"
		PARRY = "Parry"
		EVADE = "Evade"
		MISS = "Miss"

		BLOCK_TRAILER = "(Block %d)"
		ABSORB_TRAILER = "(Absorb %d)"
		RESIST_TRAILER = "(Resist %d)"

		ENTERING_COMBAT = "+COMBAT+"
		LEAVING_COMBAT = "-COMBAT-"

		COMBAT_TEXT_SCROLLSPEED = 2
		


		function CombatText_UpdateDisplayedMessages()
			if ( UnitHasVehicleUI("player") ) then
				CombatText.unit = "vehicle"
			else
				CombatText.unit = "player"
			end
			CombatTextSetActiveUnit(CombatText.unit)
			
			CombatText:RegisterEvent("UNIT_AURA")
			CombatText:RegisterEvent("COMBAT_TEXT_UPDATE")
			CombatText:RegisterEvent("UNIT_HEALTH")
			CombatText:RegisterEvent("UNIT_MANA")
			CombatText:RegisterEvent("PLAYER_REGEN_DISABLED")
			CombatText:RegisterEvent("PLAYER_REGEN_ENABLED")
			CombatText:RegisterEvent("PLAYER_COMBO_POINTS")
			CombatText:RegisterEvent("RUNE_POWER_UPDATE")
			CombatText:RegisterEvent("UNIT_ENTERED_VEHICLE")
			CombatText:RegisterEvent("UNIT_EXITING_VEHICLE")

			COMBAT_TEXT_Y_SCALE = WorldFrame:GetHeight() / 768
			COMBAT_TEXT_X_SCALE = WorldFrame:GetWidth() / 1024
			COMBAT_TEXT_SPACING = 10 * COMBAT_TEXT_Y_SCALE
			COMBAT_TEXT_MAX_OFFSET = 130 * COMBAT_TEXT_Y_SCALE
			COMBAT_TEXT_X_ADJUSTMENT = 80 * COMBAT_TEXT_X_SCALE

			for index, value in pairs(COMBAT_TEXT_TYPE_INFO) do
				if value.var then
					if _G[value.var] == "1" then
						value.show = 1
					else
						value.show = nil
					end
				end
			end

			COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll
			COMBAT_TEXT_LOCATIONS = locations

			CombatText_ClearAnimationList()
		end
		
		self:UnregisterEvent"ADDON_LOADED"
		OnEvent = nil
	end
end

local module = {}
module.name = "CombatText"
module.Init = function()
	if not SCDB.modules[module.name] then return end
	if SCDB[module.name] == nil then SCDB[module.name] = {} end
	if SCDB[module.name]["StartX"] == nil then SCDB[module.name]["StartX"] = 305 end
	if SCDB[module.name]["EndX"] == nil then SCDB[module.name]["EndX"] = 305 end
	if SCDB[module.name]["StartY"] == nil then SCDB[module.name]["StartY"] = 550 end
	if SCDB[module.name]["EndY"] == nil then SCDB[module.name]["EndY"] = 300 end
	if SCDB[module.name]["FontHeight"] == nil then SCDB[module.name]["FontHeight"] = 25 end
	local opts = SCDB[module.name]
	
	StartX, EndX = opts.StartX or 305, opts.EndX or 305
	StartY, EndY = opts.StartY or 550, opts.EndY or 300
	FontHeight = opts.FontHeight or 25
		
	COMBAT_TEXT_Y_SCALE = WorldFrame:GetHeight() / 768
	COMBAT_TEXT_X_SCALE = WorldFrame:GetWidth() / 1024
	locations = {
		startX = StartX / COMBAT_TEXT_X_SCALE,
		endX = EndX / COMBAT_TEXT_X_SCALE,
		startY = StartY / COMBAT_TEXT_Y_SCALE,
		endY = EndY / COMBAT_TEXT_Y_SCALE,
	}

	eventframe:RegisterEvent("ADDON_LOADED")
	eventframe:SetScript("OnEvent", OnEvent)


	if IsAddOnLoaded("Blizzard_CombatText") then 
		OnEvent(eventframe, "ADDON_LOADED", "Blizzard_CombatText")
	else
		LoadAddOn("Blizzard_CombatText")
	end
	
	if IsAddOnLoaded("Blizzard_AuctionUI") then 
		OnEvent(eventframe, "ADDON_LOADED", "Blizzard_AuctionUI")
	else
		LoadAddOn("Blizzard_AuctionUI")
	end
end
tinsert(SuperClassic.modules, module) -- finish him!