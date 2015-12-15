

function OnCommandMarineBuildStructure(client, message)

    local player = client:GetControllingPlayer()
    local origin, direction, structureIndex, lastClickedPosition = ParseMarineBuildMessage(message)
    
    local dropStructureAbility = player:GetWeapon(MarineStructureAbility.kMapName)
    // The player may not have an active weapon if the message is sent
    // after the player has gone back to the ready room for example.
    if dropStructureAbility then
        dropStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition)
    end
    
end

Server.HookNetworkMessage("MarineBuildStructure", OnCommandMarineBuildStructure)