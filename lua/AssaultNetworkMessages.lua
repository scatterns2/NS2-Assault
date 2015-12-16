
local kMarineBuildStructureMessage = 
{
    origin = "vector",
    direction = "vector",
    structureIndex = "integer (1 to 10)",
    lastClickedPosition = "vector"
}


function BuildMarineDropStructureMessage(origin, direction, structureIndex, lastClickedPosition)

    local t = {}
    
    t.origin = origin
    t.direction = direction
    t.structureIndex = structureIndex
    t.lastClickedPosition = lastClickedPosition or Vector(0,0,0)

    return t
    
end    

function ParseMarineBuildMessage(t)
    return t.origin, t.direction, t.structureIndex, t.lastClickedPosition
end


Shared.RegisterNetworkMessage("MarineBuildStructure", kMarineBuildStructureMessage)


local kTechPointsMessage =
{
    entityIndex = "entityid",
    teamNumber = string.format("integer (-1 to %d)", kSpectatorIndex),
    techId = "enum kTechId",
    location = "resource",
    healthFraction = "float (0 to 1 by 0.01)",
    powerNodeFraction = "float (0 to 1 by 0.01)",
    builtFraction = "float (0 to 1 by 0.01)",
    eggCount = "integer (0 to 63)"
}

function BuildTechPointsMessage(techPoint, powerNodes, eggs)

    local t = { }
    local techPointLocation = techPoint:GetLocationId()
    t.entityIndex = techPoint:GetId()
    t.location = techPointLocation
    t.teamNumber = techPoint.occupiedTeam
    t.techId = kTechId.None
    
    local structure = Shared.GetEntity(techPoint.attachedId)
    
    if structure then
    
        local eggCount = 0
        for _, egg in ientitylist(eggs) do
        
            if egg:GetLocationId() == techPointLocation and egg:GetIsAlive() and egg:GetIsEmpty() then
                eggCount = eggCount + 1
            end
            
        end
        
        t.eggCount = eggCount
        
        for _, powerNode in ientitylist(powerNodes) do
        
            if powerNode:GetLocationId() == techPointLocation then
            
                if powerNode:GetIsSocketed() then
                    t.powerNodeFraction = powerNode:GetHealthScalar()
                else
                    t.powerNodeFraction = 0
                end
                
                break
                
            end
            
        end
        
        t.teamNumber = structure:GetTeamNumber()
        t.techId = structure:GetTechId()
        if structure:GetIsAlive() then
        
            -- Structure may not have a GetBuiltFraction() function (Hallucinations for example).
            t.builtFraction = structure.GetBuiltFraction and structure:GetBuiltFraction() or 0
            t.healthFraction= structure:GetHealthScalar()
            
        else
        
            t.builtFraction = 0
            t.healthFraction= 0
            
        end
        
        return t
        
    end
    
    return t
    
end

Shared.RegisterNetworkMessage( "TechPoints", kTechPointsMessage )

if Client then

	function OnCommandTechPoints(techPointsTable)

		Insight_SetTechPoint(techPointsTable.entityIndex, techPointsTable.teamNumber, techPointsTable.techId,
			techPointsTable.location, techPointsTable.healthFraction, techPointsTable.powerNodeFraction,
			techPointsTable.builtFraction, techPointsTable.eggCount)

	end

	Client.HookNetworkMessage("TechPoints", OnCommandTechPoints)
end	


local kGorgeBuildStructureMessage = 
{
    origin = "vector",
    direction = "vector",
    structureIndex = "integer (1 to 9)",
    lastClickedPosition = "vector"
}

Shared.RegisterNetworkMessage("GorgeBuildStructure", kGorgeBuildStructureMessage)
