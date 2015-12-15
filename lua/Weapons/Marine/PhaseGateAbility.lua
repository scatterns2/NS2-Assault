// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// Based on:
// lua\Weapons\Alien\HydraAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Gorge builds PhaseGate.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'PhaseGateAbility' (Entity)

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

function PhaseGateAbility:GetIsPositionValid(position, player, surfaceNormal)
    
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

function PhaseGateAbility:AllowBackfacing()
    return false
end

function PhaseGateAbility:GetDropRange()
    return kGorgeCreateDistance
end

function PhaseGateAbility:GetRequiredTechId()
    return kTechId.Observatory
end

function PhaseGateAbility:GetStoreBuildId()
    return false
end

function PhaseGateAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function PhaseGateAbility:GetGhostModelName(ability)
    return PhaseGate.kModelName
end

function PhaseGateAbility:GetDropStructureId()
    return kTechId.PhaseGate
end

function PhaseGateAbility:GetSuffixName()
    return "PhaseGate"
end

function PhaseGateAbility:GetDropClassName()
    return "PhaseGate"
end

function PhaseGateAbility:GetDropMapName()
    return PhaseGate.kMapName
end

function PhaseGateAbility:CreateStructure()
	return false
end

function PhaseGateAbility:IsAllowed(player)
    return true
end
