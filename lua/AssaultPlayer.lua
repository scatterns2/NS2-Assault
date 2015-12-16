Script.Load("lua/Player.lua")

	
function Player:AwardResForKill(amount)

    local resReward = self:AddResources(kPersonalResPerKill)
    
    if resReward > 0 then
        self:TriggerEffects("res_received")
    end
    
    return resReward
    
end


function PlayerUI_GetInventoryTechIds()

    PROFILE("PlayerUI_GetInventoryTechIds")
    
    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "WeaponOwner") then
    
        local inventoryTechIds = table.array(5)
        local weaponList = player:GetHUDOrderedWeaponList()
        
        for w = 1, #weaponList do
        
            local weapon = weaponList[w]
            table.insert(inventoryTechIds, { TechId = weapon:GetTechId(), HUDSlot = weapon:GetHUDSlot() })
            
        end
        
        return inventoryTechIds
        
    end
    return { }
    
end

if Client then
	local kEnemyObjectiveRange = 30
	function PlayerUI_GetObjectiveInfo()

		local player = Client.GetLocalPlayer()
		
		for index, techPoint in ipairs(GetEntitiesWithinRange("TechPoint", player:GetOrigin(), 5)) do
			return techPoint
		end
		
		for index, resPoint in ipairs(GetEntitiesWithinRange("ResourcePoint", player:GetOrigin(), 5)) do
			return resPoint
		end
		
		if player or techPoint or resPoint then

		
			if player.crossHairHealth and player.crossHairText then  
			
				player.showingObjective = true
				return player.crossHairHealth / 100, player.crossHairText .. " " .. ToString(player.crossHairHealth) .. "%", player.crossHairTeamType
				
			end
			
			
			
			-- check command structures in range (enemy or friend) and return health % and name
			local objectiveInfoEnts = EntityListToTable( Shared.GetEntitiesWithClassname("ObjectiveInfo") )
			local playersTeam = player:GetTeamNumber()
			
			local function SortByHealthAndTeam(ent1, ent2)
				return ent1:GetHealthScalar() < ent2:GetHealthScalar() and ent1.teamNumber == playersTeam
			end
			
			table.sort(objectiveInfoEnts, SortByHealthAndTeam)
			
			for _, objectiveInfoEnt in ipairs(objectiveInfoEnts) do
			
				if objectiveInfoEnt:GetIsInCombat() and ( playersTeam == objectiveInfoEnt:GetTeamNumber() or (player:GetOrigin() - objectiveInfoEnt:GetOrigin()):GetLength() < kEnemyObjectiveRange ) then

					local healthFraction = math.max(0.01, objectiveInfoEnt:GetHealthScalar())

					player.showingObjective = true
					
			
					local text = StringReformat(Locale.ResolveString("OBJECTIVE_PROGRESS"),
												{ location = objectiveInfoEnt:GetLocationName(),
												  name = GetDisplayNameForTechId(objectiveInfoEnt:GetTechId()),
												  health = math.ceil(healthFraction * 100) })
					
					return healthFraction, text, objectiveInfoEnt:GetTeamType()
					
				end
				
			end
			
			player.showingObjective = false
			
		end
		
	end

	function Player:SendKeyEvent(key, down)

		--When exit hit, bring up menu.
		if down and key == InputKey.Escape and (Shared.GetTime() > (self.timeLastMenu + 0.3) and not ChatUI_EnteringChatMessage()) then
		
			ExitPressed()
			self.timeLastMenu = Shared.GetTime()
			return true
			
		end
		
		if not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
		
			if GetIsBinding(key, "RequestHealth") then
				self.timeOfLastHealRequest = Shared.GetTime()
				self.medPackRequested = true
			end
			
			if GetIsBinding(key, "ShowMap") and not self:isa("Commander") then
				self:OnShowMap(down)
			end
			if GetIsBinding(key, "ShowMapCom") and self:isa("Commander") then
				self:OnShowMap(down)
			end
			
			if down then
			
				if GetIsBinding(key, "ReadyRoom") then
					Shared.ConsoleCommand("rr")
				elseif GetIsBinding(key, "TextChat") and not self:isa("Commander") then
					ChatUI_EnterChatMessage(false)
					return true
				elseif GetIsBinding(key, "TextChatCom") and self:isa("Commander") then        
					ChatUI_EnterChatMessage(false)
					return true                   
				elseif GetIsBinding(key, "TeamChat") and not self:isa("Commander") then        
					ChatUI_EnterChatMessage(true) 
					return true
				elseif GetIsBinding(key, "TeamChatCom") and self:isa("Commander") then            
					ChatUI_EnterChatMessage(true)
					return true 
				elseif GetIsBinding(key, "LastUpgrades") then
					Shared.ConsoleCommand("evolvelastupgrades")    
				elseif GetIsBinding(key, "ToggleMinimapNames") then
					local newValue = not Client.GetOptionBoolean("minimapNames", true)
					Client.SetOptionBoolean("minimapNames", newValue)
				elseif GetIsBinding(key, "Use") and Player_CanThrowObject( self ) then
					--Halloween2015
					Shared.ConsoleCommand("throwcandy")
				end
				
			end
			
			 if GetIsBinding(key, "Weapon6") then
				Shared.ConsoleCommand("slot6")
				return true
			end
			
			if GetIsBinding(key, "Weapon7") then
				Shared.ConsoleCommand("slot7")
				return true
			end
			
			if GetIsBinding(key, "Weapon8") then
				Shared.ConsoleCommand("slot8")
				return true
			end
			
			if GetIsBinding(key, "Weapon9") then
				Shared.ConsoleCommand("slot9")
				return true
			end
			
		
		end
		
		return false
		
	end
end
