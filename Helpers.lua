local module = {}
module.name = "Helpers"
module.Init = function()
	if not SCDB.modules[module.name] then return end
   if SCDB[module.name] == nil then SCDB[module.name] = {} end
   if SCDB[module.name]["AutoGreedOnGreen"] == nil then SCDB[module.name]["AutoGreedOnGreen"] = true end
	if SCDB[module.name]["AutoRepair"] == nil then SCDB[module.name]["AutoRepair"] = true end
	if SCDB[module.name]["SellGreyCrap"] == nil then SCDB[module.name]["SellGreyCrap"] = true end
	if SCDB[module.name]["AcceptInvites"] == nil then SCDB[module.name]["AcceptInvites"] = true end
	if SCDB[module.name]["Hide errors"] == nil then SCDB[module.name]["Hide errors"] = true end
	if SCDB[module.name]["FishingHelper"] == nil then SCDB[module.name]["FishingHelper"] = true end
   
   local opts = SCDB[module.name]
   
   SlashCmdList.RELOADUI = ReloadUI
   SLASH_RELOADUI1 = "/rl"
   SLASH_RELOADUI2 = "/кд"

   SlashCmdList.RCSLASH = DoReadyCheck
   SLASH_RCSLASH1 = "/rc"
   SLASH_RCSLASH2 = "/кс"

    
   --[[ Clear UIErrors frame ]]
   UIErrorsFrame:SetScale(0.8)
   WatchFrameTitle:SetAlpha(0)

   -- Disabled WoW's combat log at startup
   local f = CreateFrame("Frame")
   f:SetScript("OnEvent", function()  
      f:UnregisterEvent("PLAYER_ENTERING_WORLD")
      COMBATLOG:UnregisterAllEvents()
   end)
   f:RegisterEvent("PLAYER_ENTERING_WORLD")
   
   if opts["Hide errors"] then
      local eframe = {
         [0] = CreateFrame("frame", nil, UIParent),
         [1] = CreateFrame("frame", nil, UIParent),
      }
      
      for i = 0, 1 do
         eframe[i]:SetScript("OnUpdate", FadingFrame_OnUpdate)
         eframe[i].fadeInTime = 0.08
         eframe[i].fadeOutTime = 0.16
         eframe[i].holdTime = 1.5
         eframe[i]:Hide()
         eframe[i]:SetFrameStrata("TOOLTIP")
         eframe[i]:SetFrameLevel(30)
         eframe[i].text = eframe[i]:CreateFontString(nil, "OVERLAY")
         eframe[i].text:SetShadowOffset(1,-1)
         eframe[i].text:SetPoint("TOP", UIParent, 0, -100-(i+1) * 15)
         eframe[i].text:SetFont(SCDB["Main"].Font, 15, "OUTLINE")
         eframe[i].text:SetTextColor(1, 1, 1)
      end
      
      local blocked = {
         SPELL_FAILED_NO_COMBO_POINTS,
         SPELL_FAILED_TARGETS_DEAD,
         SPELL_FAILED_SPELL_IN_PROGRESS,
         SPELL_FAILED_TARGET_AURASTATE,
         SPELL_FAILED_CASTER_AURASTATE,
         SPELL_FAILED_NO_ENDURANCE,
         --SPELL_FAILED_BAD_TARGETS,
         SPELL_FAILED_NOT_MOUNTED,
         SPELL_FAILED_NOT_ON_TAXI,
         SPELL_FAILED_NOT_INFRONT,
         SPELL_FAILED_NOT_IN_CONTROL,
         SPELL_FAILED_MOVING,
         ERR_ATTACK_FLEEING,
         ERR_ITEM_COOLDOWN,
         ERR_GENERIC_NO_TARGET,
         ERR_ABILITY_COOLDOWN,
         ERR_OUT_OF_ENERGY,
         ERR_NO_ATTACK_TARGET,
         ERR_SPELL_COOLDOWN,
         --ERR_OUT_OF_RAGE,
         ERR_INVALID_ATTACK_TARGET,
         ERR_NOEMOTEWHILERUNNING,
         OUT_OF_ENERGY,
      }
      
      
      local Error = CreateFrame("Frame")
      UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
      UIErrorsFrame:UnregisterEvent("SYSMSG")
      UIErrorsFrame:UnregisterEvent("UI_INFO_MESSAGE")
      local state = 0
      eframe[0]:SetScript("OnHide",function() state = 0 end)
      local allertIt = function(_,_,error)
         for i, err in pairs(blocked) do
            if error:find(err) then return end
         end
         if state == 0 then 
            eframe[0].text:SetText(error)
            FadingFrame_Show(eframe[0])
            state = 1
          else 
            eframe[1].text:SetText(error)
            FadingFrame_Show(eframe[1])
            state = 0
          end
      end
      Error:RegisterEvent("UI_ERROR_MESSAGE")
      Error:RegisterEvent("SYSMSG");
      Error:RegisterEvent("UI_INFO_MESSAGE");

      Error:SetScript("OnEvent",allertIt)
   end

   --[[ Autogreed on green items ]]
   if opts.AutoGreedOnGreen then
       local f = CreateFrame("Frame")
       f:RegisterEvent("START_LOOT_ROLL")
       f:SetScript("OnEvent", function(_, _, id)
           if(id and select(4, GetLootRollItemInfo(id))==2) then
               RollOnLoot(id, 2)
           end
       end)
   end
   
   if opts.FishingHelper then
   
      local function lureEquipped()
         GameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
         GameTooltip:ClearLines()
         GameTooltip:SetInventoryItem("player", 16)
         for i = 1, GameTooltip:NumLines() do
            local txt = getglobal("GameTooltipTextLeft" .. i)
            if txt then 
               txt = txt:GetText()
               if txt:lower():find("lure") or txt:lower():find("удочка") then
                  GameTooltip:ClearLines()
                  GameTooltip:Hide()
                  return true
               end
            end
         end
         GameTooltip:Hide()
         return false
      end

      local lastClickTime = nil
      local function CheckForDoubleClick()
         if lastClickTime then
            local pressTime = GetTime()
            local doubleTime = pressTime - lastClickTime
            lastClickTime = pressTime
            if doubleTime < .4 then
               return true
            end
         end
         lastClickTime = GetTime()
         return false
      end

      local fbtn = CreateFrame("CheckButton", "FishingButton", UIParent, "SecureActionButtonTemplate")
      fbtn:SetFrameStrata("LOW")
      fbtn:EnableMouse(true)
      fbtn:RegisterForClicks("RightButtonUp")
      fbtn:Hide()
      
      WorldFrame:HookScript("OnMouseDown", function(self, button, ...)
         if not InCombatLockdown() and button == "RightButton" and lureEquipped() then
            if CheckForDoubleClick() then
               local spn = GetSpellInfo(18248)
               fbtn:SetAttribute("type", "spell")
               fbtn:SetAttribute("spell", spn)
               SetOverrideBindingClick(fbtn, true, "BUTTON2", "FishingButton")
            else
               ClearOverrideBindings(fbtn)
            end
         else
            ClearOverrideBindings(fbtn)
         end
      end)
   end

   --[[ Accept invites ]]
   if opts.AcceptInvites then
       local IsFriend = function(name)
           for i=1, GetNumFriends() do if(GetFriendInfo(i)==name) then return true end end
           if(IsInGuild()) then for i=1, GetNumGuildMembers() do if(GetGuildRosterInfo(i)==name) then return true end end end
       end

       local ai = CreateFrame("Frame")
       ai:RegisterEvent("PARTY_INVITE_REQUEST")
       ai:SetScript("OnEvent", function(frame, event, name)
           if(IsFriend(name)) then
               AcceptGroup()
               for i = 1, 4 do
                   local frame = _G["StaticPopup"..i]
                   if(frame:IsVisible() and frame.which=="PARTY_INVITE") then
                       frame.inviteAccepted = 1
                       StaticPopup_Hide("PARTY_INVITE")
                       return
                   end
               end
           else
               SendWho(name)
           end
       end)
   end

   hooksecurefunc("WorldStateAlwaysUpFrame_Update", function()
      for i = 1, NUM_EXTENDED_UI_FRAMES do
         local cb = _G["WorldStateCaptureBar"..i]
            if cb and cb:IsShown() then
            cb:ClearAllPoints()
            cb:SetPoint("TOP", UIParent, "TOP", -100, -120)
         end
      end
   end)

   local sells, tmp_money = 0, 0
   local eframe = CreateFrame("Frame")
   eframe:SetScript("OnEvent", function(self, event, ...)
      if event == "MERCHANT_SHOW" then
         if (opts.AutoRepair and CanMerchantRepair()) then
            -- чинимся
            local cost, money = GetRepairAllCost(), GetMoney()
            if (not cost or cost==0) then return end
            local CanGuildRepair = IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() > cost and GetGuildBankMoney() > cost
            if(CanGuildRepair) then
               self.isrepair = true
               RepairAllItems(1)
               print(string.format("Guild bank repair cost: %s", GetCoinTextureString(math.min(cost, money))))
            elseif(GetMoney() > cost) then
               self.isrepair = true
               RepairAllItems()
               print(string.format("Repair cost: %s", GetCoinTextureString(math.min(cost, money))))
            end
         end

         if (opts.SellGreyCrap) then
            -- продаем мусор
            local bag,slot 
            tmp_money = GetMoney()
            for bag = 0,4 do
               if GetContainerNumSlots(bag) > 0 then
                  for slot = 0, GetContainerNumSlots(bag) do
                     local link = GetContainerItemLink(bag,slot)
                     if(link) then
                        local _,_,i_rar=GetItemInfo(link)
                        if i_rar == 0 then
                           UseContainerItem(bag,slot)
                           sells = sells + GetItemCount(link)
                        end
                     end
                  end
               end
            end
         end
      elseif event == "PLAYER_MONEY" then
         if (sells > 0) then
            tmp_money = math.abs(GetMoney() - tmp_money)
            print(string.format("Sold %d items for %s", sells, GetCoinTextureString(tmp_money)))
            sells = 0
         else
            tmp_money = GetMoney()
         end
      end
   end)
   eframe:RegisterEvent("MERCHANT_SHOW")
   eframe:RegisterEvent("PLAYER_MONEY")
   
end
tinsert(SuperClassic.modules, module) -- finish him!