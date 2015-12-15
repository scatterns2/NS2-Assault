// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// Based on:
// lua\Weapons\Alien\HydraAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds Observatory.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'ObservatoryAbility' (Entity)

local kExtents = Vector(0.4, 0.5, 0.4) 
local function IsPathable(position)

    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end    

local kUpVector = Vector(0, 1, 0)
local kCheckDistance = 0.8 // bigger than onos
local kVerticalOffset = 0.3
local kVerticalSpace = 2

local kCheckDirections = 
{
    Vector(kCheckDistance, 0, -kCheckDistance),
    Vector(kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, -kCheckDistance),
}

function ObservatoryAbility:GetIsPositionValid(position, player, surfaceNormal)
    
    local valid = false

    /// allow only on even surfaces
    if surfaceNormal then
    
       if surfaceNormal:DotProduct(kUpVector) > 0.9 then
        
            valid = true
			
			local nearEntities = GetEntitiesWithMixinWithinRange("Construct", position, 1.5)
			if #nearEntities > 0 then
				valid = false
			elseif #nearEntities == 0 then
				valid = true
			end
			
            local startPos = position + Vector(0, kVerticalOffset, 0)
        
            for i = 1, #kCheckDirections do
            
                local traceStart = startPos + kCheckDirections[i]
            
                local trace = Shared.TraceRay(traceStart, traceStart - Vector(0, kVerticalOffset + 0.1, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOneAndIsa(player, "Babbler"))
            
                if trace.fraction < 0.60 or trace.fraction >= 1.0 then //the max slope a pg can be placed on.
                    valid = false
                    break
                end
            
            end
			
			if valid then
				valid = CheckSpaceForPhaseGate(kTechId.PhaseGate, position, nil, nil)
			end

        end

    end
    
    return valid
end


function ObservatoryAbility:AllowBackfacing()
    return false
end

function ObservatoryAbility:GetDropRange()
    return kGorgeCreateDistance
end

function ObservatoryAbility:GetRequiredTechId()
    return kTechId.Armory
end
function ObservatoryAbility:GetStoreBuildId()
    return false
end

function ObservatoryAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function ObservatoryAbility:GetGhostModelName(ability)
    return Observatory.kModelName
end

function ObservatoryAbility:GetDropStructureId()
    return kTechId.Observatory
end

function ObservatoryAbility:GetSuffixName()
    return "Observatory"
end

function ObservatoryAbility:GetDropClassName()
    return "Observatory"
end

function ObservatoryAbility:GetDropMapName()
    return Observatory.kMapName
end

function ObservatoryAbility:CreateStructure()
	return false
end

function ObservatoryAbility:IsAllowed(player)
    return true
end
