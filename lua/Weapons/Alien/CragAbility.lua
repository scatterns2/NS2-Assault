//
// lua\Weapons\Alien\CragAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'CragAbility' (StructureAbility)

function CragAbility:GetEnergyCost(player)
    return 0
end

function CragAbility:GetPrimaryAttackDelay()
    return 0
end

function CragAbility:GetGhostModelName(ability)
    return Crag.kModelName
end

function CragAbility:GetDropStructureId()
    return kTechId.Crag
end

function CragAbility:GetRequiredTechId()
    return kTechId.None
end

function CragAbility:GetSuffixName()
    return "crag"
end

function CragAbility:GetDropClassName()
    return "Crag"
end

function CragAbility:GetDropMapName()
    return Crag.kMapName
end
