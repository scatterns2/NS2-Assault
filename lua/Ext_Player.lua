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

